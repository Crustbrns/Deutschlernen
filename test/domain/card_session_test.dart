import 'dart:math' show Random;

import 'package:flutter_test/flutter_test.dart';
import 'package:deutschlernen/data/services/review_scheduler.dart';
import 'package:deutschlernen/domain/models/card_decision.dart';
import 'package:deutschlernen/domain/models/card_session.dart';
import 'package:deutschlernen/domain/models/progress_book.dart';
import 'package:deutschlernen/domain/models/word_progress.dart';

void main() {
  final scheduler = ReviewScheduler();

  CardSession session(
    SessionMode mode,
    List<String> ids, {
    ProgressBook? progress,
    List<String> spare = const [],
  }) => CardSession(
    mode: mode,
    wordIds: ids,
    progress: progress ?? ProgressBook(),
    schedule: scheduler.answer,
    nextNewWord: (inDeck) =>
        spare.where((id) => !inDeck.contains(id)).firstOrNull,
    random: Random(1), // fixed, so the insert position is repeatable
  );

  /// A word recalled once: it can be reviewed.
  WordProgress reviewed() =>
      scheduler.review(scheduler.startLearning(), remembered: true);

  group('new words', () {
    test('"learn" shows the word again 6–11 cards later', () {
      final ids = [for (var i = 0; i < 20; i++) 'w$i'];
      final s = session(SessionMode.newWords, ids);

      s.answer(CardDecision.learn);

      expect(s.index, 1);
      expect(s.wordIds.length, 21);
      final again = s.wordIds.lastIndexOf('w0');
      expect(again, inInclusiveRange(6, 11));
      expect(s.progress['w0']!.isUnrecalled, isTrue);
    });

    test('"learn" near the end puts the word last', () {
      final s = session(SessionMode.newWords, ['a', 'b']);
      s.answer(CardDecision.learn);
      expect(s.wordIds, ['a', 'b', 'a']);
    });

    test('undo takes the repeat out and makes the word new again', () {
      final s = session(SessionMode.newWords, ['a', 'b']);
      s.answer(CardDecision.learn);

      expect(s.undo(), CardDecision.learn);

      expect(s.wordIds, ['a', 'b']);
      expect(s.index, 0);
      expect(s.progress['a'], isNull);
    });

    test('"already know" brings in the next new word', () {
      final s = session(SessionMode.newWords, ['a', 'b'], spare: ['b', 'c']);

      s.answer(CardDecision.known);

      expect(s.wordIds, ['a', 'b', 'c']); // b is in the deck already
      expect(s.progress['a']!.isKnown, isTrue);

      s.undo();
      expect(s.wordIds, ['a', 'b']);
    });

    test('"already know" with no new words left adds nothing', () {
      final s = session(SessionMode.newWords, ['a']);
      s.answer(CardDecision.known);
      expect(s.wordIds, ['a']);
      expect(s.isFinished, isTrue);
    });

    test('"don\'t remember" keeps a pink word pink and shows it again', () {
      final pink = scheduler.startLearning();
      final s = session(SessionMode.newWords, [
        'a',
        'b',
      ], progress: ProgressBook({'a': pink}));
      expect(s.needsRecall('a'), isTrue);
      expect(s.needsRecall('b'), isFalse);

      s.answer(CardDecision.forgot);

      expect(s.progress['a'], same(pink));
      expect(s.wordIds, ['a', 'b', 'a']);
    });

    test('"remember" on a pink word marks it recalled', () {
      final s = session(SessionMode.newWords, [
        'a',
      ], progress: ProgressBook({'a': scheduler.startLearning()}));

      s.answer(CardDecision.remembered);

      expect(s.progress['a']!.isUnrecalled, isFalse);
      expect(s.progress['a']!.firstRecalledAt, isNotNull);
      expect(s.wordIds, ['a']); // not shown again
    });
  });

  group('review', () {
    test('every word needs recall, answers move the share', () {
      final s = session(SessionMode.review, [
        'a',
        'b',
      ], progress: ProgressBook({'a': reviewed(), 'b': reviewed()}));
      expect(s.needsRecall('a'), isTrue);
      expect(s.answeredShare, 0);

      s.answer(CardDecision.remembered);
      expect(s.answeredShare, 0.5);

      s.answer(CardDecision.forgot);
      expect(s.answeredShare, 1);
      expect(s.isFinished, isTrue);
    });

    test('undo restores the progress before the answer', () {
      final before = reviewed();
      final s = session(SessionMode.review, [
        'a',
      ], progress: ProgressBook({'a': before}));

      s.answer(CardDecision.forgot);
      expect(s.progress['a'], isNot(same(before)));

      s.undo();
      expect(s.progress['a'], same(before));
      expect(s.undo(), isNull); // nothing left to undo
    });
  });
}
