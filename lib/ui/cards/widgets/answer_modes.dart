import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';
import 'package:deutschlernen/domain/models/word.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';

/// How the user checks that they know the word.
enum AnswerMode { show, write, choice }

/// The three mode buttons, shown right above the examples.
/// The first one is the eye: it is both the mode and the action (it reveals
/// the translation), so there is no separate "show" switch.
class AnswerModeBar extends StatelessWidget {
  const AnswerModeBar({
    super.key,
    required this.selected,
    required this.onPressed,
  });

  /// null = nothing is open yet.
  final AnswerMode? selected;
  final ValueChanged<AnswerMode> onPressed;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Row(
      children: [
        Expanded(
          child: _ModeButton(
            icon: AppIcons.eye,
            label: strings.modeShow,
            isSelected: selected == AnswerMode.show,
            onPressed: () => onPressed(AnswerMode.show),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ModeButton(
            icon: AppIcons.pencilSimple,
            label: strings.modeWrite,
            isSelected: selected == AnswerMode.write,
            onPressed: () => onPressed(AnswerMode.write),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ModeButton(
            icon: AppIcons.listChecks,
            label: strings.modeChoice,
            isSelected: selected == AnswerMode.choice,
            onPressed: () => onPressed(AnswerMode.choice),
          ),
        ),
      ],
    );
  }
}

/// Only the eye, no label: for new words, where there is nothing to test
/// yet, just a translation to peek at. The card replaces it with the
/// translation once tapped.
class RevealButton extends StatelessWidget {
  const RevealButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  static const size = 64.0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      // Slightly darker than the other neutral buttons; no outline.
      color: AppColors.darken(AppPalette.of(context).subtleButton, 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox.square(
          dimension: size,
          child: Icon(AppIcons.eye, size: 28, color: colors.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = isSelected ? AppColors.accentBlue : colors.onSurfaceVariant;

    return Material(
      color: isSelected
          ? AppColors.accentBlue.withValues(alpha: 0.14)
          : AppPalette.of(context).subtleButton,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isSelected
              ? AppColors.accentBlue
              : colors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: color),
              ),
            ],
          ),
        ),
      ),
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
            fillColor: AppPalette.of(context).subtleButton,
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
      _OptionState.correct => AppIcons.checkCircle,
      _OptionState.wrong => AppIcons.xCircle,
      _ => null,
    };

    return AnimatedOpacity(
      opacity: state == _OptionState.dimmed ? 0.45 : 1,
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: accent?.withValues(alpha: 0.14) ?? AppPalette.of(context).subtleButton,
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
