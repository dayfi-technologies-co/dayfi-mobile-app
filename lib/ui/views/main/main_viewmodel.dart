import 'dart:async';
import 'dart:convert';

import 'package:dayfi/app/app.locator.dart';
import 'package:dayfi/data/models/user_model.dart';
import 'package:dayfi/data/models/wallet_reponse.dart';
import 'package:dayfi/data/storage/secure_storage_service.dart';
import 'package:dayfi/services/api/auth_api_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class MainViewModel extends BaseViewModel {
  final navigationService = locator<NavigationService>();

  User? user;
  final SecureStorageService _secureStorage = SecureStorageService();

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  Future<void> loadUser() async {
    final userJson = await _secureStorage.read('user');
    if (userJson != null) {
      user = User.fromJson(json.decode(userJson));
      notifyListeners();
    }
  }

  final AuthApiService _apiService = AuthApiService();
  final SecureStorageService _storageService = SecureStorageService();

  List<Wallet>? _wallets;
  bool _isLoading = false;
  String? _error;
  Timer? _pollingTimer;

  List<Wallet>? get wallets => _wallets;
  bool get isLoading => _isLoading;
  String? get err => _error;

  Future<void> loadWalletDetails() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Try loading from cache first
      final cachedWallets = await _storageService.getWalletDetails();
      if (cachedWallets != null) {
        _wallets = cachedWallets;
        _isLoading = false;
        notifyListeners();
      } else {}

      // Fetch fresh data from API

      final response = await _apiService.getWalletDetails();

      if (response.code == 200) {
        _wallets = response.data;
        _isLoading = false;
        notifyListeners();
      } else {
        _isLoading = false;
        _error = response.message;
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load wallet details: $e';
      notifyListeners();
    }
  }

  Future<void> refreshWalletDetails() async {
    await loadWalletDetails();
  }

  void startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      refreshWalletDetails();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
