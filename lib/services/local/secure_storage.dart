import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final storage = const FlutterSecureStorage();

  Future<String> read(String key) async {
    String? value = await storage.read(key: key);
    return value ?? "";
  }

  Future<Map<String, String>> readAll() async {
    var result = await storage.readAll();
    return result;
  }

  Future<void> delete(String key) async => await storage.delete(key: key);

  Future<void> deleteAll() async => await storage.deleteAll();

  Future<void> write(String key, String value) async {
    await storage.write(key: key, value: value);
  }
}
