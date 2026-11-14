import 'package:flutter/foundation.dart';
import 'package:deutschlernen/data/services/asset_service.dart';
import 'package:deutschlernen/domain/models/app_language.dart';

class LanguageRepository {
  LanguageRepository({required this._assetService});

  final AssetService _assetService;

  /// Used when the device language is not supported, and for UI texts that a
  /// language file does not contain yet.
  static const fallbackCode = 'en';

  Future<List<AppLanguage>> getLanguages() async {
    final json = await _assetService.loadLanguages();
    return [for (final item in json) AppLanguage.fromJson(item)];
  }

  /// UI texts of [language]. Missing keys are filled from the fallback language.
  Future<Map<String, String>> getUiTexts(AppLanguage language) async {
    final texts = _toStrings(await _assetService.loadUiTexts(fallbackCode));

    if (language.code != fallbackCode) {
      try {
        texts.addAll(
          _toStrings(await _assetService.loadUiTexts(language.code)),
        );
      } catch (e) {
        debugPrint('Could not load ${language.code} UI texts: $e');
      }
    }
    return texts;
  }

  Map<String, String> _toStrings(Map<String, dynamic> json) =>
      json.map((key, value) => MapEntry(key, value as String));
}
