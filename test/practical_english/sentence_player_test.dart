import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:english_learning_app/data/repositories/progress_repository.dart';
import 'package:english_learning_app/data/repositories/word_repository.dart';
import 'package:english_learning_app/data/sources/tts_service.dart';
import 'package:english_learning_app/domain/models/playback_settings.dart';
import 'package:english_learning_app/domain/models/word_item.dart';
import 'package:english_learning_app/practical_english/data/sentence_repository.dart';
import 'package:english_learning_app/practical_english/domain/models/sentence.dart';
import 'package:english_learning_app/practical_english/domain/services/playback_coordinator.dart';
import 'package:english_learning_app/practical_english/presentation/providers/practical_english_state.dart';
import 'package:english_learning_app/practical_english/presentation/providers/sentence_player.dart';
import 'package:english_learning_app/presentation/providers/app_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 模擬 flutter_tts（awaitSpeakCompletion=true）：speak 直到 [finish] 或 stop 才完成。
class _GateTts implements TtsService {
  final events = <String>[];
  final _pending = <Completer<void>>[];
  String? speaking;
  int maxConcurrent = 0;

  @override
  Future<void> speak(String text, {required String languageCode}) async {
    events.add('speak:$text');
    speaking = text;
    final c = Completer<void>();
    _pending.add(c);
    if (_pending.length > maxConcurrent) maxConcurrent = _pending.length;
    await c.future;
  }

  void finish() {
    speaking = null;
    for (final c in List.of(_pending)) {
      if (!c.isCompleted) c.complete();
    }
    _pending.clear();
  }

  @override
  Future<void> stop() async {
    events.add('stop');
    finish();
  }

  @override
  Future<void> setRate(double rate) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeSink implements SentenceNowPlaying {
  final shown = <String>[];
  int releases = 0;

  @override
  void show(Sentence sentence,
      {String? subtitle,
      required bool playing,
      required int position,
      required int total}) {
    shown.add(
        '${sentence.sentenceText}|${subtitle ?? ''}|$playing|$position/$total');
  }

  @override
  void release() => releases++;
}

class _NoWords implements WordRepository {
  @override
  Future<List<WordDataset>> loadAllDatasets() async => [];
}

WordDataset _ds() => WordDataset(
      id: 'ngsl_2809',
      name: 'NGSL',
      shortName: 'NGSL',
      builtIn: true,
      items: [
        for (var i = 0; i < 8; i++)
          WordItem(
              id: 'ngsl_2809_${'$i'.padLeft(4, '0')}',
              word: 'w$i',
              translations: const {}),
      ],
    );

final _coreJson = jsonEncode({
  'schema': 1,
  'datasetId': 'pe_core',
  'sentences': [
    for (var i = 0; i < 8; i++)
      {
        'id': 'pe_core_00000${i + 1}',
        'wordIds': ['ngsl_2809_000$i'],
        'datasetId': 'pe_core',
        'targetLanguage': 'en-US',
        'sentenceText': 'S$i.',
        'translations': {'zh-TW': '句$i'},
      },
  ],
});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  late _GateTts tts;
  late AppState app;
  late PracticalEnglishState pe;
  final players = <SentencePlayer>[];
  var voice = PeVoiceStatus.available;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    voice = PeVoiceStatus.available;
    dir = await Directory.systemTemp.createTemp('pe_player');
    tts = _GateTts();
    app = AppState(
      wordRepository: _NoWords(),
      progressRepository: ProgressRepository(),
      ttsService: tts,
    );
    app.debugPreview(
      data: [_ds()],
      premium: true,
      newSettings: const PlaybackSettings(
          scopeMode: ScopeMode.allSequential,
          repeatCount: 1,
          readMode: ReadMode.englishOnly,
          intervalSeconds: 0.01),
    );
    pe = PracticalEnglishState(
      appState: app,
      tts: tts,
      sentences: SentenceRepository(
          loadBuiltInAsset: () async => _coreJson, baseDir: () async => dir),
      baseDir: () async => dir,
      onError: (e, st) => fail('$e\n$st'),
      translationKey: () => 'zh-TW',
      checkVoice: (_) async => voice,
    );
    await pe.load();
  });

  tearDown(() async {
    for (final p in players) {
      p.dispose();
    }
    players.clear();
    app.stopCruise();
    tts.finish();
    pe.dispose();
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await dir.delete(recursive: true);
  });

  SentencePlayer player({int index = 0, _FakeSink? sink}) {
    final p = SentencePlayer(
      nowPlaying: sink == null ? null : (_) => sink,
      state: pe,
      tts: tts,
      playback: app.playbackCoordinator,
      sentences: pe.sentences,
      initialIndex: index,
      delay: (_) => Future<void>.delayed(const Duration(milliseconds: 1)),
      onError: (e, st) => fail('$e\n$st'),
    );
    players.add(p);
    return p;
  }

  Future<void> tick() => Future<void>.delayed(const Duration(milliseconds: 5));

  List<String> speaks() =>
      tts.events.where((e) => e.startsWith('speak:')).toList();

  test('auto: English × repeat, translation, interval, next sentence',
      () async {
    final p = player();
    unawaited(p.play());
    await tick();
    expect(p.isAutoPlaying, isTrue);
    expect(app.playbackCoordinator.owner, PlaybackOwner.v2);
    expect(tts.speaking, 'S0.');
    tts.finish();
    await tick();
    expect(tts.speaking, 'S0.'); // 第二次
    tts.finish();
    await tick();
    expect(tts.speaking, '句0');
    tts.finish();
    await tick();
    expect(p.index, 1);
    expect(tts.speaking, 'S1.',
        reason: 'speech follows the displayed sentence');
    expect(speaks(), ['speak:S0.', 'speak:S0.', 'speak:句0', 'speak:S1.']);
  });

  test('manual next during auto stops auto and plays that sentence once',
      () async {
    final p = player();
    await p.updateSettings(p.settings.copyWith(repeatCount: 1));
    unawaited(p.play());
    await tick();
    expect(tts.speaking, 'S0.');
    final stopped = p.next();
    await tick();
    expect(p.isAutoPlaying, isFalse);
    expect(p.index, 1);
    expect(tts.speaking, 'S1.');
    tts.finish(); // 英文
    await tick();
    tts.finish(); // 翻譯
    expect(await stopped, isTrue);
    await tick();
    expect(p.index, 1, reason: 'no auto advance after a manual tap');
    expect(app.playbackCoordinator.owner, PlaybackOwner.none);
    expect(speaks(), ['speak:S0.', 'speak:S1.', 'speak:句1']);
    // 再按一次：只念一次，回傳 false（已不是連續播放）
    final again = p.next();
    await tick();
    expect(tts.speaking, 'S2.');
    tts.finish();
    await tick();
    tts.finish();
    expect(await again, isFalse);
  });

  test('rapid taps: only the last displayed sentence is spoken', () async {
    final p = player();
    await p.updateSettings(p.settings.copyWith(readTranslation: false));
    final futures = [for (var i = 0; i < 5; i++) p.next()];
    await tick();
    expect(p.index, 5);
    expect(tts.speaking, 'S5.');
    expect(speaks().last, 'speak:S5.');
    // 中間的句子沒有一句在最後一次 stop 之後還開口
    final lastStop = tts.events.lastIndexOf('stop');
    expect(tts.events.sublist(lastStop + 1), ['speak:S5.']);
    tts.finish();
    await tick();
    tts.finish();
    await Future.wait(futures);
    expect(tts.maxConcurrent, 1);
  });

  test('rapid taps while auto playing stay in sync', () async {
    final p = player();
    unawaited(p.play());
    await tick();
    for (var i = 0; i < 3; i++) {
      unawaited(p.next());
    }
    unawaited(p.previous());
    await tick();
    expect(p.isAutoPlaying, isFalse);
    expect(p.index, 2);
    expect(tts.speaking, 'S2.');
    expect(tts.maxConcurrent, 1);
  });

  test('pause stops speech and releases ownership', () async {
    final p = player();
    unawaited(p.play());
    await tick();
    await p.pause();
    expect(p.isAutoPlaying, isFalse);
    expect(tts.speaking, isNull);
    expect(app.playbackCoordinator.owner, PlaybackOwner.none);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(speaks(), ['speak:S0.']);
  });

  test('V1 cruise takes over: sentence auto play stops', () async {
    final p = player();
    unawaited(p.play());
    await tick();
    unawaited(app.startCruise());
    await tick();
    expect(app.playbackCoordinator.owner, PlaybackOwner.v1);
    expect(p.isAutoPlaying, isFalse);
    expect(tts.speaking, 'w0');
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(speaks().where((e) => e.startsWith('speak:S')), ['speak:S0.']);
  });

  test('sentence auto play stops V1 cruise first', () async {
    unawaited(app.startCruise());
    await tick();
    expect(app.isPlaying, isTrue);
    final p = player();
    unawaited(p.play());
    await tick();
    expect(app.isPlaying, isFalse);
    expect(app.playbackCoordinator.owner, PlaybackOwner.v2);
    expect(tts.speaking, 'S0.');
  });

  test('translation off, or voice missing: English only; warned once',
      () async {
    final warned = <String>[];
    final p = player()..onVoiceUnavailable = warned.add;
    await p.updateSettings(
        p.settings.copyWith(repeatCount: 1, readTranslation: false));
    final a = p.replay();
    await tick();
    tts.finish();
    await a;
    expect(speaks(), ['speak:S0.']);

    await p.updateSettings(p.settings.copyWith(readTranslation: true));
    voice = PeVoiceStatus.unavailable;
    pe.dispose();
    // 新的 state 才會重新查語音
    pe = PracticalEnglishState(
      appState: app,
      tts: tts,
      sentences: SentenceRepository(
          loadBuiltInAsset: () async => _coreJson, baseDir: () async => dir),
      baseDir: () async => dir,
      onError: (e, st) => fail('$e\n$st'),
      translationKey: () => 'zh-TW',
      checkVoice: (_) async => voice,
    );
    await pe.load();
    final q = player();
    q.onVoiceUnavailable = warned.add;
    await q.updateSettings(q.settings.copyWith(repeatCount: 1));
    for (var i = 0; i < 2; i++) {
      final f = q.replay();
      await tick();
      tts.finish();
      await f;
    }
    expect(speaks(), ['speak:S0.', 'speak:S0.', 'speak:S0.']);
    expect(warned, ['zh-TW']);
  });

  test('wraps around at both ends', () async {
    final p = player(index: 7);
    await p.updateSettings(p.settings.copyWith(readTranslation: false));
    unawaited(p.next());
    await tick();
    expect(p.index, 0);
    unawaited(p.previous());
    await tick();
    expect(p.index, 7);
    expect(tts.speaking, 'S7.');
  });

  test('settings persist; bad values fall back to defaults', () async {
    final p = player();
    await p.updateSettings(const SentencePlaybackSettings(
        readTranslation: false, repeatCount: 3, intervalSeconds: 4));
    final q = player();
    await q.loadSettings();
    expect(q.settings, p.settings);
    expect(
        SentencePlaybackSettings.fromJson(
            {'readTranslation': 'x', 'repeatCount': 9, 'intervalSeconds': -1}),
        const SentencePlaybackSettings());
  });

  test('dispose stops speech and releases ownership', () async {
    final p = player();
    unawaited(p.play());
    await tick();
    players.remove(p);
    p.dispose();
    await tick();
    expect(tts.speaking, isNull);
    expect(app.playbackCoordinator.owner, PlaybackOwner.none);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(speaks(), ['speak:S0.']);
  });

  test('moving to a sentence records practice for its words', () async {
    final p = player();
    await p.updateSettings(p.settings.copyWith(readTranslation: false));
    final before = pe.stateOf('ngsl_2809_0001').peExposureCount;
    unawaited(p.next());
    await tick();
    expect(pe.stateOf('ngsl_2809_0001').peExposureCount, before + 1);
  });

  group('lock screen (C3)', () {
    test('nothing shown before the first speech', () async {
      final sink = _FakeSink();
      player(sink: sink);
      await tick();
      expect(sink.shown, isEmpty);
    });

    test('auto play shows the current sentence and follows it', () async {
      final sink = _FakeSink();
      final p = player(sink: sink);
      await p.updateSettings(p.settings.copyWith(repeatCount: 1));
      unawaited(p.play());
      await tick();
      expect(sink.shown.last, 'S0.|句0|true|1/8');
      tts.finish();
      await tick();
      tts.finish();
      await tick();
      expect(p.index, 1);
      expect(sink.shown.last, 'S1.|句1|true|2/8');
      await p.pause();
      expect(sink.shown.last, 'S1.|句1|false|2/8');
      expect(sink.releases, 0, reason: 'card stays while on the sentence page');
    });

    test('translation off hides the subtitle', () async {
      final sink = _FakeSink();
      final p = player(sink: sink);
      await p.updateSettings(p.settings.copyWith(readTranslation: false));
      unawaited(p.replay());
      await tick();
      expect(sink.shown.last, 'S0.||false|1/8');
    });

    test('V1 starts (e.g. reminder ▶): auto stops and lock screen is released',
        () async {
      final sink = _FakeSink();
      final p = player(sink: sink);
      unawaited(p.play());
      await tick();
      unawaited(app.startCruise());
      await tick();
      expect(p.isAutoPlaying, isFalse);
      expect(sink.releases, 1);
      expect(tts.speaking, 'w0');
    });

    test('V1 starts after a manual one-shot: lock screen is released too',
        () async {
      final sink = _FakeSink();
      final p = player(sink: sink);
      await p.updateSettings(
          p.settings.copyWith(repeatCount: 1, readTranslation: false));
      final f = p.replay();
      await tick();
      tts.finish();
      await f;
      expect(app.playbackCoordinator.owner, PlaybackOwner.none);
      unawaited(app.startCruise());
      await tick();
      expect(sink.releases, 1);
    });

    test('leaving the sentence page releases the lock screen', () async {
      final sink = _FakeSink();
      final p = player(sink: sink);
      unawaited(p.play());
      await tick();
      players.remove(p);
      p.dispose();
      expect(sink.releases, 1);
    });
  });
}
