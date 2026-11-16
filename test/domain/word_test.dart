import 'package:flutter_test/flutter_test.dart';
import 'package:deutschlernen/domain/models/progress_book.dart';
import 'package:deutschlernen/domain/models/word.dart';
import 'package:deutschlernen/domain/models/word_progress.dart';

Word word(String id, {String level = 'A1', String? translation}) => Word(
  id: id,
  article: 'der',
  german: 'Hund',
  plural: 'Hunde',
  translation: translation ?? 't-$id',
  level: level,
  transcription: '',
  definition: '',
  definitionTranslation: null,
  examples: const [],
);

void main() {
  group('choiceOptions', () {
    final pool = ['t-a', 't-b', 't-c', 't-d', 't-e', 't-b', ''];

    test('the translation plus 3 different wrong ones', () {
      final options = word('a').choiceOptions(pool);

      expect(options, hasLength(4));
      expect(options, contains('t-a'));
      expect(options.toSet(), hasLength(4)); // no duplicates
      expect(options, isNot(contains('')));
    });

    test('same order on every call', () {
      expect(word('a').choiceOptions(pool), word('a').choiceOptions(pool));
    });

    test('a small pool gives fewer options', () {
      expect(word('a').choiceOptions(['t-a', 't-b']), hasLength(2));
    });
  });

  test('byLevel keeps the level order and empty levels', () {
    final grouped = Word.byLevel([
      word('x', level: 'B1'),
      word('y', level: 'A1'),
      word('z', level: 'B1'),
    ]);

    expect(grouped.keys, Word.levels);
    expect([for (final w in grouped['B1']!) w.id], ['x', 'z']);
    expect(grouped['A2'], isEmpty);
  });

  test('decidedShare counts words with any progress', () {
    final book = ProgressBook({'a': const WordProgress.known()});

    expect(book.decidedShare(['a', 'b', 'c', 'd']), 0.25);
    expect(book.decidedShare([]), 0);
  });
}
