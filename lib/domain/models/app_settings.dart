import 'package:material_ui/material_ui.dart' show ThemeMode;
import 'package:deutschlernen/domain/models/reminder_settings.dart';

/// The app's accent color, picked in Settings (the colors are in the UI's
/// app_style.dart). Blue is the default (user's choice, 2026-11-20).
enum AccentColor { blue, lime, yellow }

/// Everything the user can switch in Settings, except the two languages
/// (those are kept by the cards view model).
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.dark,
    this.accent = AccentColor.blue,
    this.showTranscription = true,
    this.reminders = const ReminderSettings(),
    this.autoSpeak = false,
    this.speechRate = defaultSpeechRate,
    this.wordGoal = defaultWordGoal,
  });

  /// Only light or dark; the app has no "follow the system" option.
  final ThemeMode themeMode;

  final AccentColor accent;

  /// The phonetic spelling under the German word.
  final bool showTranscription;

  /// Reminders to practice: on/off, days and times.
  final ReminderSettings reminders;

  /// Read each new word aloud as soon as its card appears.
  final bool autoSpeak;

  /// Speed of the voice in the flutter_tts scale: 0 = slowest, 1 = fastest.
  final double speechRate;

  static const minSpeechRate = 0.2;
  static const maxSpeechRate = 0.6;
  static const defaultSpeechRate =
      0.4; // what the app used before it was a setting

  /// How many words to know (learned or "already know"): the goal bar on
  /// the Progress tab.
  final int wordGoal;

  static const wordGoals = [50, 100, 250, 500, 1000];
  static const defaultWordGoal = 100;

  AppSettings copyWith({
    ThemeMode? themeMode,
    AccentColor? accent,
    bool? showTranscription,
    ReminderSettings? reminders,
    bool? autoSpeak,
    double? speechRate,
    int? wordGoal,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      accent: accent ?? this.accent,
      showTranscription: showTranscription ?? this.showTranscription,
      reminders: reminders ?? this.reminders,
      autoSpeak: autoSpeak ?? this.autoSpeak,
      speechRate: speechRate ?? this.speechRate,
      wordGoal: wordGoal ?? this.wordGoal,
    );
  }
}
