import 'dart:async' show unawaited;
import 'dart:math' show Random;

import 'package:flutter/foundation.dart';
import 'package:deutschlernen/data/repositories/history_repository.dart';
import 'package:deutschlernen/data/repositories/language_repository.dart';
import 'package:deutschlernen/data/repositories/lookup_repository.dart';
import 'package:deutschlernen/data/repositories/progress_repository.dart';
import 'package:deutschlernen/data/repositories/settings_repository.dart';
import 'package:deutschlernen/data/repositories/word_repository.dart';
import 'package:deutschlernen/data/services/review_scheduler.dart';
import 'package:deutschlernen/data/services/speech_service.dart';
import 'package:deutschlernen/domain/models/app_language.dart';
import 'package:deutschlernen/domain/models/card_decision.dart';
import 'package:deutschlernen/domain/models/status_counts.dart';
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
    required this._historyRepository,
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
  final HistoryRepository _historyRepository;
  final ReviewScheduler _reviewScheduler;
  final SpeechService _speechService;
  final SettingsViewModel _settingsViewModel;

  /// Size of one "learn new words" session.
  static const newWordsPerSession = 10;

  /// How many words a day the user aims to learn.
  static const dailyGoal = 10;

  List<Word> _words = [];
  Map<String, Word> _wordsById = {};
  List<AppLanguage> _languages = [];

  /// Levels new words are taken from; all by default.
  Set<String> _learnLevels = {...Word.levels};

  /// Word id → progress. Words without an entry are new.
  Map<String, WordProgress> _progress = {};

  /// Daily status counts for the progress chart, keyed by local midnight.
  Map<DateTime, StatusCounts> _statusHistory = {};
  Map<DateTime, StatusCounts> get statusHistory =>
      Map.unmodifiable(_statusHistory);

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

  /// "Same as system": the language comes from the device (no saved code yet
  /// counts too, so new users start here).
  bool _uiFollowsSystem = true;
  bool _wordFollowsSystem = true;
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

  /// Words for "learn new words": unrecalled (pink) ones plus new ones in
  /// the selected levels.
  int get newWordsLeft => _unrecalledIds().length + _newWordIds().length;

  /// Words learned today: first "remember" on a pink word since midnight.
  int get learnedToday {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    return _progress.values
        .where((p) => !(p.firstRecalledAt?.isBefore(midnight) ?? true))
        .length;
  }

  /// A word is answered with "forgot / remember" (pink word, or any word in
  /// a review) rather than "already know / learn" (new word).
  bool needsRecall(String wordId) =>
      _mode == SessionMode.review || (_progress[wordId]?.isUnrecalled ?? false);

  /// The top card is a pink word in a new-words session: it is answered with
  /// "don't remember" / "remember" instead of "already know" / "learn".
  bool get currentIsUnrecalled =>
      !isFinished && (_progress[_deckIds[index]]?.isUnrecalled ?? false);

  /// Words whose review time has come. Computed on each call, since time
  /// passes: a word learned 10 minutes ago may be due now.
  int get dueCount => _dueIds().length;

  /// Forgets everything about the word: it becomes new again.
  void resetProgress(String wordId) {
    if (_progress.remove(wordId) == null) return;
    notifyListeners();
    _saveProgress();
  }

  /// Forgets the progress of every word: all become new again.
  void resetAllProgress() {
    if (_progress.isEmpty) return;
    _progress.clear();
    notifyListeners();
    _saveProgress();
  }

  /// Learning status and next review of a word, for the word lists.
  WordState stateOf(String wordId) =>
      WordStatus.of(_progress[wordId], DateTime.now().toUtc());
  List<AppLanguage> get languages => _languages;
  AppLanguage get uiLanguage => _uiLanguage;
  AppLanguage get wordLanguage => _wordLanguage;
  bool get uiFollowsSystem => _uiFollowsSystem;
  bool get wordFollowsSystem => _wordFollowsSystem;

  /// What "same as system" gives right now (shown in the language sheet).
  AppLanguage get systemLanguage => _pickLanguage(null);
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

  /// Top bar progress. New-words session: today's goal. Review session:
  /// share of the session's words that are done; the bar moves only when a
  /// word is answered for good. A card that comes back later
  /// ("learn", "don't remember" on a pink word) doesn't move it, and an
  /// "already know" word is swapped for the next new word: the bar stays.
  double get progress {
    // New words: the bar is the daily goal, so it opens at e.g. 60% when 6
    // of 10 words were learned earlier today and grows with each learned one.
    if (_mode == SessionMode.newWords) {
      return (learnedToday / dailyGoal).clamp(0.0, 1.0);
    }
    // Review: share of this session's words answered.
    // "Already know" brings in a replacement word, so the total stays; only
    // when no new word was left to bring in does the total shrink.
    final unreplaced = _history
        .where((s) => s.decision == CardDecision.known && s.insertedAt == null)
        .length;
    final done = _history
        .where((s) => s.decision != CardDecision.known && s.insertedAt == null)
        .length;
    final total = _sessionSize - unreplaced;
    return total <= 0 ? 0 : done / total;
  }

  /// Words the session started with; repeats inserted later aren't added.
  int _sessionSize = 0;

  /// Set after an undo, so the UI can fly the card back in from the right side.
  CardDecision? get lastUndone => _lastUndone;

  Iterable<String> _newWordIds() => _words
      .where(
        (w) => _learnLevels.contains(w.level) && !_progress.containsKey(w.id),
      )
      .map((w) => w.id);

  /// Pink words (chosen, never recalled), oldest first. All levels: they
  /// were started already, so a level filter shouldn't hide them.
  List<String> _unrecalledIds() {
    final ids =
        _progress.entries
            .where((e) => e.value.isUnrecalled && _wordsById.containsKey(e.key))
            .toList()
          ..sort(
            (a, b) => a.value.card!.cardId.compareTo(b.value.card!.cardId),
          );
    return [for (final e in ids) e.key];
  }

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
    final uiCode = await _settingsRepository.loadUiLanguageCode();
    final wordCode = await _settingsRepository.loadWordLanguageCode();
    _uiFollowsSystem = _followsSystem(uiCode);
    _wordFollowsSystem = _followsSystem(wordCode);
    _uiLanguage = _pickLanguage(_uiFollowsSystem ? null : uiCode);
    _wordLanguage = _pickLanguage(_wordFollowsSystem ? null : wordCode);

    _setWords(await _wordRepository.getWords(_wordLanguage));
    _progress = await _progressRepository.load();
    _statusHistory = await _historyRepository.load();
    // Today gets a snapshot even without answers, so the chart has it.
    _recordSnapshot();
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

  /// Switches the interface language; null = same as the system. Words and
  /// progress stay as they are.
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

  /// Switches the language of the translations without losing the progress;
  /// null = same as the system.
  Future<void> setWordLanguage(AppLanguage? choice) async {
    final followsSystem = choice == null;
    final language = choice ?? systemLanguage;
    if (followsSystem == _wordFollowsSystem && language == _wordLanguage) {
      return;
    }

    if (language != _wordLanguage) {
      _setWords(await _wordRepository.getWords(language));
      // Same ids, so the session and its position stay valid.
      _syncDeck();
    }
    _wordLanguage = language;
    _wordFollowsSystem = followsSystem;
    notifyListeners();

    await _settingsRepository.saveWordLanguageCode(
      choice?.code ?? SettingsRepository.systemLanguageCode,
    );
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
  /// Pink words left from earlier sessions go first.
  void startNewWords() => _startSession(
    SessionMode.newWords,
    [..._unrecalledIds(), ..._newWordIds()].take(newWordsPerSession),
  );

  /// All words that are due for review.
  void startReview() => _startSession(SessionMode.review, _dueIds());

  void _startSession(SessionMode mode, Iterable<String> ids) {
    _mode = mode;
    _deckIds = ids.toList();
    _sessionSize = _deckIds.length;
    _syncDeck();
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
    final unrecalled = before?.isUnrecalled ?? false;
    _progress[id] = switch (decision) {
      CardDecision.known => const WordProgress.known(),
      CardDecision.learn => _reviewScheduler.startLearning(),
      // A pink word stays pink: FSRS starts only with the first "remember".
      CardDecision.forgot when unrecalled => before!,
      CardDecision.forgot => _reviewScheduler.review(
        before!,
        remembered: false,
      ),
      CardDecision.remembered => _reviewScheduler.review(
        before!,
        remembered: true,
      ),
    };
    // Just started, or a pink word not remembered: show it again later in
    // this session.
    final again =
        decision == CardDecision.learn ||
        (decision == CardDecision.forgot && unrecalled);
    final insertedAt = again
        ? _insertLater(id)
        : decision == CardDecision.known
        ? _appendReplacement()
        : null;
    _history.add(_Step(decision, id, before, insertedAt));
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
    if (step.insertedAt case final at?) {
      _deckIds.removeAt(at);
      _syncDeck();
    }
    if (step.before case final before?) {
      _progress[step.wordId] = before;
    } else {
      _progress.remove(step.wordId);
    }
    _lastUndone = step.decision;
    notifyListeners();
    _saveProgress();
  }

  final _random = Random();

  /// Puts [id] 5–10 cards after the current one (or at the end, if fewer
  /// are left). Returns its position, so undo can take it out again.
  int _insertLater(String id) {
    final at = (index + 1 + 5 + _random.nextInt(6)).clamp(0, _deckIds.length);
    _deckIds.insert(at, id);
    _syncDeck();
    return at;
  }

  /// "Already know" in a new-words session: the next new word goes to the
  /// end of the deck, so the session still has as many words to learn.
  /// Returns its position, or null when there is no new word left.
  int? _appendReplacement() {
    if (_mode != SessionMode.newWords) return null;
    final inDeck = _deckIds.toSet();
    final next = _newWordIds().where((id) => !inDeck.contains(id)).firstOrNull;
    if (next == null) return null;
    _deckIds.add(next);
    _syncDeck();
    return _deckIds.length - 1;
  }

  void _syncDeck() => _deck = [for (final id in _deckIds) _wordsById[id]!];

  // Not awaited: the UI already shows the new state; the write runs after.
  void _saveProgress() {
    unawaited(_progressRepository.save(_progress));
    _recordSnapshot();
  }

  /// Overwrites today's entry in the history with the current counts.
  void _recordSnapshot() {
    final now = DateTime.now();
    final nowUtc = now.toUtc();
    var known = 0, learning = 0, review = 0, learned = 0;
    for (final p in _progress.values) {
      switch (WordStatus.of(p, nowUtc).status) {
        case WordStatus.known:
          known++;
        case WordStatus.learning:
          learning++;
        case WordStatus.review:
          review++;
        case WordStatus.learned:
          learned++;
        case WordStatus.newWord:
          break;
      }
    }
    _statusHistory[DateTime(now.year, now.month, now.day)] = StatusCounts(
      known: known,
      learning: learning,
      review: review,
      learned: learned,
    );
    unawaited(_historyRepository.save(_statusHistory));
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

/// One answer in the session, with the word's progress before it (null =
/// it was new), so undo can restore it.
class _Step {
  const _Step(this.decision, this.wordId, this.before, this.insertedAt);

  final CardDecision decision;
  final String wordId;
  final WordProgress? before;

  /// Where a card was added later in the deck: the same word again, or a
  /// replacement after "already know" (null = nothing was added).
  final int? insertedAt;
}
