import 'dart:convert';
import 'package:dayfi/common/constants/username_copy.dart';
import 'package:get_it/get_it.dart';
import 'package:dayfi/flavors.dart';
import 'package:dayfi/models/api_response.dart';
import 'package:dayfi/models/auth_response.dart';
import 'package:dayfi/models/user_model.dart';
import 'package:dayfi/services/local/local_cache.dart';
import 'package:dayfi/services/local/secure_storage.dart';
import 'package:dayfi/services/notification_service.dart';
import 'package:dayfi/services/remote/network/api_error.dart';
import 'package:dayfi/services/remote/network/network_service.dart';
import 'package:dayfi/services/remote/network/url_config.dart';
import 'package:dayfi/common/constants/storage_keys.dart';

class AuthService {
  NetworkService _networkService;
  AuthService({required NetworkService networkService})
    : _networkService = networkService;

  void updateNetworkService() =>
      _networkService = NetworkService(baseUrl: F.baseUrl);

  Future<void> _saveAuthUserPreservingDayfiTag(User? user) async {
    if (user == null) return;
    final secureStorage = SecureStorageService();
    final previous = await secureStorage.read(StorageKeys.user);
    final merged = mergeStoredDayfiTagIntoUserMap(user.toJson(), previous);
    await secureStorage.write(StorageKeys.user, json.encode(merged));
  }

  Future<APIResponse> loginUser({
    required String username,
    required String password,
  }) async {
    try {
      Map<String, dynamic> map = {};
      map['email'] = username;
      map['password'] = password;

      // Get FCM token from NotificationService
      String? fcmToken;
      try {
        // Import NotificationService at the top if not already
        // import 'package:dayfi/services/notification_service.dart';
        final notificationService = NotificationService();
        await notificationService.init();
        fcmToken = notificationService.fcmToken;
      } catch (e) {
        fcmToken = null;
      }
      map['fcmToken'] = fcmToken ?? "";

      final response = await _networkService.call(
        F.baseUrl + UrlConfig.login,
        RequestMethod.post,
        data: map,
      );

      return APIResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> signup({
    required String firstName,
    required String lastName,
    required String middleName,
    required String email,
    required String password,
  }) async {
    try {
      Map<String, dynamic> map = {};
      map['firstName'] = firstName;
      map['lastName'] = lastName;
      if (middleName.isNotEmpty && middleName != "") {
        map['middleName'] = middleName;
      }
      map['email'] = email;
      map['password'] = password;

      final response = await _networkService.call(
        F.baseUrl + UrlConfig.signup,
        RequestMethod.post,
        data: map,
      );

      return AuthResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> googleAuth({required String authToken}) async {
    try {
      Map<String, dynamic> map = {};
      map['authToken'] = authToken;

      // Get FCM token from NotificationService
      String? fcmToken;
      try {
        final notificationService = NotificationService();
        await notificationService.init();
        fcmToken = notificationService.fcmToken;
      } catch (e) {
        fcmToken = null;
      }
      map['fcmToken'] = fcmToken ?? "";

      final response = await _networkService.call(
        F.baseUrl + UrlConfig.googleAuth,
        RequestMethod.post,
        data: map,
      );

      return AuthResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Same contract as [googleAuth], plus optional [nonce] (raw string) so the
  /// server can validate the `nonce` claim inside Apple's `identityToken` JWT.
  /// Optional [firstName] / [lastName] from Apple (only populated on first sign-in).
  Future<AuthResponse> appleAuth({
    required String authToken,
    String? nonce,
    String? firstName,
    String? lastName,
  }) async {
    try {
      Map<String, dynamic> map = {};
      map['authToken'] = authToken;
      if (nonce != null && nonce.isNotEmpty) {
        map['nonce'] = nonce;
      }
      if (firstName != null && firstName.trim().isNotEmpty) {
        map['firstName'] = firstName.trim();
      }
      if (lastName != null && lastName.trim().isNotEmpty) {
        map['lastName'] = lastName.trim();
      }

      String? fcmToken;
      try {
        final notificationService = NotificationService();
        await notificationService.init();
        fcmToken = notificationService.fcmToken;
      } catch (e) {
        fcmToken = null;
      }
      map['fcmToken'] = fcmToken ?? "";

      final response = await _networkService.call(
        F.baseUrl + UrlConfig.appleAuth,
        RequestMethod.post,
        data: map,
      );

      return AuthResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> validateEmail({required String email}) async {
    try {
      Map<String, dynamic> map = {};
      map['email'] = email;

      final response = await _networkService.call(
        F.baseUrl + UrlConfig.validateEmail,
        RequestMethod.post,
        data: map,
      );

      return AuthResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      Map<String, dynamic> map = {};
      map['email'] = email;
      map['password'] = password;

      final response = await _networkService.call(
        F.baseUrl + UrlConfig.login,
        RequestMethod.post,
        data: map,
      );

      final authResponse = AuthResponse.fromJson(response.data);

      if (!authResponse.error) {
        // Save user details to secure storage
        final secureStorage = SecureStorageService();

        // clear existing user before saving new user
        // await secureStorage.delete('user');
        // await secureStorage.delete('password');
        // await secureStorage.delete('user_token');

        // save new user - store user data directly, not nested
        final userJson = json.encode(authResponse.data.user?.toJson());
        await secureStorage.write(StorageKeys.user, userJson);
        await secureStorage.write(StorageKeys.password, password);
        await secureStorage.write(StorageKeys.token, authResponse.data.token!);
      }

      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> forgotPassword({required String email}) async {
    try {
      Map<String, dynamic> map = {};
      map['email'] = email;

      final response = await _networkService.call(
        F.baseUrl + UrlConfig.forgotPassword,
        RequestMethod.post,
        data: map,
      );

      return AuthResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> verifyOtp({
    required String userOtp,
    required String type,
    String email = "",
    String password = "",
  }) async {
    try {
      Map<String, dynamic> map = {};
      map['userOtp'] = userOtp;
      // For pin reset verification the backend expects no `type` field
      if (type != 'pin_reset') {
        map['type'] = type;
      }

      final response = await _networkService.call(
        F.baseUrl + UrlConfig.verifyOtp,
        RequestMethod.post,
        data: map,
      );

      final authResponse = AuthResponse.fromJson(response.data);

      if (!authResponse.error && type == "email") {
        await login(email: email, password: password);
      } else if (!authResponse.error) {
        // For non-email verification (like password reset), store user data if available
        final secureStorage = SecureStorageService();
        if (authResponse.data?.user != null) {
          final userJson = json.encode(authResponse.data!.user!.toJson());
          await secureStorage.write(StorageKeys.user, userJson);
        }
      }

      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> resendOTP({required String email}) async {
    try {
      Map<String, dynamic> map = {};
      map['email'] = email;

      final response = await _networkService.call(
        F.baseUrl + UrlConfig.resendOtp,
        RequestMethod.post,
        data: map,
      );

      return AuthResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> resetPassword({
    required String email,
    required String password,
  }) async {
    try {
      Map<String, dynamic> map = {};
      map['email'] = email;
      map['password'] = password;

      final response = await _networkService.call(
        F.baseUrl + UrlConfig.resetPassword,
        RequestMethod.patch,
        data: map,
      );

      return AuthResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> updateProfile({
    required String country,
    required String state,
    required String street,
    required String city,
    // required String postalCode,
    required String address,
    required String gender,
    required String dob,
    String? phoneNumber,
    required String userId,
    required String bvn,
  }) async {
    try {
      Map<String, dynamic> map = {};
      if (country.isNotEmpty) map['country'] = country;
      if (state.isNotEmpty) map['state'] = state;
      if (street.isNotEmpty) map['street'] = street;
      if (city.isNotEmpty) map['city'] = city;
      // if (postalCode.isNotEmpty) map['postalCode'] = postalCode;
      if (address.isNotEmpty) map['address'] = address;
      if (gender.isNotEmpty) map['gender'] = gender;
      if (dob.isNotEmpty) map['dateOfBirth'] = dob;
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        map['phoneNumber'] = phoneNumber;
      }
      if (bvn.isNotEmpty) map['bvn'] = bvn;

      final response = await _networkService.call(
        '${F.baseUrl}${UrlConfig.updateProfile}/$userId',
        RequestMethod.patch,
        data: map,
      );

      // Handle response data - check if it's a Map or String
      Map<String, dynamic> responseData;
      if (response.data is Map<String, dynamic>) {
        responseData = response.data;
      } else if (response.data is String) {
        // Try to parse JSON string
        responseData = json.decode(response.data);
      } else {
        throw Exception('Invalid response format');
      }

      final authResponse = AuthResponse.fromJson(responseData);

      if (!authResponse.error) {
        await _saveAuthUserPreservingDayfiTag(
          authResponse.data is AuthData
              ? (authResponse.data as AuthData).user
              : null,
        );
      }

      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> updateProfileBiometrics({
    required bool isBiometricsSetup,
  }) async {
    try {
      final map = {'isBiometricsSetup': isBiometricsSetup};

      final response = await _networkService.call(
        '${F.baseUrl}${UrlConfig.updateBiometrics}',
        RequestMethod.patch,
        data: map,
      );

      // Normalize response into Map
      Map<String, dynamic> responseData;
      if (response.data is Map<String, dynamic>) {
        responseData = response.data;
      } else if (response.data is String) {
        responseData = json.decode(response.data);
      } else {
        throw Exception('Invalid response format');
      }

      final authResponse = AuthResponse.fromJson(responseData);

      if (!authResponse.error) {
        await _saveAuthUserPreservingDayfiTag(
          authResponse.data is AuthData
              ? (authResponse.data as AuthData).user
              : null,
        );
      }

      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> updateBiometrics({
    required bool isBiometricsSetup,
  }) async {
    try {
      Map<String, dynamic> map = {};
      map['isBiometricsSetup'] = isBiometricsSetup;

      final response = await _networkService.call(
        '${F.baseUrl}${UrlConfig.updateBiometrics}',
        RequestMethod.patch,
        data: map,
      );

      return AuthResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> verifyBVN({required String bvn}) async {
    try {
      Map<String, dynamic> map = {};
      map['bvn'] = bvn;

      final response = await _networkService.call(
        F.baseUrl + UrlConfig.verifyBvn,
        RequestMethod.post,
        data: map,
      );

      return AuthResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> updateProfileWithNIN({
    required String userId,
    required String nin,
  }) async {
    try {
      Map<String, dynamic> map = {};
      map['idType'] = 'NIN_V2';
      map['idNumber'] = nin;

      final response = await _networkService.call(
        '${F.baseUrl}${UrlConfig.updateProfile}/$userId',
        RequestMethod.patch,
        data: map,
      );

      // Handle response data - check if it's a Map or String
      Map<String, dynamic> responseData;
      if (response.data is Map<String, dynamic>) {
        responseData = response.data;
      } else if (response.data is String) {
        // Try to parse JSON string
        responseData = json.decode(response.data);
      } else {
        throw Exception('Invalid response format');
      }

      final authResponse = AuthResponse.fromJson(responseData);

      if (!authResponse.error) {
        await _saveAuthUserPreservingDayfiTag(
          authResponse.data is AuthData
              ? (authResponse.data as AuthData).user
              : null,
        );
      }

      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<APIResponse> createDayfiId({required String dayfiId}) async {
    try {
      Map<String, dynamic> map = {};
      map['dayfiId'] = dayfiId.replaceAll('@', ''); // Remove @ if present

      final response = await _networkService.call(
        F.baseUrl + UrlConfig.addDayfiId,
        RequestMethod.post,
        data: map,
      );

      final apiResponse = APIResponse.fromJson(response.data);

      // Update user data on success (body `data` is often null; tag is still created).
      if (!apiResponse.error) {
        final secureStorage = SecureStorageService();
        final tag = dayfiId.replaceAll('@', '');
        final userJson = await secureStorage.read(StorageKeys.user);
        if (userJson.isNotEmpty) {
          final userMap = json.decode(userJson) as Map<String, dynamic>;
          userMap['dayfi_id'] = tag;
          await secureStorage.write(StorageKeys.user, json.encode(userMap));
        }
        try {
          await GetIt.instance<LocalCache>().saveToLocalCache(
            key: 'dayfi_id',
            value: tag,
          );
        } catch (_) {}
      }

      return apiResponse;
    } on ApiError catch (e) {
      final rawMsg = e.apiErrorModel?.message;
      final fromModel = (rawMsg ?? '').trim();
      final desc = (e.errorDescription ?? '').trim();
      final msg = fromModel.isNotEmpty
          ? fromModel
          : (desc.isNotEmpty
              ? desc
              : UsernameCopy.saveError);
      return APIResponse(error: true, message: msg);
    }
  }

  Future<APIResponse> validateDayfiId({required String dayfiId}) async {
    try {
      final response = await _networkService.call(
        '${F.baseUrl}${UrlConfig.validateDayfiId}/${dayfiId.replaceAll('@', '')}',
        RequestMethod.get,
      );

      final raw = response.data;
      if (raw is! Map<String, dynamic>) {
        if (raw is Map) {
          return APIResponse.fromJson(Map<String, dynamic>.from(raw));
        }
        throw const FormatException('validateDayfiId: expected JSON object');
      }
      return APIResponse.fromJson(raw);
    } catch (e) {
      rethrow;
    }
  }

  /// Update transaction pin
  /// PATCH /api/v1/auth/update-transaction-pin
  Future<AuthResponse> updateTransactionPin({
    required String transactionPin,
  }) async {
    try {
      Map<String, dynamic> map = {};
      map['transactionPin'] = transactionPin;

      final response = await _networkService.call(
        '${F.baseUrl}/auth/update-transaction-pin',
        RequestMethod.patch,
        data: map,
      );

      // Handle response data - check if it's a Map or String
      Map<String, dynamic> responseData;
      if (response.data is Map<String, dynamic>) {
        responseData = response.data;
      } else if (response.data is String) {
        responseData = json.decode(response.data);
      } else {
        throw Exception('Invalid response format');
      }

      final authResponse = AuthResponse.fromJson(responseData);

      if (!authResponse.error) {
        await _saveAuthUserPreservingDayfiTag(
          authResponse.data is AuthData
              ? (authResponse.data as AuthData).user
              : null,
        );
      }

      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  /// Change transaction pin
  /// PATCH /api/v1/auth/change-transaction-pin
  Future<AuthResponse> changeTransactionPin({
    required String transactionPin,
    required String oldTransactionPin,
  }) async {
    try {
      Map<String, dynamic> map = {};
      map['transactionPin'] = transactionPin;
      map['oldTransactionPin'] = oldTransactionPin;

      final response = await _networkService.call(
        F.baseUrl + UrlConfig.changeTransactionPin,
        RequestMethod.patch,
        data: map,
      );

      // Handle response data - check if it's a Map or String
      Map<String, dynamic> responseData;
      if (response.data is Map<String, dynamic>) {
        responseData = response.data;
      } else if (response.data is String) {
        responseData = json.decode(response.data);
      } else {
        throw Exception('Invalid response format');
      }

      final authResponse = AuthResponse.fromJson(responseData);

      if (!authResponse.error) {
        await _saveAuthUserPreservingDayfiTag(
          authResponse.data is AuthData
              ? (authResponse.data as AuthData).user
              : null,
        );
      }

      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> resetTransactionPin({
    required String transactionPin,
  }) async {
    try {
      Map<String, dynamic> map = {};
      map['transactionPin'] = transactionPin;

      final response = await _networkService.call(
        F.baseUrl + UrlConfig.resetTransactionPin,
        RequestMethod.patch,
        data: map,
      );

      // Return the response data as a map
      if (response.data is Map<String, dynamic>) {
        return response.data;
      } else {
        return {
          'error': false,
          'success': true,
          'message': 'Transaction PIN reset successfully',
        };
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> deleteAccount() async {
    try {
      final response = await _networkService.call(
        F.baseUrl + UrlConfig.deleteAccount,
        RequestMethod.delete,
      );

      return AuthResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}

/// API payloads often omit [dayfi_id] (it lives on the wallet server-side). When
/// [user_id] matches stored user, copy the tag so Account does not ask to create it again.
Map<String, dynamic> mergeStoredDayfiTagIntoUserMap(
  Map<String, dynamic> incoming,
  String? existingUserJson,
) {
  final merged = Map<String, dynamic>.from(incoming);
  if (existingUserJson == null || existingUserJson.isEmpty) return merged;
  try {
    final old = json.decode(existingUserJson) as Map<String, dynamic>;
    final oldUserId = '${old['user_id'] ?? old['userId'] ?? ''}';
    final newUserId = '${merged['user_id'] ?? merged['userId'] ?? ''}';
    final sameUser = oldUserId.isNotEmpty &&
        newUserId.isNotEmpty &&
        oldUserId == newUserId;
    if (!sameUser) return merged;
    final oldTag = old['dayfi_id'] ?? old['dayfiId'];
    final newTag = merged['dayfi_id'] ?? merged['dayfiId'];
    final oldNonEmpty = oldTag != null && oldTag.toString().trim().isNotEmpty;
    final newEmpty = newTag == null || newTag.toString().trim().isEmpty;
    if (oldNonEmpty && newEmpty) {
      merged['dayfi_id'] = oldTag.toString().replaceAll('@', '');
    }
  } catch (_) {}
  return merged;
}
