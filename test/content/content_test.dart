import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:deutschlernen/domain/models/word.dart';

/// The content rules from CLAUDE.md, checked on the asset files: a missing
/// string shows as its key name and a missing translation as an empty word,
/// and nothing else would notice.
void main() {
  Object? read(String path) => jsonDecode(File(path).readAsStringSync());

  final languages = [
    for (final l in read('assets/data/languages.json')! as List<dynamic>)
      l as Map<String, dynamic>,
  ];
  final codes = [for (final l in languages) l['code'] as String];
  final words = [
    for (final w in read('assets/data/words.json')! as List<dynamic>)
      w as Map<String, dynamic>,
  ];

  test('every language has its preview texts and both files', () {
    for (final language in languages) {
      for (final field in ['code', 'label', 'hello', 'uiNote', 'wordsNote']) {
        expect(
          language[field],
          isA<String>().having((s) => s.isNotEmpty, 'not empty', isTrue),
          reason: '${language['code']}: $field',
        );
      }
    }
    for (final code in codes) {
      expect(File('assets/data/ui/$code.json').existsSync(), isTrue);
      expect(File('assets/data/translations/$code.json').existsSync(), isTrue);
    }
  });

  group('interface strings', () {
    final strings = {
      for (final code in codes)
        code: (read('assets/data/ui/$code.json')! as Map<String, dynamic>),
    };
    final plural = RegExp(r'^(.+)(One|Few|Many|Other)$');
    final pluralBases = {
      for (final keys in strings.values)
        for (final key in keys.keys)
          if (plural.firstMatch(key) case final m?) m.group(1)!,
    };
    bool isPlural(String key) =>
        pluralBases.contains(plural.firstMatch(key)?.group(1));

    test('the same keys in every language', () {
      final all = {
        for (final keys in strings.values)
          ...keys.keys.where((k) => !isPlural(k)),
      };
      for (final MapEntry(key: code, value: keys) in strings.entries) {
        expect(
          all.difference(keys.keys.toSet()),
          isEmpty,
          reason: 'missing in ui/$code.json',
        );
      }
    });

    test('plural forms each language needs (AppStrings._pluralForm)', () {
      const forms = {
        'ru': ['One', 'Few', 'Many'],
        'uk': ['One', 'Few', 'Many'],
        'en': ['One', 'Other'],
        'es': ['One', 'Other'],
        'zh': ['Other'],
      };
      // Abbreviated units read the same for every number ("через 5 мин",
      // "in 5 min"): one "Other" form is enough there.
      const units = {'reviewInMinutes', 'reviewInHours'};
      const invariant = {
        'ru': {...units, 'reviewInDays', 'reviewInMonths'},
        'uk': {...units, 'reviewInDays', 'reviewInMonths'},
        'en': units,
        'es': units,
        'zh': <String>{},
      };
      for (final code in codes) {
        final keys = strings[code]!;
        final missing = [
          for (final base in pluralBases)
            // A listed key may have "Other" alone: AppStrings falls back to
            // it for every number.
            for (final form
                in invariant[code]!.contains(base)
                    ? const ['Other']
                    : forms[code]!)
              if (!keys.containsKey('$base$form')) '$base$form',
        ];
        expect(missing, isEmpty, reason: 'ui/$code.json');
      }
    });

    test('no empty strings', () {
      for (final MapEntry(key: code, value: keys) in strings.entries) {
        final empty = [
          for (final MapEntry(:key, :value) in keys.entries)
            if (value is! String || value.trim().isEmpty) key,
        ];
        expect(empty, isEmpty, reason: 'ui/$code.json');
      }
    });
  });

  group('words', () {
    test('ids are unique and levels are known', () {
      final ids = [for (final w in words) w['id']];
      expect(ids.toSet(), hasLength(ids.length));
      for (final word in words) {
        expect(Word.levels, contains(word['level']), reason: '${word['id']}');
      }
    });

    test('every word is translated in every language', () {
      for (final code in codes) {
        final translations =
            read('assets/data/translations/$code.json')!
                as Map<String, dynamic>;
        final missing = [
          for (final word in words)
            if (translations[word['id']] case final t?
                when (t as Map<String, dynamic>)['word'] is String &&
                    (t['word'] as String).isNotEmpty &&
                    t['examples'] is List<dynamic>)
              null
            else
              word['id'],
        ].nonNulls;
        expect(missing, isEmpty, reason: 'translations/$code.json');
      }
    });
  });
}
