import 'package:flutter/material.dart';
import 'package:dayfi/app/app.locator.dart';
import 'package:dayfi/services/api/auth_api_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class TransactionPinConfirmViewModel extends BaseViewModel {
  final navigationService = locator<NavigationService>();
  final authService = AuthApiService();
  final snackbarService = SnackbarService();
  final TextEditingController pinTextEditingController =
      TextEditingController();
  bool isPinValid = false;

  void validatePin(String value) {
    isPinValid = value.length == 4 && RegExp(r'^\d{4}$').hasMatch(value);
    notifyListeners();
  }

  Future<void> confirmPin(pin) async {
    if (!isPinValid) {
      snackbarService.showSnackbar(message: 'Please enter a valid 4-digit PIN');
      return;
    }

    if (pinTextEditingController.text != pin) {
      snackbarService.showSnackbar(message: 'PINs do not match');
      return;
    }

    setBusy(true);
    try {
      await authService.setTransactionPin(transactionPin: pin!);
      snackbarService.showSnackbar(
        message: 'Transaction PIN updated successfully',
      );
      navigationService.back();
      navigationService.back();
    } catch (e) {
      snackbarService.showSnackbar(
        message: 'Failed to update PIN: $e',
      );
    } finally {
      setBusy(false);
    }
  }
}
