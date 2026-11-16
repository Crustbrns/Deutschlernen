import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';
import 'package:deutschlernen/ui/core/app_style.dart';

/// Answer buttons for recalling a word (a pink word, or a review): two
/// separate outlined buttons in the card's color, "😞 Забыл" and
/// "🙂 Помню". While the card is dragged, the matching button fills up with
/// its color (red / green), as in [DecisionBar].
class RecallBar extends StatelessWidget {
  const RecallBar({
    super.key,
    required this.forgotLabel,
    required this.rememberedLabel,
    required this.onForgot,
    required this.onRemembered,
    required this.dragProgress,
  });

  final String forgotLabel;
  final String rememberedLabel;
  final VoidCallback onForgot;
  final VoidCallback onRemembered;

  /// From -1 (dragged towards "forgot") to 1 (towards "remember").
  final ValueListenable<double> dragProgress;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: dragProgress,
      builder: (context, progress, _) => Row(
        children: [
          Expanded(
            child: _RecallButton(
              icon: AppIcons.smileySad,
              label: forgotLabel,
              color: AppColors.decisionRed,
              highlight: (-progress).clamp(0.0, 1.0),
              onPressed: onForgot,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _RecallButton(
              icon: AppIcons.smiley,
              label: rememberedLabel,
              color: AppColors.decisionGreen,
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
  });

  final IconData icon;
  final String label;
  final Color color; // fill tint while dragged (red / green)
  final double highlight; // 0..1, how far the card is dragged this way
  final VoidCallback onPressed;

  static const _maxFill = 0.5;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final card = AppPalette.of(context).card;
    // Quieter than plain white: outline and icon 40% toward the card, the
    // label 25% (it still has to read first).
    final line = Color.lerp(onSurface, card, 0.4)!;
    final text = Color.lerp(onSurface, card, 0.25)!;

    return Material(
      // The card's own color at rest; tinted as the card is dragged.
      color: Color.alphaBlend(
        color.withValues(alpha: _maxFill * highlight),
        card,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: line, width: 1.5),
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
