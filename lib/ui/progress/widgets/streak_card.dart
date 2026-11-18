import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/study_streak.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/core/widgets/menu_row.dart';

/// The daily streak on the Progress tab: flame, "5 дней подряд", the record,
/// and this week's days with the studied ones filled. The flame is gray
/// until the user studies today.
class StreakCard extends StatelessWidget {
  const StreakCard({super.key, required this.streak});

  final StudyStreak streak;

  /// "5 дней подряд"; the goal card's "12 из 100 слов" looks the same.
  static TextStyle titleStyle(BuildContext context) => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: Theme.of(context).colorScheme.onSurface,
  );

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final palette = AppPalette.of(context);
    final days = strings.weekdaysShort;
    final week = streak.week;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.fireFill,
                size: 28,
                color: streak.studiedToday
                    ? AppColors.streak
                    : palette.mutedText,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  strings.streakDays(streak.current),
                  style: titleStyle(context),
                ),
              ),
              Text(
                strings.streakBest(streak.best),
                style: MenuRow.hintStyle(context, soft: true),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < week.length; i++)
                Expanded(
                  child: _Day(
                    label: days[i],
                    studied: week[i],
                    isToday: i == streak.todayIndex,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Weekday name over a circle: orange if studied; today's empty circle has
/// an orange ring.
class _Day extends StatelessWidget {
  const _Day({
    required this.label,
    required this.studied,
    required this.isToday,
  });

  final String label;
  final bool studied;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final palette = AppPalette.of(context);

    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
            color: isToday ? colors.onSurface : palette.mutedText,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: studied ? AppColors.streak : palette.subtleButton,
            shape: BoxShape.circle,
            border: isToday && !studied
                ? Border.all(color: AppColors.streak, width: 1.5)
                : null,
          ),
        ),
      ],
    );
  }
}
