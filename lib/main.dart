import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:dayfi/app.dart';
import 'package:dayfi/app_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(const MyApp());
  });
}
