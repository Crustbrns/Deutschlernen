/// How many words were in each status at one moment: one bar of the
/// progress chart. New (unseen) words are not counted.
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

  int get total => known + learning + review + learned;

  /// Bottom to top, the order the chart stacks them in.
  List<int> get stack => [known, learning, review, learned];

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
