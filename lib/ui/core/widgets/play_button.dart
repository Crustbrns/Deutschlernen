import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';
import 'package:deutschlernen/ui/core/app_style.dart';

/// Blue play button for German audio, used in example rows and search results.
class PlayButton extends StatelessWidget {
  const PlayButton({super.key, required this.onPressed}) : _rowEnd = false;

  /// Fills the trailing slot of an example row (46 wide, the tap area) with
  /// the icon 10 from its left, so the icon ends 16 from the card's edge,
  /// level with the row dividers.
  const PlayButton.rowEnd({super.key, required this.onPressed})
    : _rowEnd = true;

  static const _size = 20.0; // visible icon

  final VoidCallback onPressed;
  final bool _rowEnd;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(AppIcons.play), // thin rounded triangle
      iconSize: _size,
      color: AppColors.accentBlue,
      style: _rowEnd
          ? IconButton.styleFrom(
              fixedSize: const Size.square(46),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 10),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            )
          : null,
    );
  }
}
