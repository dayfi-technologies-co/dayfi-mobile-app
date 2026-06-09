import 'package:dio/dio.dart';
import 'package:dayfi/core/auth/session_auth_service.dart';

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
      await SessionAuthService.handleUnauthorized();
    }
    return super.onResponse(response, handler);
  }
}
