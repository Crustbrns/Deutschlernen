import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/word.dart';
import 'package:deutschlernen/ui/cards/widgets/answer_modes.dart';
import 'package:deutschlernen/ui/cards/widgets/example_tile.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/core/widgets/round_icon_button.dart';

class WordCard extends StatefulWidget {
  const WordCard({
    super.key,
    required this.word,
    required this.onSpeak,
    required this.showTranscription,
    required this.otherTranslations,
    required this.bottomBar,
    this.lookup = false,
    this.onClose,
  });

  /// When set, a close button is pinned to the card's top right corner.
  final VoidCallback? onClose;

  /// Opened from the vocabulary to look a word up, not to learn it:
  /// translation shown right away instead of the answer modes, no
  /// "new word" status, no extra space under the examples.
  final bool lookup;

  final Word word;
  final ValueChanged<String> onSpeak;

  /// When off, the speaker button stays but the phonetic text is hidden.
  final bool showTranscription;

  /// Translations of the other words, used as wrong options in the choice mode.
  final List<String> otherTranslations;

  /// Pinned to the bottom of the card, outside the scrolling content.
  final Widget bottomBar;

  @override
  State<WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<WordCard> {
  static const _fadeHeight = 24.0;

  AnswerMode? _mode; // null = only the three buttons are visible

  /// Lookup is a compact card: the word block's fonts are 20% smaller.
  double get _scale => widget.lookup ? 0.8 : 1.0;

  /// Big translation: revealed by the eye button, or always shown in lookup.
  Widget _buildTranslation(Word word) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          word.translation,
          style: TextStyle(
            fontFamily: AppFonts.translation,
            fontSize: 42 * _scale,
            fontWeight: FontWeight.w600, // = wght
            fontVariations: AppFonts.translationVariations,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final palette = AppPalette.of(context);
    final word = widget.word;
    final lookup = widget.lookup;

    return Material(
      color: palette.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.4)),
      ),
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
                  // 20px from the top, the same as the level chip's inset from the left.
                  padding: EdgeInsets.fromLTRB(0, 20, 0, lookup ? 0 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header is inside the scroll view, so it scrolls away.
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: _Header(level: word.level, showStatus: !lookup),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.cardInset,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: lookup ? 12 : 30),
                            // FittedBox shrinks long German words instead of overflowing.
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text.rich(
                                TextSpan(
                                  style: TextStyle(
                                    fontFamily: AppFonts.display,
                                    fontSize: 44 * _scale,
                                    fontWeight: FontWeight
                                        .w600, // keep in sync with wght
                                    fontVariations: AppFonts.word,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '${word.article} ',
                                      style: TextStyle(
                                        color: AppColors.forArticle(
                                          word.article,
                                        ),
                                      ),
                                    ),
                                    TextSpan(text: word.german),
                                  ],
                                ),
                              ),
                            ),
                            if (word.plural != null) ...[
                              // Negative gap: the line boxes of big fonts leave extra
                              // space, so the plural is pulled up a bit.
                              Transform.translate(
                                offset: Offset(0, -6 * _scale),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '(die ${word.plural})', // plural is always "die"
                                    style: TextStyle(
                                      fontFamily: AppFonts.display,
                                      fontSize: 21 * _scale,
                                      fontWeight: FontWeight.w400, // regular
                                      fontVariations: AppFonts.plural,
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            SizedBox(height: lookup ? 6 : 16),
                            Center(
                              child: _TranscriptionButton(
                                transcription: widget.showTranscription
                                    ? word.transcription
                                    : null,
                                scale: _scale,
                                onPressed: () =>
                                    widget.onSpeak(word.withArticle),
                              ),
                            ),
                            SizedBox(height: lookup ? 6 : 20),
                            if (lookup)
                              // Nothing to guess here: just the translation.
                              _buildTranslation(word)
                            else ...[
                              AnswerModeBar(
                                selected: _mode,
                                // The eye shows the translation right away.
                                onPressed: (mode) =>
                                    setState(() => _mode = mode),
                              ),
                              // Panel of the selected mode, right above the examples.
                              AnimatedSize(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOut,
                                alignment: Alignment.topCenter,
                                child: switch (_mode) {
                                  null => const SizedBox(
                                    width: double.infinity,
                                  ),
                                  AnswerMode.show => Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: _buildTranslation(word),
                                  ),
                                  AnswerMode.write => Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: WriteAnswerPanel(word: word),
                                  ),
                                  AnswerMode.choice => Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: ChoiceAnswerPanel(
                                      word: word,
                                      otherTranslations:
                                          widget.otherTranslations,
                                    ),
                                  ),
                                },
                              ),
                            ],
                            SizedBox(height: lookup ? 16 : 28),
                          ],
                        ),
                      ),
                      // Definition is the first row of the examples block.
                      DefinitionTile(
                        // "(f.) Der Zustand, ..." — gender mark only for nouns.
                        definition: word.genderMark == null
                            ? word.definition
                            : '(${word.genderMark}) ${word.definition}',
                        translation: word.definitionTranslation,
                      ),
                      for (var i = 0; i < word.examples.length; i++)
                        ExampleTile(
                          key: ValueKey(word.examples[i].german),
                          example: word.examples[i],
                          // All collapsed: an open translation would spoil the
                          // hidden word translation above.
                          initiallyExpanded: false,
                          onSpeak: widget.onSpeak,
                        ),
                      // Lookup: the last example ends at the card's bottom edge,
                      // so no closing line and no extra room.
                      if (!lookup) ...[
                        // Closing line under the last row, same as the rows' top borders.
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.cardInset,
                          ),
                          child: Divider(
                            height: 1,
                            thickness: 1,
                            color: AppColors.divider(colors),
                          ),
                        ),
                        // Extra scroll room, so the last example can be lifted up
                        // away from the card's bottom edge.
                        const SizedBox(height: 100),
                      ],
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
                if (widget.onClose case final onClose?)
                  Positioned(
                    top: 14,
                    right: 14,
                    child: RoundIconButton(
                      icon: Icons.close,
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
              child: widget.bottomBar,
            ),
        ],
      ),
    );
  }
}

class _TranscriptionButton extends StatelessWidget {
  const _TranscriptionButton({
    required this.transcription,
    required this.onPressed,
    this.scale = 1,
  });

  /// null = show only the speaker icon.
  final String? transcription;
  final VoidCallback onPressed;
  final double scale; // shrinks text, icon and padding together

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        shape: const StadiumBorder(),
        // 25% darker fill and border than the theme defaults.
        backgroundColor: AppColors.darken(colors.surfaceContainer, 0.25),
        side: BorderSide(color: AppColors.darken(colors.outlineVariant, 0.25)),
        foregroundColor: colors.onSurface,
        // All sizes are 75% of the previous ones.
        padding: EdgeInsets.symmetric(
          horizontal: 15 * scale,
          vertical: 6 * scale,
        ),
        minimumSize: Size(0, 36 * scale),
        // Otherwise Material pads the button to 48px tall, eating the
        // compact spacing around it.
        tapTargetSize: scale < 1 ? MaterialTapTargetSize.shrinkWrap : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (transcription != null) ...[
            Text(
              transcription!,
              style: TextStyle(
                fontSize: 16.5 * scale,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 12 * scale),
          ],
          Icon(Icons.volume_up_outlined, size: 19.5 * scale),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.level, required this.showStatus});

  final String level;
  final bool showStatus; // square + "New word" next to the level

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final strings = AppStrings.of(context);

    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Text(level, style: const TextStyle(fontSize: 13.5)),
          ),
        ),
        if (showStatus) ...[
          const SizedBox(width: 16),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: colors.outline,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            strings.newWord,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: AppPalette.of(context).mutedText,
            ),
          ),
        ],
      ],
    );
  }
}
