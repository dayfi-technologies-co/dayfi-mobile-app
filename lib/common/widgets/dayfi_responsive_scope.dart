import 'package:dayfi/common/utils/dayfi_platform.dart';
import 'package:dayfi/features/web/utils/web_route_helper.dart';
import 'package:flutter/material.dart';

/// Breakpoints and max widths for Flutter web app shells (not marketing pages).
abstract final class DayfiResponsive {
  DayfiResponsive._();

  static const double wideBreakpoint = 600;
  static const double appContentMaxWidth = 500;
  static const double formContentMaxWidth = 420;
  static const double dialogMaxWidth = 420;
  static const double authMaxWidth = 400;

  static bool isWide(double viewportWidth) =>
      viewportWidth > wideBreakpoint;

  static bool isWideContext(BuildContext context) =>
      isWide(MediaQuery.sizeOf(context).width);
}

/// Tracks the active route so [DayfiWebAppShell] can skip marketing pages.
class DayfiRouteTracker extends NavigatorObserver {
  final ValueNotifier<String?> routeName = ValueNotifier<String?>(null);

  void _sync(Route<dynamic>? route) {
    final name = route?.settings.name;
    if (routeName.value == name) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (routeName.value != name) {
        routeName.value = name;
      }
    });
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _sync(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _sync(previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _sync(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _sync(newRoute);
  }
}

bool dayfiShouldUseResponsiveFrame(String? routeName) {
  if (!isDayfiWeb) return false;

  if (routeName != null && isPublicWebRoute(routeName)) {
    return false;
  }

  if (routeName == null) {
    final mapped = webRouteForPath(Uri.base.path);
    if (mapped != null && isPublicWebRoute(mapped)) {
      return false;
    }
  }

  return true;
}

/// Centers the authenticated app in a phone-width column on wide web viewports.
class DayfiResponsiveFrame extends StatelessWidget {
  const DayfiResponsiveFrame({
    super.key,
    required this.child,
    this.maxWidth = DayfiResponsive.appContentMaxWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    if (!isDayfiWeb) return child;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!DayfiResponsive.isWide(constraints.maxWidth)) {
          return child;
        }

        final outerColor = Theme.of(context).scaffoldBackgroundColor;
        final columnWidth = maxWidth.clamp(0, constraints.maxWidth).toDouble();
        final columnHeight = constraints.maxHeight;

        return ColoredBox(
          color: outerColor,
          child: Center(
            child: SizedBox(
              width: columnWidth,
              height: columnHeight,
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  size: Size(columnWidth, columnHeight),
                ),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Wraps [MaterialApp] content on web; marketing routes stay full-bleed.
class DayfiWebAppShell extends StatelessWidget {
  const DayfiWebAppShell({
    super.key,
    required this.routeTracker,
    required this.child,
  });

  final DayfiRouteTracker routeTracker;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!isDayfiWeb) return child;

    return ValueListenableBuilder<String?>(
      valueListenable: routeTracker.routeName,
      builder: (context, routeName, shellChild) {
        if (!dayfiShouldUseResponsiveFrame(routeName)) {
          return shellChild!;
        }
        return DayfiResponsiveFrame(child: shellChild!);
      },
      child: child,
    );
  }
}

/// Centers scrollable body content when a screen is not under [DayfiWebAppShell].
class DayfiResponsiveBody extends StatelessWidget {
  const DayfiResponsiveBody({
    super.key,
    required this.child,
    this.maxWidth = DayfiResponsive.formContentMaxWidth,
    this.padding,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = isDayfiWeb && DayfiResponsive.isWide(constraints.maxWidth);
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isWide ? maxWidth : double.infinity,
            ),
            child: Padding(
              padding:
                  padding ??
                  EdgeInsets.symmetric(horizontal: isWide ? 24 : 18),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
