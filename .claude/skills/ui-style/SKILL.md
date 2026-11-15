---
name: ui-style
description: Visual rules of the Deutschlernen app — colors, surfaces, buttons, icons, lists and spacing. Use whenever adding or changing any screen, widget, button, icon, list or other UI in lib/ui, even small tweaks, so new UI matches the existing look.
---

# Deutschlernen UI style

The app is dark-only. All colors, fonts and sizes come from `lib/ui/core/app_style.dart`
(`AppColors`, `AppFonts`, `AppSizes`). Never write a hex color in a widget: if a new
color is needed, add a named constant to `AppColors` with a short comment.

## Surfaces

| What | Color | Shape |
|---|---|---|
| Screen background | `AppColors.background` | — |
| Content block (lists, search results) | `AppColors.card`, **no outline** | radius 20 |
| Word card (learning and lookup) | `AppColors.card` + outline `colors.outlineVariant` α 0.4 | radius 32 |
| Text field | fill `AppColors.card`, outline `outlineVariant` α 0.4, focused `AppColors.accentBlue` | radius 20 |

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

Separate blocks are only for different kinds of content (e.g. a title, then a list).

## Buttons

- **Neutral / secondary** (mode buttons, close, small actions): fill `AppColors.subtleButton`,
  icon `colors.onSurface`, label `colors.onSurfaceVariant`. Rectangular ones have radius 14.
- **Round icon button** (close, undo, …): `RoundIconButton` (`lib/ui/core/widgets/round_icon_button.dart`) —
  `subtleButton` fill, 36×36, icon 20; disabled = same fill, faded icon. Don't use `filledTonal`.
- **Selected / active state**: fill `AppColors.accentBlue` α 0.14, border `AppColors.accentBlue`,
  icon and text `AppColors.accentBlue` (see `_ModeButton` in `answer_modes.dart`).
- **Primary action** (one per screen at most): `FilledButton`, radius 14.
- **Audio**: `PlayButton` (`lib/ui/core/widgets/play_button.dart`) in rows — blue, outlined.
  The word itself is played from the transcription pill on the word card.
- A button that sits over a transparent or dimmed background (overlay routes) always
  gets a fill, otherwise it blends with what is under it.
- In compact layouts set `tapTargetSize: MaterialTapTargetSize.shrinkWrap`, otherwise
  Material adds invisible padding up to 48px and spacing looks wrong.

## Icons

- Material **outlined** variants by default (`Icons.volume_up_outlined`, `Icons.edit_outlined`,
  `Icons.settings_outlined`, …). The filled variant only marks a selected state
  (bottom navigation: `home_outlined` → `home`).
- Exception: play uses `CupertinoIcons.play` (from `cupertino_ui`) — its triangle has rounded
  corners, Material's outlined play is sharp.
- Sizes: 20 in rows and small buttons, 24 default, 28 in large mode buttons.
- Colors: `colors.onSurfaceVariant` when inactive, `AppColors.accentBlue` when active,
  `colors.onSurface` on filled neutral buttons.

## Text

- Secondary labels (level, hints, captions): `AppColors.mutedText`.
- German word: `AppFonts.display` (Fraunces) with `AppFonts.word` variations; translation:
  `AppFonts.translation` (Lora). Plain UI text uses the theme font.
- Articles are colored by gender with `AppColors.forArticle` on the word card. The plural
  article is always `die` (`Word.pluralWithArticle`).
- Translations are shown as stored (lowercase); don't capitalize them.
- No hardcoded UI text: add a key to all four `assets/data/ui/*.json` and a getter in `AppStrings`.

## Animations

Judge smoothness only in `flutter run --profile` on a device; debug mode always stutters.
Prefer `Curves.easeOutCubic` for things that open or grow.
