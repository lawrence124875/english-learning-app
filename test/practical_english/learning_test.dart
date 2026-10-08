import 'dart:convert';
import 'dart:io';

import 'package:english_learning_app/data/repositories/progress_repository.dart';
import 'package:english_learning_app/data/repositories/word_repository.dart';
import 'package:english_learning_app/data/sources/tts_service.dart';
import 'package:english_learning_app/domain/models/playback_settings.dart';
import 'package:english_learning_app/domain/models/word_item.dart';
import 'package:english_learning_app/l10n/app_localizations.dart';
import 'package:english_learning_app/practical_english/data/sentence_repository.dart';
import 'package:english_learning_app/practical_english/data/v1_legacy_gateway.dart';
import 'package:english_learning_app/practical_english/domain/services/legacy_migration.dart';
import 'package:english_learning_app/practical_english/domain/services/sentence_selector.dart';
import 'package:english_learning_app/practical_english/presentation/providers/practical_english_state.dart';
import 'package:english_learning_app/practical_english/presentation/screens/practical_english_screen.dart';
import 'package:english_learning_app/practical_english/presentation/screens/sentence_import_screen.dart';
import 'package:english_learning_app/presentation/providers/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------- fixtures ----------------

String _id(int i) => 'ngsl_2809_${'$i'.padLeft(4, '0')}';

/// 內建教材 9 字：免費版解鎖 1/3 → index 0–2。
WordDataset _builtIn() => WordDataset(
      id: 'ngsl_2809',
      name: 'NGSL',
      shortName: 'NGSL',
      builtIn: true,
      items: [
        for (var i = 0; i < 9; i++)
          WordItem(id: _id(i), word: 'w$i', translations: {'zh-TW': '字$i'}),
      ],
    );

/// 自訂教材 3 字：免費版解鎖 index 0。
WordDataset _custom() => WordDataset(
      id: 'custom_100',
      name: 'Mine',
      shortName: 'Mine',
      primaryLocale: 'ja',
      items: [
        for (var i = 0; i < 3; i++)
          WordItem(id: 'c$i', word: 'c$i', translations: {'ja': 'ジ$i'}),
      ],
    );

List<WordDataset> _datasets() => [_builtIn(), _custom()];

Map<String, dynamic> _s(String id, List<String> words, String text) => {
      'id': id,
      'wordIds': words,
      'datasetId': 'pe_core',
      'targetLanguage': 'en-US',
      'sentenceText': text,
      'translations': {'zh-TW': '譯:$text'},
    };

final _coreJson = jsonEncode({
  'schema': 1,
  'datasetId': 'pe_core',
  'sentences': [
    _s('pe_core_000001', [_id(0)], 'Sentence one.'),
    _s('pe_core_000002', [_id(1), _id(2), _id(1)], 'Sentence two.'),
    _s('pe_core_000003', [_id(0), _id(5)], 'Sentence three.'),
    _s('pe_core_000004', [_id(6)], 'Sentence four.'),
    _s('pe_core_000005', ['custom_100/c0'], 'Sentence five.'),
    _s('pe_core_000006', ['custom_100/c2'], 'Sentence six.'),
  ],
});

class _NoWords implements WordRepository {
  @override
  Future<List<WordDataset>> loadAllDatasets() async => [];
}

class _RecordingTts implements TtsService {
  final spoken = <String>[];
  int stops = 0;
  bool fail = false;

  @override
  Future<void> speak(String text, {required String languageCode}) async {
    if (fail) throw StateError('tts');
    spoken.add('$languageCode|$text');
  }

  @override
  Future<void> stop() async => stops++;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// 透過 V1 ProgressRepository 讀寫 SharedPreferences（V1 實際格式）。
class _PrefsGateway implements V1LegacyGateway {
  final repo = ProgressRepository();
  final Map<String, Set<int>> cache = {};
  int writes = 0;

  Future<void> preload(Iterable<WordDataset> ds) async {
    for (final d in ds) {
      cache[d.id] = await repo.loadStarred(d.id);
    }
  }

  @override
  Set<int> starredIndexes(String datasetId) => cache[datasetId] ?? {};

  @override
  Future<void> setStarredIndexes(String datasetId, Set<int> indexes) async {
    writes++;
    cache[datasetId] = Set.of(indexes);
    await repo.saveStarred(datasetId, indexes);
  }

  @override
  Future<List<String>> learnedKeys() => V1LearnedReader.read();
}

AppState _app({bool premium = false, int step = 0}) {
  final app = AppState(
    wordRepository: _NoWords(),
    progressRepository: ProgressRepository(),
    ttsService: _RecordingTts(),
  );
  app.debugPreview(
    data: _datasets(),
    premium: premium,
    step: step,
    newSettings: const PlaybackSettings(scopeMode: ScopeMode.allSequential),
  );
  return app;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  final created = <PracticalEnglishState>[];

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('pe_learning');
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(() async {
    for (final s in created) {
      await s.flush();
    }
    created.clear();
    await dir.delete(recursive: true);
  });

  PracticalEnglishState newState(
    AppState app, {
    V1LegacyGateway? gateway,
    TtsService? tts,
    DateTime Function()? now,
  }) {
    final state = PracticalEnglishState(
      appState: app,
      tts: tts ?? _RecordingTts(),
      gateway: gateway,
      sentences: SentenceRepository(
        loadBuiltInAsset: () async => _coreJson,
        baseDir: () async => dir,
      ),
      baseDir: () async => dir,
      onError: (e, st) => fail('unexpected error: $e\n$st'),
      now: now,
      translationKey: () => 'zh-TW',
    );
    created.add(state);
    return state;
  }

  Future<PracticalEnglishState> enter(AppState app,
      {V1LegacyGateway? gateway, TtsService? tts, DateTime Function()? now}) async {
    final s = newState(app, gateway: gateway, tts: tts, now: now);
    await s.load();
    expect(s.status, PracticalEnglishLoadStatus.ready);
    return s;
  }

  List<String> ids(PracticalEnglishState s) => [for (final x in s.sentences) x.id];

  group('Learning state', () {
    test('1. fresh install: everything unseen, no V1 write, migration recorded',
        () async {
      final app = _app();
      final s = await enter(app);
      final c = s.coverage;
      expect(c.totalWords, 12);
      expect(c.count(WordStatus.unseen), 12);
      expect(c.practicedWords, 0);
      expect(app.starredIndexesFor('ngsl_2809'), isEmpty);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt(LegacyMigration.migrationVersionKey), 1);
      expect(prefs.getStringList('starred_v1_ngsl_2809'), isNull);
    });

    test('2. existing V1 user: ★ → weak, learned → seen, V1 untouched',
        () async {
      SharedPreferences.setMockInitialValues({
        'starred_v1_ngsl_2809': ['1'],
        'stats_all_learned_v1': ['ngsl_2809:0', 'custom_100:0'],
      });
      final gw = _PrefsGateway();
      await gw.preload(_datasets());
      final s = await enter(_app(), gateway: gw);
      expect(s.statusOf(_id(1)), WordStatus.weak);
      expect(s.statusOf(_id(0)), WordStatus.seen);
      expect(s.statusOf('custom_100/c0'), WordStatus.seen);
      expect(s.statusOf(_id(2)), WordStatus.unseen);
      expect(gw.writes, 0);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('starred_v1_ngsl_2809'), ['1']);
    });

    test('3. V1 ★ (home screen toggle) → Weak on next entry', () async {
      final app = _app(premium: true, step: 4);
      var s = await enter(app);
      expect(s.statusOf(_id(4)), WordStatus.unseen);
      s.dispose();
      created.remove(s);
      await app.toggleStarCurrent(); // V1 首頁對 index 4 打 ★
      s = await enter(app);
      expect(s.statusOf(_id(4)), WordStatus.weak);
    });

    test('4. Weak → V1 ★ (memory + prefs)', () async {
      final app = _app();
      final s = await enter(app);
      await s.setWeak(_id(3), true);
      expect(s.statusOf(_id(3)), WordStatus.weak);
      expect(app.starredIndexesFor('ngsl_2809'), {3});
      expect(await ProgressRepository().loadStarred('ngsl_2809'), {3});
      await s.setWeak(_id(3), false);
      expect(app.starredIndexesFor('ngsl_2809'), isEmpty);
    });

    test('5. 我會了 → Mastered (weak cleared, record kept)', () async {
      final app = _app();
      final s = await enter(app);
      final sentence = s.sentences.firstWhere((x) => x.id == 'pe_core_000001');
      s.recordPractice(sentence);
      await s.setMastered(_id(0), true);
      final st = s.stateOf(_id(0));
      expect(s.statusOf(_id(0)), WordStatus.mastered);
      expect(st.weak, isFalse);
      expect(st.peExposureCount, 1);
      await s.setMastered(_id(0), false);
      expect(s.statusOf(_id(0)), WordStatus.learning);
    });

    test('6. Mastered removes V1 ★', () async {
      final app = _app();
      final s = await enter(app);
      await s.setWeak(_id(2), true);
      expect(app.starredIndexesFor('ngsl_2809'), {2});
      await s.setMastered(_id(2), true);
      expect(app.starredIndexesFor('ngsl_2809'), isEmpty);
      expect(await ProgressRepository().loadStarred('ngsl_2809'), isEmpty);
      // 精熟後再標弱字：mastered 取消、★ 回來
      await s.setWeak(_id(2), true);
      expect(s.stateOf(_id(2)).mastered, isFalse);
      expect(app.starredIndexesFor('ngsl_2809'), {2});
    });

    test('7. multi-target-word sentence counts each word once', () async {
      final t = DateTime.utc(2026, 10, 8, 12);
      final s = await enter(_app(), now: () => t);
      final multi = s.sentences.firstWhere((x) => x.id == 'pe_core_000002');
      s.recordPractice(multi);
      expect(s.stateOf(_id(1)).peExposureCount, 1); // wordIds 重複只算一次
      expect(s.stateOf(_id(2)).peExposureCount, 1);
      expect(s.stateOf(_id(2)).lastPracticedAt, t);
      expect(s.coverage.practicedWords, 2);
      expect(s.coverage.count(WordStatus.learning), 2);
      await s.setWeak(_id(2), true);
      // score = 3 (weak w2) + 1 (learning w1)
      expect(s.score(multi), 4);
    });

    test('8. weak priority / weak only', () async {
      final s = await enter(_app());
      await s.setWeak(_id(0), true);
      expect(ids(s).first, 'pe_core_000001');
      await s.setWeak(_id(2), true);
      // 句二：3（w2 弱）+1（w1）=4 > 句一：3
      expect(ids(s).take(2), ['pe_core_000002', 'pe_core_000001']);
      s.setMode(LearningMode.weakOnly);
      expect(ids(s), ['pe_core_000002', 'pe_core_000001']);
      await s.setMastered(_id(0), true);
      expect(ids(s), ['pe_core_000002']);
    });

    test('9. deterministic ordering (ties → older practice → id)', () async {
      var clock = DateTime.utc(2026, 10, 8);
      final a = await enter(_app(), now: () => clock);
      // 免費可學：句一(1)、句二(2)、句五(1)
      expect(ids(a), ['pe_core_000002', 'pe_core_000001', 'pe_core_000005']);
      a.recordPractice(a.sentences.firstWhere((x) => x.id == 'pe_core_000001'));
      // 句一練過（較新）→ 同分時排到句五之後
      expect(ids(a), ['pe_core_000002', 'pe_core_000005', 'pe_core_000001']);
      a.setMode(LearningMode.all);
      expect(ids(a), ['pe_core_000001', 'pe_core_000002', 'pe_core_000005']);
      await a.flush();

      clock = clock.add(const Duration(hours: 1));
      final b = await enter(_app(), now: () => clock);
      expect(ids(b), ['pe_core_000002', 'pe_core_000005', 'pe_core_000001']);
      expect(ids(b), ids(await enter(_app(), now: () => clock)));
    });

    test('10. coverage calculation', () async {
      final s = await enter(_app());
      await s.setWeak(_id(1), true);
      await s.setMastered(_id(0), true);
      final c = s.coverage;
      expect(c.totalSentences, 6);
      expect(c.accessibleSentences, 3);
      expect(c.lockedSentences, 3);
      // 有例句的字：w0 w1 w2 w5 w6 c0 c2
      expect(c.wordsWithSentences, 7);
      expect(c.count(WordStatus.weak), 1);
      expect(c.count(WordStatus.mastered), 1);
      expect(c.count(WordStatus.unseen), 10);
      expect(WordStatus.values.map(c.count).reduce((x, y) => x + y), 12);
    });
  });

  group('Free / Premium', () {
    test('11. free user cannot access a sentence containing a premium word',
        () async {
      final s = await enter(_app());
      expect(ids(s), isNot(contains('pe_core_000003'))); // w0 + w5
      expect(ids(s), isNot(contains('pe_core_000004'))); // w6
      expect(ids(s), isNot(contains('pe_core_000006'))); // custom c2
      expect(s.lockedCount, 3);
    });

    test('12. free user can access sentences whose words are all free',
        () async {
      final s = await enter(_app());
      expect(ids(s).toSet(),
          {'pe_core_000001', 'pe_core_000002', 'pe_core_000005'});
    });

    test('13. premium sees all; upgrade refreshes without re-entering',
        () async {
      final app = _app();
      final s = await enter(app);
      expect(s.sentences, hasLength(3));
      app.isPremium = true;
      app.notifyListeners();
      expect(s.sentences, hasLength(6));
      expect(s.lockedCount, 0);
      final p = await enter(_app(premium: true));
      expect(p.sentences, hasLength(6));
    });
  });

  group('Data', () {
    test('14. restart keeps weak / mastered / practice', () async {
      final app = _app();
      final s = await enter(app);
      await s.setWeak(_id(1), true);
      await s.setMastered(_id(0), true);
      s.recordPractice(s.sentences.firstWhere((x) => x.id == 'pe_core_000002'));
      s.dispose(); // 離開時 flush
      created.remove(s);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final again = await enter(_app()..replaceStarredFromPracticalEnglish('ngsl_2809', {1}));
      expect(again.statusOf(_id(1)), WordStatus.weak);
      expect(again.statusOf(_id(0)), WordStatus.mastered);
      expect(again.stateOf(_id(2)).peExposureCount, 1);
    });

    test('15. existing V1 data preserved', () async {
      final v1 = <String, Object>{
        'settings_v1': '{"repeatCount":2}',
        'progress_v1_ngsl_2809': '{"playlist":[0,1,2],"currentStep":1}',
        'stats_all_learned_v1': ['ngsl_2809:0'],
        'starred_v1_custom_100': ['0'],
      };
      SharedPreferences.setMockInitialValues(Map.of(v1));
      final gw = _PrefsGateway();
      await gw.preload(_datasets());
      final s = await enter(_app(), gateway: gw);
      await s.setWeak(_id(1), true);
      await s.setMastered(_id(1), true);
      s.recordPractice(s.sentences.first);
      await s.importCsv('word_id,sentence,sentence_translation\n${_id(0)},Imported here.,這裡\n');
      await s.flush();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('settings_v1'), v1['settings_v1']);
      expect(prefs.getString('progress_v1_ngsl_2809'), v1['progress_v1_ngsl_2809']);
      expect(prefs.getStringList('stats_all_learned_v1'), ['ngsl_2809:0']);
      expect(prefs.getStringList('starred_v1_custom_100'), ['0']);
      expect(prefs.getStringList('starred_v1_ngsl_2809'), isEmpty);
    });

    test('16. custom dataset WordRef: access, ★ sync, meaning', () async {
      final app = _app();
      final s = await enter(app);
      expect(ids(s), contains('pe_core_000005'));
      await s.setWeak('custom_100/c0', true);
      expect(app.starredIndexesFor('custom_100'), {0});
      expect(app.starredIndexesFor('ngsl_2809'), isEmpty);
      expect(s.meaningFor('custom_100/c0'), 'ジ0'); // 自訂教材用 primaryLocale
      expect(s.meaningFor(_id(3)), '字3');
      expect(s.wordFor('custom_100/c0')!.item.word, 'c0');
    });

    test('17. imported sentence becomes learnable', () async {
      final s = await enter(_app());
      final r = await s.importCsv(
          'word_id,sentence,sentence_translation\n'
          '${_id(2)}|custom_100/c0,Imported sentence.,匯入句\n'
          '${_id(8)},Locked import.,鎖住\n');
      expect(r.added, 2);
      final imported = s.sentences.where((x) => x.id.startsWith('imp_')).toList();
      expect(imported, hasLength(1)); // w8 對免費版鎖住
      expect(imported.single.sentenceText, 'Imported sentence.');
      expect(s.translationFor(imported.single), '匯入句');
      expect(s.lockedCount, 4);
    });

    test('18. duplicate import is idempotent', () async {
      final s = await enter(_app());
      const csv = 'word_id,sentence,sentence_translation\n'
          'ngsl_2809_0001,Again and again.,一再\n';
      final first = await s.importCsv(csv);
      final count = s.sentences.length;
      final second = await s.importCsv(csv);
      expect(first.added, 1);
      expect(second.added, 0);
      expect(second.duplicate, 1);
      expect(second.hasChanges, isFalse);
      expect(s.sentences.length, count);
    });

    test('playback: speaks with sentence language, stops V1 cruise, TTS failure → false',
        () async {
      final tts = _RecordingTts();
      final app = _app();
      final s = await enter(app, tts: tts);
      app.isPlaying = true;
      expect(await s.speak(s.sentences.first), isTrue);
      expect(app.isPlaying, isFalse);
      expect(tts.spoken.single, startsWith('en-US|'));
      tts.fail = true;
      // 失敗回報不中斷測試
      final failing = PracticalEnglishState(
        appState: app,
        tts: tts,
        sentences: SentenceRepository(
            loadBuiltInAsset: () async => _coreJson, baseDir: () async => dir),
        baseDir: () async => dir,
        onError: (_, __) {},
        translationKey: () => 'zh-TW',
      );
      created.add(failing);
      await failing.load();
      expect(await failing.speak(failing.sentences.first), isFalse);
    });
  });

  group('UI', () {
    Future<PracticalEnglishState> pumpScreen(WidgetTester tester,
        {AppState? app, TtsService? tts}) async {
      final state = (await tester.runAsync(
          () => enter(app ?? _app(), tts: tts)))!;
      await tester.pumpWidget(MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PracticalEnglishScreen(state: state),
      ));
      await tester.pump();
      return state;
    }

    /// 讓真實的檔案 I/O 完成後再重建畫面。
    Future<void> settleIo(WidgetTester tester) async {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pump();
    }

    /// I/O 鏈較長（匯入）時，重複等待直到 [finder] 出現。
    Future<void> settleUntil(WidgetTester tester, Finder finder) async {
      for (var i = 0; i < 30 && finder.evaluate().isEmpty; i++) {
        await settleIo(tester);
      }
    }

    Future<void> finish(WidgetTester tester, PracticalEnglishState s) async {
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(() => s.flush());
    }

    testWidgets('19. sentence list shows accessible sentences, coverage, lock hint',
        (tester) async {
      final s = await pumpScreen(tester);
      expect(find.text('實用英文'), findsOneWidget);
      expect(find.text('Sentence two.'), findsOneWidget);
      expect(find.text('Sentence one.'), findsOneWidget);
      expect(find.text('Sentence four.'), findsNothing);
      expect(find.text('還有 3 句需要 Premium 才能學習'), findsOneWidget);
      expect(find.text('可學句子 3 / 6'), findsOneWidget);
      await tester.tap(find.text('只練不熟悉'));
      await tester.pump();
      expect(find.text('沒有含不熟悉單字的句子。'), findsOneWidget);
      await finish(tester, s);
    });

    testWidgets('20–22. detail, play, weak / 我會了 refresh state',
        (tester) async {
      final tts = _RecordingTts();
      final s = await pumpScreen(tester, tts: tts);
      await tester.tap(find.text('Sentence two.'));
      await tester.pumpAndSettle();
      // 20. detail
      expect(find.byKey(const Key('pe_detail_sentence')), findsOneWidget);
      expect(find.text('譯:Sentence two.'), findsOneWidget);
      expect(find.text('1 / 3'), findsOneWidget);
      expect(find.text('字1'), findsOneWidget);
      expect(s.stateOf(_id(1)).peExposureCount, 1); // 進入即記錄練習

      // 21. play does not crash
      await tester.tap(find.byKey(const Key('pe_play')));
      await settleIo(tester);
      expect(tts.spoken, ['en-US|Sentence two.']);
      expect(tester.takeException(), isNull);

      // 22. weak → chip + V1 ★；我會了 → mastered
      await tester.tap(find.byKey(Key('pe_weak_${_id(1)}')));
      await settleIo(tester);
      expect(s.statusOf(_id(1)), WordStatus.weak);
      expect(find.text('取消不熟悉'), findsOneWidget);
      expect(find.text('w1 · 不熟悉'), findsOneWidget);

      await tester.tap(find.byKey(Key('pe_mastered_${_id(1)}')));
      await settleIo(tester);
      expect(s.statusOf(_id(1)), WordStatus.mastered);
      expect(find.text('取消「我會了」'), findsOneWidget);

      await tester.tap(find.byKey(const Key('pe_next')));
      await tester.pump();
      expect(find.text('2 / 3'), findsOneWidget);

      // 回列表後狀態已更新
      Navigator.of(tester.element(find.byKey(const Key('pe_detail_sentence'))))
          .pop();
      await tester.pumpAndSettle();
      expect(find.text('w1 · 已學會'), findsOneWidget);
      await finish(tester, s);
    });

    testWidgets('22b. TTS failure shows a message instead of crashing',
        (tester) async {
      final tts = _RecordingTts()..fail = true;
      final app = _app();
      final state = PracticalEnglishState(
        appState: app,
        tts: tts,
        sentences: SentenceRepository(
            loadBuiltInAsset: () async => _coreJson, baseDir: () async => dir),
        baseDir: () async => dir,
        onError: (_, __) {},
        translationKey: () => 'zh-TW',
      );
      created.add(state);
      await tester.runAsync(state.load);
      await tester.pumpWidget(MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PracticalEnglishScreen(state: state),
      ));
      await tester.pump();
      await tester.tap(find.text('Sentence one.'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('pe_play')));
      await tester.pump();
      await tester.pump();
      expect(find.text('無法朗讀，請確認手機的文字轉語音設定。'), findsOneWidget);
      await finish(tester, state);
    });

    testWidgets('23. import result UI', (tester) async {
      final s = (await tester.runAsync(() => enter(_app())))!;
      var csv = 'word_id,sentence,sentence_translation\n'
          '${_id(1)},New one.,新\n'
          'bad_id,Bad word.,壞\n'
          ',No word.,無\n';
      await tester.pumpWidget(MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ChangeNotifierProvider.value(
          value: s,
          child: SentenceImportScreen(pickContent: () async => csv),
        ),
      ));
      await tester.tap(find.byKey(const Key('pe_import_choose')));
      await settleUntil(tester, find.byKey(const Key('pe_import_added')));
      Text count(String k) =>
          tester.widget<Text>(find.byKey(Key('pe_import_$k')));
      expect(count('added').data, '1');
      expect(count('invalidWordId').data, '1');
      expect(count('invalidRow').data, '1');
      expect(find.text('第 3 列: bad_id'), findsOneWidget);
      expect(find.text('第 4 列: 缺少 word_id'), findsOneWidget);

      csv = 'sentence\nOnly sentence.\n';
      await tester.tap(find.byKey(const Key('pe_import_choose')));
      await settleUntil(tester, find.byKey(const Key('pe_import_error')));
      expect(find.byKey(const Key('pe_import_error')), findsOneWidget);
      await finish(tester, s);
    });
  });
}
