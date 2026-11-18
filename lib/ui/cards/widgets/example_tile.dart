import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/domain/models/example_sentence.dart';
import 'package:deutschlernen/ui/cards/widgets/expandable_tile.dart';
import 'package:deutschlernen/ui/core/highlight.dart';
import 'package:deutschlernen/ui/core/widgets/play_button.dart';

/// Text styles of the rows. German: white, the marked word yellow (a
/// marker in the light theme). Translations under it: gray, their marked
/// word white and bold, so the German line stays in focus.
({TextStyle base, TextStyle mark, TextStyle detail, TextStyle detailMark})
_tileStyles(BuildContext context) {
  final colors = Theme.of(context).colorScheme;
  final palette = AppPalette.of(context);
  final base = TextStyle(
    fontSize: 16, // 17 wrapped long German sentences into too many lines
    fontWeight: FontWeight.w400,
    height: 1.2, // lines close together
    letterSpacing: -0.2, // condensed like the rest of the card
    color: colors.onSurface,
  );
  final detail = base.copyWith(color: palette.mutedText);
  return (
    base: base,
    mark: base.copyWith(
      fontWeight: FontWeight.w700,
      color: palette.markText,
      backgroundColor: palette.markFill,
    ),
    detail: detail,
    detailMark: detail.copyWith(
      fontWeight: FontWeight.w700,
      color: colors.onSurface,
    ),
  );
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
      // Plain icon, not a button: the whole row is already tappable. Ends
      // at the row inset, like the play buttons, so texts line up.
      trailing: Padding(
        padding: const EdgeInsets.only(right: ExpandableTile.inset),
        child: Align(
          alignment: Alignment.centerRight,
          child: Icon(
            AppIcons.info,
            // Half transparent = ~50% darker on the dark card.
            color: Theme.of(context).colorScheme.onSurfaceVariant
                .withValues(alpha: 0.5),
          ),
        ),
      ),
      title: Text(definition, style: styles.base),
      details: translation == null
          ? null
          : Text(translation, style: styles.detail),
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
      trailing: PlayButton.rowEnd(
        onPressed: () => onSpeak(stripMarkup(example.german)),
      ),
      title: Text.rich(
        TextSpan(
          style: styles.base,
          children: markedSpans(example.german, styles.mark),
        ),
      ),
      details: Text.rich(
        TextSpan(
          style: styles.detail,
          children: markedSpans(example.translation, styles.detailMark),
        ),
      ),
    );
  }
}
