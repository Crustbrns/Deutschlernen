import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';

/// Answer buttons for recalling a word (a pink word, or a review): an
/// outlined "😞 Забыл" in the card's color and a lime "🙂 Помню" (the main
/// action). While the card is dragged, "Забыл" fills up with red, as in
/// [DecisionBar], and "Помню" gets lighter.
class RecallBar extends StatelessWidget {
  const RecallBar({
    super.key,
    required this.onForgot,
    required this.onRemembered,
    required this.dragProgress,
  });

  final VoidCallback onForgot;
  final VoidCallback onRemembered;

  /// From -1 (dragged towards "forgot") to 1 (towards "remember").
  final ValueListenable<double> dragProgress;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return ValueListenableBuilder<double>(
      valueListenable: dragProgress,
      builder: (context, progress, _) => Row(
        children: [
          Expanded(
            child: _RecallButton(
              icon: AppIcons.smileySad,
              label: strings.forgot,
              color: AppColors.decisionRed,
              highlight: (-progress).clamp(0.0, 1.0),
              onPressed: onForgot,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _RecallButton(
              icon: AppIcons.smiley,
              label: strings.remembered,
              color: AppColors.lime,
              filled: true,
              highlight: progress.clamp(0.0, 1.0),
              onPressed: onRemembered,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecallButton extends StatelessWidget {
  const _RecallButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.highlight,
    required this.onPressed,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final Color color; // filled: the fill; otherwise the tint while dragged
  final double highlight; // 0..1, how far the card is dragged this way
  final VoidCallback onPressed;
  final bool filled;

  static const _maxFill = 0.5;
  static const _maxLighten = 0.3;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final card = AppPalette.of(context).card;
    // Quieter than plain white: outline and icon 40% toward the card, the
    // label 25% (it still has to read first).
    final line = filled ? AppColors.onLime : Color.lerp(onSurface, card, 0.4)!;
    final text = filled ? AppColors.onLime : Color.lerp(onSurface, card, 0.25)!;

    return Material(
      // Filled: the accent, lighter (toward white) as the card is dragged.
      // Outlined: the card's own color at rest, tinted as it is dragged.
      color: filled
          ? Color.lerp(color, AppColors.onAccent, _maxLighten * highlight)
          : Color.alphaBlend(
              color.withValues(alpha: _maxFill * highlight),
              card,
            ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: filled ? BorderSide.none : BorderSide(color: line, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: line),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  // Labels carry a line break for the two-line bar; here
                  // they fit on one line.
                  label.replaceAll('\n', ' '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                    color: text,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
