import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:dayfi/app.dart';
import 'package:dayfi/flavors.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/utils/app_logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set flavor
  F.appFlavor = Flavor.dev;

  // Skip mobile-only initializations on web
  if (!kIsWeb) {
    AppLogger.info('Non-web platform: you may initialize mobile-only services here');
  } else {
    AppLogger.info('Web flavor: skipping mobile-only services');
  }

  await setupLocator();

  runApp(const MyApp());
}
