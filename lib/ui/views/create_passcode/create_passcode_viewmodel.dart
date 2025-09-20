import 'package:dayfi/app/app.locator.dart';
import 'package:dayfi/data/storage/secure_storage_service.dart';
import 'package:dayfi/ui/views/reenter_passcode/reenter_passcode_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class CreatePasscodeViewModel extends BaseViewModel {
  final NavigationService navigationService = locator<NavigationService>();
  final SecureStorageService _secureStorage = locator<SecureStorageService>();
  String _passcode = '';
  String get passcode => _passcode;

  bool get isPasscodeComplete => _passcode.length == 6;

  void updatePasscode(String value) {
    _passcode = value;
    notifyListeners();
    if (_passcode.length == 6) {
      navigateToReenterPasscode();
    }
  }

  Future<void> navigateToReenterPasscode() async {
    await _secureStorage.write('temp_passcode', _passcode);
    navigationService.navigateToView(const ReenterPasscodeView());
  }
}
