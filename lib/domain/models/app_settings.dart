import 'package:material_ui/material_ui.dart' show ThemeMode;

/// Everything the user can switch in Settings, except the two languages
/// (those are kept by the cards view model).
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.dark,
    this.showTranscription = true,
    this.notificationsEnabled = false,
    this.autoSpeak = false,
    this.speechRate = defaultSpeechRate,
  });

  /// Only light or dark; the app has no "follow the system" option.
  final ThemeMode themeMode;

  /// The phonetic spelling under the German word.
  final bool showTranscription;

  /// Reminders to practice. Only the choice is stored for now.
  final bool notificationsEnabled;

  /// Read each new word aloud as soon as its card appears.
  final bool autoSpeak;

  /// Speed of the voice in the flutter_tts scale: 0 = slowest, 1 = fastest.
  final double speechRate;

  static const minSpeechRate = 0.2;
  static const maxSpeechRate = 0.6;
  static const defaultSpeechRate = 0.4; // what the app used before it was a setting

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? showTranscription,
    bool? notificationsEnabled,
    bool? autoSpeak,
    double? speechRate,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      showTranscription: showTranscription ?? this.showTranscription,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      autoSpeak: autoSpeak ?? this.autoSpeak,
      speechRate: speechRate ?? this.speechRate,
    );
  }
}
