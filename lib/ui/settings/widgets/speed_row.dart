import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/app_settings.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/core/widgets/menu_row.dart';
import 'package:deutschlernen/ui/settings/view_models/settings_view_model.dart';

/// Speech rate: a MenuRow header with a slider and slow / fast under it.
class SpeedRow extends StatefulWidget {
  const SpeedRow({super.key, required this.settings});

  final SettingsViewModel settings;

  @override
  State<SpeedRow> createState() => _SpeedRowState();
}

class _SpeedRowState extends State<SpeedRow> {
  /// Value while the finger is on the slider. Kept here, not in the view
  /// model: notifying it on every frame rebuilt the whole MaterialApp (it
  /// listens to settings for the theme), and the drag stuttered.
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final settings = widget.settings;
    final strings = AppStrings.of(context);
    final palette = AppPalette.of(context);
    final hint = MenuRow.hintStyle(context, soft: true).copyWith(fontSize: 13);

    return Column(
      children: [
        // Not tappable itself: the slider below is the control.
        IgnorePointer(
          child: MenuRow(
            compact: true,
            title: strings.speechRate,
            subtitle: strings.speechRateHint,
            onTap: () {}, // keeps the row in its enabled colors
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6,
            activeTrackColor: AppColors.yellow,
            inactiveTrackColor: palette.sliderTrack,
            // No ripple halo: the white pill thumb is enough feedback.
            overlayColor: Colors.transparent,
            thumbShape: const _PillThumbShape(),
            // Plain round track: no M3 gap and stop dot around the thumb.
            trackShape: const RoundedRectSliderTrackShape(),
            showValueIndicator: ShowValueIndicator.never,
            // Track from 16 to 16, level with the row text and dividers
            // (the default inset leaves room for the ripple halo).
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Slider(
            value: _dragValue ?? settings.speechRate,
            min: AppSettings.minSpeechRate,
            max: AppSettings.maxSpeechRate,
            onChanged: (v) => setState(() => _dragValue = v),
            // Released: save it and say a sample word.
            onChangeEnd: (v) {
              _dragValue = null;
              settings.commitSpeechRate(v);
            },
          ),
        ),
        Padding(
          // Same 16 edges as the track.
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(strings.speedSlow, style: hint),
              Text(strings.speedFast, style: hint),
            ],
          ),
        ),
      ],
    );
  }
}

/// White rounded-rectangle slider thumb (wider than tall), with the same soft
/// shadow as the AppSwitch thumb.
class _PillThumbShape extends SliderComponentShape {
  const _PillThumbShape();

  static const _size = Size(30, 20);

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => _size;

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final pill = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: _size.width, height: _size.height),
      Radius.circular(_size.height / 2),
    );
    final canvas = context.canvas;
    canvas.drawRRect(
      pill.shift(const Offset(0, 1)),
      Paint()
        ..color = AppColors.switchThumbShadow
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawRRect(pill, Paint()..color = AppColors.onAccent);
  }
}
