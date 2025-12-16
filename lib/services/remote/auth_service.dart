import 'dart:convert';
import 'package:dayfi/flavors.dart';
import 'package:dayfi/models/api_response.dart';
import 'package:dayfi/models/auth_response.dart';
import 'package:dayfi/services/local/secure_storage.dart';
import 'package:dayfi/services/notification_service.dart';
import 'package:dayfi/services/remote/network/network_service.dart';
import 'package:dayfi/services/remote/network/url_config.dart';
import 'package:dayfi/common/constants/storage_keys.dart';

class AuthService {
  NetworkService _networkService;
  AuthService({required NetworkService networkService})
    : _networkService = networkService;

  void updateNetworkService() =>
      _networkService = NetworkService(baseUrl: F.baseUrl);

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
        F.baseUrl + UrlConfig.checkEmail,
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
        // Save user details to secure storage
        final secureStorage = SecureStorageService();
        await secureStorage.write(
          StorageKeys.user,
          json.encode(authResponse.data.user?.toJson()),
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
        // Save updated user
        final secureStorage = SecureStorageService();
        await secureStorage.write(
          StorageKeys.user,
          json.encode(authResponse.data.user?.toJson()),
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
        // Save user details to secure storage
        final secureStorage = SecureStorageService();
        await secureStorage.write(
          StorageKeys.user,
          json.encode(authResponse.data.user?.toJson()),
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

      // Update user data if successful
      if (!apiResponse.error && apiResponse.data != null) {
        final secureStorage = SecureStorageService();
        final userJson = await secureStorage.read(StorageKeys.user);
        if (userJson.isNotEmpty) {
          final userMap = json.decode(userJson) as Map<String, dynamic>;
          userMap['dayfi_id'] = dayfiId.replaceAll('@', '');
          await secureStorage.write(StorageKeys.user, json.encode(userMap));
        }
      }

      return apiResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<APIResponse> validateDayfiId({required String dayfiId}) async {
    try {
      // Map<String, dynamic> map = {};
      // map['dayfiId'] = dayfiId.replaceAll('@', ''); // Remove @ if present

      final response = await _networkService.call(
        '${F.baseUrl}${UrlConfig.validateDayfiId}/${dayfiId.replaceAll('@', '')}',
        RequestMethod.get,
        // data: map,
      );

      return APIResponse.fromJson(response.data);
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
        // Save user details to secure storage
        final secureStorage = SecureStorageService();
        await secureStorage.write(
          StorageKeys.user,
          json.encode(authResponse.data.user?.toJson()),
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
        // Save user details to secure storage
        final secureStorage = SecureStorageService();
        await secureStorage.write(
          StorageKeys.user,
          json.encode(authResponse.data.user?.toJson()),
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
}
