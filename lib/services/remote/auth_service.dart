import 'dart:convert';
import 'dart:developer';
import 'package:dayfi/flavors.dart';
import 'package:dayfi/models/api_response.dart';
import 'package:dayfi/models/auth_response.dart';
import 'package:dayfi/services/local/secure_storage.dart';
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
        log('Storing user data: $userJson');
        await secureStorage.write(
          StorageKeys.user,
          userJson,
        );
        await secureStorage.write('password', password);
        await secureStorage.write(StorageKeys.token, authResponse.data.token!);

        log(authResponse.data.toJson().toString());
      }

      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> forgotPassword({
    required String email,
  }) async {
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
      map['type'] = type;

      final response = await _networkService.call(
        F.baseUrl + UrlConfig.verifyOtp,
        RequestMethod.post,
        data: map,
      );

      final authResponse = AuthResponse.fromJson(response.data);
      
      if (!authResponse.error && type == "email") {
        log('verifyOtp: Calling login for email verification');
        await login(email: email, password: password);
        log('verifyOtp: Login completed');
      } else if (!authResponse.error) {
        // For non-email verification (like password reset), store user data if available
        log('verifyOtp: Storing user data for non-email verification');
        final secureStorage = SecureStorageService();
        if (authResponse.data?.user != null) {
          final userJson = json.encode(authResponse.data!.user!.toJson());
          log('verifyOtp: Storing user data: $userJson');
          await secureStorage.write(
            StorageKeys.user,
            userJson,
          );
        } else {
          log('verifyOtp: No user data available in authResponse.data');
        }
      }

      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> resendOTP({
    required String email,
  }) async {
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
    required String postalCode,
    required String address,
    required String gender,
    required String dob,
    required String phoneNumber,
    required String userId,
    required String bvn,
  }) async {
    try {
      log('Starting updateProfile API call for user: $userId');
      
      Map<String, dynamic> map = {};
      map['country'] = country;
      map['state'] = state;
      map['street'] = street;
      map['city'] = city;
      map['postalCode'] = postalCode;
      map['address'] = address;
      map['gender'] = gender;
      map['dateOfBirth'] = dob;
      map['phoneNumber'] = phoneNumber;
      map['bvn'] = bvn;

      log('UpdateProfile request data: $map');
      log('UpdateProfile URL: ${F.baseUrl}${UrlConfig.updateProfile}/$userId');

      final response = await _networkService.call(
        '${F.baseUrl}${UrlConfig.updateProfile}/$userId',
        RequestMethod.patch,
        data: map,
      );

      log('UpdateProfile raw response: ${response.data}');

      // Handle response data - check if it's a Map or String
      Map<String, dynamic> responseData;
      if (response.data is Map<String, dynamic>) {
        responseData = response.data;
        log('Response data is Map: $responseData');
      } else if (response.data is String) {
        // Try to parse JSON string
        responseData = json.decode(response.data);
        log('Response data parsed from String: $responseData');
      } else {
        log('Invalid response format: ${response.data.runtimeType}');
        throw Exception('Invalid response format');
      }

      final authResponse = AuthResponse.fromJson(responseData);
      
      log('UpdateProfile response - Status: ${authResponse.statusCode}, Error: ${authResponse.error}, Message: ${authResponse.message}');
      
      if (!authResponse.error) {
        log('UpdateProfile successful, saving user data to storage');
        // Save user details to secure storage
        final secureStorage = SecureStorageService();
        await secureStorage.write(
          StorageKeys.user,
          json.encode(authResponse.data.user?.toJson()),
        );
        log('User data saved to storage successfully');
      } else {
        log('UpdateProfile failed: ${authResponse.message}');
      }

      return authResponse;
    } catch (e) {
      log('Error in updateProfile: $e');
      rethrow;
    }
  }
}
