import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/word.dart';
import 'package:deutschlernen/ui/cards/view_models/cards_view_model.dart';
import 'package:deutschlernen/ui/cards/widgets/cards_screen.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/home/widgets/app_bottom_bar.dart';
import 'package:deutschlernen/ui/main_menu/widgets/main_menu_screen.dart';
import 'package:deutschlernen/ui/settings/widgets/settings_screen.dart';
import 'package:deutschlernen/ui/statistics/widgets/statistics_screen.dart';
import 'package:deutschlernen/ui/vocabulary/widgets/vocabulary_screen.dart';
import 'package:deutschlernen/ui/vocabulary/widgets/word_detail_screen.dart';

/// The app's root screen: four tabs with the bottom bar.
/// The cards screen is not a tab. It opens on top of the shell, full screen
/// and without the bottom bar, and its close button comes back here.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.viewModel});

  final CardsViewModel viewModel;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  HomeTab _tab = HomeTab.main;

  CardsViewModel get _vm => widget.viewModel;

  void _openCards() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CardsScreen(viewModel: _vm),
      ),
    );
  }

  void _openWord(Word word) {
    Navigator.of(context).push(
      WordDetailScreen.route(
        strings: _vm.strings,
        screen: WordDetailScreen(
          word: word,
          // Wrong options for the "choose" answer mode.
          otherTranslations: [
            for (final w in _vm.words)
              if (w.id != word.id) w.translation,
          ],
          onSpeak: _vm.speak,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        if (_vm.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return AppStringsScope(
          strings: _vm.strings,
          // Builder: the bar below needs a context under the scope.
          child: Builder(
            builder: (context) => Scaffold(
              // IndexedStack keeps every tab alive, so e.g. the selected
              // dictionary is not lost when switching tabs.
              body: IndexedStack(
                index: _tab.index,
                children: [
                  MainMenuScreen(onStartLearning: _openCards),
                  VocabularyScreen(
                    words: _vm.words,
                    onWordSelected: _openWord,
                    onSpeak: _vm.speak,
                  ),
                  const StatisticsScreen(),
                  SettingsScreen(
                    languages: _vm.languages,
                    uiLanguage: _vm.uiLanguage,
                    wordLanguage: _vm.wordLanguage,
                    onUiLanguageSelected: _vm.setUiLanguage,
                    onWordLanguageSelected: _vm.setWordLanguage,
                  ),
                ],
              ),
              bottomNavigationBar: AppBottomBar(
                selected: _tab,
                onSelected: (tab) => setState(() => _tab = tab),
              ),
            ),
          ),
        );
      },
    );
  }
}
