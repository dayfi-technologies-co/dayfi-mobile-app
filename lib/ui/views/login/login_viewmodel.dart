import 'package:dayfi/app/app.locator.dart';
import 'package:dayfi/app/app.router.dart';
import 'package:dayfi/services/api/auth_api_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../components/top_snack_bar.dart';

class LoginViewModel extends BaseViewModel {
  final _apiService = AuthApiService();
  final NavigationService _navigationService = locator<NavigationService>();

  String _email = '';
  String _password = '';

  String? _emailError;
  String? _passwordError;

  String? get emailError => _emailError;
  String? get passwordError => _passwordError;
  NavigationService get navigationService => _navigationService;

  bool get isFormValid =>
      _email.isNotEmpty &&
      _password.isNotEmpty &&
      _emailError == null &&
      _passwordError == null;

  void setEmail(String value) {
    _email = value;
    _emailError = _validateEmail(value);
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    _passwordError = _validatePassword(value);
    notifyListeners();
  }

  // void setDummyValues() {
  //   _email = "dorc@yopmail.com";
  //   _password = "Pass123@";
  // }

  String? _validateEmail(String value) {
    if (value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(
      r'^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9]).{8,}$',
    ).hasMatch(value)) {
      return 'Password must contain uppercase, number, and special character';
    }
    return null;
  }

  Future<void> login(BuildContext context) async {
    if (!isFormValid) return;

    setBusy(true);

    try {
      final response = await _apiService.login(
        email: _email,
        password: _password,
      );

      if (response.code == 200) {
        print('Signin successful: ${response.message}');

        // Show success message
        _showSnackBar(context, response.message, isError: false);

        _navigationService.clearStackAndShow(Routes.createPasscodeView);
        ;
      } else {
        print('Signin failed: ${response.message}');

        // Show backend error message
        _showSnackBar(context, response.message, isError: true);

        // Set field-specific errors based on the message
        // _setFieldErrorsFromMessage(response.message);
      }
    } catch (e) {
      print('Signin error: $e');
      _showSnackBar(
        // ignore: use_build_context_synchronously
        context,
        e.toString(),
        isError: true,
      );
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    TopSnackbar.show(context, message: message, isError: isError);
  }
}
