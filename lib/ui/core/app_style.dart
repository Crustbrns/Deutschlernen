import 'package:material_ui/material_ui.dart';

abstract final class AppColors {
  static const background = Color(0xFF0B0B0D);
  static const card = Color(0xFF151517);
  static const accentBlue = Color(0xFF1AA7FF);
  static const accentTeal = Color(0xFF2EE6D6);

  // Article colors by grammatical gender.
  static const articleMasculine = Color(0xFF1AA7FF); // der
  static const articleNeuter = Color(0xFFFFC83D); // das
  static const articleFeminine = Color(0xFFFF5C8A); // die

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
  // Android maps 'serif' to Noto Serif, so no font files are needed.
  static const serif = 'serif';
}