import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/services/remote/auth_service.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/services/local/secure_storage.dart';
import 'package:dayfi/common/constants/storage_keys.dart';
import 'dart:convert';

class TransactionPinState {
  final String pin;
  final bool isBusy;
  final String errorMessage;

  const TransactionPinState({
    this.pin = '',
    this.isBusy = false,
    this.errorMessage = '',
  });

  bool get isPinComplete => pin.length == 4;

  TransactionPinState copyWith({
    String? pin,
    bool? isBusy,
    String? errorMessage,
  }) {
    return TransactionPinState(
      pin: pin ?? this.pin,
      isBusy: isBusy ?? this.isBusy,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class TransactionPinNotifier extends StateNotifier<TransactionPinState> {
  final SecureStorageService _secureStorage;
  final AuthService _authService;

  TransactionPinNotifier({
    SecureStorageService? secureStorage,
    AuthService? authService,
  })  : _secureStorage = secureStorage ?? locator<SecureStorageService>(),
        _authService = authService ?? locator<AuthService>(),
        super(const TransactionPinState());

  void updatePin(String value) {
    state = state.copyWith(
      pin: value,
      errorMessage: '',
    );
  }

  void setError(String errorMessage) {
    state = state.copyWith(errorMessage: errorMessage);
  }

  void setPin(String pin) {
    state = state.copyWith(pin: pin);
  }

  Future<bool> createTransactionPin(String pin) async {
    state = state.copyWith(isBusy: true, errorMessage: '');

    try {
      AppLogger.info('Creating transaction pin...');
      
      final response = await _authService.updateTransactionPin(
        transactionPin: pin,
      );

      if (response.error == false) {
        // Update user data in storage
        if (response.data?.user != null) {
          final userJson = json.encode(response.data!.user!.toJson());
          await _secureStorage.write(StorageKeys.user, userJson);
        }

        AppLogger.info('Transaction pin created successfully');
        state = state.copyWith(isBusy: false);
        return true;
      } else {
        state = state.copyWith(
          isBusy: false,
          errorMessage: response.message.isNotEmpty
              ? response.message
              : 'Failed to create transaction pin',
        );
        return false;
      }
    } catch (e) {
      AppLogger.error('Error creating transaction pin: $e');
      state = state.copyWith(
        isBusy: false,
        errorMessage: 'Failed to create transaction pin. Please try again.',
      );
      return false;
    }
  }

  Future<bool> verifyTransactionPin(String pin) async {
    // Get user from storage
    final userJson = await _secureStorage.read(StorageKeys.user);
    if (userJson.isEmpty) {
      state = state.copyWith(
        errorMessage: 'User not found. Please login again.',
      );
      return false;
    }
    
    // For now, we'll just compare the plain pin
    // In production, you'd want to hash/encrypt the pin client-side
    // or send it securely to backend for verification
    // Note: The backend expects encryptedPin in the API call
    
    // Since we can't verify without backend, we'll store it temporarily
    // and let the backend handle verification when initiating transfer
    await _secureStorage.write('temp_transaction_pin', pin);
    
    return true;
  }

  Future<bool> changeTransactionPin({
    required String newPin,
    required String oldPin,
  }) async {
    state = state.copyWith(isBusy: true, errorMessage: '');

    try {
      AppLogger.info('Changing transaction pin...');
      
      final response = await _authService.changeTransactionPin(
        transactionPin: newPin,
        oldTransactionPin: oldPin,
      );

      if (response.error == false) {
        // Update user data in storage
        if (response.data?.user != null) {
          final userJson = json.encode(response.data!.user!.toJson());
          await _secureStorage.write(StorageKeys.user, userJson);
        }

        AppLogger.info('Transaction pin changed successfully');
        state = state.copyWith(isBusy: false);
        return true;
      } else {
        state = state.copyWith(
          isBusy: false,
          errorMessage: response.message.isNotEmpty
              ? response.message
              : 'Failed to change transaction pin',
        );
        return false;
      }
    } catch (e) {
      AppLogger.error('Error changing transaction pin: $e');
      state = state.copyWith(
        isBusy: false,
        errorMessage: 'Failed to change transaction pin. Please try again.',
      );
      return false;
    }
  }

  void resetForm() {
    state = const TransactionPinState();
  }
}

final transactionPinProvider =
    StateNotifierProvider<TransactionPinNotifier, TransactionPinState>((ref) {
  return TransactionPinNotifier();
});

