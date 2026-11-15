import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/word.dart';
import 'package:deutschlernen/ui/cards/widgets/word_card.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';

/// One word's card opened from the vocabulary search.
/// Same card as in learning, but without swipes and decision buttons.
class WordDetailScreen extends StatelessWidget {
  const WordDetailScreen({
    super.key,
    required this.word,
    required this.otherTranslations,
    required this.onSpeak,
  });

  final Word word;
  final List<String> otherTranslations;
  final ValueChanged<String> onSpeak;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: strings.close,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: WordCard(
                      word: word,
                      onSpeak: onSpeak,
                      otherTranslations: otherTranslations,
                      bottomBar: const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
