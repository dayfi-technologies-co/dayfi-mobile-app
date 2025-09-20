import 'dart:developer';

import 'package:dayfi/app/app.locator.dart';
import 'package:dayfi/app/app.router.dart';
import 'package:dayfi/services/api/auth_api_service.dart';
import 'package:dayfi/ui/views/login/login_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../components/top_snack_bar.dart';

class ResetPasswordViewModel extends BaseViewModel {
  final _apiService = AuthApiService();
  final _dialogService = DialogService();
  final NavigationService _navigationService = locator<NavigationService>();

  String _confirmPassword = '';
  String _password = '';

  String? _confirmPasswordError;
  String? _passwordError;

  String? get confirmPasswordError => _confirmPasswordError;
  String? get passwordError => _passwordError;
  NavigationService get navigationService => _navigationService;

  bool get isFormValid =>
      _confirmPassword.isNotEmpty &&
      _password.isNotEmpty &&
      _confirmPasswordError == null &&
      _passwordError == null;

  void setConfirmPassword(String value) {
    _confirmPassword = value;
    _confirmPasswordError = _validateConfirmPassword(value);
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    _passwordError = _validatePassword(value);
    notifyListeners();
  }

  String? _validateConfirmPassword(String value) {
    if (value != _password) return 'Password must match';
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9]).{8,}$')
        .hasMatch(value)) {
      return 'Password must contain uppercase, number, and special character';
    }
    return null;
  }

  Future<void> resetPassword(String email, BuildContext context) async {
    if (!isFormValid) return;

    setBusy(true);
    try {
      final response = await _apiService.resetPassword(
        email: email,
        password: _password,
      );

      TopSnackbar.show(
        context,
        message: response.message,
      );

      await Future.delayed(const Duration(milliseconds: 500));

      navigationService.clearStackAndShow(Routes.loginView);
    } catch (e) {
      TopSnackbar.show(
        context,
        message: 'Error: ${e.toString()}',
        isError: true,
      );
    } finally {
      setBusy(false);
    }
  }
}
