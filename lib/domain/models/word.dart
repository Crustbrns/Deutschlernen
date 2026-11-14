import 'package:deutschlernen/domain/models/example_sentence.dart';

class Word {
  const Word({
    required this.article,
    required this.german,
    required this.translation,
    required this.level,
    required this.transcription,
    required this.definition,
    required this.examples,
  });

  final String article; // der / die / das
  final String german; // without article
  final String translation;
  final String level; // A1, A2, B1 ...
  final String transcription;
  final String definition;
  final List<ExampleSentence> examples;

  String get withArticle => '$article $german';
}