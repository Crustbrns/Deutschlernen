import 'package:fsrs/fsrs.dart' as fsrs;

/// What the app remembers about the user and one word.
/// A word without progress is new: the user hasn't seen it yet.
class WordProgress {
  /// "Already know": the word never comes back.
  const WordProgress.known() : card = null;

  /// The word is being learned; [card] holds its FSRS schedule.
  const WordProgress.learning(fsrs.Card this.card);

  /// Null for a known word.
  final fsrs.Card? card;

  bool get isKnown => card == null;

  /// Learning and its review time has come.
  bool isDue(DateTime now) => card != null && !card!.due.isAfter(now);

  Map<String, dynamic> toJson() =>
      card == null ? {'known': true} : {'card': card!.toMap()};

  factory WordProgress.fromJson(Map<String, dynamic> json) {
    final card = json['card'];
    return card == null
        ? const WordProgress.known()
        : WordProgress.learning(
            fsrs.Card.fromMap(card as Map<String, dynamic>),
          );
  }
}
