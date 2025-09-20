import 'package:dayfi/app/app.locator.dart';
import 'package:dayfi/app/app.router.dart';
import 'package:dayfi/services/api/auth_api_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../components/top_snack_bar.dart';

class SignupViewModel extends BaseViewModel {
  final _apiService = AuthApiService();
  final _dialogService = DialogService();
  final NavigationService _navigationService = locator<NavigationService>();

  bool _isAgreed = false;

  bool get isAgreed => _isAgreed;

  void setAgreed(bool value) {
    _isAgreed = value;
    notifyListeners();
  }

  String _firstName = '';
  String _lastName = '';
  String _middleName = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = "";

  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  String? get firstNameError => _firstNameError;
  String? get lastNameError => _lastNameError;
  String? get emailError => _emailError;
  String? get passwordError => _passwordError;
  String? get confirmPasswordError => _confirmPasswordError;
  NavigationService get navigationService => _navigationService;

  bool get isFormValid =>
      _firstName.isNotEmpty &&
      _lastName.isNotEmpty &&
      _email.isNotEmpty &&
      _password.isNotEmpty &&
      _confirmPassword.isNotEmpty &&
      _firstNameError == null &&
      _lastNameError == null &&
      _emailError == null &&
      _passwordError == null &&
      _confirmPasswordError == null &&
      _isAgreed;

  void setFirstName(String value) {
    _firstName = value;
    _firstNameError = _validateName(value, 'First name');
    notifyListeners();
  }

  void setLastName(String value) {
    _lastName = value;
    _lastNameError = _validateName(value, 'Last name');
    notifyListeners();
  }

  void setMiddleName(String value) {
    _middleName = value;
    notifyListeners();
  }

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

  void setConfirmPassword(String value) {
    _confirmPassword = value;
    _confirmPasswordError = _validateConfirmPassword(value);
    notifyListeners();
  }

  String? _validateName(String value, String fieldName) {
    if (value.isEmpty) return '$fieldName is required';
    if (value.length < 2) return '$fieldName must be at least 2 characters';
    return null;
  }

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
    if (!RegExp(r'^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9]).{8,}$')
        .hasMatch(value)) {
      return 'Password must contain uppercase, number, and special character';
    }
    return null;
  }

  String? _validateConfirmPassword(String value) {
    if (value != _password) return 'Password must match';
    // if (value.length < 8) return 'Password must be at least 8 characters';
    // if (!RegExp(r'^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9]).{8,}$')
    //     .hasMatch(value)) {
    //   return 'Password must contain uppercase, number, and special character';
    // }
    return null;
  }

  Future<void> signup(BuildContext context) async {
    if (!isFormValid) return;

    setBusy(true);

    try {
      final response = await _apiService.signup(
        firstName: _firstName,
        lastName: _lastName,
        middleName: _middleName,
        email: _email,
        password: _password,
      );

      if (response.code == 200) {
        TopSnackbar.show(
          context,
          message: response.message,
        );

        await Future.delayed(const Duration(milliseconds: 500));
        navigationService.navigateToVerifyEmailView(
          isSignUp: true,
          email: _email,
          password: _password,
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
        message: 'Sign up error: $errorText',
        isError: true,
      );
    } finally {
      await Future.delayed(const Duration(milliseconds: 500));
      setBusy(false);
    }
  }
}
