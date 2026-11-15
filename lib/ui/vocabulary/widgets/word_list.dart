import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/word.dart';
import 'package:deutschlernen/domain/models/word_status.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/core/widgets/grouped_card.dart';
import 'package:deutschlernen/ui/core/widgets/play_button.dart';
import 'package:deutschlernen/ui/vocabulary/widgets/word_hero.dart';

/// Words in one grouped block: search results and a level's word list.
/// Tapping a row opens the word's card; the play button speaks it.
class WordList extends StatelessWidget {
  const WordList({
    super.key,
    required this.words,
    required this.onWordSelected,
    required this.onSpeak,
    required this.stateOf,
    this.showLevel = true,
  });

  final List<Word> words;
  final WordState Function(String wordId) stateOf;
  final ValueChanged<Word> onWordSelected;
  final ValueChanged<String> onSpeak; // German text-to-speech

  /// Off inside a level's own list, where every row would repeat it.
  final bool showLevel;

  @override
  Widget build(BuildContext context) {
    // A Column builds every row at once; fine for now, switch to a lazy list
    // if the dictionary grows to thousands of words.
    return SingleChildScrollView(
      // + bottom inset: the last row stays above the bottom bar / home indicator.
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        24 + MediaQuery.paddingOf(context).bottom,
      ),
      // Scrolling hides the keyboard, as in iOS search.
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: GroupedCard(
        children: [
          for (final word in words)
            WordRow(
              word: word,
              state: stateOf(word.id),
              showLevel: showLevel,
              onTap: () {
                FocusScope.of(context).unfocus();
                onWordSelected(word);
              },
              onSpeak: () => onSpeak(word.withArticle),
            ),
        ],
      ),
    );
  }
}

/// Status strip on the left; then a caption on top (level and learning
/// status, e.g. "A1 · Повтор через 4 дн."), "der Hund · die Hunde" in the
/// middle, translation below; play button on the right.
class WordRow extends StatelessWidget {
  const WordRow({
    super.key,
    required this.word,
    required this.state,
    required this.onTap,
    required this.onSpeak,
    this.showLevel = true,
  });

  static const _fontSize = 16.0;
  static const _wordFontSize = 17.0; // German word: a touch bigger
  static const _lineHeight = 1.15; // tighter than the default
  static const _letterSpacing = -0.2; // slightly condensed
  static const _gap = 2.0; // between the three lines

  final Word word;
  final WordState state;
  final VoidCallback onTap;
  final VoidCallback onSpeak;
  final bool showLevel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final forms = [word.withArticle, ?word.pluralWithArticle].join(' · ');
    final caption = [
      if (showLevel) word.level,
      AppStrings.of(context).wordState(state, DateTime.now().toUtc()),
    ].join(' · ');

    // No own background: the row sits inside the shared block.
    // Hero: the opened card grows out of this row and shrinks back into it.
    return WordHero(
      wordId: word.id,
      // Transparent Material: InkWell needs one, and the row is moved out
      // of the block while the hero flies.
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
            // IntrinsicHeight: the strip stretches to the text's height.
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _StatusStrip(status: state.status),
                  const SizedBox(width: 12),
                  // Expanded: long words wrap instead of pushing the button out.
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          caption,
                          // The three lines share size, line height and
                          // spacing; color and weight tell them apart.
                          style: TextStyle(
                            color: AppPalette.of(context).mutedText,
                            fontSize: _fontSize,
                            fontWeight: FontWeight.w600,
                            height: _lineHeight,
                            letterSpacing: _letterSpacing,
                          ),
                        ),
                        const SizedBox(height: _gap),
                        Text(
                          forms,
                          style: TextStyle(
                            // onSurface: white in the dark theme, near-black
                            // in the light one (plain white would vanish).
                            color: colors.onSurface,
                            fontSize: _wordFontSize,
                            fontWeight: FontWeight.bold,
                            height: _lineHeight,
                            letterSpacing: _letterSpacing,
                          ),
                        ),
                        const SizedBox(height: _gap),
                        Text(
                          word.translation,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: _fontSize,
                            fontWeight: FontWeight.w600,
                            height: _lineHeight,
                            letterSpacing: _letterSpacing,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Own tap target: plays the word without opening the card.
                  Center(child: PlayButton(onPressed: onSpeak)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Thin vertical bar colored by the word's learning status.
class _StatusStrip extends StatelessWidget {
  const _StatusStrip({required this.status});

  final WordStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = switch (status) {
      // Main text color: white in the dark theme (black in the light one).
      WordStatus.newWord => colors.onSurface,
      WordStatus.learning => AppColors.statusLearning,
      WordStatus.review => AppColors.statusReview,
      WordStatus.learned => AppColors.statusLearned,
      // Light gray: quieter than a new word, but not the dark divider gray.
      WordStatus.known => colors.onSurfaceVariant,
    };

    return Container(
      width: 4,
      // A little shorter than the text block, so it reads as a mark.
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
