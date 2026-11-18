import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/word.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';

/// Mode 2: type the translation (or the German word) and check it.
class WriteAnswerPanel extends StatefulWidget {
  const WriteAnswerPanel({super.key, required this.word});

  final Word word;

  @override
  State<WriteAnswerPanel> createState() => _WriteAnswerPanelState();
}

class _WriteAnswerPanelState extends State<WriteAnswerPanel> {
  final _controller = TextEditingController();

  /// null = not checked yet.
  bool? _isCorrect;

  @override
  void didUpdateWidget(WriteAnswerPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The language changed: the old check no longer applies.
    if (oldWidget.word.translation != widget.word.translation) {
      _isCorrect = null;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _check() {
    if (_controller.text.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() => _isCorrect = widget.word.accepts(_controller.text));
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final colors = Theme.of(context).colorScheme;
    final isCorrect = _isCorrect;

    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color),
    );
    final resultColor = switch (isCorrect) {
      true => AppColors.correct,
      false => AppColors.wrong,
      null => null,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _check(),
          // Editing starts a new attempt, so the old verdict disappears.
          onChanged: (_) {
            if (_isCorrect != null) setState(() => _isCorrect = null);
          },
          decoration: InputDecoration(
            hintText: strings.answerHint,
            filled: true,
            fillColor: AppPalette.of(context).subtleButton,
            border: border(Colors.transparent),
            enabledBorder: border(resultColor ?? Colors.transparent),
            focusedBorder: border(resultColor ?? AppColors.yellow),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _check,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.yellow,
            foregroundColor: AppColors.onYellow,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(strings.checkAnswer),
        ),
        if (isCorrect != null) ...[
          const SizedBox(height: 12),
          if (isCorrect)
            Text(
              strings.correct,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.correct,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            )
          else ...[
            Text(
              strings.wrongAnswer,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
            ),
            const SizedBox(height: 4),
            // The right answer, in the same style as the hidden translation.
            Text(
              widget.word.translation,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ],
      ],
    );
  }
}
