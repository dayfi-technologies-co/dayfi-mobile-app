import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:dayfi/app/app.locator.dart';
import 'package:dayfi/app/app.router.dart';
import 'package:dayfi/data/models/user_model.dart';
import 'package:dayfi/data/storage/secure_storage_service.dart';
import 'package:dayfi/services/api/auth_api_service.dart';
import 'package:dayfi/ui/components/top_snack_bar.dart';
import 'package:dayfi/ui/views/main/main_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class PasscodeViewModel extends BaseViewModel {
  final SecureStorageService _secureStorage = locator<SecureStorageService>();
  final NavigationService navigationService = locator<NavigationService>();
  final AuthApiService _apiService = AuthApiService();
  final LocalAuthentication _localAuth = LocalAuthentication();

  String _passcode = '';
  bool _isVerifying = false;
  bool _biometricAvailable = false;
  bool _isLoading = false;

  User? user;

  bool get isLoading => _isLoading;
  bool get isBiometricAvailable => _biometricAvailable;
  String get passcode => _passcode;
  bool get isVerifying => _isVerifying;

  Future<void> loadUser() async {
    final userJson = await _secureStorage.read('user');
    if (userJson != null) {
      user = User.fromJson(json.decode(userJson));
      notifyListeners();
    }
    await _checkBiometricAvailability();
  }

  void addDigit(String digit) {
    if (_passcode.length < 6) {
      _passcode += digit;
      notifyListeners();
      if (_passcode.length == 6) {
        _verifyPasscode();
      }
    }
  }

  void removeDigit() {
    if (_passcode.isNotEmpty) {
      _passcode = _passcode.substring(0, _passcode.length - 1);
      notifyListeners();
    }
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      _biometricAvailable = await _localAuth.canCheckBiometrics &&
          await _localAuth.isDeviceSupported();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error checking biometric availability: $e');
      }
      _biometricAvailable = false;
      notifyListeners();
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    _isVerifying = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 3));
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access the app',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (isAuthenticated) {
        await Future.delayed(const Duration(seconds: 3));
        navigationService.clearStackAndShowView(MainView());
      }

      return isAuthenticated;
    } catch (e) {
      TopSnackbar.show(
        navigationService.navigatorKey!.currentContext!,
        message: 'Biometric authentication error: ${e.toString()}',
        isError: true,
      );
      return false;
    } finally {
      _isVerifying = false;
      notifyListeners();
    }
  }

  Future<User?> _loadUserFromStorage() async {
    final userJson = await _secureStorage.read('user');
    if (userJson == null) return null;
    return User.fromJson(json.decode(userJson));
  }

  Future<void> _verifyPasscode() async {
    _isVerifying = true;
    notifyListeners();

    try {
      final storedPasscode = await _secureStorage.read('user_passcode');

      if (_passcode == storedPasscode) {
        final password = await _secureStorage.read('password');
        final user = await _loadUserFromStorage();

        if (user == null || password == null) {
          _showErrorSnackBar('User data not found. Please login again.');
          return;
        }

        await _apiService.login(email: user.email, password: password);
        await Future.delayed(const Duration(milliseconds: 500));
        navigationService.clearStackAndShowView(MainView());
      } else {
        _passcode = '';
        _showErrorSnackBar('Incorrect passcode. Please try again.');
      }
    } catch (e) {
      _passcode = '';
      _showErrorSnackBar('Error verifying passcode.');
    } finally {
      await Future.delayed(const Duration(milliseconds: 500));
      _isVerifying = false;
      notifyListeners();
    }
  }

  void _showErrorSnackBar(String message) {
    final context = navigationService.navigatorKey!.currentContext!;
    TopSnackbar.show(
      context,
      message: message,
      isError: true,
    );
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    try {
      navigationService.clearStackAndShow(Routes.loginView);
    } catch (e) {
      final context = navigationService.navigatorKey!.currentContext!;
      TopSnackbar.show(
        context,
        message: 'Error during logout: ${e.toString()}',
        isError: true,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
