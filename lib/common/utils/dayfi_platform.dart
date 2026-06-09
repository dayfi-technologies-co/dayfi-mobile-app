import 'package:flutter/foundation.dart';

/// True when running in a browser (Flutter web).
bool get isDayfiWeb => kIsWeb;

/// True when running as a native iOS or Android app.
bool get isDayfiNativeApp => !kIsWeb;
