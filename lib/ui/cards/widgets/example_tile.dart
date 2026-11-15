import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/example_sentence.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/core/highlight.dart';

/// Base text styles of the rows: grey text, white bold word.
({TextStyle base, TextStyle bold}) _tileStyles(BuildContext context) {
  final colors = Theme.of(context).colorScheme;
  final base = TextStyle(
    fontSize: 17,
    height: 1.35,
    color: colors.onSurfaceVariant,
  );
  return (
    base: base,
    bold: base.copyWith(fontWeight: FontWeight.w700, color: colors.onSurface),
  );
}

/// A row with a chevron on the left that toggles between two states.
/// The content is built by [builder], which knows whether it is expanded.
class ExpandableTile extends StatefulWidget {
  const ExpandableTile({
    super.key,
    required this.initiallyExpanded,
    required this.builder,
    this.trailing,
  });

  final bool initiallyExpanded;
  final Widget Function(BuildContext context, bool expanded) builder;
  final Widget? trailing;

  @override
  State<ExpandableTile> createState() => _ExpandableTileState();
}

class _ExpandableTileState extends State<ExpandableTile> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.outlineVariant)),
      ),
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 16, 16, 0),
              child: Icon(
                _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 28,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                // AnimatedSize smooths the height change on toggle.
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  alignment: Alignment.topLeft,
                  child: widget.builder(context, _expanded),
                ),
              ),
            ),
            if (widget.trailing != null) widget.trailing!,
          ],
        ),
      ),
    );
  }
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
      initiallyExpanded: false,
      builder: (context, expanded) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(definition, style: styles.base),
          if (expanded && translation != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(translation, style: styles.base),
            )
          else
            const SizedBox(width: double.infinity),
        ],
      ),
    );
  }
}

/// Example sentence. Expanded shows the translation under it.
class ExampleTile extends StatelessWidget {
  const ExampleTile({
    super.key,
    required this.example,
    required this.initiallyExpanded,
    required this.onSpeak,
  });

  final ExampleSentence example;
  final bool initiallyExpanded;
  final ValueChanged<String> onSpeak;

  @override
  Widget build(BuildContext context) {
    final styles = _tileStyles(context);

    return ExpandableTile(
      initiallyExpanded: initiallyExpanded,
      trailing: IconButton(
        onPressed: () => onSpeak(stripMarkup(example.german)),
        icon: const Icon(Icons.play_arrow_outlined),
        color: AppColors.accentBlue,
      ),
      builder: (context, expanded) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              style: styles.base,
              children: markedSpans(example.german, styles.bold),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text.rich(
                TextSpan(
                  style: styles.base,
                  children: markedSpans(example.translation, styles.bold),
                ),
              ),
            )
          else
            const SizedBox(width: double.infinity),
        ],
      ),
    );
  }
}
