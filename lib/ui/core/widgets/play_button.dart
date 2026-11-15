import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';
import 'package:deutschlernen/ui/core/app_style.dart';

/// Blue play button for German audio, used in example rows and search results.
class PlayButton extends StatelessWidget {
  const PlayButton({super.key, required this.onPressed});

  /// Visual icon size; rows use it to keep their right edge aligned.
  static const size = 20.0;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(AppIcons.play), // thin rounded triangle
      iconSize: size,
      color: AppColors.accentBlue,
    );
  }
}
