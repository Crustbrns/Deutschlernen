import 'dart:ui' show PlatformDispatcher;

import 'package:material_ui/material_ui.dart' show ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deutschlernen/domain/models/app_settings.dart';

class SettingsRepository {
  static const _uiLanguageKey = 'ui_language';
  static const _wordLanguageKey = 'word_language';
  static const _themeModeKey = 'theme_mode'; // system / dark / light

  /// Old bool (dark or light), read while no [_themeModeKey] is saved.
  static const _legacyDarkThemeKey = 'dark_theme';
  static const _showTranscriptionKey = 'show_transcription';
  static const _notificationsKey = 'notifications';
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
      notificationsEnabled:
          await _prefs.getBool(_notificationsKey) ??
          defaults.notificationsEnabled,
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

  Future<void> saveNotificationsEnabled(bool value) =>
      _prefs.setBool(_notificationsKey, value);

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
