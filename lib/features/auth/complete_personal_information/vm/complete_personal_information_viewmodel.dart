import 'dart:async';
import 'dart:convert';
import 'package:dayfi/services/remote/network/api_error.dart';
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
  final String dayfiId;
  final String dayfiIdError;
  final String dayfiIdResponse;
  final bool isValidating;
  final bool clearDayfiIdResponse;
  // Helper for validation
  bool get isDayfiIdValid =>
      dayfiId.isNotEmpty && dayfiIdError.isEmpty && dayfiId.length > 3;
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
    this.dayfiId = '',
    this.dayfiIdError = '',
    this.dayfiIdResponse = '',
    this.isValidating = false,
    this.clearDayfiIdResponse = false,
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
    String? dayfiId,
    String? dayfiIdError,
    String? dayfiIdResponse,
    bool? isValidating,
    bool? clearDayfiIdResponse,
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
      dayfiId: dayfiId ?? this.dayfiId,
      dayfiIdError: dayfiIdError ?? this.dayfiIdError,
      dayfiIdResponse: dayfiIdResponse ?? this.dayfiIdResponse,
      isValidating: isValidating ?? this.isValidating,
      clearDayfiIdResponse: clearDayfiIdResponse ?? this.clearDayfiIdResponse,
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

class CompletePersonalInfoNotifier
    extends StateNotifier<CompletePersonalInfoState> {
  final AuthService _authService = authService;
  final SecureStorageService _secureStorage = locator<SecureStorageService>();
  Timer? _debounceTimer;

  /// DayFi Tag rules:
  /// - Must start with @
  /// - Max 16 characters (including @)
  /// - No spaces
  /// - Only a-z, 0-9, _ or -
  /// - No other special characters
  void setDayfiId(String value) {
    String newValue = value.trim();
    String error = '';

    // Automatically add @ if missing
    if (!newValue.startsWith('@')) {
      newValue = '@${newValue.replaceAll('@', '')}';
    }

    // Check for spaces
    if (newValue.contains(' ')) {
      error = 'No spaces allowed';
    }
    // Check for max length
    else if (newValue.length > 16) {
      error = 'Max 16 characters (including @)';
    }
    // Check for allowed characters
    else if (!RegExp(r'^@[a-zA-Z0-9_-]*$').hasMatch(newValue)) {
      error = 'Only a-z, 0-9, _ or - (no other special characters)';
    }

    // Only update if the value or error has changed
    if (newValue != state.dayfiId || error != state.dayfiIdError) {
      state = state.copyWith(
        dayfiId: newValue,
        dayfiIdError: error,
        clearDayfiIdResponse: true,
        isValidating: false,
      );

      // Cancel existing debounce timer
      _debounceTimer?.cancel();

      // Only validate with API if input is valid and no error
      if (error.isEmpty && newValue.length > 1) {
        _debounceTimer = Timer(const Duration(milliseconds: 500), () {
          validateDayfiId(newValue);
        });
      }
    }
  }

  String _validateDayfiId(String value) {
    value = value.trim();
    if (value.isEmpty) return 'Please enter a DayFi Tag';
    if (!value.startsWith('@')) return 'Your tag should start with @';
    if (value.length < 3) return 'Your tag needs at least 3 characters';
    return '';
  }

  Future<void> validateDayfiId(String dayfiId) async {
    // Set validating state to true and clear previous response
    state = state.copyWith(isValidating: true, clearDayfiIdResponse: true);

    try {
      final response = await _authService.validateDayfiId(dayfiId: dayfiId);

      if (response.error == false && response.data != null) {
        final accountName = response.data['accountName'] ?? 'someone';
        // Tag is taken
        state = state.copyWith(
          dayfiIdResponse: 'This tag belongs to $accountName',
          dayfiIdError: 'This tag is already taken. Try something different.',
          isValidating: false,
        );
      } else {
        // Tag is available for creation
        state = state.copyWith(
          dayfiIdResponse: 'User not found',
          dayfiIdError: '',
          isValidating: false,
        );

        // enable next button for tab
      }
    } catch (e) {
      // Check if this is a 400 error with "Invalid dayfi ID" message - treat as success (tag available)
      if (e is ApiError) {
        if (e.errorType == 400) {
          final errorMessage =
              e.apiErrorModel?.message ?? e.errorDescription ?? '';
          if (errorMessage.toLowerCase().contains('invalid dayfi id')) {
            // Treat as success - tag is available
            AppLogger.info(
              'Invalid dayfi ID (400) - treating as available tag',
            );
            state = state.copyWith(
              dayfiIdResponse: 'User not found',
              dayfiIdError: '',
              isValidating: false,
            );
            return;
          }
        }
      }

      AppLogger.error('Error validating DayFi Tag: $e');
      state = state.copyWith(
        dayfiIdResponse: 'User not found',
        dayfiIdError: 'Error validating DayFi Tag',
        isValidating: false,
      );
    }
  }

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

    // If starts with 0, require 11 digits, otherwise require 10 digits
    if (value.startsWith('0')) {
      if (value.length != 11) {
        return 'Please enter a valid 11-digit phone number';
      }
    } else {
      if (value.length != 10) {
        return 'Please enter a valid 10-digit phone number';
      }
    }

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
    // if (!state.isFormValid) return;

    state = state.copyWith(isBusy: true);

    try {
      analyticsService.logEvent(name: 'complete_profile_started');
      AppLogger.info('Submitting personal information...');

      // Remove leading 0 from phone number if present
      final phoneNumber =
          state.phoneNumber.startsWith('0')
              ? state.phoneNumber.substring(1)
              : state.phoneNumber;

      // Call API to update user profile, only passing non-empty fields
      final success = await _updateUserProfile(
        context,
        country: state.country.isNotEmpty ? state.country : null,
        state: state.state.isNotEmpty ? state.state : null,
        street: state.address.isNotEmpty ? state.address : null,
        city: state.city.isNotEmpty ? state.city : null,
        address: state.address.isNotEmpty ? state.address : null,
        gender: 'male',
        dob: state.dateOfBirth.isNotEmpty ? state.dateOfBirth : null,
        phoneNumber: phoneNumber.isNotEmpty ? phoneNumber : null,
      );

      if (success) {
        AppLogger.info('Personal information submitted successfully');
        analyticsService.logEvent(name: 'complete_profile_completed');
        // Navigate to upload documents for KYC Tier 2 verification

        await createDayfiId(context);

        appRouter.pushNamed(AppRoute.uploadDocumentsView);
      }
    } catch (e) {
      AppLogger.error('Error submitting personal information: $e');
      analyticsService.logEvent(
        name: 'complete_profile_failed',
        parameters: {'reason': e.toString()},
      );
      // Don't show generic error message here since _updateUserProfile already shows the specific error
      // The specific error message is already displayed by _updateUserProfile method
    } finally {
      state = state.copyWith(isBusy: false);
    }
  }

  Future<void> createDayfiId(BuildContext context) async {
    state = state.copyWith(isBusy: true);

    try {
      AppLogger.info('Creating DayFi Tag: ${state.dayfiId}');

      final response = await _authService.createDayfiId(dayfiId: state.dayfiId);

      if (response.error == false) {
        AppLogger.info('DayFi Tag created successfully');
      } else {
        AppLogger.error('DayFi Tag creation failed: ${response.message}');
        TopSnackbar.show(
          // ignore: use_build_context_synchronously
          context,
          message:
              response.message.isNotEmpty
                  ? response.message
                  : 'Hmm, something went wrong. Please try again.',
          isError: true,
        );
      }
    } catch (e) {
      AppLogger.error('Error creating DayFi Tag: $e');
      TopSnackbar.show(
        // ignore: use_build_context_synchronously
        context,
        message: 'Something went wrong. Please try again.',
        isError: true,
      );
    } finally {
      state = state.copyWith(isBusy: false);
    }
  }

  Future<bool> _updateUserProfile(
    BuildContext context, {
    String? country,
    String? state,
    String? street,
    String? city,
    String? address,
    String? gender,
    String? dob,
    String? phoneNumber,
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

      // Prepare only valid (non-empty, non-null) fields for the API call
      final String? _country = (country != null && country.isNotEmpty) ? country : null;
      final String? _state = (state != null && state.isNotEmpty) ? state : null;
      final String? _street = (street != null && street.isNotEmpty) ? street : null;
      final String? _city = (city != null && city.isNotEmpty) ? city : null;
      final String? _address = (address != null && address.isNotEmpty) ? address : null;
      final String? _gender = (gender != null && gender.isNotEmpty) ? gender.toLowerCase() : null;
      final String? _dob = (dob != null && dob.isNotEmpty) ? dob : null;
      final String? _phoneNumber = (phoneNumber != null && phoneNumber.isNotEmpty) ? phoneNumber : null;

      AppLogger.info('Calling updateProfile API with data:');
      AppLogger.info({
        'userId': user.userId,
        if (_country != null) 'country': _country,
        if (_state != null) 'state': _state,
        if (_street != null) 'street': _street,
        if (_city != null) 'city': _city,
        if (_address != null) 'address': _address,
        if (_gender != null) 'gender': _gender,
        if (_dob != null) 'dob': _dob,
        if (_phoneNumber != null) 'phoneNumber': _phoneNumber,
        'bvn': '00000000000',
      }.toString());

      // Call the API service to update profile, only passing valid fields
      final response = await _authService.updateProfile(
        userId: user.userId,
        country: _country ?? '',
        state: _state ?? '',
        street: _street ?? '',
        city: _city ?? '',
        address: _address ?? '',
        gender: _gender ?? '',
        dob: _dob ?? '',
        phoneNumber: _phoneNumber ?? '',
        bvn: '00000000000',
      );

      AppLogger.info(
        'Profile update response - Status: ${response.statusCode}, Error: ${response.error}, Message: ${response.message}',
      );

      if (response.statusCode == 200) {
        AppLogger.info('Profile update successful: ${response.message}');
        TopSnackbar.show(context, message: response.message, isError: false);
        return true;
      } else if (response.message ==
          "Unable to create customer and virtual account") {
        // Handle this specific error as success case
        AppLogger.info(
          'Profile update completed with virtual account creation error - treating as success',
        );
        TopSnackbar.show(
          context,
          message: 'Profile completed successfully!',
          isError: false,
        );
        return true; // Return true for success
      } else {
        AppLogger.error('Profile update failed: ${response.message}');
        TopSnackbar.show(context, message: response.message, isError: true);
        return false; // Return false for failure
      }
    } catch (e) {
      AppLogger.error('Error updating user profile: $e');
      TopSnackbar.show(context, message: e.toString(), isError: true);
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
        if (userData is Map<String, dynamic> &&
            userData.containsKey('user_id')) {
          AppLogger.info('User ID field: ${userData['user_id']}');

          final user = User.fromJson(userData);
          AppLogger.info('Created user object with ID: ${user.userId}');
          return user;
        } else {
          AppLogger.error('Invalid user data structure: missing user_id');
          AppLogger.error(
            'Available keys: ${userData is Map ? userData.keys.toList() : 'Not a map'}',
          );
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
final completePersonalInfoProvider = StateNotifierProvider<
  CompletePersonalInfoNotifier,
  CompletePersonalInfoState
>((ref) {
  return CompletePersonalInfoNotifier();
});
