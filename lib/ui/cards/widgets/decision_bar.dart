import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';

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
                icon: Icons.arrow_back,
                iconFirst: true,
                highlight: (-progress).clamp(0.0, 1.0),
                onPressed: onKnown,
              ),
            ),
            const _DoubleDivider(),
            Expanded(
              child: _DecisionButton(
                label: strings.learn,
                icon: Icons.arrow_forward,
                iconFirst: false,
                highlight: progress.clamp(0.0, 1.0),
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
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool iconFirst; // arrow sits on the outer edge of the screen
  final double highlight; // 0..1, how far the card is dragged this way
  final VoidCallback onPressed;

  static const _maxHighlightAlpha = 0.10;
  static const _maxHighlightScale = -0.02;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final arrow = Icon(icon, size: 32);
    // Expanded lets the text take the free space and wrap into two lines.
    final text = Expanded(
      child: Text(
        label,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
      ),
    );

    return Transform.scale(
      scale: 1 + _maxHighlightScale * highlight,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: colors.onSurface,
          backgroundColor: colors.onSurface.withValues(
            alpha: _maxHighlightAlpha * highlight,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    final line = Container(width: 2, height: 36, color: color);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [line, const SizedBox(width: 5), line],
      ),
    );
  }
}
