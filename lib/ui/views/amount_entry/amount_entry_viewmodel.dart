// AmountEntryViewModel
import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:dayfi/app/app.locator.dart';
import 'package:dayfi/data/models/user_model.dart';
import 'package:dayfi/data/models/wallet_reponse.dart';
import 'package:dayfi/data/storage/secure_storage_service.dart';
import 'package:dayfi/ui/views/amount_entry/amount_entry_view.dart';
import 'package:dayfi/ui/views/recipient_details/recipient_account_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../services/api/auth_api_service.dart';
import '../../components/top_snack_bar.dart';

class AmountEntryViewModel extends BaseViewModel {
  final navigationService = locator<NavigationService>();
  final AuthApiService _service = AuthApiService();
  final TextEditingController pinController = TextEditingController();
  double _amount = 0.0;
  final double _fee = 10.0;
  bool _isAmountValid = false;

  // final AuthApiService _apiService = AuthApiService();
  final SecureStorageService _storageService = SecureStorageService();
  User? user;

  String? _error;
  Timer? _pollingTimer;
  String? get err => _error;

  Future<void> loadUser() async {
    final userJson = await _storageService.read('user');
    if (userJson != null) {
      user = User.fromJson(json.decode(userJson));
      notifyListeners();
    }
  }

  double get amount => _amount;
  double get fee => _fee;
  double get total => _amount + _fee;
  bool get isAmountValid => _isAmountValid;
  void Function(String)? onValueChanged;

  void setAmount(String value, String balance) {
    final amountDouble = double.tryParse(value.replaceAll(',', '')) ?? 0.0;
    _amount = amountDouble;

    log("amountDouble $amountDouble");
    _isAmountValid = amountDouble >= 100 &&
        amountDouble <= 300000 &&
        amountDouble < double.parse(balance);

    notifyListeners();
    notifyListeners();
  }

  void navigateToTransactionPin(
    BuildContext context, {
    required accountNumber,
    required bankCode,
    required accountName,
    required bankName,
    required beneficiaryName,
    required model,
  }) {
    showModalBottomSheet(
      barrierColor: const Color(0xff2A0079).withOpacity(0.5),
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      enableDrag: false,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28.00),
        ),
      ),
      builder: (context) => TransactionPinBottomSheet(
        pinController: pinController,
        isBankTransfer: true,
        amountEntryViewModel: model,
        onConfirm: () {
          initiateBankTransfer(
            context,
            accountNumber: accountNumber,
            bankCode: bankCode,
            accountName: accountName,
            bankName: bankName,
            beneficiaryName: beneficiaryName,
            model: model,
            amount:
                int.parse(total.toString().replaceAll(",", "").split('.')[0]),
          );
        },
      ),
    );
  }

  Future<void> initiateBankTransfer(
    BuildContext context, {
    required String accountNumber,
    required String bankCode,
    required String accountName,
    required String bankName,
    required String beneficiaryName,
    required dynamic model, // update type if you know it later
    required int amount,
  }) async {
    setBusy(true);

    try {
      final response = await _service.initiateBankTransfer(
        amount: amount,
        txPin: pinController.text.trim(),
        accountNumber: accountNumber,
        bankCode: bankCode,
        accountName: accountName,
        bankName: bankName,
        beneficiaryName: beneficiaryName,
        model: model,
      );

      if (response['status'] == 'error') {
        TopSnackbar.show(
          context,
          message: 'Bank transfer failed: ${response["message"]}',
          isError: true,
        );
      } else {
        TopSnackbar.show(
          context,
          message: 'Transfer successful!',
        );

        Future.delayed(const Duration(milliseconds: 500), () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransferSuccessView(
                    account: RecipientAccount(
                      accountNumber: accountNumber,
                      accountName: accountName,
                      bankName: bankName,
                      bankCode: bankCode,
                      beneficiaryName: beneficiaryName,
                    ),
                    amount: _amount,
                    fee: _fee,
                    model: model,
                  ),
                ),
              );
            }
          });
        });
      }
    } catch (e) {
      final errorText = e.toString();
      TopSnackbar.show(
        context,
        message: 'Bank transfer error: $errorText',
        isError: true,
      );
    } finally {
      await Future.delayed(const Duration(milliseconds: 500));
      pinController.text = "";
      notifyListeners();
      setBusy(false);
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
