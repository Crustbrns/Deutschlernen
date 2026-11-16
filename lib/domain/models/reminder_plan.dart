import 'package:deutschlernen/domain/models/card_decision.dart';
import 'package:deutschlernen/domain/models/reminder_settings.dart';

/// What a reminder asks for: due words first, else new words.
enum ReminderKind { review, learn }

/// Session a tapped reminder opens. Things may have changed since it was
/// planned (e.g. reviewed after another reminder): with nothing due a
/// review reminder falls back to new words; null = nothing to do.
SessionMode? sessionForReminder(
  ReminderKind kind, {
  required int dueCount,
  required int newWordsLeft,
}) => switch (kind) {
  ReminderKind.review when dueCount > 0 => SessionMode.review,
  _ when newWordsLeft > 0 => SessionMode.newWords,
  _ => null,
};

/// One reminder to schedule. [count] = due words (review only).
typedef PlannedReminder = ({DateTime at, ReminderKind kind, int count});

/// Reminders for the next [days] calendar days, from [now] (local time).
///
/// The progress can't change while the app is closed, so each reminder's
/// content is known in advance: [dueTimes] are the review times of the
/// words, and a reminder says how many of them are due at its moment. With
/// nothing due (or review reminders off) it asks for new words, if those
/// reminders are on, [hasNewWords] and the day's goal
/// isn't reached yet ([goalMetToday] concerns today only: other days start
/// from zero). With nothing to do it is skipped. At most [limit]: iOS keeps
/// only 64 pending notifications.
List<PlannedReminder> planReminders({
  required ReminderSettings settings,
  required DateTime now,
  required List<DateTime> dueTimes,
  required bool hasNewWords,
  required bool goalMetToday,
  int days = 7,
  int limit = 60,
}) {
  if (!settings.enabled) return const [];
  final plan = <PlannedReminder>[];
  for (var d = 0; d < days && plan.length < limit; d++) {
    // Calendar days, not 24-hour steps: survives daylight saving changes.
    final day = DateTime(now.year, now.month, now.day + d);
    if (!settings.days.contains(day.weekday)) continue;
    // toSet: two reminders set to the same time give one notification.
    for (final time in settings.times.toSet()) {
      final at = DateTime(day.year, day.month, day.day, time.hour, time.minute);
      if (!at.isAfter(now)) continue;
      final due = dueTimes.where((t) => !t.isAfter(at)).length;
      if (settings.review && due > 0) {
        plan.add((at: at, kind: ReminderKind.review, count: due));
      } else if (settings.learn && hasNewWords && !(d == 0 && goalMetToday)) {
        plan.add((at: at, kind: ReminderKind.learn, count: 0));
      }
      if (plan.length >= limit) break;
    }
  }
  return plan;
}
