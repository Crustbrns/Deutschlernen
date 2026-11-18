import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_style.dart';

/// Neutral round icon button (close, undo, …): subtle fill, 36×36, icon 20.
/// Takes 44×44 in the layout: the tap area (Apple's minimum) around the
/// visible circle; a tap there still presses the button.
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.iconColor,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed; // null = disabled
  final Color? iconColor; // default: colors.onSurface

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final subtle = AppPalette.of(context).subtleButton;

    return IconButton.filled(
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: subtle,
        foregroundColor: iconColor ?? colors.onSurface,
        // Disabled: same fill, faded icon, so the button keeps its place.
        disabledBackgroundColor: subtle,
        disabledForegroundColor: colors.onSurface.withValues(alpha: 0.3),
        fixedSize: const Size.square(36),
        minimumSize: const Size.square(36),
        padding: EdgeInsets.zero,
        // Padded to 48 minus 4 (density -1) = 44.
        tapTargetSize: MaterialTapTargetSize.padded,
        visualDensity: const VisualDensity(horizontal: -1, vertical: -1),
      ),
      onPressed: onPressed,
    );
  }
}
