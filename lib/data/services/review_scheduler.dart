import 'package:fsrs/fsrs.dart' as fsrs;
import 'package:deutschlernen/domain/models/card_decision.dart';
import 'package:deutschlernen/domain/models/word_progress.dart';

/// Decides when a word comes back, using FSRS (the algorithm Anki uses).
/// The app has two answers instead of FSRS's four: "don't remember" maps to
/// Again, "remember" to Good.
class ReviewScheduler {
  // Defaults: 90% target recall, learning steps 1 min and 10 min.
  final _scheduler = fsrs.Scheduler();

  /// A word the user chose to learn. Due right away, so it shows up in the
  /// review queue as soon as the new-words session is over.
  WordProgress startLearning() => WordProgress.learning(
    fsrs.Card(cardId: DateTime.now().microsecondsSinceEpoch),
  );

  /// The word's progress after the user's answer on its card.
  /// [before] is null only for a new word ("already know" / "learn").
  WordProgress answer(WordProgress? before, CardDecision decision) =>
      switch (decision) {
        CardDecision.known => const WordProgress.known(),
        CardDecision.learn => startLearning(),
        // A pink word stays pink: FSRS starts only with the first "remember".
        CardDecision.forgot when before!.isUnrecalled => before,
        CardDecision.forgot => review(before!, remembered: false),
        CardDecision.remembered => review(before!, remembered: true),
      };

  /// The user answered a review card.
  WordProgress review(WordProgress progress, {required bool remembered}) {
    final current = progress.card;
    if (current == null) return progress; // known words aren't reviewed
    final (:card, reviewLog: _) = _scheduler.reviewCard(
      current,
      remembered ? fsrs.Rating.good : fsrs.Rating.again,
    );
    return WordProgress.learning(
      card,
      // Kept once set; set on the first "remember" of a pink word.
      firstRecalledAt:
          progress.firstRecalledAt ??
          (remembered && progress.isUnrecalled ? DateTime.now() : null),
    );
  }
}
