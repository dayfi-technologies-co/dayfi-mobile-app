import 'dart:convert';
import 'dart:developer';
import 'package:dayfi/flavors.dart';
import 'package:dayfi/models/api_response.dart';
import 'package:dayfi/models/auth_response.dart';
import 'package:dayfi/services/local/secure_storage.dart';
import 'package:dayfi/services/remote/network/network_service.dart';
import 'package:dayfi/services/remote/network/url_config.dart';

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

        // save new user
        await secureStorage.write(
          'user',
          json.encode(authResponse.data.toJson()),
        );
        await secureStorage.write('password', password);
        await secureStorage.write('user_token', authResponse.data.token!);

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
        await login(email: email, password: password);
      }

      if (!authResponse.error) {
        final secureStorage = SecureStorageService();
        await secureStorage.write(
          'user',
          json.encode(authResponse.data.toJson()),
        );
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

  Future<AuthResponse> updateProfile1({
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

      final response = await _networkService.call(
        '${F.baseUrl}${UrlConfig.updateProfile}/$userId',
        RequestMethod.patch,
        data: map,
      );

      final authResponse = AuthResponse.fromJson(response.data);
      
      if (!authResponse.error) {
        // Save user details to secure storage
        final secureStorage = SecureStorageService();
        await secureStorage.write(
          'user',
          json.encode(authResponse.data.toJson()),
        );
      }

      return authResponse;
    } catch (e) {
      rethrow;
    }
  }
}
