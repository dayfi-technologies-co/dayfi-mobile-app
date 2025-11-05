import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/send/vm/transaction_pin_viewmodel.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/services/local/secure_storage.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';

class ChangeTransactionPinConfirmView extends ConsumerStatefulWidget {
  const ChangeTransactionPinConfirmView({super.key});

  @override
  ConsumerState<ChangeTransactionPinConfirmView> createState() =>
      _ChangeTransactionPinConfirmViewState();
}

class _ChangeTransactionPinConfirmViewState
    extends ConsumerState<ChangeTransactionPinConfirmView> {
  final SecureStorageService _secureStorage = locator<SecureStorageService>();
  String? _tempOldPin;
  String? _tempNewPin;
  String _localPin = '';
  String _errorMessage = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTempPins();
    // Reset the shared provider state when entering this view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transactionPinProvider.notifier).resetForm();
    });
  }

  Future<void> _loadTempPins() async {
    final oldPin = await _secureStorage.read('temp_old_transaction_pin');
    final newPin = await _secureStorage.read('temp_new_transaction_pin');
    setState(() {
      _tempOldPin = oldPin.isNotEmpty ? oldPin : null;
      _tempNewPin = newPin.isNotEmpty ? newPin : null;
    });
  }

  void _updateLocalPin(String value) {
    setState(() {
      _localPin = value;
      _errorMessage = '';
    });
    // Also update the shared provider for consistency
    ref.read(transactionPinProvider.notifier).updatePin(value);
  }

  bool _validatePin(String pin) {
    if (pin.length != 4) {
      return false;
    }
    // Validate that PIN contains only digits
    if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
      setState(() {
        _errorMessage = 'PIN must contain only numbers';
      });
      return false;
    }
    return true;
  }

  Future<void> _verifyAndChangePin(String confirmedPin) async {
    if (_isLoading) return; // Prevent multiple calls

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final pinNotifier = ref.read(transactionPinProvider.notifier);

    if (_tempOldPin == null || _tempNewPin == null) {
      setState(() {
        _errorMessage = 'PIN data not found. Please start over.';
        _isLoading = false;
      });
      pinNotifier.setError(_errorMessage);
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
      return;
    }

    // Validate PIN format first
    if (!_validatePin(confirmedPin)) {
      // Error message already set in _validatePin
      pinNotifier.setError(_errorMessage);
      pinNotifier.setPin('');
      setState(() {
        _localPin = '';
        _isLoading = false;
      });
      return;
    }

    // Verify that confirmed PIN matches new PIN
    if (confirmedPin != _tempNewPin) {
      setState(() {
        _errorMessage = 'PIN mismatch. Please try again.';
        _localPin = '';
        _isLoading = false;
      });
      pinNotifier.setError(_errorMessage);
      pinNotifier.setPin('');
      return;
    }

    try {
      // PINs match, change it
      final success = await pinNotifier.changeTransactionPin(
        newPin: confirmedPin,
        oldPin: _tempOldPin!,
      );

      if (success) {
        // Clear temp pins
        await _secureStorage.delete('temp_old_transaction_pin');
        await _secureStorage.delete('temp_new_transaction_pin');
        AppLogger.info('Transaction PIN changed successfully');

        // Refresh profile to get updated user data
        await ref.read(profileViewModelProvider.notifier).loadUserProfile();

        // Pop all three views (old, new, confirm)
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);

        // Show success message
        TopSnackbar.show(
          context,
          message: 'Transaction PIN changed successfully',
          isError: false,
        );
      } else {
        final updatedState = ref.read(transactionPinProvider);
        final error = updatedState.errorMessage;
        setState(() {
          _errorMessage = error;
          _localPin = '';
          _isLoading = false;
        });
        TopSnackbar.show(
          context,
          message: error,
          isError: true,
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to change PIN. Please try again.';
        _isLoading = false;
      });
      TopSnackbar.show(
        context,
        message: 'Failed to change PIN. Please try again.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pinNotifier = ref.read(transactionPinProvider.notifier);

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              pinNotifier.resetForm();
              setState(() {
                _localPin = '';
                _errorMessage = '';
              });
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          title: Text(
            "Confirm New Transaction PIN",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontFamily: 'CabinetGrotesk',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          centerTitle: true,
        ),
        body: GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 4.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: Text(
                            "Please re-enter your new 4-digit transaction PIN to confirm. This PIN will be required for all wallet transfers.",
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Karla',
                                  letterSpacing: -.6,
                                  height: 1.4,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: PasscodeWidget(
                      passcodeLength: 4,
                      currentPasscode: _localPin,
                      onPasscodeChanged: (value) {
                        _updateLocalPin(value);
                      },
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.width * 0.15),
                  // Continue button - only show when PIN is complete
                  if (_localPin.length == 4)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: PrimaryButton(
                        text: 'Change PIN',
                        onPressed: _localPin.length == 4 &&
                                _errorMessage.isEmpty &&
                                !_isLoading
                            ? () => _verifyAndChangePin(_localPin)
                            : null,
                        isLoading: _isLoading,
                        showLoadingIndicator: true,
                        height: 60.h,
                        backgroundColor: _localPin.length == 4 &&
                                _errorMessage.isEmpty &&
                                !_isLoading
                            ? AppColors.purple500
                            : AppColors.neutral0.withOpacity(0.12),
                        textColor: _localPin.length == 4 &&
                                _errorMessage.isEmpty &&
                                !_isLoading
                            ? AppColors.neutral0
                            : AppColors.neutral0.withOpacity(0.5),
                        fontFamily: 'Karla',
                        letterSpacing: -.8,
                        fontSize: 18,
                        width: double.infinity,
                        fullWidth: true,
                        borderRadius: 40.r,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 200.ms)
                        .slideY(begin: 0.2, end: 0, duration: 200.ms),
                  SizedBox(height: 16.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Text(
                      _errorMessage.isNotEmpty
                          ? _errorMessage
                          : ref.watch(transactionPinProvider).errorMessage,
                      style: TextStyle(
                        fontFamily: 'Karla',
                        fontSize: 13.sp,
                        color: Colors.red.shade800,
                        letterSpacing: -0.4,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Reuse PasscodeWidget
class PasscodeWidget extends StatelessWidget {
  final int passcodeLength;
  final String currentPasscode;
  final Function(String) onPasscodeChanged;

  const PasscodeWidget({
    super.key,
    required this.passcodeLength,
    required this.currentPasscode,
    required this.onPasscodeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: MediaQuery.of(context).size.width * 0.075),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            passcodeLength,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Text(
                index < currentPasscode.length ? '*' : '*',
                style: TextStyle(
                  fontSize: 88.sp,
                  letterSpacing: -10,
                  fontFamily: 'CabinetGrotesk',
                  fontWeight: FontWeight.w700,
                  color: index < currentPasscode.length
                      ? AppColors.purple500ForTheme(context)
                      : AppColors.neutral500,
                ),
              ),
            ),
          ),
        ),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          childAspectRatio: 1.5,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            ...List.generate(9, (index) {
              final number = (index + 1).toString();
              return _buildNumberButton(number);
            }),
            const SizedBox.shrink(),
            _buildNumberButton('0'),
            _buildIconButton(
              icon: Icons.arrow_back_ios,
              onTap: () {
                if (currentPasscode.isNotEmpty) {
                  onPasscodeChanged(
                    currentPasscode.substring(0, currentPasscode.length - 1),
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberButton(String number) {
    return Builder(
      builder: (context) => InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        borderRadius: BorderRadius.circular(100),
        onTap: () {
          if (currentPasscode.length < passcodeLength) {
            onPasscodeChanged(currentPasscode + number);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                fontSize: 32.00,
                fontFamily: 'CabinetGrotesk',
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
          ),
          child: Center(
              child: Icon(icon, color: AppColors.purple500ForTheme(context))),
        ),
      ),
    );
  }
}

