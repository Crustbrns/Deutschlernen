import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';

class DecisionBar extends StatelessWidget {
  const DecisionBar({
    super.key,
    required this.onLater,
    required this.onRemembered,
    required this.dragProgress,
  });

  final VoidCallback onLater;
  final VoidCallback onRemembered;

  /// From -1 (card dragged towards "later") to 1 (towards "remembered").
  /// The matching button lights up in proportion.
  final ValueListenable<double> dragProgress;

  static const _maxHighlightAlpha = 0.10;
  static const _maxHighlightScale = -0.02;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final strings = AppStrings.of(context);
    const textStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.w700);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );

    return ValueListenableBuilder<double>(
      valueListenable: dragProgress,
      builder: (context, progress, _) {
        final laterAmount = (-progress).clamp(0.0, 1.0);
        final rememberedAmount = progress.clamp(0.0, 1.0);

        return Row(
          children: [
            Expanded(
              child: Transform.scale(
                scale: 1 + _maxHighlightScale * laterAmount,
                child: TextButton(
                  onPressed: onLater,
                  style: TextButton.styleFrom(
                    foregroundColor: colors.onSurface,
                    backgroundColor: colors.onSurface.withValues(
                      alpha: _maxHighlightAlpha * laterAmount,
                    ),
                    shape: shape,
                    minimumSize: const Size.fromHeight(56),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.arrow_back),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          strings.later,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textStyle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(width: 1, height: 32, color: colors.outlineVariant),
            Expanded(
              child: Transform.scale(
                scale: 1 + _maxHighlightScale * rememberedAmount,
                child: TextButton(
                  onPressed: onRemembered,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.accentTeal,
                    backgroundColor: AppColors.accentTeal.withValues(
                      alpha: _maxHighlightAlpha * rememberedAmount,
                    ),
                    shape: shape,
                    minimumSize: const Size.fromHeight(56),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          strings.remembered,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textStyle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}