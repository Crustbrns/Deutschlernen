import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/core/widgets/grouped_card.dart';
import 'package:deutschlernen/ui/core/widgets/menu_row.dart';

/// One option of [showChoiceSheet].
class Choice<T> {
  const Choice(this.value, this.label, {this.subtitle});

  final T value;
  final String label;
  final String? subtitle; // gray line under the label
}

/// Bottom sheet to pick one of [choices], built like the level sheet: title,
/// then one GroupedCard on the screen background. The chosen one is blue
/// with a check; a tap picks and closes. Used for the language and theme.
Future<void> showChoiceSheet<T>({
  required BuildContext context,
  required String title,
  required List<Choice<T>> choices,
  required T current,
  required ValueChanged<T> onSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    // Height follows the content, but never under the status bar.
    isScrollControlled: true,
    useSafeArea: true,
    // Screen background, so the card-colored block stands out on it.
    backgroundColor: AppPalette.of(context).background,
    builder: (sheetContext) {
      final colors = Theme.of(sheetContext).colorScheme;

      return SafeArea(
        // Scrolls instead of clipping on short screens.
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                  child: Text(
                    title,
                    style: Theme.of(sheetContext).textTheme.titleLarge,
                  ),
                ),
                GroupedCard(
                  children: [
                    for (final choice in choices)
                      MenuRow(
                        compact: true,
                        title: choice.label,
                        subtitle: choice.subtitle,
                        titleColor: choice.value == current
                            ? AppColors.softBlue
                            : null,
                        trailing: choice.value == current
                            ? const Icon(
                                AppIcons.checkCircle,
                                color: AppColors.softBlue,
                              )
                            : Icon(
                                AppIcons.circle,
                                color: colors.onSurfaceVariant,
                              ),
                        onTap: () {
                          onSelected(choice.value);
                          Navigator.of(sheetContext).pop();
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
