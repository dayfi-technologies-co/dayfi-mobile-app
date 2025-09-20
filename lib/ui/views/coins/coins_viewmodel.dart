import 'dart:convert';
import 'package:dayfi/app/app.locator.dart';
import 'package:dio/dio.dart';
import 'package:dio_retry_plus/dio_retry_plus.dart'; // Ensure version ^2.0.0
import 'package:stacked/stacked.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked_services/stacked_services.dart';

class CoinsViewModel extends BaseViewModel {
  final navigationService = locator<NavigationService>();

  // Initialize Dio with RetryInterceptor
  final Dio _dio = Dio()
    ..interceptors.add(
      RetryInterceptor(
        dio: Dio(),
        logPrint: (message) =>
            print('RetryInterceptor: $message'), // Log retry attempts
        toNoInternetPageNavigator: () {
          // Navigate to a no-internet page or show a dialog
          locator<NavigationService>().showSnackBar(
            message: 'No internet connection. Please check your network.',
          );
          // ignore: void_checks
          return Future.value(false); // Prevent further retries if no internet
        },
        retries: 3, // Retry up to 3 times
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 4),
        ],
      ),
    );

  List<Map<String, dynamic>> _coins = [];
  List<Map<String, dynamic>> get coins => _coins;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _selectedFilter = 'market_cap';
  String get selectedFilter => _selectedFilter;

  static const String CACHE_KEY = 'coin_data_cache';
  static const String LAST_FETCH_KEY = 'last_fetch_time';
  static const refreshThreshold = Duration(minutes: 15); // 15-minute cache

  static bool _isInitialized = false;
  DateTime _lastLoadTime = DateTime(1970);
  static const Duration _refreshInterval = Duration(minutes: 15);

  final List<String> allowedCoins = [
    'stellar',
    // 'the-open-network',
    'paypal-usd',
    // 'tether-gold',
    // 'matic-network',
    'celo-dollar',
    // 'solana',
    // 'cardano',
    'usd-coin',
    'tether',
    'ethereum',
    'bitcoin',
    // 'dogecoin',
    // 'binancecoin',
    // 'scroll',
    // 'chainlink',
    // 'uniswap',
    // 'litecoin',
    // 'ripple',
  ];

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(CACHE_KEY);
    if (cachedData != null) {
      _coins = List<Map<String, dynamic>>.from(json.decode(cachedData));
      notifyListeners();
    }

    if (!_isInitialized || _shouldRefresh()) {
      await _loadData();
      _isInitialized = true;
      _lastLoadTime = DateTime.now();
    } else {
      sortCoins(_selectedFilter);
    }
  }

  bool _shouldRefresh() {
    return DateTime.now().difference(_lastLoadTime) > _refreshInterval;
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(CACHE_KEY);
    final lastFetchTimeStr = prefs.getString(LAST_FETCH_KEY);

    if (cachedData != null && lastFetchTimeStr != null) {
      final lastFetchTime = DateTime.parse(lastFetchTimeStr);
      if (DateTime.now().difference(lastFetchTime) < refreshThreshold) {
        _coins = List<Map<String, dynamic>>.from(json.decode(cachedData));
        notifyListeners();
        return;
      }
    }

    await fetchCoins();
  }

  Future<void> _saveToCache(List<Map<String, dynamic>> coinsData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(CACHE_KEY, json.encode(coinsData));
    await prefs.setString(LAST_FETCH_KEY, DateTime.now().toIso8601String());
  }

  Future<void> fetchCoins() async {
    if (isBusy && _coins.isNotEmpty) return;

    setBusy(true);
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _dio.get(
        'https://api.coingecko.com/api/v3/coins/markets',
        queryParameters: {
          'vs_currency': 'usd',
          'ids': allowedCoins.join(","),
          'order': 'market_cap_desc',
          'per_page': allowedCoins.length,
          'page': 1,
          'sparkline': false,
        },
      );

      // Handle 429 rate limit
      if (response.statusCode == 429) {
        _errorMessage = "Rate limit exceeded. Retrying...";
        notifyListeners();
        await Future.delayed(const Duration(seconds: 10));
        return fetchCoins(); // Retry
      }

      final processedData = (response.data as List)
          .map((coin) => {
                'id': coin['id'],
                'name': coin['name'],
                'abbv': coin['symbol'].toUpperCase(),
                'price_usd': coin['current_price'] ?? 0.0,
                'market_cap': coin['market_cap'] ?? 0,
                'price_change': coin['price_change_percentage_24h'] ?? 0.0,
                'icon': coin['image'] ?? '',
              })
          .toList();

      _coins = processedData;
      await _saveToCache(processedData);
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(CACHE_KEY);
      if (cachedData != null) {
        _coins = List<Map<String, dynamic>>.from(json.decode(cachedData));
        _errorMessage = "Failed to load new data. Showing cached data.";
      } else {
        _errorMessage = "Failed to load data. Please try again.";
      }
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    await fetchCoins();
    _lastLoadTime = DateTime.now();
  }

  void sortCoins(String filter) {
    _selectedFilter = filter;

    if (filter == 'price') {
      _coins.sort((a, b) => b['price_usd'].compareTo(a['price_usd']));
    } else if (filter == 'market_cap') {
      _coins.sort((a, b) => b['market_cap'].compareTo(a['market_cap']));
    } else if (filter == 'price_change') {
      _coins.sort((a, b) => b['price_change'].compareTo(a['price_change']));
    } else if (filter == 'popular') {
      _coins.sort((a, b) => allowedCoins
          .indexOf(a['id'])
          .compareTo(allowedCoins.indexOf(b['id'])));
    }

    notifyListeners();
  }

  List<Map<String, dynamic>> getFeaturedCoins() {
    return _coins
        .where((coin) => coin['id'] == 'stellar' || coin['id'] == 'bitcoin')
        .toList();
  }
}

extension on NavigationService {
  void showSnackBar({required String message}) {}
}
