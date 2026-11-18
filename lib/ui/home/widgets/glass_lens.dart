import 'package:material_ui/material_ui.dart';

/// Glass lens over the bottom bar's tabs. RawMagnifier enlarges the tabs,
/// while a theme-aware translucent surface gives it a subtle glass edge.
class GlassLens extends StatelessWidget {
  const GlassLens({super.key, required this.size, required this.lift});

  final Size size;

  /// 0 = resting (invisible), 1 = fully lifted.
  final double lift;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final height = size.height;

    return IgnorePointer(
      child: Stack(
        children: [
          RawMagnifier(
            size: size,
            magnificationScale: 1 + 0.12 * lift,
            decoration: MagnifierDecoration(
              shape: const StadiumBorder(),
              shadows: [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.2 * lift),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.onSurface.withValues(alpha: 0.06 * lift),
              border: Border.all(
                color: colors.onSurface.withValues(alpha: 0.1 * lift),
              ),
              borderRadius: BorderRadius.circular(height / 2),
            ),
            child: SizedBox.fromSize(size: size),
          ),
        ],
      ),
    );
  }
}
