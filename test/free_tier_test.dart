import 'package:english_learning_app/data/repositories/progress_repository.dart';
import 'package:english_learning_app/data/repositories/word_repository.dart';
import 'package:english_learning_app/data/sources/tts_service.dart';
import 'package:english_learning_app/domain/models/word_item.dart';
import 'package:english_learning_app/presentation/providers/app_state.dart';
import 'package:flutter_test/flutter_test.dart';

class _Tts implements TtsService {
  @override
  Future<TtsLanguageStatus> checkLanguage(String languageCode) async =>
      TtsLanguageStatus.unavailable;
  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value();
}

class _Words implements WordRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value();
}

WordDataset _ds(int n, {bool builtIn = false}) => WordDataset(
      id: builtIn ? 'ngsl' : 'custom_1',
      name: 'x',
      shortName: 'x',
      builtIn: builtIn,
      wordLocale: builtIn ? 'en-US' : 'es-ES',
      items: [
        for (var i = 0; i < n; i++)
          WordItem(id: '$i', word: 'w$i', translations: const {})
      ],
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  AppState state() => AppState(
      wordRepository: _Words(),
      progressRepository: ProgressRepository(),
      ttsService: _Tts());

  test('free tier: 1/3 of built-in and custom lists (unchanged in v20)', () {
    final s = state();
    expect(s.unlockedCount(_ds(2809, builtIn: true)), 936);
    expect(s.unlockedCount(_ds(300)), 100);
    s.isPremium = true;
    expect(s.unlockedCount(_ds(300)), 300);
  });

  test('checkTtsLanguage passes the service result through', () async {
    expect(await state().checkTtsLanguage('th'), TtsLanguageStatus.unavailable);
  });
}
