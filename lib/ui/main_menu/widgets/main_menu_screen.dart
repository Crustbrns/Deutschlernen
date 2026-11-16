import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/core/widgets/grouped_card.dart';
import 'package:deutschlernen/ui/main_menu/widgets/week_strip.dart';

/// Practice tab: title, then one block with the entry points: categories
/// (which levels new words come from), new words, and review; under it
/// the current week.
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
    final colors = Theme.of(context).colorScheme;

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
              _MenuRow(
                icon: AppIcons.squaresFour,
                iconColor: AppColors.menuCategories,
                title: strings.levelsSelected(selectedLevelCount),
                onTap: onChooseLevels,
              ),
              _MenuRow(
                icon: AppIcons.plusCircle,
                iconColor: AppColors.menuNewWords,
                title: strings.learnNewWords,
                subtitle: strings.learnedToday(learnedToday, dailyGoal),
                // Disabled when the chosen levels have no unseen words.
                onTap: newWordsLeft > 0 ? onLearnNewWords : null,
              ),
              _MenuRow(
                icon: AppIcons.clockCounterClockwise,
                iconColor: AppColors.menuRepeat,
                title: strings.repeatWords,
                // "5 слов" waiting; disabled when there is nothing to review.
                trailing: dueCount > 0
                    ? Text(
                        strings.wordCount(dueCount),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                          color: AppColors.quietText(colors),
                        ),
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

/// Colored icon + one line of text. Without [onTap] the row is disabled:
/// grayed out and not tappable.
class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle; // gray line under the title
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return ListTile(
      // 16 = divider indent of the GroupedCard.
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      // Bigger than a settings row: these are the tab's main actions.
      minVerticalPadding: 14,
      enabled: enabled,
      leading: Icon(
        icon,
        size: 26,
        // Disabled ListTile grays only its text; fade the colored icon too.
        color: enabled ? iconColor : iconColor.withValues(alpha: 0.4),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
                color: AppColors.quietText(Theme.of(context).colorScheme),
              ),
            ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
