import 'package:deutschlernen/domain/models/example_sentence.dart';
import 'package:deutschlernen/domain/models/word.dart';

class WordRepository {
  Future<List<Word>> getWords() async {
    return const [
      Word(
        article: 'der',
        german: 'Tee',
        translation: 'чай',
        level: 'A1',
        transcription: '[te:]',
        definition: 'Ein heißes Getränk, das man aus getrockneten Blättern zubereitet.',
        examples: [
          ExampleSentence(german: 'Ich trinke gerne Tee.', translation: 'Я люблю пить чай.'),
          ExampleSentence(german: 'Der Tee ist heiß.', translation: 'Чай горячий.'),
          ExampleSentence(german: 'Möchtest du einen Tee?', translation: 'Хочешь чай?'),
          ExampleSentence(german: 'Ich bereite einen Tee zu.', translation: 'Я завариваю чай.'),
        ],
      ),
      Word(
        article: 'der',
        german: 'Hund',
        translation: 'собака',
        level: 'A1',
        transcription: '[hʊnt]',
        definition: 'Ein Tier, das bellt und oft als Haustier gehalten wird.',
        examples: [
          ExampleSentence(german: 'Der Hund spielt im Garten.', translation: 'Собака играет в саду.'),
          ExampleSentence(german: 'Ich gehe mit dem Hund spazieren.', translation: 'Я гуляю с собакой.'),
          ExampleSentence(german: 'Mein Hund ist sehr klein.', translation: 'Моя собака очень маленькая.'),
        ],
      ),
      Word(
        article: 'das',
        german: 'Haus',
        translation: 'дом',
        level: 'A1',
        transcription: '[haʊs]',
        definition: 'Ein Gebäude, in dem Menschen wohnen.',
        examples: [
          ExampleSentence(german: 'Das Haus ist groß.', translation: 'Дом большой.'),
          ExampleSentence(german: 'Wir kaufen ein Haus.', translation: 'Мы покупаем дом.'),
          ExampleSentence(german: 'Ich gehe nach Hause.', translation: 'Я иду домой.'),
        ],
      ),
      Word(
        article: 'die',
        german: 'Katze',
        translation: 'кошка',
        level: 'A1',
        transcription: '[ˈkatsə]',
        definition: 'Ein kleines Haustier, das miaut und gern Mäuse jagt.',
        examples: [
          ExampleSentence(german: 'Die Katze schläft auf dem Sofa.', translation: 'Кошка спит на диване.'),
          ExampleSentence(german: 'Ich habe eine schwarze Katze.', translation: 'У меня чёрная кошка.'),
          ExampleSentence(german: 'Die Katze trinkt Milch.', translation: 'Кошка пьёт молоко.'),
        ],
      ),
    ];
  }
}