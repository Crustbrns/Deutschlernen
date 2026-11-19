import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_style.dart';

/// Top row of the word card: level chip, status square and caption.
class WordCardHeader extends StatelessWidget {
  const WordCardHeader({
    super.key,
    required this.level,
    required this.status,
    required this.squareColor,
  });

  final String level;

  /// Gray text next to the level ("New word", "Повтор через 4 дн.").
  final String status;
  final Color squareColor; // status square before the text

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (level.isNotEmpty) ...[
          CardChip(level, radius: 24),
          const SizedBox(width: 10),
        ],
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: squareColor,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            status,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              // Condensed: at the default spacing the letters looked apart.
              letterSpacing: -0.5,
              color: AppPalette.of(context).mutedText,
            ),
          ),
        ),
      ],
    );
  }
}

/// Small gray plate with text: the level in the header (round) and the
/// lookup count under the translation (squarer).
class CardChip extends StatelessWidget {
  const CardChip(this.text, {super.key, required this.radius});

  final String text;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Text(text, style: const TextStyle(fontSize: 13.5)),
      ),
    );
  }
}
