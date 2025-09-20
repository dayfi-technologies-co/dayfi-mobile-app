import 'dart:convert';
import 'package:dayfi/app/app.locator.dart';
import 'package:dayfi/data/models/user_model.dart';
import 'package:dayfi/data/storage/secure_storage_service.dart';
import 'package:dayfi/services/api/database_service.dart';
import 'package:dayfi/ui/views/recipient_details/recipient_account_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class LinkedBanksViewModel extends BaseViewModel {
  final NavigationService navigationService = locator<NavigationService>();
  final SecureStorageService _secureStorage = SecureStorageService();
  final DatabaseService _databaseService = DatabaseService();
  List<RecipientAccount> _savedAccounts = [];
  bool _isLoading = false;
  User? _user;

  List<RecipientAccount> get savedAccounts => _savedAccounts;
  bool get isLoading => _isLoading;

  LinkedBanksViewModel() {
    loadUser();
  }

  Future<void> loadUser() async {
    final userJson = await _secureStorage.read('user');
    if (userJson != null) {
      _user = User.fromJson(json.decode(userJson));
      await loadSavedAccounts();
    }
    notifyListeners();
  }

  Future<void> loadSavedAccounts() async {
    if (_user?.userId == null) return;
    try {
      _isLoading = true;
      notifyListeners();
      _savedAccounts = (await _databaseService.getSavedAccounts(_user!.userId))
          .map((e) => RecipientAccount.fromJson(e))
          .toList();
    } catch (e) {
      // Handle error appropriately
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAccount(int id) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _databaseService.deleteAccount(id);
      await loadSavedAccounts();
    } catch (e) {
      // Handle error appropriately
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
