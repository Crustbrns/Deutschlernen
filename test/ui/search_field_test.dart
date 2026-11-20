import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/app_settings.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/core/widgets/search_field.dart';

void main() {
  late List<String> sent;

  Future<void> pumpField(WidgetTester tester) async {
    sent = [];
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(AccentColor.blue),
        home: AppStringsScope(
          strings: const AppStrings({}),
          child: Scaffold(
            body: SearchField(hint: 'Search', onSearch: sent.add),
          ),
        ),
      ),
    );
  }

  testWidgets('searches only after typing pauses', (tester) async {
    await pumpField(tester);

    await tester.enterText(find.byType(TextField), 'ha');
    await tester.pump(const Duration(milliseconds: 200));
    await tester.enterText(find.byType(TextField), 'haus');
    await tester.pump(const Duration(milliseconds: 200));
    expect(sent, isEmpty); // still typing

    await tester.pump(SearchField.pause);
    expect(sent, ['haus']); // one search, with the last text
  });

  testWidgets('the search key searches right away, once', (tester) async {
    await pumpField(tester);

    await tester.enterText(find.byType(TextField), ' hund ');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    expect(sent, ['hund']);

    await tester.pump(SearchField.pause);
    expect(sent, ['hund']); // the pending pause doesn't send it again
  });

  testWidgets('the close button clears the search right away', (tester) async {
    await pumpField(tester);

    await tester.enterText(find.byType(TextField), 'hund');
    await tester.pump(SearchField.pause);
    await tester.pumpAndSettle(); // the close button slides in
    await tester.tap(find.byTooltip('close'));
    expect(sent, ['hund', '']);
  });
}
