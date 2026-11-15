import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/word.dart';
import 'package:deutschlernen/ui/cards/widgets/word_card.dart';
import 'package:deutschlernen/ui/core/app_icons.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/vocabulary/widgets/word_hero.dart';

/// One word's card opened from the vocabulary.
/// Same card as in learning, in its compact lookup mode. A word with
/// progress gets a "reset progress" button under the card.
/// Has a transparent background: the vocabulary tab stays visible, dimmed,
/// under the card (see [WordDetailScreen.route]).
class WordDetailScreen extends StatefulWidget {
  const WordDetailScreen({
    super.key,
    required this.word,
    required this.otherTranslations,
    required this.showTranscription,
    required this.lookupCount,
    required this.onSpeak,
    required this.hasProgress,
    required this.onResetProgress,
  });

  final Word word;
  final List<String> otherTranslations;
  final bool showTranscription;
  final int lookupCount; // times opened from the search, shown in the header
  final ValueChanged<String> onSpeak;

  /// False for a new word: nothing to reset, no button.
  final bool hasProgress;
  final VoidCallback onResetProgress;

  /// Route that keeps the previous screen under it. The card grows out of
  /// the search row via [WordHero]; the barrier dims the screen below.
  static Route<void> route({
    required AppStrings strings,
    required WordDetailScreen screen,
  }) {
    return PageRouteBuilder<void>(
      opaque: false, // previous screen is still painted below
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      // A pushed route is not under the shell's AppStringsScope,
      // so the scope is provided again.
      pageBuilder: (_, _, _) =>
          AppStringsScope(strings: strings, child: screen),
      // No page transition: the only visible thing is the card, and the
      // hero animates it. A fade on top would just make it look washed out.
      transitionsBuilder: (_, _, _, child) => child,
    );
  }

  @override
  State<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {
  // Local copy: after a reset the button goes away while the card stays.
  late bool _hasProgress = widget.hasProgress;

  void _reset() {
    widget.onResetProgress();
    setState(() => _hasProgress = false);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final word = widget.word;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                children: [
                  // The card takes what is left above the button.
                  Expanded(
                    child: WordHero(
                      wordId: word.id,
                      // The shuttle flies in the Navigator overlay, outside
                      // this route, so it needs its own strings scope.
                      child: AppStringsScope(
                        strings: strings,
                        child: WordCard(
                          word: word,
                          onSpeak: widget.onSpeak,
                          showTranscription: widget.showTranscription,
                          otherTranslations: widget.otherTranslations,
                          bottomBar: const SizedBox.shrink(),
                          lookup: true,
                          lookupCount: widget.lookupCount,
                          onClose: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                  ),
                  // Animated: after a reset the card grows back smoothly.
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    child: _hasProgress
                        ? Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: _ResetButton(
                              label: strings.resetProgress,
                              onPressed: _reset,
                            ),
                          )
                        : const SizedBox(width: double.infinity),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-width button under the card, styled as a piece of the card: same
/// fill, outline and corner radius (see WordCard). Filled: it sits over the
/// dimmed screen and would blend in without a fill.
class _ResetButton extends StatelessWidget {
  const _ResetButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: const Icon(AppIcons.arrowCounterClockwise, size: 20),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: AppPalette.of(context).card,
          foregroundColor: colors.onSurface,
          padding: const EdgeInsets.symmetric(vertical: 18),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
            side: BorderSide(
              color: colors.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
    );
  }
}
