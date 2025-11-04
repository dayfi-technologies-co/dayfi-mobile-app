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

class BvnNinVerificationState {
  final String bvn;
  final String nin;
  final bool isBusy;
  final String bvnError;
  final String ninError;

  const BvnNinVerificationState({
    this.bvn = '',
    this.nin = '',
    this.isBusy = false,
    this.bvnError = '',
    this.ninError = '',
  });

  bool get isFormValid =>
      bvn.isNotEmpty &&
      nin.isNotEmpty &&
      bvnError.isEmpty &&
      ninError.isEmpty;

  BvnNinVerificationState copyWith({
    String? bvn,
    String? nin,
    bool? isBusy,
    String? bvnError,
    String? ninError,
  }) {
    return BvnNinVerificationState(
      bvn: bvn ?? this.bvn,
      nin: nin ?? this.nin,
      isBusy: isBusy ?? this.isBusy,
      bvnError: bvnError ?? this.bvnError,
      ninError: ninError ?? this.ninError,
    );
  }
}

class BvnNinVerificationNotifier
    extends StateNotifier<BvnNinVerificationState> {
  final AuthService _authService = authService;
  final SecureStorageService _secureStorage = locator<SecureStorageService>();

  BvnNinVerificationNotifier() : super(const BvnNinVerificationState());

  // Setters
  void setBvn(String value) {
    final error = _validateBvn(value);
    state = state.copyWith(bvn: value, bvnError: error);
  }

  void setNin(String value) {
    final error = _validateNin(value);
    state = state.copyWith(nin: value, ninError: error);
  }

  // Validation methods
  String _validateBvn(String value) {
    if (value.isEmpty) return 'Please enter your BVN';
    if (value.length != 11) {
      return 'BVN must be exactly 11 digits';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'BVN must contain only numbers';
    }
    return '';
  }

  String _validateNin(String value) {
    if (value.isEmpty) return 'Please enter your NIN';
    if (value.length != 11) {
      return 'NIN must be exactly 11 digits';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'NIN must contain only numbers';
    }
    return '';
  }

  // Submit form
  Future<void> submitVerification(BuildContext context) async {
    if (!state.isFormValid) {
      return;
    }

    state = state.copyWith(isBusy: true);

    try {
      AppLogger.info('Starting BVN/NIN verification...');

      // First verify BVN
      final bvnSuccess = await _verifyBvn(context, state.bvn);
      if (!bvnSuccess) {
        state = state.copyWith(isBusy: false);
        return;
      }

      // Then update profile with NIN
      final ninSuccess = await _updateProfileWithNin(context, state.nin);
      if (!ninSuccess) {
        state = state.copyWith(isBusy: false);
        return;
      }

      // Success - navigate based on biometrics flag
      AppLogger.info('BVN/NIN verification completed successfully');
      TopSnackbar.show(
        context,
        message: 'Verification completed successfully',
        isError: false,
      );

      final user = await _getCurrentUser();
      if (user?.isBiometricsSetup == true) {
        appRouter.pushMainAndClearStack();
      } else {
        appRouter.pushNamed(AppRoute.biometricSetupView);
      }
    } catch (e) {
      AppLogger.error('Error verifying BVN/NIN: $e');
      TopSnackbar.show(
        context,
        message: 'Verification failed. Please try again.',
        isError: true,
      );
    } finally {
      state = state.copyWith(isBusy: false);
    }
  }

  // Verify BVN
  Future<bool> _verifyBvn(BuildContext context, String bvn) async {
    try {
      AppLogger.info('Verifying BVN...');

      final response = await _authService.verifyBVN(bvn: bvn);

      AppLogger.info(
        'BVN verification response - Status: ${response.statusCode}, Error: ${response.error}, Message: ${response.message}',
      );

      if (response.statusCode == 200 && !response.error) {
        AppLogger.info('BVN verification successful: ${response.message}');
        return true;
      } else {
        AppLogger.error('BVN verification failed: ${response.message}');
        TopSnackbar.show(
          context,
          message: response.message,
          isError: true,
        );
        return false;
      }
    } catch (e) {
      AppLogger.error('Error verifying BVN: $e');
      TopSnackbar.show(
        context,
        message: 'Failed to verify BVN. Please try again.',
        isError: true,
      );
      return false;
    }
  }

  // Update profile with NIN
  Future<bool> _updateProfileWithNin(BuildContext context, String nin) async {
    try {
      AppLogger.info('Updating profile with NIN...');

      // Get the current user from storage
      final user = await _getCurrentUser();
      if (user == null) {
        AppLogger.error('User not found in storage');
        TopSnackbar.show(
          context,
          message: 'User not found. Please login again.',
          isError: true,
        );
        return false;
      }

      AppLogger.info('User ID: ${user.userId}');

      final response = await _authService.updateProfileWithNIN(
        userId: user.userId,
        nin: nin,
      );

      AppLogger.info(
        'Profile update response - Status: ${response.statusCode}, Error: ${response.error}, Message: ${response.message}',
      );

      if (response.statusCode == 200 && !response.error) {
        AppLogger.info('Profile update successful: ${response.message}');
        return true;
      } else {
        AppLogger.error('Profile update failed: ${response.message}');
        TopSnackbar.show(
          context,
          message: response.message,
          isError: true,
        );
        return false;
      }
    } catch (e) {
      AppLogger.error('Error updating profile: $e');
      TopSnackbar.show(
        context,
        message: 'Failed to update profile. Please try again.',
        isError: true,
      );
      return false;
    }
  }

  // Get current user from storage
  Future<User?> _getCurrentUser() async {
    try {
      final userJson = await _secureStorage.read(StorageKeys.user);
      AppLogger.info('Retrieved user JSON: $userJson');

      if (userJson.isNotEmpty) {
        final userData = json.decode(userJson);
        AppLogger.info('Parsed user data: $userData');

        if (userData is Map<String, dynamic> && userData.containsKey('user_id')) {
          final user = User.fromJson(userData);
          AppLogger.info('Created user object with ID: ${user.userId}');
          return user;
        } else {
          AppLogger.error('Invalid user data structure: missing user_id');
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
    state = const BvnNinVerificationState();
  }
}

// Provider
final bvnNinVerificationProvider =
    StateNotifierProvider<BvnNinVerificationNotifier, BvnNinVerificationState>(
  (ref) => BvnNinVerificationNotifier(),
);

