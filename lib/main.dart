import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'data/repositories/remote_word_repository.dart';
import 'data/repositories/progress_repository.dart';
import 'data/sources/device_quirks.dart';
import 'data/sources/tts_service.dart';
import 'data/sources/tts_audio_handler.dart';
import 'data/sources/subscription_service.dart';
import 'data/sources/ads_service.dart';
import 'data/sources/notification_service.dart';
import 'data/sources/background_l10n.dart';
import 'presentation/providers/app_state.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/app_theme.dart';
import 'domain/models/playback_settings.dart';

/// 背景播放服務的控制器。可能為 null——見下方說明。
TtsAudioHandler? _audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 無邊框畫面（edge-to-edge）：Android 15 以上目標 SDK 35 的 App 預設就是
  // 無邊框，這裡讓舊版 Android 也採用相同顯示方式，畫面延伸到狀態列與
  // 導覽列底下；內容避開系統列的處理在 MaterialApp 的 builder 裡。
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // 0.3.0：英文單字字型 Nunito（SIL OFL 1.1）授權，顯示在「關於」的授權清單。
  LicenseRegistry.addLicense(() async* {
    final text = await rootBundle.loadString('assets/fonts/Nunito-OFL.txt');
    yield LicenseEntryWithLineBreaks(const ['Nunito'], text);
  });

  // 每一個初始化步驟都個別包一層 try-catch：任何一個服務初始化失敗，
  // 都不該讓整個 App 開不起來。特別是 AudioService.init()——如果使用者
  // 「關閉 App」但背景播放的前景服務還沒真正結束，行程可能還存活在背景，
  // 這時重新開啟 App 再呼叫一次 AudioService.init() 會直接拋例外
  // （這個套件不允許重複初始化）。過去這裡沒有防呆，出現這個情況時
  // App 會卡死在啟動階段，只能刪除重裝——這裡修正這個問題。

  try {
    await Firebase.initializeApp();
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (e, st) {
    debugPrint('Firebase 初始化失敗（不影響 App 繼續啟動）：$e\n$st');
  }

  try {
    await SubscriptionService.initialize(
      const String.fromEnvironment('REVENUECAT_API_KEY'),
    );
  } catch (e, st) {
    debugPrint('RevenueCat 初始化失敗（不影響 App 繼續啟動）：$e\n$st');
  }

  try {
    await AdsService.initialize();
  } catch (e, st) {
    debugPrint('AdMob 初始化失敗（不影響 App 繼續啟動）：$e\n$st');
  }

  try {
    await NotificationService.initialize();
  } catch (e, st) {
    debugPrint('本地通知初始化失敗（不影響 App 繼續啟動）：$e\n$st');
  }

  await DeviceQuirks.detect();

  // 第十七版：冷啟動時清掉上次關閉 App 殘留的朗讀卡片（必須在 AudioService.init 之前）。
  await NotificationService.clearStaleMediaNotification();

  try {
    _audioHandler = await AudioService.init(
      builder: () => TtsAudioHandler(),
      config: AudioServiceConfig(
        androidNotificationChannelId: 'tw.bcc.englishapp.audio',
        androidNotificationChannelName:
            BackgroundL10n.current().audioChannelName,
        // 第十七版：預設 true 時，服務結束（onDestroy）只會 DETACH 前景通知，
        // 播放中把 App 從最近使用列表滑掉，卡片會變成孤兒留在鎖屏/通知中心。
        // 改 false → 服務結束時 STOP_FOREGROUND_REMOVE，卡片一起移除。
        // 代價：App 完全結束後，按耳機播放鍵不會自動喚醒朗讀（本 App 用不到）。
        androidResumeOnClick: false,
        // 不再設成 ongoing:true——這個設定會讓通知變成「不可滑掉」，
        // 但同時似乎也影響了 App 被關閉、呼叫 stop() 之後通知/鎖屏卡片
        // 沒辦法正常消失的問題。改用套件預設值（false），這是絕大多數
        // 使用 audio_service 的 App 採用、驗證過穩定的標準做法：
        // 播放時通知一樣會顯示，只是使用者理論上滑得掉（實務上很少
        // 人會刻意去滑掉正在播放的通知），換來的是關閉 App 後通知/
        // 鎖屏卡片能正確消失，對使用體驗來說更重要。
      ),
    ).timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        throw TimeoutException('AudioService.init() 逾時，可能是前一個背景'
            '播放行程還沒釋放，改用不含背景播放控制器的模式啟動。');
      },
    );
  } catch (e, st) {
    debugPrint('背景播放服務初始化失敗，改用純前景播放模式：$e\n$st');
    // 失敗或逾時都不指派 _audioHandler，讓 App 至少能正常開啟、正常使用；
    // 只是這次啟動不會有鎖屏/通知列控制卡片（通常發生在使用者上次把 App
    // 整個滑掉、但背景播放的前景服務行程還沒真正結束的邊緣情況）。
    // 這裡用逾時而不是單純的例外捕捉，是因為這種情況有時候是「卡住等待」
    // 而不是「立刻丟出錯誤」，單純 try-catch 攔不住卡住的狀況。
  }

  runApp(const EnglishLearningApp());
}

class EnglishLearningApp extends StatelessWidget {
  const EnglishLearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ttsService = SystemTtsService();
    return MultiProvider(
      providers: [
        Provider<TtsService>.value(value: ttsService),
        ChangeNotifierProvider(
          create: (_) => AppState(
            wordRepository: RemoteWordRepository(),
            progressRepository: ProgressRepository(),
            ttsService: ttsService,
            audioHandler: _audioHandler,
          ),
        ),
      ],
      child: Selector<AppState, AppearanceMode>(
        selector: (_, s) => s.settings.appearance,
        builder: (context, appearance, _) => MaterialApp(
        // 所有畫面統一避開底部導覽列與左右瀏海（上方狀態列由各頁 AppBar
        // 自動處理），避免無邊框模式下清單最後一項或按鈕被手勢列蓋住；
        // 讓出的區域塗上背景色，看起來跟畫面連成一片。
        builder: (context, child) => ColoredBox(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SafeArea(top: false, child: child ?? const SizedBox.shrink()),
        ),
        // 工作管理員（最近使用的 App 清單）顯示的名稱，跟著手機語言走
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        debugShowCheckedModeBanner: false,
        // 依手機語言自動選擇介面語言；中文會再分辨繁體/簡體，
        // 不支援的語言用英文介面。規則集中在 BackgroundL10n.resolve，
        // 讓介面、通知、教材翻譯的語言判斷完全一致。
        localeListResolutionCallback: (locales, supported) =>
            BackgroundL10n.resolve(locales ?? const []),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('zh'),
          Locale('ja'),
          Locale('ko'),
          Locale('vi'),
          Locale('id'),
          Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
          Locale('es'),
          Locale('pt'),
          Locale('th'),
          Locale('ar'),
          Locale('en'),
        ],
        // 0.3.0：淺色「柔光卡片」＋深色「夜讀深綠」，外觀可在播放設定切換
        //（跟隨系統／淺色／深色）。配色見 app_theme.dart。
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: switch (appearance) {
          AppearanceMode.light => ThemeMode.light,
          AppearanceMode.dark => ThemeMode.dark,
          AppearanceMode.system => ThemeMode.system,
        },
        home: const HomeScreen(),
        ),
      ),
    );
  }
}
