import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/app_language.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';

Future<void> showLanguageSheet({
  required BuildContext context,
  required AppStrings strings,
  required List<AppLanguage> languages,
  required AppLanguage current,
  required ValueChanged<AppLanguage> onSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              strings.language,
              style: Theme.of(sheetContext).textTheme.titleLarge,
            ),
          ),
          // Scrolls when the list is longer than the sheet.
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final language in languages)
                  ListTile(
                    leading: Text(
                      language.flag,
                      style: const TextStyle(fontSize: 28),
                    ),
                    title: Text(language.label),
                    selected: language == current,
                    trailing: language == current
                        ? const Icon(Icons.check)
                        : null,
                    onTap: () {
                      onSelected(language);
                      Navigator.of(sheetContext).pop();
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
