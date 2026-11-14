import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/word.dart';
import 'package:deutschlernen/ui/cards/widgets/swipeable_card.dart';
import 'package:deutschlernen/ui/cards/widgets/word_card.dart';

class CardStack extends StatelessWidget {
  const CardStack({
    super.key,
    required this.words,
    required this.index,
    required this.controller,
    required this.enterFrom,
    required this.onSwipeStarted,
    required this.onSwiped,
    required this.onSpeak,
  });

  final List<Word> words;
  final int index;
  final SwipeController controller;
  final SwipeDirection? enterFrom;
  final VoidCallback onSwipeStarted;
  final ValueChanged<SwipeDirection> onSwiped;
  final ValueChanged<String> onSpeak;

  static const _visibleCards = 3;
  static const _animation = Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    final last = math.min(index + _visibleCards, words.length);
    final children = <Widget>[];

    // Back to front, so the top card is painted last.
    for (var i = last - 1; i >= index; i--) {
      final depth = i - index;

      children.add(
        AnimatedSlide(
          key: ValueKey(i),
          offset: Offset(0, depth * 0.06),
          duration: _animation,
          curve: Curves.easeOut,
          child: AnimatedScale(
            scale: 1 - depth * 0.05,
            duration: _animation,
            curve: Curves.easeOut,
            child: IgnorePointer(
              ignoring: depth != 0,
              child: SwipeableCard(
                enabled: depth == 0,
                controller: controller,
                enterFrom: depth == 0 ? enterFrom : null,
                onSwipeStarted: onSwipeStarted,
                onSwiped: onSwiped,
                child: WordCard(word: words[i], onSpeak: onSpeak),
              ),
            ),
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none, // lets the card fly past the edge
      children: children,
    );
  }
}