# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Flutter app for learning German with spaced repetition and chunks (real-life phrases), aimed at Ukrainians in Germany. No backend: all content ships as JSON assets. Two developers; one tests on iOS, the other on Android.

## Commands

```sh
flutter pub get
flutter analyze                      # lints: package:flutter_lints/flutter.yaml
flutter run                          # debug; animations stutter here
flutter run --profile                # real device only; use it to judge animation smoothness
flutter test                         # all tests
flutter test test/domain/card_session_test.dart --plain-name "<test name>"   # single test
```

`test/domain/` covers the session and progress rules; there are no widget tests yet.

Run `dart format` only on files you changed — formatting whole folders rewrites unrelated files and pollutes the diff.

## Architecture

Layered, following Flutter's recommended app architecture: `lib/data` (services + repositories) → `lib/domain/models` → `lib/ui/<feature>/{view_models,widgets}`.

- **Feature folders match the tabs**: `learn`, `categories`, `progress`, `settings`; `cards` is the learning session pushed over them, `home` the shell. Shared widgets go to `ui/core/widgets`.
- **Wiring** is manual in `lib/main.dart`: services and repositories are created there and passed into three `ChangeNotifier`s: `LanguageViewModel` (languages, interface strings), `LearningViewModel` (words, progress, the cards session; both in `ui/core/view_models`) and `SettingsViewModel`. Languages load first, words are loaded in the translation language. There is no DI or state-management package; screens get the view models or plain callbacks through constructors.
- **Rules live in plain Dart** in `lib/domain/models`: `ProgressBook` (progress per word: pink/due lists, status counts) and `CardSession` (deck order, re-inserting words, "already know" replacement, undo). `chartBars` (progress chart bars from daily snapshots), `Word.choiceOptions` / `Word.byLevel`. `ReviewScheduler.answer` maps an answer to the new progress. View models only load, save and notify; put new learning logic in the domain classes and cover it in `test/domain/`.
- **`HomeShell`** (`lib/ui/home/widgets/home_shell.dart`) is the root: an `IndexedStack` of tabs (learn, categories, progress, settings) with a bottom bar. The learning cards screen and the word detail card are pushed as routes on top of it.
- **Content assets** (`assets/data/`):
  - `words.json` — German side only: `id`, `article`, `lemma`, `plural`, `level`, `transcription`, `definition`. `level` is the word's category and must be one of `Word.levels` (A1, A2, B1, B2); the Categories tab lists words by it.
  - `translations/<lang>.json` — keyed by word `id`: `word`, `definition`, `examples[{german, translation}]`. `WordRepository` merges these into `Word`. In examples, `**word**` marks the highlighted word (`lib/ui/core/highlight.dart`).
  - `ui/<lang>.json` — interface strings, read via `AppStrings` getters.
  - `languages.json` — supported languages (currently uk, ru, en, es, zh).
- **Two languages**: the interface language and the word-translation language are chosen and saved separately (`SettingsRepository`, shared_preferences).
- **Strings**: `AppStrings.of(context)` reads an `AppStringsScope` inherited widget provided by `HomeShell`. Pushed routes and Hero flight shuttles are outside that scope, so they wrap their content in `AppStringsScope` again. A missing key renders as the key name itself.
- **`WordCard`** (`lib/ui/cards/widgets/word_card.dart`) is shared: the learning mode (answer modes Show/Write/Choose, swipes, decision bar) and `lookup: true` for the compact card opened from the Categories search (translation shown, close button via `onClose`). Change one mode without breaking the other. Its parts are separate files next to it: `WordCardHeader`, `WordTitle`, `WordAnswer` (holds the open answer mode), `WordExamples`.
- **Categories search → card** uses a Hero (`WordHero` in `lib/ui/categories/widgets/word_hero.dart`) with a custom shuttle and a non-opaque `PageRouteBuilder` (`WordDetailScreen.route`) with a solid black barrier: the list is hidden behind the open card but stays painted for the hero flight back.
- Styling constants (colors, fonts, sizes) live in `lib/ui/core/app_style.dart`. There is a dark and a light theme (`AppTheme`): theme-dependent colors come from `AppPalette.of(context)` (a `ThemeExtension`), fixed accents from `AppColors`. All text uses the theme font; `assets/fonts/` holds only the Phosphor icon font.
- TTS: `SpeechService` wraps `flutter_tts` with `de-DE`.
- **Reminders** are local notifications (`NotificationService`, flutter_local_notifications). `RemindersCoordinator` (`ui/core/view_models`) replans the next 7 days when the reminder settings change and when the app is hidden (`AppLifecycleListener` in `main.dart`): the progress can't change while the app is closed, so `planReminders` (domain) knows in advance how many words are due at each reminder, and skips reminders with nothing to do. A notification's payload is its `ReminderKind`; a tap (or a launch from it) goes through `RemindersCoordinator.opened` to `HomeShell`, which opens that session (`sessionForReminder`). Android needs the receivers in `AndroidManifest.xml` and core library desugaring in `build.gradle.kts`; iOS sets the notification delegate in `AppDelegate.swift`.

## Git workflow

- Never work on `main`. Before changing any file, check the current branch (`git branch --show-current`). If it is `main`, first create a branch: `git switch -c feature/<short-name>` (uncommitted changes move with it).
- If you notice changes were already made on `main`, move them to a new branch the same way before doing anything else.
- Never commit directly to `main`; work reaches `main` only by merging a branch.
- After merging a branch into `main`, delete that branch right away, without asking — locally with `git branch -d` (refuses unmerged work, never `-D`) and, if it was pushed, on GitHub with `git push origin --delete <branch>` once `main` with the merge is pushed. Only the branch of the current task: other people's branches are not touched. If `-d` refuses, keep the branch and say why. Merged branches must not pile up on GitHub: the other developer sees them as clutter.

## Code structure (top priority)

Clean, well-organized code matters more than speed: every change must leave the structure at least as tidy as it was. Before writing code, decide where it belongs.

- **Logic is separate from UI.** Rules (what happens on an answer, which words are due, counting, filtering) go into plain Dart classes in `lib/domain/models` with no Flutter imports, and get tests in `test/domain/`. View models only load, save, call those classes and notify. Widgets only display state and forward taps; no business logic, no repository calls in widgets.
- **One responsibility per class and file.** When a view model starts to hold unrelated things, split it, as `CardsViewModel` was split into `LanguageViewModel`, `LearningViewModel`, `CardSession` and `ProgressBook`. A widget file over ~250 lines, or with several large private widgets, gets split into separate files.
- **Everything in its place.** Feature folder = tab (`lib/ui/<feature>/{view_models,widgets}`); something used by two or more features goes to `ui/core` (`widgets`, `view_models`); data access only in `lib/data`. Names of files, classes and folders match what the user sees.
- **No dead code.** Unused files, widgets, icons, colors and string keys are removed (ask before deleting), not left "for later".
- **No duplication.** A UI piece or rule repeated in two places becomes one shared widget or function (`MenuRow`, `LevelRow`, `showChoiceSheet`).
- If a task can't be done cleanly in the current structure, say so and propose the refactor first instead of adding a workaround.

## Conventions

- Visual rules (colors, buttons, icons, grouped lists) are in the `ui-style` skill (`.claude/skills/ui-style/SKILL.md`); follow it for any UI change.

- Import `package:material_ui/material_ui.dart` instead of `package:flutter/material.dart`. Icons come only from `AppIcons` (`lib/ui/core/app_icons.dart`, Phosphor Regular font in `assets/fonts/`), see the `ui-style` skill. Don't add the `phosphor_flutter` package — it fails to compile with current Flutter (`IconData` is final).
- Adding a UI string means adding the key to every `assets/data/ui/*.json` file and a getter in `AppStrings`. Text with a number ("5 слов") uses plural forms: keys `<name>One/Few/Many/Other` with `{n}`, chosen by the language's rule in `AppStrings` (see `wordCount`); ru and uk need One/Few/Many, en/es One/Other, zh Other. A new word needs an entry in `words.json` and the same `id` in every `translations/*.json`.
- Code comments are short, in English, and only on non-obvious places.
