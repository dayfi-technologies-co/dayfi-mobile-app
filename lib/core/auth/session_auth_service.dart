import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/constants/storage_keys.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/core/auth/logout_navigation_suppressor.dart';
import 'package:dayfi/core/auth/unauthorized_navigation_guard.dart';
import 'package:dayfi/services/data_clearing_service.dart';
import 'package:dayfi/services/local/secure_storage.dart';

/// Keeps users signed in for the configured JWT lifetime (~30 days).
///
/// On 401 we first try a silent email/password re-login, then fall back to the
/// passcode lock screen instead of wiping the whole session.
class SessionAuthService {
  SessionAuthService._();

  static bool _refreshInProgress = false;

  static Future<bool> trySilentSessionRefresh() async {
    if (_refreshInProgress) return false;

    _refreshInProgress = true;
    LogoutNavigationSuppressor.begin();
    try {
      final storage = locator<SecureStorageService>();
      final email = (await storage.read(StorageKeys.email)).trim();
      final password = await storage.read(StorageKeys.password);

      if (email.isEmpty || password.isEmpty) {
        return false;
      }

      final response = await authService.login(
        email: email,
        password: password,
      );

      final token = response.data?.token?.trim() ?? '';
      if (!response.error && token.isNotEmpty) {
        AppLogger.info('Session token refreshed silently');
        return true;
      }

      return false;
    } catch (e) {
      AppLogger.warning('Silent session refresh failed: $e');
      return false;
    } finally {
      LogoutNavigationSuppressor.end();
      _refreshInProgress = false;
    }
  }

  /// Handles expired/invalid auth for API calls.
  static Future<void> handleUnauthorized() async {
    if (LogoutNavigationSuppressor.isActive) {
      AppLogger.info('Skipping 401 handler during manual logout');
      return;
    }
    if (!UnauthorizedNavigationGuard.tryBegin()) {
      AppLogger.info('Skipping 401 handler: redirect already in progress');
      return;
    }

    try {
      AppLogger.info('Unauthorized API response — attempting session recovery');

      if (await trySilentSessionRefresh()) {
        AppLogger.info('Session recovered after 401');
        return;
      }

      final storage = locator<SecureStorageService>();
      final passcode = await storage.read(StorageKeys.passcode);
      final userJson = await storage.read(StorageKeys.user);
      final hasPasscode = passcode.isNotEmpty;
      final hasUser = userJson.isNotEmpty && userJson != 'null';

      if (hasPasscode && hasUser) {
        AppLogger.info('Returning to passcode lock (session expired)');
        await storage.delete(StorageKeys.token);
        appRouter.replaceWithPasscode();
        return;
      }

      AppLogger.info('No recovery path — clearing session');
      final container = ProviderContainer();
      await DataClearingService().clearAllUserDataWithContainer(container);
      appRouter.pushOnboardingAndClearStack();
    } catch (e) {
      AppLogger.error('Error handling unauthorized access: $e');
      try {
        appRouter.pushOnboardingAndClearStack();
      } catch (navError) {
        AppLogger.error('Error navigating after unauthorized access: $navError');
      }
    } finally {
      UnauthorizedNavigationGuard.scheduleEnd();
    }
  }
}
