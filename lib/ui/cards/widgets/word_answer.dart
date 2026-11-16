import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/word.dart';
import 'package:deutschlernen/ui/cards/widgets/answer_mode_bar.dart';
import 'package:deutschlernen/ui/cards/widgets/choice_answer_panel.dart';
import 'package:deutschlernen/ui/cards/widgets/reveal_button.dart';
import 'package:deutschlernen/ui/cards/widgets/word_card_header.dart';
import 'package:deutschlernen/ui/cards/widgets/write_answer_panel.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';

/// The part of the word card under the word, by the card's mode:
/// - lookup: the translation right away, plus the lookup count chip;
/// - new words ([answerModes] false): an eye that turns into the translation;
/// - review: the Show / Write / Choose buttons and the open mode's panel.
class WordAnswer extends StatefulWidget {
  const WordAnswer({
    super.key,
    required this.word,
    required this.lookup,
    required this.answerModes,
    required this.lookupCount,
    required this.translationPool,
    this.scale = 1,
  });

  final Word word;
  final bool lookup;
  final bool answerModes;
  final int lookupCount; // lookup only; the chip is hidden when 0
  final List<String> translationPool; // wrong options in the choice mode
  final double scale;

  @override
  State<WordAnswer> createState() => _WordAnswerState();
}

class _WordAnswerState extends State<WordAnswer> {
  AnswerMode? _mode; // null = only the three buttons are visible

  @override
  Widget build(BuildContext context) {
    final word = widget.word;
    final translation = WordTranslation(word, scale: widget.scale);

    if (widget.lookup) {
      // Nothing to guess here: just the translation.
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          translation,
          if (widget.lookupCount > 0) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: CardChip(
                AppStrings.of(context).lookupCount(widget.lookupCount),
                radius: 8,
              ),
            ),
          ],
        ],
      );
    }

    if (!widget.answerModes) {
      // The eye turns into the translation; there is no way back, nothing
      // to hide it for.
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _mode == AnswerMode.show
            ? translation
            : Center(
                child: RevealButton(
                  onPressed: () => setState(() => _mode = AnswerMode.show),
                ),
              ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnswerModeBar(
          selected: _mode,
          // The eye shows the translation right away.
          onPressed: (mode) => setState(() => _mode = mode),
        ),
        // Panel of the selected mode, right above the examples.
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: switch (_mode) {
            null => const SizedBox(width: double.infinity),
            final mode => Padding(
              padding: const EdgeInsets.only(top: 16),
              child: switch (mode) {
                AnswerMode.show => translation,
                AnswerMode.write => WriteAnswerPanel(word: word),
                AnswerMode.choice => ChoiceAnswerPanel(
                  word: word,
                  translationPool: widget.translationPool,
                ),
              },
            ),
          },
        ),
      ],
    );
  }
}

/// Big translation, left-aligned like the German word above it.
class WordTranslation extends StatelessWidget {
  const WordTranslation(this.word, {super.key, this.scale = 1});

  final Word word;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          word.translation,
          // Theme font, like the rest of the UI.
          style: TextStyle(
            fontSize: 32 * scale,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.6,
          ),
        ),
      ),
    );
  }
}
