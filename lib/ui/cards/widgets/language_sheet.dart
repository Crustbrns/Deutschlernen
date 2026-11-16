import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/app_language.dart';
import 'package:deutschlernen/ui/core/widgets/choice_sheet.dart';

/// Language picker: "same as system" (null) first, then the languages.
/// No flags: the chosen one is marked by color.
Future<void> showLanguageSheet({
  required BuildContext context,
  required String title,
  required String systemLabel, // the sheet is outside the strings scope
  required AppLanguage systemLanguage, // what the system gives now
  required List<AppLanguage> languages,
  required AppLanguage? current, // null = same as system
  required ValueChanged<AppLanguage?> onSelected,
}) {
  return showChoiceSheet<AppLanguage?>(
    context: context,
    title: title,
    current: current,
    onSelected: onSelected,
    choices: [
      // Gray line: which language that is right now.
      Choice(null, systemLabel, subtitle: systemLanguage.label),
      for (final language in languages) Choice(language, language.label),
    ],
  );
}
