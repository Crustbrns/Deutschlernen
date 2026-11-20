import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/card_decision.dart';
import 'package:deutschlernen/domain/models/word.dart';
import 'package:deutschlernen/ui/core/view_models/learning_view_model.dart';
import 'package:deutschlernen/ui/cards/widgets/card_stack.dart';
import 'package:deutschlernen/ui/cards/widgets/cards_top_bar.dart';
import 'package:deutschlernen/ui/cards/widgets/decision_bar.dart';
import 'package:deutschlernen/ui/cards/widgets/recall_bar.dart';
import 'package:deutschlernen/ui/cards/widgets/swipeable_card.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key, required this.viewModel});

  final LearningViewModel viewModel;

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final _swipeController = SwipeController();

  /// Never moves: the buttons on the card below the top one stay unlit.
  final _still = ValueNotifier<double>(0);

  LearningViewModel get _vm => widget.viewModel;

  CardDecision _decisionFor(SwipeDirection direction) {
    final left = direction == SwipeDirection.left;
    return _vm.currentNeedsRecall
        ? (left ? CardDecision.forgot : CardDecision.remembered)
        : (left ? CardDecision.known : CardDecision.learn);
  }

  /// An undone card flies back in from the side it left to.
  SwipeDirection? get _enterFrom => switch (_vm.lastUndone) {
    null => null,
    final d => d.isLeft ? SwipeDirection.left : SwipeDirection.right,
  };

  @override
  void initState() {
    super.initState();
    // After the first frame, so the card is already on screen when it is read.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _vm.onCardsOpened();
    });
  }

  /// Pink / review word: "forgot" (outlined) and "remember" (lime). New word:
  /// the split bar, where knowing it is the good side (lime) and still to
  /// learn is red.
  Widget _bottomBar(Word word, {required bool isTop}) {
    final drag = isTop ? _swipeController.dragProgress : _still;
    void left() => _swipeController.swipe(SwipeDirection.left);
    void right() => _swipeController.swipe(SwipeDirection.right);

    return _vm.needsRecall(word.id)
        ? RecallBar(onForgot: left, onRemembered: right, dragProgress: drag)
        : DecisionBar(onKnown: left, onLearn: right, dragProgress: drag);
  }

  @override
  void dispose() {
    _still.dispose();
    _swipeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([_vm, _swipeController.isSwiping]),
          builder: (context, _) {
            if (_vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final review = _vm.mode == SessionMode.review;

            return Column(
              children: [
                Padding(
                  // 4 less on each side: the round buttons' tap area.
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                  child: CardsTopBar(
                    progress: _vm.progress,
                    onClose: () => Navigator.of(context).pop(),
                    onUndo: _vm.canUndo && !_swipeController.isSwiping.value
                        ? _vm.undo
                        : null,
                    learnedToday: _vm.learnedToday,
                    dailyGoal: LearningViewModel.dailyGoal,
                  ),
                ),
                Expanded(
                  child: _vm.isFinished
                      ? _FinishedView(onDone: () => Navigator.of(context).pop())
                      : Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 560),
                              child: CardStack(
                                words: _vm.deck,
                                index: _vm.index,
                                controller: _swipeController,
                                enterFrom: _enterFrom,
                                onSwipeStarted: _vm.onSwipeStarted,
                                onSwipeCancelled: _vm.onSwipeCancelled,
                                onSwiped: (direction) =>
                                    _vm.onCardSwiped(_decisionFor(direction)),
                                onSpeak: _vm.speak,
                                showTranscription: _vm.showTranscription,
                                translationPool: _vm.translations,
                                stateOf: _vm.stateOf,
                                // New words: only the eye; review: all
                                // three answer modes.
                                answerModes: review,
                                bottomBarFor: _bottomBar,
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FinishedView extends StatelessWidget {
  const _FinishedView({required this.onDone});

  final VoidCallback onDone; // back to the menu

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            strings.goodWork,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: onDone, child: Text(strings.finish)),
        ],
      ),
    );
  }
}
