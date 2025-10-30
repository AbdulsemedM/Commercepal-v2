import 'package:flutter/foundation.dart';

class LogFilters {
  LogFilters._();

  static bool get isLoggingEnabled => kDebugMode;
}
