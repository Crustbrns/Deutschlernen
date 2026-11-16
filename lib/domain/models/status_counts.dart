/// How many words were in each status at one moment: one bar of the
/// progress chart. New (unseen) words are not counted. The four counts don't
/// overlap (a word has one status); the chart layers in [stack] do.
class StatusCounts {
  const StatusCounts({
    this.known = 0,
    this.learning = 0,
    this.review = 0,
    this.learned = 0,
  });

  final int known; // "already know"
  final int learning; // pink: chosen, never recalled
  final int review; // yellow
  final int learned; // green

  /// Words with any status (each counted once).
  int get total => known + learning + review + learned;

  /// Taken to learn, whatever happened since: pink, yellow and green.
  int get started => learning + review + learned;

  /// Recalled at least once (unique words): yellow and green.
  int get reviewed => review + learned;

  /// Chart layers, bottom to top: known, started, reviewed, learned. A funnel
  /// (user's choice): a reviewed word also counts as started, a learned one
  /// as started and reviewed, so the bar is taller than [total].
  List<int> get stack => [known, started, reviewed, learned];

  /// Height of the stacked bar, in words.
  int get stackTotal => known + started + reviewed + learned;

  Map<String, dynamic> toJson() => {
    'known': known,
    'learning': learning,
    'review': review,
    'learned': learned,
  };

  factory StatusCounts.fromJson(Map<String, dynamic> json) => StatusCounts(
    known: json['known'] as int? ?? 0,
    learning: json['learning'] as int? ?? 0,
    review: json['review'] as int? ?? 0,
    learned: json['learned'] as int? ?? 0,
  );
}
