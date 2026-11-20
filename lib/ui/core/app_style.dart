import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/app_settings.dart';
import 'package:deutschlernen/domain/models/word_status.dart';

abstract final class AppSizes {
  /// Horizontal inset of the card content from the card edge.
  static const cardInset = 24.0;

  /// Widest a tab or a list gets on big screens (iPad), with its gutters.
  static const maxContentWidth = 640.0;

  /// Bottom padding of a scrolling screen: 24 above the bottom inset. In the
  /// shell that inset includes the floating bar (Scaffold.extendBody), so
  /// the last items stay reachable above it.
  static double bottomPadding(BuildContext context) =>
      24 + MediaQuery.paddingOf(context).bottom;
}

/// Colors that differ between the dark and the light theme.
/// Read them with `AppPalette.of(context)`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.card,
    required this.subtleButton,
    required this.mutedText,
    required this.sliderTrack,
    required this.secondaryText,
    required this.softHint,
    required this.levelPercent,
    required this.markText,
    required this.markFill,
    required this.accentText,
  });

  final Color background; // behind the cards
  final Color card;
  final Color subtleButton; // barely different from the card
  final Color mutedText; // secondary labels
  final Color sliderTrack; // unfilled part of a slider: soft pastel gray

  /// Second line of a level row (word count). Light: mutedText 50% lighter
  /// (user's choice), on white it looked too heavy.
  final Color secondaryText;

  /// Settings hints and category names. Light: same as [secondaryText];
  /// dark: the quiet gray (AppColors.quietText).
  final Color softHint;

  /// "40 %" on a level row: between the main text and mutedText; light
  /// 50% lighter, like the count.
  final Color levelPercent;

  /// Highlighted word in the card's examples. Dark: accent text, no fill;
  /// light: a pastel accent on white is unreadable, so an accent marker
  /// under dark text (user's choice). Set per accent by [withAccent].
  final Color markText;
  final Color markFill;

  /// Accent text and icons on the background or a card (chosen values,
  /// checks, play buttons). Dark: the accent itself; light: its dark shade,
  /// as the pastel one on white is unreadable. Accent fills are
  /// `colorScheme.primary`. Set per accent by [withAccent].
  final Color accentText;

  static const dark = AppPalette(
    background: Color(0xFF0B0B0D),
    card: Color(0xFF151517),
    subtleButton: Color(0xFF222225),
    mutedText: Color(0xFF8C8C8C), // rgb(140,140,140)
    sliderTrack: Color(0xFF3A3A3E),
    secondaryText: Color(0xFF8C8C8C),
    softHint: Color(0xFF696D72),
    levelPercent: Color(0xFFB6B7BA),
    // The accent ones are placeholders: [withAccent] sets them.
    markText: Color(0x00000000),
    markFill: Color(0x00000000),
    accentText: Color(0x00000000),
  );

  static const light = AppPalette(
    background: Color(0xFFF2F2F5),
    card: Color(0xFFFFFFFF),
    subtleButton: Color(0xFFEDEDF0),
    mutedText: Color(0xFF6A6A70),
    sliderTrack: Color(0xFFE1E1E6),
    secondaryText: Color(0xFFB5B5B8),
    softHint: Color(0xFFB5B5B8),
    levelPercent: Color(0xFF9C9C9E),
    markText: Color(0xFF080808), // the light theme's onSurface
    // The accent ones are placeholders: [withAccent] sets them.
    markFill: Color(0x00000000),
    accentText: Color(0x00000000),
  );

  /// This palette with the accent-dependent colors of [accent].
  AppPalette withAccent(AccentColor accent, Brightness brightness) =>
      brightness == Brightness.dark
      ? copyWith(markText: accent.fill, accentText: accent.fill)
      : copyWith(
          markFill: accent.fill.withValues(alpha: 0.6),
          accentText: accent.lightText,
        );

  static AppPalette of(BuildContext context) =>
      Theme.of(context).extension<AppPalette>() ?? dark;

  @override
  AppPalette copyWith({
    Color? background,
    Color? card,
    Color? subtleButton,
    Color? mutedText,
    Color? sliderTrack,
    Color? secondaryText,
    Color? softHint,
    Color? levelPercent,
    Color? markText,
    Color? markFill,
    Color? accentText,
  }) => AppPalette(
    background: background ?? this.background,
    card: card ?? this.card,
    subtleButton: subtleButton ?? this.subtleButton,
    mutedText: mutedText ?? this.mutedText,
    sliderTrack: sliderTrack ?? this.sliderTrack,
    secondaryText: secondaryText ?? this.secondaryText,
    softHint: softHint ?? this.softHint,
    levelPercent: levelPercent ?? this.levelPercent,
    markText: markText ?? this.markText,
    markFill: markFill ?? this.markFill,
    accentText: accentText ?? this.accentText,
  );

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      card: Color.lerp(card, other.card, t)!,
      subtleButton: Color.lerp(subtleButton, other.subtleButton, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      sliderTrack: Color.lerp(sliderTrack, other.sliderTrack, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      softHint: Color.lerp(softHint, other.softHint, t)!,
      levelPercent: Color.lerp(levelPercent, other.levelPercent, t)!,
      markText: Color.lerp(markText, other.markText, t)!,
      markFill: Color.lerp(markFill, other.markFill, t)!,
      accentText: Color.lerp(accentText, other.accentText, t)!,
    );
  }
}

/// The colors of each [AccentColor] (user's choice in Settings).
extension AccentColors on AccentColor {
  /// Fills: switches, sliders, selected segments, main buttons. Content on
  /// it is black (`colorScheme.onPrimary`) in both themes.
  Color get fill => switch (this) {
    AccentColor.blue => const Color(0xFFA8C8FF), // pastel sky blue
    AccentColor.lime => const Color(0xFFD6F566),
    AccentColor.yellow => const Color(0xFFFFC72C),
  };

  /// Accent text and icons in the light theme: a dark shade, ≥ 4.5:1 on white.
  Color get lightText => switch (this) {
    AccentColor.blue => const Color(0xFF3D6DB8), // 5.2:1
    AccentColor.lime => const Color(0xFF5E7A00), // 4.9:1
    AccentColor.yellow => const Color(0xFF9A6700), // 4.9:1
  };
}

abstract final class AppTheme {
  // Each one is built once: ColorScheme.fromSeed is costly, and MaterialApp
  // asks for the themes on every settings change.
  static final _cache = <(Brightness, AccentColor), ThemeData>{};

  static ThemeData dark(AccentColor accent) => _cached(Brightness.dark, accent);

  static ThemeData light(AccentColor accent) =>
      _cached(Brightness.light, accent);

  static ThemeData _cached(Brightness brightness, AccentColor accent) => _cache
      .putIfAbsent((brightness, accent), () => _build(brightness, accent));

  static ThemeData _build(Brightness brightness, AccentColor accent) {
    final palette =
        (brightness == Brightness.dark ? AppPalette.dark : AppPalette.light)
            .withAccent(accent, brightness);
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        // The seed only tints the neutral grays; the accent is set below.
        seedColor: AppColors.accentBlue,
        brightness: brightness,
        // The accent fill (switches, selected states, default buttons and
        // spinners) with black content, in both themes.
        primary: accent.fill,
        onPrimary: AppColors.onAccentFill,
        // Light theme text: near-black rgb(8,8,8) (user's choice).
        onSurface: brightness == Brightness.light
            ? const Color(0xFF080808)
            : null,
      ),
      // The cursor and handles are drawn on the background: readable accent.
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: palette.accentText,
        selectionColor: accent.fill.withValues(alpha: 0.4),
        selectionHandleColor: palette.accentText,
      ),
      scaffoldBackgroundColor: palette.background,
      // Sheet drag handle: quiet, just off the sheet's background (user's
      // choice) — a bit darker in light, a bit lighter in dark.
      bottomSheetTheme: BottomSheetThemeData(
        dragHandleColor: brightness == Brightness.light
            ? AppColors.darken(palette.background, 0.1)
            : AppColors.lighten(palette.background, 0.2),
      ),
      extensions: [palette],
    );
  }
}

abstract final class AppColors {
  // The "bad" side of the answer buttons ("Начать учить", "Забыл"); the
  // good side is the accent. See CardsScreen.
  static const decisionRed = Color(0xFFFF3B30); // saturated red
  // Only the color seed, the Learn menu's categories icon and the fallback
  // article color; the app's accent is [AccentColors] (Settings).
  static const accentBlue = Color(0xFF1AA7FF);
  // Text and icons on the accent fill (`colorScheme.onPrimary`): black in
  // both themes, every accent is pastel.
  static const onAccentFill = Color(0xFF000000);
  static const switchThumbShadow = Color(0x2E000000); // black, α 0.18

  // Icons of the learn menu rows (categories / new words / repeat).
  static const menuCategories = accentBlue;
  static const menuNewWords = Color(0xFFFF5C8A); // pink
  static const menuRepeat = Color(0xFFFFC83D); // yellow

  // Text on a saturated accent fill (e.g. today in the week strip): white
  // in both themes, since the fill doesn't change with the theme.
  static const onAccent = Color(0xFFFFFFFF);

  // Progress chart. "Already know" is a soft light gray there (white in the
  // lists); all segment fills are light, so the counts on them are black in
  // both themes.
  static const chartKnown = Color(0xFFC7C7CC);
  static const chartCount = Color(0xFF000000);

  // Streak flame and studied days on the Progress tab (iOS orange).
  static const streak = Color(0xFFFF9500);

  // Word status strips in the word lists (new words use a theme gray).
  static const statusLearning = Color(0xFFFF5C8A); // pink
  static const statusReview = Color(0xFFFFA530); // orange-yellow
  static const statusLearned = Color(0xFF34C759); // green

  // Answer feedback.
  static const correct = Color(0xFF3DDC84);
  static const wrong = Color(0xFFFF6B6B);

  // Article colors by grammatical gender.
  static const articleMasculine = Color(0xFF1AA7FF); // der
  static const articleNeuter = Color(0xFFFFC83D); // das
  static const articleFeminine = Color(0xFFFF5C8A); // die

  /// Mixes [color] with black: amount 0.2 = 20% darker.
  static Color darken(Color color, double amount) =>
      Color.lerp(color, const Color(0xFF000000), amount)!;

  /// Mixes [color] with white: amount 0.25 = 25% lighter.
  static Color lighten(Color color, double amount) =>
      Color.lerp(color, const Color(0xFFFFFFFF), amount)!;

  /// Lines between rows in blocks (GroupedCard, examples), chart grid.
  /// Light theme: a fixed soft gray (user's choice), the derived one was
  /// too dark on white.
  static Color divider(ColorScheme colors) =>
      colors.brightness == Brightness.light
      ? const Color(0xFFE6E6E6) // rgb(230,230,230)
      : _gray(colors);

  /// The old divider gray, still the base of [quietText].
  static Color _gray(ColorScheme colors) => darken(colors.outlineVariant, 0.18);

  /// Quiet gray for low-priority text and icons (search hint, word counts):
  /// [_gray] moved 30% toward the text color, so it is a bit lighter in the
  /// dark theme and a bit darker in the light one. Not based on [divider]:
  /// the light divider is too pale for text.
  static Color quietText(ColorScheme colors) =>
      Color.lerp(_gray(colors), colors.onSurface, 0.3)!;

  /// Color of a word's status: the strip in word lists and the square on
  /// the opened card use the same one.
  static Color forWordStatus(WordStatus status, ColorScheme colors) =>
      switch (status) {
        // Gray between the light secondary text and the dark divider.
        WordStatus.newWord => Color.lerp(
          colors.onSurfaceVariant,
          divider(colors),
          0.6,
        )!,
        WordStatus.learning => statusLearning,
        WordStatus.review => statusReview,
        WordStatus.learned => statusLearned,
        // Main text color: white in the dark theme (black in the light one).
        WordStatus.known => colors.onSurface,
      };

  static Color forArticle(String article) {
    return switch (article.toLowerCase()) {
      'der' => articleMasculine,
      'das' => articleNeuter,
      'die' => articleFeminine,
      _ => accentBlue, // fallback for unknown articles
    };
  }
}

/// Text of list rows (word lists, category list): every line has the same
/// size, line height and spacing; color and weight tell them apart.
/// title = the German word / category name, subtitle = the translation /
/// word count, caption = the gray line above a word (status).
abstract final class AppListText {
  static const _size = 16.0;
  static const _height = 1.27; // a bit tighter than the default
  static const _spacing = -0.2; // slightly condensed

  /// Gap between the lines of one row.
  static const gap = 2.2;

  static TextStyle title(ColorScheme colors) => TextStyle(
    // onSurface: white in the dark theme, near-black in the light one.
    color: colors.onSurface,
    fontSize: 17, // a touch bigger than the other lines
    fontWeight: FontWeight.bold,
    height: _height,
    letterSpacing: _spacing,
  );

  static TextStyle subtitle(ColorScheme colors) => TextStyle(
    color: colors.onSurface,
    fontSize: _size,
    fontWeight: FontWeight.w600,
    height: _height,
    letterSpacing: _spacing,
  );

  static TextStyle caption(BuildContext context) => TextStyle(
    color: AppPalette.of(context).mutedText,
    fontSize: _size,
    fontWeight: FontWeight.w600,
    height: _height,
    letterSpacing: _spacing,
  );
}
