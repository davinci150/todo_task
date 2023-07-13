import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import '../api/auth_api.dart';
import '../services/notification_service.dart';

Future<void> registerNotification() async {
 /*  final _messaging = FirebaseMessaging.instance;

  final NotificationSettings settings = await _messaging.requestPermission();
  _messaging.onTokenRefresh.listen((String token) {
    print('### ON REFRESH TOKEN IS: ${token}');
    FirebaseFirestore.instance
        .collection('users')
        .doc(GetIt.I<AuthApi>().getUid!)
        .update(<String, dynamic>{'Token': token});
  });
  print(
      '### ${settings.authorizationStatus == AuthorizationStatus.authorized}');

/*
  FirebaseMessaging.onMessageOpenedApp.listen((event) {
    print('## ON MESSAGE OPENED APP $event');
  }); */

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('### ON MESSAGE ${message.notification?.title ?? ''}');
    print('### ON MESSAGE ${message.notification?.body ?? ''}');
    NotificationService().singleNotification(
        0, message.notification?.title ?? '', message.notification?.body ?? '');
    // For displaying the notification as an overlay
    /*    showSimpleNotification(
      Text(_notificationInfo!.title!),
      leading: NotificationBadge(totalNotifications: _totalNotifications),
      subtitle: Text(_notificationInfo!.body!),
      background: Colors.cyan.shade700,
      duration: Duration(seconds: 2),
    ); */
  });
  await _messaging.getToken().then((token) {
    print('### MY TOKEN IS: ${token}');
    print('### MY auth: ${settings.authorizationStatus}');
    final String? userId = GetIt.I<AuthApi>().getUid;
    if (userId != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(GetIt.I<AuthApi>().getUid!)
          .update(<String, dynamic>{'Token': token});
    }
  }); */
  /*  FirebaseMessaging.onBackgroundMessage((message) async {
    // _firebaseMessagingBackgroundHandler(message);
    print('### ON BACKGROUND $message');
    /*  NotificationService().singleNotification(
        0, message.notification?.title ?? '', message.notification?.body ?? ''); */
  }); */
}

Future<void> sendMessage(
  String title,
  String body,
) async {
  try {
    final http.Response request = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization':
            'key=AAAAm6PMTMI:APA91bG--FWlgWhvneSzFVjs3ODt9xy4ab6IuP6gnm_v8BVG9OV91GSFzN9Kl3gJLs1Zu_--SL7AJ04OyyxwWAk1NltWURxipaK4obGQKlumPj_om-9BdS5IyprRp3peX7QeXCvK4LyZ'
      },
      body: constructFCMPayload(
          'fqtu70opTAGPgEXIJj2RN7:APA91bFRprnp_ZLjOAqikGYgyuaroJ9H2hXfcYRJCONX0gqaKCSRO8wF30U6DC69BJbNdGmmkEa_7MBXdcTpppYJwLINgZ7A1E4ZWMMl3lpClKIXq-XC7xxsl7eqtApZ7bIomsJ-rgy4',
          body),
    );
    print(
        'FCM request for device sent! ${request.statusCode}/ ${request.body}');
  } on Exception catch (e) {
    print(e);
  }
}

String constructFCMPayload(String? token, String body) {
  return jsonEncode(
    <String, dynamic>{
      'notification': <String, dynamic>{
        'body': body,
        'title': "TODO",
      },
      'data': <String, dynamic>{'name': 'fdf'},
      'to':
          'cxzLEmpBRTmgtxwzw28dYm:APA91bEJqVgHvkycRhq2lZJoJlZ1uqexsp2PyABmHkbeUEYi1qrGENy2TGGFucAARL0rQMLNaB65QrV4JCfN7q2yO_y65Df8Ag_4Qrxnr6QYPQeaqE0bBLfZANcZTarnr8fC4ys9JGYV'
      //"/topics/all"
      //'to': token
      /*  "condition": "'all' in topics || 'android' in topics || 'ios' in topics" */
    },
  );
}
