import 'package:dayfi/data/models/user_model.dart';

class AuthResponse {
  final String status;
  final String message;
  final int code;
  final User data;

  AuthResponse({
    required this.status,
    required this.message,
    required this.code,
    required this.data,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      status: json['status'],
      message: json['message'],
      code: json['code'],
      data: User.fromJson(json['data']),
    );
  }
}
