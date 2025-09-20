import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dayfi/data/models/wallet_reponse.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  Future<List<Wallet>?> getWalletDetails() async {
    try {
      final jsonString = await _storage.read(key: 'wallet_details');
      if (jsonString == null) return null;
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => Wallet.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to read wallet details: $e');
    }
  }
}
