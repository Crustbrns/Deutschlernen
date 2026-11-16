import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/word.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/core/widgets/grouped_card.dart';
import 'package:deutschlernen/ui/core/widgets/level_icon.dart';

/// Bottom sheet to pick the levels (A1–B2) to learn, several at once.
/// Every tap is applied right away, so there is no "Done" button.
/// The last selected level can't be turned off: a session needs words.
Future<void> showLevelSheet({
  required BuildContext context,
  required AppStrings strings,
  required Set<String> selected,
  required Map<String, int> wordCounts, // level → number of words
  required ValueChanged<Set<String>> onChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    // Height follows the content. Without it the sheet stops at 9/16 of the
    // screen and cut off the last level row.
    isScrollControlled: true,
    // ...but never under the status bar / notch.
    useSafeArea: true,
    // Screen background, so the card-colored block stands out on it.
    backgroundColor: AppPalette.of(context).background,
    builder: (sheetContext) {
      // Local copy: the sheet redraws itself on each tap.
      var current = {...selected};

      // The sheet is a new route, outside the shell's strings scope.
      return AppStringsScope(
        strings: strings,
        child: StatefulBuilder(
          builder: (context, setSheetState) {
            final colors = Theme.of(context).colorScheme;

            void toggle(String level) {
              final next = {...current};
              if (!next.remove(level)) next.add(level);
              if (next.isEmpty) return;
              setSheetState(() => current = next);
              onChanged(next);
            }

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
                          strings.chooseLevels,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      GroupedCard(
                        children: [
                          for (final level in Word.levels)
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              // Same icons as on the Categories tab.
                              leading: LevelIcon(level),
                              title: Text(level),
                              subtitle: Text(
                                strings.wordCount(wordCounts[level] ?? 0),
                                style: TextStyle(
                                  color: AppColors.quietText(colors),
                                ),
                              ),
                              trailing: current.contains(level)
                                  ? const Icon(
                                      AppIcons.checkCircle,
                                      color: AppColors.accentBlue,
                                    )
                                  : Icon(
                                      AppIcons.circle,
                                      color: colors.onSurfaceVariant,
                                    ),
                              onTap: () => toggle(level),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}
