import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/app.dart';
import 'core/config/env.dart';
import 'core/logging/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
