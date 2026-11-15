import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/card_decision.dart';
import 'package:deutschlernen/ui/cards/view_models/cards_view_model.dart';
import 'package:deutschlernen/ui/cards/widgets/card_stack.dart';
import 'package:deutschlernen/ui/cards/widgets/cards_top_bar.dart';
import 'package:deutschlernen/ui/cards/widgets/decision_bar.dart';
import 'package:deutschlernen/ui/cards/widgets/language_sheet.dart';
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

  CardDecision _decisionFor(SwipeDirection direction) =>
      direction == SwipeDirection.left
      ? CardDecision.known
      : CardDecision.learn;

  SwipeDirection? get _enterFrom => switch (_vm.lastUndone) {
    CardDecision.known => SwipeDirection.left,
    CardDecision.learn => SwipeDirection.right,
    null => null,
  };

  @override
  void dispose() {
    _swipeController.dispose();
    super.dispose();
  }

  void _openLanguageSheet() {
    showLanguageSheet(
      context: context,
      strings: _vm.strings,
      languages: _vm.languages,
      current: _vm.language,
      onSelected: _vm.setLanguage,
    );
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

            return AppStringsScope(
              strings: _vm.strings,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: CardsTopBar(
                      progress: _vm.progress,
                      onClose: () {}, // later
                      onUndo: _vm.canUndo ? _vm.undo : null,
                    ),
                  ),
                  Expanded(
                    child: _vm.isFinished
                        ? _FinishedView(onRestart: _vm.restart)
                        : Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 560,
                                ),
                                child: CardStack(
                                  words: _vm.words,
                                  index: _vm.index,
                                  controller: _swipeController,
                                  enterFrom: _enterFrom,
                                  onSwipeStarted: _vm.onSwipeStarted,
                                  onSwiped: (direction) =>
                                      _vm.onCardSwiped(_decisionFor(direction)),
                                  onSpeak: _vm.speak,
                                  onMenu: _openLanguageSheet,
                                  bottomBar: DecisionBar(
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
  const _FinishedView({required this.onRestart});

  final VoidCallback onRestart;

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
          FilledButton(onPressed: onRestart, child: Text(strings.restart)),
        ],
      ),
    );
  }
}
