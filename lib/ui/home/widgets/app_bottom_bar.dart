import 'dart:ui' show ImageFilter;

import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';

/// Order of the tabs in the bottom bar and in the shell's page stack.
enum HomeTab { main, vocabulary, statistics, settings }

/// Bottom navigation, iOS-style frosted glass: the screen content scrolls
/// under it (Scaffold.extendBody) and shows through blurred. No outline.
/// The selected tab is marked by color only: icon and label turn blue.
///
/// Own layout instead of Material's NavigationBar: that one reserves room
/// for its indicator pill, which leaves a fixed, large gap between the icon
/// and the label.
class AppBottomBar extends StatelessWidget {
  const AppBottomBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final HomeTab selected;
  final ValueChanged<HomeTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final palette = AppPalette.of(context);

    // Thin line icons (Phosphor Regular) for a light, minimal bar.
    final tabs = [
      // Main tab starts a learning session: a stack of flashcards.
      (HomeTab.main, AppIcons.cards, strings.tabMain),
      (HomeTab.vocabulary, AppIcons.bookOpen, strings.tabVocabulary),
      (HomeTab.statistics, AppIcons.chartLineUp, strings.tabStatistics),
      // Sliders instead of a gear: lighter and less "system settings".
      (HomeTab.settings, AppIcons.slidersHorizontal, strings.tabSettings),
    ];

    // ClipRect: without it the blur would spread over the whole screen,
    // not only the area behind the bar.
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: ColoredBox(
          // Semi-transparent: enough tint to keep labels readable over
          // any content, while the blurred content still shows through.
          color: palette.card.withValues(alpha: 0.7),
          // top: false — only the home indicator area below needs padding.
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  for (final (tab, icon, label) in tabs)
                    Expanded(
                      child: _TabButton(
                        icon: icon,
                        label: label,
                        color: tab == selected
                            ? AppColors.accentBlue
                            : palette.mutedText,
                        isSelected: tab == selected,
                        onTap: () => onSelected(tab),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Semantics: screen readers announce it as a selectable tab button.
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      excludeSemantics: true,
      // opaque: the whole cell is tappable, not only the icon and text.
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 26, color: color),
            const SizedBox(height: 2), // small gap between icon and label
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
