import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  SoundService() {
    _player.setPlayerMode(PlayerMode.lowLatency);
  }

  final AudioPlayer _player = AudioPlayer();

  Future<void> playSwipe() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/swipe.mp3'));
    } catch (e) {
      // A missing sound file should never crash the app.
      debugPrint('Could not play swipe sound: $e');
    }
  }

  Future<void> dispose() => _player.dispose();
}