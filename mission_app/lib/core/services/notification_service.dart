import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationService {
  FlutterLocalNotificationsPlugin? _notificationsPlugin;

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    _notificationsPlugin = FlutterLocalNotificationsPlugin();
    await _notificationsPlugin!.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Tratar navegação ao clicar na notificação
      },
    );
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'go4me_engagement',
      'Engajamento Go4Me',
      channelDescription: 'Notificações de novas postagens e atualizações de missões',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      color: const Color(0xFF2E7D32),
    );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(),
    );

    if (_notificationsPlugin == null) return;
    await _notificationsPlugin!.show(id, title, body, platformDetails, payload: payload);
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
