import 'package:material_ui/material_ui.dart';

abstract final class AppSizes {
  /// Horizontal inset of the card content from the card edge.
  static const cardInset = 24.0;
}

abstract final class AppColors {
  static const background = Color(0xFF0B0B0D);
  static const card = Color(0xFF151517);
  static const subtleButton = Color(0xFF222225); // barely lighter than card
  static const mutedText = Color(0xFF8C8C8C); // rgb(140,140,140), secondary labels
  static const decisionText = mutedText;
  static const decisionDivider = Color(0xFF5A5A5A); // rgb(90,90,90)
  static const decisionKnown = Color(0xFFFF4D4F); // left button highlight: red
  static const decisionLearn = Color(0xFF34C759); // right button highlight: green
  static const accentBlue = Color(0xFF1AA7FF);
  static const accentTeal = Color(0xFF2EE6D6);

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
