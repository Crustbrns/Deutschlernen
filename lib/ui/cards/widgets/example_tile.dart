import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/example_sentence.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/core/highlight.dart';

/// Base text styles of the rows: grey text, white bold word.
({TextStyle base, TextStyle bold}) _tileStyles(BuildContext context) {
  final colors = Theme.of(context).colorScheme;
  final base = TextStyle(
    fontSize: 16,
    height: 1.35,
    color: colors.onSurfaceVariant,
  );
  return (
    base: base,
    bold: base.copyWith(fontWeight: FontWeight.w700, color: colors.onSurface),
  );
}

/// A row with a chevron on the left. [title] is always visible,
/// [details] appear under it when the row is expanded.
class ExpandableTile extends StatefulWidget {
  const ExpandableTile({
    super.key,
    required this.initiallyExpanded,
    required this.title,
    this.details,
    this.trailing,
  });

  final bool initiallyExpanded;
  final Widget title;
  final Widget? details; // null = nothing to expand
  final Widget? trailing;

  @override
  State<ExpandableTile> createState() => _ExpandableTileState();
}

class _ExpandableTileState extends State<ExpandableTile> {
  // Width of IconButton's default tap area; the info icon uses the same.
  static const _trailingWidth = 48.0;

  // Minimum time the highlight stays visible after a quick tap.
  static const _minHighlight = Duration(milliseconds: 150);
  static const _highlightFadeOut = Duration(milliseconds: 200);

  late bool _expanded = widget.initiallyExpanded;
  bool _highlighted = false;
  int _tapId = 0; // ignores stale timers when taps follow each other fast

  void _setHighlighted(bool value) {
    if (_highlighted != value) setState(() => _highlighted = value);
  }

  void _onTap() {
    final id = ++_tapId;
    setState(() {
      _expanded = !_expanded;
      _highlighted = true;
    });
    Future.delayed(_minHighlight, () {
      if (mounted && id == _tapId) _setHighlighted(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final details = widget.details;

    // InkWell is outermost, so the highlight covers the full card width.
    // The padding inside keeps text and divider aligned with the card content.
    return InkWell(
      onTap: _onTap,
      onTapDown: (_) => _setHighlighted(true), // finger held down
      onTapCancel: () => _setHighlighted(false), // turned into a scroll/swipe
      // Built-in ripple and highlight are off: on a quick tap inside
      // a scroll view they flash for a single frame. Our own layer below
      // is guaranteed to stay visible for _minHighlight.
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: _highlighted ? 1 : 0,
              // Appears instantly, fades out smoothly.
              duration: _highlighted ? Duration.zero : _highlightFadeOut,
              child: ColoredBox(
                color: colors.onSurface.withValues(alpha: 0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.cardInset),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: colors.outlineVariant)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    // No left inset, small gap to the text: more room.
                    // Top 16 + 22px icon centers it on the first text line.
                    padding: const EdgeInsets.fromLTRB(0, 16, 8, 0),
                    // One "down" icon rotated by half a turn instead of swapping
                    // two icons: swapping can't be animated, rotation can.
                    child: AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeOut,
                      child: const Icon(Icons.keyboard_arrow_down, size: 22),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // The trailing button is centered on the title only,
                        // so it stays in place when the details open below.
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                child: widget.title,
                              ),
                            ),
                            if (widget.trailing != null)
                              SizedBox(
                                width: _trailingWidth,
                                child: Center(child: widget.trailing),
                              ),
                          ],
                        ),
                        // AnimatedSize smooths the height change on toggle.
                        AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          alignment: Alignment.topLeft,
                          child: _expanded && details != null
                              ? Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: details,
                                )
                              : const SizedBox(width: double.infinity),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
      // Plain icon, not a button: the whole row is already tappable.
      // 48x48 matches the play buttons of the examples, so texts line up.
      trailing: SizedBox.square(
        dimension: 48,
        child: Icon(
          Icons.info_outline,
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
