import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/services/remote/auth_service.dart';

// DayFi Tag to DayFi Tag transfers are limited to NGN (Nigerian Naira) only
const String dayfiTagAllowedCurrency = 'NGN';

class DayfiTagState {
  final String dayfiId;
  final bool isBusy;
  final String dayfiIdError;
  final String? dayfiIdResponse;

  const DayfiTagState({
    this.dayfiId = '',
    this.isBusy = false,
    this.dayfiIdError = '',
    this.dayfiIdResponse,
  });

  bool get isFormValid =>
      dayfiId.isNotEmpty &&
      dayfiIdError.isEmpty &&
      dayfiIdResponse != null &&
      dayfiIdResponse!.contains('User not found'); // For creation, tag should be available (not found)

  bool get isDayfiIdValid =>
      dayfiId.isNotEmpty &&
      dayfiId.startsWith('@') &&
      dayfiId.length >= 3;

  DayfiTagState copyWith({
    String? dayfiId,
    bool? isBusy,
    String? dayfiIdError,
    String? dayfiIdResponse,
  }) {
    return DayfiTagState(
      dayfiId: dayfiId ?? this.dayfiId,
      isBusy: isBusy ?? this.isBusy,
      dayfiIdError: dayfiIdError ?? this.dayfiIdError,
      dayfiIdResponse: dayfiIdResponse ?? this.dayfiIdResponse,
    );
  }
}

class DayfiTagNotifier extends StateNotifier<DayfiTagState> {
  final AuthService _authService = authService;
  Timer? _debounceTimer;

  DayfiTagNotifier() : super(const DayfiTagState());

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
    if (newValue != state.dayfiId) {
      final error = _validateDayfiId(newValue);
      state = state.copyWith(dayfiId: newValue, dayfiIdError: error);

      // Cancel existing debounce timer
      _debounceTimer?.cancel();

      // Only validate if input is valid
      if (error.isEmpty && state.isDayfiIdValid) {
        _debounceTimer = Timer(const Duration(milliseconds: 500), () {
          validateDayfiId(newValue);
        });
      } else {
        state = state.copyWith(dayfiIdResponse: null);
      }
    }
  }

  String _validateDayfiId(String value) {
    value = value.trim();
    if (value.isEmpty) return 'DayFi Tag is required';
    if (!value.startsWith('@')) return 'DayFi Tag must start with @';
    if (value.length < 3) return 'DayFi Tag must be at least 3 characters';
    return '';
  }

  Future<void> validateDayfiId(String dayfiId) async {
    try {
      final response = await _authService.validateDayfiId(dayfiId: dayfiId);

      if (response.error == false && response.data != null) {
        final accountName = response.data['accountName'] ?? 'User';
        // Tag is taken
        state = state.copyWith(
          dayfiIdResponse: 'This username belongs to $accountName',
          dayfiIdError: 'This DayFi Tag is already taken. Please choose another.',
        );
      } else {
        // Tag is available for creation
        state = state.copyWith(
          dayfiIdResponse: 'User not found',
          dayfiIdError: '',
        );
      }
    } catch (e) {
      AppLogger.error('Error validating DayFi Tag: $e');
      state = state.copyWith(
        dayfiIdResponse: 'User not found',
        dayfiIdError: 'Error validating DayFi Tag',
      );
    }
  }

  Future<void> createDayfiId(BuildContext context) async {
    if (!state.isFormValid) {
      return;
    }

    state = state.copyWith(isBusy: true);

    try {
      AppLogger.info('Creating DayFi Tag: ${state.dayfiId}');

      final response = await _authService.createDayfiId(dayfiId: state.dayfiId);

      if (response.error == false) {
        AppLogger.info('DayFi Tag created successfully');
        
        // Refresh profile to get updated user data
        // Note: We'll need to update the profile viewmodel to refresh user data
        
        TopSnackbar.show(
          context,
          message: 'DayFi Tag created successfully',
          isError: false,
        );

        // Return to previous screen with success
        Navigator.pop(context, state.dayfiId);
      } else {
        AppLogger.error('DayFi Tag creation failed: ${response.message}');
        TopSnackbar.show(
          context,
          message: response.message.isNotEmpty
              ? response.message
              : 'Failed to create DayFi Tag',
          isError: true,
        );
      }
    } catch (e) {
      AppLogger.error('Error creating DayFi Tag: $e');
      TopSnackbar.show(
        context,
        message: 'Failed to create DayFi Tag. Please try again.',
        isError: true,
      );
    } finally {
      state = state.copyWith(isBusy: false);
    }
  }

  void resetForm() {
    _debounceTimer?.cancel();
    state = const DayfiTagState();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

// Provider
final dayfiTagProvider =
    StateNotifierProvider<DayfiTagNotifier, DayfiTagState>(
  (ref) => DayfiTagNotifier(),
);

