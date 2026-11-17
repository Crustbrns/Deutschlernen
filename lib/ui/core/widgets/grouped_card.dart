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
    return Material(
      color: AppPalette.of(context).card,
      // No outline: the block stands out by its fill only.
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      // Clips the ripple of the first/last row to the rounded corners.
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const _RowDivider(),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// [GroupedCard] for long lists (words, search results): rows are built
/// lazily, only the ones on screen. Put it in a CustomScrollView.
/// The block's fill is one decoration behind the whole list, so there are
/// no seams between rows; each row gets its own transparent Material, so
/// its ripple shows on the fill and is clipped to the outer corners.
class GroupedSliverList extends StatelessWidget {
  const GroupedSliverList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  static const _radius = Radius.circular(20);

  @override
  Widget build(BuildContext context) {
    return DecoratedSliver(
      decoration: BoxDecoration(
        color: AppPalette.of(context).card,
        borderRadius: const BorderRadius.all(_radius),
      ),
      sliver: SliverList.builder(
        itemCount: itemCount,
        itemBuilder: (context, i) => Material(
          type: MaterialType.transparency,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: i == 0 ? _radius : Radius.zero,
              bottom: i == itemCount - 1 ? _radius : Radius.zero,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [if (i > 0) const _RowDivider(), itemBuilder(context, i)],
          ),
        ),
      ),
    );
  }
}

/// Thin line between two rows of a block, inset 16 like the row text.
class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: AppColors.divider(Theme.of(context).colorScheme),
    );
  }
}
