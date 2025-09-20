import 'package:dayfi/app/app.locator.dart';
import 'package:dayfi/app/app.router.dart';
import 'package:dayfi/data/storage/secure_storage_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../components/top_snack_bar.dart';

class ReenterPasscodeViewModel extends BaseViewModel {
  final NavigationService navigationService = locator<NavigationService>();
  final SecureStorageService _secureStorage = locator<SecureStorageService>();
  String _passcode = '';
  String get passcode => _passcode;

  bool get isPasscodeComplete => _passcode.length == 6;

  void updatePasscode(
    BuildContext context,
    String value,
  ) {
    _passcode = value;
    notifyListeners();
    if (_passcode.length == 6) {
      verifyPasscode(context);
    }
  }

  Future<void> verifyPasscode(BuildContext context) async {
    // setBusy(true);

    try {
      final tempPasscode = await _secureStorage.read('temp_passcode');

      if (_passcode == tempPasscode) {
        await _secureStorage.write('user_passcode', _passcode);
        await _secureStorage.delete('temp_passcode');

        navigationService.clearStackAndShow(Routes.mainView);
      } else {
        _passcode = '';
        notifyListeners();

        TopSnackbar.show(
          context,
          message: 'Passcode mismatch. Please try again.',
          isError: true,
        );
      }
    } catch (e) {
      final errorText = e.toString();
      TopSnackbar.show(
        context,
        message: 'Passcode verification error: $errorText',
        isError: true,
      );
    } finally {
      // await Future.delayed(const Duration(milliseconds: 500));
      // setBusy(false);
    }
  }
}
