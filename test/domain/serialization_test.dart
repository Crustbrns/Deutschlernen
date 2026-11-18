import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fsrs/fsrs.dart' as fsrs;
import 'package:deutschlernen/data/services/review_scheduler.dart';
import 'package:deutschlernen/domain/models/day_snapshot.dart';
import 'package:deutschlernen/domain/models/status_counts.dart';
import 'package:deutschlernen/domain/models/word_progress.dart';

/// Saved data must read back exactly as it was written: there is no backend,
/// a lost field is lost progress.
void main() {
  // Through a JSON string, as in storage.
  Map<String, dynamic> stored(Map<String, dynamic> json) =>
      jsonDecode(jsonEncode(json)) as Map<String, dynamic>;

  group('word progress', () {
    final scheduler = ReviewScheduler();
    final pink = WordProgress.learning(fsrs.Card(cardId: 1));
    final recalled = scheduler.review(pink, remembered: true);
    final forgotten = scheduler.review(recalled, remembered: false);

    for (final (name, progress) in [
      ('known', const WordProgress.known()),
      ('pink', pink),
      ('recalled once', recalled),
      ('reviewed twice', forgotten),
    ]) {
      test('$name reads back the same', () {
        final restored = WordProgress.fromJson(stored(progress.toJson()));

        expect(restored.toJson(), progress.toJson());
        expect(restored.isKnown, progress.isKnown);
        expect(restored.isUnrecalled, progress.isUnrecalled);
        expect(restored.firstRecalledAt, progress.firstRecalledAt);
        expect(restored.card?.due, progress.card?.due);
        expect(restored.card?.lastReview, progress.card?.lastReview);
        expect(restored.card?.state, progress.card?.state);
        expect(restored.card?.stability, progress.card?.stability);
      });
    }
  });

  group('day snapshot', () {
    const counts = StatusCounts(known: 1, learning: 2, review: 3, learned: 4);

    test('with the review count', () {
      final restored = DaySnapshot.fromJson(
        stored(const DaySnapshot(counts, reviewed: 5).toJson()),
      );

      expect(restored.counts.stack, counts.stack);
      expect(restored.counts.learning, 2);
      expect(restored.reviewed, 5);
    });

    test('saved before reviews were counted', () {
      final restored = DaySnapshot.fromJson(stored(counts.toJson()));

      expect(restored.counts.toJson(), counts.toJson());
      expect(restored.reviewed, isNull);
    });
  });
}
