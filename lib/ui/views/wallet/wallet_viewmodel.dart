import 'dart:convert';

import 'package:dayfi/app/app.locator.dart';
import 'package:dayfi/data/models/user_model.dart';
import 'package:dayfi/data/storage/secure_storage_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class WalletViewModel extends BaseViewModel {
  final NavigationService navigationService = locator<NavigationService>();
  final SecureStorageService _storageService = SecureStorageService();

  User? user;

  Future<void> loadUser() async {
    final userJson = await _storageService.read('user');
    if (userJson != null) {
      user = User.fromJson(json.decode(userJson));
      notifyListeners();
    }
  }
}
