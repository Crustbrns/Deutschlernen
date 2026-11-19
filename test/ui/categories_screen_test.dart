import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/word.dart';
import 'package:deutschlernen/domain/models/word_status.dart';
import 'package:deutschlernen/ui/categories/widgets/categories_screen.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/core/widgets/grouped_card.dart';

void main() {
  testWidgets('own words has its own block below levels with full-row tap', (
    tester,
  ) async {
    var openedOwnWords = 0;
    final progressChanges = ValueNotifier(0);
    addTearDown(progressChanges.dispose);

    await tester.pumpWidget(
      _categoriesApp(
        progressChanges: progressChanges,
        onOwnWordsSelected: () => openedOwnWords++,
      ),
    );

    final cards = find.byType(GroupedCard);
    expect(cards, findsNWidgets(2));
    expect(
      tester.getTopLeft(cards.at(1)).dy,
      greaterThan(tester.getTopLeft(cards.at(0)).dy),
    );
    expect(
      tester.getCenter(find.byTooltip('Add word')).dx,
      greaterThan(tester.getCenter(find.text('Own words')).dx),
    );
    expect(
      tester.getTopLeft(find.text('0\u00A0%').last).dx,
      greaterThan(tester.getCenter(find.byTooltip('Add word')).dx),
    );

    await tester.tap(find.text('0\u00A0%').last);
    expect(openedOwnWords, 1);
  });

  testWidgets('plus opens the add form and saves both fields', (tester) async {
    (String german, String translation)? savedWord;
    var openedOwnWords = 0;
    final progressChanges = ValueNotifier(0);
    addTearDown(progressChanges.dispose);

    await tester.pumpWidget(
      _categoriesApp(
        progressChanges: progressChanges,
        onOwnWordsSelected: () => openedOwnWords++,
        onAddOwnWord: (german, translation) async {
          savedWord = (german, translation);
        },
      ),
    );

    await tester.tap(find.byTooltip('Add word'));
    await tester.pumpAndSettle();
    expect(openedOwnWords, 0);

    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'German word',
      ),
      'die Möglichkeit',
    );
    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Translation',
      ),
      'possibility',
    );
    expect(
      tester
          .widget<TextField>(
            find.byWidgetPredicate(
              (widget) =>
                  widget is TextField &&
                  widget.decoration?.labelText == 'German word',
            ),
          )
          .controller
          ?.text,
      'die Möglichkeit',
    );
    expect(
      tester
          .widget<TextField>(
            find.byWidgetPredicate(
              (widget) =>
                  widget is TextField &&
                  widget.decoration?.labelText == 'Translation',
            ),
          )
          .controller
          ?.text,
      'possibility',
    );
    final addButton = find.widgetWithText(FilledButton, 'Add word');
    expect(tester.widget<FilledButton>(addButton).onPressed, isNotNull);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(savedWord, ('die Möglichkeit', 'possibility'));
  });
}

Widget _categoriesApp({
  required ValueNotifier<int> progressChanges,
  required VoidCallback onOwnWordsSelected,
  Future<void> Function(String german, String translation)? onAddOwnWord,
}) => MaterialApp(
  theme: AppTheme.dark(),
  builder: (context, navigator) => AppStringsScope(
    strings: const AppStrings({
      'tabCategories': 'Categories',
      'searchHint': 'Search words',
      'ownWords': 'Own words',
      'wordCountOther': '{n} words',
      'addWord': 'Add word',
      'germanWord': 'German word',
      'translation': 'Translation',
      'fieldRequired': 'Required',
    }),
    child: navigator!,
  ),
  home: Scaffold(
    body: CategoriesScreen(
      words: const [],
      wordsByLevel: Word.byLevel(const []),
      ownWords: const [],
      ownWordsSeenShare: 0,
      seenShare: (_) => 0,
      onOwnWordsSelected: onOwnWordsSelected,
      onAddOwnWord: onAddOwnWord ?? (_, _) async {},
      onWordSelected: (_) {},
      onSearchResultSelected: (_) {},
      onSpeak: (_) {},
      stateOf: (_) => (status: WordStatus.newWord, due: null),
      progressChanges: progressChanges,
    ),
  ),
);
