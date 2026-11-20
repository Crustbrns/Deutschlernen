import 'package:flutter_test/flutter_test.dart';
import 'package:deutschlernen/domain/models/definition_mode.dart';
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

  test(
    'words without an article speak and display without a blank article',
    () {
      final own = Word(
        id: 'own-1',
        article: '',
        german: 'lernen',
        plural: null,
        translation: 'учить',
        level: '',
        transcription: '',
        definition: '',
        definitionTranslation: null,
        examples: const [],
      );

      expect(own.withArticle, 'lernen');
      expect(own.pluralWithArticle, isNull);
    },
  );

  test('decidedShare counts words with any progress', () {
    final book = ProgressBook({'a': const WordProgress.known()});

    expect(book.decidedShare(['a', 'b', 'c', 'd']), 0.25);
    expect(book.decidedShare([]), 0);
  });

  group('definitionFor', () {
    Word withDefinition({String article = 'die', String? translation}) => Word(
      id: 'x',
      article: article,
      german: 'Lage',
      plural: '',
      translation: 't',
      level: 'A1',
      transcription: '',
      definition: 'Der Zustand',
      definitionTranslation: translation,
      examples: const [],
    );

    test('translation: only the translated text, with the gender', () {
      final d = withDefinition(translation: 'Состояние')
          .definitionFor(DefinitionMode.translation);

      expect(d.shown, '(f.) Состояние');
      expect(d.revealed, isNull);
    });

    test('translation: German when there is no translation yet', () {
      final d = withDefinition().definitionFor(DefinitionMode.translation);

      expect(d.shown, '(f.) Der Zustand');
      expect(d.revealed, isNull);
    });

    test('german: only German, nothing to reveal', () {
      final d = withDefinition(translation: 'Состояние')
          .definitionFor(DefinitionMode.german);

      expect(d.shown, '(f.) Der Zustand');
      expect(d.revealed, isNull);
    });

    test('tap: German, the translation revealed without the gender', () {
      final d = withDefinition(translation: 'Состояние')
          .definitionFor(DefinitionMode.germanTapForTranslation);

      expect(d.shown, '(f.) Der Zustand');
      expect(d.revealed, 'Состояние');
    });

    test('no gender mark for words without an article', () {
      final d = withDefinition(
        article: '',
        translation: 'Состояние',
      ).definitionFor(DefinitionMode.translation);

      expect(d.shown, 'Состояние');
    });
  });
}
