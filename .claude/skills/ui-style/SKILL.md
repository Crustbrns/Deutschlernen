---
name: ui-style
description: Visual rules of the Deutschlernen app — colors, surfaces, buttons, icons, lists and spacing. Use whenever adding or changing any screen, widget, button, icon, list or other UI in lib/ui, even small tweaks, so new UI matches the existing look.
---

# Deutschlernen UI style

The app has a dark and a light theme. All colors, fonts and sizes come from
`lib/ui/core/app_style.dart`:
- `AppPalette.of(context)` — colors that differ per theme: `background`, `card`, `subtleButton`,
  `mutedText`, `decisionDivider`. A new theme-dependent color goes here, with a value for both themes.
- `AppColors` — fixed accents (`accentBlue`, article colors, …) and helpers computed from the
  `ColorScheme` (`divider`, `quietText`).
- `AppFonts`, `AppSizes`.

Never write a hex color or `Colors.white`/`Colors.black` in a widget — it breaks one of the themes.
Main text uses `colors.onSurface`.

## Surfaces

| What | Color | Shape |
|---|---|---|
| Screen background | `palette.background` | — |
| Content block (lists, search results) | `palette.card`, **no outline** | radius 20 |
| Word card (learning and lookup) | `palette.card` + outline `colors.outlineVariant` α 0.4 | radius 32 |
| Search field | fill `palette.card`, **no outline** when idle, gray `AppColors.divider(colors)` outline (same as list dividers, not blue) only while focused; vertical padding 10, dense | pill (fully round) |

Search field behavior (`_SearchField` in `vocabulary_screen.dart`): while focused or holding text,
the field shrinks (animated) and a `RoundIconButton` with `Icons.close` appears on its right;
it clears the text, hides the keyboard and returns the field to full width.
The hint text and that close icon are gray too: the outline color made 30% lighter
(`AppColors.quietText(colors)`) — quiet but readable in both themes.

Screen side gutters are 16. Inside the word card content is inset by `AppSizes.cardInset` (24).

## Lists: one block with dividers

When several items of the same kind are listed (levels A1–B2, search results,
settings entries, any future enumeration), put them in **one** rounded block and
separate the rows with thin lines, like the examples on the word card. Never
render them as separate cards with gaps between them.

- Block: `GroupedCard` (`lib/ui/core/widgets/grouped_card.dart`). It draws the block and puts
  dividers only *between* rows (`Divider` height 1, indent 16, `AppColors.divider(colors)`).
- Rows: no own background or outline, horizontal padding 16 (so text starts where
  the divider starts), the whole row is tappable (`InkWell`/`ListTile`).
- Selection inside a block: shown in the row itself — trailing `Icons.check_circle`
  in `AppColors.accentBlue` for the chosen one, `Icons.circle_outlined` in
  `colors.onSurfaceVariant` for the others. Not by an outline.

- Navigation rows (a row that opens a list, e.g. a level): no chevron. A count on the right is
  written with its noun ("5 слов", via `AppStrings.wordCount`), font size 15, in the quiet gray
  `AppColors.quietText(colors)`.

Separate blocks are only for different kinds of content (e.g. a title, then a list).

## Buttons

- **Neutral / secondary** (mode buttons, close, small actions): fill `palette.subtleButton`,
  icon `colors.onSurface`, label `colors.onSurfaceVariant`. Rectangular ones have radius 14.
- **Round icon button** (close, undo, …): `RoundIconButton` (`lib/ui/core/widgets/round_icon_button.dart`) —
  `palette.subtleButton` fill, 36×36, icon 20; disabled = same fill, faded icon. Don't use `filledTonal`.
- **Selected / active state**: fill `AppColors.accentBlue` α 0.14, border `AppColors.accentBlue`,
  icon and text `AppColors.accentBlue` (see `_ModeButton` in `answer_modes.dart`).
- **Primary action** (one per screen at most): `FilledButton`, radius 14.
- **Audio**: `PlayButton` (`lib/ui/core/widgets/play_button.dart`) in rows — blue, outlined.
  The word itself is played from the transcription pill on the word card.
- A button that sits over a transparent or dimmed background (overlay routes) always
  gets a fill, otherwise it blends with what is under it.
- In compact layouts set `tapTargetSize: MaterialTapTargetSize.shrinkWrap`, otherwise
  Material adds invisible padding up to 48px and spacing looks wrong.

## Bottom navigation bar

`AppBottomBar` (`lib/ui/home/widgets/app_bottom_bar.dart`) is frosted glass: `BackdropFilter`
blur 20 over `palette.card` at α 0.7, **no outline or top line**, no indicator pill, no ripple.
It is a custom row of tabs, not Material's `NavigationBar` (that one forces a big gap under the
icon): icon 27, then a 1px gap, then the 11px label; row padding 12 horizontal, 5 vertical. Selected tab = `AppColors.accentBlue`
icon and label, others `palette.mutedText`.

Tabs and their icons (`AppIcons`): Regular when not selected, the `*Fill` (solid) variant when
selected — all-solid was tried and looked too heavy.
Учить / Learn — `cards` (flashcard stack), Словарь — `bookOpen`, Прогресс / Progress —
`chartLineUp`, Настройки — `slidersHorizontal`.

`HomeShell` uses `extendBody: true`, so tab content scrolls under the bar. Every scrollable
tab screen adds `MediaQuery.paddingOf(context).bottom` to its bottom padding, and
centered screens keep `SafeArea` with `bottom: true` — otherwise the last items hide
under the bar.

## Icons

- All icons are **Phosphor Regular** (thin line icons with rounded ends) — except the selected
  bottom bar tab, which uses Phosphor Fill (`*Fill` in `AppIcons`, font `assets/fonts/PhosphorFill.ttf`) — via `AppIcons`
  (`lib/ui/core/app_icons.dart`, font `assets/fonts/Phosphor.ttf`): `AppIcons.x`, `.arrowLeft`,
  `.speakerHigh`, … Never use Material `Icons.*` or `CupertinoIcons.*` — the app must look like
  one icon set. Do NOT add the `phosphor_flutter` package: it doesn't compile with current
  Flutter. To add an icon, follow the comment at the top of `app_icons.dart`.
- A selected state is shown by **color** (blue icon and label), not by a highlight behind the
  icon. Only the bottom bar also switches the icon to its Fill variant.
- Sizes: 20 in rows and small buttons, 24 default, 28 in large mode buttons.
- Colors: `colors.onSurfaceVariant` when inactive, `AppColors.accentBlue` when active,
  `colors.onSurface` on filled neutral buttons.

## Text

- Secondary labels (level, hints, captions): `palette.mutedText`.
- German word: `AppFonts.display` (Fraunces) with `AppFonts.word` variations; translation:
  `AppFonts.translation` (Lora). Plain UI text uses the theme font.
- Articles are colored by gender with `AppColors.forArticle` on the word card. The plural
  article is always `die` (`Word.pluralWithArticle`).
- Translations are shown as stored (lowercase); don't capitalize them.
- No hardcoded UI text: add a key to all four `assets/data/ui/*.json` and a getter in `AppStrings`.

## Animations

Judge smoothness only in `flutter run --profile` on a device; debug mode always stutters.
Prefer `Curves.easeOutCubic` for things that open or grow.
