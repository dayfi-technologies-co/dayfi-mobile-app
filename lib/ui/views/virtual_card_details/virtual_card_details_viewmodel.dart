import 'package:dayfi/data/models/user_model.dart';
import 'package:dayfi/data/storage/secure_storage_service.dart';
import 'package:stacked/stacked.dart';
import 'dart:convert';
import 'dart:developer';

class VirtualCardDetailsViewModel extends BaseViewModel {
  User? user;
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  bool _hasError = false;
  bool get hasError => _hasError;

  Future<void> loadUser() async {
    try {
      _isLoading = true;
      _hasError = false;
      notifyListeners();

      final storageService = SecureStorageService();
      final userJson = await storageService.read('user');
      log('Stored user JSON: $userJson');
      if (userJson != null) {
        user = User.fromJson(json.decode(userJson));
        log('User loaded: ${user!.userId}');
        if (user!.userId.isEmpty) {
          log('Error: userId is empty after parsing');
          _hasError = true;
        }
      } else {
        log('No user data found in secure storage');
        _hasError = true;
      }
    } catch (e, stackTrace) {
      log('Error loading user: $e', stackTrace: stackTrace);
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}