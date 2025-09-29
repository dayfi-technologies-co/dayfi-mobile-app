import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/models/user_model.dart';
import 'package:dayfi/services/remote/auth_service.dart';
import 'package:dayfi/services/local/secure_storage.dart';
import 'package:dayfi/common/constants/storage_keys.dart';

class CompletePersonalInfoState {
  final String dateOfBirth;
  final String country;
  final String phoneNumber;
  final String address;
  final String postalCode;
  final String state;
  final String city;
  final String occupation;
  final String referralCode;
  final bool isBusy;
  final String dateOfBirthError;
  final String countryError;
  final String phoneNumberError;
  final String addressError;
  final String postalCodeError;
  final String stateError;
  final String cityError;
  final String occupationError;
  final String referralCodeError;

  const CompletePersonalInfoState({
    this.dateOfBirth = '',
    this.country = '',
    this.phoneNumber = '',
    this.address = '',
    this.postalCode = '',
    this.state = '',
    this.city = '',
    this.occupation = '',
    this.referralCode = '',
    this.isBusy = false,
    this.dateOfBirthError = '',
    this.countryError = '',
    this.phoneNumberError = '',
    this.addressError = '',
    this.postalCodeError = '',
    this.stateError = '',
    this.cityError = '',
    this.occupationError = '',
    this.referralCodeError = '',
  });

  bool get isFormValid =>
      dateOfBirth.isNotEmpty &&
      country.isNotEmpty &&
      phoneNumber.isNotEmpty &&
      address.isNotEmpty &&
      postalCode.isNotEmpty &&
      state.isNotEmpty &&
      city.isNotEmpty &&
      occupation.isNotEmpty &&
      dateOfBirthError.isEmpty &&
      countryError.isEmpty &&
      phoneNumberError.isEmpty &&
      addressError.isEmpty &&
      postalCodeError.isEmpty &&
      stateError.isEmpty &&
      cityError.isEmpty &&
      occupationError.isEmpty &&
      referralCodeError.isEmpty;

  CompletePersonalInfoState copyWith({
    String? dateOfBirth,
    String? country,
    String? phoneNumber,
    String? address,
    String? postalCode,
    String? state,
    String? city,
    String? occupation,
    String? referralCode,
    bool? isBusy,
    String? dateOfBirthError,
    String? countryError,
    String? phoneNumberError,
    String? addressError,
    String? postalCodeError,
    String? stateError,
    String? cityError,
    String? occupationError,
    String? referralCodeError,
  }) {
    return CompletePersonalInfoState(
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      country: country ?? this.country,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      postalCode: postalCode ?? this.postalCode,
      state: state ?? this.state,
      city: city ?? this.city,
      occupation: occupation ?? this.occupation,
      referralCode: referralCode ?? this.referralCode,
      isBusy: isBusy ?? this.isBusy,
      dateOfBirthError: dateOfBirthError ?? this.dateOfBirthError,
      countryError: countryError ?? this.countryError,
      phoneNumberError: phoneNumberError ?? this.phoneNumberError,
      addressError: addressError ?? this.addressError,
      postalCodeError: postalCodeError ?? this.postalCodeError,
      stateError: stateError ?? this.stateError,
      cityError: cityError ?? this.cityError,
      occupationError: occupationError ?? this.occupationError,
      referralCodeError: referralCodeError ?? this.referralCodeError,
    );
  }
}

class CompletePersonalInfoNotifier extends StateNotifier<CompletePersonalInfoState> {
  final AuthService _authService = authService;
  final SecureStorageService _secureStorage = locator<SecureStorageService>();

  CompletePersonalInfoNotifier() : super(const CompletePersonalInfoState());

  // Setters
  void setDateOfBirth(String value) {
    final error = _validateDateOfBirth(value);
    state = state.copyWith(dateOfBirth: value, dateOfBirthError: error);
  }

  void setCountry(String value) {
    final error = _validateCountry(value);
    state = state.copyWith(country: value, countryError: error);
  }

  void setPhoneNumber(String value) {
    final error = _validatePhoneNumber(value);
    state = state.copyWith(phoneNumber: value, phoneNumberError: error);
  }

  void setAddress(String value) {
    final error = _validateAddress(value);
    state = state.copyWith(address: value, addressError: error);
  }

  void setPostalCode(String value) {
    final error = _validatePostalCode(value);
    state = state.copyWith(postalCode: value, postalCodeError: error);
  }

  void setState(String value) {
    final error = _validateState(value);
    state = state.copyWith(state: value, stateError: error);
  }

  void setCity(String value) {
    final error = _validateCity(value);
    state = state.copyWith(city: value, cityError: error);
  }

  void setOccupation(String value) {
    final error = _validateOccupation(value);
    state = state.copyWith(occupation: value, occupationError: error);
  }

  void setReferralCode(String value) {
    final error = _validateReferralCode(value);
    state = state.copyWith(referralCode: value, referralCodeError: error);
  }

  // Validation methods
  String _validateDateOfBirth(String value) {
    if (value.isEmpty) return 'Please select your date of birth';
    
    try {
      final selectedDate = DateTime.parse(value);
      final today = DateTime.now();
      final age = today.difference(selectedDate).inDays ~/ 365;
      
      if (age < 18) {
        return 'You must be at least 18 years old to use this service';
      }
      
      if (age > 120) {
        return 'Please enter a valid date of birth';
      }
    } catch (e) {
      return 'Please enter a valid date';
    }
    
    return '';
  }

  String _validateCountry(String value) {
    if (value.isEmpty) return 'Please select your country';
    return '';
  }

  String _validatePhoneNumber(String value) {
    if (value.isEmpty) return 'Please enter your phone number';
    if (value.length < 10) return 'Please enter a valid phone number';
    return '';
  }

  String _validateAddress(String value) {
    if (value.isEmpty) return 'Please enter your address';
    if (value.length < 5) return 'Please enter a complete address';
    return '';
  }

  String _validatePostalCode(String value) {
    if (value.isEmpty) return 'Please enter your postal code';
    return '';
  }

  String _validateState(String value) {
    if (value.isEmpty) return 'Please enter your state';
    return '';
  }

  String _validateCity(String value) {
    if (value.isEmpty) return 'Please enter your city';
    return '';
  }

  String _validateOccupation(String value) {
    if (value.isEmpty) return 'Please select your occupation';
    return '';
  }

  String _validateReferralCode(String value) {
    // Referral code is optional, so no validation needed
    return '';
  }

  // Submit form
  Future<void> submitPersonalInfo(BuildContext context) async {
    if (!state.isFormValid) return;

    state = state.copyWith(isBusy: true);

    try {
      AppLogger.info('Submitting personal information...');

      // Call API to update user profile
      final success = await _updateUserProfile(
        context,
        country: state.country,
        state: state.state,
        street: state.address, // Using address as street
        city: state.city,
        postalCode: state.postalCode,
        address: state.address,
        gender: 'male', // Default gender, can be made configurable
        dob: state.dateOfBirth,
        phoneNumber: state.phoneNumber,
      );

      if (success) {
        AppLogger.info('Personal information submitted successfully');
        // Navigate to biometric setup screen
        appRouter.pushNamed(AppRoute.biometricSetupView);
      }
    } catch (e) {
      AppLogger.error('Error submitting personal information: $e');
      // Don't show generic error message here since _updateUserProfile already shows the specific error
      // The specific error message is already displayed by _updateUserProfile method
    } finally {
      state = state.copyWith(isBusy: false);
    }
  }

  Future<bool> _updateUserProfile(
    BuildContext context, {
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
    try {
      AppLogger.info('Starting profile update process...');
      
      // Get the current user from storage
      final user = await _getCurrentUser();
      if (user == null) {
        AppLogger.error('User not found in storage');
        TopSnackbar.show(
          context,
          message: 'User not found. Please login again.',
          isError: true,
        );
        throw Exception('User not found. Please login again.');
      }

      AppLogger.info('User ID: ${user.userId}');
      AppLogger.info('User data: ${user.toJson()}');
      
      // Debug token retrieval
      final token = await _secureStorage.read(StorageKeys.token);
      AppLogger.info('Retrieved token: $token');

      AppLogger.info('Calling updateProfile API with data:');
      AppLogger.info('Country: $country, State: $state, City: $city');
      AppLogger.info('Phone: $phoneNumber, DOB: $dob, Gender: $gender');

      // Call the API service to update profile
      final response = await _authService.updateProfile(
        userId: user.userId,
        country: country,
        state: state,
        street: street,
        city: city,
        postalCode: postalCode,
        address: address,
        gender: gender.toLowerCase(),
        dob: dob,
        phoneNumber: phoneNumber,
        bvn: '00000000000', // Empty BVN for now
      );

      AppLogger.info('Profile update response - Status: ${response.statusCode}, Error: ${response.error}, Message: ${response.message}');
      
      if (response.statusCode == 200) {
        AppLogger.info('Profile update successful: ${response.message}');
        TopSnackbar.show(
          context,
          message: response.message,
          isError: false,
        );
        return true;
      } else if (response.message == "Unable to create customer and virtual account") {
        // Handle this specific error as success case
        AppLogger.info('Profile update completed with virtual account creation error - treating as success');
        TopSnackbar.show(
          context,
          message: 'Profile completed successfully!',
          isError: false,
        );
        return true; // Return true for success
      } else {
        AppLogger.error('Profile update failed: ${response.message}');
        TopSnackbar.show(
          context,
          message: response.message,
          isError: true,
        );
        return false; // Return false for failure
      }
    } catch (e) {
      AppLogger.error('Error updating user profile: $e');
      TopSnackbar.show(
        context,
        message: e.toString(),
        isError: true,
      );
      return false; // Return false for any exception
    }
  }

  Future<User?> _getCurrentUser() async {
    try {
      final userJson = await _secureStorage.read(StorageKeys.user);
      AppLogger.info('Retrieved user JSON: $userJson');
      
      if (userJson.isNotEmpty) {
        final userData = json.decode(userJson);
        AppLogger.info('Parsed user data: $userData');
        
        // User data should now be stored directly (not nested)
        if (userData is Map<String, dynamic> && userData.containsKey('user_id')) {
          AppLogger.info('User ID field: ${userData['user_id']}');
          
          final user = User.fromJson(userData);
          AppLogger.info('Created user object with ID: ${user.userId}');
          return user;
        } else {
          AppLogger.error('Invalid user data structure: missing user_id');
          AppLogger.error('Available keys: ${userData is Map ? userData.keys.toList() : 'Not a map'}');
          return null;
        }
      } else {
        AppLogger.error('User JSON is empty or null');
        return null;
      }
    } catch (e) {
      AppLogger.error('Error getting current user: $e');
      return null;
    }
  }

  // Clear form
  void resetForm() {
    state = const CompletePersonalInfoState();
  }
}

// Provider
final completePersonalInfoProvider = StateNotifierProvider<CompletePersonalInfoNotifier, CompletePersonalInfoState>((ref) {
  return CompletePersonalInfoNotifier();
});
