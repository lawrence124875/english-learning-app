import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'data/repositories/word_repository.dart';
import 'data/repositories/progress_repository.dart';
import 'data/sources/tts_service.dart';
import 'data/sources/tts_audio_handler.dart';
import 'data/sources/subscription_service.dart';
import 'data/sources/ads_service.dart';
import 'data/sources/notification_service.dart';
import 'presentation/providers/app_state.dart';
import 'presentation/screens/home_screen.dart';

late TtsAudioHandler _audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Android 上 google-services.json 已由 Gradle 外掛處理，
  // 這裡不需要額外傳入 FirebaseOptions。
  await Firebase.initializeApp();

  // 把 Flutter 框架層級的錯誤、以及非同步例外，都送去 Crashlytics，
  // 這樣測試者遇到當機時，我們不用等對方主動回報就能看到錯誤內容。
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // RevenueCat 訂閱付費：金鑰在編譯時期由 --dart-define 注入，
  // 不寫死在原始碼裡。
  await SubscriptionService.initialize(
    const String.fromEnvironment('REVENUECAT_API_KEY'),
  );

  await AdsService.initialize();
  await NotificationService.initialize();

  // 初始化背景播放服務：讓 App 在鎖屏/切到背景時仍可繼續朗讀，
  // 並在鎖屏/通知列顯示目前單字＋中文意思（類似音樂播放器）。
  _audioHandler = await AudioService.init(
    builder: () => TtsAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'tw.bcc.englishapp.audio',
      androidNotificationChannelName: '英語學習朗讀',
      androidNotificationOngoing: true,
    ),
  );
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
            wordRepository: LocalAssetWordRepository(),
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
