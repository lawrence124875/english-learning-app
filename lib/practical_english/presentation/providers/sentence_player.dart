import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/sources/tts_service.dart';
import '../../domain/models/pe_language.dart';
import '../../domain/models/sentence.dart';
import '../../domain/services/playback_coordinator.dart';
import 'practical_english_state.dart';

/// 句子連續播放的設定（只影響實用英文；語速與 V1 共用，不在這裡）。
@immutable
class SentencePlaybackSettings {
  /// 念完英文後是否接著念翻譯（有翻譯、手機有語音時）。
  final bool readTranslation;

  /// 每句英文念幾次（1–3）。
  final int repeatCount;

  /// 句子之間的間隔秒數。
  final double intervalSeconds;

  const SentencePlaybackSettings({
    this.readTranslation = true,
    this.repeatCount = 2,
    this.intervalSeconds = 2,
  });

  SentencePlaybackSettings copyWith({
    bool? readTranslation,
    int? repeatCount,
    double? intervalSeconds,
  }) =>
      SentencePlaybackSettings(
        readTranslation: readTranslation ?? this.readTranslation,
        repeatCount: repeatCount ?? this.repeatCount,
        intervalSeconds: intervalSeconds ?? this.intervalSeconds,
      );

  Map<String, dynamic> toJson() => {
        'readTranslation': readTranslation,
        'repeatCount': repeatCount,
        'intervalSeconds': intervalSeconds,
      };

  /// 壞掉或超出範圍的值改用預設，不丟例外。
  factory SentencePlaybackSettings.fromJson(Map<String, dynamic> json) {
    const d = SentencePlaybackSettings();
    final repeat = json['repeatCount'];
    final interval = json['intervalSeconds'];
    return SentencePlaybackSettings(
      readTranslation: json['readTranslation'] is bool
          ? json['readTranslation'] as bool
          : d.readTranslation,
      repeatCount:
          repeat is int && repeat >= 1 && repeat <= 3 ? repeat : d.repeatCount,
      intervalSeconds: interval is num && interval >= 0 && interval <= 10
          ? interval.toDouble()
          : d.intervalSeconds,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is SentencePlaybackSettings &&
      other.readTranslation == readTranslation &&
      other.repeatCount == repeatCount &&
      other.intervalSeconds == intervalSeconds;

  @override
  int get hashCode =>
      Object.hash(readTranslation, repeatCount, intervalSeconds);
}

/// 鎖屏／通知列顯示（C3）。實作見 `AudioHandlerSentenceNowPlaying`。
abstract class SentenceNowPlaying {
  /// 顯示目前句子；第一次呼叫時接管鎖屏按鈕。
  void show(Sentence sentence,
      {String? subtitle,
      required bool playing,
      required int position,
      required int total});

  /// 交還鎖屏給 V1。
  void release();
}

/// 句子頁的播放器：連續播放（英文 × N → 翻譯 → 間隔 → 下一句）與手動逐句播放。
///
/// 同步規則（Lawrence 2026-10-09）：
/// - 畫面顯示哪一句就念哪一句。每次換句或重念都換一個世代編號，
///   舊的朗讀流程在任何 await 之後發現編號過期就不再開口（同 V1 `_speakGen`）。
/// - 手動上一句／下一句／重念（含鎖屏按鈕）會先停止連續播放，再只念那一句一次。
/// - 與 V1 共用 TTS：開口前經 [PlaybackCoordinator] 取得 V2 所有權；
///   被 V1 接手（lease 失效）就停止連續播放。
///
/// 只活在句子頁：頁面關閉時 [dispose] 停止朗讀並歸還所有權。
class SentencePlayer extends ChangeNotifier {
  final PracticalEnglishState _state;
  final TtsService _tts;
  final PlaybackCoordinator _playback;
  final Future<void> Function(Duration)? _delay;
  final void Function(Object error, StackTrace stack)? _onError;

  /// 進入句子頁時的列表快照；標記弱字等造成的重新排序不影響這裡的順序。
  final List<Sentence> sentences;

  /// 手機沒有某翻譯語言的語音時呼叫（每種語言只呼叫一次）。
  void Function(String languageCode)? onVoiceUnavailable;

  SentencePlayer({
    required PracticalEnglishState state,
    required TtsService tts,
    required PlaybackCoordinator playback,
    required this.sentences,
    int initialIndex = 0,
    Future<void> Function(Duration)? delay,
    void Function(Object, StackTrace)? onError,
    SentenceNowPlaying Function(SentencePlayer player)? nowPlaying,
  })  : assert(sentences.isNotEmpty),
        _state = state,
        _tts = tts,
        _playback = playback,
        _delay = delay,
        _onError = onError,
        _index = initialIndex.clamp(0, sentences.length - 1) {
    _nowPlaying = nowPlaying?.call(this);
    _playback.addClaimListener(_onClaim);
  }

  SentenceNowPlaying? _nowPlaying;

  /// 已接管鎖屏（第一次開口後），直到被 V1 接手或離開頁面。
  bool _onLockScreen = false;

  static const prefsKey = 'pe_playback_v1';

  SentencePlaybackSettings _settings = const SentencePlaybackSettings();
  SentencePlaybackSettings get settings => _settings;

  int _index;
  int get index => _index;
  Sentence get current => sentences[_index];

  bool _autoPlaying = false;

  /// 連續播放中（按鈕顯示「暫停」）。
  bool get isAutoPlaying => _autoPlaying;

  /// 這個播放器目前擁有朗讀（正在念或連續播放的間隔中）。
  bool get isActive => _playback.isCurrent(_lease);

  PlaybackLease? _lease;
  int _speakGen = 0;
  int _loopGen = 0;
  bool _disposed = false;
  final Set<String> _voiceWarned = {};

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(prefsKey);
      if (raw != null) {
        _settings = SentencePlaybackSettings.fromJson(
            jsonDecode(raw) as Map<String, dynamic>);
      }
    } catch (e, st) {
      _onError?.call(e, st);
    }
    _notify();
  }

  Future<void> updateSettings(SentencePlaybackSettings value) async {
    if (value == _settings) return;
    _settings = value;
    _notify();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(prefsKey, jsonEncode(value.toJson()));
    } catch (e, st) {
      _onError?.call(e, st);
    }
  }

  // ---------------- 操作 ----------------

  /// 開始連續播放（從目前這句開始念）。
  Future<void> play() async {
    if (_autoPlaying || _disposed) return;
    _autoPlaying = true;
    _notify();
    final loop = ++_loopGen;
    bool alive() => _autoPlaying && loop == _loopGen && !_disposed;
    while (alive()) {
      await _speakCurrent();
      if (!alive()) break;
      if (!isActive) {
        _endAuto(); // V1 接手或朗讀失敗
        break;
      }
      await _wait(
          Duration(milliseconds: (_settings.intervalSeconds * 1000).round()));
      if (!alive()) break;
      if (!isActive) {
        _endAuto();
        break;
      }
      _moveTo(_index + 1);
    }
  }

  /// 暫停連續播放並停止朗讀。
  Future<void> pause() async {
    final wasActive = isActive;
    _autoPlaying = false;
    _loopGen++;
    _cancelInterval();
    _speakGen++;
    _releaseLease();
    _notify();
    if (wasActive) await _stopTts();
  }

  Future<void> togglePlay() => _autoPlaying ? pause() : play();

  /// 手動下一句。回傳 true 表示因此停止了連續播放（畫面可提示一次）。
  Future<bool> next() => _manual(_index + 1);

  /// 手動上一句。回傳值同 [next]。
  Future<bool> previous() => _manual(_index - 1);

  /// 重念目前這句一次。回傳值同 [next]。
  Future<bool> replay() => _manual(_index);

  /// 跳到某一句（例如從清單點選），只念一次。回傳值同 [next]。
  Future<bool> jumpTo(int index) => _manual(index);

  Future<bool> _manual(int target) async {
    if (_disposed) return false;
    final stoppedAuto = _autoPlaying;
    if (stoppedAuto) {
      _autoPlaying = false;
      _loopGen++;
      _cancelInterval();
    }
    if (target != _index) {
      _moveTo(target);
    } else if (stoppedAuto) {
      _notify();
    }
    final done = _speakCurrent();
    await done;
    return stoppedAuto;
  }

  /// 換句（頭尾相接）。換句即讓進行中的朗讀過期。
  void _moveTo(int target) {
    final n = sentences.length;
    _index = ((target % n) + n) % n;
    _speakGen++;
    _state.recordPractice(current);
    _notify();
  }

  // ---------------- 朗讀 ----------------

  /// 念目前這句：英文 × repeatCount，然後（開啟時）翻譯。
  /// 開始前停掉上一句；每個 await 之後確認世代與所有權仍有效。
  Future<void> _speakCurrent() async {
    final gen = ++_speakGen;
    bool valid() => gen == _speakGen && !_disposed && isActive;
    try {
      if (!isActive) {
        final lease = await _playback.claim(PlaybackOwner.v2);
        if (!_playback.isCurrent(lease) || gen != _speakGen || _disposed) {
          return;
        }
        _lease = lease;
        if (_nowPlaying != null) _onLockScreen = true;
        _publishNowPlaying();
      }
      await _tts.stop();
      if (!valid()) return;
      final sentence = current;
      for (var i = 0; i < _settings.repeatCount; i++) {
        await _tts.speak(sentence.sentenceText,
            languageCode: sentence.targetLanguage);
        if (!valid()) return;
      }
      if (_settings.readTranslation) {
        await _speakTranslation(sentence, valid);
      }
    } catch (e, st) {
      _onError?.call(e, st);
      if (gen == _speakGen) _endAuto();
    } finally {
      // 手動逐句：念完就歸還；連續播放在間隔中仍保有所有權。
      if (gen == _speakGen && !_autoPlaying) _releaseLease();
    }
  }

  Future<void> _speakTranslation(
      Sentence sentence, bool Function() valid) async {
    final translation = _state.translationFor(sentence);
    final language =
        translation == null ? null : PeLanguages.lookup(translation.code);
    if (translation == null || language == null) return;
    final voice = await _state.checkVoice(language.ttsCode);
    if (!valid()) return;
    if (voice == PeVoiceStatus.unavailable) {
      if (_voiceWarned.add(language.code)) {
        onVoiceUnavailable?.call(language.code);
      }
      return;
    }
    await _tts.speak(translation.text, languageCode: language.ttsCode);
  }

  void _endAuto() {
    if (!_autoPlaying) return;
    _autoPlaying = false;
    _loopGen++;
    _cancelInterval();
    _releaseLease();
    _notify();
  }

  Timer? _intervalTimer;
  Completer<void>? _intervalDone;

  /// 句子間隔。停止連續播放時立即取消，不留下計時器。
  Future<void> _wait(Duration d) {
    final custom = _delay;
    if (custom != null) return custom(d);
    final done = Completer<void>();
    _intervalDone = done;
    _intervalTimer = Timer(d, () {
      if (!done.isCompleted) done.complete();
    });
    return done.future;
  }

  void _cancelInterval() {
    _intervalTimer?.cancel();
    _intervalTimer = null;
    final done = _intervalDone;
    _intervalDone = null;
    if (done != null && !done.isCompleted) done.complete();
  }

  void _releaseLease() {
    _playback.release(_lease);
    _lease = null;
  }

  Future<void> _stopTts() async {
    try {
      await _tts.stop();
    } catch (e, st) {
      _onError?.call(e, st);
    }
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
    _publishNowPlaying();
  }

  void _publishNowPlaying() {
    final sink = _nowPlaying;
    if (sink == null || !_onLockScreen || _disposed) return;
    sink.show(
      current,
      subtitle: _settings.readTranslation
          ? _state.translationFor(current)?.text
          : null,
      playing: _autoPlaying,
      position: _index + 1,
      total: sentences.length,
    );
  }

  /// 另一方（V1 巡航、鎖屏以外的播放）開始朗讀：停止連續播放並交還鎖屏。
  void _onClaim(PlaybackOwner who) {
    if (who == PlaybackOwner.v2 || _disposed) return;
    _autoPlaying = false;
    _loopGen++;
    _cancelInterval();
    _speakGen++;
    _lease = null;
    if (_onLockScreen) {
      _onLockScreen = false;
      _nowPlaying?.release();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    final wasActive = isActive;
    _disposed = true;
    _autoPlaying = false;
    _loopGen++;
    _cancelInterval();
    _speakGen++;
    _releaseLease();
    _playback.removeClaimListener(_onClaim);
    if (_onLockScreen) {
      _onLockScreen = false;
      _nowPlaying?.release();
    }
    if (wasActive) unawaited(_stopTts());
    super.dispose();
  }
}
