import 'dart:convert';
import 'dart:io';

import 'package:english_learning_app/data/repositories/progress_repository.dart';
import 'package:english_learning_app/data/repositories/word_repository.dart';
import 'package:english_learning_app/data/sources/tts_service.dart';
import 'package:english_learning_app/domain/models/playback_settings.dart';
import 'package:english_learning_app/domain/models/word_item.dart';
import 'package:english_learning_app/l10n/app_localizations.dart';
import 'package:english_learning_app/practical_english/data/sentence_repository.dart';
import 'package:english_learning_app/practical_english/domain/services/playback_coordinator.dart';
import 'package:english_learning_app/practical_english/presentation/providers/practical_english_state.dart';
import 'package:english_learning_app/practical_english/presentation/screens/practical_english_screen.dart';
import 'package:english_learning_app/presentation/providers/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _id(int i) => 'ngsl_2809_${'$i'.padLeft(4, '0')}';

WordDataset _ngsl() => WordDataset(
      id: 'ngsl_2809',
      name: 'NGSL',
      shortName: 'NGSL',
      builtIn: true,
      items: [
        for (var i = 0; i < 6; i++)
          WordItem(
              id: _id(i),
              word: i == 0 ? 'watch' : 'w$i',
              translations: {'zh-TW': '字$i'}),
      ],
    );

/// 另一份內建清單，第 0 個字與 NGSL 第 0 個字同拼字（watch）。
WordDataset _toeic() => WordDataset(
      id: 'toeic',
      name: 'TOEIC',
      shortName: 'TOEIC',
      builtIn: true,
      items: [
        WordItem(id: 'toeic_0000', word: 'Watch ', translations: const {}),
      ],
    );

Map<String, dynamic> _s(
        String id, List<String> words, String text, Map<String, String> tr,
        {List<String> secondary = const []}) =>
    {
      'id': id,
      'wordIds': words,
      if (secondary.isNotEmpty) 'secondaryWordIds': secondary,
      'datasetId': 'pe_core',
      'targetLanguage': 'en-US',
      'sentenceText': text,
      'translations': tr,
    };

final _coreJson = jsonEncode({
  'schema': 1,
  'datasetId': 'pe_core',
  'sentences': [
    _s('pe_core_000001', [_id(0), 'toeic_0000'], 'Watch this.',
        {'zh-TW': '看這個。', 'ar': 'شاهد هذا.'},
        secondary: [_id(1), _id(0)]),
    _s('pe_core_000002', [_id(1)], 'Only Japanese.', {'ja': '日本語だけ。'}),
  ],
});

class _NoWords implements WordRepository {
  @override
  Future<List<WordDataset>> loadAllDatasets() async => [];
}

class _RecordingTts implements TtsService {
  final spoken = <String>[];

  @override
  Future<void> speak(String text, {required String languageCode}) async =>
      spoken.add('$languageCode|$text');

  @override
  Future<void> stop() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

AppState _app() {
  final app = AppState(
    wordRepository: _NoWords(),
    progressRepository: ProgressRepository(),
    ttsService: _RecordingTts(),
  );
  app.debugPreview(
    data: [_ngsl(), _toeic()],
    premium: true,
    newSettings: const PlaybackSettings(scopeMode: ScopeMode.allSequential),
  );
  return app;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  final created = <PracticalEnglishState>[];

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('pe_translation');
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(() async {
    for (final s in created) {
      await s.flush();
    }
    created.clear();
    await dir.delete(recursive: true);
  });

  Future<PracticalEnglishState> enter(
    AppState app, {
    String uiKey = 'zh-TW',
    TtsService? tts,
    PeVoiceStatus voice = PeVoiceStatus.available,
    List<String>? voiceChecks,
  }) async {
    final s = PracticalEnglishState(
      appState: app,
      tts: tts ?? _RecordingTts(),
      sentences: SentenceRepository(
          loadBuiltInAsset: () async => _coreJson, baseDir: () async => dir),
      baseDir: () async => dir,
      onError: (e, st) => fail('unexpected error: $e\n$st'),
      translationKey: () => uiKey,
      checkVoice: (code) async {
        voiceChecks?.add(code);
        return voice;
      },
    );
    created.add(s);
    await s.load();
    expect(s.status, PracticalEnglishLoadStatus.ready);
    return s;
  }

  group('translation language setting (SPEC §6.4)', () {
    test('follows the app language by default', () async {
      final s = await enter(_app());
      expect(s.translationLocaleSetting, isNull);
      expect(s.translationLocale, 'zh-TW');
      expect(s.translationFor(s.sentences.first)?.text, '看這個。');
    });

    test('English UI shows no translation', () async {
      final s = await enter(_app(), uiKey: 'en');
      expect(s.translationLocale, isNull);
      expect(s.translationFor(s.sentences.first), isNull);
      expect(s.defaultTranslationLocale, 'zh-TW');
    });

    test('zh-CN falls back to zh-TW; other languages never fall back',
        () async {
      final s = await enter(_app(), uiKey: 'zh-CN');
      final watch = s.sentences.firstWhere((x) => x.id == 'pe_core_000001');
      final ja = s.sentences.firstWhere((x) => x.id == 'pe_core_000002');
      expect(s.translationFor(watch)?.code, 'zh-TW');
      expect(s.translationFor(ja), isNull);
      await s.setTranslationLocale('ko');
      expect(s.translationFor(watch), isNull);
    });

    test('choosing a language stores the canonical code; follow removes it',
        () async {
      final s = await enter(_app());
      await s.setTranslationLocale('ja_JP');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(PracticalEnglishState.translationLocalePrefKey),
          'ja');
      expect(s.translationLocale, 'ja');
      await s.setTranslationLocale(null);
      expect(prefs.containsKey(PracticalEnglishState.translationLocalePrefKey),
          isFalse);
      expect(s.translationLocale, 'zh-TW');
      expect(() => s.setTranslationLocale('jp'), throwsArgumentError);
    });

    test('stored setting is restored; an invalid stored value means follow',
        () async {
      SharedPreferences.setMockInitialValues(
          {PracticalEnglishState.translationLocalePrefKey: 'ar'});
      final a = await enter(_app());
      expect(a.translationLocale, 'ar');
      SharedPreferences.setMockInitialValues(
          {PracticalEnglishState.translationLocalePrefKey: 'jp'});
      final b = await enter(_app());
      expect(b.translationLocaleSetting, isNull);
      expect(b.translationLocale, 'zh-TW');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(PracticalEnglishState.translationLocalePrefKey),
          'jp'); // 不改寫
    });

    test('changing the language changes no learning data (D18)', () async {
      final s = await enter(_app());
      await s.setWeak(_id(0), true);
      final before = (
        s.sentences.map((x) => x.id).join(','),
        s.coverage.accessibleSentences,
        s.stateOf(_id(0)).toJson().toString(),
      );
      await s.setTranslationLocale('ar');
      expect((
        s.sentences.map((x) => x.id).join(','),
        s.coverage.accessibleSentences,
        s.stateOf(_id(0)).toJson().toString(),
      ), before);
    });

    test('translated counts per language', () async {
      final s = await enter(_app());
      expect(s.translatedCount('zh-TW'), 1);
      expect(s.translatedCount('ja'), 1);
      expect(s.translatedCount('ko'), 0);
    });
  });

  group('translation speech (SPEC §10)', () {
    test('uses the registry ttsCode and takes the playback lease', () async {
      final tts = _RecordingTts();
      final app = _app();
      var v1Stopped = 0;
      app.playbackCoordinator
          .registerStopper(PlaybackOwner.v1, () async => v1Stopped++);
      await app.playbackCoordinator.claim(PlaybackOwner.v1);
      final s = await enter(app, tts: tts);
      await s.setTranslationLocale('ar');
      final watch = s.sentences.firstWhere((x) => x.id == 'pe_core_000001');
      expect(await s.speakTranslation(watch), TranslationSpeechResult.spoken);
      expect(tts.spoken, ['ar-SA|شاهد هذا.']);
      expect(v1Stopped, 1);
    });

    test('zh-CN fallback speaks with the zh-TW voice', () async {
      final tts = _RecordingTts();
      final s = await enter(_app(), uiKey: 'zh-CN', tts: tts);
      await s.speakTranslation(s.sentences.first);
      expect(tts.spoken.single, startsWith('zh-TW|'));
    });

    test('voice unavailable → not spoken; unknown → spoken; checked once',
        () async {
      final checks = <String>[];
      final tts = _RecordingTts();
      final s = await enter(_app(),
          tts: tts, voice: PeVoiceStatus.unavailable, voiceChecks: checks);
      final watch = s.sentences.firstWhere((x) => x.id == 'pe_core_000001');
      expect(await s.speakTranslation(watch),
          TranslationSpeechResult.voiceUnavailable);
      expect(await s.speakTranslation(watch),
          TranslationSpeechResult.voiceUnavailable);
      expect(checks, ['zh-TW']);
      expect(tts.spoken, isEmpty);

      final tts2 = _RecordingTts();
      final u = await enter(_app(), tts: tts2, voice: PeVoiceStatus.unknown);
      expect(await u.speakTranslation(u.sentences.first),
          TranslationSpeechResult.spoken);
      expect(tts2.spoken, hasLength(1));
    });

    test('no translation → nothing spoken', () async {
      final tts = _RecordingTts();
      final s = await enter(_app(), uiKey: 'en', tts: tts);
      expect(await s.speakTranslation(s.sentences.first),
          TranslationSpeechResult.noTranslation);
      expect(tts.spoken, isEmpty);
    });
  });

  group('same-surface grouping and other words (SPEC §9.6)', () {
    test('groups by locale + trimmed lowercase surface, display only',
        () async {
      final s = await enter(_app());
      final watch = s.sentences.firstWhere((x) => x.id == 'pe_core_000001');
      final groups = s.wordGroups(watch);
      expect(groups, hasLength(1));
      expect(groups.single.refs, [_id(0), 'toeic_0000']);
      // 只改點的那一筆
      await s.setWeak('toeic_0000', true);
      expect(s.stateOf(_id(0)).weak, isFalse);
    });

    test('other words exclude primary words', () async {
      final s = await enter(_app());
      final watch = s.sentences.firstWhere((x) => x.id == 'pe_core_000001');
      expect(s.otherWordsOf(watch), [_id(1)]);
    });
  });

  group('UI', () {
    Future<PracticalEnglishState> pumpList(WidgetTester tester,
        {String uiKey = 'zh-TW'}) async {
      tester.view.physicalSize = const Size(2400, 4800);
      addTearDown(tester.view.reset);
      final app = _app();
      final s = (await tester.runAsync(() => enter(app, uiKey: uiKey)))!;
      await tester.pumpWidget(MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PracticalEnglishScreen(state: s),
      ));
      await tester.pump();
      return s;
    }

    Future<void> finish(WidgetTester tester, PracticalEnglishState s) async {
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(() => s.flush());
    }

    testWidgets(
        'missing translation shows the localized notice, no language name',
        (tester) async {
      final s = await pumpList(tester);
      expect(find.text('此句尚無翻譯'), findsOneWidget);
      expect(find.text('日本語だけ。'), findsNothing);
      await finish(tester, s);
    });

    testWidgets('Arabic translation is laid out right-to-left', (tester) async {
      final s = await pumpList(tester);
      await tester.runAsync(() => s.setTranslationLocale('ar'));
      await tester.pump();
      final text = tester.widget<Text>(find.text('شاهد هذا.'));
      expect(text.textDirection, TextDirection.rtl);
      await finish(tester, s);
    });

    testWidgets('picker lists follow + 10 endonyms and switches language',
        (tester) async {
      final s = await pumpList(tester);
      await tester.tap(find.byKey(const Key('pe_translation_action')));
      await tester.pumpAndSettle();
      expect(find.text('跟隨 App 語言'), findsOneWidget);
      for (final name in [
        '繁體中文',
        '简体中文',
        '日本語',
        '한국어',
        'Tiếng Việt',
        'Bahasa Indonesia',
        'Español',
        'Português (Brasil)',
        'ไทย',
        'العربية'
      ]) {
        expect(find.text(name), findsOneWidget, reason: name);
      }
      await tester.tap(find.byKey(const Key('pe_translation_option_ja')));
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
      expect(s.translationLocale, 'ja');
      expect(find.text('日本語だけ。'), findsOneWidget);
      await finish(tester, s);
    });

    testWidgets('grouped chip shows one label with a status-differs hint',
        (tester) async {
      final s = await pumpList(tester);
      await tester.runAsync(() => s.setWeak('toeic_0000', true));
      await tester.pump();
      expect(find.textContaining('watch · 不熟悉 · 各清單狀態不同'), findsOneWidget);
      await finish(tester, s);
    });
  });
}
