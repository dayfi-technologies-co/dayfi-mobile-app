import 'dart:convert';

import 'package:dayfi/app_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists last successful bills API responses for instant UI on next open.
class BillsLocalCache {
  BillsLocalCache._();

  static const _categoriesKey = 'bills_categories_v1';
  static const _billersPrefix = 'bills_billers_v1_';
  static const _itemsPrefix = 'bills_items_v1_';

  static SharedPreferences get _prefs => locator<SharedPreferences>();

  static List<dynamic> readCategories() => _readList(_categoriesKey);

  static List<dynamic> readBillers(String categoryCode) =>
      _readList('$_billersPrefix${categoryCode.toUpperCase()}');

  static List<dynamic> readItems(String billerCode) =>
      _readList('$_itemsPrefix${billerCode.toUpperCase()}');

  static Future<void> saveCategories(List<dynamic> rows) =>
      _saveList(_categoriesKey, rows);

  static Future<void> saveBillers(String categoryCode, List<dynamic> rows) =>
      _saveList('$_billersPrefix${categoryCode.toUpperCase()}', rows);

  static Future<void> saveItems(String billerCode, List<dynamic> rows) =>
      _saveList('$_itemsPrefix${billerCode.toUpperCase()}', rows);

  static List<dynamic> _readList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = json.decode(raw);
      if (decoded is List) return List<dynamic>.from(decoded);
    } catch (_) {
      /* ignore corrupt cache */
    }
    return [];
  }

  static Future<void> _saveList(String key, List<dynamic> rows) async {
    if (rows.isEmpty) return;
    await _prefs.setString(key, json.encode(rows));
  }
}
