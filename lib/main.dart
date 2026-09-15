import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'data/repositories/remote_word_repository.dart';
import 'data/repositories/progress_repository.dart';
import 'data/sources/tts_service.dart';
import 'data/sources/tts_audio_handler.dart';
import 'data/sources/subscription_service.dart';
import 'data/sources/ads_service.dart';
import 'data/sources/notification_service.dart';
import 'presentation/providers/app_state.dart';
import 'presentation/screens/home_screen.dart';

/// 背景播放服務的控制器。可能為 null——見下方說明。
TtsAudioHandler? _audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  try {
    _audioHandler = await AudioService.init(
      builder: () => TtsAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'tw.bcc.englishapp.audio',
        androidNotificationChannelName: '英語學習朗讀',
        androidNotificationOngoing: true,
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
      child: MaterialApp(
        title: '智慧聽覺巡航',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme.light(
            // 柔和鼠尾草綠/藍綠色：研究顯示冷色調有助於放鬆專注、
            // 利於長期記憶保存，且對眼睛負擔較小，適合長時間閱讀學習。
            primary: Color(0xFF5B8A72),
            onPrimary: Colors.white,
            primaryContainer: Color(0xFFDCEEE1),
            onPrimaryContainer: Color(0xFF1E3A2A),
            secondary: Color(0xFF6B8CAE),
            onSecondary: Colors.white,
            // 暖色只用在需要吸引注意力的重點（例如標記不熟悉單字的
            // 星號），依色彩心理學研究應少量點綴、避免過度刺激。
            tertiary: Color(0xFFE0A458),
            onTertiary: Colors.white,
            surface: Color(0xFFFAFAF7),
            onSurface: Color(0xFF2C2C28),
            surfaceContainerHighest: Color(0xFFF0F0EA),
            error: Color(0xFFC5705D),
            onError: Colors.white,
          ),
          scaffoldBackgroundColor: const Color(0xFFFAFAF7),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFFAFAF7),
            foregroundColor: Color(0xFF2C2C28),
            elevation: 0,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
