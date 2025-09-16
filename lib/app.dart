import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/common/app_constants.dart';
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
            title: AppConstants.appName,
            initialRoute: AppRoute.splashView,
            navigatorKey: NavigatorKey.appNavigatorKey,
            onGenerateRoute: AppRoute.getRoute,
       
          );
        },
      ),
    );
  }
}
