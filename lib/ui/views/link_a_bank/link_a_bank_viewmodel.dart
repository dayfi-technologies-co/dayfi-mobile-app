import 'dart:convert';
import 'package:dayfi/data/models/wallet_reponse.dart';
import 'package:flutter/material.dart';
import 'package:dayfi/app/app.locator.dart';
import 'package:dayfi/app/app.router.dart';
import 'package:dayfi/data/models/user_model.dart';
import 'package:dayfi/data/storage/secure_storage_service.dart';
import 'package:dayfi/services/api/auth_api_service.dart';
import 'package:dayfi/services/api/database_service.dart';
import 'package:dayfi/ui/views/recipient_details/recipient_account_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../components/top_snack_bar.dart';

class LinkABankViewModel extends BaseViewModel {
  final AuthApiService _apiService = AuthApiService();
  final DialogService _dialogService = locator<DialogService>();
  final NavigationService navigationService = locator<NavigationService>();
  final SecureStorageService _secureStorage = SecureStorageService();
  final DatabaseService _databaseService = DatabaseService();

  String _accountNumber = '';
  String _bankCode = '';
  String accountNam = '';
  String _beneficiaryName = '';
  List<dynamic> _banks = [];
  bool _isLoading = false;
  bool _saveAccount = false;
  bool _showAccountError = false;
  List<RecipientAccount> _savedAccounts = [];
  final TextEditingController _accountNumberController =
      TextEditingController();

  String get accountNumber => _accountNumber;
  String get bankCode => _bankCode;
  String get accountName => accountNam;
  String get beneficiaryName => _beneficiaryName;
  List<dynamic> get banks => _banks;
  bool get isLoading => _isLoading;
  bool get saveAccount => _saveAccount;
  bool get showAccountError => _showAccountError;
  List<RecipientAccount> get savedAccounts => _savedAccounts;
  TextEditingController get accountNumberController => _accountNumberController;

  bool get isValidAccount =>
      accountNam.isNotEmpty && _accountNumber.length == 10;

  String get selectedBank {
    final bank = _banks.firstWhere(
      (bank) => bank['bankcode'] == _bankCode,
      orElse: () => {'bankname': ''},
    );
    return bank['bankname'] ?? '';
  }

  User? user;

  LinkABankViewModel() {
    _accountNumberController.addListener(() {
      setAccountNumber(_accountNumberController.text);
    });
  }

  Future<void> loadUser() async {
    final userJson = await _secureStorage.read('user');
    if (userJson != null) {
      user = User.fromJson(json.decode(userJson));
      notifyListeners();
    }
  }

  void setAccountNumber(String value) {
    _accountNumber = value;
    _showAccountError = value.isNotEmpty;
    notifyListeners();
  }

  void setBankCode(String value) {
    _bankCode = value;
    notifyListeners();
  }

  void setBeneficiaryName(String value) {
    _beneficiaryName = value;
    notifyListeners();
  }

  void toggleSaveAccount(bool value) {
    _saveAccount = value;
    notifyListeners();
  }

  void selectSavedAccount(RecipientAccount account) {
    _accountNumber = account.accountNumber;
    accountNam = account.accountName;
    _bankCode = account.bankCode;
    _beneficiaryName = account.beneficiaryName;
    _accountNumberController.text = _accountNumber;
    _showAccountError = false;
    notifyListeners();
  }

  void resetValidation() {
    _accountNumber = '';
    accountNam = '';
    _bankCode = '';
    _beneficiaryName = '';
    _showAccountError = false;
    _accountNumberController.clear();
    notifyListeners();

    debugPrint('Validation fields reset.');
  }

  Future<void> loadBanks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _banks = await _databaseService.getCachedBanks();
      if (_banks.isNotEmpty) {
        notifyListeners();
        return;
      }

      _banks = await _apiService.fetchBanks(jwtToken: user?.token ?? '');
      await _databaseService.cacheBanks(_banks);
    } catch (e) {
      final errorText = e.toString();
      // TopSnackbar.show(
      //   context,
      //   message: 'Failed to load banks: $errorText',
      //   isError: true,
      // );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveAccountToDatabase(BuildContext context) async {
    setBusy(true);
    try {
      final existing = await _databaseService.getAccountByNumber(
        userId: user!.userId,
        accountNumber: accountNumber,
      );

      if (existing != null) {
        throw Exception('This bank account already exists for the user.');
      }

      await _databaseService.saveAccount(
        userId: user!.userId,
        accountNumber: accountNumber,
        accountName: accountName == "Pastor Bright" ? "Bale Gary" : accountName,
        bankName: selectedBank,
        bankCode: bankCode,
        beneficiaryName: beneficiaryName,
      );

      await loadSavedAccounts();

      // pop out of current
      navigationService.back();
      navigationService.back();

      await Future.delayed(const Duration(milliseconds: 300));

      TopSnackbar.show(
        context,
        message: 'Account linked successfully!',
      );

      await Future.delayed(const Duration(milliseconds: 500));

      navigationService.navigateToLinkedBanksView();
    } catch (e) {
      final errorText = e.toString();
      TopSnackbar.show(
        context,
        message: 'Failed to save account: $errorText',
        isError: true,
      );
    } finally {
      await Future.delayed(const Duration(milliseconds: 500));
      setBusy(false);
    }
  }

  Future<void> resolveAccount(BuildContext context) async {
    if (_accountNumber.length != 10 || _bankCode.isEmpty) {
      _showAccountError = true;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.resolveAccountNumber(
        accountNumber: _accountNumber,
        bankCode: _bankCode,
        jwtToken: user?.token ?? '',
      );

      accountNam = response['accountName'] ?? 'Unknown';
      _showAccountError = false;

      // TopSnackbar.show(
      //   context,
      //   message: 'Account resolved successfully!',
      // );
    } catch (e) {
      accountNam = '';
      _showAccountError = true;

      final errorText = e.toString();
      // TopSnackbar.show(
      //   context,
      //   message: 'Failed to resolve account: $errorText',
      //   isError: true,
      // );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSavedAccounts() async {
    if (user?.userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _savedAccounts = (await _databaseService.getSavedAccounts(user!.userId))
          .map((e) => RecipientAccount.fromJson(e))
          .toList();
    } catch (e) {
      final errorText = e.toString();
      // TopSnackbar.show(
      //   context,
      //   message: 'Failed to load saved accounts: $errorText',
      //   isError: true,
      // );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void navigateToAmountEntry() {
    navigationService.navigateToAmountEntryView(
      accountNumber: _accountNumber,
      bankCode: _bankCode,
      accountName: accountNam,
      bankName: selectedBank,
      beneficiaryName: _beneficiaryName,
      wallet: Wallet(
        walletId: "",
        userId: "",
        walletReference: "",
        accountName: "",
        accountNumber: "",
        bankName: "",
        balance: "0",
        currency: "",
        provider: "",
        createdAt: "",
        updatedAt: "",
      ),
    );
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    super.dispose();
  }
}
