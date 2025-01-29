import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones(); // Initialize timezone data

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _notifications.initialize(settings);
    if (kDebugMode) {
      print("ntf initialized");
    }
  }



  // Request the necessary permissions at runtime
  Future<void> requestPermissions() async {
    // Request notification permission
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    // Request exact alarm permission
    // if (await Permission.systemAlertWindow.isDenied) {
    //   await Permission.systemAlertWindow.request();
    // }
  }
  
  
Future<void> scheduleNotification(int id, String title, DateTime dueDate) async {
  
  final tzDateTime = tz.TZDateTime.from(dueDate.subtract(const Duration(hours: 1)), tz.local);
  print('Scheduled notification at: $tzDateTime');

  if (tzDateTime.isAfter(DateTime.now())) {
    try {
      await _notifications.zonedSchedule(
        id,
        'Task Reminder',
        title,
        tzDateTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_channel',
            'Tasks',
            channelDescription: 'Reminders for your tasks',
            importance: Importance.max,  // Set importance to high
            priority: Priority.high,
            playSound: true,
            fullScreenIntent: true,
          ),
        ),
        
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
      if (kDebugMode) {
        print('Notification scheduled successfully!');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error scheduling notification: $e');
        print('StackTrace: $stackTrace');
      }
    }
  } else {
    if (kDebugMode) {
      print('The scheduled time is in the past!');
    }
  }
}


  
  Future<void> showImmediateNotification(int id,String title) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'test_channel',
      'Immediate Notifications',
      channelDescription: 'Immediate notification test',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notifications.show(
      id, // Notification ID
      'New Task Created',
      title,
      platformChannelSpecifics,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
}

