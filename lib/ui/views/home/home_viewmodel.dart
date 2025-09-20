import 'dart:async';
import 'dart:developer';
import 'package:dayfi/ui/components/top_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:dayfi/data/models/user_model.dart';
import 'package:dayfi/data/models/wallet_reponse.dart';
import 'package:dayfi/services/api/auth_api_service.dart';
import 'package:dayfi/ui/views/tranfers_details_selection/tranfers_details_selection_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'dart:convert';
import 'package:dayfi/app/app.bottomsheets.dart';
import 'package:dayfi/app/app.dialogs.dart';
import 'package:dayfi/app/app.locator.dart';
import 'package:dayfi/ui/common/app_strings.dart';
import 'package:dayfi/data/storage/secure_storage_service.dart';

import '../../../data/models/transaction_history_model.dart';
import '../payment_setup/payment_setup_viewmodel.dart';

class HomeViewModel extends BaseViewModel {
  User? user;

  final _dialogService = locator<DialogService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _apiService = AuthApiService();
  final navigationService = locator<NavigationService>();
  final currencySelected = TextEditingController();
  List<WalletTransaction> _transactions = [];
  List<WalletTransaction> get transactions => _transactions;

  String selectedPaymentMethod = "";
  String get counterLabel => 'Counter is: $_counter';

  int _counter = 0;
  String dayfiId = '';

  bool _isLoading = false;
  bool showCurrencyOptions = false;
  bool get isLoading => _isLoading;

  String? dayfiIdErr;
  String? dayfiIdRes;
  Timer? _debounceTimer;
  String? get dayfiIdError => dayfiIdErr;
  String? get dayfiIdResponse => dayfiIdRes;

  final SecureStorageService _secureStorage = SecureStorageService();

  final List<CurrencyModel> currencies = [
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

  // List<CurrencyModel> availableCurrencies(int index ) {
  //  if ( index == 1) {}

  //   avaCurrencies

  //   return
  // }

  bool get isFormValid =>
      dayfiId.isNotEmpty &&
      dayfiIdErr == null &&
      dayfiIdRes != null &&
      !dayfiIdRes!.contains('User not found');

  bool get isDayfiIdValid =>
      dayfiId.isNotEmpty && dayfiId.startsWith('@') && dayfiId.length >= 3;

  bool get isFormValid2 =>
      dayfiId.isNotEmpty &&
      dayfiIdErr == null &&
      dayfiIdRes != null &&
      dayfiIdRes!.contains('User not found');

  bool get isDayfiIdValid2 =>
      dayfiId.isNotEmpty && dayfiId.startsWith('@') && dayfiId.length >= 3;

  void setDayfiId(String value) {
    String newValue = value.trim();
    // Ensure single @ prefix and preserve character order
    if (newValue.isNotEmpty) {
      newValue = newValue.replaceAll('@', ''); // Remove all @ symbols
      newValue = '@$newValue'; // Add single @ prefix
    } else {
      newValue = '';
    }
    // Only update if the value has changed
    if (newValue != dayfiId) {
      dayfiId = newValue;
      dayfiIdErr = _validateDayfiId(newValue);
      notifyListeners();

      // Cancel existing debounce timer
      _debounceTimer?.cancel();

      // Only validate if input is valid
      if (dayfiIdErr == null && isDayfiIdValid) {
        _debounceTimer = Timer(const Duration(milliseconds: 500), () {
          validateDayfiId(newValue);
        });
      } else {
        dayfiIdRes = null;
        notifyListeners();
      }
    }
  }

  void setDayfiI2(String value) {
    String newValue = value.trim();
    // Ensure single @ prefix and preserve character order
    if (newValue.isNotEmpty) {
      newValue = newValue.replaceAll('@', ''); // Remove all @ symbols
      newValue = '@$newValue'; // Add single @ prefix
    } else {
      newValue = '';
    }
    // Only update if the value has changed
    if (newValue != dayfiId) {
      dayfiId = newValue;
      dayfiIdErr = _validateDayfiId2(newValue);
      notifyListeners();

      // Cancel existing debounce timer
      _debounceTimer?.cancel();

      // Only validate if input is valid
      if (dayfiIdErr == null && isDayfiIdValid2) {
        _debounceTimer = Timer(const Duration(milliseconds: 500), () {
          validateDayfiId2(newValue);
        });
      } else {
        dayfiIdRes = null;
        notifyListeners();
      }
    }
  }

  Future<void> validateDayfiId(String dayfiId) async {
    setBusy(true);

    try {
      final response = await _apiService.validateDayfiId(dayfiId: dayfiId);

      if (response.code == 200) {
        dayfiIdRes = 'This username belongs to ${response.data.accountName}';
        dayfiIdErr = null;
      } else {
        dayfiIdRes = 'User not found';
        dayfiIdErr = 'Invalid Dayfi ID';
      }
    } catch (e) {
      dayfiIdRes = 'User not found';
      dayfiIdErr = 'Error validating Dayfi ID';
    }
    setBusy(false);
    notifyListeners();
  }

  Future<void> validateDayfiId2(String dayfiId) async {
    setBusy(true);
    try {
      final response = await _apiService.validateDayfiId(dayfiId: dayfiId);

      if (response.code == 200) {
        dayfiIdRes = 'This username is taken';
        dayfiIdErr = "This username is taken";
      } else {
        dayfiIdRes = '';
        dayfiIdErr = '';
      }
    } catch (e) {
      dayfiIdRes = '';
      dayfiIdErr = '';

      // await _dialogService.showDialog(
      //   title: 'Error',
      //   description: e.toString(),
      // );
    }
    setBusy(false);
    notifyListeners();
  }

  String? _validateDayfiId(String value) {
    value = value.trim();
    if (value.isEmpty) return 'Dayfi ID is required';
    if (!value.startsWith('@')) return 'Dayfi ID must start with @';
    if (value.length < 3) return 'Dayfi ID must be at least 3 characters';
    return null;
  }

  String? _validateDayfiId2(String value) {
    value = value.trim();
    if (value.isEmpty) return 'Dayfi ID is required';
    if (!value.startsWith('@')) return 'Dayfi ID must start with @';
    if (value.length < 3) return 'Dayfi ID must be at least 3 characters';
    return null;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  Color getBalanceCardColor(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case "NGN":
        return const Color(0xffE8F5E9); // light minty green
      case "USD":
        return const Color(0xffE3F2FD); // very light blue
      case "GBP":
        return const Color(0xffF3E5F5); // light lavender
      case "EUR":
        return const Color(0xffFFFDE7); // very light yellow
      default:
        return const Color(0xffFAFAFA); // near-white fallback
    }
  }

  Color getFundButtonColor(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case "NGN":
        return const Color(0xff006400); // dark green
      case "USD":
        return const Color(0xff003366); // dark blue
      case "GBP":
        return const Color(0xff4B0033); // deep burgundy
      case "EUR":
        return const Color(0xff333300); // dark olive
      default:
        return const Color(0xff2A0079); // fallback dark navy
    }
  }

  void navigateToCurrencyAmount(BuildContext context, Wallet wallet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransfersDetailsSelectionView(
          dayfiId: dayfiId,
          wallet: wallet,
        ),
      ),
    );
  }

  List<LetsGetYouStartedCheckModel> letsGetYouStartedCheckList = [
    LetsGetYouStartedCheckModel(
      title: 'Complete verification',
      description: 'Provide your details and verify your identification',
      icon: 'assets/svgs/person_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg',
      check: false,
    ),
    LetsGetYouStartedCheckModel(
      title: 'Add new wallet',
      description: "Create wallets in currencies like USD, EUR, GBP, etc.",
      icon:
          "assets/svgs/account_balance_wallet_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg",
      check: false,
    ),
    LetsGetYouStartedCheckModel(
      title: 'Invest in stable coins',
      description: 'Buy and keep stablecoins like USDT, USDC or PYUSD',
      icon: 'assets/svgs/coins_tab.svg',
      check: false,
    ),
    LetsGetYouStartedCheckModel(
      title: 'Get a unique username',
      description: 'Create your Dayfi tag for receiving payments',
      icon: 'assets/svgs/edit_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg',
      check: false,
    ),
    LetsGetYouStartedCheckModel(
      title: 'Set up 2FA',
      description: 'Extra layer of security against unauthorized access',
      icon: "assets/svgs/encrypted_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg",
      check: false,
    ),
  ];

  final List<String> beforeReceivingFunds = [
    "Receive NGN funds instantly—no delays, just ease.",
    "Your money stays safe and sound in your NGN wallet.",
    "Easily swap to USD, EUR, GBP, and more when you need to.",
    "Enjoy the freedom to spend globally, anytime, anywhere.",
    "Ready to begin? Just tap below—we’ll guide you through.",
  ];

  final List<String> kycLevel1Verification = [
    "Phone Number – To keep your logins secure and send you important updates.",
    "Residential Address – Helps us confirm your location.",
    "Country of Residence – Ensures we comply with local and international regulations.",
    "Date of Birth – Confirms you’re of legal age to use our services.",
    "Bank Verification Number (BVN) – For a smooth and trusted identity check.",
  ];

  final List<String> multiCurrencyWalletBenefits = [
    "Global Payments – Pay or receive in USD, GBP, EUR easily.",
    "Lower Costs – Save on currency conversion fees.",
    "Fast Swaps – Exchange currencies quickly in-wallet.",
    "Secure Storage – Hold multiple currencies safely.",
  ];

  Future<void> loadUser() async {
    final userJson = await _secureStorage.read('user');
    if (userJson != null) {
      user = User.fromJson(json.decode(userJson));
      notifyListeners();
    }
  }

  void incrementCounter() {
    _counter++;
    rebuildUi();
  }

  void showDialog() {
    _dialogService.showCustomDialog(
      variant: DialogType.infoAlert,
      title: 'Stacked Rocks! 🌟',
      description: 'Give Stacked $_counter stars on GitHub! 🚀',
    );
  }

  void showBottomSheet() {
    _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.notice,
      title: ksHomeBottomSheetTitle,
      description: ksHomeBottomSheetDescription,
    );
  }

  Future<void> fetchWalletTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await _apiService.getWalletTransactions();
    } catch (e) {
      log("Error fetching transactions: $e");
      _transactions = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createNewWallet(BuildContext context) async {
    setBusy(true);

    try {
      final response = await _apiService.createNewWallet(
        currency: currencySelected.text.trim(),
      );

      if (response['status'] == 'error') {
        TopSnackbar.show(
          context,
          message: 'Wallet creation failed: ${response["message"]}',
          isError: true,
        );
      } else {
        TopSnackbar.show(
          context,
          message: 'Creation successful!',
          duration: Duration(seconds: 2), // Ensure snackbar has time to display
        );
        // Delay pop to avoid Navigator conflict
        await Future.delayed(Duration(milliseconds: 500));
        if (context.mounted) {
          Navigator.pop(context);
        }

        notifyListeners();
      }
    } catch (e) {
      TopSnackbar.show(
        context,
        message: 'Wallet creation error: $e',
        isError: true,
        duration: Duration(seconds: 2),
      );
    } finally {
      Future.delayed(Duration(milliseconds: 500));
      currencySelected.text = "";
      setBusy(false);
    }
  }

  // Future<void> _createDayfiId(String dayfiId, BuildContext context) async {
  //   try {
  //     await _apiService.createDayfiId(dayfiId: dayfiId);
  //   } catch (e) {
  //     print(e.toString());
  //     TopSnackbar.show(
  //       context,
  //       message: 'Error: $e',
  //       isError: true,
  //     );
  //   }
  // }
}

final List<PaymentMethodModel> paymentMethods = [
  PaymentMethodModel(
    icon: "assets/images/logoo.png",
    name: "Via Dayfi-ID",
    description: "Receive funds from friends on dayfi for free",
  ),
  PaymentMethodModel(
    icon: "assets/svgs/credit_card_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg",
    name: "Via Debit Card",
    description: "Fund your NGN wallet with NFC tap or scan",
  ),
  PaymentMethodModel(
    icon:
        "assets/svgs/account_balance_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg",
    name: "Via Bank Transfer",
    description:
        "Receive funds by sending generated account details to familyand friends",
  ),
  PaymentMethodModel(
    icon: "assets/svgs/coins_tab.svg",
    name: "Via Digital Dollars",
    description: "Fund your USD wallet with USDT, USDC or PYUSD",
  ),
];

final List<PaymentMethodModel> transferMethods = [
  PaymentMethodModel(
    icon: "assets/images/logoo.png",
    name: "Via Dayfi-ID",
    description: "Send funds to your friend on dayfi for free",
  ),
  PaymentMethodModel(
    icon:
        "assets/svgs/account_balance_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg",
    name: "Via Bank Transfer",
    description: "Withdraw funds from dayfi to your bank account",
  ),
  // PaymentMethodModel(
  //   icon: "assets/svgs/coins_tab.svg",
  //   name: "Via Digital Dollars",
  //   description:
  //       "Transfer your funds to an external crypto wallet quickly and securely.",
  // ),
];

class PaymentMethodModel {
  final String name;
  final String icon;
  final String description;

  PaymentMethodModel({
    required this.icon,
    required this.name,
    required this.description,
  });
}

class LetsGetYouStartedCheckModel {
  final String title;
  final String description;
  final String icon;
  final bool check;

  LetsGetYouStartedCheckModel({
    required this.title,
    required this.description,
    required this.icon,
    required this.check,
  });
}
