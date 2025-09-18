import 'package:dayfi/core/extensions/context_extention.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:dayfi/core/navigation/navigator_key.dart';
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
    BuildContext? context = NavigatorKey.appNavigatorKey.currentContext;
    if (error is DioException) {
      DioException dioError = error;
      if (error.response != null &&
          dioError.type == DioExceptionType.badResponse &&
          dioError.response?.statusCode != 401 &&
          dioError.response?.statusCode != 403) {}

      switch (dioError.type) {
        case DioExceptionType.cancel:
          errorDescription = context!.localizations.canceledApiRequest;
          break;
        case DioExceptionType.connectionTimeout:
          errorDescription = context!.localizations.apiConnectionTimeout;
          break;
        case DioExceptionType.badCertificate:
          errorDescription = context!.localizations.apiBadCertificate;
          break;
        case DioExceptionType.connectionError:
          errorDescription = context!.localizations.apiConnectionError;
          break;
        case DioExceptionType.unknown:
          errorDescription = context!.localizations.apiUnknownConnection;
          break;
        case DioExceptionType.receiveTimeout:
          errorDescription = context!.localizations.apiResponseTimeout;
          break;
        case DioExceptionType.badResponse:
          errorType = dioError.response?.statusCode;
          if (dioError.response?.statusCode == 400) {
            if (dioError.response != null && dioError.response!.data != null) {
              if (JsonUtils.isValidJson(dioError.response!.data.toString())) {
                dioError.response!.data = JsonUtils.formatErrorResponse(
                  context!.localizations.apiBadRequest,
                );
              }
            } else {
              dioError.response!.data = JsonUtils.formatErrorResponse(
                context!.localizations.apiBadRequest,
              );
            }
            apiErrorModel = APIResponse.fromJson(dioError.response?.data);
            errorDescription = extractDescriptionFromResponse(error.response);
          } else if (dioError.response?.statusCode == 401) {
            if (dioError.response != null && dioError.response!.data != null) {
              if (JsonUtils.isValidJson(dioError.response!.data.toString())) {
                dioError.response!.data = JsonUtils.formatErrorResponse(
                  context!.localizations.apiUnauthorized,
                );
              }
            } else {
              dioError.response!.data = JsonUtils.formatErrorResponse(
                context!.localizations.apiUnauthorized,
              );
            }
            apiErrorModel = APIResponse.fromJson(dioError.response?.data);
            errorDescription = extractDescriptionFromResponse(error.response);
          } else if (dioError.response?.statusCode == 403) {
            if (dioError.response != null && dioError.response!.data != null) {
              if (JsonUtils.isValidJson(dioError.response!.data.toString())) {
                dioError.response!.data = JsonUtils.formatErrorResponse(
                  context!.localizations.apiPermissionDenied,
                );
              }
            } else {
              dioError.response!.data = JsonUtils.formatErrorResponse(
                context!.localizations.apiPermissionDenied,
              );
            }
            apiErrorModel = APIResponse.fromJson(dioError.response?.data);
            errorDescription = extractDescriptionFromResponse(error.response);
          } else if (dioError.response?.statusCode == 404) {
            if (dioError.response != null && dioError.response!.data != null) {
              if (JsonUtils.isValidJson(dioError.response!.data.toString())) {
                dioError.response!.data = JsonUtils.formatErrorResponse(
                  context!.localizations.apiContentNotFound,
                );
              }
            } else {
              dioError.response!.data = JsonUtils.formatErrorResponse(
                context!.localizations.apiContentNotFound,
              );
            }
            apiErrorModel = APIResponse.fromJson(dioError.response?.data);
            errorDescription = extractDescriptionFromResponse(error.response);
          } else if (dioError.response?.statusCode == 422) {
            if (dioError.response != null && dioError.response!.data != null) {
              if (JsonUtils.isValidJson(dioError.response!.data.toString())) {
                dioError.response!.data = JsonUtils.formatErrorResponse(
                  context!.localizations.apiUnprocessableEntity,
                );
              }
            } else {
              dioError.response!.data = JsonUtils.formatErrorResponse(
                context!.localizations.apiUnprocessableEntity,
              );
            }
            apiErrorModel = APIResponse.fromJson(dioError.response?.data);
            errorDescription = extractDescriptionFromResponse(error.response);
          } else if (dioError.response?.statusCode == 500) {
            if (dioError.response != null && dioError.response!.data != null) {
              if (JsonUtils.isValidJson(dioError.response!.data.toString())) {
                dioError.response!.data = JsonUtils.formatErrorResponse(
                  context!.localizations.apiServerDowntime,
                );
              }
            } else {
              dioError.response!.data = JsonUtils.formatErrorResponse(
                context!.localizations.apiServerDowntime,
              );
            }
            apiErrorModel = APIResponse.fromJson(dioError.response?.data);
            errorDescription = extractDescriptionFromResponse(error.response);
          } else if (dioError.response?.statusCode == 502) {
            errorDescription = context!.localizations.apiInternalServerError;
          } else {
            errorDescription = context!.localizations.apiInternalServerError;
          }
          break;
        case DioExceptionType.sendTimeout:
          errorDescription = context!.localizations.apiGenericError;
          break;
      }
    } else {
      errorDescription = context!.localizations.apiCaughtError;
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
