import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/word.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';

/// How the user checks that they know the word.
enum AnswerMode { show, write, choice }

/// The three mode buttons, shown right above the examples.
class AnswerModeBar extends StatelessWidget {
  const AnswerModeBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final AnswerMode selected;
  final ValueChanged<AnswerMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return SegmentedButton<AnswerMode>(
      showSelectedIcon: false,
      selected: {selected},
      onSelectionChanged: (modes) => onChanged(modes.first),
      style: SegmentedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        textStyle: const TextStyle(fontSize: 13.5),
      ),
      segments: [
        ButtonSegment(
          value: AnswerMode.show,
          icon: const Icon(Icons.visibility_outlined, size: 18),
          label: Text(strings.modeShow, maxLines: 1),
        ),
        ButtonSegment(
          value: AnswerMode.write,
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: Text(strings.modeWrite, maxLines: 1),
        ),
        ButtonSegment(
          value: AnswerMode.choice,
          icon: const Icon(Icons.checklist, size: 18),
          label: Text(strings.modeChoice, maxLines: 1),
        ),
      ],
    );
  }
}

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
            fillColor: AppColors.subtleButton,
            border: border(Colors.transparent),
            enabledBorder: border(resultColor ?? Colors.transparent),
            focusedBorder: border(resultColor ?? AppColors.accentBlue),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _check,
          style: FilledButton.styleFrom(
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
            // The right answer, in the same font as the hidden translation.
            Text(
              widget.word.translation,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppFonts.translation,
                fontSize: 28,
                fontWeight: FontWeight.w600,
                fontVariations: AppFonts.translationVariations,
              ),
            ),
          ],
        ],
      ],
    );
  }
}

/// Mode 3: pick the right translation out of four.
class ChoiceAnswerPanel extends StatefulWidget {
  const ChoiceAnswerPanel({
    super.key,
    required this.word,
    required this.otherTranslations,
  });

  final Word word;

  /// Translations of other words, used as wrong options.
  final List<String> otherTranslations;

  @override
  State<ChoiceAnswerPanel> createState() => _ChoiceAnswerPanelState();
}

class _ChoiceAnswerPanelState extends State<ChoiceAnswerPanel> {
  String? _picked;

  @override
  void didUpdateWidget(ChoiceAnswerPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The language changed: the options are different now.
    if (oldWidget.word.translation != widget.word.translation) _picked = null;
  }

  /// Correct answer plus up to 3 wrong ones. The seed is the word, so the
  /// order stays the same when the card rebuilds.
  List<String> _options() {
    final random = math.Random(widget.word.id.hashCode);
    final wrong = widget.otherTranslations
        .where((text) => text.isNotEmpty && text != widget.word.translation)
        .toSet()
        .toList()
      ..shuffle(random);
    return [widget.word.translation, ...wrong.take(3)]..shuffle(random);
  }

  @override
  Widget build(BuildContext context) {
    final picked = _picked;
    final answered = picked != null;
    final correct = widget.word.translation;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final option in _options())
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _ChoiceOption(
              text: option,
              state: !answered
                  ? _OptionState.idle
                  : option == correct
                  ? _OptionState.correct
                  : option == picked
                  ? _OptionState.wrong
                  : _OptionState.dimmed,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
          ),
      ],
    );
  }
}

enum _OptionState { idle, correct, wrong, dimmed }

class _ChoiceOption extends StatelessWidget {
  const _ChoiceOption({
    required this.text,
    required this.state,
    required this.onTap,
  });

  final String text;
  final _OptionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final accent = switch (state) {
      _OptionState.correct => AppColors.correct,
      _OptionState.wrong => AppColors.wrong,
      _ => null,
    };
    final icon = switch (state) {
      _OptionState.correct => Icons.check_circle,
      _OptionState.wrong => Icons.cancel,
      _ => null,
    };

    return AnimatedOpacity(
      opacity: state == _OptionState.dimmed ? 0.45 : 1,
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: accent?.withValues(alpha: 0.14) ?? AppColors.subtleButton,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: accent ?? colors.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 17,
                      color: accent ?? colors.onSurface,
                    ),
                  ),
                ),
                if (icon != null) Icon(icon, color: accent, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
