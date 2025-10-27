import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/services/local/secure_storage.dart';
import 'package:dayfi/services/remote/auth_service.dart';
import 'package:dayfi/services/local/biometric_service.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/models/user_model.dart';
import 'package:dayfi/common/constants/storage_keys.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/services/data_clearing_service.dart';

class PasscodeState {
  final String passcode;
  final bool isVerifying;
  final bool isBiometricAvailable;
  final bool isLoading;
  final User? user;
  final String errorMessage;
  final String biometricType;

  const PasscodeState({
    this.passcode = '',
    this.isVerifying = false,
    this.isBiometricAvailable = false,
    this.isLoading = false,
    this.user,
    this.errorMessage = '',
    this.biometricType = '',
  });

  bool get hasFaceId => isBiometricAvailable && biometricType.contains('Face');
  bool get hasFingerprint => isBiometricAvailable && biometricType.contains('Fingerprint');

  PasscodeState copyWith({
    String? passcode,
    bool? isVerifying,
    bool? isBiometricAvailable,
    bool? isLoading,
    User? user,
    String? errorMessage,
    String? biometricType,
  }) {
    return PasscodeState(
      passcode: passcode ?? this.passcode,
      isVerifying: isVerifying ?? this.isVerifying,
      isBiometricAvailable: isBiometricAvailable ?? this.isBiometricAvailable,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      biometricType: biometricType ?? this.biometricType,
    );
  }
}

class PasscodeNotifier extends StateNotifier<PasscodeState> {
  final SecureStorageService _secureStorage = locator<SecureStorageService>();
  final AuthService _authService = locator<AuthService>();

  PasscodeNotifier() : super(const PasscodeState());

  Future<void> loadUser() async {
    try {
      // First verify that we have a valid token before loading user data
      final token = await _secureStorage.read(StorageKeys.token);
      if (token.isEmpty) {
        AppLogger.warning('No token found, cannot load user data');
        return;
      }

      final userJson = await _secureStorage.read(StorageKeys.user);
      if (userJson.isNotEmpty) {
        final user = User.fromJson(json.decode(userJson));
        state = state.copyWith(user: user);
        AppLogger.info('User data loaded successfully: ${user.firstName}');
      } else {
        AppLogger.warning('No user data found in storage');
        // If we have a token but no user data, this might be an inconsistent state
        // We could trigger a re-authentication here if needed
      }
      
      // Check if biometric authentication is available and enabled
      await _checkBiometricAvailability();
    } catch (e) {
      AppLogger.error('Error loading user: $e');
      // Error loading user - handled by UI state
    }
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      // Check if biometrics are available on device
      final bool isAvailable = await BiometricService.isBiometricAvailable();
      
      if (isAvailable) {
        // Check if biometrics are enabled for this app
        final String? biometricEnabled = await _secureStorage.read('biometric_enabled');
        final bool isEnabled = biometricEnabled == 'true';
        
        if (isEnabled) {
          // Get biometric type for display
          final String biometricType = await BiometricService.getPrimaryBiometricType();
          
          state = state.copyWith(
            isBiometricAvailable: true,
            biometricType: biometricType,
          );
          
          AppLogger.info('Biometric authentication available: $biometricType');
        } else {
          state = state.copyWith(isBiometricAvailable: false);
          AppLogger.info('Biometric authentication not enabled for this app');
        }
      } else {
        state = state.copyWith(isBiometricAvailable: false);
        AppLogger.info('Biometric authentication not available on device');
      }
    } catch (e) {
      AppLogger.error('Error checking biometric availability: $e');
      state = state.copyWith(isBiometricAvailable: false);
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

  Future<bool> authenticateWithBiometrics() async {
    if (!state.isBiometricAvailable) {
      _showErrorSnackBar('Biometric authentication is not available');
      return false;
    }

    state = state.copyWith(isVerifying: true);

    try {
      AppLogger.info('Starting biometric authentication...');
      
      // Authenticate using biometrics with platform-specific messaging
      final bool authenticated = await BiometricService.authenticateWithPlatformMessaging(
        customReason: 'Authenticate to access your account',
      );

      if (authenticated) {
        AppLogger.info('Biometric authentication successful');
        
        // If biometric authentication succeeds, proceed with login
        await _authenticateAndNavigate();
        return true;
      } else {
        AppLogger.info('Biometric authentication failed or was cancelled');
        _showErrorSnackBar('Biometric authentication failed. Please use your passcode.');
        return false;
      }
    } catch (e) {
      AppLogger.error('Error during biometric authentication: $e');
      _showErrorSnackBar('Biometric authentication error. Please use your passcode.');
      return false;
    } finally {
      state = state.copyWith(isVerifying: false);
    }
  }

  // Future<User?> _loadUserFromStorage() async {
  //   final userJson = await _secureStorage.read('user');
  //   if (userJson.isEmpty) return null;
  //   return User.fromJson(json.decode(userJson));
  // }

  Future<void> _verifyPasscode() async {
    state = state.copyWith(isVerifying: true);

    try {
      final storedPasscode = await _secureStorage.read(StorageKeys.passcode);

      if (state.passcode == storedPasscode) {
        // Passcode is correct, now re-authenticate to get fresh JWT token
        await Future.delayed(const Duration(milliseconds: 500));
        await _authenticateAndNavigate();
      } else {
        state = state.copyWith(passcode: '');
        _showErrorSnackBar('Wrong passcode. Please try again.');
      }
    } catch (e) {
      AppLogger.error('Error verifying passcode: $e');
      state = state.copyWith(passcode: '');
      _showErrorSnackBar('Something went wrong. Please try again.');
    } finally {
      await Future.delayed(const Duration(milliseconds: 500));
      state = state.copyWith(isVerifying: false);
    }
  }

  /// Shared authentication and navigation logic for both passcode and biometric auth
  Future<void> _authenticateAndNavigate() async {
    try {
      // Retrieve saved login credentials
      final savedEmail = await _secureStorage.read(StorageKeys.email);
      final savedPassword = await _secureStorage.read(StorageKeys.password);

      if (savedEmail.isNotEmpty && savedPassword.isNotEmpty) {
        try {
          // Re-authenticate to get fresh JWT token
          final response = await _authService.login(
            email: savedEmail,
            password: savedPassword,
          );

          if (response.statusCode == 200) {
            // Save fresh token
            await _secureStorage.write(
              StorageKeys.token,
              response.data?.token ?? '',
            );

            // Save updated user data if available
            if (response.data?.user != null) {
              await _secureStorage.write(
                StorageKeys.user,
                json.encode(response.data!.user!.toJson()),
              );
              // Update the state with the fresh user data
              state = state.copyWith(user: response.data!.user!);
              AppLogger.info('User data updated after re-authentication: ${response.data!.user!.firstName}');
            }

            // Navigate to main view and clear stack
            appRouter.pushMainAndClearStack();
          } else {
            // If re-authentication fails, clear credentials and show error
            await _clearStoredCredentials();
            _showErrorSnackBar('Session expired. Please login again.');
            appRouter.pushLoginAndClearStack();
          }
        } catch (e) {
          AppLogger.error('Error during re-authentication: $e');
          // If re-authentication fails, clear credentials and show error
          await _clearStoredCredentials();
          _showErrorSnackBar('Session expired. Please login again.');
          appRouter.pushLoginAndClearStack();
        }
      } else {
        // No saved credentials found, redirect to login
        _showErrorSnackBar('Please login again.');
        appRouter.pushLoginAndClearStack();
      }
    } catch (e) {
      AppLogger.error('Error in authentication and navigation: $e');
      _showErrorSnackBar('Login failed. Please try again.');
    }
  }

  void _showErrorSnackBar(String message) {
    // Note: This will be called from the viewmodel, so we need to get context from the view
    // For now, we'll store the error message and let the view handle showing it
    state = state.copyWith(errorMessage: message);
  }

  Future<void> _clearStoredCredentials() async {
    await _secureStorage.delete(StorageKeys.email);
    await _secureStorage.delete(StorageKeys.password);
    await _secureStorage.delete(StorageKeys.token);
    await _secureStorage.delete(StorageKeys.user);
  }

  Future<void> logout(WidgetRef ref) async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true);
    try {
      // Use comprehensive data clearing service
      final dataClearingService = DataClearingService();
      await dataClearingService.clearAllUserData(ref);

      // Navigate to login and clear stack (hide back button)
      appRouter.pushLoginAndClearStack(arguments: false);
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error during logout: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: '');
  }

  void resetForm() {
    state = const PasscodeState();
  }
}

// Provider
final passcodeProvider = StateNotifierProvider<PasscodeNotifier, PasscodeState>(
  (ref) {
    return PasscodeNotifier();
  },
);
