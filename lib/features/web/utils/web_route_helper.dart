import 'package:dayfi/common/utils/dayfi_platform.dart';
import 'package:dayfi/routes/route.dart';

/// Where logged-out users should land: marketing site on web, onboarding on native.
String get unauthenticatedEntryRoute =>
    isDayfiWeb ? AppRoute.webLandingView : AppRoute.onboardingView;

/// Routes that can render immediately on web without waiting for secure storage.
String? instantWebBootRoute(String uriPath) {
  if (!isDayfiWeb) return null;

  final mapped = webRouteForPath(uriPath);
  if (mapped != null && isPublicWebRoute(mapped)) return mapped;
  if (mapped == AppRoute.loginPath) return AppRoute.loginView;
  if (mapped == AppRoute.signupPath) return AppRoute.signupView;

  // Optimistic shell for `/` — auth check may redirect logged-in users later.
  if (_normalizePath(uriPath) == AppRoute.webLandingView) {
    return AppRoute.webLandingView;
  }

  return null;
}

/// Public marketing / legal pages on web. App auth routes are handled separately.
const _publicWebPaths = <String>{
  AppRoute.webLandingView,
  AppRoute.webTermsPath,
  AppRoute.webPrivacyPath,
  AppRoute.webAboutPath,
  AppRoute.webSecurityPath,
  AppRoute.webGovernmentPath,
  AppRoute.webFaqPath,
};

String _normalizePath(String path) {
  if (path.isEmpty) return AppRoute.webLandingView;
  var normalized = path;
  if (!normalized.startsWith('/')) {
    normalized = '/$normalized';
  }
  if (normalized.length > 1 && normalized.endsWith('/')) {
    normalized = normalized.substring(0, normalized.length - 1);
  }
  return normalized;
}

/// Maps a browser path to an app route name, or null if unknown.
String? webRouteForPath(String path) {
  final normalized = _normalizePath(path);
  switch (normalized) {
    case AppRoute.webLandingView:
      return AppRoute.webLandingView;
    case AppRoute.webTermsPath:
    case '/terms-of-use':
      return AppRoute.webTermsPath;
    case AppRoute.webPrivacyPath:
    case '/privacy-notice':
      return AppRoute.webPrivacyPath;
    case AppRoute.webAboutPath:
      return AppRoute.webAboutPath;
    case AppRoute.webSecurityPath:
      return AppRoute.webSecurityPath;
    case AppRoute.webGovernmentPath:
    case '/government-law-enforcement':
      return AppRoute.webGovernmentPath;
    case AppRoute.webFaqPath:
    case AppRoute.faqView:
      return AppRoute.webFaqPath;
    case AppRoute.loginPath:
      return AppRoute.loginPath;
    case AppRoute.signupPath:
      return AppRoute.signupPath;
    default:
      return null;
  }
}

bool isPublicWebRoute(String route) => _publicWebPaths.contains(route);

/// Resolves the bootstrap route when running on Flutter web.
String resolveWebInitialRoute({
  required String uriPath,
  required String fallbackAppRoute,
  required bool isAuthenticated,
}) {
  if (!isDayfiWeb) return fallbackAppRoute;

  final normalized = _normalizePath(uriPath);

  // Logged-in users at `/` should enter the app, not marketing.
  if (normalized == AppRoute.webLandingView) {
    return isAuthenticated ? fallbackAppRoute : AppRoute.webLandingView;
  }

  final mapped = webRouteForPath(uriPath);
  if (mapped != null && isPublicWebRoute(mapped)) {
    return mapped;
  }
  if (mapped == AppRoute.loginPath) {
    return AppRoute.loginView;
  }
  if (mapped == AppRoute.signupPath) {
    return AppRoute.signupView;
  }

  return fallbackAppRoute;
}
