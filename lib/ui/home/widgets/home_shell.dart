import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/word.dart';
import 'package:deutschlernen/ui/cards/view_models/cards_view_model.dart';
import 'package:deutschlernen/ui/cards/widgets/cards_screen.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/home/widgets/app_bottom_bar.dart';
import 'package:deutschlernen/ui/main_menu/widgets/level_sheet.dart';
import 'package:deutschlernen/ui/main_menu/widgets/main_menu_screen.dart';
import 'package:deutschlernen/ui/settings/view_models/settings_view_model.dart';
import 'package:deutschlernen/ui/settings/widgets/settings_screen.dart';
import 'package:deutschlernen/ui/statistics/widgets/statistics_screen.dart';
import 'package:deutschlernen/ui/vocabulary/widgets/vocabulary_screen.dart';
import 'package:deutschlernen/ui/vocabulary/widgets/word_detail_screen.dart';

/// The app's root screen: four tabs with the bottom bar.
/// The cards screen is not a tab. It opens on top of the shell, full screen
/// and without the bottom bar, and its close button comes back here.
class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.viewModel,
    required this.settingsViewModel,
  });

  final CardsViewModel viewModel;
  final SettingsViewModel settingsViewModel;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  HomeTab _tab = HomeTab.main;

  CardsViewModel get _vm => widget.viewModel;

  void _openCards() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => CardsScreen(viewModel: _vm)),
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
          showTranscription: widget.settingsViewModel.showTranscription,
          lookupCount: _vm.lookupCount(word.id),
          onSpeak: _vm.speak,
          state: _vm.stateOf(word.id),
          onResetProgress: () => _vm.resetProgress(word.id),
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
              // Content runs under the bar, which blurs it. Scaffold then
              // reports the bar's height as bottom padding in MediaQuery,
              // so screens keep their last items above the bar with it.
              extendBody: true,
              // IndexedStack keeps every tab alive, so e.g. the selected
              // dictionary is not lost when switching tabs.
              body: IndexedStack(
                index: _tab.index,
                children: [
                  MainMenuScreen(
                    selectedLevelCount: _vm.learnLevels.length,
                    newWordsLeft: _vm.newWordsLeft,
                    dueCount: _vm.dueCount,
                    learnedToday: _vm.learnedToday,
                    dailyGoal: CardsViewModel.dailyGoal,
                    onChooseLevels: () => showLevelSheet(
                      context: context,
                      strings: _vm.strings,
                      selected: _vm.learnLevels,
                      wordCounts: {
                        for (final level in Word.levels)
                          level: _vm.words
                              .where((w) => w.level == level)
                              .length,
                      },
                      onChanged: _vm.setLearnLevels,
                    ),
                    onLearnNewWords: () {
                      _vm.startNewWords();
                      _openCards();
                    },
                    onReview: () {
                      _vm.startReview();
                      _openCards();
                    },
                  ),
                  VocabularyScreen(
                    words: _vm.words,
                    onWordSelected: _openWord,
                    onSearchResultSelected: (word) {
                      // Count first, so the card already shows this lookup.
                      _vm.recordLookup(word.id);
                      _openWord(word);
                    },
                    onSpeak: _vm.speak,
                    stateOf: _vm.stateOf,
                    progressChanges: _vm,
                  ),
                  StatisticsScreen(history: _vm.statusHistory),
                  SettingsScreen(
                    settings: widget.settingsViewModel,
                    languages: _vm.languages,
                    uiLanguage: _vm.uiLanguage,
                    wordLanguage: _vm.wordLanguage,
                    uiFollowsSystem: _vm.uiFollowsSystem,
                    wordFollowsSystem: _vm.wordFollowsSystem,
                    systemLanguage: _vm.systemLanguage,
                    onUiLanguageSelected: _vm.setUiLanguage,
                    onWordLanguageSelected: _vm.setWordLanguage,
                    onResetAllProgress: _vm.resetAllProgress,
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
