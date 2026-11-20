import 'dart:async' show unawaited;

import 'package:flutter/foundation.dart';
import 'package:deutschlernen/data/repositories/history_repository.dart';
import 'package:deutschlernen/data/repositories/lookup_repository.dart';
import 'package:deutschlernen/data/repositories/own_words_repository.dart';
import 'package:deutschlernen/data/repositories/progress_repository.dart';
import 'package:deutschlernen/data/repositories/settings_repository.dart';
import 'package:deutschlernen/data/repositories/word_repository.dart';
import 'package:deutschlernen/data/services/review_scheduler.dart';
import 'package:deutschlernen/data/services/speech_service.dart';
import 'package:deutschlernen/domain/models/definition_mode.dart';
import 'package:deutschlernen/domain/models/app_language.dart';
import 'package:deutschlernen/domain/models/card_decision.dart';
import 'package:deutschlernen/domain/models/card_session.dart';
import 'package:deutschlernen/domain/models/chart_bars.dart';
import 'package:deutschlernen/domain/models/day_snapshot.dart';
import 'package:deutschlernen/domain/models/own_word.dart';
import 'package:deutschlernen/domain/models/progress_book.dart';
import 'package:deutschlernen/domain/models/reminder_plan.dart';
import 'package:deutschlernen/domain/models/study_streak.dart';
import 'package:deutschlernen/domain/models/word.dart';
import 'package:deutschlernen/domain/models/word_status.dart';
import 'package:deutschlernen/ui/core/view_models/language_view_model.dart';
import 'package:deutschlernen/ui/settings/view_models/settings_view_model.dart';

/// Words, the user's progress on them and the current cards session; shared
/// by all tabs and the cards screen. The rules live in ProgressBook and
/// CardSession; this class loads, saves and notifies the UI.
class LearningViewModel extends ChangeNotifier {
  LearningViewModel({
    required this._wordRepository,
    required this._settingsRepository,
    required this._lookupRepository,
    required this._ownWordsRepository,
    required this._progressRepository,
    required this._historyRepository,
    required this._reviewScheduler,
    required this._speechService,
    required this._settingsViewModel,
    required this._languageViewModel,
  }) {
    // Settings that change the cards (e.g. transcription) redraw them.
    _settingsViewModel.addListener(notifyListeners);
    _languageViewModel.addListener(_onLanguageChanged);
  }

  final WordRepository _wordRepository;
  final SettingsRepository _settingsRepository;
  final LookupRepository _lookupRepository;
  final OwnWordsRepository _ownWordsRepository;
  final ProgressRepository _progressRepository;
  final HistoryRepository _historyRepository;
  final ReviewScheduler _reviewScheduler;
  final SpeechService _speechService;
  final SettingsViewModel _settingsViewModel;
  final LanguageViewModel _languageViewModel;

  /// Size of one "learn new words" session.
  static const newWordsPerSession = 10;

  /// How many words a day the user aims to learn.
  static const dailyGoal = 10;

  List<Word> _words = [];
  List<Word> _catalogWords = [];
  List<OwnWord> _ownWords = [];
  Map<String, Word> _wordsById = {};
  Map<String, List<Word>> _wordsByLevel = Word.byLevel(const []);
  List<String> _translations = [];

  /// Translation language [_words] were loaded in.
  AppLanguage? _wordsLanguage;

  ProgressBook _progress = ProgressBook();

  /// Levels new words and reviews are taken from; all by default.
  Set<String> _learnLevels = {...Word.levels};

  /// Daily snapshots for the progress chart, keyed by local midnight.
  Map<DateTime, DaySnapshot> _statusHistory = {};

  /// Word id → times opened from the Categories search.
  Map<String, int> _lookupCounts = {};

  /// Null until the first session starts.
  CardSession? _session;

  /// Words of [_session], kept as a list so the cards get the same one on
  /// every rebuild.
  List<Word> _deck = [];
  CardDecision? _lastUndone;
  bool _isLoading = true;
  bool _isSwiping = false;

  bool get isLoading => _isLoading;

  /// All words, for the Categories tab.
  List<Word> get words => _words;

  /// User-created words, in their saved order.
  List<Word> get ownWords => [for (final word in _ownWords) _asWord(word)];

  /// Words of each level, in [Word.levels] order.
  Map<String, List<Word>> get wordsByLevel => _wordsByLevel;

  /// Every word's translation: wrong options for the "choose" mode.
  List<String> get translations => _translations;
  Set<String> get learnLevels => _learnLevels;

  /// Progress chart for [period]: its bars and their totals per layer.
  ({List<ChartBar> bars, List<int> totals}) chartFor(ChartPeriod period) {
    final bars = chartBars(period, _statusHistory, DateTime.now());
    return (bars: bars, totals: periodTotals(bars));
  }

  /// Words in each status right now, per chart layer.
  List<int> get currentTotals => latestCounts(_statusHistory).stack;

  /// Words known now (green or "already know"): progress to [wordGoal].
  int get masteredCount => latestCounts(_statusHistory).mastered;
  int get wordGoal => _settingsViewModel.wordGoal;

  /// The daily streak, as of now.
  StudyStreak get streak => StudyStreak.of(_statusHistory, DateTime.now());
  bool get showTranscription => _settingsViewModel.showTranscription;
  DefinitionMode get definitionMode => _settingsViewModel.definitionMode;

  /// Learning status and next review of a word, for the word lists.
  WordState stateOf(String wordId) =>
      _progress.stateOf(wordId, DateTime.now().toUtc());

  /// Words for "learn new words": pink and new words of the selected levels.
  int get newWordsLeft => _unrecalledIds().length + _newWordIds().length;

  /// Words whose review time has come. Computed on each call, since time
  /// passes: a word learned 10 minutes ago may be due now.
  int get dueCount => _dueIds().length;

  /// Words learned today: first "remember" on a pink word since midnight.
  int get learnedToday {
    final now = DateTime.now();
    return _progress.recalledSince(DateTime(now.year, now.month, now.day));
  }

  /// Share (0–1) of the level's words the user has decided on: "already
  /// know" or started learning.
  double seenShare(String level) =>
      _progress.decidedShare([for (final w in _wordsByLevel[level]!) w.id]);

  /// Share of the user's own words already seen: known or started.
  double get ownWordsSeenShare =>
      _progress.decidedShare(_ownWords.map((word) => word.id).toList());

  /// Review times of the selected levels' words, for the reminders.
  List<DateTime> get reviewDueTimes => _progress.dueTimes(_inLearnLevels);

  /// 0 for a word that was never searched.
  int lookupCount(String wordId) => _lookupCounts[wordId] ?? 0;

  // --- Session, for the cards screen ---

  /// Words of the current cards session.
  List<Word> get deck => _deck;
  SessionMode get mode => _session?.mode ?? SessionMode.newWords;
  int get index => _session?.index ?? 0;
  bool get isFinished => !_isLoading && (_session?.isFinished ?? true);
  bool get canUndo => _session?.canUndo ?? false;

  /// Set after an undo, so the UI can fly the card back in from the right side.
  CardDecision? get lastUndone => _lastUndone;

  /// The word is answered with "forgot / remember" (pink word, or any word
  /// in a review) rather than "already know / learn".
  bool needsRecall(String wordId) => _session?.needsRecall(wordId) ?? false;

  /// [needsRecall] for the top card.
  bool get currentNeedsRecall =>
      !isFinished && _session!.needsRecall(_session!.currentId);

  /// Top bar progress. New-words session: today's goal, so the bar opens
  /// at e.g. 60% when 6 of 10 words were learned earlier today. Review
  /// session: share of the session's words that are done.
  double get progress => mode == SessionMode.newWords
      ? (learnedToday / dailyGoal).clamp(0.0, 1.0)
      : _session?.answeredShare ?? 0;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    await _loadWords(_languageViewModel.wordLanguage);
    _ownWords = await _ownWordsRepository.load();
    _refreshWordCollections();
    _progress = ProgressBook(await _progressRepository.load());
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

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadWords(AppLanguage language) async {
    _wordsLanguage = language;
    _catalogWords = await _wordRepository.getWords(language);
    _refreshWordCollections();
  }

  void _refreshWordCollections() {
    _words = [..._catalogWords, for (final word in _ownWords) _asWord(word)];
    _wordsById = {for (final w in _words) w.id: w};
    _wordsByLevel = Word.byLevel(_words);
    _translations = [for (final w in _words) w.translation];
    _syncDeck();
  }

  /// Saves a user-created word without assigning it to a learning level.
  Future<void> addOwnWord(String german, String translation) async {
    final trimmedGerman = german.trim();
    final trimmedTranslation = translation.trim();
    if (trimmedGerman.isEmpty || trimmedTranslation.isEmpty) {
      throw ArgumentError('A German word and its translation are required.');
    }

    final word = OwnWord(
      id: 'own-${DateTime.now().microsecondsSinceEpoch}',
      german: trimmedGerman,
      translation: trimmedTranslation,
    );
    final updated = [..._ownWords, word];
    await _ownWordsRepository.save(updated);
    _ownWords = updated;
    _refreshWordCollections();
    notifyListeners();
  }

  static Word _asWord(OwnWord word) => Word(
    id: word.id,
    article: '',
    german: word.german,
    plural: null,
    translation: word.translation,
    level: '',
    transcription: '',
    definition: '',
    definitionTranslation: null,
    examples: const [],
  );

  /// Reloads the words when the translation language changes.
  Future<void> _onLanguageChanged() async {
    final language = _languageViewModel.wordLanguage;
    if (_isLoading || language == _wordsLanguage) return;
    await _loadWords(language);
    notifyListeners();
  }

  /// Changes the levels new words and reviews come from. Applies to the
  /// next session.
  Future<void> setLearnLevels(Set<String> levels) async {
    if (levels.isEmpty) return; // a session needs words
    _learnLevels = levels;
    notifyListeners();
    await _settingsRepository.saveLearnLevels(levels);
  }

  /// Forgets everything about the word: it becomes new again.
  void resetProgress(String wordId) {
    if (!_progress.remove(wordId)) return;
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

  /// Called when a word is opened from the search results: +1 and save.
  Future<void> recordLookup(String wordId) async {
    // Update in memory before the first await: the card reads the count
    // right after this call, while saving is still in progress.
    _lookupCounts.update(wordId, (count) => count + 1, ifAbsent: () => 1);
    notifyListeners();
    await _lookupRepository.saveCounts(_lookupCounts);
  }

  /// Session a tapped reminder opens now; null = nothing to do.
  SessionMode? sessionFor(ReminderKind kind) =>
      sessionForReminder(kind, dueCount: dueCount, newWordsLeft: newWordsLeft);

  /// New words: up to [newWordsPerSession] unseen words of the selected
  /// levels, pink words left from earlier sessions first. Review: all due
  /// words of the selected levels.
  void startSession(SessionMode mode) {
    _session = CardSession(
      mode: mode,
      wordIds: switch (mode) {
        SessionMode.newWords => [
          ..._unrecalledIds(),
          ..._newWordIds(),
        ].take(newWordsPerSession),
        SessionMode.review => _dueIds(),
      },
      progress: _progress,
      schedule: _reviewScheduler.answer,
      nextNewWord: (inDeck) =>
          _newWordIds().where((id) => !inDeck.contains(id)).firstOrNull,
    );
    _syncDeck();
    _lastUndone = null;
    notifyListeners();
  }

  /// The cards screen has opened: read the word on top, if the user wants that.
  void onCardsOpened() {
    _isSwiping = false;
    _speakCurrentIfAuto();
  }

  /// The card has been released and starts flying off screen.
  void onSwipeStarted() => _isSwiping = true;

  /// The card's flight was interrupted before its answer was committed.
  void onSwipeCancelled() => _isSwiping = false;

  /// The card has left the screen.
  void onCardSwiped(CardDecision decision) {
    _session!.answer(decision);
    _syncDeck();
    _lastUndone = null;
    _isSwiping = false;
    notifyListeners();
    _speakCurrentIfAuto();
    _saveProgress();
  }

  /// Takes back the last answer, including its effect on the progress.
  void undo() {
    if (!canUndo || _isSwiping) return;
    _lastUndone = _session!.undo();
    _syncDeck();
    notifyListeners();
    _saveProgress();
  }

  void speak(String text) => _speechService.speak(text);

  void _speakCurrentIfAuto() {
    if (!_settingsViewModel.autoSpeak || _isLoading || isFinished) return;
    _speechService.speak(_deck[index].withArticle, warnIfMuted: false);
  }

  Iterable<String> _newWordIds() => _words
      .where((w) => _learnLevels.contains(w.level) && !_progress.contains(w.id))
      .map((w) => w.id);

  /// Pink and due words come only from the selected levels too (user's
  /// choice): the level choice means the same everywhere. Words of other
  /// levels wait until their level is selected again.
  List<String> _unrecalledIds() => _progress.unrecalledIds(_inLearnLevels);

  List<String> _dueIds() =>
      _progress.dueIds(DateTime.now().toUtc(), _inLearnLevels);

  /// The word is in the app and its level is selected.
  bool _inLearnLevels(String wordId) =>
      _learnLevels.contains(_wordsById[wordId]?.level);

  void _syncDeck() => _deck = [
    for (final id in _session?.wordIds ?? const <String>[]) _wordsById[id]!,
  ];

  // Not awaited: the UI already shows the new state; the write runs after.
  void _saveProgress() {
    unawaited(_progressRepository.save(_progress.entries));
    _recordSnapshot();
  }

  /// Overwrites today's entry in the history with the current counts.
  void _recordSnapshot() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _statusHistory[today] = DaySnapshot(
      _progress.counts(now.toUtc()),
      reviewed: _progress.reviewedSince(today),
    );
    unawaited(_historyRepository.save(_statusHistory));
  }

  @override
  void dispose() {
    _settingsViewModel.removeListener(notifyListeners);
    _languageViewModel.removeListener(_onLanguageChanged);
    super.dispose();
  }
}
