import 'package:flutter_test/flutter_test.dart';
import 'package:deutschlernen/domain/models/card_decision.dart';
import 'package:deutschlernen/domain/models/reminder_plan.dart';
import 'package:deutschlernen/domain/models/reminder_settings.dart';

void main() {
  // Wednesday 2026-11-18, 12:00.
  final now = DateTime(2026, 11, 18, 12);
  const evening = (hour: 19, minute: 0);
  const morning = (hour: 9, minute: 0);

  List<PlannedReminder> plan({
    Set<int> days = ReminderSettings.allDays,
    List<ReminderTime> times = const [evening],
    List<DateTime> dueTimes = const [],
    bool hasNewWords = true,
    bool goalMetToday = false,
    bool enabled = true,
    bool review = true,
    bool learn = true,
  }) => planReminders(
    settings: ReminderSettings(
      enabled: enabled,
      review: review,
      learn: learn,
      days: days,
      times: times,
    ),
    now: now,
    dueTimes: dueTimes,
    hasNewWords: hasNewWords,
    goalMetToday: goalMetToday,
  );

  group('planReminders', () {
    test('off: nothing', () {
      expect(plan(enabled: false), isEmpty);
    });

    test('one a day for 7 days; a time already passed today is skipped', () {
      final p = plan(times: const [morning, evening]);

      // Today only 19:00 (9:00 is gone), then two a day for 6 days.
      expect(p, hasLength(1 + 6 * 2));
      expect(p.first.at, DateTime(2026, 11, 18, 19));
      expect(p[1].at, DateTime(2026, 11, 19, 9));
    });

    test('only on the chosen weekdays', () {
      final p = plan(days: const {DateTime.saturday, DateTime.sunday});

      expect([for (final r in p) r.at.weekday], [6, 7]);
    });

    test('counts the words due at each reminder', () {
      final p = plan(
        dueTimes: [
          DateTime(2026, 11, 18, 8), // due already
          DateTime(2026, 11, 18, 20), // due after today's reminder
          DateTime(2026, 11, 30), // after the plan
        ],
      );

      expect((p[0].kind, p[0].count), (ReminderKind.review, 1));
      expect((p[1].kind, p[1].count), (ReminderKind.review, 2));
    });

    test('nothing due: asks for new words', () {
      expect(plan().first.kind, ReminderKind.learn);
    });

    test('goal reached today: today is skipped, other days stay', () {
      final p = plan(goalMetToday: true);

      expect(p.first.at, DateTime(2026, 11, 19, 19));
      expect(p, hasLength(6));
    });

    test('nothing to do at all: no reminders', () {
      expect(plan(hasNewWords: false), isEmpty);
    });

    test('review reminders off: due words ask for new words instead', () {
      final p = plan(review: false, dueTimes: [DateTime(2026, 11, 18, 8)]);

      expect(p.every((r) => r.kind == ReminderKind.learn), isTrue);
      expect(p, hasLength(7));
    });

    test('new-word reminders off: only days with due words', () {
      final p = plan(learn: false, dueTimes: [DateTime(2026, 11, 20, 8)]);

      expect(p.first.at, DateTime(2026, 11, 20, 19)); // nothing due before
      expect(p.every((r) => r.kind == ReminderKind.review), isTrue);
    });

    test('both kinds off: no reminders', () {
      expect(
        plan(review: false, learn: false, dueTimes: [DateTime(2026, 11, 18)]),
        isEmpty,
      );
    });

    test('the same time twice gives one reminder', () {
      expect(plan(times: const [evening, evening]), hasLength(7));
    });
  });

  test('a tapped reminder opens what there is to do now', () {
    SessionMode? open(ReminderKind k, int due, int fresh) =>
        sessionForReminder(k, dueCount: due, newWordsLeft: fresh);

    expect(open(ReminderKind.review, 3, 5), SessionMode.review);
    expect(open(ReminderKind.review, 0, 5), SessionMode.newWords);
    expect(open(ReminderKind.learn, 3, 5), SessionMode.newWords);
    expect(open(ReminderKind.learn, 3, 0), isNull);
    expect(open(ReminderKind.review, 0, 0), isNull);
  });

  group('ReminderSettings', () {
    const one = ReminderSettings(times: [(hour: 10, minute: 30)]);

    test('more a day keeps the times and adds defaults, sorted', () {
      expect(one.withCount(3).times, [
        morning,
        (hour: 10, minute: 30),
        (hour: 14, minute: 0),
      ]);
    });

    test('fewer a day keeps the earliest', () {
      expect(one.withCount(3).withCount(1).times, [morning]);
    });

    test('a changed time keeps the list sorted', () {
      final two = one.withCount(2); // 9:00, 10:30
      expect(two.withTime(0, (hour: 22, minute: 0)).times, [
        (hour: 10, minute: 30),
        (hour: 22, minute: 0),
      ]);
    });

    test('day groups', () {
      expect(const ReminderSettings().daysGroup, ReminderDays.everyDay);
      expect(
        const ReminderSettings(days: {1, 2, 3, 4, 5}).daysGroup,
        ReminderDays.weekdays,
      );
      expect(
        const ReminderSettings(days: {6, 7}).daysGroup,
        ReminderDays.weekend,
      );
      expect(
        const ReminderSettings(days: {1, 3}).daysGroup,
        ReminderDays.custom,
      );
    });
  });
}
