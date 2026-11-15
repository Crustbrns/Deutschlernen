import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/word.dart';
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
    this.showLevel = true,
  });

  final List<Word> words;
  final ValueChanged<Word> onWordSelected;
  final ValueChanged<String> onSpeak; // German text-to-speech

  /// Off inside a level's own list, where every row would repeat it.
  final bool showLevel;

  @override
  Widget build(BuildContext context) {
    // A Column builds every row at once; fine for now, switch to a lazy list
    // if the dictionary grows to thousands of words.
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      // Scrolling hides the keyboard, as in iOS search.
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: GroupedCard(
        children: [
          for (final word in words)
            WordRow(
              word: word,
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

/// Level on top, "der Hund · die Hunde" in the middle, translation below,
/// left-aligned; play button on the right.
class WordRow extends StatelessWidget {
  const WordRow({
    super.key,
    required this.word,
    required this.onTap,
    required this.onSpeak,
    this.showLevel = true,
  });

  final Word word;
  final VoidCallback onTap;
  final VoidCallback onSpeak;
  final bool showLevel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final forms = [word.withArticle, ?word.pluralWithArticle].join(' · ');

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
            child: Row(
              children: [
                // Expanded: long words wrap instead of pushing the button out.
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showLevel) ...[
                        Text(
                          word.level,
                          style: const TextStyle(
                            color: AppColors.mutedText,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1.2, // tighter than the default line height
                          ),
                        ),
                        const SizedBox(height: 3),
                      ],
                      Text(
                        forms,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        word.translation,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                // Own tap target: plays the word without opening the card.
                PlayButton(onPressed: onSpeak),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
