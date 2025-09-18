import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:dayfi/app.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/flavor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  F.init();
  await setupLocator();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(const MyApp());
  });
}
