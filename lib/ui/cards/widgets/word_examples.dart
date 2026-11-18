import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/word.dart';
import 'package:deutschlernen/ui/cards/widgets/example_tile.dart';
import 'package:deutschlernen/ui/cards/widgets/expandable_tile.dart';
import 'package:deutschlernen/ui/core/app_style.dart';

/// The definition and the examples of the word card, full card width so the
/// rows' tap highlight spans it too.
class WordExamples extends StatelessWidget {
  const WordExamples({
    super.key,
    required this.word,
    required this.onSpeak,
    required this.lookup,
  });

  final Word word;
  final ValueChanged<String> onSpeak;
  final bool lookup;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Definition is the first row of the examples block.
        DefinitionTile(
          // "(f.) Der Zustand, ..." — gender mark only for nouns.
          definition: word.genderMark == null
              ? word.definition
              : '(${word.genderMark}) ${word.definition}',
          translation: word.definitionTranslation,
        ),
        for (final example in word.examples)
          ExampleTile(
            key: ValueKey(example.german),
            example: example,
            onSpeak: onSpeak,
          ),
        // Lookup: the last example ends at the card's bottom edge, so no
        // closing line and no extra room.
        if (!lookup) ...[
          // Closing line under the last row, same as the rows' top borders.
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ExpandableTile.inset,
            ),
            child: Divider(
              height: 1,
              thickness: 1,
              color: AppColors.divider(Theme.of(context).colorScheme),
            ),
          ),
          // Extra scroll room, so the last example can be lifted up away
          // from the card's bottom edge.
          const SizedBox(height: 100),
        ],
      ],
    );
  }
}
