import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/services/remote/auth_service.dart';
import 'package:dayfi/services/remote/network/network_service.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/common/constants/analytics_events.dart';
import 'package:dayfi/common/utils/connectivity_utils.dart';

class SignupState {
  final String firstName;
  final String lastName;
  final String middleName;
  final String email;
  final String password;
  final String confirmPassword;
  final bool isAgreed;
  final bool isBusy;
  final String firstNameError;
  final String lastNameError;
  final String emailError;
  final String passwordError;
  final String confirmPasswordError;
  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasNumber;
  final bool hasSpecialCharacter;
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;

  const SignupState({
    this.firstName = '',
    this.lastName = '',
    this.middleName = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.isAgreed = false,
    this.isBusy = false,
    this.firstNameError = '',
    this.lastNameError = '',
    this.emailError = '',
    this.passwordError = '',
    this.confirmPasswordError = '',
    this.hasMinLength = false,
    this.hasUppercase = false,
    this.hasLowercase = false,
    this.hasNumber = false,
    this.hasSpecialCharacter = false,
    this.isPasswordVisible = true,
    this.isConfirmPasswordVisible = true,
  });

  bool get isFormValid =>
      firstName.isNotEmpty &&
      lastName.isNotEmpty &&
      email.isNotEmpty &&
      password.isNotEmpty &&
      confirmPassword.isNotEmpty &&
      firstNameError.isEmpty &&
      lastNameError.isEmpty &&
      emailError.isEmpty &&
      passwordError.isEmpty &&
      confirmPasswordError.isEmpty &&
      isAgreed;

  SignupState copyWith({
    String? firstName,
    String? lastName,
    String? middleName,
    String? email,
    String? password,
    String? confirmPassword,
    bool? isAgreed,
    bool? isBusy,
    String? firstNameError,
    String? lastNameError,
    String? emailError,
    String? passwordError,
    String? confirmPasswordError,
    bool? hasMinLength,
    bool? hasUppercase,
    bool? hasLowercase,
    bool? hasNumber,
    bool? hasSpecialCharacter,
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
  }) {
    return SignupState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      middleName: middleName ?? this.middleName,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isAgreed: isAgreed ?? this.isAgreed,
      isBusy: isBusy ?? this.isBusy,
      firstNameError: firstNameError ?? this.firstNameError,
      lastNameError: lastNameError ?? this.lastNameError,
      emailError: emailError ?? this.emailError,
      passwordError: passwordError ?? this.passwordError,
      confirmPasswordError: confirmPasswordError ?? this.confirmPasswordError,
      hasMinLength: hasMinLength ?? this.hasMinLength,
      hasUppercase: hasUppercase ?? this.hasUppercase,
      hasLowercase: hasLowercase ?? this.hasLowercase,
      hasNumber: hasNumber ?? this.hasNumber,
      hasSpecialCharacter: hasSpecialCharacter ?? this.hasSpecialCharacter,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isConfirmPasswordVisible:
          isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
    );
  }
}

class SignupNotifier extends StateNotifier<SignupState> {
  final AuthService _authService;

  SignupNotifier({AuthService? authService})
    : _authService = authService ?? _getAuthService(),
      super(const SignupState());

  static AuthService _getAuthService() {
    try {
      return locator<AuthService>();
    } catch (e) {
      AppLogger.error('Failed to get AuthService from locator: $e');
      return AuthService(networkService: NetworkService());
    }
  }

  // Setters
  void setFirstName(String value) {
    final firstNameError = _validateName(value, 'First name');
    state = state.copyWith(firstName: value, firstNameError: firstNameError);
  }

  void setLastName(String value) {
    final lastNameError = _validateName(value, 'Last name');
    state = state.copyWith(lastName: value, lastNameError: lastNameError);
  }

  void setMiddleName(String value) {
    state = state.copyWith(middleName: value);
  }

  void setEmail(String value) {
    final emailError = _validateEmail(value);
    state = state.copyWith(email: value, emailError: emailError);
  }

  void setPassword(String value) {
    final passwordError = _validatePassword(value);
    String? confirmPasswordError = state.confirmPasswordError;

    // Re-validate confirm password when password changes
    if (state.confirmPassword.isNotEmpty) {
      confirmPasswordError = _validateConfirmPassword(state.confirmPassword);
    }

    // Check password requirements
    final hasMinLength = value.length >= 8;
    final hasUppercase = value.contains(RegExp(r'[A-Z]'));
    final hasLowercase = value.contains(RegExp(r'[a-z]'));
    final hasNumber = value.contains(RegExp(r'[0-9]'));
    final hasSpecialCharacter = value.contains(
      RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
    );

    state = state.copyWith(
      password: value,
      passwordError: passwordError,
      confirmPasswordError: confirmPasswordError,
      hasMinLength: hasMinLength,
      hasUppercase: hasUppercase,
      hasLowercase: hasLowercase,
      hasNumber: hasNumber,
      hasSpecialCharacter: hasSpecialCharacter,
    );
  }

  void setConfirmPassword(String value) {
    final confirmPasswordError = _validateConfirmPassword(value);
    state = state.copyWith(
      confirmPassword: value,
      confirmPasswordError: confirmPasswordError,
    );
  }

  void setAgreed(bool value) {
    state = state.copyWith(isAgreed: value);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(
      isConfirmPasswordVisible: !state.isConfirmPasswordVisible,
    );
  }

  // Reset all form data and errors
  void resetForm() {
    state = const SignupState();
  }

  @override
  void dispose() {
    // Reset form when disposing
    resetForm();
    super.dispose();
  }

  // Validation methods
  String _validateName(String value, String fieldName) {
    if (value.isEmpty) return 'Please enter your $fieldName';
    if (value.trim().length < 2) {
      return 'Please enter a valid $fieldName';
    }
    if (!RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(value.trim())) {
      return 'Please use only letters, spaces, hyphens, and apostrophes';
    }
    return '';
  }

  String _validateEmail(String value) {
    if (value.isEmpty) return 'Please enter your email address';
    if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(value)) {
      return 'Please enter a valid email address (like: yourname@email.com)';
    }
    return '';
  }

  String _validatePassword(String value) {
    if (value.isEmpty) return 'Please create a password';
    if (value.length < 8) return 'Password must be at least 8 characters long';

    // Check individual requirements
    final hasUppercase = value.contains(RegExp(r'[A-Z]'));
    final hasLowercase = value.contains(RegExp(r'[a-z]'));
    final hasNumber = value.contains(RegExp(r'[0-9]'));
    final hasSpecialCharacter = value.contains(
      RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
    );

    if (!hasUppercase || !hasLowercase || !hasNumber || !hasSpecialCharacter) {
      return 'Password must include: 1 uppercase letter, 1 lowercase letter, 1 number, and 1 special character';
    }
    return '';
  }

  String _validateConfirmPassword(String value) {
    if (value.isEmpty) return 'Please type your password again';
    if (value != state.password) {
      return 'Both passwords must be exactly the same';
    }
    return '';
  }

  // Signup method
  Future<void> signup(BuildContext context) async {
    if (!state.isFormValid) return;

    state = state.copyWith(isBusy: true);

    try {
      // Analytics: signup started
      analyticsService.logEvent(
        name: AnalyticsEvents.signupStarted,
        parameters: { 'email': state.email },
      );
      AppLogger.info('Starting signup process for email: ${state.email}');

      final response = await _authService.signup(
        firstName: state.firstName,
        lastName: state.lastName,
        middleName: state.middleName,
        email: state.email,
        password: state.password,
      );

      AppLogger.info(
        'Signup response - Status: ${response.statusCode}, Error: ${response.error}, Message: ${response.message}',
      );

      if (response.statusCode == 200) {
        AppLogger.info('Signup successful: ${response.message}');
        analyticsService.logEvent(
          name: AnalyticsEvents.signupCompleted,
          parameters: { 'email': state.email },
        );

        // Show success message
        TopSnackbar.show(context, message: response.message, isError: false);

        // Navigate to verification screen
        appRouter.pushNamed(
          AppRoute.verifyEmailView,
          arguments: VerifyEmailViewArguments(
            isSignUp: true,
            email: state.email,
            password: state.password,
          ),
        );
      } else {
        AppLogger.error('Signup failed: ${response.message}');
        analyticsService.logEvent(
          name: AnalyticsEvents.signupFailed,
          parameters: { 'email': state.email, 'reason': response.message },
        );

        // Check if it's a 401 error with activation message
        if (response.message.toLowerCase().contains('activate your account')) {
          AppLogger.info(
            'Account needs activation, navigating to verify email screen',
          );

          // Navigate to verify email screen and automatically resend OTP
          _navigateToVerifyEmailAndResendOTP(context, state.email);
        } else {
          // Show backend error message for other errors
          TopSnackbar.show(context, message: response.message, isError: true);

          // Set field-specific errors based on the message
          _setFieldErrorsFromMessage(response.message);
        }
      }
    } catch (e) {
      if (e.toString().toLowerCase().contains('activate your account')) {
        AppLogger.info(
          'Account needs activation, navigating to verify email screen',
        );

        // Navigate to verify email screen and automatically resend OTP
        _navigateToVerifyEmailAndResendOTP(context, state.email);
      } else {
        AppLogger.error('Signup error: $e');
        AppLogger.error('Signup error type: ${e.runtimeType}');
        
        // Get user-friendly error message
        final errorMessage = await ConnectivityUtils.getErrorMessage(e);
        AppLogger.info('Parsed error message: $errorMessage');
        
        analyticsService.logEvent(
          name: AnalyticsEvents.signupFailed,
          parameters: { 'email': state.email, 'reason': errorMessage },
        );
        TopSnackbar.show(
          // ignore: use_build_context_synchronously
          context,
          message: errorMessage,
          isError: true,
        );
      }
    } finally {
      state = state.copyWith(isBusy: false);
    }
  }

  // Set field-specific errors based on backend message
  void _setFieldErrorsFromMessage(String message) {
    String? emailError;
    String? passwordError;
    String? firstNameError;
    String? lastNameError;

    // Check for specific field errors in the message
    if (message.toLowerCase().contains('email')) {
      emailError = message;
    } else if (message.toLowerCase().contains('password')) {
      passwordError = message;
    } else if (message.toLowerCase().contains('first name') ||
        message.toLowerCase().contains('firstname')) {
      firstNameError = message;
    } else if (message.toLowerCase().contains('last name') ||
        message.toLowerCase().contains('lastname')) {
      lastNameError = message;
    } else {
      // If no specific field is mentioned, show as general error
      emailError = message;
    }

    state = state.copyWith(
      emailError: emailError ?? '',
      passwordError: passwordError ?? '',
      firstNameError: firstNameError ?? '',
      lastNameError: lastNameError ?? '',
    );
  }

  // Navigate to verify email screen and automatically resend OTP
  void _navigateToVerifyEmailAndResendOTP(BuildContext context, String email) {
    // Navigate to verify email screen
    appRouter.pushNamed(
      AppRoute.verifyEmailView,
      arguments: VerifyEmailViewArguments(
        isSignUp: true, // This is for signup flow
        email: email,
        password: state.password, // Pass the password for potential use
      ),
    );

    // Show a message that OTP will be resent automatically
    TopSnackbar.show(
      context,
      message:
          'Please check your email for verification code. A new code will be sent automatically.',
      isError: false,
    );

    // Automatically resend OTP after a short delay to ensure the screen is loaded

    _authService
        .resendOTP(email: email)
        .then((response) {
          if (response.statusCode == 200) {
            AppLogger.info('OTP resent successfully: ${response.message}');
          } else {
            AppLogger.error('Failed to resend OTP: ${response.message}');
          }
        })
        .catchError((e) {
          AppLogger.error('Error resending OTP: $e');
        });
  }

  // Navigation methods
  void navigateToLogin() {
    appRouter.pushNamed(AppRoute.loginView);
  }

  // Clear form
  void clearForm() {
    state = const SignupState();
  }
}

// Provider
final signupProvider = StateNotifierProvider<SignupNotifier, SignupState>((
  ref,
) {
  return SignupNotifier();
});
