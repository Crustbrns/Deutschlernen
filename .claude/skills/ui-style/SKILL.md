---
name: ui-style
description: Visual rules of the Deutschlernen app — colors, surfaces, buttons, icons, lists and spacing. Use whenever adding or changing any screen, widget, button, icon, list or other UI in lib/ui, even small tweaks, so new UI matches the existing look.
---

# Deutschlernen UI style

The app has a dark and a light theme. All colors, fonts and sizes come from
`lib/ui/core/app_style.dart`:
- `AppPalette.of(context)` — colors that differ per theme: `background`, `card`, `subtleButton`,
  `mutedText`. A new theme-dependent color goes here, with a value for both themes.
- `AppColors` — fixed accents (`accentBlue`, article colors, …) and helpers computed from the
  `ColorScheme` (`divider`, `quietText`).
- `AppSizes`, `AppListText` (list row typography).

Never write a hex color or `Colors.white`/`Colors.black` in a widget — it breaks one of the themes.
Main text uses `colors.onSurface`.
Light theme (user's choice): text `onSurface` = rgb(8,8,8) `#080808` (set in `AppTheme._build`),
dividers `AppColors.divider` = rgb(230,230,230) `#E6E6E6`. `quietText` is not derived from the
divider any more (it would be too pale), it keeps the old gray base.

## Surfaces

| What | Color | Shape |
|---|---|---|
| Screen background | `palette.background` | — |
| Content block (lists, search results) | `palette.card`, **no outline** | radius 20 |
| Word card (learning and lookup) | `palette.card`, **no outline** (solid) | radius 32 |
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
  status strip: 4px wide, radius 2, full text height, 12px gap to the text. Row padding is
  8 left / 2 right (tighter than other rows). Color by
  `WordStatus`: new — gray (`onSurfaceVariant` moved 60% toward `AppColors.divider`), learning — `AppColors.statusLearning`
  pink (chosen to learn, never reviewed), reviewed at least once or due — `statusReview`
  orange-yellow, learned — `statusLearned` green (one mapping:
  `AppColors.forWordStatus`),
  "already know" — `colors.onSurface` (white in dark). New/known were swapped by the user:
  untouched words should look quiet.
  The caption above the German word (`palette.mutedText`, semibold): "Новое слово", "Уже знаю",
  "Учится" (pink, never reviewed), or only when the word comes back — "Повтор через 8 мин" /
  "Повтор через 4 дн." / "Повторить сейчас" (`AppStrings.wordState`). No "Выучено": green says
  that (user's choice); in search
  results it is prefixed with the level ("A1 · …"). Green = interval ≥ 21 days
  (`WordStatus.matureInterval`), a due word is always yellow.
  Caption, word and translation use `AppListText.caption/title/subtitle` (see "List row
  typography" below).
- **List row typography (`AppListText` in `app_style.dart`)** — every two/three-line list row
  uses it, so all lists look like the word list: `title` (17 bold `onSurface`, like the German
  word), `subtitle` (16 w600 `onSurface`, like the translation), `caption` (16 w600
  `mutedText`, the status line above a word); line height 1.27, letter spacing -0.2,
  `AppListText.gap` (2.2) between lines. Don't style list text inline; don't use ListTile's
  title/subtitle for such rows (it adds its own spacing) — build the row with InkWell + Column.
- Navigation rows (a row that opens a list, e.g. a level): no chevron. Level rows: level name
  as `title`, word count under it in `subtitle` style but `mutedText` gray ("5 слов",
  `AppStrings.wordCount`), and on the right the share of seen words ("40 %" with a
  non-breaking space — known or started learning) in `subtitle` style, color halfway between
  `onSurface` and `mutedText`. In the light theme both the count and the percent are 25% lighter
  (`AppColors.lighten`, user's choice). Padding 16 horizontal, 12 vertical.
  Each level row starts with a colored icon (26, 14px gap), a growth metaphor: A1 `plant`
  (sprout, `AppColors.levelA1` teal), A2 `flowerTulip` (pink), B1 `tree` (green), B2
  `mountains` (blue) — `LevelIcon` (`lib/ui/core/widgets/level_icon.dart`); the level picker sheet
  (`level_sheet.dart`) shows the same icons as `ListTile.leading`.

Separate blocks are only for different kinds of content (e.g. a title, then a list).

## Buttons

- **Neutral / secondary** (mode buttons, close, small actions): fill `palette.subtleButton`,
  icon `colors.onSurface`, label `colors.onSurfaceVariant`. Rectangular ones have radius 14.
- Cards screen top bar: close · progress bar (words finished in this session) · daily goal
  (`_GoalRing`: 36px tall, min 36 wide, radius 18 — a circle that grows into a pill for
  "10/10"; `subtleButton` fill like `RoundIconButton`, no ring; "3/10" 14.5 regular, letter
  spacing 0.3) · undo.
- Undo on the cards screen uses `AppIcons.arrowUUpLeft` (curved U-turn), not `arrowLeft`
  (that one means "go back").
- **Round icon button** (close, undo, …): `RoundIconButton` (`lib/ui/core/widgets/round_icon_button.dart`) —
  `palette.subtleButton` fill, 36×36, icon 20; disabled = same fill, faded icon. Don't use `filledTonal`.
- **Card stack motion**: the top card flies off in 560–1120 ms (button: `easeInOutCubic`,
  drag: `easeOutCubic`). The next card is a real card under it (`IgnorePointer`) that grows
  95% → 100% with `SwipeController.reveal` (how far the top card has moved) while its dimming
  (`palette.background` α 0.75 on top) fades out, so it is full size and bright
  the moment the top one is gone; deeper cards are empty shapes. Each card gets its own bottom
  bar (`bottomBarFor`); only the top one reacts to the drag.
- **Recall buttons** (`RecallBar` in `decision_bar.dart`) for pink words and reviews: two
  separate buttons, 12px apart, 56 tall, radius 14, fill `palette.card` at rest; 1.5px outline
  and face icon 24 (`smileySad` / `smiley`, Regular) in `onSurface` moved 40% toward the card;
  label 17 w700 -0.4 on one line ("Забыл" / "Помню") in `onSurface` moved 25% toward the card. On drag the matching side is
  tinted up to α 0.5 (red / green). New (gray) words keep the split `DecisionBar` below.
- **Decision bar** buttons: text 17 w600, line height 1.05, letter spacing -0.4; text and arrows
  `colors.onSurface` (white in dark), the "||" divider between them too.
- **Decision bar highlight** (while dragging, up to α 0.45 at full drag; was 0.18 — too pale;
  red `#FF3B30`, green `#30D158`):
  `AppColors.decisionGreen` for the "good" side,
  `decisionRed` for the other. New word: left "Уже знаю" green, right "Начать учить" red.
  Pink word / review: left "Не помню" red, right "Помню" green.
- **Answer controls on a learning card**: new-words session — only `RevealButton` (64×64,
  radius 16, no outline, fill `subtleButton` darkened 10%, eye icon, no label, centered); a tap
  replaces it with the translation (no way back); review session — the three-button
  `AnswerModeBar` (Show / Write / Choose). `WordCard.answerModes` switches them.
- **Selected / active state**: fill `AppColors.accentBlue` α 0.14, border `AppColors.accentBlue`,
  icon and text `AppColors.accentBlue` (see `_ModeButton` in `answer_modes.dart`).
- **Primary action** (one per screen at most): `FilledButton`, radius 14.
- **Audio**: `PlayButton` (`lib/ui/core/widgets/play_button.dart`) in rows — blue, outlined.
  On the word card the German word and its plural are left-aligned with a speaker button
  (`_TranscriptionButton` without text: rounded square, radius 12) on the right of the word,
  8px after it; the row reaches 12px into the card's right inset (`OverflowBox`), so long words
  get more room before wrapping; the transcription pill below
  (text only, left, also speaks) appears when transcription is on.
- A button that sits over a transparent or dimmed background (overlay routes) always
  gets a fill, otherwise it blends with what is under it.
- Card header: level chip, 10px, 12px square, 6px, status text (14.5 w600 muted, letter
  spacing -0.5).
- Opened word card header (lookup mode): level chip, then a 12px square in the word's status
  color (`AppColors.forWordStatus`, the same as the list strip) and the same caption as in
  the list (`AppStrings.wordState`). The lookup count ("Искали 3 раза") is a chip under the
  translation, right-aligned, radius 8 (squarer than the round level chip).
- Word card opened from a list (`WordDetailScreen`) sits on a solid black backdrop (barrier
  `Colors.black`, fades in) — the list behind must not show. A word with progress gets a full-width
  "Сбросить прогресс по слову" button under the card, styled like the card itself (fill
  `palette.card`, no outline, radius 32, text `onSurface` 16 w600, 12px above); the card shrinks just enough to fit it. Reset is instant, no dialog
  (user's choice); the button then collapses with `AnimatedSize`.
- In compact layouts set `tapTargetSize: MaterialTapTargetSize.shrinkWrap`, otherwise
  Material adds invisible padding up to 48px and spacing looks wrong.

## Bottom navigation bar

`AppBottomBar` (`lib/ui/home/widgets/app_bottom_bar.dart`) is a **floating pill** of frosted
glass: 16 from the screen sides, above the home indicator (12 from the bottom without one),
radius 34, `BackdropFilter` blur 20 over `palette.card` at α 0.75, thin border
`colors.outlineVariant` α 0.4, no ripple. A custom row of tabs, not Material's `NavigationBar`.
Tab: icon 22, 2px gap, 12px w600 label, letter spacing -0.3.

Selection: a lighter pill behind the selected tab (`colors.onSurface` α 0.1, 6px inset from
the bar's edge). All icons and labels are `colors.onSurface` (white in dark); the pill alone
marks the selected tab. All tab icons are **Phosphor Fill** (solid), selected or not — the
user's choice (earlier tries: blue color only; Fill only when selected; muted unselected
tabs; all-Regular line icons — all replaced by this design).

Liquid-glass motion (iOS 26 style): on a tap the pill lifts into a lens and settles back in one
continuous arc (lift = sin²(π·t) over a 420 ms `easeInOutQuart` slide: slow–fast–slow, user asked for it — no hand-off between
animations, it looked jerky). The lens grows a little (1.2× wide, 1.22× tall), `RawMagnifier`
enlarges the tabs under it (×1.12) and `LiquidGlass` (package `liquid_glass_renderer`, Impeller
only) refracts them at the edges: blur 0 and chromatic aberration 0 — the user rejected both the
soapy blur and the rainbow rim. Dragging along the bar holds the lens up and moves it with the
finger, a haptic tick per tab crossed; release snaps to the nearest tab. Taps are handled by
the bar, not the tabs.

Tabs and their icons (`AppIcons`, font `assets/fonts/PhosphorFill.ttf`): Учить / Learn —
`houseFill`, Категории / Categories — `squaresFourFill`, Прогресс / Progress —
`fileTextFill` (a sheet with text lines), Настройки — `gearFill` (8 rounded teeth).

`HomeShell` uses `extendBody: true`, so tab content scrolls under the bar. Every scrollable
tab screen adds `MediaQuery.paddingOf(context).bottom` to its bottom padding, and
centered screens keep `SafeArea` with `bottom: true` — otherwise the last items hide
under the bar.

## Icons

- All icons are **Phosphor Regular** (thin line icons with rounded ends) — except the example
  rows' chevron, `caretDownBold` from Phosphor Bold, and the bottom bar tabs (Phosphor Fill,
  see above) — via `AppIcons`
  (`lib/ui/core/app_icons.dart`, font `assets/fonts/Phosphor.ttf`): `AppIcons.x`, `.arrowLeft`,
  `.speakerHigh`, … Never use Material `Icons.*` or `CupertinoIcons.*` — the app must look like
  one icon set. Do NOT add the `phosphor_flutter` package: it doesn't compile with current
  Flutter. To add an icon, follow the comment at the top of `app_icons.dart`.
- A selected state is shown by **color** (blue icon and label), not by a highlight behind the
  icon. Only the bottom bar uses a highlight pill (see above).
- Sizes: 20 in rows and small buttons, 24 default, 28 in large mode buttons.
- Colors: `colors.onSurfaceVariant` when inactive, `AppColors.accentBlue` when active,
  `colors.onSurface` on filled neutral buttons.
- Practice tab menu text is condensed: title `headlineSmall` letter spacing -0.5, row titles
  17 w600 / -0.4, trailing count 15 w600 / -0.3 (default spacing looked too loose to the user).
- Exception: the Learn tab menu (`main_menu_screen.dart`) has colored leading icons, size 26,
  one color per action (`AppColors.menuCategories` blue, `menuNewWords` pink, `menuRepeat`
  yellow); a disabled row fades its icon to α 0.4.
- Week strip (`WeekStrip` in `main_menu/widgets/week_strip.dart`), 16px under the Practice
  menu block: 7 tiles Mon–Sun (`AppStrings.weekdaysShort`, day names only, no dates), 6px
  apart, 52 tall, radius 14, fill `palette.card`, text 15 w600 -0.3 `onSurface`; today is
  filled `AppColors.menuNewWords` pink with `AppColors.onAccent` (white) text.

## Text

- Secondary labels (level, hints, captions): `palette.mutedText`.
- All text uses the theme font — the word card too (no decorative fonts; Fraunces/Lora were
  dropped: the user found the hooked letters too fancy). Word card: "der Hund (die Hunde)" as one
  left-aligned text, 32 w600, letter spacing -0.6 — the plural continues the line in brackets,
  same style and color (only the article is colored); long ones wrap. Translation 32 w600,
  -0.6, left-aligned. Examples and the
  definition (`example_tile.dart`): theme font 17, `onSurface` (white), regular; the highlighted
  word is the same color, extra bold (w800) — weight alone sets it apart. Expand chevron: 11px
  `AppIcons.caretDownBold` (Phosphor Bold, `assets/fonts/PhosphorBold.ttf`), 4px gap.
- Articles are colored by gender with `AppColors.forArticle` on the word card. The plural
  article is always `die` (`Word.pluralWithArticle`).
- Translations are shown as stored (lowercase); don't capitalize them.
- No hardcoded UI text: add a key to every `assets/data/ui/*.json` and a getter in `AppStrings`.

## Animations

Judge smoothness only in `flutter run --profile` on a device; debug mode always stutters.
Prefer `Curves.easeOutCubic` for things that open or grow.

## Settings

`SettingsScreen`: title (`headlineSmall`, -0.5, 12 below), then per category a gray name
(`MenuRow.hintStyle`, not uppercase, 8 from the left like the title, 20 above) and a
`GroupedCard` of `MenuRow`s (`lib/ui/core/widgets/menu_row.dart`, shared with the Learn menu:
title 17 w600 -0.4, gray hint 15 w600 -0.3). **No icons in settings rows** (user removed them;
the Learn menu keeps its colored icons). Rows use `compact: true`: line height 1.2, 2px above
the hint. Reset all progress: title in `decisionRed`.

- Switches: `AppSwitch` (`lib/ui/core/widgets/app_switch.dart`), same on both platforms: track
  60×31, oval white thumb 37×25 (wider than tall, user's choice), on = `AppColors.softBlue`
  `#0A84FF` (softer than `accentBlue`), off = `subtleButton`; the whole row toggles. iOS behavior:
  tap toggles, the thumb can be dragged (snaps to the nearer side, a flick > 300 px/s decides
  by direction), stretches 6px toward the middle while pressed, track color lerps with the
  thumb, `HapticFeedback.lightImpact` on change.
- Theme: `ThemeSwitch` (`settings/widgets/theme_switch.dart`), an iOS segmented control: pill
  as tall as `AppSwitch` (31, `subtleButton`, padding 2), two icon-only segments 42 wide
  (moon / sun 18; labels squeezed the title). The chosen one sits on a raised thumb
  (`palette.segmentThumb`: white in light, #3A3A3D in dark, shadow like the switch thumb); tap
  a segment or drag the thumb (snaps, flick > 300 px/s decides), pressed thumb shrinks to 0.94,
  haptic on change; icons fade `quietText` → `onSurface` with the thumb. No blue here.
- Language rows: current language name (no flag) as `AppColors.softBlue` trailing text, no
  chevron. Language sheet (`language_sheet.dart`): no flags, chosen language and its check in
  `softBlue`.
- Speech rate: a `MenuRow` header, then a slider (track 4, `softBlue`, thumb radius 10, no value
  indicator) and slow / fast 13 gray under it.
- Reset dialog: `palette.card`, radius 20, title `AppListText.title`, body gray hint, buttons
  17 w600 (cancel `onSurface`, reset red).

## Progress chart

`StatisticsScreen` (Progress tab): title like the other tabs, then a period switch, then one
`palette.card` block (radius 20) with `ProgressChart`, then a `GroupedCard` with the current count
per status (`_TotalRow`: 12px status dot, 12 gap, name in `AppListText.subtitle`, count right in
`AppListText.title`; padding 16/14), top of the stack first: learned, review, learning, known.
The list doubles as the chart's legend, so the chart has none of its own.

- Period switch (`_PeriodSwitch`): one `palette.card` block, radius 14, padding 4; four equal
  segments 36 tall, radius 10 — 7 / 30 / 90 days / all time. Selected: `accentBlue` α 0.14 fill,
  `accentBlue` text; others `onSurface`; 14 w600 -0.3.
- Chart (`progress_chart.dart`, `CustomPainter`): stacked bars, bottom to top known (soft light
  gray `AppColors.chartKnown` #C7C7CC in both themes — white in the lists, gray here by the
  user's choice), learning (pink),
  review (yellow), learned (green); colors via `ProgressChart.colorFor`, the legend dots too.
  2px gaps between segments, radius 6, bar ≤ 44 wide (62% of its slot). Neighbouring bars are
  joined per status by bands (same color α 0.22, cubic curves). x labels 12 w600 `mutedText`,
  a short date with the month abbreviated (`AppStrings.dateShort`: "16 ноя", "16 Nov",
  "11月 16日"); if any label is wider than its column, all break into two lines (day / month). Slots narrower than 52 scroll sideways, opening at the latest bar.
- Every non-empty segment shows its word count centered (14 regular w400, -0.3, always black
  `AppColors.chartCount` — all fills are light), so it is at least 22px tall; the rest of
  the height is linear, one scale for all bars. Y axis (34 wide, 12 w600 `mutedText`) and a
  dashed grid in `AppColors.divider` stay: round steps 1/2/5/10/…, ≤ 4 lines above 0; if the
  minimums make a bar too tall, the scale shrinks to fit and the ticks follow
  (`ProgressChart._layout`).
- Vertical grid: dashed lines between columns, same style as the horizontal ones (1px,
  4 on / 4 off, `AppColors.divider`), plot height only; scroll with the bars. (Zebra column
  backings were tried and rejected: the user wants plain dashes both ways.) A segment raised to the minimum looks bigger than its value on
  the axis — intended, the user's choice.
- Meaning — a funnel, layers overlap (user's choice): known — "already know" (separate);
  pink "Изучаю" — every word taken to learn (pink + yellow + green statuses); yellow
  "Повторено" — unique words recalled at least once (yellow + green); green "Выучено" —
  interval ≥ 21 days. A learned word adds to pink, yellow and green, so a bar is taller than
  the number of words (`StatusCounts.stack` / `stackTotal`). The list under the chart shows
  the same funnel numbers.
- Height = all words in each status at the end of that day/week (not the day's activity).
  7 days — a bar per day; 30 / 90 days / all time — a bar per week (Monday start).
