import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/word.dart';
import 'package:deutschlernen/ui/cards/widgets/example_tile.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';

class WordCard extends StatefulWidget {
  const WordCard({
    super.key,
    required this.word,
    required this.onSpeak,
    required this.onMenu,
    required this.bottomBar,
  });

  final Word word;
  final ValueChanged<String> onSpeak;
  final VoidCallback onMenu;

  /// Pinned to the bottom of the card, outside the scrolling content.
  final Widget bottomBar;

  @override
  State<WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<WordCard> {
  static const _fadeHeight = 24.0;

  bool _translationVisible = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final strings = AppStrings.of(context);
    final word = widget.word;

    return Material(
      color: AppColors.card,
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
                  // Top 10, not 20: the header row is as tall as the 48px menu button,
                  // and the ~28px level chip is centered in it (+10px). So the chip ends
                  // up 20px from the top, the same as its 20px inset from the left.
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header is inside the scroll view, so it scrolls away.
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 16, 0),
                        child: _Header(
                          level: word.level,
                          onMenu: widget.onMenu,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.cardInset,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 30),
                            // FittedBox shrinks long German words instead of overflowing.
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text.rich(
                                TextSpan(
                                  style: TextStyle(
                                    fontFamily: AppFonts.display,
                                    fontSize: 44,
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
                                offset: const Offset(0, -6),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '(die ${word.plural})', // plural is always "die"
                                    style: TextStyle(
                                      fontFamily: AppFonts.display,
                                      fontSize: 21,
                                      fontWeight: FontWeight.w400, // regular
                                      fontVariations: AppFonts.plural,
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            Center(
                              child: _TranscriptionButton(
                                transcription: word.transcription,
                                onPressed: () =>
                                    widget.onSpeak(word.withArticle),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 80, // must fit the 76px eye button

                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                child: _translationVisible
                                    ? Center(
                                        key: const ValueKey('shown'),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            word.translation,
                                            style: const TextStyle(
                                              fontFamily: AppFonts.translation,
                                              fontSize: 42,
                                              fontWeight:
                                                  FontWeight.w600, // = wght
                                              fontVariations: AppFonts
                                                  .translationVariations,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Center(
                                        key: const ValueKey('hidden'),
                                        child: IconButton.filledTonal(
                                          onPressed: () => setState(
                                            () => _translationVisible = true,
                                          ),
                                          // Text is kept as tooltip and for screen readers.
                                          tooltip: strings.showTranslation,
                                          icon: const Icon(
                                            Icons.visibility,
                                            size: 28,
                                          ),
                                          // Neutral dark grey instead of the tonal
                                          // accent, so the button doesn't stand out.
                                          style: IconButton.styleFrom(
                                            backgroundColor:
                                                AppColors.subtleButton,
                                            foregroundColor: colors
                                                .onSurfaceVariant
                                                .withValues(alpha: 0.6),
                                            // Same icon, bigger box = more padding.
                                            fixedSize: const Size.square(76),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 28),
                          ],
                        ),
                      ),
                      // Definition is the first row of the examples block.
                      DefinitionTile(
                        definition: word.definition,
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
                  ),
                ),
                // Fade at the bottom edge: the content dissolves into the
                // card color right above the buttons instead of being cut.
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
                            AppColors.card.withValues(alpha: 0),
                            AppColors.card,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
  });

  final String transcription;
  final VoidCallback onPressed;

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
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
        minimumSize: const Size(0, 36),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            transcription,
            style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.volume_up_outlined, size: 19.5),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.level, required this.onMenu});

  final String level;
  final VoidCallback onMenu;

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
        const SizedBox(width: 16),
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: colors.outline,
            borderRadius: BorderRadius.circular(3),
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
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
        IconButton.outlined(
          onPressed: onMenu,
          tooltip: strings.menu,
          icon: const Icon(Icons.more_horiz),
          // ~26% smaller than the default (40px circle, 24px icon).
          // The tap area stays 48px (default tapTargetSize), so it is still
          // easy to hit and the header row keeps its height.
          iconSize: 17.6,
          style: IconButton.styleFrom(
            fixedSize: const Size.square(29.7),
            minimumSize: Size.zero,
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}
