import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';
import 'package:deutschlernen/ui/core/app_style.dart';

class DecisionBar extends StatelessWidget {
  const DecisionBar({
    super.key,
    required this.leftLabel,
    required this.rightLabel,
    required this.leftColor,
    required this.rightColor,
    required this.onKnown,
    required this.onLearn,
    required this.dragProgress,
  });

  /// "Already know" / "Start learning", or "Don't remember" / "Remember"
  /// in a review session.
  final String leftLabel;
  final String rightLabel;

  /// Highlight while the card is dragged that way: green for the "good"
  /// side ("already know", "remember"), red for the other.
  final Color leftColor;
  final Color rightColor;

  final VoidCallback onKnown;
  final VoidCallback onLearn;

  /// From -1 (card dragged towards "known") to 1 (towards "learn").
  /// The matching button lights up in proportion.
  final ValueListenable<double> dragProgress;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: dragProgress,
      builder: (context, progress, _) {
        return Row(
          children: [
            Expanded(
              child: _DecisionButton(
                label: leftLabel,
                icon: AppIcons.arrowLeft,
                iconFirst: true,
                highlight: (-progress).clamp(0.0, 1.0),
                highlightColor: leftColor,
                onPressed: onKnown,
              ),
            ),
            const _DoubleDivider(),
            Expanded(
              child: _DecisionButton(
                label: rightLabel,
                icon: AppIcons.arrowRight,
                iconFirst: false,
                highlight: progress.clamp(0.0, 1.0),
                highlightColor: rightColor,
                onPressed: onLearn,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DecisionButton extends StatelessWidget {
  const _DecisionButton({
    required this.label,
    required this.icon,
    required this.iconFirst,
    required this.highlight,
    required this.highlightColor,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool iconFirst; // arrow sits on the outer edge of the screen
  final double highlight; // 0..1, how far the card is dragged this way
  final Color highlightColor; // tint of the highlight (red / green)
  final VoidCallback onPressed;

  // Strong enough to read as clearly red / green at full drag.
  static const _maxHighlightAlpha = 0.45;
  static const _maxHighlightScale = -0.02;

  @override
  Widget build(BuildContext context) {
    final arrow = Icon(icon, size: 24);
    // Expanded lets the text take the free space and wrap into two lines.
    final text = Expanded(
      child: Text(
        label,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          height: 1.05, // two-line labels stay compact
          letterSpacing: -0.4,
        ),
      ),
    );

    return Transform.scale(
      scale: 1 + _maxHighlightScale * highlight,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          // Text and arrows in the main text color (white in the dark theme).
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          backgroundColor: highlightColor.withValues(
            alpha: _maxHighlightAlpha * highlight,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          minimumSize: const Size.fromHeight(64),
        ),
        child: Row(
          children: iconFirst
              ? [arrow, const SizedBox(width: 8), text]
              : [text, const SizedBox(width: 8), arrow],
        ),
      ),
    );
  }
}

/// The "||" separator between the two buttons.
class _DoubleDivider extends StatelessWidget {
  const _DoubleDivider();

  @override
  Widget build(BuildContext context) {
    // Main text color, like the button labels (white in the dark theme).
    final color = Theme.of(context).colorScheme.onSurface;
    final line = Container(
      width: 1.4,
      height: 27.5,
      color: color,
    ); // 36 -15% -10%

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [line, const SizedBox(width: 3), line],
      ),
    );
  }
}

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
