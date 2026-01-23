import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'app/app.dart';
import 'core/config/env.dart';
import 'core/logging/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    AppLogger.i('Firebase initialized successfully');

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

  runApp(MyApp());
}
