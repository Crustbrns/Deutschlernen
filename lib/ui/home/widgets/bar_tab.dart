import 'package:material_ui/material_ui.dart';

/// One tab of the bottom bar: icon and label. Taps are handled by the bar.
class BarTab extends StatelessWidget {
  const BarTab({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // All tabs in the main text color (white in the dark theme); the
    // selected one is marked by the pill only.
    final color = Theme.of(context).colorScheme.onSurface;

    // Taps are handled by the bar (it also runs the lens); Semantics keeps
    // each tab a separate button for screen readers.
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
