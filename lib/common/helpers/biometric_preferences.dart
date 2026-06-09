import 'dart:convert';

import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/constants/storage_keys.dart';
import 'package:dayfi/services/local/secure_storage.dart';

/// Keeps biometric flags aligned across secure storage and the cached user map.
class BiometricPreferences {
  static final SecureStorageService _storage = locator<SecureStorageService>();

  static Future<bool> isEnabled() async {
    final flag = await _storage.read('biometric_enabled');
    if (flag == 'true') return true;

    final user = await localCache.getUser();
    if (user['biometric_enabled'] == true) return true;
    if (user['is_biometrics_setup'] == true) return true;
    return false;
  }

  /// After a fresh login, show the biometric opt-in once on the next main entry.
  static Future<void> schedulePostLoginBiometricPrompt() async {
    await _storage.write(StorageKeys.pendingBiometricPrompt, 'true');
    await _storage.delete(StorageKeys.biometricSetupCompleted);
  }

  /// Returns true only once after [schedulePostLoginBiometricPrompt] (passcode → main).
  static Future<bool> consumePostLoginBiometricPrompt() async {
    final pending = await _storage.read(StorageKeys.pendingBiometricPrompt);
    if (pending != 'true') return false;
    await _storage.delete(StorageKeys.pendingBiometricPrompt);
    return true;
  }

  /// User skipped the opt-in — do not show the home dialog again.
  static Future<void> markPromptDismissed() async {
    await _storage.write(StorageKeys.biometricSetupCompleted, 'true');
    await setEnabled(false);
  }

  static Future<void> setEnabled(bool enabled) async {
    await _storage.write('biometric_enabled', enabled ? 'true' : 'false');
    if (enabled) {
      await _storage.write(StorageKeys.biometricSetupCompleted, 'true');
    }

    final userJson = await _storage.read(StorageKeys.user);
    if (userJson.isEmpty) return;

    final userMap = jsonDecode(userJson) as Map<String, dynamic>;
    userMap['is_biometrics_setup'] = enabled;
    userMap['biometric_enabled'] = enabled;
    await _storage.write(StorageKeys.user, jsonEncode(userMap));
    await localCache.saveToLocalCache(
      key: 'biometric_enabled',
      value: enabled.toString(),
    );
  }
}
