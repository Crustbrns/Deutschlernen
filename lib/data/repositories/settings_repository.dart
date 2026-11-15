import 'dart:ui' show PlatformDispatcher;

import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const _uiLanguageKey = 'ui_language';
  static const _wordLanguageKey = 'word_language';

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

  String get deviceLanguageCode =>
      PlatformDispatcher.instance.locale.languageCode;
}
