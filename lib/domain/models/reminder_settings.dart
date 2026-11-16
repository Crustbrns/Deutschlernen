/// Time of day of one reminder.
typedef ReminderTime = ({int hour, int minute});

/// Which named group the chosen days form, for a short label.
enum ReminderDays { everyDay, weekdays, weekend, custom }

/// When the app reminds the user to practice: on/off, which kinds of
/// reminders, the days of the week and 1–3 times a day.
class ReminderSettings {
  const ReminderSettings({
    this.enabled = false,
    this.review = true,
    this.learn = true,
    this.days = allDays,
    this.times = const [(hour: 19, minute: 0)],
  });

  final bool enabled;

  /// "Words are waiting for a review" reminders.
  final bool review;

  /// "Time for new words" reminders. Both off = no reminders at all.
  final bool learn;

  /// Weekdays as in [DateTime.weekday]: 1 = Monday … 7 = Sunday. Never empty.
  final Set<int> days;

  /// 1 to [maxPerDay] times, earliest first.
  final List<ReminderTime> times;

  static const maxPerDay = 3;
  static const allDays = {1, 2, 3, 4, 5, 6, 7};
  static const _weekdays = {1, 2, 3, 4, 5};
  static const _weekend = {6, 7};

  /// Default times for 1, 2 and 3 reminders a day: evening, then morning
  /// and evening, then morning, lunch and evening.
  static const _defaults = [
    [(hour: 19, minute: 0)],
    [(hour: 9, minute: 0), (hour: 19, minute: 0)],
    [(hour: 9, minute: 0), (hour: 14, minute: 0), (hour: 20, minute: 0)],
  ];

  ReminderDays get daysGroup => switch (days) {
    _ when _same(days, allDays) => ReminderDays.everyDay,
    _ when _same(days, _weekdays) => ReminderDays.weekdays,
    _ when _same(days, _weekend) => ReminderDays.weekend,
    _ => ReminderDays.custom,
  };

  static bool _same(Set<int> a, Set<int> b) =>
      a.length == b.length && a.containsAll(b);

  /// [count] reminders a day. Fewer keeps the earliest ones; more adds the
  /// default times of that count which aren't taken yet.
  ReminderSettings withCount(int count) {
    final n = count.clamp(1, maxPerDay);
    if (n <= times.length) return copyWith(times: times.take(n).toList());
    final added = _defaults[n - 1].where((t) => !times.contains(t));
    return copyWith(
      times: _sorted([...times, ...added.take(n - times.length)]),
    );
  }

  /// Replaces the time at [index]; the list stays sorted.
  ReminderSettings withTime(int index, ReminderTime time) =>
      copyWith(times: _sorted([...times]..[index] = time));

  static List<ReminderTime> _sorted(List<ReminderTime> times) => times
    ..sort(
      (a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute),
    );

  ReminderSettings copyWith({
    bool? enabled,
    bool? review,
    bool? learn,
    Set<int>? days,
    List<ReminderTime>? times,
  }) => ReminderSettings(
    enabled: enabled ?? this.enabled,
    review: review ?? this.review,
    learn: learn ?? this.learn,
    days: days ?? this.days,
    times: times ?? this.times,
  );
}
