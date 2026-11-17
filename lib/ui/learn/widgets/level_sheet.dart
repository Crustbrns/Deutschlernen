import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/word.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/widgets/choice_sheet.dart';
import 'package:deutschlernen/ui/core/widgets/level_row.dart';

/// Bottom sheet to pick the levels (A1–B2) to learn, several at once.
/// Every tap is applied right away, so there is no "Done" button.
/// The last selected level can't be turned off: a session needs words.
/// The rows are the level rows of the Categories tab.
Future<void> showLevelSheet({
  required BuildContext context,
  required Set<String> selected,
  required Map<String, int> wordCounts, // level → number of words
  required ValueChanged<Set<String>> onChanged,
}) {
  return showMultiChoiceSheet<String>(
    context: context,
    title: AppStrings.of(context).chooseLevels,
    choices: [for (final level in Word.levels) Choice(level, level)],
    selected: selected,
    onChanged: onChanged,
    rowBuilder: (choice, isSelected, onTap) => LevelRow(
      level: choice.value,
      wordCount: wordCounts[choice.value] ?? 0,
      trailing: SelectionMark(isSelected: isSelected),
      onTap: onTap,
    ),
  );
}
