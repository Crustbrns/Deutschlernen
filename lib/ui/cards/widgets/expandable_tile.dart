import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';
import 'package:deutschlernen/ui/core/app_style.dart';

/// A row with a chevron on the left. [title] is always visible,
/// [details] appear under it when the row is expanded. Starts collapsed:
/// an open example translation would give away the hidden word translation.
class ExpandableTile extends StatefulWidget {
  const ExpandableTile({
    super.key,
    required this.title,
    this.details,
    this.trailing,
  });

  /// Side inset of the rows and their dividers: smaller than the card's
  /// (24), so the German text gets more room (user's choice).
  static const inset = 16.0;

  /// Width of [trailing], from the text to the card's edge: 10 gap, a 20
  /// icon and the 16 inset; the whole slot is the tap area (46).
  static const trailingWidth = 46.0;

  final Widget title;
  final Widget? details; // null = nothing to expand

  /// Fills [trailingWidth]; its icon should end [inset] from the right.
  final Widget? trailing;

  @override
  State<ExpandableTile> createState() => _ExpandableTileState();
}

class _ExpandableTileState extends State<ExpandableTile> {
  // Small: the chevron is a hint, the text matters (halved from 22 / 8).
  static const _chevronSize = 11.0;
  static const _chevronGap = 8.0; // was 4: text too close to the chevron

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
          // Top divider, inset on both sides. Painted over the row, not part
          // of its layout, so the row runs on to the card's edge.
          Positioned(
            top: 0,
            left: ExpandableTile.inset,
            right: ExpandableTile.inset,
            height: 1,
            child: ColoredBox(color: AppColors.divider(colors)),
          ),
          Padding(
            // Left inset only: the trailing slot runs to the card's edge,
            // so its tap area takes in the right inset too.
            padding: const EdgeInsets.only(left: ExpandableTile.inset),
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
                    SizedBox(
                      width: widget.trailing == null
                          ? ExpandableTile.inset
                          : ExpandableTile.trailingWidth,
                      child: widget.trailing,
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
                            right: ExpandableTile.inset,
                            bottom: 16,
                          ),
                          child: details,
                        )
                      : const SizedBox(width: double.infinity),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
