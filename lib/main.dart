import 'package:dayfi/services/local/analytics_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_strategy/url_strategy.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intercom_flutter/intercom_flutter.dart';
// import 'package:smile_id/smile_id.dart';

import 'package:dayfi/app.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/flavors.dart';
import 'package:dayfi/firebase_options.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Smile ID SDK
  try {
    // SmileID.initialize(useSandbox: true, enableCrashReporting: true);
    AppLogger.info('Smile ID initialized successfully');
  } catch (e) {
    AppLogger.error('Smile ID initialization error: $e');
  }

  try {
    F.appFlavor = Flavor.values.firstWhere(
      (element) => element.name == appFlavor,
    );
    AppLogger.info('App flavor initialized: ${F.appFlavor.name}');
  } catch (e) {
    AppLogger.error('Error initializing app flavor: $e');
    F.appFlavor = Flavor.values.first;
  }

  // Enable path URL strategy on web to remove '#' from URLs
  if (kIsWeb) setPathUrlStrategy();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    await NotificationService().init();
    AppLogger.info('Notification service initialized successfully');
  } catch (e) {
    AppLogger.error('Firebase initialization error: $e');
  }

  // Initialize Intercom
  try {
    const String intercomAppId = 'ihv28wow';
    const String intercomAndroidKey =
        'android_sdk-ca7182fe1675e2a978f6041b3c6d93e3672ca418';
    const String intercomIOSKey =
        'ios_sdk-b87b21cdfb0ee5f75291d95bd72845bb4a30e6f7';

    await Intercom.instance.initialize(
      intercomAppId,
      iosApiKey: intercomIOSKey,
      androidApiKey: intercomAndroidKey,
    );
    await Intercom.instance.setLauncherVisibility(IntercomVisibility.gone);
    await Intercom.instance.loginUnidentifiedUser();
    AppLogger.info('Intercom initialized successfully');
  } catch (e) {
    AppLogger.error('Intercom initialization error: $e');
  }

  try {
    await setupLocator();
    AppLogger.info('App locator setup completed');
    try {
      final analyticsService = locator<AnalyticsService>();
      await Future.delayed(Duration(seconds: 2));
      await analyticsService.logEvent(name: 'app_launched_test');
      AppLogger.info('Analytics test event sent');
    } catch (e) {
      AppLogger.error('Analytics initialization error: $e');
    }
  } catch (e) {
    AppLogger.error('Error setting up app locator: $e');
  }

  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } catch (e) {
    AppLogger.error('Error setting system chrome orientation: $e');
  }

  try {
    runApp(const MyApp());
    AppLogger.info('App started successfully');
  } catch (e) {
    AppLogger.error('Error starting app: $e');
    rethrow;
  }
}