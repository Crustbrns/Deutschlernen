import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/core/widgets/round_icon_button.dart';

class CardsTopBar extends StatelessWidget {
  const CardsTopBar({
    super.key,
    required this.progress,
    required this.onClose,
    required this.onUndo,
    required this.learnedToday,
    required this.dailyGoal,
  });

  final double progress;
  final int learnedToday; // words learned today, for the goal ring
  final int dailyGoal;
  final VoidCallback onClose;
  final VoidCallback? onUndo; // null = disabled

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Row(
      children: [
        RoundIconButton(
          icon: AppIcons.x,
          tooltip: strings.close,
          onPressed: onClose,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _ProgressBar(progress: progress),
          ),
        ),
        _GoalRing(learned: learnedToday, goal: dailyGoal),
        const SizedBox(width: 8),
        // Curved "U-turn" arrow: undo, not "go back".
        RoundIconButton(
          icon: AppIcons.arrowUUpLeft,
          tooltip: strings.back,
          onPressed: onUndo,
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 8,
        child: ColoredBox(
          color: colors.surfaceContainerHighest,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value.clamp(0.0, 1.0).toDouble(),
              child: ColoredBox(color: colors.onSurface),
            ),
          ),
        ),
      ),
    );
  }
}

/// Today's goal, "3/10": learned words (first "remember" on a pink word)
/// out of the daily goal. Looks like the round buttons next to it.
class _GoalRing extends StatelessWidget {
  const _GoalRing({required this.learned, required this.goal});

  final int learned;
  final int goal;

  @override
  Widget build(BuildContext context) {
    // A circle as tall as RoundIconButton; grows into a pill when the
    // text is wider ("10/10").
    return Container(
      height: 36,
      constraints: const BoxConstraints(minWidth: 36),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppPalette.of(context).subtleButton,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        '$learned/$goal',
        style: TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.3, // a little air: the digits stuck together
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
