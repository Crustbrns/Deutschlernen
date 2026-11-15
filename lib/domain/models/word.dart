import 'package:deutschlernen/domain/models/example_sentence.dart';

class Word {
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
}
