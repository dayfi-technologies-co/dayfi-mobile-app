import 'dart:convert';
import 'package:dayfi/app/app.locator.dart';
import 'package:dayfi/data/models/user_model.dart';
import 'package:dayfi/data/storage/secure_storage_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class ProfileViewModel extends BaseViewModel {
  User? _user;
  User? get user => _user;
  final SecureStorageService _secureStorage = SecureStorageService();
  final NavigationService navigationService = locator<NavigationService>();

  int? _year;
  int? _month;
  int? _day;

  int? get year => _year;
  int? get month => _month;
  int? get day => _day;

  Future<void> loadUser() async {
    setBusy(true); // Set busy state before loading
    try {
      final userJson = await _secureStorage.read('user');
      if (userJson != null) {
        _user = User.fromJson(json.decode(userJson));
        if (_user?.dateOfBirth != null) {
          // Only parse date if dateOfBirth is not null
          DateTime parsedDate = DateTime.parse(_user!.dateOfBirth!);
          _year = parsedDate.year;
          _month = parsedDate.month;
          _day = parsedDate.day;
        } else {
          // Set default values or keep null if dateOfBirth is null
          _year = null;
          _month = null;
          _day = null;
        }
        notifyListeners(); // Notify UI to rebuild
      } else {
        // Handle case where userJson is null (e.g., no user data in storage)
        _user = null;
        _year = null;
        _month = null;
        _day = null;
        notifyListeners();
      }
    } catch (e) {
      print("Error loading user: $e");
      // Optionally set an error state to display in the UI
    } finally {
      setBusy(false); // Clear busy state after loading
    }
  }
}
