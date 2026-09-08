import 'package:flutter_tts/flutter_tts.dart';

/// TTS 服務抽象介面。目前是系統內建 TTS；
/// 之後若要換成雲端 TTS，只需要新增另一個實作，不影響上層播放邏輯。
abstract class TtsService {
  Future<void> speak(String text, {required String languageCode});
  Future<void> stop();
  Future<void> setRate(double rate);
  Future<List<Map<String, String>>> getVoices();
  Future<void> setVoice(Map<String, String> voice);
  Stream<void> get onComplete;
}

class SystemTtsService implements TtsService {
  final FlutterTts _tts = FlutterTts();

  SystemTtsService() {
    _tts.awaitSpeakCompletion(true);
  }

  @override
  Future<void> speak(String text, {required String languageCode}) async {
    await _tts.setLanguage(languageCode);
    await _tts.speak(text);
  }

  @override
  Future<void> stop() => _tts.stop();

  @override
  Future<void> setRate(double rate) => _tts.setSpeechRate(rate);

  @override
  Future<List<Map<String, String>>> getVoices() async {
    final voices = await _tts.getVoices;
    if (voices == null) return [];
    return (voices as List)
        .map<Map<String, String>>((v) => Map<String, String>.from(
              (v as Map).map((k, val) => MapEntry(k.toString(), val.toString())),
            ))
        .toList();
  }

  @override
  Future<void> setVoice(Map<String, String> voice) => _tts.setVoice(voice);

  @override
  Stream<void> get onComplete {
    // ignore: close_sinks
    final controller = Stream<void>.empty();
    _tts.setCompletionHandler(() {});
    return controller;
  }
}
