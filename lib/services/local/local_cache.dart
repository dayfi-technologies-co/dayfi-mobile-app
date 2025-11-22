import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dayfi/services/local/secure_storage.dart';
import 'package:dayfi/common/constants/storage_keys.dart';
import 'package:dayfi/common/utils/app_logger.dart';

class LocalCache {
  late SecureStorageService storage;
  late SharedPreferences sharedPreferences;

  LocalCache({required this.storage, required this.sharedPreferences});

  Future<void> deleteToken() async {
    try {
      await storage.delete(StorageKeys.token);
    } catch (e) {
      AppLogger.error('Error deleting token: $e');
    }
  }

  Object? getFromLocalCache(String key) {
    try {
      return sharedPreferences.get(key);
    } catch (e) {
      AppLogger.error('Error getting from local cache: $e');
    }
    return null;
  }

  Future<String> getToken() async {
    try {
      return await storage.read(StorageKeys.token);
    } catch (e) {
      AppLogger.error('Error getting token: $e');
      return "";
    }
  }

  Future<Map<String, dynamic>> getUser() async {
    final jsonData = await storage.read(StorageKeys.user);
    return json.decode(jsonData.isNotEmpty ? jsonData : '{}');
  }

  set setUser(Map<String, dynamic> map) =>
      storage.write(StorageKeys.user, json.encode(map));

  Future<void> removeFromLocalCache(String key) async {
    await sharedPreferences.remove(key);
  }

  Future<void> saveToken(String token) async {
    try {
      await storage.write(StorageKeys.token, token);
    } catch (e) {
      AppLogger.error('Error saving token: $e');
    }
  }

  Future<void> saveToLocalCache({required String key, required value}) async {
    try {
      await sharedPreferences.setString(key, value.toString());
    } catch (e) {
      AppLogger.error('Error saving to local cache: $e');
    }
  }

  /// Clear all user-related data from both secure storage and shared preferences
  Future<void> clearAllUserData() async {
    try {
      AppLogger.info('Clearing all user data...');
      
      // Clear secure storage data
      await storage.delete(StorageKeys.token);
      await storage.delete(StorageKeys.user);
      await storage.delete(StorageKeys.password);
      await storage.delete(StorageKeys.isFirstTime);
      await storage.delete(StorageKeys.hasSeenWelcome);
      
      // Clear shared preferences data
      await sharedPreferences.remove(StorageKeys.userId);
      await sharedPreferences.remove(StorageKeys.userEmail);
      await sharedPreferences.remove(StorageKeys.userPhone);
      await sharedPreferences.remove(StorageKeys.isLoggedIn);
      await sharedPreferences.remove(StorageKeys.accountBalance);
      await sharedPreferences.remove(StorageKeys.lastLogin);
      await sharedPreferences.remove(StorageKeys.biometricEnabled);
      await sharedPreferences.remove(StorageKeys.hideUserBalance);
      await sharedPreferences.remove(StorageKeys.faceIDTouchID);
      await sharedPreferences.remove(StorageKeys.facedIdToSharedPrefKey);
      await sharedPreferences.remove(StorageKeys.fxInflowSheet);
      await sharedPreferences.remove('dayfi_id'); // Clear cached DayFi ID
      
      AppLogger.info('All user data cleared successfully');
    } catch (e) {
      AppLogger.error('Error clearing user data: $e');
    }
  }

  Future<void> cacheUserData({required String value}) async {
    await saveToLocalCache(key: StorageKeys.user, value: value);
  }
}
