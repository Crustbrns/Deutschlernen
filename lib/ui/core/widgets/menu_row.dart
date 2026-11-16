import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_style.dart';

/// A row of a menu block (Learn tab, settings): optional colored icon,
/// title, an optional gray line under it and an optional trailing widget.
/// Without [onTap] the row is disabled: grayed out and not tappable.
class MenuRow extends StatelessWidget {
  const MenuRow({
    super.key,
    this.icon,
    this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.titleColor,
    this.compact = false,
    this.onTap,
  });

  /// Settings rows: tighter line height (and a smaller icon, if any),
  /// because their titles and hints often wrap to two lines.
  final bool compact;

  final IconData? icon; // settings rows have none
  final Color? iconColor;
  final String title;
  final String? subtitle; // gray line under the title
  final Widget? trailing;
  final Color? titleColor; // e.g. red for a destructive action
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final height = compact ? compactHeight : null;

    return ListTile(
      // 16 = divider indent of the GroupedCard.
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      minVerticalPadding: 14,
      enabled: enabled,
      leading: icon == null
          ? null
          : Icon(
              icon,
              size: compact ? 22 : 26,
              // Disabled ListTile grays only its text; fade the colored icon too.
              color: enabled ? iconColor : iconColor?.withValues(alpha: 0.4),
            ),
      title: Text(
        title,
        style: MenuRow.titleStyle(color: titleColor, height: height),
      ),
      subtitle: subtitle == null
          ? null
          : Padding(
              padding: EdgeInsets.only(top: compact ? 4 : 0),
              child: Text(
                subtitle!,
                style: MenuRow.hintStyle(
                  context,
                  height: height,
                  soft: compact,
                ),
              ),
            ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  /// Line height of compact rows (the font's default is looser).
  static const compactHeight = 1.12;

  static TextStyle titleStyle({Color? color, double? height}) => TextStyle(
    color: color,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
    height: height,
  );

  /// Gray secondary text: hints, current values, counts.
  /// [soft]: settings text — lighter in the light theme, the same as the
  /// level word count (`AppColors.softSecondary`).
  static TextStyle hintStyle(
    BuildContext context, {
    double? height,
    bool soft = false,
  }) {
    final colors = Theme.of(context).colorScheme;
    return TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
      height: height,
      color: soft && colors.brightness == Brightness.light
          ? AppColors.softSecondary(context)
          : AppColors.quietText(colors),
    );
  }
}
