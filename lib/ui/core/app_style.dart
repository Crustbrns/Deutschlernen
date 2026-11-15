import 'package:material_ui/material_ui.dart';

abstract final class AppSizes {
  /// Horizontal inset of the card content from the card edge.
  static const cardInset = 24.0;
}

abstract final class AppColors {
  static const background = Color(0xFF0B0B0D);
  static const card = Color(0xFF151517);
  static const subtleButton = Color(0xFF222225); // barely lighter than card
  static const accentBlue = Color(0xFF1AA7FF);
  static const accentTeal = Color(0xFF2EE6D6);

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
