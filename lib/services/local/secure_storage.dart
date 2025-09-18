import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final storage = const FlutterSecureStorage();

  Future<String> getValue(String key) async {
    String? value = await storage.read(key: key);
    return value ?? "";
  }

  Future<Map<String, String>> getValues() async {
    var result = await storage.readAll();
    return result;
  }

  void deleteKey(dynamic key) async => await storage.delete(key: key);

  void emptyDB() async => await storage.deleteAll();

  void writeKey(String key, String value) async {
    await storage.write(key: key, value: value);
  }
}
