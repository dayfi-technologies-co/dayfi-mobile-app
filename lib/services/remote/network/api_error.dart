import 'package:dio/dio.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/utils/json_utils.dart';
import 'package:dayfi/models/api_response.dart';

class ApiError {
  int? errorType = 0;
  APIResponse? apiErrorModel;

  /// description of error generated this is similar to convention [Error.message]
  String? errorDescription;

  ApiError({this.errorDescription});

  ApiError.fromDio(Object dioError) {
    _handleError(dioError);
  }

  /// Ensures [response.data] is a JSON object before [APIResponse.fromJson].
  /// Servers sometimes return HTML/plain text on 5xx, which Dio may expose as [String].
  static void _normalizeErrorBody(Response<dynamic>? response, String fallbackMessage) {
    final data = response?.data;
    if (data is Map<String, dynamic>) return;
    if (data is Map) {
      response?.data = Map<String, dynamic>.from(data);
      return;
    }
    response?.data = JsonUtils.formatErrorResponse(fallbackMessage);
  }

  /// Handles 4xx/5xx bodies for [DioExceptionType.badResponse]. Safe when [dioError.response] is null.
  void _applyParsedErrorBody(DioException dioError, String fallbackMessage) {
    final response = dioError.response;
    if (response == null) {
      final body = JsonUtils.formatErrorResponse(fallbackMessage);
      apiErrorModel = APIResponse.fromJson(body);
      errorDescription = fallbackMessage;
      return;
    }

    if (response.data != null) {
      if (JsonUtils.isValidJson(response.data.toString())) {
        response.data = JsonUtils.formatErrorResponse(fallbackMessage);
      }
    } else {
      response.data = JsonUtils.formatErrorResponse(fallbackMessage);
    }

    _normalizeErrorBody(response, fallbackMessage);

    final raw = response.data;
    final map = raw is Map<String, dynamic>
        ? raw
        : (raw is Map ? Map<String, dynamic>.from(raw) : JsonUtils.formatErrorResponse(fallbackMessage));

    apiErrorModel = APIResponse.fromJson(map);
    errorDescription = extractDescriptionFromResponse(response);
    if ((errorDescription ?? '').isEmpty) {
      errorDescription = map['message'] as String? ?? fallbackMessage;
    }
  }

  /// sets value of class properties from [error]
  void _handleError(Object error) {
    if (error is DioException) {
      DioException dioError = error;
      if (error.response != null &&
          dioError.type == DioExceptionType.badResponse &&
          dioError.response?.statusCode != 401 &&
          dioError.response?.statusCode != 403) {}

      switch (dioError.type) {
        case DioExceptionType.cancel:
          errorDescription = appStrings.localize.canceledApiRequest;
          break;
        case DioExceptionType.connectionTimeout:
          errorDescription = appStrings.localize.apiConnectionTimeout;
          break;
        case DioExceptionType.badCertificate:
          errorDescription = appStrings.localize.apiBadCertificate;
          break;
        case DioExceptionType.connectionError:
          errorDescription = appStrings.localize.apiConnectionError;
          break;
        case DioExceptionType.unknown:
          errorDescription = appStrings.localize.apiUnknownConnection;
          break;
        case DioExceptionType.receiveTimeout:
          errorDescription = appStrings.localize.apiResponseTimeout;
          break;
        case DioExceptionType.badResponse:
          errorType = dioError.response?.statusCode;
          final statusCode = dioError.response?.statusCode;
          if (statusCode == 400) {
            _applyParsedErrorBody(dioError, appStrings.localize.apiBadRequest);
          } else if (statusCode == 401) {
            _applyParsedErrorBody(dioError, appStrings.localize.apiUnauthorized);
          } else if (statusCode == 403) {
            _applyParsedErrorBody(
              dioError,
              appStrings.localize.apiPermissionDenied,
            );
          } else if (statusCode == 404) {
            _applyParsedErrorBody(
              dioError,
              appStrings.localize.apiContentNotFound,
            );
          } else if (statusCode == 422) {
            _applyParsedErrorBody(
              dioError,
              appStrings.localize.apiUnprocessableEntity,
            );
          } else if (statusCode == 500) {
            _applyParsedErrorBody(
              dioError,
              appStrings.localize.apiServerDowntime,
            );
          } else if (statusCode == 502) {
            errorDescription = appStrings.localize.apiInternalServerError;
          } else if (dioError.response?.statusCode == 503) {
            errorDescription = 'Service temporarily unavailable. Please try again later.';
          } else {
            errorDescription = appStrings.localize.apiInternalServerError;
          }
          break;
        case DioExceptionType.sendTimeout:
          errorDescription = appStrings.localize.apiGenericError;
          break;
      }
    } else {
      errorDescription = appStrings.localize.apiCaughtError;
    }
  }

  String extractDescriptionFromResponse(Response<dynamic>? response) {
    String message = "";
    try {
      final r = response;
      if (r == null) return '';

      final data = r.data;
      if (data != null) {
        if (data is Map<String, dynamic>) {
          final dataMap = data;
          final m = dataMap["message"];
          if (m != null) {
            message = m.toString();
          } else {
            message = r.statusMessage ?? '';
          }
        } else if (data is Map) {
          final m = data["message"];
          message = m != null ? m.toString() : (r.statusMessage ?? '');
        } else {
          message = r.statusMessage ?? 'Server error';
        }
      } else {
        message = r.statusMessage ?? '';
      }
    } catch (error, _) {
      message = response?.statusMessage ?? error.toString();
    }
    return message;
  }

  @override
  String toString() => '$errorDescription';
}
