import 'package:flutter/foundation.dart';
import 'package:deutschlernen/data/repositories/language_repository.dart';
import 'package:deutschlernen/data/repositories/settings_repository.dart';
import 'package:deutschlernen/data/repositories/word_repository.dart';
import 'package:deutschlernen/data/services/speech_service.dart';
import 'package:deutschlernen/domain/models/app_language.dart';
import 'package:deutschlernen/domain/models/card_decision.dart';
import 'package:deutschlernen/domain/models/word.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';

class CardsViewModel extends ChangeNotifier {
  CardsViewModel({
    required this._wordRepository,
    required this._languageRepository,
    required this._settingsRepository,
    required this._speechService,
  });

  final WordRepository _wordRepository;
  final LanguageRepository _languageRepository;
  final SettingsRepository _settingsRepository;
  final SpeechService _speechService;

  List<Word> _words = [];
  List<AppLanguage> _languages = [];
  static const _defaultLanguage = AppLanguage(
    code: 'en',
    label: 'English',
    country: 'GB',
  );

  /// Language of the interface texts.
  AppLanguage _uiLanguage = _defaultLanguage;

  /// Language of the word translations.
  AppLanguage _wordLanguage = _defaultLanguage;
  AppStrings _strings = const AppStrings({});
  final List<CardDecision> _history = [];
  CardDecision? _lastUndone;
  bool _isLoading = true;
  bool _isSwiping = false;

  List<Word> get words => _words;
  List<AppLanguage> get languages => _languages;
  AppLanguage get uiLanguage => _uiLanguage;
  AppLanguage get wordLanguage => _wordLanguage;
  AppStrings get strings => _strings;
  bool get isLoading => _isLoading;

  /// Index of the current card = number of decisions made so far.
  int get index => _history.length;
  bool get isFinished => !_isLoading && index >= _words.length;
  bool get canUndo => _history.isNotEmpty;
  double get progress => _words.isEmpty ? 0 : index / _words.length;

  /// Set after an undo, so the UI can fly the card back in from the right side.
  CardDecision? get lastUndone => _lastUndone;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    _languages = await _languageRepository.getLanguages();
    _uiLanguage = _pickLanguage(await _settingsRepository.loadUiLanguageCode());
    _wordLanguage = _pickLanguage(
      await _settingsRepository.loadWordLanguageCode(),
    );

    _words = await _wordRepository.getWords(_wordLanguage);
    _strings = AppStrings(await _languageRepository.getUiTexts(_uiLanguage));
    _history.clear();
    _lastUndone = null;

    _isLoading = false;
    notifyListeners();
  }

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

  /// Switches the interface language. Words and progress stay as they are.
  Future<void> setUiLanguage(AppLanguage language) async {
    if (language == _uiLanguage) return;

    final texts = await _languageRepository.getUiTexts(language);

    _uiLanguage = language;
    _strings = AppStrings(texts);
    notifyListeners();

    await _settingsRepository.saveUiLanguageCode(language.code);
  }

  /// Switches the language of the translations without losing the progress.
  Future<void> setWordLanguage(AppLanguage language) async {
    if (language == _wordLanguage) return;

    final words = await _wordRepository.getWords(language);

    _wordLanguage = language;
    _words = words;
    notifyListeners();

    await _settingsRepository.saveWordLanguageCode(language.code);
  }

  /// The card has been released and starts flying off screen.
  void onSwipeStarted() {
    _isSwiping = true;
  }

  /// The card has left the screen.
  void onCardSwiped(CardDecision decision) {
    _history.add(decision);
    _lastUndone = null;
    _isSwiping = false;
    notifyListeners();
  }

  void undo() {
    if (!canUndo || _isSwiping) return;
    _lastUndone = _history.removeLast();
    notifyListeners();
  }

  void restart() {
    _history.clear();
    _lastUndone = null;
    notifyListeners();
  }

  void speak(String text) => _speechService.speak(text);
}
