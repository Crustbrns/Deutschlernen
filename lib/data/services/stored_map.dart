import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';

/// Turns one saved JSON entry into a map entry; may throw on bad data.
typedef EntryParser<K, V> = MapEntry<K, V> Function(String key, Object? value);

/// Decodes [raw], a JSON object, with [parse] for each entry.
///
/// Never throws: text that isn't a JSON object gives an empty map, and an
/// entry [parse] fails on is skipped. [broken] tells whether anything was
/// lost that way.
({Map<K, V> map, bool broken}) decodeStoredMap<K, V>(
  String raw,
  EntryParser<K, V> parse,
) {
  final map = <K, V>{};
  var broken = false;
  try {
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    for (final MapEntry(:key, :value) in decoded.entries) {
      try {
        final entry = parse(key, value);
        map[entry.key] = entry.value;
      } catch (e) {
        broken = true;
        debugPrint('Skipped an unreadable saved entry "$key": $e');
      }
    }
  } catch (e) {
    broken = true;
    debugPrint('Saved data is not a JSON object: $e');
  }
  return (map: map, broken: broken);
}

/// Reads the JSON object saved under [key] (see [decodeStoredMap]).
///
/// If any of it can't be read, the original text is first copied to
/// `<key>_backup`: the app saves over [key] with what it could read, and the
/// lost data (say, after a package changed its format) stays recoverable.
Future<Map<K, V>> readStoredMap<K, V>(
  SharedPreferencesAsync prefs,
  String key,
  EntryParser<K, V> parse,
) async {
  final raw = await prefs.getString(key);
  if (raw == null) return {};
  final (:map, :broken) = decodeStoredMap(raw, parse);
  if (broken) await prefs.setString('${key}_backup', raw);
  return map;
}
