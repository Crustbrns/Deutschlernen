import 'package:flutter_test/flutter_test.dart';
import 'package:deutschlernen/domain/models/app_language.dart';

AppLanguage language(String code) =>
    AppLanguage(code: code, label: code, hello: '', uiNote: '', wordsNote: '');

void main() {
  group('splitByDevice', () {
    final all = [
      for (final c in ['uk', 'ru', 'en', 'es', 'zh']) language(c),
    ];
    List<String> codes(List<AppLanguage> list) => [
      for (final l in list) l.code,
    ];

    test('device languages first, in the phone order; the rest as listed', () {
      final split = splitByDevice(all, ['ru-RU', 'de-DE', 'uk-UA']);

      expect(codes(split.onDevice), ['ru', 'uk']);
      expect(codes(split.others), ['en', 'es', 'zh']);
    });

    test('script/region tags, underscores and repeats map to one language', () {
      final split = splitByDevice(all, ['zh-Hans-CN', 'en_US', 'en-GB', 'EN']);

      expect(codes(split.onDevice), ['zh', 'en']);
    });

    test('nothing known on the device: everything is in others', () {
      final split = splitByDevice(all, ['de-DE', 'emoji', 'dictation']);

      expect(split.onDevice, isEmpty);
      expect(codes(split.others), codes(all));
    });
  });
}
