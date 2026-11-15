import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/card_decision.dart';
import 'package:deutschlernen/ui/cards/view_models/cards_view_model.dart';
import 'package:deutschlernen/ui/cards/widgets/card_stack.dart';
import 'package:deutschlernen/ui/cards/widgets/cards_top_bar.dart';
import 'package:deutschlernen/ui/cards/widgets/decision_bar.dart';
import 'package:deutschlernen/ui/cards/widgets/swipeable_card.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key, required this.viewModel});

  final CardsViewModel viewModel;

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final _swipeController = SwipeController();

  CardsViewModel get _vm => widget.viewModel;

  CardDecision _decisionFor(SwipeDirection direction) {
    final left = direction == SwipeDirection.left;
    return switch (_vm.mode) {
      SessionMode.newWords => left ? CardDecision.known : CardDecision.learn,
      SessionMode.review =>
        left ? CardDecision.forgot : CardDecision.remembered,
    };
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

  @override
  void dispose() {
    _swipeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _vm,
          builder: (context, _) {
            if (_vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final strings = _vm.strings;
            final review = _vm.mode == SessionMode.review;

            return AppStringsScope(
              strings: strings,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: CardsTopBar(
                      progress: _vm.progress,
                      onClose: () => Navigator.of(context).pop(),
                      onUndo: _vm.canUndo ? _vm.undo : null,
                    ),
                  ),
                  Expanded(
                    child: _vm.isFinished
                        ? _FinishedView(
                            onDone: () => Navigator.of(context).pop(),
                          )
                        : Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 560,
                                ),
                                child: CardStack(
                                  words: _vm.deck,
                                  index: _vm.index,
                                  controller: _swipeController,
                                  enterFrom: _enterFrom,
                                  onSwipeStarted: _vm.onSwipeStarted,
                                  onSwiped: (direction) =>
                                      _vm.onCardSwiped(_decisionFor(direction)),
                                  onSpeak: _vm.speak,
                                  showTranscription: _vm.showTranscription,
                                  bottomBar: DecisionBar(
                                    leftLabel: review
                                        ? strings.forgot
                                        : strings.known,
                                    rightLabel: review
                                        ? strings.remembered
                                        : strings.learn,
                                    onKnown: () => _swipeController.swipe(
                                      SwipeDirection.left,
                                    ),
                                    onLearn: () => _swipeController.swipe(
                                      SwipeDirection.right,
                                    ),
                                    dragProgress: _swipeController.dragProgress,
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
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
