import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/reminder_plan.dart';
import 'package:deutschlernen/domain/models/word.dart';
import 'package:deutschlernen/ui/cards/widgets/cards_screen.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/view_models/language_view_model.dart';
import 'package:deutschlernen/ui/core/view_models/learning_view_model.dart';
import 'package:deutschlernen/ui/home/widgets/app_bottom_bar.dart';
import 'package:deutschlernen/ui/learn/widgets/level_sheet.dart';
import 'package:deutschlernen/ui/learn/widgets/learn_screen.dart';
import 'package:deutschlernen/ui/settings/view_models/settings_view_model.dart';
import 'package:deutschlernen/ui/settings/widgets/settings_screen.dart';
import 'package:deutschlernen/ui/progress/widgets/progress_screen.dart';
import 'package:deutschlernen/ui/categories/widgets/categories_screen.dart';
import 'package:deutschlernen/ui/categories/widgets/word_detail_screen.dart';

/// The app's root screen: four tabs with the bottom bar.
/// The cards screen is not a tab. It opens on top of the shell, full screen
/// and without the bottom bar, and its close button comes back here.
class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.viewModel,
    required this.languageViewModel,
    required this.settingsViewModel,
    required this.reminderOpened,
    required this.onReminderHandled,
  });

  final LearningViewModel viewModel;
  final LanguageViewModel languageViewModel;
  final SettingsViewModel settingsViewModel;

  /// Set when a reminder is tapped; the shell opens its session, then calls
  /// [onReminderHandled].
  final ValueListenable<ReminderKind?> reminderOpened;
  final VoidCallback onReminderHandled;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  HomeTab _tab = HomeTab.learn;

  LearningViewModel get _vm => widget.viewModel;
  LanguageViewModel get _lang => widget.languageViewModel;

  @override
  void initState() {
    super.initState();
    widget.reminderOpened.addListener(_onReminder);
    // Set before the shell was built (app started from the reminder).
    WidgetsBinding.instance.addPostFrameCallback((_) => _onReminder());
  }

  @override
  void dispose() {
    widget.reminderOpened.removeListener(_onReminder);
    super.dispose();
  }

  /// Opens the tapped reminder's session on the Learn tab. A session that
  /// is already open is closed first: the new one starts fresh.
  void _onReminder() {
    final kind = widget.reminderOpened.value;
    if (kind == null || !mounted) return;
    widget.onReminderHandled();
    Navigator.of(context).popUntil((route) => route.isFirst);
    setState(() => _tab = HomeTab.learn);
    if (_vm.sessionFor(kind) case final mode?) {
      _vm.startSession(mode);
      _openCards();
    }
  }

  void _openCards() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CardsScreen(viewModel: _vm, strings: _lang.strings),
      ),
    );
  }

  void _openWord(Word word) {
    Navigator.of(context).push(
      WordDetailScreen.route(
        strings: _lang.strings,
        screen: WordDetailScreen(
          word: word,
          translationPool: _vm.translations,
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
      listenable: Listenable.merge([_vm, _lang]),
      builder: (context, _) {
        if (_vm.isLoading || _lang.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return AppStringsScope(
          strings: _lang.strings,
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
                  LearnScreen(
                    selectedLevelCount: _vm.learnLevels.length,
                    newWordsLeft: _vm.newWordsLeft,
                    dueCount: _vm.dueCount,
                    learnedToday: _vm.learnedToday,
                    dailyGoal: LearningViewModel.dailyGoal,
                    onChooseLevels: () => showLevelSheet(
                      context: context,
                      strings: _lang.strings,
                      selected: _vm.learnLevels,
                      wordCounts: {
                        for (final MapEntry(key: level, value: words)
                            in _vm.wordsByLevel.entries)
                          level: words.length,
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
                  CategoriesScreen(
                    words: _vm.words,
                    wordsByLevel: _vm.wordsByLevel,
                    seenShare: _vm.seenShare,
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
                  ProgressScreen(history: _vm.statusHistory),
                  SettingsScreen(
                    settings: widget.settingsViewModel,
                    languages: _lang.languages,
                    uiLanguage: _lang.uiLanguage,
                    wordLanguage: _lang.wordLanguage,
                    uiFollowsSystem: _lang.uiFollowsSystem,
                    wordFollowsSystem: _lang.wordFollowsSystem,
                    systemLanguage: _lang.systemLanguage,
                    onUiLanguageSelected: _lang.setUiLanguage,
                    onWordLanguageSelected: _lang.setWordLanguage,
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
