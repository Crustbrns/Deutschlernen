import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_style.dart';

/// One rounded block with its rows split by thin lines, like the examples
/// on the word card. Use it for any list of same-kind items instead of
/// separate cards.
class GroupedCard extends StatelessWidget {
  const GroupedCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: AppPalette.of(context).card,
      // No outline: the block stands out by its fill only.
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      // Clips the ripple of the first/last row to the rounded corners.
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                indent: 16,
                endIndent: 16,
                color: AppColors.divider(colors),
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}
