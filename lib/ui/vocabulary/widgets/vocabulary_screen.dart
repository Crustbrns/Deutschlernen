import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/word.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/core/widgets/grouped_card.dart';
import 'package:deutschlernen/ui/core/widgets/play_button.dart';
import 'package:deutschlernen/ui/vocabulary/widgets/word_hero.dart';

/// Vocabulary tab: title, word search under it, below them the dictionaries.
/// While the search has text, the matching words replace the dictionaries.
/// The dictionary list is a placeholder; real ones will come from a repository.
class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({
    super.key,
    required this.words,
    required this.onWordSelected,
    required this.onSpeak,
  });

  final List<Word> words;
  final ValueChanged<Word> onWordSelected;
  final ValueChanged<String> onSpeak; // German text-to-speech

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  static const _dictionaries = ['A1', 'A2', 'B1', 'B2'];

  final _searchController = TextEditingController();
  int _selected = 0;

  @override
  void dispose() {
    _searchController.dispose(); // controllers hold listeners, free them
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final query = _searchController.text.trim();

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title stays above the search, visible in both states.
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
            child: Text(
              strings.tabVocabulary,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _SearchField(
              controller: _searchController,
              hint: strings.searchHint,
              // The controller already holds the text; setState only rebuilds.
              onChanged: () => setState(() {}),
            ),
          ),
          Expanded(
            child: query.isEmpty
                ? _buildDictionaries(context)
                : _buildResults(context, query),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(BuildContext context, String query) {
    final strings = AppStrings.of(context);
    final colors = Theme.of(context).colorScheme;
    final results = widget.words.where((w) => w.matches(query)).toList();

    if (results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 32),
        child: Text(
          strings.nothingFound,
          style: TextStyle(color: colors.onSurfaceVariant),
        ),
      );
    }

    // A Column builds every row at once; fine for now, switch to a lazy list
    // if the dictionary grows to thousands of words.
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      // Scrolling the results hides the keyboard, as in iOS search.
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: GroupedCard(
        children: [
          for (final word in results)
            _ResultRow(
              word: word,
              onTap: () {
                FocusScope.of(context).unfocus();
                widget.onWordSelected(word);
              },
              onSpeak: () => widget.onSpeak(word.withArticle),
            ),
        ],
      ),
    );
  }

  Widget _buildDictionaries(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: GroupedCard(
        children: [
          for (var i = 0; i < _dictionaries.length; i++)
            ListTile(
              // 16 = divider indent, so text and lines start at one edge.
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: Text(_dictionaries[i]),
              // In a shared card a row can't have its own outline, so the
              // selection is shown by the check only.
              trailing: Icon(
                i == _selected ? Icons.check_circle : Icons.circle_outlined,
                color: i == _selected
                    ? AppColors.accentBlue
                    : colors.onSurfaceVariant,
              ),
              onTap: () => setState(() => _selected = i),
            ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: color),
    );

    return TextField(
      controller: controller,
      onChanged: (_) => onChanged(),
      autocorrect: false,
      enableSuggestions: false,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        // Clear button only when there is something to clear.
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  controller.clear();
                  onChanged();
                },
              ),
        filled: true,
        fillColor: AppColors.card,
        border: border(colors.outlineVariant.withValues(alpha: 0.4)),
        enabledBorder: border(colors.outlineVariant.withValues(alpha: 0.4)),
        focusedBorder: border(AppColors.accentBlue),
      ),
    );
  }
}

/// Search result: level on top, "der Hund · die Hunde" in the middle,
/// translation below, left-aligned; play button on the right.
class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.word,
    required this.onTap,
    required this.onSpeak,
  });

  final Word word;
  final VoidCallback onTap;
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final forms = [word.withArticle, ?word.pluralWithArticle].join(' · ');

    // No own background: the row sits inside the shared results card.
    // Hero: the opened card grows out of this row and shrinks back into it.
    return WordHero(
      wordId: word.id,
      // Transparent Material: InkWell needs one, and the row is moved out
      // of the results card while the hero flies.
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
