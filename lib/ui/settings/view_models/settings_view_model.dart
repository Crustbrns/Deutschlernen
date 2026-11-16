import 'package:material_ui/material_ui.dart' show ThemeMode;
import 'package:flutter/foundation.dart';
import 'package:deutschlernen/data/repositories/settings_repository.dart';
import 'package:deutschlernen/data/services/notification_service.dart';
import 'package:deutschlernen/data/services/speech_service.dart';
import 'package:deutschlernen/domain/models/app_settings.dart';
import 'package:deutschlernen/domain/models/reminder_settings.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({
    required this._settingsRepository,
    required this._speechService,
    required this._notificationService,
  });

  final SettingsRepository _settingsRepository;
  final SpeechService _speechService;
  final NotificationService _notificationService;

  AppSettings _settings = const AppSettings();

  AppSettings get settings => _settings;
  ThemeMode get themeMode => _settings.themeMode;
  bool get showTranscription => _settings.showTranscription;
  ReminderSettings get reminders => _settings.reminders;
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

  /// Turning on asks for the system permission first. Returns false when
  /// it was denied: reminders stay off, the UI explains how to allow them.
  Future<bool> setRemindersEnabled(bool value) async {
    if (value && !await _notificationService.requestPermission()) return false;
    await _setReminders(reminders.copyWith(enabled: value));
    return true;
  }

  Future<void> setReviewReminders(bool value) =>
      _setReminders(reminders.copyWith(review: value));

  Future<void> setLearnReminders(bool value) =>
      _setReminders(reminders.copyWith(learn: value));

  /// [days] as in DateTime.weekday; an empty set is ignored.
  Future<void> setReminderDays(Set<int> days) async {
    if (days.isEmpty) return;
    await _setReminders(reminders.copyWith(days: days));
  }

  /// 1–3 reminders a day.
  Future<void> setReminderCount(int count) =>
      _setReminders(reminders.withCount(count));

  Future<void> setReminderTime(int index, ReminderTime time) =>
      _setReminders(reminders.withTime(index, time));

  Future<void> openNotificationSettings() =>
      _notificationService.openSystemSettings();

  Future<void> _setReminders(ReminderSettings value) async {
    _settings = _settings.copyWith(reminders: value);
    notifyListeners();
    await _settingsRepository.saveReminders(value);
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
