import 'package:shared_preferences/shared_preferences.dart';
import 'package:dayfi/common/constants/storage_keys.dart';
import 'package:dayfi/common/utils/app_logger.dart';

/// Service to track app version changes and handle data migration
class VersionService {
  static const String _versionKey = 'app_version';
  static const String _buildNumberKey = 'app_build_number';
  static const String _currentVersion = '1.0.0'; // Update this when you release new versions
  static const String _currentBuildNumber = '1'; // Update this when you release new builds
  
  final SharedPreferences _sharedPreferences;
  
  VersionService(this._sharedPreferences);
  
  /// Check if this is a new app version and handle data migration
  Future<bool> isNewVersion() async {
    try {
      final storedVersion = _sharedPreferences.getString(_versionKey);
      final storedBuildNumber = _sharedPreferences.getString(_buildNumberKey);
      
      AppLogger.info('Version check - Current: $_currentVersion ($_currentBuildNumber), Stored: $storedVersion ($storedBuildNumber)');
      
      // Check if version or build number has changed
      final isNewVersion = storedVersion != _currentVersion || storedBuildNumber != _currentBuildNumber;
      
      if (isNewVersion) {
        AppLogger.info('New app version detected - clearing user data');
        await _clearUserDataForNewVersion();
        await _updateStoredVersion(_currentVersion, _currentBuildNumber);
      }
      
      return isNewVersion;
    } catch (e) {
      AppLogger.error('Error checking app version: $e');
      return false;
    }
  }
  
  /// Clear user data when app version changes
  Future<void> _clearUserDataForNewVersion() async {
    try {
      // Clear all user-related data from SharedPreferences
      await _sharedPreferences.remove(StorageKeys.userId);
      await _sharedPreferences.remove(StorageKeys.userEmail);
      await _sharedPreferences.remove(StorageKeys.userPhone);
      await _sharedPreferences.remove(StorageKeys.isLoggedIn);
      await _sharedPreferences.remove(StorageKeys.accountBalance);
      await _sharedPreferences.remove(StorageKeys.lastLogin);
      await _sharedPreferences.remove(StorageKeys.biometricEnabled);
      await _sharedPreferences.remove(StorageKeys.hideUserBalance);
      await _sharedPreferences.remove(StorageKeys.faceIDTouchID);
      await _sharedPreferences.remove(StorageKeys.facedIdToSharedPrefKey);
      await _sharedPreferences.remove(StorageKeys.fxInflowSheet);
      await _sharedPreferences.remove(StorageKeys.isFirstTime);
      await _sharedPreferences.remove(StorageKeys.hasSeenWelcome);
      
      AppLogger.info('User data cleared for new app version');
    } catch (e) {
      AppLogger.error('Error clearing user data for new version: $e');
    }
  }
  
  /// Update stored version information
  Future<void> _updateStoredVersion(String version, String buildNumber) async {
    try {
      await _sharedPreferences.setString(_versionKey, version);
      await _sharedPreferences.setString(_buildNumberKey, buildNumber);
      AppLogger.info('Updated stored version to $version ($buildNumber)');
    } catch (e) {
      AppLogger.error('Error updating stored version: $e');
    }
  }
  
  /// Get current app version
  String getCurrentVersion() {
    return _currentVersion;
  }
  
  /// Get current build number
  String getCurrentBuildNumber() {
    return _currentBuildNumber;
  }
}
