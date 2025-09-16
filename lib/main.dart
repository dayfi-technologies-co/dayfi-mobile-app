import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:onebank/app.dart';
import 'package:onebank/app_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(const MyApp());
  });
}
