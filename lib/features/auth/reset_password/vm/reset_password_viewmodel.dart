import 'package:flutter/material.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/services/remote/auth_service.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/routes/route.dart';

class ResetPasswordViewModel extends ChangeNotifier {
  final AuthService _authService = locator<AuthService>();

  String _confirmPassword = '';
  String _password = '';
  String? _confirmPasswordError;
  String? _passwordError;
  bool _isBusy = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  String? get confirmPasswordError => _confirmPasswordError;
  String? get passwordError => _passwordError;
  bool get isBusy => _isBusy;
  bool get isPasswordVisible => _isPasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;

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
    // Re-validate confirm password when password changes
    if (_confirmPassword.isNotEmpty) {
      _confirmPasswordError = _validateConfirmPassword(_confirmPassword);
    }
    notifyListeners();
  }

  String? _validateConfirmPassword(String value) {
    if (value.isEmpty) return 'Please type your password again';
    if (value != _password) return 'Both passwords must be exactly the same';
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) return 'Please create a password';
    if (value.length < 8) return 'Password must be at least 8 characters long';
    if (!RegExp(r'^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9]).{8,}$')
        .hasMatch(value)) {
      return 'Password must include: 1 uppercase letter, 1 number, and 1 special character (!@#\$&*)';
    }
    return null;
  }

  Future<void> resetPassword(String email, BuildContext context) async {
    if (!isFormValid) return;

    _isBusy = true;
    notifyListeners();

    try {
      final response = await _authService.resetPassword(
        email: email,
        password: _password,
      );

      if (!response.error) {
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
        TopSnackbar.show(
          context,
          message: response.message,
          isError: true,
        );
      }
    } catch (e) {
      TopSnackbar.show(
        context,
        message: 'Error: ${e.toString()}',
        isError: true,
      );
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
