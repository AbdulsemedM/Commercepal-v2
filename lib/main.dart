import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/logging/app_logger.dart';

void main() {
  AppLogger.i('App starting');
  runApp(MyApp());
}
