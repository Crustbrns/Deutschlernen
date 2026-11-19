import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:deutschlernen/data/services/stored_map.dart';
import 'package:deutschlernen/domain/models/own_word.dart';

class OwnWordsRepository {
  static const _key = 'own_words';

  final _prefs = SharedPreferencesAsync();

  Future<List<OwnWord>> load() async {
    final words = await readStoredMap<String, OwnWord>(
      _prefs,
      _key,
      (id, json) =>
          MapEntry(id, OwnWord.fromJson(id, json as Map<String, dynamic>)),
    );
    return words.values.toList();
  }

  Future<void> save(Iterable<OwnWord> words) => _prefs.setString(
    _key,
    jsonEncode({for (final word in words) word.id: word.toJson()}),
  );
}
