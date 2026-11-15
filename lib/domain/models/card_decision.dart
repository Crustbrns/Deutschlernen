/// The user's answer on a card. Left swipe = known / forgot,
/// right swipe = learn / remembered, depending on the session.
enum CardDecision {
  // New words session.
  known, // the word is skipped for good
  learn, // the word goes into reviews
  // Review session.
  forgot,
  remembered;

  bool get isLeft => this == known || this == forgot;
}

/// Which words a cards session shows.
enum SessionMode { newWords, review }
