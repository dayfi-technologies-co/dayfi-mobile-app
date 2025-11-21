import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/services/local/secure_storage.dart';
import 'package:dayfi/services/remote/auth_service.dart';
import 'package:dayfi/services/local/biometric_service.dart';
import 'package:dayfi/models/user_model.dart';
import 'package:dayfi/common/constants/storage_keys.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/services/data_clearing_service.dart';

class PasscodeState {
  final String passcode;
  final bool isVerifying;
  final bool isBiometricAvailable;
  final bool isBiometricEnabled;
  final bool isDeviceBiometricAvailable;
  final bool isLoading;
  final User? user;
  final String errorMessage;
  final String biometricType;

  const PasscodeState({
    this.passcode = '',
    this.isVerifying = false,
    this.isBiometricAvailable = false,
    this.isBiometricEnabled = false,
    this.isDeviceBiometricAvailable = false,
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
    bool? isBiometricEnabled,
    bool? isDeviceBiometricAvailable,
    bool? isLoading,
    User? user,
    String? errorMessage,
    String? biometricType,
  }) {
    return PasscodeState(
      passcode: passcode ?? this.passcode,
      isVerifying: isVerifying ?? this.isVerifying,
      isBiometricAvailable: isBiometricAvailable ?? this.isBiometricAvailable,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      isDeviceBiometricAvailable: isDeviceBiometricAvailable ?? this.isDeviceBiometricAvailable,
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
      
      // Auto-trigger biometric authentication if enabled
      await _autoTriggerBiometricIfEnabled();
    } catch (e) {
      AppLogger.error('Error loading user: $e');
      // Error loading user - handled by UI state
    }
  }

  /// Automatically trigger biometric authentication if it's enabled
  Future<void> _autoTriggerBiometricIfEnabled() async {
    try {
      // Only auto-trigger if biometrics are available and enabled
      if (state.isBiometricAvailable && state.isBiometricEnabled) {
        AppLogger.info('Auto-triggering biometric authentication...');
        
        // Small delay to ensure UI is ready
        await Future.delayed(const Duration(milliseconds: 300));
        
        // Trigger biometric authentication
        final bool authenticated = await BiometricService.authenticateWithPlatformMessaging(
          customReason: 'Authenticate to access your account',
        );

        if (authenticated) {
          AppLogger.info('Auto biometric authentication successful');
          await _authenticateAndNavigate();
        } else {
          AppLogger.info('Auto biometric authentication failed or cancelled - user can use passcode');
        }
      }
    } catch (e) {
      AppLogger.error('Error during auto biometric trigger: $e');
      // Silently fail - user can still use passcode
    }
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      // Check if biometrics are available on device
      final bool isDeviceAvailable = await BiometricService.isBiometricAvailable();
      
      state = state.copyWith(isDeviceBiometricAvailable: isDeviceAvailable);
      
      if (isDeviceAvailable) {
        // Check if biometrics are enabled for this app
        final String biometricEnabled = await _secureStorage.read('biometric_enabled');
        final bool isEnabled = biometricEnabled == 'true';
        
        state = state.copyWith(isBiometricEnabled: isEnabled);
        
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
        state = state.copyWith(
          isBiometricAvailable: false,
          isBiometricEnabled: false,
        );
        AppLogger.info('Biometric authentication not available on device');
      }
    } catch (e) {
      AppLogger.error('Error checking biometric availability: $e');
      state = state.copyWith(
        isBiometricAvailable: false,
        isDeviceBiometricAvailable: false,
        isBiometricEnabled: false,
      );
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
    // Check device availability first
    if (!state.isDeviceBiometricAvailable) {
      _showErrorSnackBar('Biometric authentication is not available on this device');
      return false;
    }

    // Check if enabled for this app
    if (!state.isBiometricEnabled) {
      _showErrorSnackBar('Biometric authentication is not enabled. Please enable it in settings.');
      return false;
    }

    if (!state.isBiometricAvailable) {
      _showErrorSnackBar('Biometric authentication is not available');
      return false;
    }

    // Set loading state immediately when biometric prompt appears
    state = state.copyWith(isVerifying: true);
    
    // Give UI a moment to update before showing biometric prompt
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      AppLogger.info('Starting manual biometric authentication...');
      
      // Authenticate using biometrics with platform-specific messaging
      final bool authenticated = await BiometricService.authenticateWithPlatformMessaging(
        customReason: 'Authenticate to access your account',
      );

      if (authenticated) {
        AppLogger.info('Manual biometric authentication successful');
        
        // If biometric authentication succeeds, proceed with login
        await _authenticateAndNavigate();
        return true;
      } else {
        AppLogger.info('Manual biometric authentication failed or was cancelled');
        state = state.copyWith(isVerifying: false);
        // Don't show error for cancellation - user can use passcode
        return false;
      }
    } catch (e) {
      AppLogger.error('Error during manual biometric authentication: $e');
      state = state.copyWith(isVerifying: false);
      _showErrorSnackBar('Biometric authentication error. Please use your passcode.');
      return false;
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
              // Mark biometric as setup if user authenticated with biometrics
              final userData = response.data!.user!.toJson();
              userData['is_biometrics_setup'] = true;
              
              await _secureStorage.write(
                StorageKeys.user,
                json.encode(userData),
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
      // Disable biometrics on backend before logout for security
      await _disableBiometricsBeforeLogout();
      
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

  /// Disable biometrics on backend before logout for security
  Future<void> _disableBiometricsBeforeLogout() async {
    try {
      AppLogger.info('Disabling biometrics before logout...');
      
      // Check if biometrics are currently enabled
      final biometricEnabled = await _secureStorage.read('biometric_enabled');
      
      if (biometricEnabled == 'true') {
        // Get user ID from stored user data
        final userJson = await _secureStorage.read(StorageKeys.user);
        if (userJson.isNotEmpty) {
          final userMap = json.decode(userJson) as Map<String, dynamic>;
          final userId = userMap['_id'] as String?;
          
          if (userId != null && userId.isNotEmpty) {
            // Call backend API to disable biometrics
            await _authService.updateProfileBiometrics(
              userId: userId,
              isBiometricsSetup: false,
            );
            AppLogger.info('Biometrics disabled on backend before logout');
          }
        }
      }
    } catch (e) {
      // Don't fail logout if biometric disable fails - just log it
      AppLogger.warning('Failed to disable biometrics before logout: $e');
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
