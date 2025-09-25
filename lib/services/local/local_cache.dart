import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dayfi/services/local/secure_storage.dart';
import 'package:dayfi/common/constants/storage_keys.dart';
import 'package:dayfi/common/utils/app_logger.dart';

class LocalCache {
  late SecureStorage storage;
  late SharedPreferences sharedPreferences;

  LocalCache({required this.storage, required this.sharedPreferences});

  Future<void> deleteToken() async {
    try {
      storage.deleteKey(StorageKeys.token);
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
      return await storage.getValue(StorageKeys.token);
    } catch (e) {
      AppLogger.error('Error getting token: $e');
      return "";
    }
  }

  Future<Map<String, dynamic>> getUser() async {
    final jsonData = await storage.getValue(StorageKeys.user);
    return json.decode(jsonData.isNotEmpty ? jsonData : '{}');
  }

  set setUser(Map<String, dynamic> map) =>
      storage.writeKey(StorageKeys.user, json.encode(map));

  Future<void> removeFromLocalCache(String key) async {
    await sharedPreferences.remove(key);
  }

  Future<void> saveToken(String token) async {
    try {
      storage.writeKey(StorageKeys.token, token);
    } catch (e) {
      AppLogger.error('Error saving token: $e');
    }
  }

  Future<void> saveToLocalCache({required String key, required value}) async {
    AppLogger.debug('Data being saved: key: $key, value: $value');

    if (value is String) {
      await sharedPreferences.setString(key, value);
    }
    if (value is bool) {
      await sharedPreferences.setBool(key, value);
    }
    if (value is int) {
      await sharedPreferences.setInt(key, value);
    }
    if (value is double) {
      await sharedPreferences.setDouble(key, value);
    }
    if (value is List<String>) {
      await sharedPreferences.setStringList(key, value);
    }
    if (value is Map) {
      await sharedPreferences.setString(key, json.encode(value));
    }
  }

  Future<void> cacheUserData({required String value}) async {
    await saveToLocalCache(key: StorageKeys.user, value: value);
  }
}
