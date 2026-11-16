import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';
import 'package:deutschlernen/ui/core/app_style.dart';

/// Only the eye, no label: for new words, where there is nothing to test
/// yet, just a translation to peek at. The card replaces it with the
/// translation once tapped.
class RevealButton extends StatelessWidget {
  const RevealButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  static const size = 64.0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      // Slightly darker than the other neutral buttons; no outline.
      color: AppColors.darken(AppPalette.of(context).subtleButton, 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox.square(
          dimension: size,
          child: Icon(AppIcons.eye, size: 28, color: colors.onSurfaceVariant),
        ),
      ),
    );
  }
}
