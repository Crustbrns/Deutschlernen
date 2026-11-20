import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Languages the user has on the phone: keyboard layouts first (what they
/// write in), then the system languages. Keyboards come from native code
/// (AppDelegate.swift, MainActivity.kt); some Android keyboards report none,
/// so the system languages fill in.
class DeviceLanguagesService {
  static const _channel = MethodChannel('deutschlernen/device_languages');

  /// Language tags like "uk-UA", in the order set on the phone.
  Future<List<String>> languageTags() async => [
    ...await _keyboardTags(),
    for (final locale in PlatformDispatcher.instance.locales)
      locale.toLanguageTag(),
  ];

  Future<List<String>> _keyboardTags() async {
    if (kIsWeb) return [];
    try {
      return await _channel.invokeListMethod<String>('keyboardLanguages') ?? [];
    } on PlatformException {
      return [];
    } on MissingPluginException {
      return []; // no native side: desktop, widget tests
    }
  }
}
