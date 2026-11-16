import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';

/// How the user checks that they know the word.
enum AnswerMode { show, write, choice }

/// The three mode buttons, shown right above the examples.
/// The first one is the eye: it is both the mode and the action (it reveals
/// the translation), so there is no separate "show" switch.
class AnswerModeBar extends StatelessWidget {
  const AnswerModeBar({
    super.key,
    required this.selected,
    required this.onPressed,
  });

  /// null = nothing is open yet.
  final AnswerMode? selected;
  final ValueChanged<AnswerMode> onPressed;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Row(
      children: [
        Expanded(
          child: _ModeButton(
            icon: AppIcons.eye,
            label: strings.modeShow,
            isSelected: selected == AnswerMode.show,
            onPressed: () => onPressed(AnswerMode.show),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ModeButton(
            icon: AppIcons.pencilSimple,
            label: strings.modeWrite,
            isSelected: selected == AnswerMode.write,
            onPressed: () => onPressed(AnswerMode.write),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ModeButton(
            icon: AppIcons.listChecks,
            label: strings.modeChoice,
            isSelected: selected == AnswerMode.choice,
            onPressed: () => onPressed(AnswerMode.choice),
          ),
        ),
      ],
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = isSelected ? AppColors.accentBlue : colors.onSurfaceVariant;

    return Material(
      color: isSelected
          ? AppColors.accentBlue.withValues(alpha: 0.14)
          : AppPalette.of(context).subtleButton,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isSelected
              ? AppColors.accentBlue
              : colors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
