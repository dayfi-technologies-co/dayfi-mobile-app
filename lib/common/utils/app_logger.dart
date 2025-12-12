import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class AppLogger {
  static void log(dynamic message, {String? name, Object? error, StackTrace? stackTrace}) {
    if (!kDebugMode) return;

    // final logName = name ?? 'AppLogger';
    // final logMessage = message.toString();

    // developer.log(logMessage, name: logName, error: error, stackTrace: stackTrace);
  }

  static void info(dynamic message) {
    log(message, name: 'INFO');
  }

  static void warning(dynamic message) {
    log(message, name: 'WARNING');
  }

  static void error(dynamic message, {Object? error, StackTrace? stackTrace}) {
    log(message, name: 'ERROR', error: error, stackTrace: stackTrace);
  }

  static void debug(dynamic message) {
    log(message, name: 'DEBUG');
  }
}
