import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/word.dart';
import 'package:deutschlernen/domain/models/word_status.dart';
import 'package:deutschlernen/ui/categories/widgets/word_list.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';

Word word(int i) => Word(
  id: 'w$i',
  article: 'der',
  german: 'Hund$i',
  plural: null,
  translation: 'собака $i',
  level: 'A1',
  transcription: '',
  definition: '',
  definitionTranslation: null,
  examples: const [],
);

void main() {
  testWidgets('a long word list builds only the rows on screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: AppStringsScope(
          strings: const AppStrings({}),
          child: Scaffold(
            body: WordList(
              words: [for (var i = 0; i < 500; i++) word(i)],
              onWordSelected: (_) {},
              onSpeak: (_) {},
              stateOf: (_) => (status: WordStatus.newWord, due: null),
            ),
          ),
        ),
      ),
    );

    final built = find.byType(WordRow).evaluate().length;
    expect(built, greaterThan(0));
    expect(built, lessThan(50)); // a screenful plus the cache, not 500

    // Scrolling far down builds the rows there.
    await tester.drag(find.byType(WordList), const Offset(0, -20000));
    await tester.pumpAndSettle();
    expect(find.text('der Hund0'), findsNothing);
    expect(find.byType(WordRow).evaluate().length, lessThan(50));
  });
}
