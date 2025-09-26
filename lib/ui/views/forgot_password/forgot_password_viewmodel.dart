import 'package:dayfi/app/app.locator.dart';
import 'package:dayfi/app/app.router.dart';
import 'package:dayfi/services/api/auth_api_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../components/top_snack_bar.dart';

class ForgotPasswordViewModel extends BaseViewModel {
  final _apiService = AuthApiService();
  final NavigationService _navigationService = locator<NavigationService>();

  NavigationService get navigationService => _navigationService;

  String _email = '';

  String? _emailError;

  String? get emailError => _emailError;

  bool get isFormValid => _email.isNotEmpty && _emailError == null;

  void setEmail(String value) {
    _email = value;
    _emailError = _validateEmail(value);
    notifyListeners();
  }

  String? _validateEmail(String value) {
    if (value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  Future<void> forgotPassword(BuildContext context) async {
    if (!isFormValid) return;

    setBusy(true);

    try {
      final response = await _apiService.forgotPassowrd(
        email: _email,
      );

      if (response.code == 200) {
        TopSnackbar.show(
          context,
          message: response.message,
        );

        await Future.delayed(const Duration(milliseconds: 500));
        navigationService.navigateToVerifyEmailView(
          isSignUp: false,
          email: _email,
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
      setBusy(false);
    }
  }
}
