import 'package:dayfi/flavors.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter/material.dart' show TargetPlatform;

/// Google OAuth client IDs for social sign-in.
///
/// iOS requires an OAuth client registered for the app bundle ID. Override per
/// flavor with `--dart-define=GOOGLE_IOS_CLIENT_ID=…` after downloading
/// [GoogleService-Info.plist] from Firebase for that iOS app.
class GoogleAuthConfig {
  GoogleAuthConfig._();

  static const String _iosClientIdFromEnv = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
    defaultValue: '',
  );
  static const String _serverClientIdFromEnv = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '',
  );
  static const String _webClientIdFromEnv = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '',
  );

  /// Dev iOS client (`com.dayfi.test`) from Firebase / GoogleService-Info.plist.
  static const String _devIosClientId =
      '826631103417-uc5f8ruhc8av1ncunkpufu9dpa1190ar.apps.googleusercontent.com';

  static String? get iosClientId {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return null;
    if (_iosClientIdFromEnv.isNotEmpty) return _iosClientIdFromEnv;
    switch (F.appFlavor) {
      case Flavor.dev:
        return _devIosClientId;
      case Flavor.pilot:
      case Flavor.prod:
        // Register pilot/prod bundle IDs in Firebase, then pass dart-define or
        // add their CLIENT_ID values here.
        return _devIosClientId;
    }
  }

  static String? get webClientId {
    if (!kIsWeb) return null;
    return _webClientIdFromEnv.isNotEmpty ? _webClientIdFromEnv : null;
  }

  /// Web client ID — required on mobile for [GoogleSignInAuthentication.accessToken].
  /// Falls back to the Firebase iOS client when no web client is configured.
  static String? get serverClientId {
    if (_serverClientIdFromEnv.isNotEmpty) return _serverClientIdFromEnv;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      return iosClientId;
    }
    return null;
  }
}
