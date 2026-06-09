import 'package:flutter/material.dart';

/// Soft fade used for screen transitions across the app.
class DayfiFadePageTransitionsBuilder extends PageTransitionsBuilder {
  const DayfiFadePageTransitionsBuilder();

  static const Duration duration = Duration(milliseconds: 280);
  static const Duration reverseDuration = Duration(milliseconds: 220);

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
    return FadeTransition(opacity: curved, child: child);
  }
}

PageTransitionsTheme dayfiPageTransitionsTheme() {
  const builder = DayfiFadePageTransitionsBuilder();
  return const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: builder,
      TargetPlatform.iOS: builder,
      TargetPlatform.macOS: builder,
      TargetPlatform.linux: builder,
      TargetPlatform.windows: builder,
      TargetPlatform.fuchsia: builder,
    },
  );
}

/// Named-route and imperative pushes that should match [dayfiPageTransitionsTheme].
class DayfiPageRoute<T> extends MaterialPageRoute<T> {
  DayfiPageRoute({
    required super.builder,
    super.settings,
    super.fullscreenDialog,
    super.maintainState,
  });
}
