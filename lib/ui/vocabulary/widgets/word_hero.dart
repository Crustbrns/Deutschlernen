import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_style.dart';

/// Hero shared by a search result row and its opened card: they fly between
/// each other because they have the same tag. Both sides must use this, so
/// the flight settings match.
class WordHero extends StatelessWidget {
  const WordHero({super.key, required this.wordId, required this.child});

  final String wordId;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'word-$wordId',
      // Default fastOutSlowIn starts slowly and makes the big jump in the
      // middle. easeOutCubic moves at once and settles softly; on close
      // its flipped version is used, so the card lands softly into the row.
      curve: Curves.easeOutCubic,
      // Straight line instead of Material's default arc, which bends the path.
      createRectTween: (begin, end) => RectTween(begin: begin, end: end),
      flightShuttleBuilder: _shuttle,
      child: child,
    );
  }
}

/// What is drawn while the row and the card fly between each other.
///
/// The default shuttle lays the card out at every in-between size, and the
/// card overflows when it is small. Here a card-colored box grows instead,
/// and the real card, at its final size and scaled to the box width,
/// fades in over it.
Widget _shuttle(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection direction,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  // The card is the hero on the detail route: "to" on open, "from" on close.
  final cardContext = direction == HeroFlightDirection.push
      ? toHeroContext
      : fromHeroContext;
  final card = (cardContext.widget as Hero).child;
  final cardSize = (cardContext.findRenderObject()! as RenderBox).size;

  // animation is already curved: 0 = row, 1 = card, in both directions.
  return AnimatedBuilder(
    animation: animation,
    builder: (context, child) => ClipRRect(
      borderRadius: BorderRadius.circular(20 + 12 * animation.value), // 20 → 32
      child: ColoredBox(color: AppColors.card, child: child),
    ),
    child: FadeTransition(
      // Content shows up early, together with the growing box, so nothing
      // pops in at the end.
      opacity: CurvedAnimation(
        parent: animation,
        curve: const Interval(0, 0.5),
      ),
      // fitWidth + top: the card keeps its proportions and unfolds downward.
      child: FittedBox(
        fit: BoxFit.fitWidth,
        alignment: Alignment.topCenter,
        clipBehavior: Clip.hardEdge,
        // RepaintBoundary: the card is painted once and then only scaled
        // each frame, instead of being repainted 60 times a second.
        child: RepaintBoundary(
          child: SizedBox.fromSize(size: cardSize, child: card),
        ),
      ),
    ),
  );
}
