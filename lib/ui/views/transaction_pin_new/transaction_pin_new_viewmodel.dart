import 'package:flutter/material.dart';
import 'package:dayfi/app/app.locator.dart';
import 'package:dayfi/app/app.router.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class TransactionPinNewViewModel extends BaseViewModel {
  final navigationService = locator<NavigationService>();
  final TextEditingController pinTextEditingController =
      TextEditingController();
  bool isPinValid = false;

  void validatePin(String value) {
    isPinValid = value.length == 4 && RegExp(r'^\d{4}$').hasMatch(value);
    notifyListeners();
  }

  void navigateToConfirmPin() {
    if (isPinValid) {
      navigationService.navigateToTransactionPinConfirmView(
        pin: pinTextEditingController.text,
      );
    }
  }
}
