import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';
import 'package:deutschlernen/ui/core/app_style.dart';

/// Speaker button next to the word, or the transcription pill under it;
/// both speak the word.
class TranscriptionButton extends StatelessWidget {
  const TranscriptionButton({
    super.key,
    required this.transcription,
    required this.onPressed,
    this.showIcon = true,
    this.scale = 1,
  });

  /// null = show only the speaker icon.
  final String? transcription;
  final bool showIcon; // false = transcription text only
  final VoidCallback onPressed;
  final double scale; // shrinks text, icon and padding together

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        // Icon only: a rounded square; with the transcription: a pill.
        shape: transcription == null
            ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
            : const StadiumBorder(),
        // 25% darker fill and border than the theme defaults.
        backgroundColor: AppColors.darken(colors.surfaceContainer, 0.25),
        side: BorderSide(color: AppColors.darken(colors.outlineVariant, 0.25)),
        foregroundColor: colors.onSurface,
        // All sizes are 75% of the previous ones.
        // Icon only: equal padding, so the button is square.
        padding: transcription == null
            ? EdgeInsets.all(10 * scale)
            : EdgeInsets.symmetric(horizontal: 15 * scale, vertical: 6 * scale),
        minimumSize: Size(0, 36 * scale),
        // Otherwise Material pads the button to 48px tall, eating the
        // compact spacing around it.
        tapTargetSize: scale < 1 ? MaterialTapTargetSize.shrinkWrap : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (transcription != null)
            Text(
              transcription!,
              style: TextStyle(
                fontSize: 16.5 * scale,
                fontWeight: FontWeight.w500,
              ),
            ),
          if (transcription != null && showIcon) SizedBox(width: 12 * scale),
          if (showIcon) Icon(AppIcons.speakerHigh, size: 19.5 * scale),
        ],
      ),
    );
  }
}
