import 'package:flutter/foundation.dart';
import 'package:deutschlernen/data/services/asset_service.dart';
import 'package:deutschlernen/domain/models/app_language.dart';
import 'package:deutschlernen/domain/models/example_sentence.dart';
import 'package:deutschlernen/domain/models/word.dart';

class WordRepository {
  WordRepository({required this._assetService});

  final AssetService _assetService;

  /// German content merged with the translations and examples of [language].
  Future<List<Word>> getWords(AppLanguage language) async {
    final words = await _assetService.loadWords();

    Map<String, dynamic> translations;
    try {
      translations = await _assetService.loadTranslations(language.code);
    } catch (e) {
      debugPrint('Could not load ${language.code} translations: $e');
      translations = const {};
    }

    return [
      for (final json in words)
        _toWord(
          json,
          translations[json['id']] as Map<String, dynamic>?,
          language,
        ),
    ];
  }

  Word _toWord(
    Map<String, dynamic> json,
    Map<String, dynamic>? translation,
    AppLanguage language,
  ) {
    final id = json['id'] as String;

    final word = translation?['word'] as String?;
    if (word == null || word.isEmpty) {
      debugPrint('Missing ${language.code} translation for "$id"');
    }

    final examples = (translation?['examples'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();

    return Word(
      id: id,
      article: json['article'] as String,
      german: json['lemma'] as String,
      plural: json['plural'] as String?,
      level: json['level'] as String,
      transcription: json['transcription'] as String,
      definition: json['definition'] as String,
      translation: word ?? '',
      examples: [
        for (final example in examples)
          ExampleSentence(
            german: example['german'] as String,
            translation: example['translation'] as String,
          ),
      ],
    );
  }
}
