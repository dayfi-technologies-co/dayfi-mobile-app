// import 'package:dayfi/app/env.dart';
// import 'package:dio/dio.dart';
// // import 'package:dayfi/app/env.dart';
// import 'package:dayfi/core/errors/api_error.dart';
// import 'package:dayfi/data/storage/secure_storage_service.dart';
// import 'package:pretty_dio_logger/pretty_dio_logger.dart';
// import 'package:dayfi/core/constants/api_constants.dart';

// class BaseApiService {
//   final Dio _dio;
//   final SecureStorageService _secureStorage;
//   final Environment _env;

//   BaseApiService(this._secureStorage, this._env)
//       : _dio = Dio(
//           BaseOptions(
//             baseUrl: _env.apiBaseUrl,
//             connectTimeout: const Duration(seconds: 30),
//             receiveTimeout: const Duration(seconds: 30),
//             headers: {
//               'Content-Type': 'application/json',
//             },
//           ),
//         )..interceptors.addAll([
//             PrettyDioLogger(
//               requestHeader: true,
//               requestBody: true,
//               responseHeader: true,
//               responseBody: true,
//             ),
//             InterceptorsWrapper(
//               onRequest: (options, handler) async {
//                 final token = await _secureStorage.read(ApiConstants.tokenKey);
//                 if (token != null) {
//                   options.headers['Authorization'] = 'Bearer $token';
//                 }
//                 return handler.next(options);
//               },
//               onError: (DioException e, handler) {
//                 // AppLogger.error('API Error: ${e.message}', e);
//                 return handler.next(e);
//               },
//             ),
//           ]);

//   Future<Response> get(
//     String path, {
//     Map<String, dynamic>? queryParameters,
//     Options? options,
//   }) async {
//     try {
//       final response = await _dio.get(
//         path,
//         queryParameters: queryParameters,
//         options: options,
//       );
//       return response;
//     } on DioException catch (e) {
//       throw _handleError(e);
//     }
//   }

//   Future<Response> post(
//     String path, {
//     dynamic data,
//     Map<String, dynamic>? queryParameters,
//     Options? options,
//   }) async {
//     try {
//       final response = await _dio.post(
//         path,
//         data: data,
//         queryParameters: queryParameters,
//         options: options,
//       );
//       return response;
//     } on DioException catch (e) {
//       throw _handleError(e);
//     }
//   }

//   ApiError _handleError(DioException e) {
//     final statusCode = e.response?.statusCode;
//     final message = e.response?.data['message'] ?? e.message ?? 'Unknown error';
//     // AppLogger.error('API Request Failed: $message', e, e.stackTrace);
//     return ApiError(message, statusCode: statusCode);
//   }
// }
