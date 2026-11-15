import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/word.dart';
import 'package:deutschlernen/ui/cards/widgets/swipeable_card.dart';
import 'package:deutschlernen/ui/cards/widgets/word_card.dart';
import 'package:deutschlernen/ui/core/app_style.dart';

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
    required this.onMenu,
    required this.bottomBar,
  });

  final List<Word> words;
  final int index;
  final SwipeController controller;
  final SwipeDirection? enterFrom;
  final VoidCallback onSwipeStarted;
  final ValueChanged<SwipeDirection> onSwiped;
  final ValueChanged<String> onSpeak;
  final VoidCallback onMenu;
  final Widget bottomBar; // goes into the top card

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
          offset: Offset.zero, // no room below the card to peek out
          duration: _animation,
          curve: Curves.easeOut,
          child: AnimatedScale(
            scale: 1 - depth * 0.05,
            duration: _animation,
            curve: Curves.easeOut,
            // Only the top card is a real card. The ones behind are plain
            // shapes, so their content is not built or painted in advance.
            child: depth == 0
                ? SwipeableCard(
                    enabled: true,
                    controller: controller,
                    enterFrom: enterFrom,
                    onSwipeStarted: onSwipeStarted,
                    onSwiped: onSwiped,
                    child: WordCard(
                      word: words[i],
                      onSpeak: onSpeak,
                      onMenu: onMenu,
                      bottomBar: bottomBar,
                    ),
                  )
                : const _CardBackdrop(),
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

/// Empty card shape shown behind the top card.
class _CardBackdrop extends StatelessWidget {
  const _CardBackdrop();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32), // same as WordCard
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: const SizedBox.expand(),
    );
  }
}
