import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/word.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/widgets/round_icon_button.dart';
import 'package:deutschlernen/ui/vocabulary/widgets/word_list.dart';

/// Words of one level (A1, A2, …), opened from the vocabulary tab.
class LevelWordsScreen extends StatelessWidget {
  const LevelWordsScreen({
    super.key,
    required this.level,
    required this.words,
    required this.onWordSelected,
    required this.onSpeak,
  });

  final String level;
  final List<Word> words; // already filtered to [level]
  final ValueChanged<Word> onWordSelected;
  final ValueChanged<String> onSpeak;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  RoundIconButton(
                    icon: Icons.arrow_back,
                    tooltip: strings.back,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 12),
                  Text(level, style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
            ),
            Expanded(
              child: words.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                      child: Text(
                        strings.noWordsYet,
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    )
                  : WordList(
                      words: words,
                      // Level is in the title already.
                      showLevel: false,
                      onWordSelected: onWordSelected,
                      onSpeak: onSpeak,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
