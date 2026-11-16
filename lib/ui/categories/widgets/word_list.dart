import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/word.dart';
import 'package:deutschlernen/domain/models/word_status.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/core/widgets/grouped_card.dart';
import 'package:deutschlernen/ui/core/widgets/play_button.dart';
import 'package:deutschlernen/ui/categories/widgets/word_hero.dart';

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
    // Lazy: only the rows on screen are built (project rule), the
    // dictionary and its search results can be long.
    return CustomScrollView(
      // Scrolling hides the keyboard, as in iOS search.
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverPadding(
          // + bottom inset: the last row stays above the bottom bar / home
          // indicator.
          padding: EdgeInsets.fromLTRB(
            16,
            0,
            16,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          sliver: GroupedSliverList(
            itemCount: words.length,
            itemBuilder: (context, i) {
              final word = words[i];
              return WordRow(
                word: word,
                state: stateOf(word.id),
                showLevel: showLevel,
                onTap: () {
                  FocusScope.of(context).unfocus();
                  onWordSelected(word);
                },
                onSpeak: () => onSpeak(word.withArticle),
              );
            },
          ),
        ),
      ],
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
            // Tight sides: the strip sits close to the block's edge.
            padding: const EdgeInsets.fromLTRB(8, 8, 2, 8),
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
                        Text(caption, style: AppListText.caption(context)),
                        const SizedBox(height: AppListText.gap),
                        Text(forms, style: AppListText.title(colors)),
                        const SizedBox(height: AppListText.gap),
                        Text(
                          word.translation,
                          style: AppListText.subtitle(colors),
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
    final color = AppColors.forWordStatus(
      status,
      Theme.of(context).colorScheme,
    );

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
