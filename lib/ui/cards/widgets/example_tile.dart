import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';
import 'package:deutschlernen/domain/models/example_sentence.dart';
import 'package:deutschlernen/ui/cards/widgets/expandable_tile.dart';
import 'package:deutschlernen/ui/core/highlight.dart';
import 'package:deutschlernen/ui/core/widgets/play_button.dart';

/// Base text styles of the rows: white regular text, white bold word.
({TextStyle base, TextStyle bold}) _tileStyles(BuildContext context) {
  final colors = Theme.of(context).colorScheme;
  final base = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.2, // lines close together
    letterSpacing: -0.2, // condensed like the rest of the card
    // As white as the highlighted word; only weight sets that one apart.
    color: colors.onSurface,
  );
  return (base: base, bold: base.copyWith(fontWeight: FontWeight.w800));
}

/// German explanation of the word. Expanded shows its translation under it.
class DefinitionTile extends StatelessWidget {
  const DefinitionTile({
    super.key,
    required this.definition,
    required this.translation,
  });

  final String definition;
  final String? translation;

  @override
  Widget build(BuildContext context) {
    final styles = _tileStyles(context);
    final translation = this.translation; // local copy for null promotion

    return ExpandableTile(
      // Plain icon, not a button: the whole row is already tappable.
      // 48x48 matches the play buttons of the examples, so texts line up.
      trailing: SizedBox.square(
        dimension: 48,
        child: Icon(
          AppIcons.info,
          // Half transparent = ~50% darker on the dark card.
          color: Theme.of(context).colorScheme.onSurfaceVariant
              .withValues(alpha: 0.5),
        ),
      ),
      title: Text(definition, style: styles.base),
      details: translation == null
          ? null
          : Text(translation, style: styles.base),
    );
  }
}

/// Example sentence. Expanded shows the translation under it.
class ExampleTile extends StatelessWidget {
  const ExampleTile({super.key, required this.example, required this.onSpeak});

  final ExampleSentence example;
  final ValueChanged<String> onSpeak;

  @override
  Widget build(BuildContext context) {
    final styles = _tileStyles(context);

    return ExpandableTile(
      trailingVisualSize: PlayButton.size, // keeps the right edge aligned
      trailing: PlayButton(
        onPressed: () => onSpeak(stripMarkup(example.german)),
      ),
      title: Text.rich(
        TextSpan(
          style: styles.base,
          children: markedSpans(example.german, styles.bold),
        ),
      ),
      details: Text.rich(
        TextSpan(
          style: styles.base,
          children: markedSpans(example.translation, styles.bold),
        ),
      ),
    );
  }
}
