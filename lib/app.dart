import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/flavor.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/navigation/navigator_key.dart';
import 'package:dayfi/routes/route.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: F.title,
            initialRoute: AppRoute.splashView,
            navigatorKey: NavigatorKey.appNavigatorKey,
            onGenerateRoute: AppRoute.getRoute,
       
          );
        },
      ),
    );
  }
}
