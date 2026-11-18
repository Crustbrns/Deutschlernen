import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/core/widgets/menu_row.dart';
import 'package:deutschlernen/ui/core/widgets/progress_bar.dart';
import 'package:deutschlernen/ui/progress/widgets/streak_card.dart';

/// The word goal on the Progress tab: "12 из 100 слов" with the "Цель"
/// label on the right, and a green bar filled to [known] / [goal].
class GoalCard extends StatelessWidget {
  const GoalCard({super.key, required this.known, required this.goal});

  /// Words known now: green or "already know".
  final int known;

  /// From Settings, 50 or more.
  final int goal;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    // Same block as the streak card above it.
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.of(context).card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  strings.wordGoalProgress(known, goal),
                  style: StreakCard.titleStyle(context),
                ),
              ),
              Text(
                strings.wordGoal,
                style: MenuRow.hintStyle(context, soft: true),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // int / int is a double in Dart; past the goal the bar stays full.
          ProgressBar(progress: known / goal, color: AppColors.statusLearned),
        ],
      ),
    );
  }
}
