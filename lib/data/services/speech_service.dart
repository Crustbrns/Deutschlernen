import 'package:flutter_tts/flutter_tts.dart';
import 'package:deutschlernen/domain/models/app_settings.dart';

class SpeechService {
  SpeechService() {
    _tts.setLanguage('de-DE');
    _tts.setSpeechRate(AppSettings.defaultSpeechRate);
  }

  final FlutterTts _tts = FlutterTts();

  /// 0 = slowest, 1 = fastest (flutter_tts scale).
  Future<void> setRate(double rate) => _tts.setSpeechRate(rate);

  Future<void> speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> dispose() async {
    await _tts.stop();
  }
}
