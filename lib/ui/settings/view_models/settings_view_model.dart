import 'package:material_ui/material_ui.dart' show ThemeMode;
import 'package:flutter/foundation.dart';
import 'package:deutschlernen/data/repositories/settings_repository.dart';
import 'package:deutschlernen/data/services/speech_service.dart';
import 'package:deutschlernen/domain/models/app_settings.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({
    required this._settingsRepository,
    required this._speechService,
  });

  final SettingsRepository _settingsRepository;
  final SpeechService _speechService;

  AppSettings _settings = const AppSettings();

  AppSettings get settings => _settings;
  ThemeMode get themeMode => _settings.themeMode;
  bool get showTranscription => _settings.showTranscription;
  bool get notificationsEnabled => _settings.notificationsEnabled;
  bool get autoSpeak => _settings.autoSpeak;
  double get speechRate => _settings.speechRate;

  Future<void> load() async {
    _settings = await _settingsRepository.loadSettings();
    await _speechService.setRate(_settings.speechRate);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _settings.themeMode) return;
    _settings = _settings.copyWith(themeMode: mode);
    notifyListeners();
    await _settingsRepository.saveThemeMode(mode);
  }

  Future<void> setShowTranscription(bool value) async {
    _settings = _settings.copyWith(showTranscription: value);
    notifyListeners();
    await _settingsRepository.saveShowTranscription(value);
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _settings = _settings.copyWith(notificationsEnabled: value);
    notifyListeners();
    await _settingsRepository.saveNotificationsEnabled(value);
  }

  Future<void> setAutoSpeak(bool value) async {
    _settings = _settings.copyWith(autoSpeak: value);
    notifyListeners();
    await _settingsRepository.saveAutoSpeak(value);
  }

  /// Called when the slider is released (the drag itself stays in the
  /// widget): applies and saves the speed and says a sample word so the user
  /// hears what they picked.
  Future<void> commitSpeechRate(double value) async {
    _settings = _settings.copyWith(speechRate: value);
    _speechService.setRate(value);
    notifyListeners();
    await _settingsRepository.saveSpeechRate(value);
    await _speechService.speak('Guten Tag');
  }
}
