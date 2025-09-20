import 'dart:convert';

import 'package:dayfi/services/api/auth_api_service.dart';
import 'package:dayfi/ui/views/payment_setup/payment_setup_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:dayfi/app/app.locator.dart';

import '../../../data/models/user_model.dart';
import '../../../data/storage/secure_storage_service.dart';
import '../../components/top_snack_bar.dart';
import '../amount_entry/amount_entry_view.dart';
import '../amount_entry/amount_entry_viewmodel.dart';
import '../recipient_details/recipient_account_model.dart';

class TransfersDetailsSelectionViewModel extends BaseViewModel {
  final SecureStorageService _storageService = SecureStorageService();
  final NavigationService navigationService = locator<NavigationService>();
  final TextEditingController pinController = TextEditingController();
  final AuthApiService _service = AuthApiService();
  final String dayfiId;

  String _selectedCurrency = 'NGN';
  double _amount = 0.0;
  double _convertedAmount = 0.0;

  User? user;

  final currencyTextController = TextEditingController(
    text: "NGN",
  );

  Future<void> loadUser() async {
    final userJson = await _storageService.read('user');
    if (userJson != null) {
      user = User.fromJson(json.decode(userJson));
      notifyListeners();
    }
  }

  Future<void> initiateUserIDTransfer({
    required String dayfiId,
    required int amount,
    required BuildContext context,
    required String walletType,
  }) async {
    setBusy(true);

    try {
      final response = await _service.initiateWalletTransfer(
        dayfiId: dayfiId.replaceAll("@", ""),
        amount: amount,
        txPin: pinController.text.trim(),
      );

      // Assuming response contains a status or code for success/failure:
      if (response['status'] == 'error') {
        TopSnackbar.show(
          context,
          message: 'Transfer failed: ${response["message"] ?? "Unknown error"}',
          isError: true,
        );
        return;
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
                  builder: (_) => TransferSuccessView(
                    account: RecipientAccount(
                      accountNumber: dayfiId,
                      accountName: walletType,
                      bankName: "bankName",
                      bankCode: "bankCode",
                      beneficiaryName: "beneficiaryName",
                    ),
                    amount: amount.toDouble(),
                    fee: 0,
                    model: AmountEntryViewModel(),
                  ),
                ),
              );
            }
          });
        });
      }
    } catch (e) {
      TopSnackbar.show(
        context,
        message: 'Transfer error: ${e.toString()}',
        isError: true,
      );
    } finally {
      await Future.delayed(const Duration(milliseconds: 500));
      pinController.text = "";
      await Future.delayed(const Duration(milliseconds: 500));
      setBusy(false);
    }
  }

  bool isAmountValid(String value, balance) {
    if (value.isEmpty) return false;
    try {
      final amount = double.parse(value.replaceAll(',', ''));
      return amount > 99 && amount <= 300000 && amount < balance;
    } catch (e) {
      return false;
    }
  }

  bool showCurrencyOptions = false;
  String? initialValue;
  void Function(String)? onValueChanged;
  String previousText = '';
  int previousCursorPosition = 0;

  final List<CurrencyModel> currencies = [
    CurrencyModel(
      name: "NGN",
      icon: "assets/images/nigeria.png",
    ),
    CurrencyModel(
      name: 'USD',
      icon: "assets/images/united-states.png",
    ),
    CurrencyModel(
      name: "GBP",
      icon: "assets/images/united-kingdom.png",
    ),
    CurrencyModel(
      name: "EUR",
      icon: "assets/images/european-union.png",
    ),
  ];

  TransfersDetailsSelectionViewModel({required this.dayfiId});

  String get selectedCurrency => _selectedCurrency;
  double get amount => _amount;
  double get convertedAmount => _convertedAmount;

  String get currencySymbol => _selectedCurrency == 'USD'
      ? '\$'
      : _selectedCurrency == 'NGN'
          ? 'NGN'
          : '£';

  bool get isFormValid => _amount > 0;

  void setCurrency(String? currency) {
    if (currency != null) {
      _selectedCurrency = currency;
      _updateConvertedAmount();
      notifyListeners();
    }
  }

  void setAmount(String value) {
    _amount = double.tryParse(value) ?? 0.0;
    _updateConvertedAmount();
    notifyListeners();
  }

  void _updateConvertedAmount() {
    // Mock conversion logic (use real API in production)
    if (_selectedCurrency == 'NGN') {
      _convertedAmount = _amount / 1593; // Assuming 1 USD = 1593 NGN
    } else if (_selectedCurrency == 'GBP') {
      _convertedAmount = _amount * 1.3; // Mock conversion
    } else {
      _convertedAmount = _amount; // USD
    }
  }

  void navigateBack() {
    navigationService.back();
  }
}

class SummaryBottomSheetViewModel extends BaseViewModel {
  final String dayfiId;
  final double amount;
  final String currency;
  final double convertedAmount;

  SummaryBottomSheetViewModel({
    required this.dayfiId,
    required this.amount,
    required this.currency,
    required this.convertedAmount,
  });

  String get currencySymbol {
    switch (currency) {
      case 'USD':
        return '\$';
      case 'NGN':
        return 'NGN';
      case 'GBP':
        return '£';
      default:
        return '\$'; // Default to USD if unknown currency
    }
  }

  double get transactionFee => 0.01; // Mock transaction fee in USD

  double get totalAmount {
    // Convert fee to the selected currency if needed
    double feeInSelectedCurrency;
    if (currency == 'NGN') {
      feeInSelectedCurrency =
          transactionFee * 1593; // Assuming 1 USD = 1593 NGN
    } else if (currency == 'GBP') {
      feeInSelectedCurrency = transactionFee / 1.3; // Mock conversion
    } else {
      feeInSelectedCurrency = transactionFee; // USD
    }
    return amount + feeInSelectedCurrency;
  }
}

class PinInputViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  List<String?> _pin = List.generate(4, (index) => null);

  List<String?> get pin => _pin;

  bool get isPinComplete => !_pin.contains(null);

  void addPin(String digit) {
    for (int i = 0; i < _pin.length; i++) {
      if (_pin[i] == null) {
        _pin[i] = digit;
        notifyListeners();
        break;
      }
    }
  }

  void removePin() {
    for (int i = _pin.length - 1; i >= 0; i--) {
      if (_pin[i] != null) {
        _pin[i] = null;
        notifyListeners();
        break;
      }
    }
  }

  void onComplete() {
    if (isPinComplete) {
      // Mock transaction confirmation logic
      // In a real app, validate PIN and process the transfer
      // _navigationService.navigateTo(Routes.transferSuccessView);
    }
  }
}
