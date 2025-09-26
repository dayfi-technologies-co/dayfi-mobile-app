import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/services/remote/auth_service.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/routes/route.dart';

class VerifyEmailState {
  final String otpCode;
  final bool isVerifying;
  final bool isResending;
  final String errorMessage;
  final bool canResend;
  final int remainingSeconds;
  final String email;

  const VerifyEmailState({
    this.otpCode = '',
    this.isVerifying = false,
    this.isResending = false,
    this.errorMessage = '',
    this.canResend = false,
    this.remainingSeconds = 60,
    this.email = '',
  });

  bool get isFormValid => otpCode.length == 6;
  bool get isBusy => isVerifying || isResending;

  String get timerText {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  VerifyEmailState copyWith({
    String? otpCode,
    bool? isVerifying,
    bool? isResending,
    String? errorMessage,
    bool? canResend,
    int? remainingSeconds,
    String? email,
  }) {
    return VerifyEmailState(
      otpCode: otpCode ?? this.otpCode,
      isVerifying: isVerifying ?? this.isVerifying,
      isResending: isResending ?? this.isResending,
      errorMessage: errorMessage ?? this.errorMessage,
      canResend: canResend ?? this.canResend,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      email: email ?? this.email,
    );
  }
}

class VerifyEmailNotifier extends StateNotifier<VerifyEmailState> {
  final AuthService _authService;
  Timer? _timer;

  VerifyEmailNotifier({AuthService? authService})
    : _authService = authService ?? _getAuthService(),
      super(const VerifyEmailState());

  static AuthService _getAuthService() {
    return locator<AuthService>();
  }

  void setOtpCode(String value) {
    state = state.copyWith(
      otpCode: value,
      errorMessage: '', // Clear error when user types
    );
  }

  void setEmail(String email) {
    state = state.copyWith(email: email);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    state = state.copyWith(remainingSeconds: 60, canResend: false);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        state = state.copyWith(canResend: true);
        timer.cancel();
      }
    });
  }

  Future<void> resendOTP(BuildContext context, String email) async {
    if (state.isResending) return;

    state = state.copyWith(isResending: true, errorMessage: '');

    try {
      AppLogger.info('Resending OTP to email: $email');

      final response = await _authService.resendOTP(email: email);

      AppLogger.info(
        'Resend OTP response - Status: ${response.statusCode}, Error: ${response.error}, Message: ${response.message}',
      );

      if (response.statusCode == 200) {
        AppLogger.info('OTP resent successfully: ${response.message}');
        TopSnackbar.show(context, message: response.message, isError: false);
        _startTimer(); // Restart timer
      } else {
        AppLogger.error('Failed to resend OTP: ${response.message}');
        TopSnackbar.show(context, message: response.message, isError: true);
      }
    } catch (e) {
      AppLogger.error('Error resending OTP: $e');
      TopSnackbar.show(
        context,
        message: e.toString(),
        isError: true,
      );
    } finally {
      state = state.copyWith(isResending: false);
    }
  }

  Future<void> verifySignup(
    BuildContext context,
    String email,
    String password,
  ) async {
    if (!state.isFormValid || state.isVerifying) return;

    state = state.copyWith(isVerifying: true, errorMessage: '');

    try {
      AppLogger.info('Verifying signup OTP for email: $email');

      final response = await _authService.verifyOtp(
        email: email,
        userOtp: state.otpCode,
        type: "email",
        password: password,
      );

      AppLogger.info(
        'Verify OTP response - Status: ${response.statusCode}, Error: ${response.error}, Message: ${response.message}',
      );

      if (response.statusCode == 200) {
        AppLogger.info('Signup verification successful: ${response.message}');
        TopSnackbar.show(context, message: response.message, isError: false);

        // Navigate to create passcode screen (for signup flow)
        appRouter.pushNamed(AppRoute.createPasscodeView, arguments: true);
      } else {
        AppLogger.error('Signup verification failed: ${response.message}');
        state = state.copyWith(errorMessage: response.message);
        TopSnackbar.show(context, message: response.message, isError: true);
      }
    } catch (e) {
      AppLogger.error('Error verifying signup: $e');
      state = state.copyWith(errorMessage: e.toString());
      TopSnackbar.show(context, message: e.toString(), isError: true);
    } finally {
      state = state.copyWith(isVerifying: false);
    }
  }

  Future<void> verifyForgotPassword(BuildContext context, String email) async {
    if (!state.isFormValid || state.isVerifying) return;

    state = state.copyWith(isVerifying: true, errorMessage: '');

    try {
      AppLogger.info('Verifying forgot password OTP for email: $email');

      final response = await _authService.verifyOtp(
        email: email,
        userOtp: state.otpCode,
        type: "password",
      );

      AppLogger.info(
        'Verify OTP response - Status: ${response.statusCode}, Error: ${response.error}, Message: ${response.message}',
      );

      if (response.statusCode == 200) {
        AppLogger.info(
          'Password reset verification successful: ${response.message}',
        );
        TopSnackbar.show(context, message: response.message, isError: false);

        // Navigate to reset password screen
        appRouter.pushNamed(AppRoute.resetPasswordView, arguments: email);
      } else {
        AppLogger.error(
          'Password reset verification failed: ${response.message}',
        );
        state = state.copyWith(errorMessage: response.message);
        TopSnackbar.show(context, message: response.message, isError: true);
      }
    } catch (e) {
      AppLogger.error('Error verifying forgot password: $e');
      state = state.copyWith(errorMessage: e.toString());
      TopSnackbar.show(context, message: e.toString(), isError: true);
    } finally {
      state = state.copyWith(isVerifying: false);
    }
  }


  void resetForm() {
    _timer?.cancel();
    state = const VerifyEmailState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// Provider
final verifyEmailProvider =
    StateNotifierProvider<VerifyEmailNotifier, VerifyEmailState>((ref) {
      return VerifyEmailNotifier();
    });
