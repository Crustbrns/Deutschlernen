import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/word.dart';
import 'package:deutschlernen/domain/models/word_status.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';
import 'package:deutschlernen/ui/core/widgets/grouped_card.dart';
import 'package:deutschlernen/ui/core/widgets/level_row.dart';
import 'package:deutschlernen/ui/core/widgets/round_icon_button.dart';
import 'package:deutschlernen/ui/core/widgets/search_field.dart';
import 'package:deutschlernen/ui/core/widgets/tab_page.dart';
import 'package:deutschlernen/ui/categories/widgets/add_own_word_sheet.dart';
import 'package:deutschlernen/ui/categories/widgets/level_words_screen.dart';
import 'package:deutschlernen/ui/categories/widgets/word_list.dart';

/// Categories tab: title, word search, levels (A1, A2, …), and a separate
/// Own words category. While the search has text, matching words replace
/// the categories.
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({
    super.key,
    required this.words,
    required this.wordsByLevel,
    required this.ownWords,
    required this.ownWordsSeenShare,
    required this.seenShare,
    required this.onOwnWordsSelected,
    required this.onAddOwnWord,
    required this.onWordSelected,
    required this.onSearchResultSelected,
    required this.onSpeak,
    required this.stateOf,
    required this.progressChanges,
  });

  /// All words, for the search.
  final List<Word> words;

  /// Words of each level, in display order.
  final Map<String, List<Word>> wordsByLevel;

  /// User-created words shown in their separate category.
  final List<Word> ownWords;

  /// Share (0–1) of own words already seen: known or started.
  final double ownWordsSeenShare;

  /// Share (0–1) of a level's words already seen: known or started.
  final double Function(String level) seenShare;

  final VoidCallback onOwnWordsSelected;
  final Future<void> Function(String german, String translation) onAddOwnWord;

  /// Word opened from a level's list.
  final ValueChanged<Word> onWordSelected;

  /// Word opened from the search results: counts as a lookup.
  final ValueChanged<Word> onSearchResultSelected;
  final ValueChanged<String> onSpeak; // German text-to-speech

  /// Learning status of a word, for the strip and caption next to it.
  final WordState Function(String wordId) stateOf;

  /// Fires when word progress changes (e.g. a reset from the word card),
  /// so the pushed level list redraws its statuses.
  final Listenable progressChanges;

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  /// What the results show: set by the field once typing pauses.
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final query = _query;

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title stays above the search, visible in both states.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TabTitle(strings.tabCategories),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SearchField(
              hint: strings.searchHint,
              onSearch: (query) => setState(() => _query = query),
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
      onWordSelected: widget.onSearchResultSelected,
      onSpeak: widget.onSpeak,
      stateOf: widget.stateOf,
    );
  }

  void _openLevel(String level, List<Word> words) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        // A pushed route doesn't rebuild with the tab; listen directly.
        builder: (_) => ListenableBuilder(
          listenable: widget.progressChanges,
          builder: (_, _) => LevelWordsScreen(
            level: level,
            words: words,
            onWordSelected: widget.onWordSelected,
            onSpeak: widget.onSpeak,
            stateOf: widget.stateOf,
          ),
        ),
      ),
    );
  }

  Widget _buildLevels(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 0, 16, AppSizes.bottomPadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GroupedCard(
            children: [
              for (final MapEntry(key: level, value: words)
                  in widget.wordsByLevel.entries)
                _buildLevelRow(level, words, colors),
            ],
          ),
          const SizedBox(height: 12),
          GroupedCard(children: [_buildOwnWordsRow(context)]),
        ],
      ),
    );
  }

  Widget _buildOwnWordsRow(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final percent = (widget.ownWordsSeenShare * 100).round();
    return InkWell(
      onTap: widget.onOwnWordsSelected,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              AppIcons.pencilSimple,
              size: 30,
              color: AppPalette.of(context).accentText,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.of(context).ownWords,
                    style: AppListText.title(colors),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.of(context).wordCount(widget.ownWords.length),
                    style: AppListText.subtitle(colors).copyWith(
                      color: AppPalette.of(context).secondaryText,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            RoundIconButton(
              icon: AppIcons.plusCircle,
              tooltip: AppStrings.of(context).addWord,
              onPressed: () => showAddOwnWordSheet(
                context: context,
                onSave: widget.onAddOwnWord,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$percent\u00A0%',
              style: AppListText.subtitle(colors).copyWith(
                fontSize: 17,
                color: AppPalette.of(context).levelPercent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelRow(String level, List<Word> words, ColorScheme colors) {
    final percent = (widget.seenShare(level) * 100).round();
    return LevelRow(
      level: level,
      wordCount: words.length,
      onTap: () => _openLevel(level, words),
      // Share of the level's words already seen, a bit bigger than the
      // count: the row's progress at a glance (user's choice).
      // Non-breaking space: "40 %" never splits across lines.
      trailing: Text(
        '$percent\u00A0%',
        style: AppListText.subtitle(colors)
            .copyWith(fontSize: 17, color: AppPalette.of(context).levelPercent),
      ),
    );
  }
}
