import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// Reads the raw JSON files from the app's assets.
class AssetService {
  Future<List<Map<String, dynamic>>> loadWords() =>
      _loadList('assets/data/words.json');

  Future<List<Map<String, dynamic>>> loadLanguages() =>
      _loadList('assets/data/languages.json');

  Future<Map<String, dynamic>> loadTranslations(String languageCode) =>
      _loadMap('assets/data/translations/$languageCode.json');

  Future<Map<String, dynamic>> loadUiTexts(String languageCode) =>
      _loadMap('assets/data/ui/$languageCode.json');

  Future<List<Map<String, dynamic>>> _loadList(String path) async {
    final raw = await rootBundle.loadString(path);
    return (jsonDecode(raw) as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> _loadMap(String path) async {
    final raw = await rootBundle.loadString(path);
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}