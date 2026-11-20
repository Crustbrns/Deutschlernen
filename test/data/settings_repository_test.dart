import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:deutschlernen/data/repositories/settings_repository.dart';
import 'package:deutschlernen/domain/models/app_settings.dart';
import 'package:deutschlernen/domain/models/definition_mode.dart';

void main() {
  Future<AppSettings> loadWith(Map<String, Object> saved) {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData(saved);
    return SettingsRepository().loadSettings();
  }

  group('accent color', () {
    test('saved before the setting existed: blue', () async {
      expect((await loadWith({})).accent, AccentColor.blue);
    });

    test('an unknown saved name falls back to blue', () async {
      expect(
        (await loadWith({'accent_color': 'pink'})).accent,
        AccentColor.blue,
      );
    });

    test('a saved choice reads back unchanged', () async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
      final repository = SettingsRepository();

      await repository.saveAccent(AccentColor.lime);

      expect((await repository.loadSettings()).accent, AccentColor.lime);
    });
  });

  group('definition mode', () {
    test('saved before the setting existed: translation', () async {
      expect((await loadWith({})).definitionMode, DefinitionMode.translation);
    });

    test('a saved choice reads back unchanged', () async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
      final repository = SettingsRepository();

      await repository.saveDefinitionMode(DefinitionMode.german);

      expect(
        (await repository.loadSettings()).definitionMode,
        DefinitionMode.german,
      );
    });
  });
}
