import 'package:dayfi/app/app.locator.dart';
import 'package:dayfi/app/app.router.dart';
import 'package:dayfi/services/api/auth_api_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../components/top_snack_bar.dart';

class SignupState {
  final String firstName;
  final String lastName;
  final String middleName;
  final String email;
  final String password;
  final String confirmPassword;
  final bool isBusy;
  final bool isFormValid;

  const SignupState({
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.isBusy,
    required this.isFormValid,
  });

  SignupState copyWith({
    String? firstName,
    String? lastName,
    String? middleName,
    String? email,
    String? password,
    String? confirmPassword,
    bool? isBusy,
    bool? isFormValid,
  }) {
    return SignupState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      middleName: middleName ?? this.middleName,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isBusy: isBusy ?? this.isBusy,
      isFormValid: isFormValid ?? this.isFormValid,
    );
  }
}

class SignupViewModel extends BaseViewModel {
  final _apiService = AuthApiService();
  final NavigationService _navigationService = locator<NavigationService>();

  bool _isAgreed = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  bool get isAgreed => _isAgreed;
  bool get isPasswordVisible => _isPasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;

  void setAgreed(bool value) {
    _isAgreed = value;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
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
  bool get isBusy => state.isBusy;
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
    state = state.copyWith(firstName: value, isFormValid: isFormValid);
    notifyListeners();
  }

  void setLastName(String value) {
    _lastName = value;
    _lastNameError = _validateName(value, 'Last name');
    state = state.copyWith(lastName: value, isFormValid: isFormValid);
    notifyListeners();
  }

  void setMiddleName(String value) {
    _middleName = value;
    state = state.copyWith(middleName: value, isFormValid: isFormValid);
    notifyListeners();
  }

  void setEmail(String value) {
    _email = value;
    _emailError = _validateEmail(value);
    state = state.copyWith(email: value, isFormValid: isFormValid);
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    _passwordError = _validatePassword(value);
    state = state.copyWith(password: value, isFormValid: isFormValid);
    notifyListeners();
  }

  void setConfirmPassword(String value) {
    _confirmPassword = value;
    _confirmPasswordError = _validateConfirmPassword(value);
    state = state.copyWith(confirmPassword: value, isFormValid: isFormValid);
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

  // State management
  late SignupState state = SignupState(
    firstName: _firstName,
    lastName: _lastName,
    middleName: _middleName,
    email: _email,
    password: _password,
    confirmPassword: _confirmPassword,
    isBusy: false,
    isFormValid: isFormValid,
  );


  // Helper methods
  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    TopSnackbar.show(
      context,
      message: message,
      isError: isError,
    );
  }

  void _setFieldErrorsFromMessage(String message) {
    // Reset all errors
    _firstNameError = null;
    _lastNameError = null;
    _emailError = null;
    _passwordError = null;
    _confirmPasswordError = null;

    // Set specific errors based on message content
    if (message.toLowerCase().contains('email')) {
      _emailError = message;
    } else if (message.toLowerCase().contains('password')) {
      _passwordError = message;
    } else if (message.toLowerCase().contains('first name') || message.toLowerCase().contains('firstname')) {
      _firstNameError = message;
    } else if (message.toLowerCase().contains('last name') || message.toLowerCase().contains('lastname')) {
      _lastNameError = message;
    }

    notifyListeners();
  }

  Future<void> signup(BuildContext context) async {
    if (!state.isFormValid) return;

    state = state.copyWith(isBusy: true);
    notifyListeners();

    try {
      print('Starting signup process for email: ${state.email}');

      final response = await _apiService.signup(
        firstName: state.firstName,
        lastName: state.lastName,
        middleName: state.middleName,
        email: state.email,
        password: state.password,
      );

      print('Signup response - Status: ${response.code}, Message: ${response.message}');

      if (response.code == 200) {
        print('Signup successful: ${response.message}');

        // Show success message
        _showSnackBar(context, response.message, isError: false);

        // Navigate to verification screen
        _navigationService.navigateToVerifyEmailView(
          isSignUp: true,
          email: state.email,
          password: state.password,
        );
      } else {
        print('Signup failed: ${response.message}');
        
        // Show backend error message
        _showSnackBar(context, response.message, isError: true);
        
        // Set field-specific errors based on the message
        _setFieldErrorsFromMessage(response.message);
      }
    } catch (e) {
      print('Signup error: $e');
      _showSnackBar(
        // ignore: use_build_context_synchronously
        context,
        e.toString(),
        isError: true,
      );
    } finally {
      state = state.copyWith(isBusy: false);
      notifyListeners();
    }
  }
}
