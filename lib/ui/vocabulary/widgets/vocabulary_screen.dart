import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/word.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/core/widgets/grouped_card.dart';
import 'package:deutschlernen/ui/vocabulary/widgets/level_words_screen.dart';
import 'package:deutschlernen/ui/vocabulary/widgets/word_list.dart';

/// Vocabulary tab: title, word search under it, below them the levels
/// (A1, A2, …) with their word counts; a level opens its words.
/// While the search has text, the matching words replace the levels.
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
  final _searchController = TextEditingController();

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
                ? _buildLevels(context)
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

    return WordList(
      words: results,
      onWordSelected: widget.onWordSelected,
      onSpeak: widget.onSpeak,
    );
  }

  void _openLevel(String level, List<Word> words) {
    final strings = AppStrings.of(context);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        // A pushed route is not under the shell's AppStringsScope,
        // so the scope is provided again.
        builder: (_) => AppStringsScope(
          strings: strings,
          child: LevelWordsScreen(
            level: level,
            words: words,
            onWordSelected: widget.onWordSelected,
            onSpeak: widget.onSpeak,
          ),
        ),
      ),
    );
  }

  Widget _buildLevels(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: GroupedCard(
        children: [
          for (final level in Word.levels)
            _buildLevelRow(
              level,
              widget.words.where((w) => w.level == level).toList(),
              colors,
            ),
        ],
      ),
    );
  }

  Widget _buildLevelRow(String level, List<Word> words, ColorScheme colors) {
    return ListTile(
      // 16 = divider indent, so text and lines start at one edge.
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(level),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${words.length}',
            style: const TextStyle(color: AppColors.mutedText),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
        ],
      ),
      onTap: () => _openLevel(level, words),
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
