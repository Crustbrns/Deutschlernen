import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/word.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';

/// Vocabulary tab: word search on top, below it the dictionaries.
/// While the search has text, the matching words replace the dictionaries.
/// The dictionary list is a placeholder; real ones will come from a repository.
class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({
    super.key,
    required this.words,
    required this.onWordSelected,
  });

  final List<Word> words;
  final ValueChanged<Word> onWordSelected;

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
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      // Scrolling the results hides the keyboard, as in iOS search.
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: results.length,
      itemBuilder: (context, i) {
        final word = results[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _Tile(
            selected: false,
            onTap: () {
              FocusScope.of(context).unfocus();
              widget.onWordSelected(word);
            },
            title: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${word.article} ',
                    style: TextStyle(color: AppColors.forArticle(word.article)),
                  ),
                  TextSpan(text: word.german),
                ],
              ),
            ),
            subtitle: Text(
              word.translation,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            trailing: Text(
              word.level,
              style: const TextStyle(color: AppColors.mutedText),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDictionaries(BuildContext context) {
    final strings = AppStrings.of(context);
    final colors = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
          child: Text(
            strings.dictionaries,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        for (var i = 0; i < _dictionaries.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _Tile(
              selected: i == _selected,
              onTap: () => setState(() => _selected = i),
              title: Text(_dictionaries[i]),
              trailing: Icon(
                i == _selected ? Icons.check_circle : Icons.circle_outlined,
                color: i == _selected
                    ? AppColors.accentBlue
                    : colors.onSurfaceVariant,
              ),
            ),
          ),
      ],
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

/// Rounded card row shared by dictionaries and search results.
class _Tile extends StatelessWidget {
  const _Tile({
    required this.selected,
    required this.onTap,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected
              ? AppColors.accentBlue
              : colors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
