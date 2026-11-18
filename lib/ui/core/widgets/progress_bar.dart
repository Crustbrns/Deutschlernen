import 'package:material_ui/material_ui.dart';

/// Thin rounded bar filled to [progress] (0–1); slides to a new value.
class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.progress, this.color});

  final double progress;

  /// Fill; null = the text color.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 8,
        child: ColoredBox(
          color: colors.surfaceContainerHighest,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value.clamp(0.0, 1.0).toDouble(),
              child: ColoredBox(color: color ?? colors.onSurface),
            ),
          ),
        ),
      ),
    );
  }
}
