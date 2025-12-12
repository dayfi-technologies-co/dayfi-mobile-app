import 'dart:convert';
import 'dart:developer';
import 'user_model.dart';

class AuthResponse {
  dynamic data;
  bool error;
  String message;
  int? statusCode;

  AuthResponse({this.data, this.error = false, this.message = "", this.statusCode});

  factory AuthResponse.fromJson(Map<String, dynamic> data) {
    // log("AuthResponse============> ${json.encode(data)}");
    
    // Handle status code - prioritize 'code' field, then 'status'
    int? statusCode;
    if (data['code'] != null) {
      statusCode = data['code'] is int ? data['code'] : int.tryParse(data['code'].toString());
    } else if (data['status'] != null) {
      statusCode = data['status'] is int ? data['status'] : int.tryParse(data['status'].toString());
    }
    
    // Handle error determination - check both status string and status code
    bool isError = true;
    if (data['status'] != null) {
      // If status is a string like "success" or "error"
      if (data['status'] is String) {
        isError = data['status'].toString().toLowerCase() != 'success';
      } else if (data['status'] is int) {
        isError = data['status'] != 200;
      }
    } else if (statusCode != null) {
      // Fallback to status code
      isError = statusCode != 200;
    }
    
    return AuthResponse(
        error: isError,
        message: data['message'] ?? "",
        statusCode: statusCode,
        data: data['data'] != null ? AuthData.fromJson(data['data']) : null);
  }
}

class AuthData {
  String? token;
  User? user;
  String? action;

  AuthData({this.token, this.user, this.action});

  factory AuthData.fromJson(Map<String, dynamic> data) {
    return AuthData(
      token: data['token'],
      user: data.containsKey('user_id') ? User.fromJson(data) : null,
      action: data['action'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user?.toJson(),
      'action': action,
    };
  }
}
