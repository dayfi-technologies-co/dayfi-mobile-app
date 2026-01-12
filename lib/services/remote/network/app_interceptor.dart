import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/app_locator.dart';
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
    if (response.statusCode! >= 200 && response.statusCode! < 400) {
      response.statusCode = 200;
    } else if (response.statusCode == 401) {
      // Handle token expiry - clear all data and redirect to login
      await _handleTokenExpiry();
    }
    return super.onResponse(response, handler);
  }

  /// Handle token expiry by clearing all user data and redirecting to login
  Future<void> _handleTokenExpiry() async {
    try {
      AppLogger.info('Token expired, clearing all user data...');
      
      // Create a temporary container for data clearing
      final container = ProviderContainer();
      
      // Use comprehensive data clearing service
      final dataClearingService = DataClearingService();
      await dataClearingService.clearAllUserDataWithContainer(container);
      
      // Navigate to login screen (hide back button)
      appRouter.pushNamedAndRemoveAllBehind('/loginView', arguments: false);
      
      AppLogger.info('Token expiry handled successfully');
    } catch (e) {
      AppLogger.error('Error handling token expiry: $e');
      // Even if there's an error, try to navigate to login
      try {
        appRouter.pushNamedAndRemoveAllBehind('/loginView', arguments: false);
      } catch (navError) {
        AppLogger.error('Error navigating to login after token expiry: $navError');
      }
    }
  }
}
