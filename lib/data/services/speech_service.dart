import 'package:flutter_tts/flutter_tts.dart';

class SpeechService {
  SpeechService() {
    _tts.setLanguage('de-DE');
    _tts.setSpeechRate(0.4);
  }

  final FlutterTts _tts = FlutterTts();

  Future<void> speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> dispose() async {
    await _tts.stop();
  }
}
