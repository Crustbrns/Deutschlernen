import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:deutschlernen/domain/models/app_settings.dart';

class SpeechService {
  SpeechService() {
    _tts.setLanguage('de-DE');
    _tts.setSpeechRate(AppSettings.defaultSpeechRate);
    // Cutting off the previous phrase makes the browser report an error for
    // it. That is expected, so it is only logged.
    _tts.setErrorHandler((message) => debugPrint('TTS: $message'));
    // The default iOS category is muted by the silent switch; playback is not,
    // since the user taps "listen" on purpose. kIsWeb first: flutter_tts checks
    // dart:io Platform, which throws in the browser.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        // Music only gets quieter; flutter_tts restores it after the word.
        [IosTextToSpeechAudioCategoryOptions.duckOthers],
        IosTextToSpeechAudioMode.spokenAudio,
      );
    }
  }

  final FlutterTts _tts = FlutterTts();
  final _mutedTaps = StreamController<void>.broadcast();

  /// Fires when the user asks to hear something while the volume is at zero.
  Stream<void> get mutedTaps => _mutedTaps.stream;

  /// Counts speak requests; only the newest one is allowed to play.
  int _latestRequest = 0;

  /// Browsers (Chrome especially) drop a speak() that comes right after
  /// cancel(), so there is a short pause in between.
  static const _afterStopPause = Duration(milliseconds: 120);

  /// 0 = slowest, 1 = fastest (flutter_tts scale).
  Future<void> setRate(double rate) => _tts.setSpeechRate(rate);

  /// [warnIfMuted] is off for automatic speech: a warning on every card
  /// would be noise, only a tap gets one.
  Future<void> speak(String text, {bool warnIfMuted = true}) async {
    final request = ++_latestRequest;

    // Speaks anyway: on iOS reading the volume activates the audio session
    // (music ducks), and only finishing the speech releases it again.
    if (warnIfMuted && await _isMuted()) _mutedTaps.add(null);

    await _tts.stop();
    await Future<void>.delayed(_afterStopPause);

    // Another word was requested during the pause (fast swiping): skip this.
    if (request != _latestRequest) return;
    await _tts.speak(text);
  }

  // The plugin reads dart:io Platform, which throws in the browser.
  Future<bool> _isMuted() async {
    if (kIsWeb) return false;
    final volume = await FlutterVolumeController.getVolume();
    return volume != null && volume < 0.01;
  }

  Future<void> dispose() async {
    _latestRequest++;
    await _tts.stop();
    await _mutedTaps.close();
  }
}
