import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/word.dart';
import 'package:deutschlernen/ui/cards/widgets/word_card.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/vocabulary/widgets/word_hero.dart';

/// One word's card opened from the vocabulary search.
/// Same card as in learning, in its compact lookup mode.
/// Has a transparent background: the vocabulary tab stays visible, dimmed,
/// under the card (see [WordDetailScreen.route]).
class WordDetailScreen extends StatelessWidget {
  const WordDetailScreen({
    super.key,
    required this.word,
    required this.otherTranslations,
    required this.showTranscription,
    required this.onSpeak,
  });

  final Word word;
  final List<String> otherTranslations;
  final bool showTranscription;
  final ValueChanged<String> onSpeak;

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
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: WordHero(
                wordId: word.id,
                // The shuttle flies in the Navigator overlay, outside
                // this route, so it needs its own strings scope.
                child: AppStringsScope(
                  strings: strings,
                  child: WordCard(
                    word: word,
                    onSpeak: onSpeak,
                    showTranscription: showTranscription,
                    otherTranslations: otherTranslations,
                    bottomBar: const SizedBox.shrink(),
                    lookup: true,
                    onClose: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
