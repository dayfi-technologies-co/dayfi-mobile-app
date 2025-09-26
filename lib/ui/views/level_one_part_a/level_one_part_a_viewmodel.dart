import 'package:dayfi/app/app.locator.dart';
import 'package:dayfi/app/app.router.dart';
import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../components/top_snack_bar.dart';

class LevelOnePartAViewModel extends BaseViewModel {
  final NavigationService _navigationService = locator<NavigationService>();

  String countryOfOrigin = '';
  String _residenceAddress = '';
  String _cityTown = '';
  String _street = '';
  String _zipCode = '';
  String state = '';

  String? _countryOfOriginError;
  String? _residenceAddressError;
  String? _cityTownError;
  String? _streetError;
  String? _zipCodeError;
  String? _stateError;

  final List<String> _countries = [
    "Nigeria",
  ];

  final List<String> _states = [
    "Abia",
    "Adamawa",
    "Akwa Ibom",
    "Anambra",
    "Bauchi",
    "Bayelsa",
    "Benue",
    "Borno",
    "Cross River",
    "Delta",
    "Ebonyi",
    "Edo",
    "Ekiti",
    "Enugu",
    "FCT (Federal Capital Territory)",
    "Gombe",
    "Imo",
    "Jigawa",
    "Kaduna",
    "Kano",
    "Katsina",
    "Kebbi",
    "Kogi",
    "Kwara",
    "Lagos",
    "Nasarawa",
    "Niger",
    "Ogun",
    "Ondo",
    "Osun",
    "Oyo",
    "Plateau",
    "Rivers",
    "Sokoto",
    "Taraba",
    "Yobe",
    "Zamfara",
  ];

  List<String> get countries => _countries;
  List<String> get states => _states;

  String? get countryOfOriginError => _countryOfOriginError;
  String? get residenceAddressError => _residenceAddressError;
  String? get cityTownError => _cityTownError;
  String? get streetError => _streetError;
  String? get zipCodeError => _zipCodeError;
  String? get stateError => _stateError;
  NavigationService get navigationService => _navigationService;

  bool get isFormValid =>
      countryOfOrigin.isNotEmpty &&
      _residenceAddress.isNotEmpty &&
      _cityTown.isNotEmpty &&
      _street.isNotEmpty &&
      _zipCode.isNotEmpty &&
      state.isNotEmpty &&
      _countryOfOriginError == null &&
      _residenceAddressError == null &&
      _cityTownError == null &&
      _streetError == null &&
      _zipCodeError == null &&
      _stateError == null;

  void setCountryOfOrigin(String value) {
    countryOfOrigin = value;
    _countryOfOriginError = _validateCountryOfOrigin(value);
    notifyListeners();
  }

  void setSelectedCountry(String? country) {
    countryOfOrigin = country!;
    _countryOfOriginError = _validateCountryOfOrigin(country);
    // validateAccount();
    notifyListeners();
  }

  void setResidenceAddress(String value) {
    _residenceAddress = value;
    _residenceAddressError = _validateResidenceAddress(value);
    notifyListeners();
  }

  void setCityTown(String value) {
    _cityTown = value;
    _cityTownError = _validateCityTown(value);
    notifyListeners();
  }

  void setStreet(String value) {
    _street = value;
    _streetError = _validateStreet(value);
    notifyListeners();
  }

  void setZipCode(String value) {
    _zipCode = value;
    _zipCodeError = _validateZipCode(value);
    notifyListeners();
  }

  void setState(String value) {
    state = value;
    _stateError = _validateState(value);
    notifyListeners();
  }

  void setSelectedState(String? stateValue) {
    state = stateValue!;
    _stateError = _validateState(stateValue);
    // validateAccount();
    notifyListeners();
  }

  void setDummyValues() {
    countryOfOrigin = "United States";
    _residenceAddress = "123 Main St, Apt 4B";
    _cityTown = "Springfield";
    _street = "Main St";
    _zipCode = "12345";
    state = "Illinois";
    notifyListeners();
  }

  String? _validateCountryOfOrigin(String value) {
    if (value.isEmpty) return 'Country of origin is required';
    return null;
  }

  String? _validateResidenceAddress(String value) {
    if (value.isEmpty) return 'Residence address is required';
    if (value.length < 5) return 'Address must be at least 5 characters';
    return null;
  }

  String? _validateCityTown(String value) {
    if (value.isEmpty) return 'City/Town is required';
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'City/Town must contain only letters and spaces';
    }
    return null;
  }

  String? _validateStreet(String value) {
    if (value.isEmpty) return 'Street is required';
    return null;
  }

  String? _validateZipCode(String value) {
    if (value.isEmpty) return 'Zip code is required';
    if (!RegExp(r'^\d{6}(-\d{5})?$').hasMatch(value)) {
      return 'Enter a valid zip code (e.g., 12345 or 12345-6789)';
    }
    return null;
  }

  String? _validateState(String value) {
    if (value.isEmpty) return 'State is required';
    return null;
  }

  Future<void> submitForm(BuildContext context) async {
    if (!isFormValid) return;

    setBusy(true);

    try {
      // Simulate API call or further processing
      await Future.delayed(const Duration(seconds: 1)); // Mock delay

      TopSnackbar.show(
        context,
        message: 'Form submitted successfully!',
      );

      await Future.delayed(const Duration(milliseconds: 500));

      navigationService.navigateToLevelOnePartBView(
        country: countryOfOrigin.trim(),
        state: state.trim(),
        street: _street,
        city: _cityTown.trim(),
        postalCode: _zipCode.trim(),
        address: _residenceAddress,
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
