import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

/// Flat color illustration of a level, growth from A1 to B2: seedling,
/// tulip, tree, snow-capped mountain (Fluent Emoji Flat, MIT, see
/// assets/icons/levels/LICENSE). Used wherever levels are listed. Empty for
/// an unknown level.
class LevelIcon extends StatelessWidget {
  const LevelIcon(this.level, {super.key, this.size = 30});

  final String level;
  final double size;

  static const _assets = {
    'A1': 'assets/icons/levels/a1_seedling.svg',
    'A2': 'assets/icons/levels/a2_tulip.svg',
    'B1': 'assets/icons/levels/b1_tree.svg',
    'B2': 'assets/icons/levels/b2_mountain.svg',
  };

  @override
  Widget build(BuildContext context) {
    final asset = _assets[level];
    if (asset == null) return SizedBox.square(dimension: size);
    // Own colors in both themes: illustrations, not tinted icons.
    return SvgPicture.asset(asset, width: size, height: size);
  }
}
