import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/word.dart';
import 'package:deutschlernen/domain/models/word_status.dart';
import 'package:deutschlernen/ui/cards/widgets/word_card.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/categories/widgets/word_hero.dart';

/// One word's card opened from the Categories tab.
/// Same card as in learning, in its compact lookup mode. A word with
/// progress gets a "reset progress" button under the card.
/// Shown over a solid black backdrop that hides the list behind it
/// (see [WordDetailScreen.route]).
class WordDetailScreen extends StatefulWidget {
  const WordDetailScreen({
    super.key,
    required this.word,
    required this.showTranscription,
    required this.lookupCount,
    required this.onSpeak,
    required this.state,
    required this.onResetProgress,
  });

  final Word word;
  final bool showTranscription;
  final int lookupCount; // times opened from the search, shown in the header
  final ValueChanged<String> onSpeak;

  /// Shown in the card header; a new word has nothing to reset, no button.
  final WordState state;
  final VoidCallback onResetProgress;

  /// The card grows out of the list row via [WordHero] while the barrier
  /// fades in to solid black, so the list is hidden once the card is open.
  static Route<void> route(WordDetailScreen screen) {
    return PageRouteBuilder<void>(
      // Not opaque: the list stays painted while the barrier fades in and
      // out, and the hero has its row to fly back to on close.
      opaque: false,
      // Solid black, not a dim: the list behind must not show (user's
      // choice). The barrier is not themed, black in both themes.
      barrierColor: Colors.black,
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, _, _) => screen,
      // No page transition: the only visible thing is the card, and the
      // hero animates it. A fade on top would just make it look washed out.
      transitionsBuilder: (_, _, _, child) => child,
    );
  }

  @override
  State<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {
  // Local copy: after a reset the card shows "new" and the button goes
  // away while the card stays open.
  late WordState _state = widget.state;

  void _reset() {
    widget.onResetProgress();
    setState(() => _state = (status: WordStatus.newWord, due: null));
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final word = widget.word;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                children: [
                  // The card takes what is left above the button.
                  Expanded(
                    child: WordHero(
                      wordId: word.id,
                      child: WordCard(
                        word: word,
                        onSpeak: widget.onSpeak,
                        showTranscription: widget.showTranscription,
                        bottomBar: const SizedBox.shrink(),
                        lookup: true,
                        lookupCount: widget.lookupCount,
                        state: _state,
                        onClose: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                  // Animated: after a reset the card grows back smoothly.
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    child: _state.status != WordStatus.newWord
                        ? Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: _ResetButton(
                              label: strings.resetProgress,
                              onPressed: _reset,
                            ),
                          )
                        : const SizedBox(width: double.infinity),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-width button under the card, styled as a piece of the card: same
/// fill, outline and corner radius (see WordCard). Filled: it sits over the
/// black backdrop and would blend in without a fill.
class _ResetButton extends StatelessWidget {
  const _ResetButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: const Icon(AppIcons.arrowCounterClockwise, size: 20),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: AppPalette.of(context).card,
          foregroundColor: colors.onSurface,
          padding: const EdgeInsets.symmetric(vertical: 18),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
      ),
    );
  }
}
