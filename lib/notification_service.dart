import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService() {
    _initNotification();
    _configureLocalTimeZone();
  }

  late FlutterLocalNotificationsPlugin notificationPlugin;

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

  Future<void> scheduleNotification(
      int id, DateTime data, String description) async {
    log('Add notification id: ${id.toString()}');
    return notificationPlugin.zonedSchedule(
      id,
      'Birthday',
      description,
      _nextInstanceOfTenAM(data),
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

  tz.TZDateTime _nextInstanceOfTenAM(DateTime data) {
    final d = data.toUtc();
    return tz.TZDateTime(tz.local, d.year, d.month, d.day, d.hour, d.minute);
  }

  Future<void> cancelNotification(int id) async {
    log('Cancel notification id: ${id.toString()}');
    await notificationPlugin.cancel(id);
  }

  Future<void> deleteNotificationChannel() async {
    const String channelId = 'Channel Name';
    await notificationPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.deleteNotificationChannel(channelId);
  }

  Future<void> cancelAllNotifications() async {
    await notificationPlugin.cancelAll();
  }

  Future<void> onSelectNotification(String payload) async {
    //  showDialog(
    //      context: context,
    //      builder: (_) => AlertDialog(
    //            title: const Text("Hello Everyone"),
    //            content: Text("$payload"),
    //          ));
  }

  Future<void> getActiveNotifications(BuildContext context) async {
    final List<AndroidNotificationChannel>? channels = await notificationPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .getNotificationChannels();
    log(channels!.first.name.toString());
    return;

    final Widget activeNotificationsDialogContent =
        await _getActiveNotificationsDialogContent(context);
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: activeNotificationsDialogContent,
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<Widget> _getActiveNotificationsDialogContent(
      BuildContext context) async {
    /* if (Platform.isAndroid) {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt! < 23) {
        return const Text(
          '"getActiveNotifications" is available only for Android 6.0 or newer',
        );
      }
    } else if (Platform.isIOS) {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      final List<String> fullVersion = iosInfo.systemVersion!.split('.');
      if (fullVersion.isNotEmpty) {
        final int? version = int.tryParse(fullVersion[0]);
        if (version != null && version < 10) {
          return const Text(
            '"getActiveNotifications" is available only for iOS 10.0 or newer',
          );
        }
      }
    }*/

    try {
      final List<ActiveNotification> activeNotifications =
          await notificationPlugin.getActiveNotifications();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text(
            'Active Notifications',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Divider(color: Colors.black),
          if (activeNotifications.isEmpty)
            const Text('No active notifications'),
          if (activeNotifications.isNotEmpty)
            for (ActiveNotification activeNotification in activeNotifications)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'id: ${activeNotification.id}\n'
                    'channelId: ${activeNotification.channelId}\n'
                    'groupKey: ${activeNotification.groupKey}\n'
                    'tag: ${activeNotification.tag}\n'
                    'title: ${activeNotification.title}\n'
                    'body: ${activeNotification.body}',
                  ),
                  TextButton(
                    child: const Text('Get messaging style'),
                    onPressed: () {
                      _getActiveNotificationMessagingStyle(
                          activeNotification.id,
                          activeNotification.tag,
                          context);
                    },
                  ),
                  const Divider(color: Colors.black),
                ],
              ),
        ],
      );
    } on PlatformException catch (error) {
      return Text(
        'Error calling "getActiveNotifications"\n'
        'code: ${error.code}\n'
        'message: ${error.message}',
      );
    }
  }

  Future<void> _getActiveNotificationMessagingStyle(
      int id, String? tag, BuildContext context) async {
    Widget dialogContent;
    try {
      final MessagingStyleInformation? messagingStyle = await notificationPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()!
          .getActiveNotificationMessagingStyle(id, tag: tag);
      if (messagingStyle == null) {
        dialogContent = const Text('No messaging style');
      } else {
        dialogContent = SingleChildScrollView(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('person: ${_formatPerson(messagingStyle.person)}\n'
                'conversationTitle: ${messagingStyle.conversationTitle}\n'
                'groupConversation: ${messagingStyle.groupConversation}'),
            const Divider(color: Colors.black),
            if (messagingStyle.messages == null) const Text('No messages'),
            if (messagingStyle.messages != null)
              for (final Message msg in messagingStyle.messages!)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('text: ${msg.text}\n'
                        'timestamp: ${msg.timestamp}\n'
                        'person: ${_formatPerson(msg.person)}'),
                    const Divider(color: Colors.black),
                  ],
                ),
          ],
        ));
      }
    } on PlatformException catch (error) {
      dialogContent = Text(
        'Error calling "getActiveNotificationMessagingStyle"\n'
        'code: ${error.code}\n'
        'message: ${error.message}',
      );
    }

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Messaging style'),
        content: dialogContent,
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatPerson(Person? person) {
    if (person == null) {
      return 'null';
    }

    final List<String> attrs = <String>[];
    if (person.name != null) {
      attrs.add('name: "${person.name}"');
    }
    if (person.uri != null) {
      attrs.add('uri: "${person.uri}"');
    }
    if (person.key != null) {
      attrs.add('key: "${person.key}"');
    }
    if (person.important) {
      attrs.add('important: true');
    }
    if (person.bot) {
      attrs.add('bot: true');
    }
    if (person.icon != null) {
      attrs.add('icon: ${_formatAndroidIcon(person.icon)}');
    }
    return 'Person(${attrs.join(', ')})';
  }

  String _formatAndroidIcon(Object? icon) {
    if (icon == null) {
      return 'null';
    }
    if (icon is DrawableResourceAndroidIcon) {
      return 'DrawableResourceAndroidIcon("${icon.data}")';
    } else if (icon is ContentUriAndroidIcon) {
      return 'ContentUriAndroidIcon("${icon.data}")';
    } else {
      return 'AndroidIcon()';
    }
  }
}
