import 'package:dayfi/app/app.locator.dart';
import 'package:dayfi/app/app.router.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../components/top_snack_bar.dart';

class LevelOnePartBViewModel extends BaseViewModel {
  final NavigationService _navigationService = locator<NavigationService>();
  final _dialogService = DialogService();

  String _phoneNumber = '';
  String dobDay = '';
  String dobMonth = '';
  String dobYear = '';
  String gender = '';

  String? _phoneNumberError;
  String? _dobDayError;
  String? _dobMonthError;
  String? _dobYearError;
  String? _genderError;

  // Define lists for days, months, and years
  final List<String> days = List.generate(
      31, (index) => (index + 1).toString().padLeft(2, '0')); // 01 to 31
  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  final List<String> years =
      List.generate(100, (index) => (2007 - index).toString());

  final List<String> genders = [
    'Male',
    'Female',
    'Other',
  ];

  String? get phoneNumberError => _phoneNumberError;
  String? get dobDayError => _dobDayError;
  String? get dobMonthError => _dobMonthError;
  String? get dobYearError => _dobYearError;
  String? get genderError => _genderError;
  NavigationService get navigationService => _navigationService;

  bool get isFormValid =>
      _phoneNumber.isNotEmpty &&
      dobDay.isNotEmpty &&
      dobMonth.isNotEmpty &&
      dobYear.isNotEmpty &&
      gender.isNotEmpty &&
      _phoneNumberError == null &&
      _dobDayError == null &&
      _dobMonthError == null &&
      _dobYearError == null &&
      _genderError == null;

  void setPhoneNumber(String value) {
    _phoneNumber = value;
    _phoneNumberError = _validatePhoneNumber(value);
    notifyListeners();
  }

  void setDobDay(String? value) {
    dobDay = value!;
    _dobDayError = _validateDobDay(value);
    notifyListeners();
  }

  void setDobMonth(String? value) {
    const monthMap = {
      'January': '01',
      'February': '02',
      'March': '03',
      'April': '04',
      'May': '05',
      'June': '06',
      'July': '07',
      'August': '08',
      'September': '09',
      'October': '10',
      'November': '11',
      'December': '12',
    };
    dobMonth = monthMap[value] ?? '';

    _dobMonthError = _validateDobMonth(dobMonth);
    notifyListeners();
  }

  void setDobYear(String? value) {
    dobYear = value!;
    _dobYearError = _validateDobYear(value);
    notifyListeners();
  }

  void setGender(String? value) {
    gender = value!;
    _genderError = _validateGender(value);
    notifyListeners();
  }

  void setDummyValues() {
    _phoneNumber = "9027382921";
    dobDay = "15";
    dobMonth = "06";
    dobYear = "1990";
    gender = "Male";
    notifyListeners();
  }

  String? _validatePhoneNumber(String value) {
    if (value.isEmpty) return 'Phone number is required';
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  String? _validateDobDay(String value) {
    if (value.isEmpty) return 'Day is required';
    final day = int.tryParse(value);
    if (day == null || day < 1 || day > 31) {
      return 'Enter a valid day (1-31)';
    }
    return null;
  }

  String? _validateDobMonth(String value) {
    if (value.isEmpty) return 'Month is required';
    final month = int.tryParse(value);
    if (month == null || month < 1 || month > 12) {
      return 'Enter a valid month (1-12)';
    }
    return null;
  }

  String? _validateDobYear(String value) {
    if (value.isEmpty) return 'Year is required';
    final year = int.tryParse(value);
    final currentYear = DateTime.now().year;
    if (year == null || year < 1900 || year > currentYear) {
      return 'Enter a valid year (1900-$currentYear)';
    }
    return null;
  }

  String? _validateGender(String value) {
    if (value.isEmpty) return 'Gender is required';
    if (!['Male', 'Female', 'Other'].contains(value)) {
      return 'Select a valid gender';
    }
    return null;
  }

  Future<void> submitForm(
    BuildContext context, {
    required String country,
    required String state,
    required String street,
    required String city,
    required String postalCode,
    required String address,
  }) async {
    if (!isFormValid) return;

    setBusy(true);

    try {
      String dateStr = "$dobYear-$dobMonth-$dobDay";
      String timeStr = "00:00:00";

      // Parse date and time
      List<String> dateParts = dateStr.split('-');
      List<String> timeParts = timeStr.split(':');

      // Nigeria UTC+1
      DateTime dt = DateTime.utc(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
        int.parse(timeParts[2]),
      ).add(const Duration(hours: 1));

      String formatted = DateFormat("yyyy-MM-ddTHH:mm:ss+01:00").format(dt);

      if (kDebugMode) {
        print("ISO 8601 (Nigeria): $formatted");
      }

      // Simulated API or processing
      await Future.delayed(const Duration(seconds: 1));

      TopSnackbar.show(
        context,
        message: 'Form submitted successfully!',
      );

      await Future.delayed(const Duration(milliseconds: 500));

      navigationService.navigateToVerifyPhoneView(
        country: country,
        state: state,
        street: street,
        city: city,
        postalCode: postalCode,
        address: address,
        gender: gender,
        dob: formatted,
        phoneNumber: _phoneNumber,
      );
    } catch (e) {
      final errorText = e.toString();
      TopSnackbar.show(
        context,
        message: 'Form submission error: $errorText',
        isError: true,
      );
    } finally {
      await Future.delayed(const Duration(milliseconds: 500));
      setBusy(false);
    }
  }
}
