import 'package:deutschlernen/domain/models/word.dart';

class WordRepository {
  Future<List<Word>> getWords() async {
    // Hardcoded for now. Later this can call a service (API, database).
    return const [
      Word(german: 'der Hund', english: 'dog'),
      Word(german: 'die Katze', english: 'cat'),
    ];
  }
}