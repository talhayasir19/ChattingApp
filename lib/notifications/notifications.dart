import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';

class LocalNotificationService {
  static LocalNotificationService? localNotificationService;
  LocalNotificationService.internal();

  factory LocalNotificationService() {
    return localNotificationService ??= LocalNotificationService.internal();
  }

  //make the instance of the flutter local notification
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  //method to initialize the notification setting
  Future<void> initializeSettingsOfNotifications() async {
    // for Android
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // for IOS
    const DarwinInitializationSettings darwinInitializationSettings =
        DarwinInitializationSettings(
            requestSoundPermission: false,
            requestBadgePermission: false,
            requestAlertPermission: false);

    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: androidInitializationSettings,
            iOS: darwinInitializationSettings,
            macOS: null);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    // for Android
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'chaticious',
      'chatBuddy channel',
      enableVibration: true,
      importance: Importance.high,
      priority: Priority.high,
    );
    // for IOS
    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);

    await flutterLocalNotificationsPlugin
        .show(2, title, body, notificationDetails, payload: 'data');
  }
}

void triggerNotifiation(
    {required String tittle,
    required String body,
    required var tokenId}) async {
  try {
    await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'content-type': 'application/json',
          'Authorization':
              'key=AAAAt_y0K1Q:APA91bH9U0B80IdKVYbdmYHFRd_3YHdwLnNNCbuGM2V3axCjWcHKepU9XXiJcIWAGeB-CAR-JnNSzSMcdGxh7PsDlu0p7MPo8M7iI8V8Jt7RT7W40pXrL1JLaTCqI-KDVWfvO-HUkvuW'
        },
        body: jsonEncode(
          <String, dynamic>{
            "priority": "high",
            "data": <String, dynamic>{
              "click_action": "FLUTTER_NOTIFICATION_CLICK",
              "status": "done",
            },
            "notification": <String, dynamic>{
              "title": tittle,
              "body": body,
              "channel": "chaticious",
              "priority": "high",
              "alert": true,
            },
            "to": tokenId
          },
        ));
  } catch (e) {
    // ignore: avoid_print
    print(e);
  }
}
