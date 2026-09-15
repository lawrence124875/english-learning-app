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
    );
  } catch (e, st) {
    debugPrint('背景播放服務初始化失敗，改用純前景播放模式：$e\n$st');
    // 失敗時不指派 _audioHandler，AppState 會以「沒有背景播放控制器」的
    // 模式運作：App 仍可正常使用、正常朗讀，只是這次啟動不會有鎖屏/
    // 通知列控制卡片（通常只會發生在背景服務還沒真正結束的邊緣情況，
    // 使用者之後把 App 完全滑掉、重新整個開啟一次就會恢復正常）。
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
          colorSchemeSeed: Colors.teal,
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
