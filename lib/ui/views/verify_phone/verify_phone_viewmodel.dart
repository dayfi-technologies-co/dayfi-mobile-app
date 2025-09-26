import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:dayfi/app/app.locator.dart';
import 'package:dayfi/app/app.router.dart';
import 'package:dayfi/data/models/user_model.dart';
import 'package:dayfi/data/storage/secure_storage_service.dart';
import 'package:dayfi/services/api/auth_api_service.dart' show AuthApiService;
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class VerifyPhoneViewModel extends BaseViewModel {
  final _apiService = AuthApiService();
  final _dialogService = DialogService();
  final NavigationService _navigationService = locator<NavigationService>();

  int _remainingSeconds = 60;

  String _phoneNumber = '';
  String _verificationCode = '';
  String bvn = '';

  Timer? _timer;

  String? _verificationCodeError;
  String? _bvnError;

  User? user;

  final SecureStorageService _secureStorage = SecureStorageService();

  int get remainingSeconds => _remainingSeconds;
  String? get bvnError => _bvnError;

  String get timerText =>
      'Resend code in ${(_remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}';
  bool get canResend => _remainingSeconds == 0;
  String? get verificationCodeError => _verificationCodeError;
  NavigationService get navigationService => _navigationService;

  VerifyPhoneViewModel({String phoneNumber = ''}) {
    _phoneNumber = phoneNumber;
    startTimer();
  }

  Future<void> loadUser() async {
    final userJson = await _secureStorage.read('user');
    if (userJson != null) {
      user = User.fromJson(json.decode(userJson));
      notifyListeners();
    }
  }

  void setBvn(
    String value, {
    required String country,
    required String state,
    required String street,
    required String city,
    required String postalCode,
    required String address,
    required String gender,
    required String dob,
    required String phoneNumber,
  }) {
    ;
    bvn = value;
    _bvnError = _validateBvn(value);
    if (value.length == 11) {
      updateUserProfile(
        country: country,
        state: state,
        street: street,
        city: city,
        postalCode: postalCode,
        address: address,
        gender: gender,
        dob: dob,
        phoneNumber: phoneNumber,
      );
    }
    notifyListeners();
  }

  String? _validateBvn(String? value) {
    if (value == null || value.isEmpty) {
      return 'BVN is required';
    }
    if (!RegExp(r'^\d{11}$').hasMatch(value)) {
      return 'BVN must be exactly 11 digits';
    }
    return null;
  }

  void startTimer() {
    _timer?.cancel(); // Cancel any existing timer
    _remainingSeconds = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  void setVerificationCode(String value) {
    _verificationCode = value;
    _verificationCodeError = _validateVerificationCode(value);
    notifyListeners();
  }

  String? _validateVerificationCode(String value) {
    if (value.isEmpty) return 'Verification code is required';
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'Enter a valid 6-digit code';
    }
    return null;
  }

  bool get isFormValid =>
      _verificationCodeError == null && _verificationCode.isNotEmpty;

  Future<void> resendCode() async {
    if (!canResend) return;

    setBusy(true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      await _dialogService.showDialog(
        title: 'Success',
        description: 'A new verification code has been sent to $_phoneNumber',
      );
      startTimer();
    } catch (e) {
      await _dialogService.showDialog(
        title: 'Error',
        description: e.toString(),
      );
    }
    setBusy(false);
  }

  Future<void> verifyCode({
    required String country,
    required String state,
    required String street,
    required String city,
    required String postalCode,
    required String address,
    required String gender,
    required String dob,
    required String phoneNumber,
  }) async {
    if (!isFormValid) return;

    setBusy(true);
    try {
      await updateUserProfile(
        country: country,
        state: state,
        street: street,
        city: city,
        postalCode: postalCode,
        address: address,
        gender: gender,
        dob: dob,
        phoneNumber: phoneNumber,
      );
    } catch (e) {
      await _dialogService.showDialog(
        title: 'Error',
        description: e.toString(),
      );
    }
    setBusy(false);
  }

  Future<void> updateUserProfile({
    required String country,
    required String state,
    required String street,
    required String city,
    required String postalCode,
    required String address,
    required String gender,
    required String dob,
    required String phoneNumber,
  }) async {
    // if (!isFormValid) return;
    setBusy(true);

    try {
      await _apiService.updateProfile1(
        userId: user!.userId,
        country: country,
        state: state,
        street: street,
        city: city,
        postalCode: postalCode,
        address: address,
        gender: gender.toLowerCase(),
        dob: dob,
        phoneNumber: phoneNumber,
        bvn: bvn,
      );

      // await _dialogService.showDialog(
      //   title: 'Success',
      //   description: response.message,
      // );

      setBusy(false);

      // log(response.message);

      navigationService.clearStackAndShow(Routes.kycSuccessView);
    } catch (e) {
      await _dialogService.showDialog(
        title: 'Error',
        description: e.toString(),
      );
      setBusy(false);

      // removing soon
      // navigationService.clearStackAndShow(Routes.kycSuccessView);
    }

    setBusy(false);
  }

  Future<void> updateUserProfile2({
    required String idType,
    required String idNumber,
  }) async {
    if (!isFormValid) return;

    setBusy(true);
    try {
      final response = await _apiService.updateProfile2(
        jwtToken: user!.token!,
        userId: user!.userId,
        idType: idType,
        idNumber: idNumber,
      );
      await _dialogService.showDialog(
        title: 'Success',
        description: response.message,
      );
      log(response.message);

      // navigationService.clearStackAndShow(Routes.successView);
    } catch (e) {
      await _dialogService.showDialog(
        title: 'Error',
        description: e.toString(),
      );
    }
    setBusy(false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
