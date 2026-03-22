// Notification service using Firebase Cloud Messaging
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../core/logging/app_logger.dart';

/// Handles push notification setup and callbacks.
/// Call [initialize] after [Firebase.initializeApp] (e.g. in main.dart).
class NotificationService {
  NotificationService._();

  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;

  static Future<void> initialize() async {
    try {
      final messaging = FirebaseMessaging.instance;

      // Request permission (required on iOS; optional on Android 13+)
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      if (kDebugMode) {
        AppLogger.i(
          'Notification permission: ${settings.authorizationStatus}',
          data: {
            'alert': settings.alert,
            'badge': settings.badge,
            'sound': settings.sound,
          },
        );
      }

      // On iOS, show heads-up when app is in foreground
      if (Platform.isIOS) {
        await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      // FCM token (send to your backend to target this device)
      final token = await messaging.getToken();
      if (token != null && kDebugMode) {
        AppLogger.i('FCM token: $token');
      }

      // Optional: subscribe to a topic
      // await messaging.subscribeToTopic('orders');

      // Foreground messages
      FirebaseMessaging.onMessage.listen(_onMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

      // App opened from terminated state via notification
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpened(initialMessage);
      }
    } catch (e, st) {
      AppLogger.e(
        'NotificationService.initialize failed',
        error: e,
        stack: st,
      );
    }
  }

  static void _onMessage(RemoteMessage message) {
    if (kDebugMode) {
      AppLogger.i(
        'Foreground message: ${message.notification?.title}',
        data: message.data,
      );
    }
    // Optional: show in-app banner or update UI
  }

  static void _onMessageOpenedApp(RemoteMessage message) {
    _handleMessageOpened(message);
  }

  static void _handleMessageOpened(RemoteMessage message) {
    if (kDebugMode) {
      AppLogger.i('Opened from notification', data: message.data);
    }
    // Navigate based on message.data (e.g. orderId, screen, deep link)
    // You can use a global navigator key or pass a callback from app.
  }

  /// Call from backend or after login to register this device's FCM token.
  Future<String?> getToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      AppLogger.e('getToken failed', error: e);
      return null;
    }
  }
}
