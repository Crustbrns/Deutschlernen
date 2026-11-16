import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/core/widgets/level_icon.dart';

/// A level (A1–B2) in a GroupedCard: colored icon, level name, word count
/// under it, and an optional [trailing] (the percent on the Categories tab,
/// a check in the level picker). One widget, so both places look the same.
class LevelRow extends StatelessWidget {
  const LevelRow({
    super.key,
    required this.level,
    required this.wordCount,
    this.trailing,
    required this.onTap,
  });

  final String level;
  final int wordCount;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // Same typography as a word row: level like the German word. Own row
    // instead of ListTile, which adds its own spacing between the lines.
    return InkWell(
      onTap: onTap,
      child: Padding(
        // 16 = divider indent, so text and lines start at one edge.
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            LevelIcon(level),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(level, style: AppListText.title(colors)),
                  // More air than a word row (AppListText.gap): the count
                  // is smaller and lighter, it shouldn't stick to the name.
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.of(context).wordCount(wordCount),
                    // A size smaller than a word row's translation.
                    style: AppListText.subtitle(colors).copyWith(
                      color: AppPalette.of(context).secondaryText,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
