import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';
import 'package:deutschlernen/domain/models/word.dart';
import 'package:deutschlernen/domain/models/word_status.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/core/widgets/grouped_card.dart';
import 'package:deutschlernen/ui/core/widgets/level_row.dart';
import 'package:deutschlernen/ui/core/widgets/round_icon_button.dart';
import 'package:deutschlernen/ui/categories/widgets/level_words_screen.dart';
import 'package:deutschlernen/ui/categories/widgets/word_list.dart';

/// Categories tab: title, word search under it, below them the levels
/// (A1, A2, …) with their word counts; a level opens its words.
/// While the search has text, the matching words replace the levels.
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({
    super.key,
    required this.words,
    required this.onWordSelected,
    required this.onSearchResultSelected,
    required this.onSpeak,
    required this.stateOf,
    required this.progressChanges,
  });

  final List<Word> words;

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
              strings.tabCategories,
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
      onWordSelected: widget.onSearchResultSelected,
      onSpeak: widget.onSpeak,
      stateOf: widget.stateOf,
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
          // A pushed route doesn't rebuild with the tab; listen directly.
          child: ListenableBuilder(
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
      ),
    );
  }

  Widget _buildLevels(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      // + bottom inset: the last row stays reachable above the blurred bar.
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        24 + MediaQuery.paddingOf(context).bottom,
      ),
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
    // Seen = the user decided on it: "already know" or started learning.
    final seen = words
        .where((w) => widget.stateOf(w.id).status != WordStatus.newWord)
        .length;
    final percent = words.isEmpty ? 0 : (seen * 100 / words.length).round();
    final muted = AppPalette.of(context).mutedText;
    // Light theme: 50% lighter, like the count (user's choice).
    Color soft(Color c) =>
        colors.brightness == Brightness.light ? AppColors.lighten(c, 0.5) : c;

    return LevelRow(
      level: level,
      wordCount: words.length,
      onTap: () => _openLevel(level, words),
      // Share of the level's words already seen, a bit bigger than the
      // count: the row's progress at a glance (user's choice).
      // Non-breaking space: "40 %" never splits across lines.
      trailing: Text(
        '$percent\u00A0%',
        style: AppListText.subtitle(colors).copyWith(
          fontSize: 17,
          // Light gray: between the main text and the muted count.
          color: soft(Color.lerp(colors.onSurface, muted, 0.5)!),
        ),
      ),
    );
  }
}

/// Pill-shaped search field, iOS-style. Idle: no outline, full width.
/// Active (focused or holding text): blue outline while focused, and the
/// field shrinks to make room for a round close button on its right.
/// The button clears the text, hides the keyboard and returns the idle look.
class _SearchField extends StatefulWidget {
  const _SearchField({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final VoidCallback onChanged;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Rebuild on focus changes: the outline and the button depend on it.
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  // Also active with text but no focus (e.g. after scrolling the results
  // hid the keyboard), so the text can still be cleared.
  bool get _isActive =>
      _focusNode.hasFocus || widget.controller.text.isNotEmpty;

  void _close() {
    widget.controller.clear();
    _focusNode.unfocus();
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final pill = OutlineInputBorder(
      borderRadius: BorderRadius.circular(100), // fully round ends
      borderSide: BorderSide.none,
    );
    // Quiet grays, so the search doesn't draw attention from the content:
    // the outline is the divider color, hint and close icon a bit more
    // visible to stay readable.
    final colors = Theme.of(context).colorScheme;
    final gray = AppColors.divider(colors);
    final lightGray = AppColors.quietText(colors);

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            onChanged: (_) => widget.onChanged(),
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(color: lightGray),
              prefixIcon: const Icon(AppIcons.magnifyingGlass),
              filled: true,
              fillColor: AppPalette.of(context).card,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: pill,
              enabledBorder: pill,
              focusedBorder: pill.copyWith(borderSide: BorderSide(color: gray)),
            ),
          ),
        ),
        // AnimatedSize: the field shrinks/grows smoothly as the button
        // appears/disappears instead of jumping.
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: _isActive
              ? Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: RoundIconButton(
                    icon: AppIcons.x,
                    tooltip: AppStrings.of(context).close,
                    iconColor: lightGray,
                    onPressed: _close,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
