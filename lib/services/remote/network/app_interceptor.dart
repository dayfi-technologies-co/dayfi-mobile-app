import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/core/auth/logout_navigation_suppressor.dart';
import 'package:dayfi/core/auth/unauthorized_navigation_guard.dart';
import 'package:dayfi/services/data_clearing_service.dart';
import 'package:dayfi/common/utils/app_logger.dart';

/// [Interceptor] extension for setting token header
/// and other required properties for all requests
class AppInterceptor extends Interceptor {
  String authToken;
  AppInterceptor(this.authToken);

  /// sets the auth token and App token
  /// App token is an identify for each app
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (authToken.isNotEmpty) {
      options.headers.addAll({"Authorization": "Bearer $authToken"});
    }
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    final code = response.statusCode ?? 0;
    if (code >= 200 && code < 400) {
      response.statusCode = 200;
    } else if (code == 401) {
      // Handle token expiry - clear all data and redirect to login
      await _handleTokenExpiry();
    }
    return super.onResponse(response, handler);
  }

  /// Handle token expiry by clearing all user data and redirecting to login.
  ///
  /// Guarded so a burst of 401s only triggers a single redirect.
  Future<void> _handleTokenExpiry() async {
    if (LogoutNavigationSuppressor.isActive) {
      return;
    }
    if (!UnauthorizedNavigationGuard.tryBegin()) {
      return;
    }
    try {
      AppLogger.info('Token expired, clearing all user data...');

      final container = ProviderContainer();
      final dataClearingService = DataClearingService();
      await dataClearingService.clearAllUserDataWithContainer(container);

      appRouter.pushLoginAndClearStack(arguments: false);

      AppLogger.info('Token expiry handled successfully');
    } catch (e) {
      AppLogger.error('Error handling token expiry: $e');
      try {
        appRouter.pushLoginAndClearStack(arguments: false);
      } catch (navError) {
        AppLogger.error('Error navigating to login after token expiry: $navError');
      }
    } finally {
      UnauthorizedNavigationGuard.scheduleEnd();
    }
  }
}
