import 'dart:ui' show PlatformDispatcher;

import 'package:material_ui/material_ui.dart' show ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deutschlernen/domain/models/app_settings.dart';
import 'package:deutschlernen/domain/models/reminder_settings.dart';

class SettingsRepository {
  static const _uiLanguageKey = 'ui_language';
  static const _wordLanguageKey = 'word_language';
  static const _themeModeKey = 'theme_mode'; // system / dark / light

  /// Old bool (dark or light), read while no [_themeModeKey] is saved.
  static const _legacyDarkThemeKey = 'dark_theme';
  static const _showTranscriptionKey = 'show_transcription';
  // New key: the old 'notifications' switch did nothing, so an old "on"
  // must not start reminders without asking for permission.
  static const _remindersEnabledKey = 'reminders_enabled';
  static const _reminderDaysKey = 'reminder_days'; // "1","2",… (weekday)
  static const _reminderTimesKey = 'reminder_times'; // "9:00","19:30",…
  static const _autoSpeakKey = 'auto_speak';
  static const _speechRateKey = 'speech_rate';
  static const _learnLevelsKey = 'learn_levels';

  /// One shared choice, saved before the two were separated.
  static const _legacyLanguageKey = 'language';

  /// Saved instead of a language code: follow the device language. Not just
  /// a removed key: then the legacy single choice would win again.
  static const systemLanguageCode = 'system';

  final _prefs = SharedPreferencesAsync();

  /// Language of the interface. Falls back to the old single choice.
  Future<String?> loadUiLanguageCode() async =>
      await _prefs.getString(_uiLanguageKey) ??
      await _prefs.getString(_legacyLanguageKey);

  /// Language of the word translations. Falls back to the old single choice.
  Future<String?> loadWordLanguageCode() async =>
      await _prefs.getString(_wordLanguageKey) ??
      await _prefs.getString(_legacyLanguageKey);

  Future<void> saveUiLanguageCode(String code) =>
      _prefs.setString(_uiLanguageKey, code);

  Future<void> saveWordLanguageCode(String code) =>
      _prefs.setString(_wordLanguageKey, code);

  /// Missing values stay at the defaults of [AppSettings].
  Future<AppSettings> loadSettings() async {
    const defaults = AppSettings();
    final themeName = await _prefs.getString(_themeModeKey);
    final legacyDark = await _prefs.getBool(_legacyDarkThemeKey);
    final rate = await _prefs.getDouble(_speechRateKey);

    return AppSettings(
      themeMode:
          ThemeMode.values.asNameMap()[themeName] ??
          switch (legacyDark) {
            true => ThemeMode.dark,
            false => ThemeMode.light,
            null => defaults.themeMode,
          },
      showTranscription:
          await _prefs.getBool(_showTranscriptionKey) ??
          defaults.showTranscription,
      reminders: await _loadReminders(defaults.reminders),
      autoSpeak: await _prefs.getBool(_autoSpeakKey) ?? defaults.autoSpeak,
      speechRate: (rate ?? defaults.speechRate).clamp(
        AppSettings.minSpeechRate,
        AppSettings.maxSpeechRate,
      ),
    );
  }

  Future<void> saveThemeMode(ThemeMode mode) =>
      _prefs.setString(_themeModeKey, mode.name);

  Future<void> saveShowTranscription(bool value) =>
      _prefs.setBool(_showTranscriptionKey, value);

  /// Broken or empty saved values fall back to [defaults].
  Future<ReminderSettings> _loadReminders(ReminderSettings defaults) async {
    final days = (await _prefs.getStringList(_reminderDaysKey))
        ?.map(int.tryParse)
        .whereType<int>()
        .where((d) => d >= DateTime.monday && d <= DateTime.sunday)
        .toSet();
    final times = (await _prefs.getStringList(_reminderTimesKey))
        ?.map(_parseTime)
        .whereType<ReminderTime>()
        .take(ReminderSettings.maxPerDay)
        .toList();
    return ReminderSettings(
      enabled: await _prefs.getBool(_remindersEnabledKey) ?? defaults.enabled,
      days: days == null || days.isEmpty ? defaults.days : days,
      times: times == null || times.isEmpty ? defaults.times : times,
    );
  }

  static ReminderTime? _parseTime(String text) {
    final parts = text.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]), m = int.tryParse(parts[1]);
    if (h == null || m == null || h < 0 || h > 23 || m < 0 || m > 59) {
      return null;
    }
    return (hour: h, minute: m);
  }

  Future<void> saveReminders(ReminderSettings reminders) async {
    await _prefs.setBool(_remindersEnabledKey, reminders.enabled);
    await _prefs.setStringList(_reminderDaysKey, [
      for (final d in reminders.days) '$d',
    ]);
    await _prefs.setStringList(_reminderTimesKey, [
      for (final t in reminders.times) '${t.hour}:${t.minute}',
    ]);
  }

  Future<void> saveAutoSpeak(bool value) =>
      _prefs.setBool(_autoSpeakKey, value);

  Future<void> saveSpeechRate(double value) =>
      _prefs.setDouble(_speechRateKey, value);

  /// Levels picked for learning; null = never chosen.
  Future<List<String>?> loadLearnLevels() =>
      _prefs.getStringList(_learnLevelsKey);

  Future<void> saveLearnLevels(Set<String> levels) =>
      _prefs.setStringList(_learnLevelsKey, levels.toList());

  String get deviceLanguageCode =>
      PlatformDispatcher.instance.locale.languageCode;
}
