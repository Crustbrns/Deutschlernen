---
name: ui-style
description: Visual rules of the Deutschlernen app — colors, surfaces, buttons, icons, lists and spacing. Use whenever adding or changing any screen, widget, button, icon, list or other UI in lib/ui, even small tweaks, so new UI matches the existing look.
---

# Deutschlernen UI style

The app has a dark and a light theme. All colors, fonts and sizes come from
`lib/ui/core/app_style.dart`:
- `AppPalette.of(context)` — colors that differ per theme: `background`, `card`, `subtleButton`,
  `mutedText`. A new theme-dependent color goes here, with a value for both themes.
- **One accent: lime** (user's choice, 2026-11-20, from a reference; was yellow `#FFC72C`
  before, blue before that). Fills —
  switches, slider, selected segments, primary buttons — `AppColors.lime` `#D6F566` with
  `AppColors.onLime` (black) content, in both themes. Accent **text and icons** on a surface —
  chosen values, checks, play buttons, cursor — `palette.accentText`: lime in dark, olive `#5E7A00`
  in light (lime on white is 1.2:1, this is 4.9:1). `colorScheme.primary` is lime, so default
  `FilledButton`s and spinners follow. `AppColors.accentBlue` is left only as the color seed
  (neutral grays), the Learn menu's categories icon and the unknown-article fallback.
- `AppColors` — fixed accents (`lime`, article colors, …) and helpers computed from the
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

Search field behavior (`SearchField` in `lib/ui/core/widgets/search_field.dart`, the one widget for every search): results update only once typing pauses (350 ms), the search key and the close button update them at once. While focused or holding text,
the field shrinks (animated) and a `RoundIconButton` with `Icons.close` appears on its right;
it clears the text, hides the keyboard and returns the field to full width.
The hint text and that close icon are gray too: the outline color made 30% lighter
(`AppColors.quietText(colors)`) — quiet but readable in both themes.

Screen side gutters are 16. Inside the word card content is inset by `AppSizes.cardInset` (24),
except the definition / example rows (`ExpandableTile`): inset 16 with their dividers, so the
German text gets more room (user's choice). Their trailing slot (`ExpandableTile.trailingWidth`,
46) runs from the text to the card's edge: 10 gap, the 20 icon ending 16 from the edge
(`PlayButton.rowEnd`), and the whole slot is the tap area.

## Lists: one block with dividers

When several items of the same kind are listed (levels A1–B2, search results,
settings entries, any future enumeration), put them in **one** rounded block and
separate the rows with thin lines, like the examples on the word card. Never
render them as separate cards with gaps between them.

- Block: `GroupedCard` (`lib/ui/core/widgets/grouped_card.dart`). It draws the block and puts
  dividers only *between* rows (`Divider` height 1, indent 16, `AppColors.divider(colors)`).
  Long lists (words, search results) use `GroupedSliverList` from the same file instead: same
  look, but only the visible rows are built (project rule).
- Rows: no own background or outline, horizontal padding 16 (so text starts where
  the divider starts), the whole row is tappable (`InkWell`/`ListTile`).
- Selection inside a block: shown in the row itself — trailing `AppIcons.checkCircle`
  in `palette.accentText` for the chosen one (level sheet, language sheet), `AppIcons.circle` in
  `colors.onSurfaceVariant` for the others. Not by an outline.
- Language sheet rows start with a code badge (`_Badge` in `language_sheet.dart`, user's choice
  2026-11-20): 40×28, radius 8, "UK"/"RU"… 14 w700 +0.3; gray `palette.subtleButton` with
  `onSurface` text, the chosen one `colorScheme.primary` (the accent) with `onPrimary`. "Same as
  system" has the same badge with `AppIcons.deviceMobile` 18. Sections: "Как в системе" block,
  then `GroupedSection`s "На устройстве" / "Доступные".

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
  `onSurface` and `mutedText`. In the light theme both the count and the percent are 50% lighter
  (`AppColors.lighten`, user's choice). Count 15 (not 16), percent 17, 4px gap under the
  level name (not `AppListText.gap`). Padding 16 horizontal, 12 vertical.
  Each level row starts with a flat color illustration (30, 14px gap), a growth metaphor:
  A1 seedling, A2 tulip, B1 tree, B2 snow-capped mountain — Fluent Emoji Flat SVGs (MIT,
  `assets/icons/levels/`, rendered with `flutter_svg`) via `LevelIcon`
  (`lib/ui/core/widgets/level_icon.dart`); the user wanted illustrations like in other learning
  apps instead of tinted line icons. Never take icons from another app's screenshots — use a
  free-licensed set; the level picker sheet
  (`level_sheet.dart`) uses the same `LevelRow` (`lib/ui/core/widgets/level_row.dart`) as the
  Categories tab, with the picker check (`accentText` `checkCircle` / `circle`) as trailing.

Theme-dependent colors are fields of `AppPalette` with a value per theme (e.g. `secondaryText`
for the level word count, `levelPercent` for "40 %"). Widgets never check
`Theme.of(context).brightness` themselves.

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
  `palette.subtleButton` fill, 36×36 visible, icon 20; disabled = same fill, faded icon. Don't use `filledTonal`.
  It takes **44×44 in the layout** (the tap area, padded tap target + density −1): place it with
  4 less padding/gap on each side than you want to the visible circle.
- **Tap areas are at least 44 px** (Apple's minimum), even when the visible control is smaller:
  extend the tappable area with padding inside the gesture detector (see `_PeriodSwitch`), not
  by enlarging the visuals.
- **Card stack motion**: the top card flies off in 560–1120 ms (button: `easeInOutCubic`;
  drag: `_LaunchCurve` — starts at the finger's speed along the path, then eases out, so there
  is no seam at release). Haptics: a `selectionClick` when a drag crosses the decision line
  (25% of the width), a `lightImpact` when a button or a short flick decides. The next card is a real card under it (`IgnorePointer`) that grows
  95% → 100% with `SwipeController.reveal` (how far the top card has moved) while its dimming
  (`palette.background` α 0.75 on top) fades out, so it is full size and bright
  the moment the top one is gone; deeper cards are empty shapes. Each card gets its own bottom
  bar (`bottomBarFor`); only the top one reacts to the drag.
- **Recall buttons** (`RecallBar` in `recall_bar.dart`) for pink words and reviews: two
  separate buttons, 12px apart, 56 tall, radius 14, fill `palette.card` at rest; 1.5px outline
  and face icon 24 (`smileySad` / `smiley`, Regular) in `onSurface` moved 40% toward the card;
  label 17 w700 -0.4 on one line ("Забыл" / "Помню") in `onSurface` moved 25% toward the card.
  "Помню" is the main action (user's choice, 2026-11-20): solid `AppColors.lime` fill, no
  outline, icon and label `onLime` (black). On drag "Забыл" is tinted up to α 0.5 red, "Помню"
  gets up to 30% lighter (toward white). New (gray) words keep the split `DecisionBar` below.
- **Decision bar** buttons: text 17 w600, line height 1.05, letter spacing -0.4; text and arrows
  `colors.onSurface` (white in dark), the "||" divider between them too.
- **Decision bar highlight** (while dragging, up to α 0.45 at full drag; was 0.18 — too pale;
  red `#FF3B30`, the accent lime):
  `AppColors.lime` for the "good" side (user's choice, 2026-11-20; was green),
  `decisionRed` for the other. New word: left "Уже знаю" lime, right "Начать учить" red.
- **Accent card style** (cards screen and the lookup card, from a reference the user liked:
  yellow on black, now lime): one accent `AppColors.lime` `#D6F566`, content on it `AppColors.onLime`
  (black, both themes). Lime = the card's main action (`RevealButton`, "Проверить"), the
  selected answer mode, the write field's focus border, the session progress bar and the
  highlighted word in examples. Everything else on the card stays neutral (example play
  buttons white); red / green decision colors and article colors are unchanged. The same
  lime is the accent of the whole app (see the top of this file).
- **Answer controls on a learning card**: new-words session — only `RevealButton` (64×64,
  radius 16, no outline, fill `AppColors.lime`, black eye icon, no label, centered); a tap
  replaces it with the translation (no way back); review session — the three-button
  `AnswerModeBar` (Show / Write / Choose). `WordCard.answerModes` switches them.
- **Selected / active state**: solid `AppColors.lime` fill, black (`onLime`) icon and text —
  the period switch on Progress, `_ModeButton` in `answer_mode_bar.dart`. Not lime text on a
  tinted fill: unreadable in the light theme.
- **Primary action** (one per screen at most): `FilledButton`, radius 14.
- **Audio**: `PlayButton` (`lib/ui/core/widgets/play_button.dart`) — `accentText` in search results,
  `onSurface` (white) in the card's example rows (`PlayButton.rowEnd`).
  On the word card the German word and its plural are left-aligned with a speaker button
  (`TranscriptionButton` in `transcription_button.dart`, without text: rounded square, radius 12) on the right of the word,
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
finger, a haptic tick per tab crossed. Grabbing doesn't jump: the lens starts where it is and
catches up with the finger over the first half tab. On release the lens springs (damping 0.85,
stiffness 320) from the finger's speed to the tab the flick is heading for (Apple's momentum
projection, deceleration 0.99), not just the nearest one. Taps are handled by the bar, not the
tabs.

Tabs and their icons (`AppIcons`, font `assets/fonts/PhosphorFill.ttf`): Учить / Learn —
`houseFill`, Категории / Categories — `squaresFourFill`, Прогресс / Progress —
`fileTextFill` (a sheet with text lines), Настройки — `gearFill` (8 rounded teeth).

`HomeShell` uses `extendBody: true`, so tab content scrolls under the bar. Every scrollable
screen ends with `AppSizes.bottomPadding(context)` (24 + the bottom inset, which includes the
bar), and centered screens keep `SafeArea` with `bottom: true` — otherwise the last items
hide under the bar.

Tabs: Learn, Progress and Settings are a `TabPage` (`lib/ui/core/widgets/tab_page.dart`):
16 gutters, the tab's `TabTitle`, then the content. `TabTitle` is the one tab title, also
above the Categories search: `headlineSmall`, letter spacing -0.5, 24 from the screen edge,
12 below.

## Icons

- Level illustrations (`LevelIcon`) are the one exception: flat color SVGs, see Lists.
- All other icons are **Phosphor Regular** (thin line icons with rounded ends) — except the example
  rows' chevron, `caretDownBold` from Phosphor Bold, the bottom bar tabs (Phosphor Fill,
  see above) and the streak flame `fireFill` (Phosphor Fill) — via `AppIcons`
  (`lib/ui/core/app_icons.dart`, font `assets/fonts/Phosphor.ttf`): `AppIcons.x`, `.arrowLeft`,
  `.speakerHigh`, … Never use Material `Icons.*` or `CupertinoIcons.*` — the app must look like
  one icon set. Do NOT add the `phosphor_flutter` package: it doesn't compile with current
  Flutter. To add an icon, follow the comment at the top of `app_icons.dart`.
- A selected icon is shown by **color** (`palette.accentText`), not by a highlight behind it.
  Only the bottom bar uses a highlight pill (see above).
- Sizes: 20 in rows and small buttons, 24 default, 28 in large mode buttons.
- Colors: `colors.onSurfaceVariant` when inactive, `palette.accentText` when active,
  `colors.onSurface` on filled neutral buttons.
- Learn tab menu text is condensed: title `TabTitle`, row titles 17 w600 / -0.4, trailing
  count 15 w600 / -0.3 (default spacing looked too loose to the user).
- Exception: the Learn tab menu (`learn_screen.dart`) has colored leading icons, size 26,
  one color per action (`AppColors.menuCategories` blue, `menuNewWords` pink, `menuRepeat`
  yellow); a disabled row fades its icon to α 0.4.
- Week strip (`WeekStrip` in `learn/widgets/week_strip.dart`), 16px under the Practice
  menu block: 7 tiles Mon–Sun (`AppStrings.weekdaysShort`, day names only, no dates), 6px
  apart, 52 tall, radius 14, fill `palette.card`, text 15 w600 -0.3 `onSurface`; today is
  filled `AppColors.menuNewWords` pink with `AppColors.onAccent` (white) text.

## Text

- Secondary labels (level, hints, captions): `palette.mutedText`.
- All text uses the theme font — the word card too (no decorative fonts; Fraunces/Lora were
  dropped: the user found the hooked letters too fancy). Word card: "der Hund (die Hunde)" as one
  left-aligned text, 32 w700, letter spacing -0.8, line height 1.1 — the plural continues the
  line in brackets, same style and color (only the article is colored); long ones wrap.
  Translation 32 w700, -0.8, left-aligned (bolder for the accent card style; the user kept
  the system font instead of a geometric one). Examples and the
  definition (`example_tile.dart`): theme font 16 (was 17: long sentences wrapped too much),
  `onSurface` (white), regular; the highlighted word w700 in `palette.markText` on
  `palette.markFill` — dark: lime text, no fill; light: dark text on a lime marker (α 0.6;
  user's choice, lime text on white is 1.2:1). Opened translations under them are
  `mutedText` gray with their marked word highlighted the same way (user's choice: accent in
  both lines).
  Expand chevron: 11px
  `AppIcons.caretDownBold` (Phosphor Bold, `assets/fonts/PhosphorBold.ttf`), 8px gap to the text.
- Articles are colored by gender with `AppColors.forArticle` on the word card. The plural
  article is always `die` (`Word.pluralWithArticle`).
- Translations are shown as stored (lowercase); don't capitalize them.
- No hardcoded UI text: add a key to every `assets/data/ui/*.json` and a getter in `AppStrings`.

## Animations

Judge smoothness only in `flutter run --profile` on a device; debug mode always stutters.
Prefer `Curves.easeOutCubic` for things that open or grow.

**Reduce Motion** (iOS setting, `MediaQuery.disableAnimationsOf(context)`) is respected: big
moves become short fades, bounce goes away. Card flight → the card fades out in place (200 ms),
undo fades it in; snap-back spring without overshoot; bottom bar — no lens, 150 ms slide; word
detail card — fade, no hero flight. Dragging still follows the finger (direct manipulation
stays). New motion must follow the same rule.

**Text size**: the iOS text size is followed up to ×1.3 (`MediaQuery.withClampedTextScaling` in
`main.dart`); fixed-height controls must fit their text at ×1.3.

## Settings

`SettingsScreen`: `TabTitle`, then per category a gray name
(`MenuRow.hintStyle`, not uppercase, 8 from the left like the title, 20 above) and a
`GroupedCard` of `MenuRow`s (`lib/ui/core/widgets/menu_row.dart`, shared with the Learn menu:
title 17 w600 -0.4, gray hint 15 w600 -0.3). **No icons in settings rows** (user removed them;
the Learn menu keeps its colored icons). Rows use `compact: true`: line height 1.12, 4px above
the hint. All gray settings text (hints, category names, slow/fast, reset dialog body) is
`AppPalette.softHint` via `MenuRow.hintStyle(context, soft: true)`; in the light theme it equals
the level word count (mutedText 50% lighter). Reset all progress: title in `decisionRed`, no hint line, trailing
`AppIcons.arrowCounterClockwise` 22 in `decisionRed`.

- Switches: `AppSwitch` (`lib/ui/core/widgets/app_switch.dart`), same on both platforms: track
  60×31, oval white thumb 37×25 (wider than tall, user's choice), on = `AppColors.lime`,
  off = `subtleButton`; the whole row toggles. iOS behavior:
  tap toggles, the thumb can be dragged (snaps to the nearer side, a flick > 300 px/s decides
  by direction), stretches 6px toward the middle while pressed, track color lerps with the
  thumb, `HapticFeedback.lightImpact` on change.
- Theme: a value row like the language rows ("Тема" … accent current value) opening a choice
  sheet: same as system / dark / light (user replaced the segmented switch).
- Language and theme rows (`SettingsValueRow` in `settings_rows.dart`): current choice as `palette.accentText` trailing text,
  no chevron; "Как в системе" when following the device. Pick-one sheets use `showChoiceSheet` (`lib/ui/core/widgets/choice_sheet.dart`). Language
  sheet (`language_sheet.dart`, the same for the interface and the word language): title, then a
  preview card (`palette.card`, radius 20, padding 20/28, centered) with the greeting of the
  chosen language ("Привет", 40 w700 -0.8 `accentText`) and a gray line under it in that language
  ("Меню и тексты на русском" / "Переводы слов на русском", 15 w500 `mutedText`), crossfading
  on change; then the `GroupedCard` — first row "Как в системе" with the language it gives now as
  a gray subtitle, then the languages; no flags; chosen one `accentText` + `checkCircle`. A tap
  applies right away and the sheet stays open (the interface language redraws the sheet too);
  "Готово" (`SheetDoneButton`) or a swipe closes it.
- Bottom sheets' drag handle (`AppTheme` → `bottomSheetTheme.dragHandleColor`): quiet, just off the
  sheet background — light: background 10% darker, dark: background 20% lighter.
- Speech rate: a `MenuRow` header, then a slider (track 6, filled `AppColors.lime`, unfilled
  `palette.sliderTrack` soft pastel gray, white pill thumb 30×20 with the switch's shadow
  (`_PillThumbShape` in `speed_row.dart`), no ripple, no value indicator; `SliderThemeData.padding` 16 horizontal, so
  the track is level with the row text; slow / fast labels at the same 16 edges) and slow / fast 13 gray under it.
- Dialogs: `showConfirmDialog` (`lib/ui/core/widgets/confirm_dialog.dart`) — `palette.card`,
  radius 20, title `AppListText.title`, body gray hint, buttons 17 w600 (cancel `onSurface`,
  action in its color: reset red, "open settings" `accentText`). Don't style an AlertDialog inline.
- All picker sheets go through `showSheet` (`choice_sheet.dart`): drag handle, title, content on
  the screen background. Several-at-once picks: `showMultiChoiceSheet` (applied on each tap,
  the last one can't be turned off), same rows as `showChoiceSheet`.
- Reminders (`RemindersCategory`, `reminders_category.dart`): category "Уведомления" with the main
  switch; while on, two more categories: "О чём напоминать" (switches "Повторение слов" / "Новые
  слова" with gray hints; both off = no reminders) and "Расписание" with value
  rows "Дни" ("Каждый день" / "Будни" / "Выходные" / "Пн, Ср, Пт"; full day names in the
  multi-choice sheet), "Сколько раз в день" (1–3, choice sheet) and one "Время" row per reminder
  ("Время 1", "Время 2" when several), value "09:00". Time sheet (`time_sheet.dart`): iOS-style
  looping wheels for hours and minutes, 24-hour, tabular digits 24 w500, in a `palette.card`
  block radius 20, 220 tall, `subtleButton` band radius 12 behind the selected row, haptic tick
  per step; full-width "Готово" `FilledButton` 52 tall radius 14; the value applies on close.

## Progress chart

`ProgressScreen` (Progress tab): title like the other tabs, then the streak block, the word
goal block, then a period switch, then one
`palette.card` block (radius 20) with `ProgressChart`, then the totals: a gray header
(`_TotalsHeader`, `MenuRow.hintStyle(soft: true)`, 20 above, 8 below) naming the number
columns — the period ("7 дней") and "Всего" — and a `GroupedCard` (`_TotalRow`: 12px status
dot, 12 gap, name in `AppListText.subtitle`, then the numbers in `AppListText.title`,
right-aligned in 76-wide columns; padding 16/14), top of the stack first: learned, review,
learning, known. Period column = the sum of the bars (`periodTotals`); "Всего" = words in
each status now (`latestCounts`). With "all time" selected only the "Всего" column shows
(the two would repeat). The list doubles as the chart's legend, so the chart has none.

- Period switch (`_PeriodSwitch`): one `palette.card` block, radius 14, padding 4; four equal
  segments 36 tall, radius 10 — 7 / 30 / 90 days / all time. Selected: solid `AppColors.lime`
  fill, `onLime` (black) text; others `onSurface`; 14 w600 -0.3.
- Bars show only their own period's activity (user's choice, not the running stock):
  7 and 30 days — a bar per day, 90 days — per week (Monday start), all time — per calendar
  month (label "ноя", `AppStrings.monthShort`). See `chartBars`.
- Chart (`progress_chart.dart`, its `CustomPainter`s in the part file
  `progress_chart_painters.dart`): stacked bars, bottom to top known (soft light
  gray `AppColors.chartKnown` #C7C7CC in both themes — white in the lists, gray here by the
  user's choice), learning (pink),
  review (yellow), learned (green); colors via `ProgressChart.colorFor`, the legend dots too.
  2px gaps between segments, radius 6; the lowest segment stands on the axis: no gap under it,
  square bottom corners. Bar 80% of its slot, at most 28 wide. Neighbouring bars are
  joined per status by bands (same color α 0.22, cubic curves). x labels 12 w600 `mutedText`,
  3px below the grid, a short date with the month abbreviated (`AppStrings.dateShort`:
  "16 ноя", "16 Nov", "11月 16日"); if any label is wider than its column, all break into two
  lines (day / month, line height 1.05). Slots narrower than 36 scroll sideways, opening at
  the latest bar.
- Every non-empty segment shows its word count centered (14 regular w400, -0.3, always black
  `AppColors.chartCount` — all fills are light) and is at least square (min height = bar
  width + the 2px gap); the rest of the height is linear, one scale for all bars. Y axis
  (34 wide, 12 w600 `mutedText`) and a dashed grid in `AppColors.divider` stay: round steps
  1/2/5/10/…, ≤ 4 lines above 0; the axis top is the tallest bar × 1.5 (headroom, user's
  choice); if the minimums make a bar too tall, the scale shrinks so it still leaves that
  headroom, and the ticks follow (`ProgressChart._layout`).
- Vertical grid: dashed lines between columns, same style as the horizontal ones (1px,
  4 on / 4 off, `AppColors.divider`), plot height only; scroll with the bars. (Zebra column
  backings were tried and rejected: the user wants plain dashes both ways.) A segment raised to the minimum looks bigger than its value on
  the axis — intended, the user's choice.
- Layers — a funnel (user's choice): known — "already know"; pink "Изучаю" — words taken to
  learn; yellow "Повторено" — in a bar, every word reviewed that day (old ones too, summed
  over the days of a week/month; `DaySnapshot.reviewed`), in "Всего" the unique words
  recalled at least once; green "Выучено" — interval ≥ 21 days. A bar's layers are the growth
  since the previous bar (drops count as 0).

## Daily streak

`StreakCard` (`lib/ui/progress/widgets/streak_card.dart`), the first block on the Progress tab,
12 above the word goal: `palette.card`, radius 20, padding 16. Top row: `AppIcons.fireFill`
28 — `AppColors.streak` orange #FF9500 once the user studied today, `palette.mutedText` before —
8 gap, "5 дней подряд" (`AppStrings.streakDays`, plural) 20 w700 -0.5 `onSurface`, and on the
right "Рекорд: 12" in `MenuRow.hintStyle(soft: true)`. 14 below: this week Mon–Sun, each a
12 w600 day name (`mutedText`, today `onSurface`) over a 30px circle, 6 apart vertically:
studied = `AppColors.streak` fill, else `palette.subtleButton`; today not studied yet gets a
1.5px `AppColors.streak` ring. Rule (`StudyStreak`, domain): a day counts if the user reviewed a
word or took a new one to learn ("Уже знаю" doesn't); today not studied yet doesn't break the
streak before midnight. The Learn tab's week strip doesn't show studied days (user's choice).

## Word goal

`GoalCard` (`lib/ui/progress/widgets/goal_card.dart`), under the streak, 12 above the period
switch, same block as the streak (`palette.card`, radius 20, padding 16). Top row: "12 из 100
слов" (`AppStrings.wordGoalProgress`) in `StreakCard.titleStyle`, on the right "Цель" in
`MenuRow.hintStyle(soft: true)`; 14 below a `ProgressBar` (`ui/core/widgets/progress_bar.dart`,
8 tall) filled `AppColors.statusLearned` green. Counts green + "Уже знаю" words
(`StatusCounts.mastered`, user's choice); the goal is set in Settings → Прогресс (50–1000).
