// Notification service using Firebase Cloud Messaging
import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../core/logging/app_logger.dart';
import '../core/storage/storage.dart';
import '../features/notifications/data/repository/fcm_repository.dart';

const String _fcmLastRegisteredTokenKey = 'fcm_last_registered_token';

const AndroidNotificationChannel _androidChannel = AndroidNotificationChannel(
  'commercepal_high_importance',
  'CommercePal Notifications',
  description: 'Order updates and promotional notifications',
  importance: Importance.high,
);

/// Top-level background handler required by firebase_messaging.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    AppLogger.i(
      'Background message: ${message.notification?.title}',
      data: message.data,
    );
  }
}

/// Handles push notification setup, display, and backend token registration.
/// Call [initialize] after [Firebase.initializeApp] (e.g. in main.dart).
class NotificationService {
  NotificationService._({
    FcmRepository? fcmRepository,
    Storage? storage,
  })  : _fcmRepository = fcmRepository ?? FcmRepository(),
        _storage = storage ?? Storage();

  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;

  final FcmRepository _fcmRepository;
  final Storage _storage;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _localNotificationsReady = false;

  static const Duration _fcmTokenTimeout = Duration(seconds: 8);

  static Future<void> initialize() async {
    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      final messaging = FirebaseMessaging.instance;

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

      if (!kIsWeb && Platform.isIOS) {
        await FirebaseMessaging.instance
            .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      await _instance._setupLocalNotifications();

      final token = await _getTokenWithTimeout(messaging);
      if (kDebugMode && token != null) {
        AppLogger.i('FCM token captured', data: {'token': token});
      }

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        if (kDebugMode) {
          AppLogger.i('FCM token refreshed', data: {'token': newToken});
        }
        final hasTokens = await _instance._storage.hasTokens();
        if (hasTokens) {
          await _instance.registerTokenWithBackend(tokenOverride: newToken);
        }
      });

      FirebaseMessaging.onMessage.listen(_onMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

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

  Future<void> _setupLocalNotifications() async {
    if (kIsWeb) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifications.initialize(initSettings);

    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_androidChannel);

    _localNotificationsReady = true;
  }

  static void _onMessage(RemoteMessage message) {
    if (kDebugMode) {
      AppLogger.i(
        'Foreground message: ${message.notification?.title}',
        data: message.data,
      );
    }
    _instance._showForegroundNotification(message);
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    if (!_localNotificationsReady) return;

    final notification = message.notification;
    if (notification == null) return;

    // iOS already shows via setForegroundNotificationPresentationOptions
    if (!kIsWeb && Platform.isIOS) return;

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: message.data.isEmpty ? null : message.data.toString(),
    );
  }

  static void _onMessageOpenedApp(RemoteMessage message) {
    _handleMessageOpened(message);
  }

  static void _handleMessageOpened(RemoteMessage message) {
    if (kDebugMode) {
      AppLogger.i('Opened from notification', data: message.data);
    }
  }

  Future<String?> getToken() async {
    return _getTokenWithTimeout(FirebaseMessaging.instance);
  }

  static Future<String?> _getTokenWithTimeout(FirebaseMessaging messaging) async {
    try {
      return await messaging.getToken().timeout(_fcmTokenTimeout);
    } on TimeoutException {
      AppLogger.w('FCM getToken timed out');
      return null;
    } catch (e) {
      AppLogger.e('getToken failed', error: e);
      return null;
    }
  }

  String _deviceType() {
    if (kIsWeb) return 'WEB';
    if (Platform.isIOS) return 'IOS';
    if (Platform.isAndroid) return 'ANDROID';
    return 'ANDROID';
  }

  /// Registers the current FCM token with the CommercePal backend.
  /// Safe to call repeatedly; failures are logged and do not throw to callers
  /// that wrap this in try/catch for login/splash.
  Future<void> registerTokenWithBackend({String? tokenOverride}) async {
    try {
      final token = tokenOverride ?? await getToken();
      if (token == null || token.isEmpty) {
        AppLogger.w('FCM register skipped: no device token');
        return;
      }

      final last = await _storage.readData(_fcmLastRegisteredTokenKey);
      if (last == token) {
        if (kDebugMode) {
          AppLogger.i('FCM register skipped: token already registered');
        }
        return;
      }

      final deviceId = await _storage.getOrCreateDeviceId();
      await _fcmRepository.register(
        fcmToken: token,
        deviceType: _deviceType(),
        deviceId: deviceId,
      );
      await _storage.writeData(key: _fcmLastRegisteredTokenKey, value: token);
      if (kDebugMode) {
        AppLogger.i(
          'FCM token registered with backend',
          data: {'deviceType': _deviceType(), 'deviceId': deviceId},
        );
      }
    } catch (e, st) {
      AppLogger.e('FCM registerTokenWithBackend failed', error: e, stack: st);
    }
  }

  /// Unregisters the FCM token from the backend. Call while auth tokens are
  /// still present so the Bearer header can be sent.
  Future<void> unregisterTokenFromBackend() async {
    try {
      final token = await getToken();
      final cached = await _storage.readData(_fcmLastRegisteredTokenKey);
      final fcmToken = (token != null && token.isNotEmpty) ? token : cached;

      if (fcmToken == null || fcmToken.isEmpty) {
        await _storage.deleteData(_fcmLastRegisteredTokenKey);
        return;
      }

      await _fcmRepository.unregister(fcmToken: fcmToken);
      await _storage.deleteData(_fcmLastRegisteredTokenKey);
      if (kDebugMode) {
        AppLogger.i('FCM token unregistered from backend');
      }
    } catch (e, st) {
      AppLogger.e(
        'FCM unregisterTokenFromBackend failed',
        error: e,
        stack: st,
      );
      // Clear local cache even if API fails so we re-register on next login.
      try {
        await _storage.deleteData(_fcmLastRegisteredTokenKey);
      } catch (_) {}
    }
  }

  /// Clears locally cached registration without calling the API.
  Future<void> clearLocalRegistration() async {
    await _storage.deleteData(_fcmLastRegisteredTokenKey);
  }
}
