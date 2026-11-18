import 'package:deutschlernen/domain/models/status_counts.dart';

/// One day of the progress history: the status counts at the end of the day
/// and how many words were reviewed during it.
class DaySnapshot {
  const DaySnapshot(this.counts, {this.reviewed});

  final StatusCounts counts;

  /// Words reviewed that day, old ones too (each word once). Null for days
  /// saved before this was counted.
  final int? reviewed;

  Map<String, dynamic> toJson() => {
    ...counts.toJson(),
    if (reviewed != null) 'reviewed': reviewed,
  };

  factory DaySnapshot.fromJson(Map<String, dynamic> json) => DaySnapshot(
    StatusCounts.fromJson(json),
    reviewed: json['reviewed'] as int?,
  );
}
