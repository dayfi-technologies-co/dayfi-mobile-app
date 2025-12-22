import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:dayfi/common/utils/haptic_helper.dart';
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
        TopSnackbar.show(context, message: error, isError: true);
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
          scrolledUnderElevation: .5,
          foregroundColor: Theme.of(context).scaffoldBackgroundColor,
          shadowColor: Theme.of(context).scaffoldBackgroundColor,
          surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leadingWidth: 72,
                    centerTitle: true,
          leading: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              FocusScope.of(context).unfocus();
              pinNotifier.resetForm();
              // Clear the new PIN state from previous view
              _secureStorage.delete('temp_new_transaction_pin');
              setState(() {
                _localPin = '';
                _errorMessage = '';
              });
              Navigator.pop(context);
            },
            child:   Stack(
                                alignment: AlignmentGeometry.center,
                                children: [
                                  SvgPicture.asset(
                                    "assets/icons/svgs/notificationn.svg",
                                    height: 40,
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                  ),
                                  SizedBox(
                                    height: 40,
                                    width: 40,
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8.0,
                                        ),
                                        child: Icon(
                                          Icons.arrow_back_ios,
                                          size: 20,
                                          color:
                                              Theme.of(
                                                context,
                                              ).textTheme.bodyLarge!.color,
                                          // size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth > 600;
            return GestureDetector(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isWide ? 32 : 18,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              "Confirm new PIN",
                              textAlign: TextAlign.center,
                              style: Theme.of(
                                context,
                              ).textTheme.displayLarge?.copyWith(
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.headlineLarge?.color,
                                fontSize: isWide ? 32 : 28,
                                letterSpacing: -.250,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'FunnelDisplay',
                                height: 1,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(height: 16),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 18,
                                    ),
                                    child: Text(
                                      "Please re-enter your new 4-digit transaction PIN to confirm. This PIN will be required for all wallet transfers.",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Chirp',
                                        letterSpacing: -.25,
                                        height: 1.2,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 12),
                            PasscodeWidget(
                              passcodeLength: 4,
                              currentPasscode: _localPin,
                              onPasscodeChanged: (value) {
                                _updateLocalPin(value);
                              },
                            ),
                            SizedBox(
                              height:
                                  isWide
                                      ? 40
                                      : MediaQuery.of(context).size.width * 0.1,
                            ),

                            SizedBox(height: 16),
                            Text(
                              _errorMessage.isNotEmpty
                                  ? _errorMessage
                                  : ref
                                      .watch(transactionPinProvider)
                                      .errorMessage,
                              style: TextStyle(
                                fontFamily: 'Chirp',
                                fontSize: 13,
                                color: Colors.red.shade800,
                                letterSpacing: -0.4,
                                fontWeight: FontWeight.w500,
                                height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: SafeArea(
          child: AnimatedContainer(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(.2),
                  width: 1,
                ),
              ),
            ),
            duration: const Duration(milliseconds: 10),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
              left: 18,
              right: 18,
              top: 8,
              bottom:
                  MediaQuery.of(context).viewInsets.bottom > 0
                      ? MediaQuery.of(context).viewInsets.bottom + 8
                      : 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 300,
                  child: PrimaryButton(
                    borderRadius: 38,
                    text: "Change PIN",
                    onPressed:
                        _localPin.length == 4 &&
                                _errorMessage.isEmpty &&
                                !_isLoading
                            ? () => _verifyAndChangePin(_localPin)
                            : null,
                    enabled:
                        _localPin.length == 4 &&
                        _errorMessage.isEmpty &&
                        !_isLoading,
                    isLoading: _isLoading,
                    backgroundColor:
                        _localPin.length == 4 &&
                                _errorMessage.isEmpty &&
                                !_isLoading
                            ? AppColors.purple500ForTheme(context)
                            : AppColors.purple500ForTheme(context).withOpacity(.15),
                    textColor: AppColors.neutral0,
                    fontFamily: 'Chirp',
                    fullWidth: true,
                  ),
                ),
              ],
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
        SizedBox(height: 32),

        // Passcode dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            passcodeLength,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Container(
                width: 20,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      index < currentPasscode.length
                          ? AppColors.purple500ForTheme(context)
                          : Colors.transparent,
                  border: Border.all(
                    color: AppColors.purple500ForTheme(context),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: 32),
        SizedBox(height: 32),

        // Number pad
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
      builder:
          (context) => InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            borderRadius: BorderRadius.circular(100),
            onTap: () {
              HapticHelper.lightImpact();
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
                    fontSize: 44,
                    fontFamily: 'FunnelDisplay',
                    fontWeight: FontWeight.w500,
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
      builder:
          (context) => GestureDetector(
            onTap: () {
              HapticHelper.lightImpact();
              onTap();
            },
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: AppColors.purple500ForTheme(context),
                  size: 20,
                ),
              ),
            ),
          ),
    );
  }
}
