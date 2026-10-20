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
import 'package:english_learning_app/domain/models/playback_settings.dart';
import 'package:english_learning_app/domain/models/word_item.dart';
import 'package:english_learning_app/l10n/app_localizations.dart';
import 'package:english_learning_app/presentation/app_theme.dart';
import 'package:english_learning_app/presentation/providers/app_state.dart';
import 'package:english_learning_app/practical_english/data/sentence_repository.dart';
import 'package:english_learning_app/practical_english/presentation/providers/practical_english_state.dart';
import 'package:english_learning_app/practical_english/presentation/screens/sentence_detail_screen.dart';
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

/// 輸出資料夾 → 翻譯語言（en 介面不顯示內建翻譯）。
const _tr = {
  'zh': 'zh-TW', 'zh_Hans': 'zh-CN', 'ja': 'ja', 'ko': 'ko', 'vi': 'vi',
  'id': 'id', 'es': 'es', 'pt': 'pt-BR', 'th': 'th', 'ar': 'ar', 'en': 'en',
};
const _sentenceId = String.fromEnvironment('SENTENCE', defaultValue: 'pe_core_000946');

Future<void> _shoot(WidgetTester tester, String path) async {
  await tester.pump(const Duration(milliseconds: 500));
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
    testWidgets('practical english screenshot ${entry.key}', (tester) async {
      const dpr = 2.625;
      tester.view.devicePixelRatio = dpr;
      tester.view.physicalSize = const Size(1080, 2160);
      tester.view.padding = const FakeViewPadding(top: 24 * dpr, bottom: 16 * dpr);
      tester.view.viewPadding = const FakeViewPadding(top: 24 * dpr, bottom: 16 * dpr);
      tester.platformDispatcher.localesTestValue = [locale];
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      SharedPreferences.setMockInitialValues({});
      BackgroundL10n.debugLocale = locale;
      debugDisableShadows = false;

      final app = AppState(
        wordRepository: _NoWords(),
        progressRepository: ProgressRepository(),
        ttsService: _NoTts(),
      );
      app.debugPreview(data: data, premium: true, newSettings: const PlaybackSettings());
      final dir = await tester.runAsync(
          () => Directory.systemTemp.createTemp('pe_shot'));
      final core = File('assets/practical_english/pe_core.json').readAsStringSync();
      final pe = PracticalEnglishState(
        appState: app,
        tts: _NoTts(),
        sentences: SentenceRepository(
            loadBuiltInAsset: () async => core, baseDir: () async => dir!),
        baseDir: () async => dir!,
        onError: (e, st) => debugPrint('pe error $e'),
        translationKey: () => _tr[entry.key]!,
      );
      await tester.runAsync(() => pe.load());
      final list = pe.sentences;
      final idx = list.indexWhere((s) => s.id == _sentenceId);

      await tester.pumpWidget(RepaintBoundary(
        key: _key,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider<AppState>.value(value: app),
            ChangeNotifierProvider<PracticalEnglishState>.value(value: pe),
          ],
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
            themeMode: ThemeMode.light,
            builder: (context, child) => ColoredBox(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: SafeArea(top: false, child: child!),
            ),
            home: SentenceDetailScreen(
                sentences: list, initialIndex: idx < 0 ? 0 : idx),
          ),
        ),
      ));
      await tester.pump(const Duration(seconds: 1));
      await _shoot(tester, 'build/store_screenshots/${entry.key}/raw_6_practical.png');
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
      debugDisableShadows = true;
    });
  }
}
