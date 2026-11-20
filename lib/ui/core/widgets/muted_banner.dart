import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';

/// Slides a "sound is off" banner in at the top whenever [mutedTaps] fires.
/// Sits above the navigator, so it shows over any screen or sheet.
class MutedBanner extends StatefulWidget {
  const MutedBanner({super.key, required this.mutedTaps, required this.child});

  final Stream<void> mutedTaps;
  final Widget child;

  @override
  State<MutedBanner> createState() => _MutedBannerState();
}

class _MutedBannerState extends State<MutedBanner>
    with SingleTickerProviderStateMixin {
  static const _visibleFor = Duration(milliseconds: 2500);

  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  );
  late final _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );
  late final StreamSubscription<void> _subscription;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _subscription = widget.mutedTaps.listen((_) => _show());
  }

  // A repeated tap keeps the banner up instead of flashing it again.
  void _show() {
    _controller.forward();
    _hideTimer?.cancel();
    _hideTimer = Timer(_visibleFor, _controller.reverse);
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _subscription.cancel();
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Stack(
      children: [
        widget.child,
        Positioned(
          top: MediaQuery.paddingOf(context).top + 8,
          left: 16,
          right: 16,
          child: IgnorePointer(
            child: FadeTransition(
              opacity: _curve,
              child: SlideTransition(
                // Reduce Motion: only the fade.
                position: Tween(
                  begin: Offset(0, reduceMotion ? 0 : -0.6),
                  end: Offset.zero,
                ).animate(_curve),
                child: const _BannerBody(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BannerBody extends StatelessWidget {
  const _BannerBody();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final palette = AppPalette.of(context);
    return Center(
      child: Semantics(
        liveRegion: true,
        child: Material(
          color: palette.subtleButton,
          elevation: 6,
          shadowColor: colors.shadow.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(AppIcons.speakerSlash, size: 20, color: colors.onSurface),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    AppStrings.of(context).volumeMuted,
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
