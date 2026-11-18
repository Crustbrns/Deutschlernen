/// [d] moved by [n] calendar days, at local midnight. Calendar days, not
/// 24-hour steps: survives daylight saving changes.
DateTime addDays(DateTime d, int n) => DateTime(d.year, d.month, d.day + n);
