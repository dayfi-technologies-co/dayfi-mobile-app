import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intercom_flutter/intercom_flutter.dart';

import 'package:dayfi/app.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/flavors.dart';
import 'package:dayfi/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    F.appFlavor = Flavor.values.firstWhere(
      (element) => element.name == appFlavor,
    );
    debugPrint('App flavor initialized: ${F.appFlavor.name}');
  } catch (e) {
    debugPrint('Error initializing app flavor: $e');
    // Set default flavor if there's an error
    F.appFlavor = Flavor.values.first;
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    // Continue without Firebase if initialization fails
  }

  // Initialize Intercom
  try {
    // Use hardcoded values for release builds to avoid environment variable issues
    const String intercomAppId = 'ihv28wow';
    const String intercomAndroidKey = 'android_sdk-ca7182fe1675e2a978f6041b3c6d93e3672ca418';
    const String intercomIOSKey = 'ios_sdk-b87b21cdfb0ee5f75291d95bd72845bb4a30e6f7';
    
    await Intercom.instance.initialize(
      intercomAppId,
      iosApiKey: intercomIOSKey,
      androidApiKey: intercomAndroidKey,
    );
    
    // Set launcher visibility to hidden and login unidentified user
    await Intercom.instance.setLauncherVisibility(IntercomVisibility.gone);
    await Intercom.instance.loginUnidentifiedUser();
    
    debugPrint('Intercom initialized successfully');
  } catch (e) {
    debugPrint('Intercom initialization error: $e');
    // Continue without Intercom if initialization fails
  }

  try {
    await setupLocator();
    debugPrint('App locator setup completed');
  } catch (e) {
    debugPrint('Error setting up app locator: $e');
    // Continue without locator if there's an error
  }

  try {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]).then((_) {
      try {
        runApp(const MyApp());
        debugPrint('App started successfully');
      } catch (e) {
        debugPrint('Error starting app: $e');
        // This is critical - if this fails, the app won't start
        rethrow;
      }
    });
  } catch (e) {
    debugPrint('Error setting system chrome orientation: $e');
    // Fallback - start app without orientation restriction
    try {
      runApp(const MyApp());
    } catch (e) {
      debugPrint('Critical error starting app: $e');
      rethrow;
    }
  }
}
