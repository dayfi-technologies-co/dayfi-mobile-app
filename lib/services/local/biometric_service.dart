import 'package:local_auth/local_auth.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'dart:io';

class BiometricService {
  static final LocalAuthentication _localAuth = LocalAuthentication();

  /// Check if biometric authentication is available on the device
  static Future<bool> isBiometricAvailable() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      
      AppLogger.info('Biometric available: $isAvailable, Device supported: $isDeviceSupported');
      
      // Check if biometrics are actually enrolled
      final List<BiometricType> availableBiometrics = await getAvailableBiometrics();
      final bool hasEnrolledBiometrics = availableBiometrics.isNotEmpty;
      
      AppLogger.info('Has enrolled biometrics: $hasEnrolledBiometrics, Available types: $availableBiometrics');
      
      return isAvailable && isDeviceSupported && hasEnrolledBiometrics;
    } catch (e) {
      AppLogger.error('Error checking biometric availability: $e');
      return false;
    }
  }

  /// Get available biometric types
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();
      AppLogger.info('Available biometrics: $availableBiometrics');
      return availableBiometrics;
    } catch (e) {
      AppLogger.error('Error getting available biometrics: $e');
      return [];
    }
  }

  /// Authenticate using biometrics
  static Future<bool> authenticate({
    String reason = 'Please authenticate to continue',
    String? cancelButton,
    String? goToSettingsButton,
    String? goToSettingsDescription,
  }) async {
    try {
      final bool isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        AppLogger.error('Biometric authentication not available');
        return false;
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      AppLogger.info('Biometric authentication result: $didAuthenticate');
      return didAuthenticate;
    } catch (e) {
      AppLogger.error('Error during biometric authentication: $e');
      return false;
    }
  }

  /// Check if biometrics are enrolled on the device
  static Future<bool> hasEnrolledBiometrics() async {
    try {
      final bool isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;

      final List<BiometricType> availableBiometrics = await getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      AppLogger.error('Error checking enrolled biometrics: $e');
      return false;
    }
  }

  /// Get biometric type name for display
  static String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.iris:
        return 'Iris';
      case BiometricType.strong:
        return 'Strong Biometric';
      case BiometricType.weak:
        return 'Weak Biometric';
    }
  }

  /// Get primary biometric type for display
  static Future<String> getPrimaryBiometricType() async {
    try {
      final List<BiometricType> availableBiometrics = await getAvailableBiometrics();
      if (availableBiometrics.isEmpty) return 'Biometric';

      // Prioritize face over fingerprint
      if (availableBiometrics.contains(BiometricType.face)) {
        return 'Face ID';
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        return 'Fingerprint';
      } else if (availableBiometrics.contains(BiometricType.iris)) {
        return 'Iris';
      } else {
        return getBiometricTypeName(availableBiometrics.first);
      }
    } catch (e) {
      AppLogger.error('Error getting primary biometric type: $e');
      return 'Biometric';
    }
  }

  /// Get all available biometric types for display
  static Future<List<String>> getAllAvailableBiometricTypes() async {
    try {
      final List<BiometricType> availableBiometrics = await getAvailableBiometrics();
      return availableBiometrics.map((type) => getBiometricTypeName(type)).toList();
    } catch (e) {
      AppLogger.error('Error getting all biometric types: $e');
      return [];
    }
  }

  /// Get comprehensive biometric description
  static Future<String> getBiometricDescription() async {
    try {
      final List<BiometricType> availableBiometrics = await getAvailableBiometrics();
      if (availableBiometrics.isEmpty) return 'Biometric authentication';

      if (availableBiometrics.length == 1) {
        return getBiometricTypeName(availableBiometrics.first);
      } else if (availableBiometrics.contains(BiometricType.face) && 
                 availableBiometrics.contains(BiometricType.fingerprint)) {
        return 'Face ID or Fingerprint';
      } else {
        return availableBiometrics.map((type) => getBiometricTypeName(type)).join(' or ');
      }
    } catch (e) {
      AppLogger.error('Error getting biometric description: $e');
      return 'Biometric authentication';
    }
  }

  /// Check if both face ID and fingerprint are available
  static Future<bool> hasBothFaceAndFingerprint() async {
    try {
      final List<BiometricType> availableBiometrics = await getAvailableBiometrics();
      return availableBiometrics.contains(BiometricType.face) && 
             availableBiometrics.contains(BiometricType.fingerprint);
    } catch (e) {
      AppLogger.error('Error checking for both face and fingerprint: $e');
      return false;
    }
  }

  /// Get platform-specific biometric information
  static Future<Map<String, dynamic>> getPlatformInfo() async {
    try {
      final bool isAvailable = await isBiometricAvailable();
      final bool isEnrolled = await hasEnrolledBiometrics();
      final List<BiometricType> availableTypes = await getAvailableBiometrics();
      final String description = await getBiometricDescription();
      final bool hasBoth = await hasBothFaceAndFingerprint();

      return {
        'isAvailable': isAvailable,
        'isEnrolled': isEnrolled,
        'availableTypes': availableTypes.map((e) => e.toString()).toList(),
        'description': description,
        'hasBothFaceAndFingerprint': hasBoth,
        'platform': Platform.operatingSystem,
        'isIOS': Platform.isIOS,
        'isAndroid': Platform.isAndroid,
      };
    } catch (e) {
      AppLogger.error('Error getting platform info: $e');
      return {
        'isAvailable': false,
        'isEnrolled': false,
        'availableTypes': <String>[],
        'description': 'Biometric authentication',
        'hasBothFaceAndFingerprint': false,
        'platform': Platform.operatingSystem,
        'isIOS': Platform.isIOS,
        'isAndroid': Platform.isAndroid,
      };
    }
  }

  /// Check if Face ID is specifically available (iOS only)
  static Future<bool> isFaceIDAvailable() async {
    if (!Platform.isIOS) return false;
    
    try {
      final List<BiometricType> availableBiometrics = await getAvailableBiometrics();
      return availableBiometrics.contains(BiometricType.face);
    } catch (e) {
      AppLogger.error('Error checking Face ID availability: $e');
      return false;
    }
  }

  /// Check if Fingerprint is specifically available
  static Future<bool> isFingerprintAvailable() async {
    try {
      final List<BiometricType> availableBiometrics = await getAvailableBiometrics();
      return availableBiometrics.contains(BiometricType.fingerprint);
    } catch (e) {
      AppLogger.error('Error checking Fingerprint availability: $e');
      return false;
    }
  }

  /// Get device-specific biometric capabilities
  static Future<String> getDeviceCapabilities() async {
    try {
      final Map<String, dynamic> info = await getPlatformInfo();
      
      if (!info['isAvailable']) {
        return 'Biometric authentication not supported on this device';
      }
      
      if (!info['isEnrolled']) {
        return 'No biometric data enrolled. Please set up ${info['description']} in device settings.';
      }
      
      final List<String> types = List<String>.from(info['availableTypes']);
      if (types.isEmpty) {
        return 'No biometric types available';
      }
      
      if (Platform.isIOS) {
        if (types.contains('BiometricType.face') && types.contains('BiometricType.fingerprint')) {
          return 'Face ID and Touch ID available';
        } else if (types.contains('BiometricType.face')) {
          return 'Face ID available';
        } else if (types.contains('BiometricType.fingerprint')) {
          return 'Touch ID available';
        }
      } else if (Platform.isAndroid) {
        if (types.contains('BiometricType.fingerprint')) {
          return 'Fingerprint authentication available';
        } else if (types.contains('BiometricType.face')) {
          return 'Face authentication available';
        }
      }
      
      return 'Biometric authentication available';
    } catch (e) {
      AppLogger.error('Error getting device capabilities: $e');
      return 'Unable to determine biometric capabilities';
    }
  }

  /// Enhanced authentication with platform-specific messaging
  static Future<bool> authenticateWithPlatformMessaging({
    String? customReason,
  }) async {
    try {
      final bool isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        AppLogger.error('Biometric authentication not available');
        return false;
      }

      String reason = customReason ?? 'Authenticate to continue';
      
      // Platform-specific messaging
      if (Platform.isIOS) {
        final bool hasFaceID = await isFaceIDAvailable();
        final bool hasFingerprint = await isFingerprintAvailable();
        
        if (hasFaceID && hasFingerprint) {
          reason = customReason ?? 'Use Face ID or Touch ID to continue';
        } else if (hasFaceID) {
          reason = customReason ?? 'Use Face ID to continue';
        } else if (hasFingerprint) {
          reason = customReason ?? 'Use Touch ID to continue';
        }
      } else if (Platform.isAndroid) {
        final bool hasFingerprint = await isFingerprintAvailable();
        if (hasFingerprint) {
          reason = customReason ?? 'Use your fingerprint to continue';
        }
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      AppLogger.info('Platform-specific biometric authentication result: $didAuthenticate');
      return didAuthenticate;
    } catch (e) {
      AppLogger.error('Error during platform-specific biometric authentication: $e');
      return false;
    }
  }
}
