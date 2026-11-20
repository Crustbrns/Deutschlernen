import 'package:material_ui/material_ui.dart';
import 'package:deutschlernen/ui/core/widgets/grouped_card.dart';
import 'package:deutschlernen/domain/models/reminder_settings.dart';
import 'package:deutschlernen/ui/core/app_strings.dart';
import 'package:deutschlernen/ui/core/app_style.dart';
import 'package:deutschlernen/ui/core/widgets/choice_sheet.dart';
import 'package:deutschlernen/ui/core/widgets/confirm_dialog.dart';
import 'package:deutschlernen/ui/core/widgets/time_sheet.dart';
import 'package:deutschlernen/ui/settings/view_models/settings_view_model.dart';
import 'package:deutschlernen/ui/settings/widgets/settings_rows.dart';

/// Reminder settings: the main switch; while it is on, a block with the
/// kinds of reminders (reviews, new words) and a schedule block with the
/// days, how many times a day and the time of each reminder.
class RemindersCategory extends StatelessWidget {
  const RemindersCategory({super.key, required this.settings});

  final SettingsViewModel settings;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final reminders = settings.reminders;
    final times = reminders.times;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GroupedSection(
          title: strings.settingsNotifications,
          children: [
            SettingsSwitchRow(
              title: strings.reminders,
              hint: strings.remindersHint,
              value: reminders.enabled,
              onChanged: (on) => _setEnabled(context, on),
            ),
          ],
        ),
        if (reminders.enabled) ...[
          GroupedSection(
            title: strings.reminderKinds,
            children: [
              SettingsSwitchRow(
                title: strings.reminderKindReview,
                hint: strings.reminderKindReviewHint,
                value: reminders.review,
                onChanged: settings.setReviewReminders,
              ),
              SettingsSwitchRow(
                title: strings.reminderKindLearn,
                hint: strings.reminderKindLearnHint,
                value: reminders.learn,
                onChanged: settings.setLearnReminders,
              ),
            ],
          ),
          GroupedSection(
            title: strings.reminderSchedule,
            children: [
              SettingsValueRow(
                title: strings.reminderDays,
                value: _daysLabel(strings, reminders),
                onTap: () => showMultiChoiceSheet<int>(
                  context: context,
                  title: strings.reminderDays,
                  selected: reminders.days,
                  onChanged: settings.setReminderDays,
                  choices: [
                    for (final (i, name) in strings.weekdaysLong.indexed)
                      Choice(i + 1, name), // DateTime.weekday: Monday = 1
                  ],
                ),
              ),
              SettingsValueRow(
                title: strings.reminderFrequency,
                value: strings.reminderTimesPerDay(times.length),
                onTap: () => showChoiceSheet<int>(
                  context: context,
                  title: strings.reminderFrequency,
                  current: times.length,
                  onSelected: settings.setReminderCount,
                  choices: [
                    for (var n = 1; n <= ReminderSettings.maxPerDay; n++)
                      Choice(n, strings.reminderTimesPerDay(n)),
                  ],
                ),
              ),
              for (final (i, time) in times.indexed)
                SettingsValueRow(
                  // One time: just "Time"; several: "Time 1", "Time 2", …
                  title: times.length == 1
                      ? strings.reminderTime
                      : strings.reminderTimeN(i + 1),
                  value: _format(time),
                  onTap: () => showTimeSheet(
                    context: context,
                    title: strings.reminderTime,
                    doneLabel: strings.done,
                    initial: time,
                    onSelected: (t) => settings.setReminderTime(i, t),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _setEnabled(BuildContext context, bool on) async {
    final allowed = await settings.setRemindersEnabled(on);
    if (!allowed && context.mounted) await _explainDenied(context);
  }

  /// The system asks only once; after a "no" only the phone's settings can
  /// allow notifications, so the dialog leads there.
  Future<void> _explainDenied(BuildContext context) async {
    final strings = AppStrings.of(context);
    final open = await showConfirmDialog(
      context: context,
      title: strings.notificationsDeniedTitle,
      body: strings.notificationsDeniedBody,
      cancelLabel: strings.cancel,
      confirmLabel: strings.openSettings,
      confirmColor: AppPalette.of(context).accentText,
    );
    if (open) await settings.openNotificationSettings();
  }

  /// "Every day", "Weekdays", "Weekends" or the short names: "Mo, We, Fr".
  static String _daysLabel(AppStrings strings, ReminderSettings reminders) =>
      switch (reminders.daysGroup) {
        ReminderDays.everyDay => strings.reminderEveryDay,
        ReminderDays.weekdays => strings.reminderWeekdays,
        ReminderDays.weekend => strings.reminderWeekend,
        ReminderDays.custom => [
          for (final (i, name) in strings.weekdaysShort.indexed)
            if (reminders.days.contains(i + 1)) name,
        ].join(', '),
      };

  /// 24-hour "9:05" → "09:05".
  static String _format(ReminderTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:'
      '${t.minute.toString().padLeft(2, '0')}';
}
