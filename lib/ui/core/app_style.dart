import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/domain/models/word_status.dart';

abstract final class AppSizes {
  /// Horizontal inset of the card content from the card edge.
  static const cardInset = 24.0;
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
  });

  final Color background; // behind the cards
  final Color card;
  final Color subtleButton; // barely different from the card
  final Color mutedText; // secondary labels

  static const dark = AppPalette(
    background: Color(0xFF0B0B0D),
    card: Color(0xFF151517),
    subtleButton: Color(0xFF222225),
    mutedText: Color(0xFF8C8C8C), // rgb(140,140,140)
  );

  static const light = AppPalette(
    background: Color(0xFFF2F2F5),
    card: Color(0xFFFFFFFF),
    subtleButton: Color(0xFFEDEDF0),
    mutedText: Color(0xFF6A6A70),
  );

  static AppPalette of(BuildContext context) =>
      Theme.of(context).extension<AppPalette>() ?? dark;

  @override
  AppPalette copyWith({
    Color? background,
    Color? card,
    Color? subtleButton,
    Color? mutedText,
  }) => AppPalette(
    background: background ?? this.background,
    card: card ?? this.card,
    subtleButton: subtleButton ?? this.subtleButton,
    mutedText: mutedText ?? this.mutedText,
  );

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      card: Color.lerp(card, other.card, t)!,
      subtleButton: Color.lerp(subtleButton, other.subtleButton, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
    );
  }
}

abstract final class AppTheme {
  static ThemeData dark() => _build(Brightness.dark, AppPalette.dark);

  static ThemeData light() => _build(Brightness.light, AppPalette.light);

  static ThemeData _build(Brightness brightness, AppPalette palette) {
    return ThemeData(
      brightness: brightness,
      colorSchemeSeed: AppColors.accentBlue,
      scaffoldBackgroundColor: palette.background,
      extensions: [palette],
    );
  }
}

abstract final class AppColors {
  // Decision button highlights. Which side is which depends on the card:
  // see CardsScreen (new word: left green / right red; recall: the reverse).
  static const decisionRed = Color(0xFFFF3B30); // saturated red
  static const decisionGreen = Color(0xFF30D158); // saturated green
  static const accentBlue = Color(0xFF1AA7FF);
  static const accentTeal = Color(0xFF2EE6D6);
  // Settings controls (switch on, slider, chosen language): deeper and
  // softer than accentBlue (iOS blue).
  static const softBlue = Color(0xFF0A84FF);
  static const switchThumbShadow = Color(0x2E000000); // black, α 0.18

  // Icons of the learn menu rows (categories / new words / repeat).
  static const menuCategories = accentBlue;
  static const menuNewWords = Color(0xFFFF5C8A); // pink
  static const menuRepeat = Color(0xFFFFC83D); // yellow

  // Text on a saturated accent fill (e.g. today in the week strip): white
  // in both themes, since the fill doesn't change with the theme.
  static const onAccent = Color(0xFFFFFFFF);

  // Level icons on the Categories tab: growth from a sprout to a peak.
  static const levelA1 = accentTeal; // sprout
  static const levelA2 = Color(0xFFFF5C8A); // pink tulip
  static const levelB1 = Color(0xFF34C759); // green tree
  static const levelB2 = accentBlue; // mountains

  // Progress chart. "Already know" is a soft light gray there (white in the
  // lists); all segment fills are light, so the counts on them are black in
  // both themes.
  static const chartKnown = Color(0xFFC7C7CC);
  static const chartCount = Color(0xFF000000);

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

  /// Lines between the example rows.
  static Color divider(ColorScheme colors) =>
      darken(colors.outlineVariant, 0.18);

  /// Quiet gray for low-priority text and icons (search hint, word counts):
  /// the divider color moved 30% toward the text color, so it is a bit
  /// lighter in the dark theme and a bit darker in the light one.
  static Color quietText(ColorScheme colors) =>
      Color.lerp(divider(colors), colors.onSurface, 0.3)!;

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
