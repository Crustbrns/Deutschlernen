import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';
import 'package:deutschlernen/domain/models/word.dart';
import 'package:deutschlernen/domain/models/word_status.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/widgets/round_icon_button.dart';
import 'package:deutschlernen/ui/categories/widgets/word_list.dart';

/// Words of one level (A1, A2, …), opened from the Categories tab.
class LevelWordsScreen extends StatelessWidget {
  const LevelWordsScreen({
    super.key,
    required this.level,
    required this.words,
    required this.onWordSelected,
    required this.onSpeak,
    required this.stateOf,
  });

  final String level;
  final List<Word> words; // already filtered to [level]
  final ValueChanged<Word> onWordSelected;
  final ValueChanged<String> onSpeak;
  final WordState Function(String wordId) stateOf;

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
              // 4 less around the back button: its tap area adds 4.
              padding: const EdgeInsets.fromLTRB(12, 12, 16, 8),
              child: Row(
                children: [
                  RoundIconButton(
                    icon: AppIcons.arrowLeft,
                    tooltip: strings.back,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
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
                      stateOf: stateOf,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
