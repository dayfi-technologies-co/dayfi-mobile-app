import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/services/remote/auth_service.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/common/constants/analytics_events.dart';
import 'package:dayfi/common/utils/connectivity_utils.dart';

class ResetPasswordState {
  final String password;
  final String confirmPassword;
  final String passwordError;
  final String confirmPasswordError;
  final bool isBusy;
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;

  const ResetPasswordState({
    this.password = '',
    this.confirmPassword = '',
    this.passwordError = '',
    this.confirmPasswordError = '',
    this.isBusy = false,
    this.isPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
  });

  ResetPasswordState copyWith({
    String? password,
    String? confirmPassword,
    String? passwordError,
    String? confirmPasswordError,
    bool? isBusy,
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
  }) {
    return ResetPasswordState(
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      passwordError: passwordError ?? this.passwordError,
      confirmPasswordError: confirmPasswordError ?? this.confirmPasswordError,
      isBusy: isBusy ?? this.isBusy,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isConfirmPasswordVisible: isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
    );
  }

  bool get isFormValid =>
      password.isNotEmpty &&
      confirmPassword.isNotEmpty &&
      passwordError.isEmpty &&
      confirmPasswordError.isEmpty;
}

class ResetPasswordViewModel extends StateNotifier<ResetPasswordState> {
  final AuthService _authService = locator<AuthService>();

  ResetPasswordViewModel() : super(const ResetPasswordState());

  void setConfirmPassword(String value) {
    state = state.copyWith(
      confirmPassword: value,
      confirmPasswordError: _validateConfirmPassword(value),
    );
  }

  void setPassword(String value) {
    state = state.copyWith(
      password: value,
      passwordError: _validatePassword(value),
    );
    
    // Re-validate confirm password when password changes
    if (state.confirmPassword.isNotEmpty) {
      state = state.copyWith(
        confirmPasswordError: _validateConfirmPassword(state.confirmPassword),
      );
    }
  }

  String _validateConfirmPassword(String value) {
    if (value.isEmpty) return 'Please type your password again';
    if (value != state.password) return 'Both passwords must be exactly the same';
    return '';
  }

  String _validatePassword(String value) {
    if (value.isEmpty) return 'Please create a password';
    if (value.length < 8) return 'Password must be at least 8 characters long';
    if (!RegExp(r'^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9]).{8,}$')
        .hasMatch(value)) {
      return 'Password must include: 1 uppercase letter, 1 number, and 1 special character (!@#\$&*)';
    }
    return '';
  }

  Future<void> resetPassword(String email, BuildContext context) async {
    if (!state.isFormValid) return;

    state = state.copyWith(isBusy: true);

    try {
      analyticsService.logEvent(
        name: AnalyticsEvents.apiCallStarted,
        parameters: { 'action': 'reset_password', 'email': email },
      );
      final response = await _authService.resetPassword(
        email: email,
        password: state.password,
      );

      if (!response.error) {
        analyticsService.logEvent(
          name: 'password_reset_completed',
          parameters: { 'email': email },
        );
        TopSnackbar.show(
          context,
          message: response.message,
        );

        await Future.delayed(const Duration(milliseconds: 500));

        // Navigate to login view
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoute.loginView,
          (route) => false,
        );
      } else {
        analyticsService.logEvent(
          name: 'password_reset_failed',
          parameters: { 'email': email, 'reason': response.message },
        );
        TopSnackbar.show(
          context,
          message: response.message,
          isError: true,
        );
      }
    } catch (e) {
      // Get user-friendly error message
      final errorMessage = await ConnectivityUtils.getErrorMessage(e);
      
      analyticsService.logEvent(
        name: 'password_reset_failed',
        parameters: { 'email': email, 'reason': errorMessage },
      );
      TopSnackbar.show(
        context,
        message: errorMessage,
        isError: true,
      );
    } finally {
      state = state.copyWith(isBusy: false);
    }
  }

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(isConfirmPasswordVisible: !state.isConfirmPasswordVisible);
  }

  void resetForm() {
    state = const ResetPasswordState();
  }
}

final resetPasswordProvider = StateNotifierProvider<ResetPasswordViewModel, ResetPasswordState>(
  (ref) => ResetPasswordViewModel(),
);
