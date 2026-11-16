import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';
import 'package:deutschlernen/ui/core/app_style.dart';

/// Colored icon of a level, growth from A1 to B2: sprout, tulip, tree,
/// mountain peak. Used wherever levels are listed. Empty for an unknown
/// level.
class LevelIcon extends StatelessWidget {
  const LevelIcon(this.level, {super.key, this.size = 26});

  final String level;
  final double size;

  static const _icons = {
    'A1': (AppIcons.plant, AppColors.levelA1),
    'A2': (AppIcons.flowerTulip, AppColors.levelA2),
    'B1': (AppIcons.tree, AppColors.levelB1),
    'B2': (AppIcons.mountains, AppColors.levelB2),
  };

  @override
  Widget build(BuildContext context) {
    final entry = _icons[level];
    if (entry == null) return SizedBox.square(dimension: size);
    final (icon, color) = entry;
    return Icon(icon, size: size, color: color);
  }
}
