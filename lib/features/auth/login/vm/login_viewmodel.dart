import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/services/remote/auth_service.dart';
import 'package:dayfi/services/local/secure_storage.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/common/constants/storage_keys.dart';
import 'package:dayfi/common/constants/analytics_events.dart';
import 'package:dayfi/common/utils/connectivity_utils.dart';

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
  /// Save user token, user data, and credentials after Google auth
  Future<void> saveGoogleAuthData({
    required String token,
    required Map<String, dynamic> userJson,
    required String email,
    required String password,
  }) async {
    await _secureStorage.write(StorageKeys.token, token);
    await _secureStorage.write(StorageKeys.isFirstTime, 'false');
    await _secureStorage.write(StorageKeys.user, json.encode(userJson));
    await _secureStorage.write(StorageKeys.email, email);
    await _secureStorage.write(StorageKeys.password, password);
    // Optionally, you can call _disableBiometricsOnLogin if needed
    // await _disableBiometricsOnLogin(userJson['user_id'] ?? userJson['id']);
  }

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
      return 'Please enter a valid email address';
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
      // Analytics: login started
      analyticsService.logEvent(
        name: AnalyticsEvents.loginStarted,
        parameters: {'email': state.email},
      );
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
        // Analytics: login completed
        analyticsService.logEvent(
          name: AnalyticsEvents.loginCompleted,
          parameters: {'email': state.email},
        );

        // Save user token and data
        await _secureStorage.write(
          StorageKeys.token,
          response.data?.token ?? '',
        );
        await _secureStorage.write(StorageKeys.isFirstTime, 'false');

        // Save user data if available
        if (response.data?.user != null) {
          await _secureStorage.write(
            StorageKeys.user,
            json.encode(response.data!.user!.toJson()),
          );
        }

        // Save login credentials for passcode verification flow
        await _secureStorage.write(StorageKeys.email, state.email);
        await _secureStorage.write(StorageKeys.password, state.password);

        // Disable biometrics on backend for fresh login flow
        // User will re-enable during biometric setup if they choose
        // Use `userId` from the User model (API returns `user_id`) instead of `id`
        await _disableBiometricsOnLogin(response.data?.user?.userId);

        // Show success message
        // _showSnackBar(context, response.message, isError: false);

        // Navigate to create passcode screen (for login flow)
        appRouter.pushNamed(AppRoute.createPasscodeView, arguments: false);
      } else {
        AppLogger.error('Login failed: ${response.message}');
        // Analytics: login failed
        analyticsService.logEvent(
          name: AnalyticsEvents.loginFailed,
          parameters: {'email': state.email, 'reason': response.message},
        );

        // Check if it's a 401 error with activation message
        if (response.message.toLowerCase().contains('activate your account')) {
          AppLogger.info(
            'Account needs activation, navigating to verify email screen',
          );

          // Navigate to verify email screen and automatically resend OTP
          _navigateToVerifyEmailAndResendOTP(context, state.email);
        } else {
          // Show backend error message for other errors
          TopSnackbar.show(context, message: response.message, isError: true);

          // Set field-specific errors based on the message
          _setFieldErrorsFromMessage(response.message);
        }
      }
    } catch (e) {
      if (e.toString().toLowerCase().contains('activate your account')) {
        AppLogger.info(
          'Account needs activation, navigating to verify email screen',
        );

        // Navigate to verify email screen and automatically resend OTP
        _navigateToVerifyEmailAndResendOTP(context, state.email);
      } else {
        AppLogger.error('Login error: $e');

        // Get user-friendly error message
        final errorMessage = await ConnectivityUtils.getErrorMessage(e);

        analyticsService.logEvent(
          name: AnalyticsEvents.loginFailed,
          parameters: {'email': state.email, 'reason': errorMessage},
        );
        TopSnackbar.show(context, message: errorMessage, isError: true);
      }
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

  /// Disable biometrics on backend immediately after login
  /// This ensures every fresh login starts with biometrics disabled
  /// User will re-enable during biometric setup flow if they choose
  Future<void> _disableBiometricsOnLogin(String? userId) async {
    try {
      // if (userId == null || userId.isEmpty) {
      //   AppLogger.warning('No user ID available, skipping biometric disable on login');
      //   return;
      // }

      AppLogger.info('Disabling biometrics on backend after fresh login...');

      // Call backend API to disable biometrics
      await _authService.updateProfileBiometrics(isBiometricsSetup: false);

      // Also clear local biometric flag to ensure consistency
      await _secureStorage.delete('biometric_enabled');
      await _secureStorage.delete(StorageKeys.biometricSetupCompleted);

      AppLogger.info(
        'Biometrics disabled on backend after login - user can re-enable during setup',
      );
    } catch (e) {
      // Don't fail login if biometric disable fails - just log it
      AppLogger.warning('Failed to disable biometrics on login: $e');
    }
  }

  // Navigate to verify email screen and automatically resend OTP
  void _navigateToVerifyEmailAndResendOTP(BuildContext context, String email) {
    // Navigate to verify email screen
    appRouter.pushNamed(
      AppRoute.verifyEmailView,
      arguments: VerifyEmailViewArguments(
        isSignUp: true, // This is for login flow, not signup
        email: email,
        password: state.password, // Pass the password for potential use
      ),
    );

    // Show a message that OTP will be resent automatically
    TopSnackbar.show(
      context,
      message:
          'Please check your email for verification code. A new code will be sent automatically.',
      isError: false,
    );

    // Automatically resend OTP after a short delay to ensure the screen is loaded
    _authService
        .resendOTP(email: email)
        .then((response) {
          if (response.statusCode == 200) {
            AppLogger.info('OTP resent successfully: ${response.message}');
          } else {
            AppLogger.error('Failed to resend OTP: ${response.message}');
          }
        })
        .catchError((e) {
          AppLogger.error('Error resending OTP: $e');
        });
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
