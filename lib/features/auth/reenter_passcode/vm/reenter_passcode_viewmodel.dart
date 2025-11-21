import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/services/local/secure_storage.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/constants/storage_keys.dart';
import 'package:dayfi/models/user_model.dart';
import 'package:flutter_svg/svg.dart';

class ReenterPasscodeState {
  final String passcode;
  final bool isBusy;
  final String errorMessage;

  const ReenterPasscodeState({
    this.passcode = '',
    this.isBusy = false,
    this.errorMessage = '',
  });

  bool get isPasscodeComplete => passcode.length == 4;

  ReenterPasscodeState copyWith({
    String? passcode,
    bool? isBusy,
    String? errorMessage,
  }) {
    return ReenterPasscodeState(
      passcode: passcode ?? this.passcode,
      isBusy: isBusy ?? this.isBusy,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ReenterPasscodeNotifier extends StateNotifier<ReenterPasscodeState> {
  final SecureStorageService _secureStorage;
  final bool isFromSignup;

  ReenterPasscodeNotifier({
    SecureStorageService? secureStorage,
    this.isFromSignup = false,
  }) : _secureStorage = secureStorage ?? _getSecureStorage(),
       super(const ReenterPasscodeState());

  static SecureStorageService _getSecureStorage() {
    return locator<SecureStorageService>();
  }

  void updatePasscode(String value, BuildContext context) {
    state = state.copyWith(
      passcode: value,
      errorMessage: '', // Clear error when user types
    );

    // Auto-verify when passcode is complete
    if (state.isPasscodeComplete) {
      _verifyPasscode(context);
    }
  }

  Future<void> _verifyPasscode(BuildContext context) async {
    if (state.isBusy) return;

    state = state.copyWith(isBusy: true, errorMessage: '');

    try {
      AppLogger.info('Verifying passcode...');

      // Get the temporary passcode from storage
      final tempPasscode = await _secureStorage.read('temp_passcode');

      if (tempPasscode.isEmpty) {
        state = state.copyWith(
          errorMessage: 'No passcode found. Please create a new one.',
        );
        return;
      }

      // Compare passcodes
      if (state.passcode == tempPasscode) {
        AppLogger.info('Passcode verification successful');

        // Save the passcode permanently
        await _secureStorage.write(StorageKeys.passcode, state.passcode);

        // Clean up temporary passcode and password
        await _secureStorage.delete('temp_passcode');
        await _secureStorage.delete('password');

        // Show success dialog before navigating
        _showSuccessDialog(context);
      } else {
        AppLogger.warning('Passcode mismatch');
        state = state.copyWith(
          passcode: '', // Clear the passcode
          errorMessage: 'Passcode mismatch. Please try again.',
        );
      }
    } catch (e) {
      AppLogger.error('Error verifying passcode: $e');
      state = state.copyWith(
        errorMessage: 'Passcode verification failed. Please try again.',
      );
    } finally {
      state = state.copyWith(isBusy: false);
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Container(
            padding: EdgeInsets.all(28.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success icon with enhanced styling
                SizedBox(
                  width: 80.w,
                  height: 80.w,
                  child: SvgPicture.asset('assets/icons/svgs/successs.svg'),
                ),

                SizedBox(height: 24.h),

                // Title with auth view styling
                Text(
                  'You have successfully created your passcode to access the app',
                  style: TextStyle(
                    fontFamily: 'CabinetGrotesk',
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 16.h),

                // Continue button with auth view styling
                PrimaryButton(
                  text: 'Continue',
                  onPressed: () async {
                    Navigator.of(context).pop();
                    // Check if user's phone number is empty (regardless of flow)
                    final user = await _getCurrentUser();
                    if (isFromSignup ||
                        user?.phoneNumber == null ||
                        user?.phoneNumber?.isEmpty == true) {
                      // Either from signup flow OR phone number is empty, navigate to success signup view
                      AppLogger.info(
                        'Navigating to success signup view - isFromSignup: $isFromSignup, phoneNumber: ${user?.phoneNumber}',
                      );
                      appRouter.pushNamed(AppRoute.successSignupView);
                    } else {
                      // Check if ID verification is complete
                      final hasValidId =
                          user?.idType != null &&
                          user?.idType?.isNotEmpty == true &&
                          user?.idNumber != null &&
                          user?.idNumber?.isNotEmpty == true;

                      if (!hasValidId) {
                        // ID verification not completed, navigate to upload documents
                        AppLogger.info(
                          'ID verification not complete - navigating to upload documents. idType: ${user?.idType}, idNumber: ${user?.idNumber}',
                        );
                        appRouter.pushNamed(AppRoute.uploadDocumentsView);
                      } else {
                      // Check if biometric setup is needed based on user profile flag
                      final refreshedUser = await _getCurrentUser();
                      if (refreshedUser?.isBiometricsSetup == true) {
                        appRouter.pushMainAndClearStack();
                      } else {
                        appRouter.pushNamed(AppRoute.biometricSetupView);
                      }
                      }
                    }
                  },
                  backgroundColor: AppColors.purple500,
                  textColor: AppColors.neutral0,
                  borderRadius: 38,
                  height: 48.000.h,
                  width: double.infinity,
                  fullWidth: true,
                  fontFamily: 'Karla',
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -.8,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Get current user from secure storage
  Future<User?> _getCurrentUser() async {
    try {
      final userJson = await _secureStorage.read(StorageKeys.user);
      if (userJson.isNotEmpty) {
        final userData = json.decode(userJson);
        return User.fromJson(userData);
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting current user: $e');
      return null;
    }
  }

  void resetForm() {
    state = const ReenterPasscodeState();
  }

  @override
  void dispose() {
    resetForm();
    super.dispose();
  }
}

// Provider
final reenterPasscodeProvider = StateNotifierProvider.family<
  ReenterPasscodeNotifier,
  ReenterPasscodeState,
  bool
>((ref, isFromSignup) {
  return ReenterPasscodeNotifier(isFromSignup: isFromSignup);
});
