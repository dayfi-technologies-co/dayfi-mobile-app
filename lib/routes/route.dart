import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dayfi/features/auth/login/views/login_view.dart';
import 'package:dayfi/features/auth/splash/views/splash_view.dart';

class AppRoute {
  static RouteSettings globalrouteSettings = const RouteSettings();

  static const String splashView = '/splashView';
  static const String loginView = '/loginView';

  static Route getRoute(RouteSettings routeSettings) {
    globalrouteSettings = routeSettings;
    switch (routeSettings.name) {
      case loginView:
        return _getPageRoute(routeSettings, const LoginView());
      case splashView:
        return _getPageRoute(routeSettings, const SplashView());
      //example for passing arguments to a route
      //  case highTransactionLimitStep2View:
      // HighTransactionLimitStep2ViewArguments args = routeSettings.arguments as HighTransactionLimitStep2ViewArguments;
      // return _getPageRoute(
      //   routeSettings,
      //   HighTransactionLimitStep2View(
      //     highLimitArgs: args,
      //   ),
      // );

      default:
        return _getPageRoute(routeSettings, const LoginView());
    }
  }

  static Route _getPageRoute(RouteSettings routeSettings, Widget screen, {bool isFullScreen = false}) {
    if (Platform.isIOS) {
      return CupertinoPageRoute(
        settings: routeSettings,
        builder: (context) {
          return screen;
        },
        fullscreenDialog: isFullScreen,
      );
    }
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (context) {
        return screen;
      },
      fullscreenDialog: isFullScreen,
    );
  }
}
