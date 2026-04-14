// ignore_for_file: avoid_print, unused_local_variable, unused_element, use_build_context_synchronously, unused_field, file_names, constant_identifier_names, deprecated_member_use, unused_import
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification click if needed
      },
    );
    _initialized = true;
  }

  static Future<void> requestPermission() async {
    await Permission.notification.request();
  }

  static Future<void> showBookingConfirmation({
    required String patientName,
    required String type,
    required String token,
  }) async {
    await init();
    
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'booking_channel',
      'Booking Notifications',
      channelDescription: 'Notifications for successful token bookings',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      color: Color(0xFF2E4C9D), // Optional styling
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    final String title = 'Booking Confirmed! 🎉';
    final String body = 'Your $type token for $patientName is confirmed. Token number: $token.';

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000), // Random ID
      title,
      body,
      platformChannelSpecifics,
    );
  }
}
