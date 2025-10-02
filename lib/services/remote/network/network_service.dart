import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/services/remote/network/api_error.dart';
import 'package:dayfi/services/remote/network/app_interceptor.dart';
import 'package:dayfi/flavors.dart';


/// description: A network provider class which manages network connections
/// between the app and external services. This is a wrapper around [Dio].
///
/// Using this class automatically handle, token management, logging, global

void printWrapped(String text) {
  final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) => log(match.group(0) ?? ""));
}

/// A top level function to print dio logs
void printDioLogs(Object object) {
  printWrapped(object.toString());
}

class NetworkService {
  static const int connectTimeOut = 120000;
  static const int receiveTimeOut = 120000;
  Dio? dio;
  String? baseUrl, authToken;

  NetworkService({this.baseUrl, this.authToken}) {
    _initialiseDio();
  }

  /// Initialize essential class properties
  void _initialiseDio() {
    if (dio == null) {
      dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(milliseconds: connectTimeOut),
          receiveTimeout: const Duration(milliseconds: receiveTimeOut),
          baseUrl: baseUrl ?? F.baseUrl,
        ),
      );
      dio!.interceptors
        ..add(AppInterceptor(''))
        ..add(LogInterceptor(requestBody: true, logPrint: printDioLogs));
    }
  }

  addInterceptor() {}

  Future<Options> getOption({responseType, bool isJson = true}) async {
    String token = await localCache.getToken();
    return isJson
        ? Options(
          responseType: responseType,
          headers: {"Authorization": token.isNotEmpty ? "Bearer $token" : ''},
        )
        : Options(
          responseType: responseType,
          headers: {
            "Authorization": token.isNotEmpty ? "Bearer $token" : '',
            "Content-Disposition": "form-data",
            "Content-Type": "multipart/form-data",
          },
        );
  }

  /// Factory constructor used mainly for injecting an instance of [Dio] mock
  NetworkService.test(this.dio);

  Future<Response> call(
    String path,
    RequestMethod method, {
    Map<String, dynamic>? queryParams,
    data,
    FormData? formData,
    ResponseType responseType = ResponseType.json,
    classTag = '',
  }) async {
    _initialiseDio();
    
    if (dio == null) {
      throw Exception('Dio is not initialized');
    }
    
    Response response;
    var params = queryParams ?? {};
    if (params.keys.contains("searchTerm")) {
      params["searchTerm"] = Uri.encodeQueryComponent(params["searchTerm"]);
    }
    try {
      switch (method) {
        case RequestMethod.post:
          response = await dio!.post(
            path,
            queryParameters: params,
            data: data,
            options: await getOption(responseType: responseType),
          );
          break;
        case RequestMethod.get:
          response = await dio!.get(
            path,
            queryParameters: params,
            options: await getOption(),
          );
          break;
        case RequestMethod.patch:
          response = await dio!.patch(
            path,
            queryParameters: params,
            data: data,
            options: await getOption(),
          );
          break;
        case RequestMethod.put:
          response = await dio!.put(
            path,
            queryParameters: params,
            data: data,
            options: await getOption(),
          );
          break;
        case RequestMethod.delete:
          response = await dio!.delete(
            path,
            queryParameters: params,
            data: data,
            options: await getOption(),
          );
          break;
        case RequestMethod.upload:
          response = await dio!.post(
            path,
            data: formData,
            queryParameters: params,
            options: await getOption(isJson: false),
            onSendProgress: (sent, total) {
              // Progress and total data sent can be used where applicable
            },
          );
          break;
      }
      return response;
    } catch (error, stackTrace) {
      var apiError = ApiError.fromDio(error);
      if (apiError.errorType == 401) {
        // User is not authorized, redirect to login
      }
      return Future.error(apiError, stackTrace);
    }
  }
}

enum RequestMethod { post, get, put, delete, upload, patch }
