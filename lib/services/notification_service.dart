import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:injectable/injectable.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

@LazySingleton()
class NotificationService {
  NotificationService() {
    _initNotification();
    _configureLocalTimeZone();
  }

  late FlutterLocalNotificationsPlugin notificationPlugin;

  Future<List<PendingNotificationRequest>> pendingNotificationRequests() async {
    return notificationPlugin.pendingNotificationRequests();
  }

  void _initNotification() {
    const initSettingsAndroid = AndroidInitializationSettings('app_icon');
    const initSettingsMacOS = DarwinInitializationSettings();
    const initSettingsIOS = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
        macOS: initSettingsMacOS,
        android: initSettingsAndroid,
        iOS: initSettingsIOS);
    notificationPlugin = FlutterLocalNotificationsPlugin();
    notificationPlugin.initialize(
      initSettings,
      // onSelectNotification: (text) {
      //  onSelectNotification(text ?? '');
      //}
    );
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    await FlutterNativeTimezone.getLocalTimezone()
        .then((value) => tz.setLocalLocation(tz.getLocation(value)));
  }

  tz.TZDateTime _scheduleDateForEarlyNotification(DateTime date) {
    final d = date.toUtc();
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    final tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local, now.year, d.month, d.day, d.hour, d.minute, d.second);

    return scheduledDate;
  }

  Future<void> yearlyNotification(int id, DateTime date, String name) {
    return notificationPlugin.zonedSchedule(
        id,
        'Birthday',
        name,
        _scheduleDateForEarlyNotification(date),
        const NotificationDetails(
          android: AndroidNotificationDetails('yearly notification channel id',
              'yearly notification channel name',
              channelDescription: 'yearly notification description'),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime);
  }

  Future<void> scheduleNotification(
      int id, DateTime date, String description) async {
    log('Add notification id: ${id.toString()}');

    return notificationPlugin.zonedSchedule(
      id,
      'TO-DO',
      description,
      _scheduleDate(date),
      const NotificationDetails(
          android: AndroidNotificationDetails(
        'Notification Channel ID',
        'Channel Name',
        channelDescription: 'Description',
        importance: Importance.max,
        priority: Priority.high,
      )),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      androidAllowWhileIdle: true,
      //matchDateTimeComponents: DateTimeComponents.dateAndTime
    );
  }

  tz.TZDateTime _scheduleDate(DateTime data) {
    final d = data.toUtc();
    final scheduledDate =
        tz.TZDateTime(tz.local, d.year, d.month, d.day, d.hour, d.minute);
    print('#### DATE:$scheduledDate');
    return scheduledDate;
  }

  Future<void> cancelNotification(int id) async {
    log('Cancel notification id: ${id.toString()}');
    await notificationPlugin.cancel(id);
  }

  Future<void> singleNotification(int id, String title, String body) async {
    return notificationPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
          android: AndroidNotificationDetails(
        'com.example.todo_task',
        'firebase_push_notification',
        channelDescription: 'Description',
        importance: Importance.max,
        priority: Priority.max,
      )),
    );
  }

  Future<void> onSelectNotification(String payload) async {
    //  showDialog(
    //      context: context,
    //      builder: (_) => AlertDialog(
    //            title: const Text("Hello Everyone"),
    //            content: Text("$payload"),
    //          ));
  }
}
