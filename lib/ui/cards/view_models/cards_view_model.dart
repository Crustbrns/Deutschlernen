import 'package:flutter/foundation.dart';
import 'package:deutschlernen/data/repositories/language_repository.dart';
import 'package:deutschlernen/data/repositories/lookup_repository.dart';
import 'package:deutschlernen/data/repositories/settings_repository.dart';
import 'package:deutschlernen/data/repositories/word_repository.dart';
import 'package:deutschlernen/data/services/speech_service.dart';
import 'package:deutschlernen/domain/models/app_language.dart';
import 'package:deutschlernen/domain/models/card_decision.dart';
import 'package:deutschlernen/domain/models/word.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/settings/view_models/settings_view_model.dart';

class CardsViewModel extends ChangeNotifier {
  CardsViewModel({
    required this._wordRepository,
    required this._languageRepository,
    required this._settingsRepository,
    required this._lookupRepository,
    required this._speechService,
    required this._settingsViewModel,
  }) {
    // Settings that change the cards (e.g. transcription) redraw them.
    _settingsViewModel.addListener(notifyListeners);
  }

  final WordRepository _wordRepository;
  final LanguageRepository _languageRepository;
  final SettingsRepository _settingsRepository;
  final LookupRepository _lookupRepository;
  final SpeechService _speechService;
  final SettingsViewModel _settingsViewModel;

  List<Word> _words = [];
  List<AppLanguage> _languages = [];

  /// Levels the learning session takes words from; all by default.
  Set<String> _learnLevels = {...Word.levels};

  /// Words of the current session: [_words] filtered by [_learnLevels].
  List<Word> _deck = [];

  /// Word id → times opened from the vocabulary search.
  Map<String, int> _lookupCounts = {};
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

  /// All words, for the vocabulary.
  List<Word> get words => _words;

  /// Words of the learning session (selected levels only).
  List<Word> get deck => _deck;
  Set<String> get learnLevels => _learnLevels;
  List<AppLanguage> get languages => _languages;
  AppLanguage get uiLanguage => _uiLanguage;
  AppLanguage get wordLanguage => _wordLanguage;
  AppStrings get strings => _strings;
  bool get isLoading => _isLoading;
  bool get showTranscription => _settingsViewModel.showTranscription;

  /// 0 for a word that was never searched.
  int lookupCount(String wordId) => _lookupCounts[wordId] ?? 0;

  /// Called when a word is opened from the search results: +1 and save.
  Future<void> recordLookup(String wordId) async {
    // Update in memory before the first await: the card reads the count
    // right after this call, while saving is still in progress.
    _lookupCounts.update(wordId, (count) => count + 1, ifAbsent: () => 1);
    notifyListeners();
    await _lookupRepository.saveCounts(_lookupCounts);
  }

  /// Index of the current card = number of decisions made so far.
  int get index => _history.length;
  bool get isFinished => !_isLoading && index >= _deck.length;
  bool get canUndo => _history.isNotEmpty;
  double get progress => _deck.isEmpty ? 0 : index / _deck.length;

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
    _lookupCounts = await _lookupRepository.loadCounts();
    // Unknown saved levels are dropped; nothing valid left = all levels.
    final savedLevels = (await _settingsRepository.loadLearnLevels())
        ?.where(Word.levels.contains)
        .toSet();
    _learnLevels = (savedLevels == null || savedLevels.isEmpty)
        ? {...Word.levels}
        : savedLevels;
    _rebuildDeck();
    _strings = AppStrings(
      await _languageRepository.getUiTexts(_uiLanguage),
      languageCode: _uiLanguage.code,
    );
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
    _strings = AppStrings(texts, languageCode: language.code);
    notifyListeners();

    await _settingsRepository.saveUiLanguageCode(language.code);
  }

  /// Switches the language of the translations without losing the progress.
  Future<void> setWordLanguage(AppLanguage language) async {
    if (language == _wordLanguage) return;

    final words = await _wordRepository.getWords(language);

    _wordLanguage = language;
    _words = words;
    // Same ids in the same order, so the session position stays valid.
    _rebuildDeck();
    notifyListeners();

    await _settingsRepository.saveWordLanguageCode(language.code);
  }

  /// Changes the levels to learn from. The session starts over: the old
  /// position points into a different list of words.
  Future<void> setLearnLevels(Set<String> levels) async {
    if (levels.isEmpty) return; // an empty session makes no sense
    _learnLevels = levels;
    _rebuildDeck();
    _history.clear();
    _lastUndone = null;
    notifyListeners();
    await _settingsRepository.saveLearnLevels(levels);
  }

  void _rebuildDeck() {
    _deck = _words.where((w) => _learnLevels.contains(w.level)).toList();
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
    _speakCurrentIfAuto();
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
    _speakCurrentIfAuto();
  }

  /// The cards screen has opened: read the word on top, if the user wants that.
  void onCardsOpened() => _speakCurrentIfAuto();

  void _speakCurrentIfAuto() {
    if (!_settingsViewModel.autoSpeak || _isLoading || isFinished) return;
    _speechService.speak(_deck[index].withArticle);
  }

  void speak(String text) => _speechService.speak(text);

  @override
  void dispose() {
    _settingsViewModel.removeListener(notifyListeners);
    super.dispose();
  }
}
