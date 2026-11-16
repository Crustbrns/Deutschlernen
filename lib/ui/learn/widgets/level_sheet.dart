import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/word.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/core/widgets/choice_sheet.dart';
import 'package:deutschlernen/ui/core/widgets/grouped_card.dart';
import 'package:deutschlernen/ui/core/widgets/level_row.dart';

/// Bottom sheet to pick the levels (A1–B2) to learn, several at once.
/// Every tap is applied right away, so there is no "Done" button.
/// The last selected level can't be turned off: a session needs words.
/// Like showMultiChoiceSheet, but with the level rows of the Categories tab.
Future<void> showLevelSheet({
  required BuildContext context,
  required AppStrings strings,
  required Set<String> selected,
  required Map<String, int> wordCounts, // level → number of words
  required ValueChanged<Set<String>> onChanged,
}) {
  // Local copy: the sheet redraws itself on each tap.
  var current = {...selected};

  return showSheet(
    context: context,
    title: strings.chooseLevels,
    // The sheet is a new route, outside the shell's strings scope.
    builder: (_) => AppStringsScope(
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

          return GroupedCard(
            children: [
              for (final level in Word.levels)
                // Same row as on the Categories tab; the check like in the
                // other pickers.
                LevelRow(
                  level: level,
                  wordCount: wordCounts[level] ?? 0,
                  trailing: current.contains(level)
                      ? const Icon(
                          AppIcons.checkCircle,
                          color: AppColors.softBlue,
                        )
                      : Icon(AppIcons.circle, color: colors.onSurfaceVariant),
                  onTap: () => toggle(level),
                ),
            ],
          );
        },
      ),
    ),
  );
}
