import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/services/remote/auth_service.dart';
import 'package:dayfi/services/remote/network/api_error.dart';
import 'package:dayfi/features/auth/dayfi_tag/views/dayfi_tag_success_dialog.dart';

// DayFi Tag to DayFi Tag transfers are limited to NGN (Nigerian Naira) only
const String dayfiTagAllowedCurrency = 'NGN';

class DayfiTagState {
  final String dayfiId;
  final bool isBusy;
  final bool isValidating;
  final String dayfiIdError;
  final String? dayfiIdResponse;

  const DayfiTagState({
    this.dayfiId = '',
    this.isBusy = false,
    this.isValidating = false,
    this.dayfiIdError = '',
    this.dayfiIdResponse,
  });

  bool get isFormValid =>
      dayfiId.isNotEmpty &&
      dayfiIdError.isEmpty &&
      dayfiIdResponse != null &&
      dayfiIdResponse!.contains(
        'User not found',
      ); // For creation, tag should be available (not found)

  bool get isDayfiIdValid =>
      dayfiId.isNotEmpty && dayfiId.startsWith('@') && dayfiId.length >= 3;

  DayfiTagState copyWith({
    String? dayfiId,
    bool? isBusy,
    bool? isValidating,
    String? dayfiIdError,
    String? dayfiIdResponse,
    bool clearDayfiIdResponse = false,
  }) {
    return DayfiTagState(
      dayfiId: dayfiId ?? this.dayfiId,
      isBusy: isBusy ?? this.isBusy,
      isValidating: isValidating ?? this.isValidating,
      dayfiIdError: dayfiIdError ?? this.dayfiIdError,
      dayfiIdResponse:
          clearDayfiIdResponse
              ? null
              : (dayfiIdResponse ?? this.dayfiIdResponse),
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
      // Clear validation response and error when user starts typing
      state = state.copyWith(
        dayfiId: newValue,
        dayfiIdError: error,
        clearDayfiIdResponse:
            true, // Clear the success/error message when input changes
        isValidating: false, // Reset validating state when input changes
      );

      // Cancel existing debounce timer
      _debounceTimer?.cancel();

      // Only validate if input is valid
      if (error.isEmpty && state.isDayfiIdValid) {
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

        // Show success dialog BEFORE popping
        await showModalBottomSheet(
          barrierColor: Colors.black.withOpacity(0.85),
          // ignore: use_build_context_synchronously
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          isDismissible: false,
          enableDrag: false,
          builder:
              (dialogContext) => DayfiTagSuccessDialog(
                dayfiId: state.dayfiId,
                parentContext: context,
                onClose: () {
                  Navigator.pop(context, state.dayfiId);
                },
              ),
        );
      } else {
        AppLogger.error('DayFi Tag creation failed: ${response.message}');
        TopSnackbar.show(
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
        context,
        message: 'Something went wrong. Please try again.',
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
final dayfiTagProvider = StateNotifierProvider<DayfiTagNotifier, DayfiTagState>(
  (ref) => DayfiTagNotifier(),
);
