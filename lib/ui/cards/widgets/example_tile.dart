import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';
import 'package:deutschlernen/domain/models/example_sentence.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
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

/// A row with a chevron on the left. [title] is always visible,
/// [details] appear under it when the row is expanded. Starts collapsed:
/// an open example translation would give away the hidden word translation.
class ExpandableTile extends StatefulWidget {
  const ExpandableTile({
    super.key,
    required this.title,
    this.details,
    this.trailing,
    this.trailingVisualSize = 24,
  });

  final Widget title;
  final Widget? details; // null = nothing to expand
  final Widget? trailing;

  /// Visible size of [trailing] (icon or circle). Used to line its right
  /// edge up with the card inset.
  final double trailingVisualSize;

  @override
  State<ExpandableTile> createState() => _ExpandableTileState();
}

class _ExpandableTileState extends State<ExpandableTile> {
  // Width of IconButton's default tap area; the info icon uses the same.
  static const _trailingWidth = 48.0;
  // Small: the chevron is a hint, the text matters (halved from 22 / 8).
  static const _chevronSize = 11.0;
  static const _chevronGap = 4.0;

  // Minimum time the highlight stays visible after a quick tap.
  static const _minHighlight = Duration(milliseconds: 150);
  static const _highlightFadeOut = Duration(milliseconds: 200);

  bool _expanded = false;
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
                border: Border(
                  top: BorderSide(color: AppColors.divider(colors)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Chevron and trailing button are centered on the title
                  // only, so they stay in place when the details open below.
                  Row(
                    children: [
                      Padding(
                        // No left inset, small gap to the text: more room.
                        padding: const EdgeInsets.only(right: _chevronGap),
                        // One "down" icon rotated by half a turn instead of
                        // swapping two icons: rotation can be animated.
                        child: AnimatedRotation(
                          turns: _expanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          child: const Icon(
                            AppIcons.caretDownBold,
                            size: _chevronSize,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: widget.title,
                        ),
                      ),
                      if (widget.trailing != null)
                        SizedBox(
                          width: _trailingWidth,
                          // The visible icon is centered in a 48px slot, so there is
                          // (48 - size) / 2 of empty space on its right. Shifting by
                          // that puts it at the same distance from the card edge as
                          // the chevron on the left (cardInset).
                          child: Transform.translate(
                            offset: Offset(
                              (_trailingWidth - widget.trailingVisualSize) / 2,
                              0,
                            ),
                            child: Center(child: widget.trailing),
                          ),
                        ),
                    ],
                  ),
                  // AnimatedSize smooths the height change on toggle.
                  AnimatedSize(
                    duration: const Duration(milliseconds: 170),
                    curve: Curves.easeOut,
                    alignment: Alignment.topLeft,
                    child: _expanded && details != null
                        ? Padding(
                            // Left inset lines the details up with the title.
                            padding: const EdgeInsets.only(
                              left: _chevronSize + _chevronGap,
                              bottom: 16,
                            ),
                            child: details,
                          )
                        : const SizedBox(width: double.infinity),
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
