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

class RecipientDetailsViewModel extends BaseViewModel {
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
  final TextEditingController _beneficiaryNameController =
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
  TextEditingController get beneficiaryNameController =>
      _beneficiaryNameController;

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

  RecipientDetailsViewModel() {
    _accountNumberController.addListener(() {
      setAccountNumber(_accountNumberController.text);
    });
    _beneficiaryNameController.addListener(() {
      setBeneficiaryName(_beneficiaryNameController.text);
    });
    loadUser();
    loadBanks();
    loadSavedAccounts();
  }

  Future<void> saveAccountToDatabase() async {
    setBusy(true);
    try {
      final existing = await _databaseService.getAccountByNumber(
        userId: user!.userId,
        accountNumber: accountNumber,
      );

      if (existing != null) {
        throw Exception('This bank account already exists for the user.');
      }

      // Proceed to save
      await _databaseService.saveAccount(
        userId: user!.userId,
        accountNumber: accountNumber,
        accountName: accountName == "Pastor Bright" ? "Bale Gary" : accountName,
        bankName: selectedBank,
        bankCode: bankCode,
        beneficiaryName: beneficiaryName,
      );
      await loadSavedAccounts();
      setBusy(false);
    } catch (e) {
      setBusy(false);
      // await _dialogService.showDialog(
      //   title: 'Error',
      //   description: 'Failed to save account: $e',
      // );
    }
    setBusy(false);
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
    _beneficiaryNameController.text = _beneficiaryName;
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
    _beneficiaryNameController.clear();
    notifyListeners();
  }

  Future<void> loadBanks() async {
    try {
      _isLoading = true;
      notifyListeners();

      _banks = await _databaseService.getCachedBanks();
      if (_banks.isNotEmpty) {
        notifyListeners();
        return;
      }

      _banks = await _apiService.fetchBanks(jwtToken: user?.token ?? '');
      await _databaseService.cacheBanks(_banks);
    } catch (e) {
      // await _dialogService.showDialog(
      //   title: 'Error',
      //   description: 'Failed to load banks: $e',
      // );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSavedAccounts() async {
    if (user?.userId == null) return;
    try {
      _isLoading = true;
      notifyListeners();
      _savedAccounts = (await _databaseService.getSavedAccounts(user!.userId))
          .map((e) => RecipientAccount.fromJson(e))
          .toList();
    } catch (e) {
      // await _dialogService.showDialog(
      //   title: 'Error',
      //   description: 'Failed to load saved accounts: $e',
      // );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resolveAccount() async {
    if (_accountNumber.length != 10 || _bankCode.isEmpty) {
      _showAccountError = true;
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.resolveAccountNumber(
        accountNumber: _accountNumber,
        bankCode: _bankCode,
        jwtToken: user?.token ?? '',
      );

      accountNam = response['accountName'] ?? 'Unknown';
      _showAccountError = false;

      if (_saveAccount && user?.userId != null) {
        await _databaseService.saveAccount(
          userId: user!.userId,
          accountNumber: _accountNumber,
          accountName: "Bale Gary",
          bankName: selectedBank,
          bankCode: _bankCode,
          beneficiaryName: _beneficiaryName,
        );
        await loadSavedAccounts();
      }
    } catch (e) {
      accountNam = '';
      _showAccountError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> navigateToAmountEntry(Wallet wallet) async {
    await saveAccountToDatabase();
    navigationService.navigateToAmountEntryView(
      accountNumber: _accountNumber,
      bankCode: _bankCode,
      accountName: accountNam,
      bankName: selectedBank,
      beneficiaryName: _beneficiaryName,
      wallet: wallet,
    );
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    _beneficiaryNameController.dispose();
    super.dispose();
  }
}
