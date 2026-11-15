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

- Word rows (`WordRow` in `word_list.dart`, category lists and search results) start with a
  status strip: 4px wide, radius 2, full text height, 12px gap to the text. Color by
  `WordStatus`: new — `colors.onSurface` (white in dark), learning — `AppColors.statusLearning`
  pink, due for review — `statusReview` yellow, learned — `statusLearned` green,
  "already know" — `colors.onSurfaceVariant` light gray (not the dark divider gray).
  The caption above the German word (`palette.mutedText`, semibold) names the status and the
  next review: "Новое слово", "Уже знаю", "Учится · повтор через 8 мин", "Повтор через 4 дн." /
  "Повторить сейчас", "Выучено · повтор через 2 мес." (`AppStrings.wordState`); in search
  results it is prefixed with the level ("A1 · …"). Green = interval ≥ 21 days
  (`WordStatus.matureInterval`), a due word is always yellow.
  Caption and translation 16px, German word 17px; line height 1.15, letter spacing -0.2, 2px
  apart. Caption gray w600, German word `onSurface` bold, translation `onSurface` w600.
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

`AppBottomBar` (`lib/ui/home/widgets/app_bottom_bar.dart`) is a **floating pill** of frosted
glass: 16 from the screen sides, above the home indicator (12 from the bottom without one),
radius 34, `BackdropFilter` blur 20 over `palette.card` at α 0.75, thin border
`colors.outlineVariant` α 0.4, no ripple. A custom row of tabs, not Material's `NavigationBar`.
Tab: icon 27, 2px gap, 12px w600 label.

Selection: a lighter pill behind the selected tab (`colors.onSurface` α 0.1, 6px inset from
the bar's edge). All icons and labels are `colors.onSurface` (white in dark); the pill alone
marks the selected tab. Icons stay Regular (earlier tries: blue color only; Fill when
selected; muted unselected tabs — all replaced by this design).

Liquid-glass motion (iOS 26 style): on a tap the pill lifts into a lens and settles back in one
continuous arc (lift = sin²(π·t) over a 420 ms `easeInOutQuart` slide: slow–fast–slow, user asked for it — no hand-off between
animations, it looked jerky). The lens grows a little (1.2× wide, 1.22× tall), `RawMagnifier`
enlarges the tabs under it (×1.12) and `LiquidGlass` (package `liquid_glass_renderer`, Impeller
only) refracts them at the edges: blur 0 and chromatic aberration 0 — the user rejected both the
soapy blur and the rainbow rim. Dragging along the bar holds the lens up and moves it with the
finger, a haptic tick per tab crossed; release snaps to the nearest tab. Taps are handled by
the bar, not the tabs.

Tabs and their icons (`AppIcons`): Практика / Practice — `cards` (flashcard stack),
Категории / Categories — `squaresFour`, Прогресс / Progress — `chartLineUp`,
Настройки — `slidersHorizontal`.

`HomeShell` uses `extendBody: true`, so tab content scrolls under the bar. Every scrollable
tab screen adds `MediaQuery.paddingOf(context).bottom` to its bottom padding, and
centered screens keep `SafeArea` with `bottom: true` — otherwise the last items hide
under the bar.

## Icons

- All icons are **Phosphor Regular** (thin line icons with rounded ends) via `AppIcons`
  (`lib/ui/core/app_icons.dart`, font `assets/fonts/Phosphor.ttf`): `AppIcons.x`, `.arrowLeft`,
  `.speakerHigh`, … Never use Material `Icons.*` or `CupertinoIcons.*` — the app must look like
  one icon set. Do NOT add the `phosphor_flutter` package: it doesn't compile with current
  Flutter. To add an icon, follow the comment at the top of `app_icons.dart`.
- A selected state is shown by **color** (blue icon and label), not by a highlight behind the
  icon. Only the bottom bar uses a highlight pill (see above).
- Sizes: 20 in rows and small buttons, 24 default, 28 in large mode buttons.
- Colors: `colors.onSurfaceVariant` when inactive, `AppColors.accentBlue` when active,
  `colors.onSurface` on filled neutral buttons.
- Exception: the Learn tab menu (`main_menu_screen.dart`) has colored leading icons, size 26,
  one color per action (`AppColors.menuCategories` blue, `menuNewWords` pink, `menuRepeat`
  yellow); a disabled row fades its icon to α 0.4.

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
