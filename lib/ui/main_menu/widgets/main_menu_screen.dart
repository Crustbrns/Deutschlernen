import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/core/widgets/grouped_card.dart';
import 'package:deutschlernen/ui/core/widgets/menu_row.dart';
import 'package:deutschlernen/ui/main_menu/widgets/week_strip.dart';

/// Learn tab (was "Practice"): title, then one block with the entry
/// points: categories (which levels new words come from), new words, and
/// review; under it the current week.
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({
    super.key,
    required this.selectedLevelCount,
    required this.newWordsLeft,
    required this.dueCount,
    required this.learnedToday,
    required this.dailyGoal,
    required this.onChooseLevels,
    required this.onLearnNewWords,
    required this.onReview,
  });

  final int selectedLevelCount;
  final int newWordsLeft; // 0 = all words of the chosen levels are seen
  final int dueCount; // words waiting for review right now
  final int learnedToday;
  final int dailyGoal;
  final VoidCallback onChooseLevels;
  final VoidCallback onLearnNewWords;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return SafeArea(
      bottom: false,
      child: ListView(
        // + bottom inset: the block stays above the blurred bar.
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          // Same title placement as the vocabulary and settings tabs.
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
            child: Text(
              strings.tabMain,
              // Condensed: at the default spacing the letters drift apart.
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(letterSpacing: -0.5),
            ),
          ),
          GroupedCard(
            children: [
              MenuRow(
                icon: AppIcons.squaresFour,
                iconColor: AppColors.menuCategories,
                title: strings.levelsSelected(selectedLevelCount),
                onTap: onChooseLevels,
              ),
              MenuRow(
                icon: AppIcons.plusCircle,
                iconColor: AppColors.menuNewWords,
                title: strings.learnNewWords,
                subtitle: strings.learnedToday(learnedToday, dailyGoal),
                // Disabled when the chosen levels have no unseen words.
                onTap: newWordsLeft > 0 ? onLearnNewWords : null,
              ),
              MenuRow(
                icon: AppIcons.clockCounterClockwise,
                iconColor: AppColors.menuRepeat,
                title: strings.repeatWords,
                // "5 слов" waiting; disabled when there is nothing to review.
                trailing: dueCount > 0
                    ? Text(
                        strings.wordCount(dueCount),
                        style: MenuRow.hintStyle(context),
                      )
                    : null,
                onTap: dueCount > 0 ? onReview : null,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const WeekStrip(),
        ],
      ),
    );
  }
}
