import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'app/app.dart';
import 'core/config/env.dart';
import 'core/logging/app_logger.dart';
import 'core/update/app_update_remote_config.dart';
import 'services/localization_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Home shows many product tiles; keep more decoded images in memory while scrolling.
  final ImageCache imageCache = PaintingBinding.instance.imageCache;
  imageCache.maximumSize = 200;
  imageCache.maximumSizeBytes = 120 << 20; // 120 MB

  await LocalizationService.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    AppLogger.i('Firebase initialized successfully');

    await AppUpdateRemoteConfig.initialize(
      defaultLatestVersionAndroid: '6.0.3',
      defaultLatestVersionIos: '6.0.3',
    );

    // Do not block first frame: iOS FCM getToken can wait indefinitely for APNS.
    unawaited(NotificationService.initialize());

    // Initialize Crashlytics
    // FlutterError.onError = (errorDetails) {
    //   FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    // };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    // Initialize Performance Monitoring
    final performance = FirebasePerformance.instance;
    performance.setPerformanceCollectionEnabled(true);
  } catch (e) {
    AppLogger.e('Failed to initialize Firebase', error: e);
  }

  try {
    await dotenv.load(fileName: '.env');
    await Env.initialize();
    AppLogger.i('App starting');
  } catch (e) {
    AppLogger.e('Failed to load .env file', error: e);
    // Initialize with defaults if .env fails to load
    await Env.initialize();
  }

  runApp(const MyApp());
}
