import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/word.dart';
import 'package:deutschlernen/domain/models/word_status.dart';
import 'package:deutschlernen/ui/cards/widgets/word_answer.dart';
import 'package:deutschlernen/ui/cards/widgets/word_card_header.dart';
import 'package:deutschlernen/ui/cards/widgets/word_examples.dart';
import 'package:deutschlernen/ui/cards/widgets/word_title.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/core/widgets/round_icon_button.dart';

/// A word's card: header, the word, the answer part and the examples, with
/// [bottomBar] pinned under them. Learning mode and the compact lookup mode
/// share it; the parts live in their own files.
class WordCard extends StatelessWidget {
  const WordCard({
    super.key,
    required this.word,
    required this.onSpeak,
    required this.showTranscription,
    required this.bottomBar,
    this.translationPool = const [],
    this.lookup = false,
    this.answerModes = true,
    this.lookupCount = 0,
    this.state = (status: WordStatus.newWord, due: null),
    this.onClose,
  });

  /// Lookup mode only: "Искали 3 раза" chip under the translation; hidden
  /// when 0.
  final int lookupCount;

  /// Shown in the header as a colored square + caption ("Учится",
  /// "Повтор через 4 дн.").
  final WordState state;

  /// When set, a close button is pinned to the card's top right corner.
  final VoidCallback? onClose;

  /// Opened from the Categories tab to look a word up, not to learn it:
  /// translation shown right away instead of the answer modes, no
  /// "new word" status, no extra space under the examples.
  final bool lookup;

  /// Learning mode: true = the Show / Write / Choose buttons (review);
  /// false = only an eye that reveals the translation (new words).
  final bool answerModes;

  final Word word;
  final ValueChanged<String> onSpeak;

  /// When off, the speaker button stays but the phonetic text is hidden.
  final bool showTranscription;

  /// Translations to take the wrong options from in the choice mode
  /// (learning only: the lookup card shows the translation right away).
  final List<String> translationPool;

  /// Pinned to the bottom of the card, outside the scrolling content.
  final Widget bottomBar;

  static const _fadeHeight = 24.0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final palette = AppPalette.of(context);
    // Lookup is a compact card: the word block's fonts are 20% smaller.
    final scale = lookup ? 0.8 : 1.0;

    return Material(
      color: palette.card,
      // No outline: a solid card.
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Scrolls; the bottom bar below stays in place.
          Expanded(
            // No horizontal padding here: example rows must span the full
            // card width so their tap highlight does too. Each part insets
            // itself.
            child: Stack(
              children: [
                SingleChildScrollView(
                  // 20px from the top, the same as the level chip's inset
                  // from the left.
                  padding: EdgeInsets.fromLTRB(0, 20, 0, lookup ? 0 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header is inside the scroll view, so it scrolls away.
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: WordCardHeader(
                          level: word.level,
                          status: AppStrings.of(context)
                              .wordState(state, DateTime.now().toUtc()),
                          // Same color as the word's strip in the lists.
                          squareColor: AppColors.forWordStatus(
                            state.status,
                            colors,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.cardInset,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: lookup ? 12 : 30),
                            WordTitle(
                              word: word,
                              showTranscription: showTranscription,
                              onSpeak: onSpeak,
                              scale: scale,
                              compact: lookup,
                            ),
                            SizedBox(height: lookup ? 6 : 20),
                            WordAnswer(
                              word: word,
                              lookup: lookup,
                              answerModes: answerModes,
                              lookupCount: lookupCount,
                              translationPool: translationPool,
                              scale: scale,
                            ),
                            SizedBox(height: lookup ? 16 : 28),
                          ],
                        ),
                      ),
                      WordExamples(
                        word: word,
                        onSpeak: onSpeak,
                        lookup: lookup,
                      ),
                    ],
                  ),
                ),
                // Fade at the bottom edge: the content dissolves into the
                // card color right above the buttons instead of being cut.
                // Not in lookup: there are no buttons, and at the end of the
                // scroll it would fade the last example.
                if (!lookup)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: _fadeHeight,
                    // IgnorePointer: taps go through to the rows underneath.
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              palette.card.withValues(alpha: 0),
                              palette.card,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                // Pinned, not in the scroll view: stays reachable while
                // the examples are scrolled. Centered on the level chip row.
                if (onClose case final onClose?)
                  Positioned(
                    top: 14,
                    right: 14,
                    child: RoundIconButton(
                      icon: AppIcons.x,
                      tooltip: AppStrings.of(context).close,
                      onPressed: onClose,
                    ),
                  ),
              ],
            ),
          ),
          if (!lookup)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: bottomBar,
            ),
        ],
      ),
    );
  }
}
