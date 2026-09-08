import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/repositories/word_repository.dart';
import 'data/repositories/progress_repository.dart';
import 'data/sources/tts_service.dart';
import 'presentation/providers/app_state.dart';
import 'presentation/screens/home_screen.dart';

void main() {
  runApp(const EnglishLearningApp());
}

class EnglishLearningApp extends StatelessWidget {
  const EnglishLearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(
        wordRepository: LocalAssetWordRepository(),
        progressRepository: ProgressRepository(),
        ttsService: SystemTtsService(),
      ),
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
