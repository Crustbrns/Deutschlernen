import 'package:material_ui/material_ui.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

/// Glass lens over the bottom bar's tabs: RawMagnifier enlarges what is
/// under it, and a LiquidGlass layer on top bends it at the edges (real
/// refraction via a shader, like iOS 26), with no blur and no color fringes.
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
          LiquidGlass.withOwnLayer(
            shape: LiquidRoundedSuperellipse(borderRadius: height / 2),
            settings: LiquidGlassSettings(
              // Fades the glass in and out with the lift.
              visibility: lift,
              thickness: 14,
              refractiveIndex: 1.3,
              blur: 0, // sharp, not soapy
              chromaticAberration: 0, // no rainbow edges
              lightIntensity: 0.6,
              saturation: 1,
              glassColor: colors.onSurface.withValues(alpha: 0.04),
            ),
            child: SizedBox.fromSize(size: size),
          ),
        ],
      ),
    );
  }
}
