import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';
import 'package:deutschlernen/domain/models/app_language.dart';
import 'package:deutschlernen/ui/core/app_style.dart';

Future<void> showLanguageSheet({
  required BuildContext context,
  required String title,
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
              title,
              style: Theme.of(sheetContext).textTheme.titleLarge,
            ),
          ),
          // Scrolls when the list is longer than the sheet.
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final language in languages)
                  // No flags: the chosen language is marked by color only.
                  ListTile(
                    title: Text(language.label),
                    selected: language == current,
                    selectedColor: AppColors.softBlue,
                    trailing: language == current
                        ? const Icon(AppIcons.check)
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
