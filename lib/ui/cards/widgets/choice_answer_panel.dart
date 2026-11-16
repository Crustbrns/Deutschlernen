import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/word.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';
import 'package:deutschlernen/ui/core/app_style.dart';

/// Mode 3: pick the right translation out of four.
class ChoiceAnswerPanel extends StatefulWidget {
  const ChoiceAnswerPanel({
    super.key,
    required this.word,
    required this.translationPool,
  });

  final Word word;

  /// Translations to take the wrong options from.
  final List<String> translationPool;

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

  @override
  Widget build(BuildContext context) {
    final picked = _picked;
    final answered = picked != null;
    final correct = widget.word.translation;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final option in widget.word.choiceOptions(widget.translationPool))
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
        color:
            accent?.withValues(alpha: 0.14) ??
            AppPalette.of(context).subtleButton,
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
