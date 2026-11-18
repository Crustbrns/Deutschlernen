import 'package:flutter_test/flutter_test.dart';
import 'package:deutschlernen/data/services/stored_map.dart';

void main() {
  MapEntry<String, int> parseCount(String id, Object? count) =>
      MapEntry(id, count as int);

  test('reads every entry of a good map', () {
    final (:map, :broken) = decodeStoredMap('{"a": 1, "b": 2}', parseCount);

    expect(map, {'a': 1, 'b': 2});
    expect(broken, isFalse);
  });

  test('skips an unreadable entry, keeps the rest', () {
    final (:map, :broken) = decodeStoredMap(
      '{"a": 1, "b": "two", "c": 3}',
      parseCount,
    );

    expect(map, {'a': 1, 'c': 3});
    expect(broken, isTrue);
  });

  test('text that is not a JSON object gives an empty map', () {
    for (final raw in ['not json', '[1, 2]', '']) {
      final (:map, :broken) = decodeStoredMap(raw, parseCount);

      expect(map, isEmpty, reason: raw);
      expect(broken, isTrue, reason: raw);
    }
  });
}
