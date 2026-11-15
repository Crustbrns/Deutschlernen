import 'package:deutschlernen/domain/models/example_sentence.dart';

class Word {
  /// Levels (categories) shown in the vocabulary tab, in this order.
  /// Every word's [level] is one of them.
  static const levels = ['A1', 'A2', 'B1', 'B2'];

  const Word({
    required this.id,
    required this.article,
    required this.german,
    required this.plural,
    required this.translation,
    required this.level,
    required this.transcription,
    required this.definition,
    required this.definitionTranslation,
    required this.examples,
  });

  final String id;
  final String article; // der / die / das
  final String german; // without article
  final String? plural; // null if the word has no common plural
  final String translation; // in the selected language
  final String level; // A1, A2, B1 ...
  final String transcription;
  final String definition; // German explanation
  final String? definitionTranslation; // null if not translated yet
  final List<ExampleSentence> examples;

  String get withArticle => '$article $german';

  /// German plural always takes "die", whatever the singular article is.
  String? get pluralWithArticle => plural == null ? null : 'die $plural';

  /// True when [input] is the translation or the German word (with or without
  /// the article). Ignores case, extra spaces and trailing punctuation.
  bool accepts(String input) {
    final given = _normalize(input);
    if (given.isEmpty) return false;
    return {translation, german, withArticle}.map(_normalize).contains(given);
  }

  static String _normalize(String text) => text
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll(RegExp(r'[.!?。！？]+$'), '');

  /// Search: [query] is part of the German word (with article or plural)
  /// or of the translation. Ignores case and umlauts, so "hauser" finds
  /// "Häuser" for people without a German keyboard.
  bool matches(String query) {
    final q = _fold(query.trim());
    if (q.isEmpty) return true;
    return [withArticle, ?plural, translation].any((s) => _fold(s).contains(q));
  }

  static String _fold(String text) => text
      .toLowerCase()
      .replaceAll('ä', 'a')
      .replaceAll('ö', 'o')
      .replaceAll('ü', 'u')
      .replaceAll('ß', 'ss');

  /// Grammatical gender by article: der → m., die → f., das → n.
  /// null when there is no known article, i.e. the word is not a noun.
  String? get genderMark => switch (article.toLowerCase()) {
    'der' => 'm.',
    'die' => 'f.',
    'das' => 'n.',
    _ => null,
  };
}
