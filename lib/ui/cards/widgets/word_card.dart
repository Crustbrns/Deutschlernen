// material_ui doesn't re-export OverflowBoxFit.
import 'package:flutter/rendering.dart' show OverflowBoxFit;
import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';
import 'package:deutschlernen/domain/models/word.dart';
import 'package:deutschlernen/domain/models/word_status.dart';
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

  /// Opened from the vocabulary to look a word up, not to learn it:
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

  /// Translations of the other words, used as wrong options in the choice mode.
  final List<String> otherTranslations;

  /// Pinned to the bottom of the card, outside the scrolling content.
  final Widget bottomBar;

  @override
  State<WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<WordCard> {
  /// How far the word row reaches into the card's right inset.
  static const _speakerOverhang = 12.0;

  static const _fadeHeight = 24.0;

  AnswerMode? _mode; // null = only the three buttons are visible

  /// Lookup is a compact card: the word block's fonts are 20% smaller.
  double get _scale => widget.lookup ? 0.8 : 1.0;

  /// Big translation: revealed by the eye button, or always shown in lookup.
  /// Left-aligned, like the German word above it.
  Widget _buildTranslation(Word word) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          word.translation,
          // Theme font, like the rest of the UI.
          style: TextStyle(
            fontSize: 32 * _scale,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.6,
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
                  // 20px from the top, the same as the level chip's inset from the left.
                  padding: EdgeInsets.fromLTRB(0, 20, 0, lookup ? 0 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header is inside the scroll view, so it scrolls away.
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: _Header(
                          level: word.level,
                          status: AppStrings.of(context)
                              .wordState(widget.state, DateTime.now().toUtc()),
                          // Same color as the word's strip in the lists.
                          squareColor: AppColors.forWordStatus(
                            widget.state.status,
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
                            // Word and plural left-aligned, speaker on the
                            // right of the word. The row reaches into the
                            // card's right inset (24 → 12): more room for
                            // long words before they wrap.
                            LayoutBuilder(
                              builder: (context, constraints) => OverflowBox(
                                alignment: Alignment.centerLeft,
                                fit: OverflowBoxFit.deferToChild,
                                minWidth:
                                    constraints.maxWidth + _speakerOverhang,
                                maxWidth:
                                    constraints.maxWidth + _speakerOverhang,
                                child: Row(
                                  children: [
                                    // "der Hund (die Hunde)" in one text: the
                                    // plural continues the line in the same
                                    // style; long ones wrap to the next line.
                                    Expanded(
                                      child: Text.rich(
                                        TextSpan(
                                          // Theme font, like the rest of the UI.
                                          style: TextStyle(
                                            fontSize: 32 * _scale,
                                            fontWeight: FontWeight.w600,
                                            // Condensed: big text looks loose.
                                            letterSpacing: -0.6,
                                            height: 1.15,
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
                                            // Plural is always "die".
                                            if (word.plural != null)
                                              TextSpan(
                                                text: ' (die ${word.plural})',
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8 * _scale),
                                    _TranscriptionButton(
                                      transcription: null, // speaker icon only
                                      scale: _scale,
                                      onPressed: () =>
                                          widget.onSpeak(word.withArticle),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (widget.showTranscription) ...[
                              SizedBox(height: lookup ? 6 : 12),
                              // Also speaks the word on tap.
                              Align(
                                alignment: Alignment.centerLeft,
                                child: _TranscriptionButton(
                                  transcription: word.transcription,
                                  showIcon: false,
                                  scale: _scale,
                                  onPressed: () =>
                                      widget.onSpeak(word.withArticle),
                                ),
                              ),
                            ],
                            SizedBox(height: lookup ? 6 : 20),
                            if (lookup) ...[
                              // Nothing to guess here: just the translation.
                              _buildTranslation(word),
                              if (widget.lookupCount > 0) ...[
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: _Chip(
                                    AppStrings.of(context)
                                        .lookupCount(widget.lookupCount),
                                    radius: 8,
                                  ),
                                ),
                              ],
                            ] else if (!widget.answerModes) ...[
                              // The eye turns into the translation; there is
                              // no way back, nothing to hide it for.
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: _mode == AnswerMode.show
                                    ? _buildTranslation(word)
                                    : Center(
                                        child: RevealButton(
                                          onPressed: () => setState(
                                            () => _mode = AnswerMode.show,
                                          ),
                                        ),
                                      ),
                              ),
                            ] else ...[
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
    this.showIcon = true,
    this.scale = 1,
  });

  /// null = show only the speaker icon.
  final String? transcription;
  final bool showIcon; // false = transcription text only
  final VoidCallback onPressed;
  final double scale; // shrinks text, icon and padding together

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        // Icon only: a rounded square; with the transcription: a pill.
        shape: transcription == null
            ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
            : const StadiumBorder(),
        // 25% darker fill and border than the theme defaults.
        backgroundColor: AppColors.darken(colors.surfaceContainer, 0.25),
        side: BorderSide(color: AppColors.darken(colors.outlineVariant, 0.25)),
        foregroundColor: colors.onSurface,
        // All sizes are 75% of the previous ones.
        // Icon only: equal padding, so the button is square.
        padding: transcription == null
            ? EdgeInsets.all(10 * scale)
            : EdgeInsets.symmetric(horizontal: 15 * scale, vertical: 6 * scale),
        minimumSize: Size(0, 36 * scale),
        // Otherwise Material pads the button to 48px tall, eating the
        // compact spacing around it.
        tapTargetSize: scale < 1 ? MaterialTapTargetSize.shrinkWrap : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (transcription != null)
            Text(
              transcription!,
              style: TextStyle(
                fontSize: 16.5 * scale,
                fontWeight: FontWeight.w500,
              ),
            ),
          if (transcription != null && showIcon) SizedBox(width: 12 * scale),
          if (showIcon) Icon(AppIcons.speakerHigh, size: 19.5 * scale),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.level,
    required this.status,
    required this.squareColor,
  });

  final String level;

  /// Gray text next to the level ("New word", "Повтор через 4 дн.").
  final String status;
  final Color squareColor; // status square before the text

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Chip(level, radius: 24),
        const SizedBox(width: 10),
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: squareColor,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            status,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              // Condensed: at the default spacing the letters looked apart.
              letterSpacing: -0.5,
              color: AppPalette.of(context).mutedText,
            ),
          ),
        ),
      ],
    );
  }
}

/// Small gray plate with text: the level in the header (round) and the
/// lookup count under the translation (squarer).
class _Chip extends StatelessWidget {
  const _Chip(this.text, {required this.radius});

  final String text;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Text(text, style: const TextStyle(fontSize: 13.5)),
      ),
    );
  }
}
