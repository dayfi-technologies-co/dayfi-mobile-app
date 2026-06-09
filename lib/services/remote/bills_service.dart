import 'package:dayfi/flavors.dart';
import 'package:dayfi/services/local/bills_local_cache.dart';
import 'package:dayfi/services/remote/network/network_service.dart';
import 'package:dayfi/services/remote/network/url_config.dart';

class BillsService {
  BillsService(this._networkService);

  final NetworkService _networkService;

  static const Duration _cacheTtl = Duration(minutes: 30);

  List<dynamic>? _categoriesCache;
  DateTime? _categoriesCachedAt;
  final Map<String, List<dynamic>> _billersCache = {};
  final Map<String, DateTime> _billersCachedAt = {};
  final Map<String, List<dynamic>> _itemsCache = {};
  final Map<String, DateTime> _itemsCachedAt = {};

  bool _isFresh(DateTime? cachedAt) {
    if (cachedAt == null) return false;
    return DateTime.now().difference(cachedAt) < _cacheTtl;
  }

  /// Last saved categories — synchronous, for first paint before API returns.
  List<dynamic> getPersistedCategories() => BillsLocalCache.readCategories();

  /// Last saved billers for a category — synchronous.
  List<dynamic> getPersistedBillers(String categoryCode) =>
      BillsLocalCache.readBillers(categoryCode);

  /// Last saved items for a biller — synchronous.
  List<dynamic> getPersistedItems(String billerCode) =>
      BillsLocalCache.readItems(billerCode);

  void _warmCategoriesFromDisk() {
    if (_categoriesCache != null) return;
    final disk = BillsLocalCache.readCategories();
    if (disk.isNotEmpty) {
      _categoriesCache = List<dynamic>.from(disk);
      _categoriesCachedAt = DateTime.now();
    }
  }

  void _warmBillersFromDisk(String categoryCode) {
    final code = categoryCode.toUpperCase();
    if (_billersCache.containsKey(code)) return;
    final disk = BillsLocalCache.readBillers(code);
    if (disk.isNotEmpty) {
      _billersCache[code] = List<dynamic>.from(disk);
      _billersCachedAt[code] = DateTime.now();
    }
  }

  void _warmItemsFromDisk(String billerCode) {
    final code = billerCode.toUpperCase();
    if (_itemsCache.containsKey(code)) return;
    final disk = BillsLocalCache.readItems(code);
    if (disk.isNotEmpty) {
      _itemsCache[code] = List<dynamic>.from(disk);
      _itemsCachedAt[code] = DateTime.now();
    }
  }

  Future<List<dynamic>> _list(String path) async {
    final response = await _networkService.call(
      '${F.baseUrl}$path',
      RequestMethod.get,
    );
    final root = response.data;
    if (root is Map && root['data'] is List) {
      return root['data'] as List;
    }
    if (root is List) return root;
    return [];
  }

  Future<Map<String, dynamic>> _map(String path, {Map<String, dynamic>? data}) async {
    final response = await _networkService.call(
      '${F.baseUrl}$path',
      data == null ? RequestMethod.get : RequestMethod.post,
      data: data,
    );
    final root = response.data;
    if (root is Map<String, dynamic>) {
      final inner = root['data'];
      if (inner is Map<String, dynamic>) return inner;
      return root;
    }
    return {};
  }

  /// Cached bill categories — disk first, then memory, then network.
  Future<List<dynamic>> fetchCategories({bool forceRefresh = false}) async {
    _warmCategoriesFromDisk();

    if (!forceRefresh &&
        _categoriesCache != null &&
        _isFresh(_categoriesCachedAt)) {
      return List<dynamic>.from(_categoriesCache!);
    }

    try {
      final rows = await _list(UrlConfig.billCategories);
      if (rows.isNotEmpty) {
        _categoriesCache = List<dynamic>.from(rows);
        _categoriesCachedAt = DateTime.now();
        await BillsLocalCache.saveCategories(rows);
        return rows;
      }
    } catch (_) {
      /* use cache below */
    }

    if (_categoriesCache != null) {
      return List<dynamic>.from(_categoriesCache!);
    }
    return [];
  }

  /// Cached billers for a category — disk first, then memory, then network.
  Future<List<dynamic>> fetchBillers(
    String categoryCode, {
    bool forceRefresh = false,
  }) async {
    final code = categoryCode.toUpperCase();
    _warmBillersFromDisk(code);

    if (!forceRefresh &&
        _billersCache.containsKey(code) &&
        _isFresh(_billersCachedAt[code])) {
      return List<dynamic>.from(_billersCache[code]!);
    }

    try {
      final rows = await _list('${UrlConfig.billBillers}/$code/billers');
      if (rows.isNotEmpty) {
        _billersCache[code] = List<dynamic>.from(rows);
        _billersCachedAt[code] = DateTime.now();
        await BillsLocalCache.saveBillers(code, rows);
        return rows;
      }
    } catch (_) {
      /* use cache below */
    }

    final cached = _billersCache[code];
    if (cached != null) return List<dynamic>.from(cached);
    return [];
  }

  /// Cached bill items for a biller — disk first, then memory, then network.
  Future<List<dynamic>> fetchItems(
    String billerCode, {
    bool forceRefresh = false,
  }) async {
    final code = billerCode.toUpperCase();
    _warmItemsFromDisk(code);

    if (!forceRefresh &&
        _itemsCache.containsKey(code) &&
        _isFresh(_itemsCachedAt[code])) {
      return List<dynamic>.from(_itemsCache[code]!);
    }

    try {
      final rows = await _list('${UrlConfig.billItems}/$code/items');
      if (rows.isNotEmpty) {
        _itemsCache[code] = List<dynamic>.from(rows);
        _itemsCachedAt[code] = DateTime.now();
        await BillsLocalCache.saveItems(code, rows);
        return rows;
      }
    } catch (_) {
      /* use cache below */
    }

    final cached = _itemsCache[code];
    if (cached != null) return List<dynamic>.from(cached);
    return [];
  }

  Future<Map<String, dynamic>> validateBill({
    required String categoryCode,
    required String billerCode,
    required String itemCode,
    required String customerId,
  }) {
    return _map(
      UrlConfig.billValidate,
      data: {
        'categoryCode': categoryCode,
        'billerCode': billerCode,
        'itemCode': itemCode,
        'customerId': customerId,
      },
    );
  }

  Future<Map<String, dynamic>> payBill({
    required String categoryCode,
    required String billerCode,
    required String itemCode,
    required String customerId,
    required double amount,
    required String pin,
    String? billerName,
    String? itemName,
  }) {
    return _map(
      UrlConfig.billPay,
      data: {
        'categoryCode': categoryCode,
        'billerCode': billerCode,
        'itemCode': itemCode,
        'customerId': customerId,
        'amount': amount,
        'pin': pin,
        'billerName': billerName,
        'itemName': itemName,
        'spendCurrency': 'NGN',
      },
    );
  }
}
