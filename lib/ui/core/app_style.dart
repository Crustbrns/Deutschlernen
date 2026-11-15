import 'package:material_ui/material_ui.dart';

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
    required this.decisionDivider,
  });

  final Color background; // behind the cards
  final Color card;
  final Color subtleButton; // barely different from the card
  final Color mutedText; // secondary labels
  final Color decisionDivider;

  /// The decision buttons use the muted text color.
  Color get decisionText => mutedText;

  static const dark = AppPalette(
    background: Color(0xFF0B0B0D),
    card: Color(0xFF151517),
    subtleButton: Color(0xFF222225),
    mutedText: Color(0xFF8C8C8C), // rgb(140,140,140)
    decisionDivider: Color(0xFF5A5A5A), // rgb(90,90,90)
  );

  static const light = AppPalette(
    background: Color(0xFFF2F2F5),
    card: Color(0xFFFFFFFF),
    subtleButton: Color(0xFFEDEDF0),
    mutedText: Color(0xFF6A6A70),
    decisionDivider: Color(0xFFC4C4CA),
  );

  static AppPalette of(BuildContext context) =>
      Theme.of(context).extension<AppPalette>() ?? dark;

  @override
  AppPalette copyWith({
    Color? background,
    Color? card,
    Color? subtleButton,
    Color? mutedText,
    Color? decisionDivider,
  }) => AppPalette(
    background: background ?? this.background,
    card: card ?? this.card,
    subtleButton: subtleButton ?? this.subtleButton,
    mutedText: mutedText ?? this.mutedText,
    decisionDivider: decisionDivider ?? this.decisionDivider,
  );

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      card: Color.lerp(card, other.card, t)!,
      subtleButton: Color.lerp(subtleButton, other.subtleButton, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      decisionDivider: Color.lerp(decisionDivider, other.decisionDivider, t)!,
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
  static const decisionKnown = Color(0xFFFF4D4F); // left button highlight: red
  static const decisionLearn = Color(0xFF34C759); // right button highlight: green
  static const accentBlue = Color(0xFF1AA7FF);
  static const accentTeal = Color(0xFF2EE6D6);

  // Icons of the learn menu rows (categories / new words / repeat).
  static const menuCategories = accentBlue;
  static const menuNewWords = Color(0xFFFF5C8A); // pink
  static const menuRepeat = Color(0xFFFFC83D); // yellow

  // Word status strips in the word lists (new words use a theme gray).
  static const statusLearning = Color(0xFFFF5C8A); // pink
  static const statusReview = Color(0xFFFFC83D); // yellow
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

  static Color forArticle(String article) {
    return switch (article.toLowerCase()) {
      'der' => articleMasculine,
      'das' => articleNeuter,
      'die' => articleFeminine,
      _ => accentBlue, // fallback for unknown articles
    };
  }
}

abstract final class AppFonts {
  /// Soft serif with "wonky" hooked letters (h, n, m), for the German word.
  static const display = 'Fraunces';

  /// A variable font is one file with adjustable axes instead of
  /// separate files per weight, so the axes are set here explicitly.
  /// [opticalSize]: letter shapes tuned for that text size in px
  /// (big = finer details, small = sturdier and wider).
  static List<FontVariation> displayVariations({
    required double weight,
    required double opticalSize,
  }) => [
    FontVariation('wght', weight),
    FontVariation('opsz', opticalSize),
    const FontVariation('SOFT', 50), // slightly rounded corners
    const FontVariation('WONK', 1), // the hooked, leaning letter variants
  ];

  /// German word: semi-bold, 44px.
  static final word = displayVariations(weight: 600, opticalSize: 72);

  /// Plural line: regular, 21px.
  static final plural = displayVariations(weight: 400, opticalSize: 21);

  /// Translation of the word. Fraunces has no Cyrillic, so translations use
  /// Lora, a similar soft serif that covers Russian and Ukrainian too.
  /// Chinese has no glyphs in it and falls back to the system font.
  static const translation = 'Lora';

  /// Lora's only axis is weight.
  static const translationVariations = [FontVariation('wght', 600)];
}
