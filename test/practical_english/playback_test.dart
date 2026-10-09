import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:english_learning_app/data/repositories/progress_repository.dart';
import 'package:english_learning_app/data/repositories/word_repository.dart';
import 'package:english_learning_app/data/sources/tts_service.dart';
import 'package:english_learning_app/domain/models/playback_settings.dart';
import 'package:english_learning_app/domain/models/word_item.dart';
import 'package:english_learning_app/practical_english/data/sentence_repository.dart';
import 'package:english_learning_app/practical_english/domain/services/playback_coordinator.dart';
import 'package:english_learning_app/practical_english/presentation/providers/practical_english_state.dart';
import 'package:english_learning_app/presentation/providers/app_state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------- fakes ----------------

/// 模擬 flutter_tts（awaitSpeakCompletion=true）：speak 直到「念完」或 stop 才完成。
/// [auto] 為 true 時 speak 立即完成。記錄所有事件以檢查是否重疊。
class GateTts implements TtsService {
  bool auto;
  Object? failWith;
  final events = <String>[];
  final _pending = <Completer<void>>[];
  String? speaking;
  int maxConcurrent = 0;

  GateTts({this.auto = false});

  @override
  Future<void> speak(String text, {required String languageCode}) async {
    if (failWith != null) throw failWith!;
    events.add('speak:$text');
    speaking = text;
    if (auto) {
      speaking = null;
      return;
    }
    final c = Completer<void>();
    _pending.add(c);
    maxConcurrent = _pending.length > maxConcurrent ? _pending.length : maxConcurrent;
    await c.future;
  }

  /// 目前這句念完。
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

class _NoWords implements WordRepository {
  @override
  Future<List<WordDataset>> loadAllDatasets() async => [];
}

/// coordinator 單元測試用的播放端：開口前一定確認 lease 仍有效。
class FakePlayer {
  final PlaybackOwner who;
  final PlaybackCoordinator c;
  final Set<PlaybackOwner> speakingNow;
  PlaybackLease? lease;
  int stopCalls = 0;
  Duration stopDelay;

  FakePlayer(this.who, this.c, this.speakingNow, {this.stopDelay = Duration.zero}) {
    c.registerStopper(who, stop);
  }

  Future<void> stop() async {
    stopCalls++;
    await Future<void>.delayed(stopDelay);
    speakingNow.remove(who);
    lease = null;
  }

  Future<bool> play() async {
    final l = await c.claim(who);
    if (!c.isCurrent(l)) return false;
    lease = l;
    speakingNow.add(who);
    expect(speakingNow.length, 1, reason: 'two owners speaking at once');
    return true;
  }

  void finish() {
    speakingNow.remove(who);
    c.release(lease);
    lease = null;
  }
}

WordDataset _ds() => WordDataset(
      id: 'ngsl_2809',
      name: 'NGSL',
      shortName: 'NGSL',
      builtIn: true,
      items: [
        for (var i = 0; i < 6; i++)
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
    for (var i = 0; i < 2; i++)
      {
        'id': 'pe_core_00000${i + 1}',
        'wordIds': ['ngsl_2809_000$i'],
        'datasetId': 'pe_core',
        'targetLanguage': 'en-US',
        'sentenceText': 'Sentence $i.',
        'translations': const {},
      },
  ],
});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PlaybackCoordinator', () {
    late PlaybackCoordinator c;
    late Set<PlaybackOwner> speaking;
    late FakePlayer v1, v2;

    setUp(() {
      c = PlaybackCoordinator();
      speaking = {};
      v1 = FakePlayer(PlaybackOwner.v1, c, speaking);
      v2 = FakePlayer(PlaybackOwner.v2, c, speaking);
    });

    test('initial owner is none', () {
      expect(PlaybackCoordinator().owner, PlaybackOwner.none);
      expect(PlaybackCoordinator().isCurrent(null), isFalse);
    });

    test('V1 → V2 stops V1 first', () async {
      await v1.play();
      expect(c.owner, PlaybackOwner.v1);
      await v2.play();
      expect(v1.stopCalls, 1);
      expect(c.owner, PlaybackOwner.v2);
      expect(speaking, {PlaybackOwner.v2});
    });

    test('V2 → V1 stops V2 first', () async {
      await v2.play();
      await v1.play();
      expect(v2.stopCalls, 1);
      expect(c.owner, PlaybackOwner.v1);
      expect(speaking, {PlaybackOwner.v1});
    });

    test('repeated claim by same owner does not stop itself; old lease is stale',
        () async {
      final a = await c.claim(PlaybackOwner.v2);
      final b = await c.claim(PlaybackOwner.v2);
      expect(v2.stopCalls, 0);
      expect(c.isCurrent(a), isFalse);
      expect(c.isCurrent(b), isTrue);
      c.release(a); // 舊的完成 callback
      expect(c.owner, PlaybackOwner.v2);
      c.release(b);
      expect(c.owner, PlaybackOwner.none);
    });

    test('repeated release / stop is harmless', () async {
      final a = await c.claim(PlaybackOwner.v1);
      c.release(a);
      c.release(a);
      c.release(null);
      expect(c.owner, PlaybackOwner.none);
      // owner 為 none 時 claim 不呼叫任何停止函式
      await c.claim(PlaybackOwner.v2);
      expect(v1.stopCalls, 0);
    });

    test('late callback of the previous owner never clears the new owner',
        () async {
      final old = await c.claim(PlaybackOwner.v2);
      final fresh = await c.claim(PlaybackOwner.v1);
      c.release(old); // V2 的 completion 晚到
      expect(c.owner, PlaybackOwner.v1);
      expect(c.isCurrent(fresh), isTrue);
    });

    test('stopper failure does not block the new owner and is reported',
        () async {
      final errors = <Object>[];
      final c2 = PlaybackCoordinator(onError: (e, _) => errors.add(e));
      c2.registerStopper(PlaybackOwner.v1, () async => throw StateError('x'));
      await c2.claim(PlaybackOwner.v1);
      final l = await c2.claim(PlaybackOwner.v2);
      expect(c2.isCurrent(l), isTrue);
      expect(errors, hasLength(1));
    });

    test('rapid V2 → V1 → V2 switching: only the last claim plays, never two at once',
        () async {
      v1.stopDelay = const Duration(milliseconds: 20);
      v2.stopDelay = const Duration(milliseconds: 10);
      await v1.play();
      final results = await Future.wait([v2.play(), v1.play(), v2.play()]);
      expect(results, [false, false, true]);
      expect(c.owner, PlaybackOwner.v2);
      expect(speaking, {PlaybackOwner.v2});
    });

    test('unregister only removes the same stopper', () async {
      Future<void> other() async {}
      c.unregisterStopper(PlaybackOwner.v2, other);
      await v2.play();
      await v1.play();
      expect(v2.stopCalls, 1);
      c.unregisterStopper(PlaybackOwner.v2, v2.stop);
      await c.claim(PlaybackOwner.v2);
      await c.claim(PlaybackOwner.v1);
      expect(v2.stopCalls, 1);
    });
  });

  group('V1 / V2 integration (shared TTS)', () {
    late Directory dir;
    late GateTts tts;
    late AppState app;
    final states = <PracticalEnglishState>[];

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      dir = await Directory.systemTemp.createTemp('pe_playback');
      tts = GateTts();
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
    });

    tearDown(() async {
      app.stopCruise();
      tts.finish();
      for (final s in states) {
        s.dispose();
      }
      states.clear();
      await Future<void>.delayed(const Duration(milliseconds: 30));
      await dir.delete(recursive: true);
    });

    Future<PracticalEnglishState> enterPe({void Function(Object)? onError}) async {
      final s = PracticalEnglishState(
        appState: app,
        tts: tts,
        sentences: SentenceRepository(
            loadBuiltInAsset: () async => _coreJson, baseDir: () async => dir),
        baseDir: () async => dir,
        onError: (e, st) => onError != null ? onError(e) : fail('$e\n$st'),
        translationKey: () => 'zh-TW',
      );
      states.add(s);
      await s.load();
      return s;
    }

    Future<void> tick() => Future<void>.delayed(const Duration(milliseconds: 5));

    test('V1 cruise playing → V2 speak stops V1, V2 owns, then releases',
        () async {
      final pe = await enterPe();
      unawaited(app.startCruise());
      await tick();
      expect(app.isPlaying, isTrue);
      expect(app.playbackCoordinator.owner, PlaybackOwner.v1);
      expect(tts.speaking, 'w0');

      final done = pe.speak(pe.sentences.first);
      await tick();
      expect(app.isPlaying, isFalse);
      expect(app.playbackCoordinator.owner, PlaybackOwner.v2);
      expect(pe.isSpeaking, isTrue);
      expect(tts.speaking, 'Sentence 0.');

      tts.finish();
      expect(await done, isTrue);
      expect(app.playbackCoordinator.owner, PlaybackOwner.none);
      // V1 舊的巡航迴圈不會再開口
      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(tts.events.where((e) => e.startsWith('speak:w')), ['speak:w0']);
    });

    test('V2 speaking → V1 start (home / lock screen) stops V2; V2 callback does not clear V1',
        () async {
      final pe = await enterPe();
      final done = pe.speak(pe.sentences.first);
      await tick();
      expect(app.playbackCoordinator.owner, PlaybackOwner.v2);

      unawaited(app.startCruise()); // 鎖屏 ▶ 也是 startCruise
      await tick();
      expect(await done, isTrue); // stop 讓 V2 的 speak 結束，不算失敗
      expect(app.playbackCoordinator.owner, PlaybackOwner.v1);
      expect(pe.isSpeaking, isFalse);
      expect(tts.speaking, 'w0');
      expect(app.isPlaying, isTrue);
    });

    test('V2 manual replay from V1 home (replay/next/previous) also claims V1',
        () async {
      final pe = await enterPe();
      unawaited(pe.speak(pe.sentences.first));
      await tick();
      final replay = app.replay();
      await tick();
      expect(app.playbackCoordinator.owner, PlaybackOwner.v1);
      expect(tts.speaking, 'w0');
      tts.finish();
      await replay;
      // 單次朗讀結束後歸還
      expect(app.playbackCoordinator.owner, PlaybackOwner.none);
    });

    test('rapid taps / switching sentence: newest wins, old completion is ignored',
        () async {
      final pe = await enterPe();
      final a = pe.speak(pe.sentences[0]);
      await tick();
      final b = pe.speak(pe.sentences[1]);
      await tick();
      expect(await a, isTrue);
      expect(tts.speaking, 'Sentence 1.');
      expect(pe.isSpeaking, isTrue);
      expect(app.playbackCoordinator.owner, PlaybackOwner.v2);
      tts.finish();
      expect(await b, isTrue);
      expect(app.playbackCoordinator.owner, PlaybackOwner.none);
      expect(tts.maxConcurrent, 1);
    });

    test('many rapid V1/V2 switches never leave two speakers', () async {
      final pe = await enterPe();
      for (var i = 0; i < 5; i++) {
        unawaited(pe.speak(pe.sentences[i % 2]));
        unawaited(app.replay());
        unawaited(pe.speak(pe.sentences[(i + 1) % 2]));
      }
      await tick();
      expect(tts.maxConcurrent, 1);
      expect(app.playbackCoordinator.owner, PlaybackOwner.v2);
      expect(tts.speaking, startsWith('Sentence'));
      tts.finish();
      await tick();
      expect(app.playbackCoordinator.owner, PlaybackOwner.none);
    });

    test('TTS failure: returns false, ownership released, next speak works',
        () async {
      final errors = <Object>[];
      final pe = await enterPe(onError: errors.add);
      tts.failWith = StateError('engine');
      expect(await pe.speak(pe.sentences.first), isFalse);
      expect(errors, hasLength(1));
      expect(app.playbackCoordinator.owner, PlaybackOwner.none);
      tts
        ..failWith = null
        ..auto = true;
      expect(await pe.speak(pe.sentences.first), isTrue);
      expect(app.playbackCoordinator.owner, PlaybackOwner.none);
    });

    test('V2 stopSpeaking after V1 took over does not stop V1', () async {
      final pe = await enterPe();
      unawaited(pe.speak(pe.sentences.first));
      await tick();
      unawaited(app.startCruise());
      await tick();
      final stops = tts.events.where((e) => e == 'stop').length;
      await pe.stopSpeaking(); // 例如離開句子頁
      expect(tts.events.where((e) => e == 'stop').length, stops);
      expect(app.playbackCoordinator.owner, PlaybackOwner.v1);
      expect(tts.speaking, 'w0');
    });

    test('dispose while speaking releases V2 and unregisters its stopper',
        () async {
      final pe = await enterPe();
      unawaited(pe.speak(pe.sentences.first));
      await tick();
      states.remove(pe);
      pe.dispose();
      await tick();
      expect(app.playbackCoordinator.owner, PlaybackOwner.none);
      expect(tts.speaking, isNull);
      final stopsBefore = tts.events.where((e) => e == 'stop').length;
      tts.auto = true;
      await app.replay();
      // 已釋放的 V2 不會再被呼叫停止
      expect(tts.events.where((e) => e == 'stop').length, stopsBefore);
    });

    test('app paused stops V2 speech (no background playback in V2.0)',
        () async {
      final pe = await enterPe();
      final done = pe.speak(pe.sentences.first);
      await tick();
      pe.didChangeAppLifecycleState(AppLifecycleState.paused);
      expect(await done, isTrue);
      expect(app.playbackCoordinator.owner, PlaybackOwner.none);
      expect(tts.speaking, isNull);
    });

    test('V1 regression: cruise / stop / replay unchanged without V2', () async {
      tts.auto = true;
      expect(app.playbackCoordinator.owner, PlaybackOwner.none);
      unawaited(app.startCruise());
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(app.isPlaying, isTrue);
      expect(app.playbackCoordinator.owner, PlaybackOwner.v1);
      final spoken = tts.events.where((e) => e.startsWith('speak:')).toList();
      expect(spoken.length, greaterThan(1)); // 自動前進
      expect(spoken.take(2), ['speak:w0', 'speak:w1']);
      app.stopCruise();
      expect(app.isPlaying, isFalse);
      expect(app.playbackCoordinator.owner, PlaybackOwner.none);
      app.stopCruise(); // 重複停止
      expect(app.playbackCoordinator.owner, PlaybackOwner.none);

      tts.events.clear();
      await app.replay();
      expect(tts.events, ['speak:${app.currentWord!.word}']);
      expect(app.playbackCoordinator.owner, PlaybackOwner.none);
      unawaited(app.togglePlay());
      await tick();
      expect(app.isPlaying, isTrue);
      await app.togglePlay();
      expect(app.isPlaying, isFalse);
    });
  });
}
