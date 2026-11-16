import 'dart:math' show Random;

import 'package:deutschlernen/domain/models/card_decision.dart';
import 'package:deutschlernen/domain/models/progress_book.dart';
import 'package:deutschlernen/domain/models/word_progress.dart';

/// One cards session: the order of the words, the answers given and undo.
/// Answers write straight into [progress]; saving is the caller's job.
/// Plain Dart, so the rules below can be tested without the UI.
class CardSession {
  CardSession({
    required this.mode,
    required Iterable<String> wordIds,
    required this.progress,
    required this.schedule,
    required this.nextNewWord,
    Random? random,
  }) : _ids = wordIds.toList(),
       _random = random ?? Random() {
    _size = _ids.length;
  }

  final SessionMode mode;
  final ProgressBook progress;

  /// The word's progress after an answer (ReviewScheduler.answer).
  final WordProgress Function(WordProgress? before, CardDecision decision)
  schedule;

  /// A new word not in [inDeck] yet, to replace an "already know" one;
  /// null when none is left.
  final String? Function(Set<String> inDeck) nextNewWord;

  final Random _random;
  final List<String> _ids;
  final List<_Step> _steps = [];

  /// Words the session started with; repeats inserted later aren't added.
  late final int _size;

  /// Word ids in the order they are shown, including the ones added later.
  List<String> get wordIds => List.unmodifiable(_ids);

  /// Index of the current card = number of answers so far.
  int get index => _steps.length;
  bool get isFinished => index >= _ids.length;
  bool get canUndo => _steps.isNotEmpty;
  String get currentId => _ids[index];

  /// A word is answered with "forgot / remember" (pink word, or any word in
  /// a review) rather than "already know / learn" (new word).
  bool needsRecall(String wordId) =>
      mode == SessionMode.review || (progress[wordId]?.isUnrecalled ?? false);

  /// Review session: share of its words answered for good. A card that comes
  /// back later doesn't count, and an "already know" word is swapped for
  /// the next new word, so the total stays; only when no new word was left
  /// to bring in does the total shrink.
  double get answeredShare {
    final unreplaced = _steps
        .where((s) => s.decision == CardDecision.known && s.insertedAt == null)
        .length;
    final done = _steps
        .where((s) => s.decision != CardDecision.known && s.insertedAt == null)
        .length;
    final total = _size - unreplaced;
    return total <= 0 ? 0 : done / total;
  }

  /// Answers the current card and moves to the next one.
  void answer(CardDecision decision) {
    final id = currentId;
    final before = progress[id];
    final unrecalled = before?.isUnrecalled ?? false;
    progress.put(id, schedule(before, decision));
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
    _steps.add(_Step(decision, id, before, insertedAt));
  }

  /// Takes back the last answer, including its effect on the progress.
  /// Returns that answer, or null if there was none.
  CardDecision? undo() {
    if (!canUndo) return null;
    final step = _steps.removeLast();
    if (step.insertedAt case final at?) _ids.removeAt(at);
    progress.put(step.wordId, step.before);
    return step.decision;
  }

  /// Puts [id] 5–10 cards after the current one (or at the end, if fewer
  /// are left). Returns its position, so undo can take it out again.
  int _insertLater(String id) {
    final at = (index + 1 + 5 + _random.nextInt(6)).clamp(0, _ids.length);
    _ids.insert(at, id);
    return at;
  }

  /// "Already know" in a new-words session: the next new word goes to the
  /// end, so the session still has as many words to learn. Returns its
  /// position, or null when there is no new word left.
  int? _appendReplacement() {
    if (mode != SessionMode.newWords) return null;
    final next = nextNewWord(_ids.toSet());
    if (next == null) return null;
    _ids.add(next);
    return _ids.length - 1;
  }
}

/// One answer, with the word's progress before it (null = it was new), so
/// undo can restore it.
class _Step {
  const _Step(this.decision, this.wordId, this.before, this.insertedAt);

  final CardDecision decision;
  final String wordId;
  final WordProgress? before;

  /// Where a card was added later in the deck: the same word again, or a
  /// replacement after "already know" (null = nothing was added).
  final int? insertedAt;
}
