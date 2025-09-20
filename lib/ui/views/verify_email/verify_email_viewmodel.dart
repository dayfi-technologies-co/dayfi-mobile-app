import 'dart:async';
import 'dart:developer';

import 'package:dayfi/app/app.router.dart';
import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';

import 'package:dayfi/app/app.locator.dart';
import 'package:dayfi/services/api/auth_api_service.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../components/top_snack_bar.dart';

class VerifyEmailViewModel extends BaseViewModel {
  final _apiService = AuthApiService();
  final _dialogService = DialogService();
  final NavigationService navigationService = locator<NavigationService>();

  // TextEditingController otpCodeTextEditingController = TextEditingController();
  Timer? _timer;
  int _remainingSeconds = 60; // Start at 60 seconds
  String _emailAddress = '';
  String otpCode = "";

  String? _otpCodeError;

  String? get emailError => _otpCodeError;

  int get remainingSeconds => _remainingSeconds;
  String get timerText =>
      'Resend code in ${(_remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}';
  bool get canResend => _remainingSeconds == 0;

  bool get isFormValid => otpCode.isNotEmpty && _otpCodeError == null;

  VerifyEmailViewModel({String emailAddress = ''}) {
    _emailAddress = emailAddress;
    startTimer();
  }

  void startTimer() {
    _timer?.cancel(); // Cancel any existing timer
    _remainingSeconds = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  void setOtpCode(String value) {
    otpCode = value;
    _otpCodeError = _validateOTPCOde(value);
    notifyListeners();
  }

  String? _validateOTPCOde(String value) {
    if (value.isEmpty) return 'OTP is required';
    if (value.length != 6) return 'OTP must be 6 digits';
    // if (!RegExp(r'^\d{6}$').hasMatch(value)) return 'Enter a valid 6-digit OTP';
    return null;
  }

  Future<void> verifySignup(
      BuildContext context, String email, String password) async {
    if (!isFormValid) return;

    setBusy(true);

    try {
      final response = await _apiService.verifyOtp(
        userOtp: otpCode,
        type: "email",
        email: email,
        password: password,
      );

      if (response.code == 200) {
        TopSnackbar.show(
          context,
          message: response.message,
        );

        await Future.delayed(const Duration(milliseconds: 500));
        navigationService.clearStackAndShow(Routes.successView);
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
        message: 'Verification error: $errorText',
        isError: true,
      );
    } finally {
      await Future.delayed(const Duration(milliseconds: 500));
      setBusy(false);
    }
  }

  Future<void> verifyForgotPassword(BuildContext context, String email) async {
    if (!isFormValid) return;

    setBusy(true);

    try {
      final response = await _apiService.verifyOtp(
        userOtp: otpCode,
        type: 'password',
      );

      if (response.code == 200) {
        TopSnackbar.show(
          context,
          message: response.message,
        );

        await Future.delayed(const Duration(milliseconds: 500));
        navigationService.navigateToResetPasswordView(email: email);
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
        message: 'Verification error: $errorText',
        isError: true,
      );
    } finally {
      await Future.delayed(const Duration(milliseconds: 500));
      setBusy(false);
    }
  }

  Future<void> resendOTP(BuildContext context, String email) async {
    if (!isFormValid) return;

    setBusy(true);

    try {
      final response = await _apiService.resendOTP(email: email);

      if (response.code == 200) {
        TopSnackbar.show(
          context,
          message: response.message,
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
        message: 'Resend OTP error: $errorText',
        isError: true,
      );
    } finally {
      await Future.delayed(const Duration(milliseconds: 500));
      setBusy(false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
