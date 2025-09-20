import 'dart:async';
import 'dart:developer';
import 'package:dayfi/data/models/user_model.dart';
import 'package:dayfi/services/api/auth_api_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:dayfi/app/app.locator.dart';
import '../../../data/models/transaction_history_model.dart';

class WalletsViewModel extends BaseViewModel {
  User? user;

  final _apiService = AuthApiService();
  final navigationService = locator<NavigationService>();

  List<WalletTransaction> _transactions = [];
  List<WalletTransaction> get transactions => _transactions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchWalletTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await _apiService.getWalletTransactions();
    } catch (e) {
      log("Error fetching transactions: $e");
      _transactions = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}
