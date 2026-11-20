import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';

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
      // The card's main action: the accent, no outline.
      color: colors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox.square(
          dimension: size,
          child: Icon(AppIcons.eye, size: 28, color: colors.onPrimary),
        ),
      ),
    );
  }
}
