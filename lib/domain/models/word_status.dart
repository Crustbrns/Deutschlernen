import 'package:fsrs/fsrs.dart' as fsrs;
import 'package:deutschlernen/domain/models/word_progress.dart';

/// A word's status plus its next review time (null for new and known words).
typedef WordState = ({WordStatus status, DateTime? due});

/// Where a word is on its way to being learned; shown as a colored strip
/// and a caption in the word lists.
enum WordStatus {
  /// Not seen yet.
  newWord,

  /// Short FSRS steps (minutes): just started, or forgotten and relearning.
  learning,

  /// On review intervals shorter than [matureInterval], or any review word
  /// whose time has come.
  review,

  /// Interval of [matureInterval] or more and not due yet: learned well.
  learned,

  /// Marked "already know": never comes back.
  known;

  /// From this interval on a word counts as learned ("mature" in Anki).
  static const matureInterval = Duration(days: 21);

  /// [progress] null = the word is new.
  static WordState of(WordProgress? progress, DateTime now) {
    if (progress == null) return (status: newWord, due: null);
    final card = progress.card;
    if (card == null) return (status: known, due: null);
    final due = card.due;
    if (card.state != fsrs.State.review) return (status: learning, due: due);
    // Review cards always have a last review; the gap to the due date is
    // the current interval.
    final interval = due.difference(card.lastReview ?? due);
    final mature = interval >= matureInterval && !progress.isDue(now);
    return (status: mature ? learned : review, due: due);
  }
}
