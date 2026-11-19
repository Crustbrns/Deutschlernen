// material_ui doesn't re-export OverflowBoxFit.
import 'package:flutter/rendering.dart' show OverflowBoxFit;
import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/word.dart';
import 'package:deutschlernen/ui/cards/widgets/transcription_button.dart';
import 'package:deutschlernen/ui/core/app_style.dart';

/// "der Hund (die Hunde)" with the speaker button on its right, and the
/// transcription pill under it when [showTranscription] is on.
class WordTitle extends StatelessWidget {
  const WordTitle({
    super.key,
    required this.word,
    required this.showTranscription,
    required this.onSpeak,
    this.scale = 1,
    this.compact = false,
  });

  final Word word;
  final bool showTranscription;
  final ValueChanged<String> onSpeak;
  final double scale; // lookup card: 0.8
  final bool compact; // lookup card: tighter spacing

  /// How far the row reaches into the card's right inset.
  static const _speakerOverhang = 12.0;

  @override
  Widget build(BuildContext context) {
    void speak() => onSpeak(word.withArticle);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Word and plural left-aligned, speaker on the
        // right of the word. The row reaches into the
        // card's right inset (24 → 12): more room for
        // long words before they wrap.
        LayoutBuilder(
          builder: (context, constraints) => OverflowBox(
            alignment: Alignment.centerLeft,
            fit: OverflowBoxFit.deferToChild,
            minWidth: constraints.maxWidth + _speakerOverhang,
            maxWidth: constraints.maxWidth + _speakerOverhang,
            child: Row(
              children: [
                // "der Hund (die Hunde)" in one text: the
                // plural continues the line in the same
                // style; long ones wrap to the next line.
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      // Theme font, like the rest of the UI.
                      style: TextStyle(
                        fontSize: 32 * scale,
                        fontWeight: FontWeight.w700,
                        // Condensed: big bold text looks loose.
                        letterSpacing: -0.8,
                        height: 1.1,
                      ),
                      children: [
                        if (word.article.isNotEmpty)
                          TextSpan(
                            text: '${word.article} ',
                            style: TextStyle(
                              color: AppColors.forArticle(word.article),
                            ),
                          ),
                        TextSpan(text: word.german),
                        if (word.pluralWithArticle case final plural?)
                          TextSpan(text: ' ($plural)'),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8 * scale),
                TranscriptionButton(
                  transcription: null, // speaker icon only
                  scale: scale,
                  onPressed: speak,
                ),
              ],
            ),
          ),
        ),
        if (showTranscription && word.transcription.isNotEmpty) ...[
          SizedBox(height: compact ? 6 : 12),
          // Also speaks the word on tap.
          Align(
            alignment: Alignment.centerLeft,
            child: TranscriptionButton(
              transcription: word.transcription,
              scale: scale,
              onPressed: speak,
            ),
          ),
        ],
      ],
    );
  }
}
