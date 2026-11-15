import 'package:fsrs/fsrs.dart' as fsrs;
import 'package:deutschlernen/domain/models/word_progress.dart';

/// A word's status plus its next review time (null for new and known words).
typedef WordState = ({WordStatus status, DateTime? due});

/// Where a word is on its way to being learned; shown as a colored strip
/// and a caption in the word lists.
enum WordStatus {
  /// Not seen yet.
  newWord,

  /// Chosen to learn, not reviewed even once yet.
  learning,

  /// Reviewed at least once (whatever the answer), interval shorter than
  /// [matureInterval]; or any word whose review time has come.
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
    final lastReview = card.lastReview;
    if (lastReview == null) return (status: learning, due: due);
    // The gap between the last review and the due date is the interval.
    final mature =
        card.state == fsrs.State.review &&
        due.difference(lastReview) >= matureInterval &&
        !progress.isDue(now);
    return (status: mature ? learned : review, due: due);
  }
}
