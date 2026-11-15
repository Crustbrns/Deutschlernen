import 'package:fsrs/fsrs.dart' as fsrs;

/// What the app remembers about the user and one word.
/// A word without progress is new: the user hasn't seen it yet.
class WordProgress {
  /// "Already know": the word never comes back.
  const WordProgress.known() : card = null, firstRecalledAt = null;

  /// The word is being learned; [card] holds its FSRS schedule.
  const WordProgress.learning(fsrs.Card this.card, {this.firstRecalledAt});

  /// Null for a known word.
  final fsrs.Card? card;

  /// When the user first answered "remember" (pink → orange): the moment
  /// the word counts as learned, e.g. for "learned today". FSRS keeps only
  /// the last review, so it is stored here.
  final DateTime? firstRecalledAt;

  bool get isKnown => card == null;

  /// Chosen to learn but not yet recalled once ("pink"): it stays in the
  /// new-words sessions until the user answers "remember" on it.
  bool get isUnrecalled => card != null && card!.lastReview == null;

  /// Recalled at least once and its review time has come. Unrecalled words
  /// are never due: they belong to the new-words sessions.
  bool isDue(DateTime now) =>
      card != null && !isUnrecalled && !card!.due.isAfter(now);

  Map<String, dynamic> toJson() => card == null
      ? {'known': true}
      : {
          'card': card!.toMap(),
          if (firstRecalledAt != null)
            'firstRecalledAt': firstRecalledAt!.toIso8601String(),
        };

  factory WordProgress.fromJson(Map<String, dynamic> json) {
    final card = json['card'];
    final recalled = json['firstRecalledAt'] as String?;
    return card == null
        ? const WordProgress.known()
        : WordProgress.learning(
            fsrs.Card.fromMap(card as Map<String, dynamic>),
            firstRecalledAt: recalled == null ? null : DateTime.parse(recalled),
          );
  }
}
