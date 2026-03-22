import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:home_widget/home_widget.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
      },
    );
  }

  /// Schedule a repeating notification every 2 hours
  static Future<void> schedulePeriodicNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'periodic_channel',
      'Periodic Notifications',
      channelDescription: 'Notifications sent every 2 hours',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.periodicallyShow(
      0,
      'TokN Reminder',
      'Don\'t forget to check your token status!',
      RepeatInterval.everyMinute, // For testing; change to hourly in production
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// Show a live alert (delivery-style persistent notification)
  static Future<void> showLiveAlert({
    String servingNumber = '42',
    String mineNumber = '48',
    String hospitalName = 'City General',
    String waitTime = '15',
  }) async {
    // Sync with HomeWidget (Android Widget)
    await HomeWidget.saveWidgetData('hospital', hospitalName);
    await HomeWidget.saveWidgetData('serving', servingNumber);
    await HomeWidget.saveWidgetData('mine', mineNumber);
    await HomeWidget.saveWidgetData('wait_time', waitTime);
    await HomeWidget.updateWidget(name: 'TokenWidgetProvider', androidName: 'TokenWidgetProvider');

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'live_alert_channel',
      'Live Alerts',
      channelDescription: 'Real-time booking updates',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
      styleInformation: BigTextStyleInformation(''),
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'get_directions',
          'Get Directions',
          showsUserInterface: true,
        ),
      ],
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      1,
      'Serving #$servingNumber | Mine #$mineNumber',
      '$hospitalName • ~$waitTime mins wait',
      platformChannelSpecifics,
    );
  }

  /// Cancel all notifications
  static Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
