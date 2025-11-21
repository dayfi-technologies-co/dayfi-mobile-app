import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/services/remote/auth_service.dart';
import 'package:dayfi/app_locator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:dayfi/services/remote/network/api_error.dart';

class ResetTransactionPinState {
  final bool isLoading;
  final bool isOtpSent;
  final bool isOtpVerified;
  final String email;
  final String errorMessage;
  final int remainingTime;

  ResetTransactionPinState({
    this.isLoading = false,
    this.isOtpSent = false,
    this.isOtpVerified = false,
    this.email = '',
    this.errorMessage = '',
    this.remainingTime = 0,
  });

  ResetTransactionPinState copyWith({
    bool? isLoading,
    bool? isOtpSent,
    bool? isOtpVerified,
    String? email,
    String? errorMessage,
    int? remainingTime,
  }) {
    return ResetTransactionPinState(
      isLoading: isLoading ?? this.isLoading,
      isOtpSent: isOtpSent ?? this.isOtpSent,
      isOtpVerified: isOtpVerified ?? this.isOtpVerified,
      email: email ?? this.email,
      errorMessage: errorMessage ?? this.errorMessage,
      remainingTime: remainingTime ?? this.remainingTime,
    );
  }
}

class ResetTransactionPinNotifier extends StateNotifier<ResetTransactionPinState> {
  ResetTransactionPinNotifier() : super(ResetTransactionPinState());

  final _authService = locator<AuthService>();

  Future<bool> sendResetOtp(String email) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: '');

      final response = await _authService.resendOTP(email: email);

      if (response.error == false) {
        state = state.copyWith(
          isLoading: false,
          isOtpSent: true,
          email: email,
          errorMessage: '',
        );
        AppLogger.info('Reset OTP sent successfully');
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.message,
        );
        AppLogger.error('Error sending reset OTP: ${response.message}');
        return false;
      }
    } catch (e) {
      final errorMsg = 'Failed to send reset OTP: $e';
      state = state.copyWith(isLoading: false, errorMessage: errorMsg);
      AppLogger.error(errorMsg);
      return false;
    }
  }

  Future<bool> verifyResetOtp(String userOtp) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: '');

      // For reset transaction pin, type is 'pin_reset'
      final response = await _authService.verifyOtp(
        userOtp: userOtp,
        type: 'pin_reset',
      );

      if (response.error == false) {
        state = state.copyWith(
          isLoading: false,
          isOtpVerified: true,
          errorMessage: '',
        );
        AppLogger.info('Reset OTP verified successfully');
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.message,
        );
        AppLogger.error('Error verifying reset OTP: ${response.message}');
        return false;
      }
    } catch (e) {
      final errorMsg = 'Failed to verify reset OTP: $e';
      state = state.copyWith(isLoading: false, errorMessage: errorMsg);
      AppLogger.error(errorMsg);
      return false;
    }
  }

  Future<bool> resetTransactionPin(String newPin) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: '');

      final response = await _authService.resetTransactionPin(
        transactionPin: newPin,
      );

      if (response['error'] == false || response['success'] == true) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: '',
        );
        AppLogger.info('Transaction PIN reset successfully');
        return true;
      } else {
        final errorMsg = response['message'] ?? 'Failed to reset PIN';
        state = state.copyWith(
          isLoading: false,
          errorMessage: errorMsg,
        );
        AppLogger.error('Error resetting transaction PIN: $errorMsg');
        return false;
      }
    } catch (e) {
      // Some backends return a success message inside an exception or non-standard wrapper.
      // If the exception contains a success message like "Transaction pin updated successfully",
      // treat it as success so the UI shows the success dialog and navigates correctly.
      try {
        if (e is DioException) {
          final apiErr = ApiError.fromDio(e);
          final backendMsg = apiErr.errorDescription ?? apiErr.apiErrorModel?.message;
          if (backendMsg != null) {
            final lower = backendMsg.toLowerCase();
            if (lower.contains('transaction') && (lower.contains('updated') || lower.contains('success') || lower.contains('reset'))) {
              AppLogger.info('Backend reported success in exception: $backendMsg');
              state = state.copyWith(isLoading: false, errorMessage: '');
              return true;
            }
          }
        } else if (e.toString().toLowerCase().contains('transaction') &&
            (e.toString().toLowerCase().contains('updated') || e.toString().toLowerCase().contains('success') || e.toString().toLowerCase().contains('reset'))) {
          AppLogger.info('Caught success-like message in exception: $e');
          state = state.copyWith(isLoading: false, errorMessage: '');
          return true;
        }
      } catch (_) {}

      final errorMsg = 'Failed to reset transaction PIN: $e';
      state = state.copyWith(isLoading: false, errorMessage: errorMsg);
      AppLogger.error(errorMsg);
      return false;
    }
  }

  void resetForm() {
    state = ResetTransactionPinState();
  }

  void setError(String error) {
    state = state.copyWith(errorMessage: error);
  }
}

final resetTransactionPinProvider =
    StateNotifierProvider<ResetTransactionPinNotifier, ResetTransactionPinState>(
  (ref) => ResetTransactionPinNotifier(),
);
