import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// One notification to schedule. [payload] comes back when it is tapped.
typedef ScheduledNotification = ({
  DateTime at,
  String title,
  String body,
  String payload,
});

/// Local notifications (flutter_local_notifications): asks for permission
/// and replaces the whole schedule at once. No-op on the web.
class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  Future<void>? _init;
  final _taps = StreamController<String>.broadcast();

  /// Payloads of notifications tapped while the app is running (also in
  /// the background).
  Stream<String> get taps => _taps.stream;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'reminders',
      'Reminders',
      channelDescription: 'Reminders to learn and review words',
    ),
    iOS: DarwinNotificationDetails(),
  );

  /// Call at start-up, so taps are received from the beginning.
  Future<void> init() => _ready();

  /// Started once, on first use.
  Future<void> _ready() => _init ??= _initialize();

  Future<void> _initialize() async {
    tzdata.initializeTimeZones();
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } catch (_) {
      // Unknown zone name: keep UTC; times shift, but nothing breaks.
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // Asked later, when the user turns reminders on, not at start-up.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestSoundPermission: false,
          requestBadgePermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        if (response.payload case final payload?) _taps.add(payload);
      },
    );
  }

  /// Payload of the notification that started the app; null when it was
  /// opened another way. Taps after the start come through [taps].
  Future<String?> launchPayload() async {
    if (kIsWeb) return null;
    await _ready();
    final details = await _plugin.getNotificationAppLaunchDetails();
    return (details?.didNotificationLaunchApp ?? false)
        ? details?.notificationResponse?.payload
        : null;
  }

  /// Shows the system dialog (only the first time); true = allowed.
  Future<bool> requestPermission() async {
    if (kIsWeb) return false;
    await _ready();
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      return await ios.requestPermissions(alert: true, sound: true) ?? false;
    }
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await android?.requestNotificationsPermission() ?? false;
  }

  /// Opens the app's notification settings in the system settings.
  Future<void> openSystemSettings() async {
    if (kIsWeb) return;
    await _ready();
    await _plugin.openAppNotificationSettings();
  }

  /// Cancels everything scheduled before and schedules [notifications].
  Future<void> replaceAll(List<ScheduledNotification> notifications) async {
    if (kIsWeb) return;
    await _ready();
    await _plugin.cancelAllPendingNotifications();
    for (final (i, n) in notifications.indexed) {
      await _plugin.zonedSchedule(
        id: i,
        scheduledDate: tz.TZDateTime.from(n.at, tz.local),
        notificationDetails: _details,
        // Inexact: no exact-alarm permission needed; a few minutes late
        // is fine for a reminder.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: n.title,
        body: n.body,
        payload: n.payload,
      );
    }
  }
}
