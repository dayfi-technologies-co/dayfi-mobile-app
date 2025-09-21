import 'dart:developer';

import 'package:dayfi/app/app.locator.dart';
import 'package:dayfi/data/models/auth_response.dart';
import 'package:dayfi/data/models/wallet_reponse.dart';
import 'package:dayfi/data/storage/secure_storage_service.dart';

// models/user.dart
import 'dart:convert';

// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

import '../../data/models/transaction_history_model.dart';
import 'package:bcrypt/bcrypt.dart';

class AuthApiService {
  static const String _baseUrl =
  'https://dayfi-staging-4417d7a6dfe0.herokuapp.com/api/v1';

  Future<AuthResponse> signup({
    required String firstName,
    required String lastName,
    required String middleName,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/auth/signup"),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(middleName.isEmpty || middleName == ""
          ? {
              'firstName': firstName,
              'lastName': lastName,
              'email': email,
              'password': password,
            }
          : {
              'firstName': firstName,
              'lastName': lastName,
              'middleName': middleName,
              'email': email,
              'password': password,
            }),
    );

    if (response.statusCode == 200) {
      return AuthResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/auth/login"),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final authResponse = AuthResponse.fromJson(json.decode(response.body));
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
      return authResponse;
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  Future<AuthResponse> forgotPassowrd({
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/auth/forgot-password"),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      return AuthResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed: ${response.body}');
    }
  }

  Future<AuthResponse> verifyOtp({
    required String userOtp,
    required String type,
    String email = "",
    String password = "",
  }) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/auth/verify-otp"),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userOtp': userOtp,
        'type': type,
      }),
    );

    if (response.statusCode == 200) {
      final authResponse = AuthResponse.fromJson(json.decode(response.body));
      type == "email" ? await login(email: email, password: password) : null;

      final secureStorage = SecureStorageService();
      await secureStorage.write(
        'user',
        json.encode(authResponse.data.toJson()),
      );
      return authResponse;
    } else {
      throw Exception('Failed: ${response.body}');
    }
  }

  Future<AuthResponse> resendOTP({
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/auth/resend-otp"),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      return AuthResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed: ${response.body}');
    }
  }

  Future<AuthResponse> resetPassword({
    required String email,
    required String password,
  }) async {
    final response = await http.patch(
      Uri.parse("$_baseUrl/auth/reset-password"),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      return AuthResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed: ${response.body}');
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
    final secureStorage = locator<SecureStorageService>();
    final token = await secureStorage.read('user_token');

    final response = await http.patch(
      Uri.parse("$_baseUrl/auth/update-profile/$userId"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer $token"
      },
      body: json.encode({
        "country": country,
        "state": state,
        "street": street,
        "city": city,
        "postalCode": postalCode,
        "address": address,
        "gender": gender,
        "dateOfBirth": dob,
        "phoneNumber": phoneNumber,
        "bvn": bvn,
      }),
    );

    if (response.statusCode == 200) {
      AuthResponse authResponse =
          AuthResponse.fromJson(json.decode(response.body));

      // Save user details to secure storage
      final secureStorage = SecureStorageService();
      await secureStorage.write(
        'user',
        json.encode(authResponse.data.toJson()),
      );
      return authResponse;
    } else {
      throw Exception('Failed: ${response.body}');
    }
  }

  Future<AuthResponse> updateProfile2({
    required String idType,
    required String idNumber,
    required String userId,
    required String jwtToken,
  }) async {
    final secureStorage = locator<SecureStorageService>();
    final token = await secureStorage.read('user_token');

    final response = await http.patch(
      Uri.parse("$_baseUrl/auth/update-profile/$userId"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer $token"
      },
      body: json.encode({
        "idType": idType,
        "idNumber": idNumber,
      }),
    );

    if (response.statusCode == 200) {
      AuthResponse authResponse =
          AuthResponse.fromJson(json.decode(response.body));

      // Save user details to secure storage
      final secureStorage = SecureStorageService();
      await secureStorage.write(
        'user',
        json.encode(authResponse.data.toJson()),
      );
      return authResponse;
    } else {
      throw Exception('Failed: ${response.body}');
    }
  }

  Future<AuthResponse> createDayfiId({
    required String dayfiId,
  }) async {
    final secureStorage = locator<SecureStorageService>();
    final token = await secureStorage.read('user_token');

    final response = await http.post(
      Uri.parse("$_baseUrl/payments/add-dayfi-id"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer $token"
      },
      body: json.encode({
        "dayfiId": dayfiId,
      }),
    );

    if (response.statusCode == 200) {
      AuthResponse authResponse =
          AuthResponse.fromJson(json.decode(response.body));

      // Save user details to secure storage
      final secureStorage = SecureStorageService();
      await secureStorage.write(
        'user',
        json.encode(authResponse.data.toJson()),
      );
      return authResponse;
    } else {
      throw Exception('Failed: ${response.body}');
    }
  }

  Future<AuthResponse> logout({
    required String jwtToken,
  }) async {
    final secureStorage = locator<SecureStorageService>();
    final token = await secureStorage.read('user_token');

    final response = await http.post(
      Uri.parse("$_baseUrl/auth/logout"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer $token"
      },
      body: json.encode({
        "token": token,
      }),
    );

    if (response.statusCode == 200) {
      AuthResponse authResponse =
          AuthResponse.fromJson(json.decode(response.body));

      // Don't save user data during logout - this is handled by the viewmodel
      return authResponse;
    } else {
      throw Exception('Failed: ${response.body}');
    }
  }

  Future<List<dynamic>> fetchBanks({
    required String jwtToken,
  }) async {
    final secureStorage = locator<SecureStorageService>();
    final token = await secureStorage.read('user_token');

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/payments/banks'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': "Bearer $token"
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          return jsonResponse['data'] as List<dynamic>;
        } else {
          throw Exception('Failed to fetch banks: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to fetch banks: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching banks: $e');
    }
  }

  Future<Map<String, dynamic>> resolveAccountNumber({
    required String accountNumber,
    required String bankCode,
    required String jwtToken,
  }) async {
    final secureStorage = locator<SecureStorageService>();
    final token = await secureStorage.read('user_token');

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payments/resolve-account'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': "Bearer $token"
        },
        body: json.encode({
          'accountNumber': "0690000032", // accountNumber,
          'bankCode': "044", // bankCode
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          return jsonResponse['data'] as Map<String, dynamic>;
        } else {
          throw Exception(
              'Failed to resolve account: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to resolve account: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error resolving account: $e');
    }
  }

  Future<AuthResponse> changePassword({
    required String password,
    required String oldPassword,
  }) async {
    final secureStorage = locator<SecureStorageService>();
    final token = await secureStorage.read('user_token');

    final response = await http.patch(
      Uri.parse("$_baseUrl/auth/change-password"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer $token"
      },
      body: json.encode({
        "password": password,
        "oldPassword": oldPassword,
      }),
    );

    if (response.statusCode == 200) {
      AuthResponse authResponse =
          AuthResponse.fromJson(json.decode(response.body));

      // Save user details to secure storage
      final secureStorage = SecureStorageService();
      await secureStorage.write(
        'user',
        json.encode(authResponse.data.toJson()),
      );
      return authResponse;
    } else {
      throw Exception('Failed: ${response.body}');
    }
  }

  Future<AuthResponse> changeTransactionPIN({
    required String transactionPin,
    required String oldTransactionPin,
  }) async {
    final secureStorage = locator<SecureStorageService>();
    final token = await secureStorage.read('user_token');

    final response = await http.patch(
      Uri.parse("$_baseUrl/auth/change-transaction-pin"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer $token"
      },
      body: json.encode({
        "transactionPin": transactionPin,
        "oldTransactionPin": oldTransactionPin,
      }),
    );

    if (response.statusCode == 200) {
      AuthResponse authResponse =
          AuthResponse.fromJson(json.decode(response.body));

      // Save user details to secure storage
      final secureStorage = SecureStorageService();
      await secureStorage.write(
        'user',
        json.encode(authResponse.data.toJson()),
      );
      return authResponse;
    } else {
      throw Exception('Failed: ${response.body}');
    }
  }

  // create transaction PIN
  Future<AuthResponse> setTransactionPin({
    required String transactionPin,
  }) async {
    final secureStorage = locator<SecureStorageService>();
    final token = await secureStorage.read('user_token');

    final response = await http.patch(
      Uri.parse("$_baseUrl/auth/update-transaction-pin"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer $token"
      },
      body: json.encode({
        "transactionPin": transactionPin,
      }),
    );

    if (response.statusCode == 200) {
      AuthResponse authResponse =
          AuthResponse.fromJson(json.decode(response.body));

      // Save user details to secure storage
      final secureStorage = SecureStorageService();
      await secureStorage.write(
        'user',
        json.encode(authResponse.data.toJson()),
      );
      return authResponse;
    } else {
      throw Exception('Failed: ${response.body}');
    }
  }

  Future<AuthResponse> verifyResetTransactionPinOTP({
    required String userOtp,
  }) async {
    final secureStorage = locator<SecureStorageService>();
    final token = await secureStorage.read('user_token');

    final response = await http.post(
      Uri.parse("$_baseUrl/auth/verify-otp"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer $token"
      },
      body: json.encode({
        "userOtp": userOtp,
      }),
    );

    if (response.statusCode == 200) {
      AuthResponse authResponse =
          AuthResponse.fromJson(json.decode(response.body));

      // Save user details to secure storage
      final secureStorage = SecureStorageService();
      await secureStorage.write(
        'user',
        json.encode(authResponse.data.toJson()),
      );
      return authResponse;
    } else {
      throw Exception('Failed: ${response.body}');
    }
  }

  Future<AuthResponse> updateTransactionPin({
    required String transactionPin,
  }) async {
    final secureStorage = locator<SecureStorageService>();
    final token = await secureStorage.read('user_token');

    final response = await http.patch(
      Uri.parse("$_baseUrl/auth/update-transaction-pin"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer $token"
      },
      body: json.encode({
        "transactionPin": transactionPin,
      }),
    );

    if (response.statusCode == 200) {
      AuthResponse authResponse =
          AuthResponse.fromJson(json.decode(response.body));

      // Save user details to secure storage
      final secureStorage = SecureStorageService();
      await secureStorage.write(
        'user',
        json.encode(authResponse.data.toJson()),
      );
      return authResponse;
    } else {
      throw Exception('Failed: ${response.body}');
    }
  }

  Future<WalletResponse2> validateDayfiId({
    required String dayfiId,
  }) async {
    log(dayfiId);
    final secureStorage = locator<SecureStorageService>();
    final token = await secureStorage.read('user_token');

    final response = await http.get(
      Uri.parse(
          "$_baseUrl/payments/validate-dayfi-id/${dayfiId.replaceAll("@", "")}"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer $token"
      },
    );

    log(response.statusCode.toString());

    if (response.statusCode == 200) {
      WalletResponse2 wallet =
          WalletResponse2.fromJson(json.decode(response.body));
      return wallet;
    } else {
      throw Exception('Failed: ${response.body}');
    }
  }

  Future<WalletResponse> getWalletDetails() async {
    final secureStorage = locator<SecureStorageService>();
    final token = await secureStorage.read('user_token');

    final response = await http.get(
      Uri.parse("$_baseUrl/payments/wallet-details"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer $token"
      },
    );

    if (response.statusCode == 200) {
      WalletResponse walletResponse =
          WalletResponse.fromJson(json.decode(response.body));

      // Save user details to secure storage
      final secureStorage = SecureStorageService();
      await secureStorage.write(
        'wallet_details',
        json.encode(

            // this looks beautiful
            walletResponse.data.map((wallet) => wallet.toJson()).toList()),
      );

      return walletResponse;
    } else {
      throw Exception('Failed: ${response.body}');
    }
  }

  Future<List<WalletTransaction>> getWalletTransactions({
    int page = 1,
    int limit = 50,
  }) async {
    final secureStorage = locator<SecureStorageService>();
    final token = await secureStorage.read('user_token');

    if (token == null) {
      throw Exception('No token found. Please log in again.');
    }

    final url = Uri.parse(
        "$_baseUrl/payments/wallet-transactions?page=$page&limit=$limit");

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final historyResponse =
            WalletTransactionHistoryResponse.fromJson(decoded);
        return historyResponse.transactions;
      } else {
        throw Exception(
            'Failed to fetch transactions: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> initiateWalletTransfer({
    required String dayfiId,
    required int amount,
    required String txPin,
  }) async {
    final secureStorage = locator<SecureStorageService>();
    final token = await secureStorage.read('user_token');

    if (token == null) {
      throw Exception('User token not found. Please log in again.');
    }

    final uri = Uri.parse(
      "https://dayfi-app-31eb033892cf.herokuapp.com/api/v1/payments/initiate-wallet-transfer",
    );

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer $token",
      },
      body: json.encode({
        "dayfiId": dayfiId,
        "amount": amount,
        "pin": txPin,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to initiate wallet transfer: ${response.body}');
    }

    final Map<String, dynamic> responseBody = json.decode(response.body);
    return responseBody;
  }

  Future<Map<String, dynamic>> initiateBankTransfer({
    required int amount,
    required String txPin,
    required String accountNumber,
    required String bankCode,
    required String accountName,
    required String bankName,
    required String beneficiaryName,
    required dynamic model,
  }) async {
    final secureStorage = locator<SecureStorageService>();
    final token = await secureStorage.read('user_token');
    final response = await http.post(
      Uri.parse(
        "https://dayfi-app-31eb033892cf.herokuapp.com/api/v1/payments/bank-transfer",
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer $token",
      },
      // "amount": amount,
      // "accountNumber": accountNumber,
      // "bankCode": bankCode,
      // "bankName": bankName,
      // "accountName": accountName,

      body: json.encode({
        "amount": amount,
        "accountNumber": "0690000033",
        "bankCode": "044",
        "bankName": "ACCESS BANK NIGERIA",
        "accountName": "Bale Gary",
        "fee": 10,
        "pin": txPin,
      }),
    );

    log('Response Body: ${response.body}');

    final Map<String, dynamic> jsonResponse = json.decode(response.body);

    return jsonResponse;
  }

  Future<Map<String, dynamic>> createNewWallet({
    required String currency,
  }) async {
    final secureStorage = locator<SecureStorageService>();
    final token = await secureStorage.read('user_token');
    final response = await http.post(
      Uri.parse(
        "https://dayfi-app-31eb033892cf.herokuapp.com/api/v1/payments/wallets",
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer $token",
      },
      // "amount": amount,
      // "accountNumber": accountNumber,
      // "bankCode": bankCode,
      // "bankName": bankName,
      // "accountName": accountName,

      body: json.encode({"currency": currency}),
    );

    log('Response Body: ${response.body}');

    final Map<String, dynamic> jsonResponse = json.decode(response.body);

    return jsonResponse;
  }

  // ===============================================
  // ENCRYPTION
  // ===============================================

  Future<String> encryptPin(String pin) async {
    try {
      const pepper = "78G6F56DRUCYTVU"; // secret from backend
      final saltedText = pin + pepper;
      final salt = BCrypt.gensalt(logRounds: 10); // cost factor 10
      final hash = BCrypt.hashpw(saltedText, salt);
      return hash;
    } catch (e) {
      throw Exception(
          'An error occurred. Please try again or contact support.');
    }
  }
}
