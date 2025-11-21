import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/services/local/biometric_service.dart';
import 'package:dayfi/services/local/secure_storage.dart';
import 'package:dayfi/services/remote/auth_service.dart';
import 'package:dayfi/common/constants/storage_keys.dart';

class BiometricSetupState {
  final bool isAvailable;
  final bool isEnrolled;
  final bool isEnabled;
  final bool isBusy;
  final String biometricType;
  final String biometricDescription;
  final bool hasBothFaceAndFingerprint;
  final String errorMessage;

  const BiometricSetupState({
    this.isAvailable = false,
    this.isEnrolled = false,
    this.isEnabled = false,
    this.isBusy = false,
    this.biometricType = 'Biometric',
    this.biometricDescription = 'Biometric Authentication',
    this.hasBothFaceAndFingerprint = false,
    this.errorMessage = '',
  });

  BiometricSetupState copyWith({
    bool? isAvailable,
    bool? isEnrolled,
    bool? isEnabled,
    bool? isBusy,
    String? biometricType,
    String? biometricDescription,
    bool? hasBothFaceAndFingerprint,
    String? errorMessage,
  }) {
    return BiometricSetupState(
      isAvailable: isAvailable ?? this.isAvailable,
      isEnrolled: isEnrolled ?? this.isEnrolled,
      isEnabled: isEnabled ?? this.isEnabled,
      isBusy: isBusy ?? this.isBusy,
      biometricType: biometricType ?? this.biometricType,
      biometricDescription: biometricDescription ?? this.biometricDescription,
      hasBothFaceAndFingerprint: hasBothFaceAndFingerprint ?? this.hasBothFaceAndFingerprint,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class BiometricSetupNotifier extends StateNotifier<BiometricSetupState> {
  final SecureStorageService _secureStorage = locator<SecureStorageService>();
  final AuthService _authService = locator<AuthService>();

  BiometricSetupNotifier() : super(const BiometricSetupState()) {
    _initializeBiometrics();
  }

  Future<void> _initializeBiometrics() async {
    state = state.copyWith(isBusy: true, errorMessage: '');

    try {
      AppLogger.info('Initializing biometric setup...');

      // Check if biometrics are available
      final bool isAvailable = await BiometricService.isBiometricAvailable();
      AppLogger.info('Biometric available: $isAvailable');

      if (!isAvailable) {
        state = state.copyWith(
          isAvailable: false,
          isBusy: false,
          errorMessage: 'Biometric authentication is not available on this device',
        );
        return;
      }

      // Check if biometrics are enrolled
      final bool isEnrolled = await BiometricService.hasEnrolledBiometrics();
      AppLogger.info('Biometric enrolled: $isEnrolled');

      // Get biometric type and description
      final String biometricType = await BiometricService.getPrimaryBiometricType();
      final String biometricDescription = await BiometricService.getBiometricDescription();
      final bool hasBoth = await BiometricService.hasBothFaceAndFingerprint();
      final String deviceCapabilities = await BiometricService.getDeviceCapabilities();
      final Map<String, dynamic> platformInfo = await BiometricService.getPlatformInfo();
      
      AppLogger.info('Primary biometric type: $biometricType');
      AppLogger.info('Biometric description: $biometricDescription');
      AppLogger.info('Has both face and fingerprint: $hasBoth');
      AppLogger.info('Device capabilities: $deviceCapabilities');
      AppLogger.info('Platform info: $platformInfo');

      // Check if biometrics are already enabled for this app
      final String biometricEnabled = await _secureStorage.read('biometric_enabled');
      final bool isEnabled = biometricEnabled == 'true';

      state = state.copyWith(
        isAvailable: isAvailable,
        isEnrolled: isEnrolled,
        isEnabled: isEnabled,
        isBusy: false,
        biometricType: biometricType,
        biometricDescription: biometricDescription,
        hasBothFaceAndFingerprint: hasBoth,
        errorMessage: isAvailable && isEnrolled 
            ? '' 
            : isAvailable && !isEnrolled
                ? 'Please set up $biometricDescription in your device settings first'
                : 'Biometric authentication is not available on this device',
      );

      AppLogger.info('Biometric setup initialized - Available: $isAvailable, Enrolled: $isEnrolled, Enabled: $isEnabled');
    } catch (e) {
      AppLogger.error('Error initializing biometrics: $e');
      state = state.copyWith(
        isBusy: false,
        errorMessage: 'Failed to initialize biometric authentication',
      );
    }
  }

  Future<void> enableBiometrics(BuildContext context) async {
    if (!state.isAvailable || !state.isEnrolled) {
      TopSnackbar.show(
        context,
        message: state.errorMessage.isNotEmpty ? state.errorMessage : 'Biometric authentication is not available',
        isError: true,
      );
      return;
    }

    state = state.copyWith(isBusy: true, errorMessage: '');

    try {
      AppLogger.info('Enabling biometric authentication...');

      // Authenticate with biometrics using platform-specific messaging
      final bool authenticated = await BiometricService.authenticateWithPlatformMessaging(
        customReason: 'Enable ${state.biometricDescription} for secure access to your account',
      );

      if (authenticated) {
        try {
          // Get current user id
          final userJson = await _secureStorage.read(StorageKeys.user);
          String? userId;
          if (userJson.isNotEmpty) {
            final parsed = jsonDecode(userJson);
            if (parsed is Map<String, dynamic> && parsed['user_id'] is String) {
              userId = parsed['user_id'] as String;
            }
          }

          if (userId != null && userId.isNotEmpty) {
            // Update profile to set biometrics flag via Edit Profile API
            await _authService.updateProfileBiometrics(
              userId: userId,
              isBiometricsSetup: true,
            );
            AppLogger.info('Biometric status updated on profile successfully');
          } else {
            AppLogger.error('Unable to determine userId for biometrics update');
          }
        } catch (e) {
          AppLogger.error('Failed to update biometric status on profile: $e');
          // Continue with local setup even if backend fails
        }

        // Save biometric preference locally
        await _secureStorage.write('biometric_enabled', 'true');
        // Mark biometric setup as completed
        await _secureStorage.write(StorageKeys.biometricSetupCompleted, 'true');
        
        AppLogger.info('Biometric authentication enabled successfully');
        
        state = state.copyWith(
          isEnabled: true,
          isBusy: false,
        );

        TopSnackbar.show(
          context,
          message: '${state.biometricDescription} enabled successfully!',
          isError: false,
        );

        // Navigate to main view after a short delay
        await Future.delayed(const Duration(milliseconds: 1500));
        appRouter.pushNamed(AppRoute.mainView);
      } else {
        AppLogger.info('Biometric authentication was cancelled or failed');
        state = state.copyWith(
          isBusy: false,
          errorMessage: 'Authentication was cancelled',
        );
      }
    } catch (e) {
      AppLogger.error('Error enabling biometrics: $e');
      state = state.copyWith(
        isBusy: false,
        errorMessage: 'Failed to enable biometric authentication',
      );
      
      TopSnackbar.show(
        context,
        message: 'Failed to enable biometric authentication. Please try again.',
        isError: true,
      );
    }
  }

  Future<void> skipBiometrics(BuildContext context) async {
    try {
      AppLogger.info('Skipping biometric setup...');
      state = state.copyWith(isBusy: true);
      
      try {
        // Get current user id
        final userJson = await _secureStorage.read(StorageKeys.user);
        String? userId;
        if (userJson.isNotEmpty) {
          final parsed = jsonDecode(userJson);
          if (parsed is Map<String, dynamic> && parsed['user_id'] is String) {
            userId = parsed['user_id'] as String;
          }
        }

        if (userId != null && userId.isNotEmpty) {
          // Update backend to mark biometrics as not setup
          await _authService.updateProfileBiometrics(
            userId: userId,
            isBiometricsSetup: false,
          );
          AppLogger.info('Biometric skip status updated on backend successfully');
        }
        
        // Save preference to skip biometrics locally
        await _secureStorage.write('biometric_enabled', 'false');
      } catch (e) {
        AppLogger.error('Error updating biometric skip status: $e');
        // Continue even if backend fails
      }
      
      state = state.copyWith(isEnabled: false, isBusy: false);
      
      TopSnackbar.show(
        context,
        message: 'You can enable ${state.biometricDescription} later in settings',
        isError: false,
      );
      // Intentionally do not navigate here; the caller (dialog) handles navigation after showing loader
    } catch (e) {
      AppLogger.error('Error skipping biometrics: $e');
      state = state.copyWith(isBusy: false);
      TopSnackbar.show(
        context,
        message: 'An error occurred. Please try again.',
        isError: true,
      );
    }
  }

  Future<void> retrySetup() async {
    await _initializeBiometrics();
  }
}

// Provider
final biometricSetupProvider = StateNotifierProvider<BiometricSetupNotifier, BiometricSetupState>((ref) {
  return BiometricSetupNotifier();
});
