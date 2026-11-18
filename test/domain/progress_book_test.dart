import 'package:flutter_test/flutter_test.dart';
import 'package:fsrs/fsrs.dart' as fsrs;
import 'package:deutschlernen/data/services/review_scheduler.dart';
import 'package:deutschlernen/domain/models/progress_book.dart';
import 'package:deutschlernen/domain/models/word_progress.dart';

void main() {
  final scheduler = ReviewScheduler();
  final now = DateTime.now().toUtc();
  bool all(String _) => true;

  /// Pink word created at [cardId] µs: a lower id is older.
  WordProgress pink(int cardId) =>
      WordProgress.learning(fsrs.Card(cardId: cardId));

  test('pink words come oldest first, missing words are skipped', () {
    final book = ProgressBook({
      'late': pink(3),
      'early': pink(1),
      'gone': pink(2),
      'known': const WordProgress.known(),
    });

    expect(book.unrecalledIds((id) => id != 'gone'), ['early', 'late']);
  });

  test(
    'pink words are never due; a recalled word is due once its time comes',
    () {
      final recalled = scheduler.review(pink(1), remembered: true);
      final book = ProgressBook({'pink': pink(2), 'recalled': recalled});

      expect(book.dueIds(now, all), isEmpty);
      expect(book.dueIds(recalled.card!.due, all), ['recalled']);
    },
  );

  test('counts one word per status, new words are not counted', () {
    final book = ProgressBook({
      'k': const WordProgress.known(),
      'p': pink(1),
      'r': scheduler.review(pink(2), remembered: true),
    });

    final counts = book.counts(now);
    expect(
      (counts.known, counts.learning, counts.review, counts.learned),
      (1, 1, 1, 0),
    );
  });

  test('recalledSince counts first recalls from that moment on', () {
    final recalled = scheduler.review(pink(1), remembered: true);
    final book = ProgressBook({'a': recalled, 'b': pink(2)});

    expect(book.recalledSince(recalled.firstRecalledAt!), 1);
    expect(
      book.recalledSince(
        recalled.firstRecalledAt!.add(const Duration(seconds: 1)),
      ),
      0,
    );
  });

  test('reviewedSince counts any answered review, not pink or known', () {
    final remembered = scheduler.review(pink(1), remembered: true);
    final forgot = scheduler.review(remembered, remembered: false);
    final book = ProgressBook({
      'a': remembered,
      'b': forgot,
      'c': pink(2),
      'd': const WordProgress.known(),
    });
    final reviewedAt = remembered.card!.lastReview!;

    expect(book.reviewedSince(reviewedAt), 2);
    expect(
      book.reviewedSince(DateTime.now().add(const Duration(seconds: 1))),
      0,
    );
  });

  test('put(null) makes a word new again', () {
    final book = ProgressBook({'a': pink(1)});
    book.put('a', null);
    expect(book.contains('a'), isFalse);
    expect(book.remove('a'), isFalse);
  });
}
