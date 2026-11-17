import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';
import 'package:deutschlernen/ui/core/app_style.dart';

/// Speaker button next to the word ([transcription] null), or the
/// transcription pill under it; both speak the word.
class TranscriptionButton extends StatelessWidget {
  const TranscriptionButton({
    super.key,
    required this.transcription,
    required this.onPressed,
    this.scale = 1,
  });

  /// null = the speaker icon instead of the text.
  final String? transcription;
  final VoidCallback onPressed;
  final double scale; // shrinks text, icon and padding together

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final transcription = this.transcription; // local copy for null promotion

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
      child: transcription == null
          ? Icon(AppIcons.speakerHigh, size: 19.5 * scale)
          : Text(
              transcription,
              style: TextStyle(
                fontSize: 16.5 * scale,
                fontWeight: FontWeight.w500,
              ),
            ),
    );
  }
}
