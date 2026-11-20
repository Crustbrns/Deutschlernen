import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';

/// Answer bar of a new (gray) word: "Already know" on the left, "Start
/// learning" on the right. Knowing it is the good side, so the left button
/// lights up in the accent while the card is dragged that way, the right one red.
class DecisionBar extends StatelessWidget {
  const DecisionBar({
    super.key,
    required this.onKnown,
    required this.onLearn,
    required this.dragProgress,
  });

  final VoidCallback onKnown;
  final VoidCallback onLearn;

  /// From -1 (card dragged towards "known") to 1 (towards "learn").
  /// The matching button lights up in proportion.
  final ValueListenable<double> dragProgress;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return ValueListenableBuilder<double>(
      valueListenable: dragProgress,
      builder: (context, progress, _) {
        return Row(
          children: [
            Expanded(
              child: _DecisionButton(
                label: strings.known,
                icon: AppIcons.arrowLeft,
                iconFirst: true,
                highlight: (-progress).clamp(0.0, 1.0),
                highlightColor: Theme.of(context).colorScheme.primary,
                onPressed: onKnown,
              ),
            ),
            const _DoubleDivider(),
            Expanded(
              child: _DecisionButton(
                label: strings.learn,
                icon: AppIcons.arrowRight,
                iconFirst: false,
                highlight: progress.clamp(0.0, 1.0),
                highlightColor: AppColors.decisionRed,
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
  final Color highlightColor; // tint of the highlight (red / accent)
  final VoidCallback onPressed;

  // Strong enough to read as clearly red / accent at full drag.
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
