import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/services/remote/auth_service.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/routes/route.dart';

class ForgotPasswordState {
  final String email;
  final String emailError;
  final bool isBusy;

  const ForgotPasswordState({
    this.email = '',
    this.emailError = '',
    this.isBusy = false,
  });

  ForgotPasswordState copyWith({
    String? email,
    String? emailError,
    bool? isBusy,
  }) {
    return ForgotPasswordState(
      email: email ?? this.email,
      emailError: emailError ?? this.emailError,
      isBusy: isBusy ?? this.isBusy,
    );
  }

  bool get isFormValid => email.isNotEmpty && emailError.isEmpty;
}

class ForgotPasswordViewModel extends StateNotifier<ForgotPasswordState> {
  final AuthService _authService = locator<AuthService>();

  ForgotPasswordViewModel() : super(const ForgotPasswordState());

   void setEmail(String value) {
    state = state.copyWith(email: value, emailError: _validateEmail(value));
  }

  String _validateEmail(String value) {
    if (value.isEmpty) return 'Please enter your email address';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address (like: yourname@email.com)';
    }
    return '';
  }

  Future<void> forgotPassword(BuildContext context) async {
    if (!state.isFormValid) return;

    state = state.copyWith(isBusy: true);

    try {
      final response = await _authService.forgotPassword(email: state.email);

      if (!response.error) {
        TopSnackbar.show(
          context,
          message: response.message,
        );

        await Future.delayed(const Duration(milliseconds: 500));
        
        // Navigate to verify email view for forgot password
        Navigator.pushNamed(
          context,
          AppRoute.verifyEmailView,
          arguments: VerifyEmailViewArguments(
            isSignUp: false,
            email: state.email,
          ),
        );
      } else {
        TopSnackbar.show(
          context,
          message: response.message,
          isError: true,
        );
      }
    } catch (e) {
      final errorText = e.toString();
      TopSnackbar.show(
        context,
        message: 'Forgot password error: $errorText',
        isError: true,
      );
    } finally {
      await Future.delayed(const Duration(milliseconds: 500));
      state = state.copyWith(isBusy: false);
    }
  }

  void resetForm() {
    state = const ForgotPasswordState();
  }
}

final forgotPasswordProvider = StateNotifierProvider<ForgotPasswordViewModel, ForgotPasswordState>(
  (ref) => ForgotPasswordViewModel(),
);
