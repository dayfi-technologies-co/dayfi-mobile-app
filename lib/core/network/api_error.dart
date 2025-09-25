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
          if (dioError.response?.statusCode == 400) {
            if (dioError.response != null && dioError.response!.data != null) {
              if (JsonUtils.isValidJson(dioError.response!.data.toString())) {
                dioError.response!.data = JsonUtils.formatErrorResponse(
                  appStrings.localize.apiBadRequest,
                );
              }
            } else {
              dioError.response!.data = JsonUtils.formatErrorResponse(
                appStrings.localize.apiBadRequest,
              );
            }
            apiErrorModel = APIResponse.fromJson(dioError.response?.data);
            errorDescription = extractDescriptionFromResponse(error.response);
          } else if (dioError.response?.statusCode == 401) {
            if (dioError.response != null && dioError.response!.data != null) {
              if (JsonUtils.isValidJson(dioError.response!.data.toString())) {
                dioError.response!.data = JsonUtils.formatErrorResponse(
                  appStrings.localize.apiUnauthorized,
                );
              }
            } else {
              dioError.response!.data = JsonUtils.formatErrorResponse(
                appStrings.localize.apiUnauthorized,
              );
            }
            apiErrorModel = APIResponse.fromJson(dioError.response?.data);
            errorDescription = extractDescriptionFromResponse(error.response);
          } else if (dioError.response?.statusCode == 403) {
            if (dioError.response != null && dioError.response!.data != null) {
              if (JsonUtils.isValidJson(dioError.response!.data.toString())) {
                dioError.response!.data = JsonUtils.formatErrorResponse(
                  appStrings.localize.apiPermissionDenied,
                );
              }
            } else {
              dioError.response!.data = JsonUtils.formatErrorResponse(
                appStrings.localize.apiPermissionDenied,
              );
            }
            apiErrorModel = APIResponse.fromJson(dioError.response?.data);
            errorDescription = extractDescriptionFromResponse(error.response);
          } else if (dioError.response?.statusCode == 404) {
            if (dioError.response != null && dioError.response!.data != null) {
              if (JsonUtils.isValidJson(dioError.response!.data.toString())) {
                dioError.response!.data = JsonUtils.formatErrorResponse(
                  appStrings.localize.apiContentNotFound,
                );
              }
            } else {
              dioError.response!.data = JsonUtils.formatErrorResponse(
                appStrings.localize.apiContentNotFound,
              );
            }
            apiErrorModel = APIResponse.fromJson(dioError.response?.data);
            errorDescription = extractDescriptionFromResponse(error.response);
          } else if (dioError.response?.statusCode == 422) {
            if (dioError.response != null && dioError.response!.data != null) {
              if (JsonUtils.isValidJson(dioError.response!.data.toString())) {
                dioError.response!.data = JsonUtils.formatErrorResponse(
                  appStrings.localize.apiUnprocessableEntity,
                );
              }
            } else {
              dioError.response!.data = JsonUtils.formatErrorResponse(
                appStrings.localize.apiUnprocessableEntity,
              );
            }
            apiErrorModel = APIResponse.fromJson(dioError.response?.data);
            errorDescription = extractDescriptionFromResponse(error.response);
          } else if (dioError.response?.statusCode == 500) {
            if (dioError.response != null && dioError.response!.data != null) {
              if (JsonUtils.isValidJson(dioError.response!.data.toString())) {
                dioError.response!.data = JsonUtils.formatErrorResponse(
                  appStrings.localize.apiServerDowntime,
                );
              }
            } else {
              dioError.response!.data = JsonUtils.formatErrorResponse(
                appStrings.localize.apiServerDowntime,
              );
            }
            apiErrorModel = APIResponse.fromJson(dioError.response?.data);
            errorDescription = extractDescriptionFromResponse(error.response);
          } else if (dioError.response?.statusCode == 502) {
            errorDescription = appStrings.localize.apiInternalServerError;
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
      if (response?.data != null && response?.data["message"] != null) {
        message = response?.data["message"];
      } else {
        message = response?.statusMessage ?? '';
      }
    } catch (error, _) {
      message = response?.statusMessage ?? error.toString();
    }
    return message;
  }

  @override
  String toString() => '$errorDescription';
}
