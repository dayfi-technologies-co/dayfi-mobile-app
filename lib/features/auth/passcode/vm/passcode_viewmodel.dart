import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/services/local/secure_storage.dart';
import 'package:dayfi/services/remote/auth_service.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/models/user_model.dart';

class PasscodeState {
  final String passcode;
  final bool isVerifying;
  final bool isBiometricAvailable;
  final bool isLoading;
  final User? user;
  final String errorMessage;

  const PasscodeState({
    this.passcode = '',
    this.isVerifying = false,
    this.isBiometricAvailable = false,
    this.isLoading = false,
    this.user,
    this.errorMessage = '',
  });

  bool get hasFaceId => false; // Simplified for now
  bool get hasFingerprint => false; // Simplified for now

  PasscodeState copyWith({
    String? passcode,
    bool? isVerifying,
    bool? isBiometricAvailable,
    bool? isLoading,
    User? user,
    String? errorMessage,
  }) {
    return PasscodeState(
      passcode: passcode ?? this.passcode,
      isVerifying: isVerifying ?? this.isVerifying,
      isBiometricAvailable: isBiometricAvailable ?? this.isBiometricAvailable,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class PasscodeNotifier extends StateNotifier<PasscodeState> {
  final SecureStorageService _secureStorage = locator<SecureStorageService>();
  final AuthService _authService = locator<AuthService>();

  PasscodeNotifier() : super(const PasscodeState());

  Future<void> loadUser() async {
    try {
      final userJson = await _secureStorage.read('user');
      if (userJson.isNotEmpty) {
        final user = User.fromJson(json.decode(userJson));
        state = state.copyWith(user: user);
      }
      // Simplified biometric check - always false for now
      state = state.copyWith(isBiometricAvailable: false);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user: $e');
      }
    }
  }

  void addDigit(String digit) {
    if (state.passcode.length < 4) {
      state = state.copyWith(passcode: state.passcode + digit);
      if (state.passcode.length == 4) {
        _verifyPasscode();
      }
    }
  }

  void removeDigit() {
    if (state.passcode.isNotEmpty) {
      state = state.copyWith(
        passcode: state.passcode.substring(0, state.passcode.length - 1),
      );
    }
  }

  // Simplified biometric authentication - always returns false for now
  Future<bool> authenticateWithBiometrics() async {
    state = state.copyWith(isVerifying: true);

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      // For now, always return false since local_auth is not available
      return false;
    } catch (e) {
      _showErrorSnackBar('Biometric authentication is not available on this device');
      return false;
    } finally {
      state = state.copyWith(isVerifying: false);
    }
  }

  Future<User?> _loadUserFromStorage() async {
    final userJson = await _secureStorage.read('user');
    if (userJson.isEmpty) return null;
    return User.fromJson(json.decode(userJson));
  }

  Future<void> _verifyPasscode() async {
    state = state.copyWith(isVerifying: true);

    try {
      final storedPasscode = await _secureStorage.read('user_passcode');

      if (state.passcode == storedPasscode) {
        final password = await _secureStorage.read('password');
        final user = await _loadUserFromStorage();

        if (user == null || password.isEmpty) {
          _showErrorSnackBar('Unable to verify your account. Please sign in again.');
          return;
        }

        await _authService.login(email: user.email, password: password);
        await Future.delayed(const Duration(milliseconds: 500));
        appRouter.pushNamed(AppRoute.mainView);
      } else {
        state = state.copyWith(passcode: '');
        _showErrorSnackBar('Wrong passcode. Please try again.');
      }
    } catch (e) {
      state = state.copyWith(passcode: '');
      _showErrorSnackBar('Something went wrong. Please try again.');
    } finally {
      await Future.delayed(const Duration(milliseconds: 500));
      state = state.copyWith(isVerifying: false);
    }
  }

  void _showErrorSnackBar(String message) {
    // Note: This will be called from the viewmodel, so we need to get context from the view
    // For now, we'll store the error message and let the view handle showing it
    state = state.copyWith(errorMessage: message);
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      // Clear stored data
      await _secureStorage.delete('user');
      await _secureStorage.delete('password');
      await _secureStorage.delete('user_passcode');
      
      // Navigate to login (hide back button)
      appRouter.pushNamed(AppRoute.loginView, arguments: false);
    } catch (e) {
      _showErrorSnackBar('Error during logout: ${e.toString()}');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: '');
  }
}

// Provider
final passcodeProvider = StateNotifierProvider<PasscodeNotifier, PasscodeState>((ref) {
  return PasscodeNotifier();
});
