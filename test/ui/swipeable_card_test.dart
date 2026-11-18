import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/cards/widgets/swipeable_card.dart';

void main() {
  testWidgets('button spam cannot interrupt a flight or lock the next card', (
    tester,
  ) async {
    final controller = SwipeController();
    var cardIndex = 0;
    final swiped = <SwipeDirection>[];
    late StateSetter rebuild;

    Widget card(int index) => SizedBox(
      width: 300,
      height: 400,
      child: SwipeableCard(
        key: ValueKey(index),
        controller: controller,
        onSwipeStarted: () {},
        onSwipeCancelled: () {},
        onSwiped: (direction) {
          swiped.add(direction);
          rebuild(() => cardIndex++);
        },
        child: Column(
          children: [
            Text('card-$index'),
            TextButton(
              onPressed: () => controller.swipe(SwipeDirection.left),
              child: Text('left-$index'),
            ),
            TextButton(
              onPressed: () => controller.swipe(SwipeDirection.right),
              child: Text('right-$index'),
            ),
          ],
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return card(cardIndex);
          },
        ),
      ),
    );

    await tester.tap(find.text('left-0'));
    await tester.pump();
    expect(controller.isSwiping.value, isTrue);

    for (var i = 0; i < 4; i++) {
      await tester.tap(find.text('right-0'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 50));
    }

    await tester.pumpAndSettle();
    expect(swiped, [SwipeDirection.left]);
    expect(find.text('card-1'), findsOneWidget);
    expect(controller.isSwiping.value, isFalse);

    await tester.tap(find.text('right-1'));
    await tester.pumpAndSettle();

    expect(swiped, [SwipeDirection.left, SwipeDirection.right]);
    controller.dispose();
  });

  testWidgets('an interrupted flight releases the swipe lock', (tester) async {
    final controller = SwipeController();
    var showFirstCard = true;
    var cancelled = 0;
    final swiped = <SwipeDirection>[];
    late StateSetter rebuild;

    Widget card({
      required Key key,
      required VoidCallback onSwipeCancelled,
      required ValueChanged<SwipeDirection> onSwiped,
    }) => SizedBox(
      width: 300,
      height: 400,
      child: SwipeableCard(
        key: key,
        controller: controller,
        onSwipeStarted: () {},
        onSwipeCancelled: onSwipeCancelled,
        onSwiped: onSwiped,
        child: const ColoredBox(color: Color(0xFFFFFFFF)),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return showFirstCard
                ? card(
                    key: const ValueKey('first'),
                    onSwipeCancelled: () => cancelled++,
                    onSwiped: swiped.add,
                  )
                : card(
                    key: const ValueKey('next'),
                    onSwipeCancelled: () {},
                    onSwiped: swiped.add,
                  );
          },
        ),
      ),
    );

    controller.swipe(SwipeDirection.left);
    controller.swipe(SwipeDirection.right);
    await tester.pump(const Duration(milliseconds: 100));

    rebuild(() => showFirstCard = false);
    await tester.pump();

    expect(cancelled, 1);
    expect(swiped, isEmpty);

    controller.swipe(SwipeDirection.right);
    await tester.pumpAndSettle();

    expect(swiped, [SwipeDirection.right]);
    controller.dispose();
  });
}
