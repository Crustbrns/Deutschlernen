import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:deutschlernen/domain/models/app_settings.dart';

class SpeechService {
  SpeechService() {
    _tts.setLanguage('de-DE');
    _tts.setSpeechRate(AppSettings.defaultSpeechRate);
    // Cutting off the previous phrase makes the browser report an error for
    // it. That is expected, so it is only logged.
    _tts.setErrorHandler((message) => debugPrint('TTS: $message'));
  }

  final FlutterTts _tts = FlutterTts();

  /// Counts speak requests; only the newest one is allowed to play.
  int _latestRequest = 0;

  /// Browsers (Chrome especially) drop a speak() that comes right after
  /// cancel(), so there is a short pause in between.
  static const _afterStopPause = Duration(milliseconds: 120);

  /// 0 = slowest, 1 = fastest (flutter_tts scale).
  Future<void> setRate(double rate) => _tts.setSpeechRate(rate);

  Future<void> speak(String text) async {
    final request = ++_latestRequest;

    await _tts.stop();
    await Future<void>.delayed(_afterStopPause);

    // Another word was requested during the pause (fast swiping): skip this.
    if (request != _latestRequest) return;
    await _tts.speak(text);
  }

  Future<void> dispose() async {
    _latestRequest++;
    await _tts.stop();
  }
}
