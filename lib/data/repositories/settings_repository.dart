import 'dart:ui' show PlatformDispatcher;

import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const _languageKey = 'language';

  final _prefs = SharedPreferencesAsync();

  Future<String?> loadLanguageCode() => _prefs.getString(_languageKey);

  Future<void> saveLanguageCode(String code) =>
      _prefs.setString(_languageKey, code);

  String get deviceLanguageCode =>
      PlatformDispatcher.instance.locale.languageCode;
}
