import 'dart:async' show unawaited;

import 'package:flutter/foundation.dart';
import 'package:deutschlernen/data/repositories/language_repository.dart';
import 'package:deutschlernen/data/repositories/lookup_repository.dart';
import 'package:deutschlernen/data/repositories/progress_repository.dart';
import 'package:deutschlernen/data/repositories/settings_repository.dart';
import 'package:deutschlernen/data/repositories/word_repository.dart';
import 'package:deutschlernen/data/services/review_scheduler.dart';
import 'package:deutschlernen/data/services/speech_service.dart';
import 'package:deutschlernen/domain/models/app_language.dart';
import 'package:deutschlernen/domain/models/card_decision.dart';
import 'package:deutschlernen/domain/models/word.dart';
import 'package:deutschlernen/domain/models/word_progress.dart';
import 'package:deutschlernen/domain/models/word_status.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/settings/view_models/settings_view_model.dart';

class CardsViewModel extends ChangeNotifier {
  CardsViewModel({
    required this._wordRepository,
    required this._languageRepository,
    required this._settingsRepository,
    required this._lookupRepository,
    required this._progressRepository,
    required this._reviewScheduler,
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
  final ProgressRepository _progressRepository;
  final ReviewScheduler _reviewScheduler;
  final SpeechService _speechService;
  final SettingsViewModel _settingsViewModel;

  /// Size of one "learn new words" session.
  static const newWordsPerSession = 10;

  List<Word> _words = [];
  Map<String, Word> _wordsById = {};
  List<AppLanguage> _languages = [];

  /// Levels new words are taken from; all by default.
  Set<String> _learnLevels = {...Word.levels};

  /// Word id → progress. Words without an entry are new.
  Map<String, WordProgress> _progress = {};

  SessionMode _mode = SessionMode.newWords;

  /// Words of the current session. Ids are kept too, to rebuild the words
  /// when the translation language changes.
  List<String> _deckIds = [];
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
  final List<_Step> _history = [];
  CardDecision? _lastUndone;
  bool _isLoading = true;
  bool _isSwiping = false;

  /// All words, for the vocabulary.
  List<Word> get words => _words;

  /// Words of the current cards session.
  List<Word> get deck => _deck;
  SessionMode get mode => _mode;
  Set<String> get learnLevels => _learnLevels;

  /// New words left in the selected levels.
  int get newWordsLeft => _newWordIds().length;

  /// Words whose review time has come. Computed on each call, since time
  /// passes: a word learned 10 minutes ago may be due now.
  int get dueCount => _dueIds().length;

  /// Forgets everything about the word: it becomes new again.
  void resetProgress(String wordId) {
    if (_progress.remove(wordId) == null) return;
    notifyListeners();
    _saveProgress();
  }

  /// Learning status and next review of a word, for the word lists.
  WordState stateOf(String wordId) =>
      WordStatus.of(_progress[wordId], DateTime.now().toUtc());
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

  Iterable<String> _newWordIds() => _words
      .where(
        (w) => _learnLevels.contains(w.level) && !_progress.containsKey(w.id),
      )
      .map((w) => w.id);

  /// Due words, the most overdue first. Words no longer in the app are skipped.
  List<String> _dueIds() {
    final now = DateTime.now().toUtc();
    final due =
        _progress.entries
            .where((e) => e.value.isDue(now) && _wordsById.containsKey(e.key))
            .toList()
          ..sort((a, b) => a.value.card!.due.compareTo(b.value.card!.due));
    return [for (final e in due) e.key];
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    _languages = await _languageRepository.getLanguages();
    _uiLanguage = _pickLanguage(await _settingsRepository.loadUiLanguageCode());
    _wordLanguage = _pickLanguage(
      await _settingsRepository.loadWordLanguageCode(),
    );

    _setWords(await _wordRepository.getWords(_wordLanguage));
    _progress = await _progressRepository.load();
    _lookupCounts = await _lookupRepository.loadCounts();
    // Unknown saved levels are dropped; nothing valid left = all levels.
    final savedLevels = (await _settingsRepository.loadLearnLevels())
        ?.where(Word.levels.contains)
        .toSet();
    _learnLevels = (savedLevels == null || savedLevels.isEmpty)
        ? {...Word.levels}
        : savedLevels;
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
    _setWords(words);
    // Same ids, so the session and its position stay valid.
    _deck = [for (final id in _deckIds) _wordsById[id]!];
    notifyListeners();

    await _settingsRepository.saveWordLanguageCode(language.code);
  }

  void _setWords(List<Word> words) {
    _words = words;
    _wordsById = {for (final w in words) w.id: w};
  }

  /// Changes the levels new words come from. Applies to the next session.
  Future<void> setLearnLevels(Set<String> levels) async {
    if (levels.isEmpty) return; // a session needs words
    _learnLevels = levels;
    notifyListeners();
    await _settingsRepository.saveLearnLevels(levels);
  }

  /// Up to [newWordsPerSession] unseen words from the selected levels.
  void startNewWords() => _startSession(
    SessionMode.newWords,
    _newWordIds().take(newWordsPerSession),
  );

  /// All words that are due for review.
  void startReview() => _startSession(SessionMode.review, _dueIds());

  void _startSession(SessionMode mode, Iterable<String> ids) {
    _mode = mode;
    _deckIds = ids.toList();
    _deck = [for (final id in _deckIds) _wordsById[id]!];
    _history.clear();
    _lastUndone = null;
    notifyListeners();
  }

  /// The card has been released and starts flying off screen.
  void onSwipeStarted() {
    _isSwiping = true;
  }

  /// The card has left the screen.
  void onCardSwiped(CardDecision decision) {
    final id = _deckIds[index];
    final before = _progress[id];
    _progress[id] = switch (decision) {
      CardDecision.known => const WordProgress.known(),
      CardDecision.learn => _reviewScheduler.startLearning(),
      CardDecision.forgot => _reviewScheduler.review(
        before!,
        remembered: false,
      ),
      CardDecision.remembered => _reviewScheduler.review(
        before!,
        remembered: true,
      ),
    };
    _history.add(_Step(decision, id, before));
    _lastUndone = null;
    _isSwiping = false;
    notifyListeners();
    _speakCurrentIfAuto();
    _saveProgress();
  }

  /// Takes back the last answer, including its effect on the progress.
  void undo() {
    if (!canUndo || _isSwiping) return;
    final step = _history.removeLast();
    if (step.before case final before?) {
      _progress[step.wordId] = before;
    } else {
      _progress.remove(step.wordId);
    }
    _lastUndone = step.decision;
    notifyListeners();
    _saveProgress();
  }

  // Not awaited: the UI already shows the new state; the write runs after.
  void _saveProgress() => unawaited(_progressRepository.save(_progress));

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

/// One answer in the session, with the word's progress before it (null =
/// it was new), so undo can restore it.
class _Step {
  const _Step(this.decision, this.wordId, this.before);

  final CardDecision decision;
  final String wordId;
  final WordProgress? before;
}
