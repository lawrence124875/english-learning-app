import 'package:english_learning_app/data/sources/tts_service.dart';
import 'package:english_learning_app/l10n/app_localizations.dart';
import 'package:english_learning_app/presentation/screens/import_dataset_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('flutter_tts');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  void answer(Object? Function() result) {
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'isLanguageAvailable') return result();
      return null;
    });
  }

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  group('SystemTtsService.checkLanguage', () {
    test('engine says yes → available', () async {
      answer(() => true);
      expect(await SystemTtsService().checkLanguage('th'),
          TtsLanguageStatus.available);
    });
    test('engine says no → unavailable', () async {
      answer(() => false);
      expect(await SystemTtsService().checkLanguage('th'),
          TtsLanguageStatus.unavailable);
    });
    test('query throws → unknown (not available)', () async {
      answer(() => throw PlatformException(code: 'x'));
      final tts = SystemTtsService();
      expect(await tts.checkLanguage('th'), TtsLanguageStatus.unknown);
      // 舊方法維持原行為（失敗時回 true），只給既有呼叫端用。
      expect(await tts.isLanguageAvailable('th'), isTrue);
    });
    test('unreadable result → unknown', () async {
      answer(() => 'maybe');
      expect(await SystemTtsService().checkLanguage('th'),
          TtsLanguageStatus.unknown);
    });
  });

  group('importVoiceNote', () {
    final l = lookupAppLocalizations(const Locale('zh'));
    test('available or not yet checked → no note', () {
      expect(importVoiceNote(TtsLanguageStatus.available, 'ไทย', l), isNull);
      expect(importVoiceNote(null, 'ไทย', l), isNull);
    });
    test('unavailable and unknown → different notes naming the language', () {
      final missing = importVoiceNote(TtsLanguageStatus.unavailable, 'ไทย', l)!;
      final unknown = importVoiceNote(TtsLanguageStatus.unknown, 'ไทย', l)!;
      expect(missing, contains('ไทย'));
      expect(unknown, contains('ไทย'));
      expect(missing, isNot(unknown));
    });
  });
}
