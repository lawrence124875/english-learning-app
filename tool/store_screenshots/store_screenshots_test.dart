// Google Play 商店截圖（0.3.1 起）：用真正的 App 畫面（Flutter widget）渲染，
// 不是手繪示意圖。執行方式見同資料夾 README.md。
//
// 輸出 build/store_screenshots/<lang>/raw_*.png（1080×2160，無狀態列），
// 再由 compose.py 補上狀態列／手勢列並輸出到最終資料夾。
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:english_learning_app/data/repositories/progress_repository.dart';
import 'package:english_learning_app/data/repositories/word_repository.dart';
import 'package:english_learning_app/data/sources/tts_service.dart';
import 'package:english_learning_app/data/sources/background_l10n.dart';
import 'package:english_learning_app/data/repositories/stats_repository.dart';
import 'package:english_learning_app/domain/models/playback_settings.dart';
import 'package:english_learning_app/domain/models/word_item.dart';
import 'package:english_learning_app/l10n/app_localizations.dart';
import 'package:english_learning_app/presentation/app_theme.dart';
import 'package:english_learning_app/presentation/providers/app_state.dart';
import 'package:english_learning_app/presentation/screens/home_screen.dart';
import 'package:english_learning_app/presentation/screens/onboarding_screen.dart';
import 'package:english_learning_app/presentation/screens/stats_screen.dart';
import 'package:english_learning_app/presentation/widgets/settings_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _fontDir = String.fromEnvironment('FONT_DIR', defaultValue: '/home/claude/fonts');
const _flutterRoot = String.fromEnvironment('FLUTTER_ROOT');
const _only = String.fromEnvironment('LANGS');

/// 輸出資料夾名稱 → Locale、CJK 字型優先順序（跟手機內建字型一致）。
final _langs = <String, (Locale, String)>{
  'zh': (const Locale('zh'), 'TC'),
  'zh_Hans': (const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'), 'SC'),
  'ja': (const Locale('ja'), 'JP'),
  'ko': (const Locale('ko'), 'KR'),
  'vi': (const Locale('vi'), 'TC'),
  'id': (const Locale('id'), 'TC'),
  'es': (const Locale('es'), 'TC'),
  'pt': (const Locale('pt'), 'TC'),
  'th': (const Locale('th'), 'TC'),
  'ar': (const Locale('ar'), 'TC'),
  'en': (const Locale('en'), 'TC'),
};

Future<void> _loadFont(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final f in files) {
    final bytes = File(f).readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await loader.load();
}

Future<void> _loadFonts() async {
  final mf = '$_flutterRoot/bin/cache/artifacts/material_fonts';
  await _loadFont('Roboto', [
    for (final w in ['Regular', 'Medium', 'Bold']) '$mf/Roboto-$w.ttf'
  ]);
  await _loadFont('MaterialIcons', ['$mf/MaterialIcons-Regular.otf']);
  await _loadFont('Nunito', ['assets/fonts/Nunito-ExtraBold.ttf']);
  for (final c in ['TC', 'SC', 'JP', 'KR']) {
    await _loadFont('Noto$c', [
      for (final w in ['Regular', 'Medium', 'Bold']) '$_fontDir/NotoSans$c-$w.otf'
    ]);
  }
  for (final s in ['Thai', 'Arabic']) {
    await _loadFont('Noto$s', [
      for (final w in ['Regular', 'Medium', 'Bold']) '$_fontDir/NotoSans$s-$w.ttf'
    ]);
  }
}

ThemeData _withFallback(ThemeData t, String cjk) {
  final fb = ['Noto$cjk', 'NotoThai', 'NotoArabic'];
  return t.copyWith(
    textTheme: t.textTheme.apply(fontFamily: 'Roboto', fontFamilyFallback: fb),
    primaryTextTheme:
        t.primaryTextTheme.apply(fontFamily: 'Roboto', fontFamilyFallback: fb),
  );
}

List<WordDataset> _datasets() {
  final manifest = jsonDecode(File('assets/data/manifest.json').readAsStringSync());
  final order = (manifest['datasets'] as Map).keys.cast<String>();
  return [
    for (final id in order)
      WordDataset.fromJson({
        ...jsonDecode(File('assets/data/$id.json').readAsStringSync())
            as Map<String, dynamic>,
        'builtIn': true,
      }),
  ];
}

class _NoTts implements TtsService {
  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value();
}

class _NoWords implements WordRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value();
}

final _key = GlobalKey();

Future<void> _shoot(WidgetTester tester, String path) async {
  await tester.pumpAndSettle();
  await tester.runAsync(() async {
    final boundary =
        _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: tester.view.devicePixelRatio);
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    File(path)
      ..createSync(recursive: true)
      ..writeAsBytesSync(png!.buffer.asUint8List());
  });
}

void main() {
  final data = _datasets();

  setUpAll(() async {
    await _loadFonts();
  });

  for (final entry in _langs.entries) {
    if (_only.isNotEmpty && !_only.split(',').contains(entry.key)) continue;
    final (locale, cjk) = entry.value;
    final out = 'build/store_screenshots/${entry.key}';

    testWidgets('store screenshots ${entry.key}', (tester) async {
      // 1080×2160（9:18），上方留 24dp 狀態列、下方 16dp 手勢列。
      const dpr = 2.625;
      tester.view.devicePixelRatio = dpr;
      tester.view.physicalSize = const Size(1080, 2160);
      tester.view.padding = const FakeViewPadding(top: 24 * dpr, bottom: 16 * dpr);
      tester.view.viewPadding = const FakeViewPadding(top: 24 * dpr, bottom: 16 * dpr);
      tester.platformDispatcher.localesTestValue = [locale];
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      // 學習統計各教材進度（共 1,248 個）。
      final learned = <String>[
        for (var i = 0; i < 860; i++) 'ngsl_2809:$i',
        for (var i = 0; i < 260; i++) 'ngsl_spoken_720:$i',
        for (var i = 0; i < 98; i++) 'phrase_list_506:$i',
        for (var i = 0; i < 30; i++) 'phave_list_150:$i',
      ];
      SharedPreferences.setMockInitialValues({'stats_all_learned_v1': learned});
      HomeScreenState.previewMode = true;
      BackgroundL10n.debugLocale = locale;
      debugDisableShadows = false;

      final state = AppState(
        wordRepository: _NoWords(),
        progressRepository: ProgressRepository(),
        ttsService: _NoTts(),
      );

      Future<void> show(Widget home,
          {required ThemeMode mode, int step = 887, PlaybackSettings? s}) async {
        state.debugPreview(
            data: data, step: step, newSettings: s ?? const PlaybackSettings());
        state.stats = const LearningStats(learnedToday: 12, totalLearned: 1248);
        state.reminderEnabled = true;
        await tester.pumpWidget(const SizedBox());
        await tester.pumpWidget(RepaintBoundary(
          key: _key,
          child: ChangeNotifierProvider<AppState>.value(
            value: state,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              locale: locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              theme: _withFallback(AppTheme.light(), cjk),
              darkTheme: _withFallback(AppTheme.dark(), cjk),
              themeMode: mode,
              builder: (context, child) => ColoredBox(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: SafeArea(top: false, child: child!),
              ),
              home: home,
            ),
          ),
        ));
      }

      // 1 首頁（淺色）
      await show(const HomeScreen(), mode: ThemeMode.light, step: 887);
      await _shoot(tester, '$out/raw_1_home.png');
      // 2 首頁（深色）
      await show(const HomeScreen(), mode: ThemeMode.dark, step: 1620);
      await _shoot(tester, '$out/raw_2_dark.png');
      // 3 首頁＋播放設定展開（雙語朗讀、重複次數、語速）
      await show(const HomeScreen(),
          mode: ThemeMode.light,
          step: 507,
          s: const PlaybackSettings(settingsPanelExpanded: true));
      await tester.pumpAndSettle();
      // 捲到「播放設定」標題在畫面上方約 1/3 處，上面還看得到單字卡下緣。
      final panelTop = tester.getTopLeft(find.byType(SettingsPanel)).dy;
      await tester.drag(find.byType(SingleChildScrollView).first,
          Offset(0, -(panelTop - 300)));
      await _shoot(tester, '$out/raw_3_settings.png');
      // 4 特色介紹第一頁
      await show(const OnboardingScreen(), mode: ThemeMode.light);
      await _shoot(tester, '$out/raw_4_intro.png');
      // 5 學習統計
      await show(const StatsScreen(), mode: ThemeMode.light);
      await _shoot(tester, '$out/raw_5_stats.png');

      await tester.pumpWidget(const SizedBox());
      debugDisableShadows = true; // 測試框架要求結束前還原
    });
  }
}
