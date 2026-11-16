import 'package:flutter_test/flutter_test.dart';
import 'package:english_learning_app/domain/models/playback_settings.dart';

void main() {
  test('朗讀例句預設關、翻譯預設開，舊設定檔讀得回來', () {
    const d = PlaybackSettings();
    expect(d.speakExample, isFalse);
    expect(d.speakExampleTranslation, isTrue);
    final old = PlaybackSettings.fromJson({'readMode': 1});
    expect(old.speakExample, isFalse);
    expect(old.speakExampleTranslation, isTrue);
  });

  test('朗讀例句設定可存取', () {
    final s = const PlaybackSettings()
        .copyWith(speakExample: true, speakExampleTranslation: false);
    final back = PlaybackSettings.fromJson(s.toJson());
    expect(back.speakExample, isTrue);
    expect(back.speakExampleTranslation, isFalse);
  });
}
