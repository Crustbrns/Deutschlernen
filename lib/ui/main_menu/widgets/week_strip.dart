import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';

/// The current week, Monday to Sunday, as a row of tiles; today is filled
/// pink. Days only, no dates.
class WeekStrip extends StatelessWidget {
  const WeekStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final days = AppStrings.of(context).weekdaysShort;
    // DateTime.weekday: 1 = Monday … 7 = Sunday.
    final today = DateTime.now().weekday - 1;

    return Row(
      children: [
        for (var i = 0; i < days.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: _DayTile(label: days[i], isToday: i == today),
          ),
        ],
      ],
    );
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({required this.label, required this.isToday});

  final String label;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        // Same pink as the "learn new words" icon.
        color: isToday ? AppColors.menuNewWords : AppPalette.of(context).card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        maxLines: 1,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: isToday ? AppColors.onAccent : colors.onSurface,
        ),
      ),
    );
  }
}
