import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/word.dart';
import 'package:deutschlernen/domain/models/word_status.dart';
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
    required this.showTranscription,
    required this.translationPool,
    required this.bottomBarFor,
    required this.answerModes,
    required this.stateOf,
  });

  final List<Word> words;

  /// Every word's translation, for the choice mode's wrong options: the
  /// session alone may have too few words for four.
  final List<String> translationPool;
  final int index;
  final SwipeController controller;
  final SwipeDirection? enterFrom;
  final VoidCallback onSwipeStarted;
  final ValueChanged<SwipeDirection> onSwiped;
  final ValueChanged<String> onSpeak;
  final bool showTranscription;

  /// Buttons at the bottom of a word's card (they differ per word: new vs
  /// pink).
  /// [isTop]: only the top card's buttons react to the drag.
  final Widget Function(Word word, {required bool isTop}) bottomBarFor;
  final bool answerModes; // see WordCard.answerModes

  /// Learning status of a word, for the card header.
  final WordState Function(String wordId) stateOf;

  static const _visibleCards = 3;

  /// Dimming of the card under the top one while the top card is at rest.
  static const _maxDim = 0.75;
  // How fast the cards deeper in the stack move up one place after a swipe.
  // (The next card itself grows along with the swipe, see controller.reveal.)
  static const _animation = Duration(milliseconds: 150);

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
            // The next card (depth 1) scales itself with the swipe below.
            scale: depth == 1 ? 1 : 1 - depth * 0.05,
            duration: _animation,
            curve: Curves.easeOut,
            child: switch (depth) {
              0 => SwipeableCard(
                controller: controller,
                enterFrom: enterFrom,
                onSwipeStarted: onSwipeStarted,
                onSwiped: onSwiped,
                child: _card(words[i], isTop: true),
              ),
              // A real card under the top one: its content is already
              // there, and as the top card moves away it grows 95% → 100%
              // and its dimming fades out.
              1 => IgnorePointer(
                child: ValueListenableBuilder<double>(
                  valueListenable: controller.reveal,
                  builder: (context, reveal, child) => Transform.scale(
                    scale: 0.95 + 0.05 * reveal,
                    child: DecoratedBox(
                      // Dimmed toward the screen background (dark theme:
                      // darker), so it reads as "behind".
                      position: DecorationPosition.foreground,
                      decoration: BoxDecoration(
                        color: AppPalette.of(context).background
                            .withValues(alpha: _maxDim * (1 - reveal)),
                        borderRadius: BorderRadius.circular(32), // = WordCard
                      ),
                      child: child,
                    ),
                  ),
                  child: _card(words[i], isTop: false),
                ),
              ),
              // Deeper ones are plain shapes: nothing built in advance.
              _ => const _CardBackdrop(),
            },
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

  Widget _card(Word word, {required bool isTop}) => WordCard(
    word: word,
    onSpeak: onSpeak,
    showTranscription: showTranscription,
    translationPool: translationPool,
    bottomBar: bottomBarFor(word, isTop: isTop),
    answerModes: answerModes,
    state: stateOf(word.id),
  );
}

/// Empty card shape shown behind the top card.
class _CardBackdrop extends StatelessWidget {
  const _CardBackdrop();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppPalette.of(context).card,
      // Same shape as WordCard: rounded, no outline.
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: const SizedBox.expand(),
    );
  }
}
