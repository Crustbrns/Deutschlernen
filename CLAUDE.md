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
flutter test test/widget_test.dart --plain-name "<test name>"   # single test
```

`test/widget_test.dart` is still the default counter template and fails against the real app.

Run `dart format` only on files you changed — formatting whole folders rewrites unrelated files and pollutes the diff.

## Architecture

Layered, following Flutter's recommended app architecture: `lib/data` (services + repositories) → `lib/domain/models` → `lib/ui/<feature>/{view_models,widgets}`.

- **Wiring** is manual in `lib/main.dart`: services and repositories are created there and passed into a single `CardsViewModel` (`ChangeNotifier`). There is no DI or state-management package; screens get the view model or plain callbacks through constructors.
- **`HomeShell`** (`lib/ui/home/widgets/home_shell.dart`) is the root: an `IndexedStack` of tabs (main, vocabulary, statistics, settings) with a bottom bar. The learning cards screen and the word detail card are pushed as routes on top of it.
- **Content assets** (`assets/data/`):
  - `words.json` — German side only: `id`, `article`, `lemma`, `plural`, `level`, `transcription`, `definition`. `level` is the word's category and must be one of `Word.levels` (A1, A2, B1, B2); the vocabulary tab lists words by it.
  - `translations/<lang>.json` — keyed by word `id`: `word`, `definition`, `examples[{german, translation}]`. `WordRepository` merges these into `Word`. In examples, `**word**` marks the highlighted word (`lib/ui/core/highlight.dart`).
  - `ui/<lang>.json` — interface strings, read via `AppStrings` getters.
  - `languages.json` — supported languages (currently ru, en, es, zh).
- **Two languages**: the interface language and the word-translation language are chosen and saved separately (`SettingsRepository`, shared_preferences).
- **Strings**: `AppStrings.of(context)` reads an `AppStringsScope` inherited widget provided by `HomeShell`. Pushed routes and Hero flight shuttles are outside that scope, so they wrap their content in `AppStringsScope` again. A missing key renders as the key name itself.
- **`WordCard`** (`lib/ui/cards/widgets/word_card.dart`) is shared: the learning mode (answer modes Show/Write/Choose, swipes, decision bar) and `lookup: true` for the compact card opened from the vocabulary search (translation shown, close button via `onClose`). Change one mode without breaking the other.
- **Vocabulary search → card** uses a Hero (`WordHero` in `lib/ui/vocabulary/widgets/word_hero.dart`) with a custom shuttle and a non-opaque `PageRouteBuilder` (`WordDetailScreen.route`) with a solid black barrier: the list is hidden behind the open card but stays painted for the hero flight back.
- Styling constants (colors, fonts, sizes) live in `lib/ui/core/app_style.dart`. There is a dark and a light theme (`AppTheme`): theme-dependent colors come from `AppPalette.of(context)` (a `ThemeExtension`), fixed accents from `AppColors`. All text uses the theme font; `assets/fonts/` holds only the Phosphor icon font plus the no longer used Fraunces and Lora.
- TTS: `SpeechService` wraps `flutter_tts` with `de-DE`.

## Git workflow

- Never work on `main`. Before changing any file, check the current branch (`git branch --show-current`). If it is `main`, first create a branch: `git switch -c feature/<short-name>` (uncommitted changes move with it).
- If you notice changes were already made on `main`, move them to a new branch the same way before doing anything else.
- Never commit directly to `main`; work reaches `main` only by merging a branch.
- After merging a branch into `main`, delete that **local** branch right away, without asking: use `git branch -d` (refuses unmerged work), never `-D`. Only the branch of the current task; remote branches and other people's branches are not touched. If `-d` refuses, keep the branch and say why.

## Conventions

- Visual rules (colors, buttons, icons, grouped lists) are in the `ui-style` skill (`.claude/skills/ui-style/SKILL.md`); follow it for any UI change.

- Import `package:material_ui/material_ui.dart` instead of `package:flutter/material.dart`. Icons come only from `AppIcons` (`lib/ui/core/app_icons.dart`, Phosphor Regular font in `assets/fonts/`), see the `ui-style` skill. Don't add the `phosphor_flutter` package — it fails to compile with current Flutter (`IconData` is final).
- Adding a UI string means adding the key to all four `assets/data/ui/*.json` files and a getter in `AppStrings`. Text with a number ("5 слов") uses plural forms: keys `<name>One/Few/Many/Other` with `{n}`, chosen by the language's rule in `AppStrings` (see `wordCount`); ru needs One/Few/Many, en/es One/Other, zh Other. A new word needs an entry in `words.json` and the same `id` in every `translations/*.json`.
- Code comments are short, in English, and only on non-obvious places.
- `lib/ui/screens/home_screen.dart` and `greeting_card.dart` are unused template leftovers.
