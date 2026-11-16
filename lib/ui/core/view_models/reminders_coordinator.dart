import 'package:deutschlernen/data/services/notification_service.dart';
import 'package:deutschlernen/domain/models/reminder_plan.dart';
import 'package:deutschlernen/domain/models/reminder_settings.dart';
import 'package:deutschlernen/ui/core/view_models/language_view_model.dart';
import 'package:deutschlernen/ui/core/view_models/learning_view_model.dart';
import 'package:deutschlernen/ui/settings/view_models/settings_view_model.dart';

/// Keeps the scheduled notifications in line with the reminder settings
/// and the progress. Rescheduled when the reminder settings change and when
/// the app goes to the background (the progress is final until it's back).
class RemindersCoordinator {
  RemindersCoordinator({
    required this._notifications,
    required this._learning,
    required this._settings,
    required this._languages,
  }) {
    _settings.addListener(_onSettingsChanged);
  }

  final NotificationService _notifications;
  final LearningViewModel _learning;
  final SettingsViewModel _settings;
  final LanguageViewModel _languages;

  /// Reminder settings the schedule was built from; other settings (theme,
  /// speech, …) notify too and must not reschedule.
  ReminderSettings? _scheduledFor;

  void _onSettingsChanged() {
    if (!identical(_settings.reminders, _scheduledFor)) reschedule();
  }

  Future<void> reschedule() async {
    if (_learning.isLoading || _languages.isLoading) return;
    final reminders = _scheduledFor = _settings.reminders;
    final strings = _languages.strings;
    final plan = planReminders(
      settings: reminders,
      now: DateTime.now(),
      dueTimes: _learning.reviewDueTimes,
      hasNewWords: _learning.newWordsLeft > 0,
      goalMetToday: _learning.learnedToday >= LearningViewModel.dailyGoal,
    );
    await _notifications.replaceAll([
      for (final r in plan)
        switch (r.kind) {
          ReminderKind.review => (
            at: r.at,
            title: strings.reminderReviewTitle,
            body: strings.reminderReviewBody(r.count),
          ),
          ReminderKind.learn => (
            at: r.at,
            title: strings.reminderLearnTitle,
            body: strings.reminderLearnBody,
          ),
        },
    ]);
  }

  void dispose() => _settings.removeListener(_onSettingsChanged);
}
