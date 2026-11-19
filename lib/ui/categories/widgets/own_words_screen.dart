import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/word.dart';
import 'package:deutschlernen/domain/models/word_status.dart';
import 'package:deutschlernen/ui/categories/widgets/add_own_word_sheet.dart';
import 'package:deutschlernen/ui/categories/widgets/word_list.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/widgets/round_icon_button.dart';
import 'package:deutschlernen/ui/core/widgets/readable_width.dart';

class OwnWordsScreen extends StatelessWidget {
  const OwnWordsScreen({
    super.key,
    required this.ownWords,
    required this.onWordSelected,
    required this.onSpeak,
    required this.stateOf,
    required this.progressChanges,
    required this.onAddWord,
  });

  final List<Word> Function() ownWords;
  final ValueChanged<Word> onWordSelected;
  final ValueChanged<String> onSpeak;
  final WordState Function(String wordId) stateOf;
  final Listenable progressChanges;
  final Future<void> Function(String german, String translation) onAddWord;

  Future<void> _showAddWord(BuildContext context) =>
      showAddOwnWordSheet(context: context, onSave: onAddWord);

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Scaffold(
      body: ReadableWidth(
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: Row(
                  children: [
                    RoundIconButton(
                      icon: AppIcons.arrowLeft,
                      tooltip: strings.back,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        strings.ownWords,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    RoundIconButton(
                      icon: AppIcons.plusCircle,
                      tooltip: strings.addWord,
                      onPressed: () => _showAddWord(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListenableBuilder(
                  listenable: progressChanges,
                  builder: (context, _) {
                    final words = ownWords();
                    if (words.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                        child: Text(
                          strings.noWordsYet,
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      );
                    }
                    return WordList(
                      words: words,
                      showLevel: false,
                      onWordSelected: onWordSelected,
                      onSpeak: onSpeak,
                      stateOf: stateOf,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
