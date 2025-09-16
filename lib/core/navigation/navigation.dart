import 'package:flutter/material.dart';

import 'navigator_key.dart';

class AppRouter {
  final NavigatorState _navigatorState =
      NavigatorKey.appNavigatorKey.currentState!;

  NavigatorState get navigatorState => _navigatorState;

  bool canPop() {
    return navigatorState.canPop();
  }

  void popSheet(BuildContext context) {
    Navigator.of(context).pop();
  }

  void pop<T extends Object?>([T? result]) {
    navigatorState.pop<T>(result);
  }

  Future<T?> popAndPushNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) {
    return navigatorState.popAndPushNamed<T, TO>(
      routeName,
      result: result,
      arguments: arguments,
    );
  }

  void popUntil(String routeName) {
    navigatorState.popUntil((Route route) {
      return route.settings.name == routeName;
    });
  }

  void popUntilRoot() {
    navigatorState.popUntil((Route route) {
      return route.isFirst;
    });
  }

  Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return navigatorState.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  static Future pushN(String route, {arguments}) {
    return NavigatorKey.appNavigatorKey.currentState!
        .pushNamed(route, arguments: arguments);
  }

  Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    String newRouteName,
    predicate, {
    Object? arguments,
  }) {
    return navigatorState.pushNamedAndRemoveUntil<T>(
      newRouteName,
      predicate,
      arguments: arguments,
    );
  }

  Future<T?> pushNamedAndRemoveAllBehind<T extends Object?>(
    String newRouteName, {
    Object? arguments,
  }) {
    return navigatorState.pushNamedAndRemoveUntil<T>(
      newRouteName,
      (Route route) => false,
      arguments: arguments,
    );
  }

  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) {
    return navigatorState.pushReplacementNamed<T, TO>(
      routeName,
      result: result,
      arguments: arguments,
    );
  }

  void dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}

class AppLevelRouter extends AppRouter {
  AppLevelRouter();

  @override
  NavigatorState get navigatorState =>
      NavigatorKey.appNavigatorKey.currentState!;
}
