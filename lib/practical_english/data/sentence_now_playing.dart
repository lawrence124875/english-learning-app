import 'dart:async';

import '../../data/sources/cover_art.dart';
import '../../data/sources/tts_audio_handler.dart';
import '../domain/models/sentence.dart';
import '../presentation/providers/sentence_player.dart';

/// 句子播放時接管 V1 的背景播放服務（鎖屏／通知列卡片與按鈕）。
///
/// - 第一次 [show] 時接管：鎖屏的播放／暫停／上一句／下一句改由 [SentencePlayer]
///   處理（上一句／下一句＝手動，會停止連續播放並只念一次）。
/// - [release]（離開句子頁、V1 開始朗讀）時交還，V1 的卡片恢復原狀。
/// - 有播放中的卡片，Android 前景服務就會保持，關螢幕也能繼續念。
class AudioHandlerSentenceNowPlaying implements SentenceNowPlaying {
  final TtsAudioHandler _handler;
  final SentencePlayer _player;
  final Object _owner = Object();
  int _gen = 0;

  AudioHandlerSentenceNowPlaying(this._handler, this._player);

  @override
  void show(Sentence sentence,
      {String? subtitle,
      required bool playing,
      required int position,
      required int total}) {
    if (!_handler.isOverriddenBy(_owner)) {
      _handler.setOverride(NowPlayingOverride(
        owner: _owner,
        // 連續播放的 Future 要等整個迴圈結束，按鈕處理不能等它。
        onPlay: () async => unawaited(_player.play()),
        onPause: _player.pause,
        onSkipNext: () async => unawaited(_player.next()),
        onSkipPrevious: () async => unawaited(_player.previous()),
      ));
    }
    // 連續快速換句時只送最後一次（同 V1）。
    final gen = ++_gen;
    void push(Uri? art) {
      if (gen != _gen) return;
      _handler.updateOverrideNowPlaying(
        _owner,
        id: sentence.id,
        title: sentence.sentenceText,
        subtitle: subtitle ?? '',
        playing: playing,
        currentIndex: position,
        totalCount: total,
        artUri: art,
      );
    }

    CoverArt.lockScreen()
        .timeout(const Duration(seconds: 2))
        .then(push, onError: (_) => push(null));
  }

  @override
  void release() {
    _gen++;
    _handler.releaseOverride(_owner);
  }
}
