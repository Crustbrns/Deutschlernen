import 'dart:ui' show PlatformDispatcher;

import 'package:material_ui/material_ui.dart' show ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deutschlernen/domain/models/app_settings.dart';

class SettingsRepository {
  static const _uiLanguageKey = 'ui_language';
  static const _wordLanguageKey = 'word_language';
  static const _darkThemeKey = 'dark_theme';
  static const _showTranscriptionKey = 'show_transcription';
  static const _notificationsKey = 'notifications';
  static const _autoSpeakKey = 'auto_speak';
  static const _speechRateKey = 'speech_rate';

  /// One shared choice, saved before the two were separated.
  static const _legacyLanguageKey = 'language';

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
    final isDark = await _prefs.getBool(_darkThemeKey);
    final rate = await _prefs.getDouble(_speechRateKey);

    return AppSettings(
      themeMode: switch (isDark) {
        false => ThemeMode.light,
        _ => defaults.themeMode,
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
      _prefs.setBool(_darkThemeKey, mode != ThemeMode.light);

  Future<void> saveShowTranscription(bool value) =>
      _prefs.setBool(_showTranscriptionKey, value);

  Future<void> saveNotificationsEnabled(bool value) =>
      _prefs.setBool(_notificationsKey, value);

  Future<void> saveAutoSpeak(bool value) =>
      _prefs.setBool(_autoSpeakKey, value);

  Future<void> saveSpeechRate(double value) =>
      _prefs.setDouble(_speechRateKey, value);

  String get deviceLanguageCode =>
      PlatformDispatcher.instance.locale.languageCode;
}
