import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/core/widgets/grouped_card.dart';

/// Practice tab: title, then one block with the entry points: categories
/// (which levels new words come from), new words, and review.
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({
    super.key,
    required this.selectedLevelCount,
    required this.newWordsLeft,
    required this.dueCount,
    required this.onChooseLevels,
    required this.onLearnNewWords,
    required this.onReview,
  });

  final int selectedLevelCount;
  final int newWordsLeft; // 0 = all words of the chosen levels are seen
  final int dueCount; // words waiting for review right now
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
              style: Theme.of(context).textTheme.headlineSmall,
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
                          color: AppColors.quietText(colors),
                        ),
                      )
                    : null,
                onTap: dueCount > 0 ? onReview : null,
              ),
            ],
          ),
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
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
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
      title: Text(title, style: const TextStyle(fontSize: 17)),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
