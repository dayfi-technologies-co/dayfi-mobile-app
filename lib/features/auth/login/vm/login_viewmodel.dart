import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/services/remote/auth_service.dart';
import 'package:dayfi/services/local/secure_storage.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/routes/route.dart';

class LoginState {
  final String email;
  final String password;
  final bool isBusy;
  final String emailError;
  final String passwordError;
  final bool isPasswordVisible;

  const LoginState({
    this.email = '',
    this.password = '',
    this.isBusy = false,
    this.emailError = '',
    this.passwordError = '',
    this.isPasswordVisible = true,
  });

  bool get isFormValid =>
      email.isNotEmpty &&
      password.isNotEmpty &&
      emailError.isEmpty &&
      passwordError.isEmpty;

  LoginState copyWith({
    String? email,
    String? password,
    bool? isBusy,
    String? emailError,
    String? passwordError,
    bool? isPasswordVisible,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      isBusy: isBusy ?? this.isBusy,
      emailError: emailError ?? this.emailError,
      passwordError: passwordError ?? this.passwordError,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
    );
  }
}

class LoginNotifier extends StateNotifier<LoginState> {
  final AuthService _authService = authService;
  final SecureStorageService _secureStorage = locator<SecureStorageService>();

  LoginNotifier() : super(const LoginState());

  void setEmail(String value) {
    state = state.copyWith(email: value, emailError: _validateEmail(value));
  }

  void setPassword(String value) {
    state = state.copyWith(
      password: value,
      passwordError: _validatePassword(value),
    );
  }

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  String _validateEmail(String value) {
    if (value.isEmpty) return 'Please enter your email address';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address (like: yourname@email.com)';
    }
    return '';
  }

  String _validatePassword(String value) {
    if (value.isEmpty) return 'Please enter your password';
    if (value.length < 8) return 'Password must be at least 8 characters long';
    return '';
  }

  // Login method
  Future<void> login(BuildContext context) async {
    if (!state.isFormValid) return;

    state = state.copyWith(isBusy: true);

    try {
      AppLogger.info('Starting login process for email: ${state.email}');

      final response = await _authService.login(
        email: state.email,
        password: state.password,
      );

      AppLogger.info(
        'Login response - Status: ${response.statusCode}, Error: ${response.error}, Message: ${response.message}',
      );

      if (response.statusCode == 200) {
        AppLogger.info('Login successful: ${response.message}');

        // Save user token and data
        await _secureStorage.write('user_token', response.data?.token ?? '');
        await _secureStorage.write('first_time_user', 'false');
        
        // Save user data if available
        if (response.data?.user != null) {
          await _secureStorage.write('user', json.encode(response.data!.user!.toJson()));
        }

        // Show success message
        // _showSnackBar(context, response.message, isError: false);

        // Navigate to create passcode screen (for login flow)
        appRouter.pushNamed(AppRoute.createPasscodeView, arguments: false);
      } else {
        AppLogger.error('Login failed: ${response.message}');

        // Show backend error message
        TopSnackbar.show(context, message: response.message, isError: true);

        // Set field-specific errors based on the message
        _setFieldErrorsFromMessage(response.message);
      }
    } catch (e) {
      AppLogger.error('Login error: $e');
      TopSnackbar.show(context, message: e.toString(), isError: true);
    } finally {
      state = state.copyWith(isBusy: false);
    }
  }

  // Set field-specific errors based on backend message
  void _setFieldErrorsFromMessage(String message) {
    String? emailError;
    String? passwordError;

    // Check for specific field errors in the message
    if (message.toLowerCase().contains('email')) {
      emailError = message;
    } else if (message.toLowerCase().contains('password')) {
      passwordError = message;
    } else {
      // If no specific field is mentioned, show as general error
      emailError = message;
    }

    state = state.copyWith(
      emailError: emailError ?? '',
      passwordError: passwordError ?? '',
    );
  }


  void navigateToForgotPassword() {
    appRouter.pushNamed(AppRoute.forgotPasswordView);
  }

  void navigateToSignup() {
    appRouter.pushNamed(AppRoute.signupView);
  }

  // Clear form
  void resetForm() {
    state = const LoginState();
  }
}

// Provider
final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  return LoginNotifier();
});
