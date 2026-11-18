import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/app_language.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/core/view_models/language_view_model.dart';
import 'package:deutschlernen/ui/core/widgets/choice_sheet.dart';
import 'package:deutschlernen/ui/core/widgets/grouped_card.dart';

/// Which of the two language choices a sheet edits.
enum LanguageChoice { interface, words }

/// Language picker: a preview card ("Привет" in the chosen language), then
/// "same as system" and the languages. A tap applies right away and the
/// sheet stays open, so the preview shows the choice; the interface
/// language also redraws the sheet's own texts. Closed by "Done" or a swipe.
Future<void> showLanguageSheet({
  required BuildContext context,
  required LanguageViewModel languages,
  required LanguageChoice choice,
}) {
  return showSheet(
    context: context,
    builder: (_) => ListenableBuilder(
      listenable: languages,
      builder: (context, _) {
        final strings = languages.strings;
        final words = choice == LanguageChoice.words;
        // null = same as the system.
        final current = words ? languages.wordChoice : languages.uiChoice;
        final shown = current ?? languages.systemLanguage;

        void select(AppLanguage? language) => words
            ? languages.setWordLanguage(language)
            : languages.setUiLanguage(language);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SheetTitle(
              words ? strings.wordsLanguage : strings.interfaceLanguage,
            ),
            _Preview(
              hello: shown.hello,
              note: words ? shown.wordsNote : shown.uiNote,
            ),
            const SizedBox(height: 16),
            GroupedCard(
              children: [
                // Gray line: which language that is right now.
                ChoiceRow(
                  choice: Choice(
                    null,
                    strings.systemLanguage,
                    subtitle: languages.systemLanguage.label,
                  ),
                  isSelected: current == null,
                  onTap: () => select(null),
                ),
                for (final language in languages.languages)
                  ChoiceRow(
                    choice: Choice(language, language.label),
                    isSelected: current == language,
                    onTap: () => select(language),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SheetDoneButton(strings.done),
          ],
        );
      },
    ),
  );
}

/// Card with a big accent-colored greeting and a gray line under it, both in
/// the chosen language; crossfades when the choice changes.
class _Preview extends StatelessWidget {
  const _Preview({required this.hello, required this.note});

  final String hello;
  final String note;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          // Both texts change together: one key for the pair.
          child: Column(
            key: ValueKey(hello),
            children: [
              Text(
                hello,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                  color: AppPalette.of(context).accentText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                note,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: palette.mutedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
