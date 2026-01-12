import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/services/local/secure_storage.dart';
import 'package:dayfi/routes/route.dart';

class CreatePasscodeState {
  final String passcode;
  final bool isBusy;
  final String errorMessage;

  const CreatePasscodeState({
    this.passcode = '',
    this.isBusy = false,
    this.errorMessage = '',
  });

  bool get isPasscodeComplete => passcode.length == 4;

  CreatePasscodeState copyWith({
    String? passcode,
    bool? isBusy,
    String? errorMessage,
  }) {
    return CreatePasscodeState(
      passcode: passcode ?? this.passcode,
      isBusy: isBusy ?? this.isBusy,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class CreatePasscodeNotifier extends StateNotifier<CreatePasscodeState> {
  final SecureStorageService _secureStorage;
  final bool isFromSignup;

  CreatePasscodeNotifier({
    SecureStorageService? secureStorage,
    this.isFromSignup = false,
  }) : _secureStorage = secureStorage ?? _getSecureStorage(),
       super(const CreatePasscodeState());

  static SecureStorageService _getSecureStorage() {
    return locator<SecureStorageService>();
  }

  void updatePasscode(String value) {
    state = state.copyWith(
      passcode: value,
      errorMessage: '', // Clear error when user types
    );

    // Auto-navigate when passcode is complete
    if (state.isPasscodeComplete) {
      _navigateToReenterPasscode();
    }
  }

  Future<void> _navigateToReenterPasscode() async {
    try {
      // Store the passcode temporarily
      await _secureStorage.write('temp_passcode', state.passcode);
      
      // Navigate to re-enter passcode screen with isFromSignup parameter
      appRouter.pushNamed(
        AppRoute.reenterPasscodeView,
        arguments: isFromSignup,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to save passcode. Please try again.',
      );
    }
  }

  void resetForm() {
    state = const CreatePasscodeState();
  }

  @override
  void dispose() {
    resetForm();
    super.dispose();
  }
}

// Provider
final createPasscodeProvider = StateNotifierProvider.family<CreatePasscodeNotifier, CreatePasscodeState, bool>((ref, isFromSignup) {
  return CreatePasscodeNotifier(isFromSignup: isFromSignup);
});
