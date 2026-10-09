import 'package:english_learning_app/l10n/app_localizations.dart';
import 'package:english_learning_app/practical_english/data/whats_new_service.dart';
import 'package:english_learning_app/practical_english/presentation/screens/whats_new_screen.dart';
import 'package:english_learning_app/data/repositories/progress_repository.dart';
import 'package:english_learning_app/data/repositories/word_repository.dart';
import 'package:english_learning_app/data/sources/tts_service.dart';
import 'package:english_learning_app/domain/models/word_item.dart';
import 'package:english_learning_app/presentation/providers/app_state.dart';
import 'package:english_learning_app/presentation/screens/home_screen.dart';
import 'package:english_learning_app/presentation/screens/onboarding_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _whatsNewTitle = '新功能：實用英文';

class _NoWords implements WordRepository {
  @override
  Future<List<WordDataset>> loadAllDatasets() async => [];
}

class _SilentTts implements TtsService {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SharedPreferences> prefs() => SharedPreferences.getInstance();

  group('WhatsNewService', () {
    test('fresh install: not shown, schema 2, marked as seen', () async {
      SharedPreferences.setMockInitialValues({});
      expect(await WhatsNewService.prepareOnLaunch(), isFalse);
      final p = await prefs();
      expect(p.getInt('app_schema_version'), 2);
      expect(p.getString('last_seen_whats_new_version'), 'pe_2_0');
      // 第二次啟動也不顯示
      expect(await WhatsNewService.prepareOnLaunch(), isFalse);
    });

    test('V1 user (onboarding seen) upgrading: shown, V1 keys untouched',
        () async {
      final v1 = <String, Object>{
        'onboarding_seen_v1': true,
        'settings_v1': '{"repeatCount":2}',
        'starred_v1_ngsl_2809': ['1', '3'],
        'stats_all_learned_v1': ['ngsl_2809:0'],
        'progress_v1_ngsl_2809': '{"playlist":[0,1],"currentStep":1}',
      };
      SharedPreferences.setMockInitialValues(Map.of(v1));
      expect(await WhatsNewService.prepareOnLaunch(), isTrue);
      final p = await prefs();
      expect(p.getInt('app_schema_version'), 2);
      expect(p.getString('last_seen_whats_new_version'), isNull);
      for (final e in v1.entries) {
        expect(p.get(e.key), e.value, reason: e.key);
      }
    });

    test('V1 user with only settings_v1 is also an upgrade', () async {
      SharedPreferences.setMockInitialValues({'settings_v1': '{}'});
      expect(await WhatsNewService.prepareOnLaunch(), isTrue);
    });

    test('shown once: after markSeen it does not show again (restart)',
        () async {
      SharedPreferences.setMockInitialValues({'onboarding_seen_v1': true});
      expect(await WhatsNewService.prepareOnLaunch(), isTrue);
      await WhatsNewService.markSeen();
      expect(await WhatsNewService.prepareOnLaunch(), isFalse);
      expect(await WhatsNewService.prepareOnLaunch(), isFalse);
    });

    test('not seen yet on a later launch (killed before marking) → still shown',
        () async {
      SharedPreferences.setMockInitialValues({'app_schema_version': 2});
      expect(await WhatsNewService.prepareOnLaunch(), isTrue);
    });

    test('an older What\'s New id is replaced by pe_2_0', () async {
      SharedPreferences.setMockInitialValues(
          {'app_schema_version': 2, 'last_seen_whats_new_version': 'pe_1_9'});
      expect(await WhatsNewService.prepareOnLaunch(), isTrue);
    });
  });

  group('Launch flow (real V1 onboarding)', () {
    Widget app(Future<void> Function(BuildContext) onReady) => MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(builder: (context) {
            WidgetsBinding.instance
                .addPostFrameCallback((_) => onReady(context));
            return const Scaffold(body: Text('home'));
          }),
        );

    Future<void> launch(WidgetTester tester) async {
      await tester.pumpWidget(app((context) => WhatsNewScreen.showOnLaunch(
          context,
          showOnboarding: () => OnboardingScreen.showIfFirstTime(context))));
      await tester.pumpAndSettle();
    }

    testWidgets('fresh install: onboarding, no What\'s New', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await launch(tester);
      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.byType(WhatsNewScreen), findsNothing);
      Navigator.of(tester.element(find.byType(OnboardingScreen))).pop();
      await tester.pumpAndSettle();
      expect(find.byType(WhatsNewScreen), findsNothing);
      // 功能介紹寫入 onboarding_seen_v1 後，下次啟動也不會被誤判成 V1 使用者
      expect((await prefs()).getBool('onboarding_seen_v1'), isTrue);
      await tester.pumpWidget(const SizedBox());
      await launch(tester);
      expect(find.byType(WhatsNewScreen), findsNothing);
      expect(find.byType(OnboardingScreen), findsNothing);
    });

    testWidgets('V1 upgrade: What\'s New once, onboarding not repeated',
        (tester) async {
      SharedPreferences.setMockInitialValues(
          {'onboarding_seen_v1': true, 'settings_v1': '{}'});
      await launch(tester);
      expect(find.byType(OnboardingScreen), findsNothing);
      expect(find.text(_whatsNewTitle), findsOneWidget);
      expect(find.text('用句子學單字'), findsOneWidget);
      expect(find.text('不熟悉單字優先'), findsOneWidget);
      expect(find.text('在哪裡找到'), findsOneWidget);
      await tester.tap(find.byKey(const Key('whats_new_done')));
      await tester.pumpAndSettle();
      expect(find.byType(WhatsNewScreen), findsNothing);
      expect(find.text('home'), findsOneWidget);

      // 重新啟動：不再自動出現
      await tester.pumpWidget(const SizedBox());
      await launch(tester);
      expect(find.byType(WhatsNewScreen), findsNothing);
    });

    testWidgets('can be reopened from the menu any time', (tester) async {
      SharedPreferences.setMockInitialValues(
          {'app_schema_version': 2, 'last_seen_whats_new_version': 'pe_2_0'});
      await tester.pumpWidget(MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => WhatsNewScreen.open(context),
            child: const Text('menu'),
          ),
        ),
      ));
      for (var i = 0; i < 2; i++) {
        await tester.tap(find.text('menu'));
        await tester.pumpAndSettle();
        expect(find.text(_whatsNewTitle), findsOneWidget);
        await tester.tap(find.byKey(const Key('whats_new_done')));
        await tester.pumpAndSettle();
      }
      // 從選單打開不改變已看過的紀錄
      expect((await prefs()).getString('last_seen_whats_new_version'), 'pe_2_0');
    });

    testWidgets('all 11 languages render the page', (tester) async {
      for (final locale in AppLocalizations.supportedLocales) {
        await tester.pumpWidget(MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const WhatsNewScreen(),
        ));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$locale');
        expect(find.byType(ListTile), findsNWidgets(4), reason: '$locale');
      }
    });

    testWidgets('home ⋮ menu has 新功能 and opens What\'s New', (tester) async {
      SharedPreferences.setMockInitialValues({});
      HomeScreenState.previewMode = true;
      addTearDown(() => HomeScreenState.previewMode = false);
      final tts = _SilentTts();
      final appState = AppState(
        wordRepository: _NoWords(),
        progressRepository: ProgressRepository(),
        ttsService: tts,
      )..debugPreview(data: [
          WordDataset(
            id: 'ngsl_2809',
            name: 'NGSL',
            shortName: 'NGSL',
            builtIn: true,
            items: const [
              WordItem(id: 'ngsl_2809_0000', word: 'the', translations: {}),
            ],
          ),
        ], premium: true);
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MultiProvider(
        providers: [
          Provider<TtsService>.value(value: tts),
          ChangeNotifierProvider.value(value: appState),
        ],
        child: MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeScreen(),
        ),
      ));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      expect(find.text('實用英文'), findsOneWidget);
      await tester.tap(find.text('新功能'));
      await tester.pumpAndSettle();
      expect(find.text(_whatsNewTitle), findsOneWidget);
    });
  });
}
