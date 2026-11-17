import 'package:flutter/foundation.dart';
import 'package:deutschlernen/data/repositories/language_repository.dart';
import 'package:deutschlernen/data/repositories/settings_repository.dart';
import 'package:deutschlernen/domain/models/app_language.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';

/// The two language choices (interface and word translations) and the
/// interface strings. Words themselves are reloaded by LearningViewModel,
/// which listens here for [wordLanguage] changes.
class LanguageViewModel extends ChangeNotifier {
  LanguageViewModel({
    required this._languageRepository,
    required this._settingsRepository,
  });

  final LanguageRepository _languageRepository;
  final SettingsRepository _settingsRepository;

  static const _defaultLanguage = AppLanguage(
    code: 'en',
    label: 'English',
    hello: 'Hello',
    uiNote: 'Menus and texts in English',
    wordsNote: 'Word translations in English',
  );

  List<AppLanguage> _languages = [];
  AppLanguage _uiLanguage = _defaultLanguage;
  AppLanguage _wordLanguage = _defaultLanguage;

  /// "Same as system": the language comes from the device (no saved code yet
  /// counts too, so new users start here).
  bool _uiFollowsSystem = true;
  bool _wordFollowsSystem = true;
  AppStrings _strings = const AppStrings({});
  bool _isLoading = true;

  List<AppLanguage> get languages => _languages;

  /// Language of the interface texts.
  AppLanguage get uiLanguage => _uiLanguage;

  /// Language of the word translations.
  AppLanguage get wordLanguage => _wordLanguage;

  /// What the user picked for the interface; null = same as the system.
  AppLanguage? get uiChoice => _uiFollowsSystem ? null : _uiLanguage;

  /// What the user picked for the words; null = same as the system.
  AppLanguage? get wordChoice => _wordFollowsSystem ? null : _wordLanguage;
  AppStrings get strings => _strings;
  bool get isLoading => _isLoading;

  /// What "same as system" gives right now (shown in the language sheet).
  AppLanguage get systemLanguage => _pickLanguage(null);

  Future<void> load() async {
    _languages = await _languageRepository.getLanguages();
    final uiCode = await _settingsRepository.loadUiLanguageCode();
    final wordCode = await _settingsRepository.loadWordLanguageCode();
    _uiFollowsSystem = _followsSystem(uiCode);
    _wordFollowsSystem = _followsSystem(wordCode);
    _uiLanguage = _pickLanguage(_uiFollowsSystem ? null : uiCode);
    _wordLanguage = _pickLanguage(_wordFollowsSystem ? null : wordCode);
    _strings = AppStrings(
      await _languageRepository.getUiTexts(_uiLanguage),
      languageCode: _uiLanguage.code,
    );
    _isLoading = false;
    notifyListeners();
  }

  /// Switches the interface language; null = same as the system.
  Future<void> setUiLanguage(AppLanguage? choice) async {
    final followsSystem = choice == null;
    final language = choice ?? systemLanguage;
    if (followsSystem == _uiFollowsSystem && language == _uiLanguage) return;

    if (language != _uiLanguage) {
      final texts = await _languageRepository.getUiTexts(language);
      _strings = AppStrings(texts, languageCode: language.code);
    }
    _uiLanguage = language;
    _uiFollowsSystem = followsSystem;
    notifyListeners();

    await _settingsRepository.saveUiLanguageCode(
      choice?.code ?? SettingsRepository.systemLanguageCode,
    );
  }

  /// Switches the language of the translations; null = same as the system.
  /// Progress is kept: it is stored by word id, not by translation.
  Future<void> setWordLanguage(AppLanguage? choice) async {
    final followsSystem = choice == null;
    final language = choice ?? systemLanguage;
    if (followsSystem == _wordFollowsSystem && language == _wordLanguage) {
      return;
    }
    _wordLanguage = language;
    _wordFollowsSystem = followsSystem;
    notifyListeners();

    await _settingsRepository.saveWordLanguageCode(
      choice?.code ?? SettingsRepository.systemLanguageCode,
    );
  }

  /// Nothing saved, the "system" mark, or a language that no longer exists.
  bool _followsSystem(String? savedCode) =>
      savedCode == null ||
      savedCode == SettingsRepository.systemLanguageCode ||
      !_languages.any((l) => l.code == savedCode);

  /// Saved choice, else the device language, else English, else the first one.
  AppLanguage _pickLanguage(String? savedCode) {
    AppLanguage? find(String? code) {
      for (final language in _languages) {
        if (language.code == code) return language;
      }
      return null;
    }

    return find(savedCode) ??
        find(_settingsRepository.deviceLanguageCode) ??
        find(LanguageRepository.fallbackCode) ??
        _languages.first;
  }
}
