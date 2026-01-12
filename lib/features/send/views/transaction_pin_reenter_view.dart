import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/send/vm/transaction_pin_viewmodel.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/services/local/secure_storage.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/services/remote/network/api_error.dart';
import 'package:dayfi/common/utils/haptic_helper.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dio/dio.dart';

class TransactionPinReenterView extends ConsumerStatefulWidget {
  const TransactionPinReenterView({super.key});

  @override
  ConsumerState<TransactionPinReenterView> createState() =>
      _TransactionPinReenterViewState();
}

class _TransactionPinReenterViewState
    extends ConsumerState<TransactionPinReenterView> {
  final SecureStorageService _secureStorage = locator<SecureStorageService>();
  String? _tempPin;
  String _localPin = '';
  String _errorMessage = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTempPin();
    // Reset the shared provider state when entering this view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transactionPinProvider.notifier).resetForm();
    });
  }

  Future<void> _loadTempPin() async {
    final tempPin = await _secureStorage.read('temp_transaction_pin');
    setState(() {
      _tempPin = tempPin.isNotEmpty ? tempPin : null;
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

  Future<void> _verifyAndCreatePin(String reenteredPin) async {
    if (_isLoading) return; // Prevent multiple calls

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final pinNotifier = ref.read(transactionPinProvider.notifier);

    if (_tempPin == null) {
      setState(() {
        _errorMessage = 'No PIN found. Please create a new one.';
        _isLoading = false;
      });
      pinNotifier.setError(_errorMessage);
      Navigator.pop(context);
      return;
    }

    // Validate PIN format first
    if (!_validatePin(reenteredPin)) {
      // Error message already set in _validatePin
      pinNotifier.setError(_errorMessage);
      pinNotifier.setPin('');
      setState(() {
        _localPin = '';
        _isLoading = false;
      });
      return;
    }

    if (reenteredPin != _tempPin) {
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
      // PINs match, create it
      final success = await pinNotifier.createTransactionPin(reenteredPin);

      if (success) {
        // Clear temp pin
        await _secureStorage.delete('temp_transaction_pin');
        AppLogger.info('Transaction PIN created successfully');

        // Clear stored return route info
        await _secureStorage.delete('transaction_pin_return_route');
        final returnArgumentsJson = await _secureStorage.read(
          'transaction_pin_return_arguments',
        );
        if (returnArgumentsJson.isNotEmpty) {
          await _secureStorage.delete('transaction_pin_return_arguments');
        }

        // Pop both create and reenter views (the review view is already in the stack)
        Navigator.pop(context);
        Navigator.pop(context);

        // Don't push a new instance - just let the existing review view show
        // The review view will refresh its profile in initState

        // Show success message
        TopSnackbar.show(
          context,
          message: 'Transaction PIN created successfully',
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
          message: error.isNotEmpty ? error : 'Failed to create PIN',
          isError: true,
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to create PIN. Please try again.';
        _isLoading = false;
      });
      // Try to extract backend message when available
      try {
        if (e is DioException) {
          final apiErr = ApiError.fromDio(e);
          final backendMessage =
              apiErr.errorDescription ?? apiErr.apiErrorModel?.message;
          if (backendMessage != null && backendMessage.isNotEmpty) {
            TopSnackbar.show(context, message: backendMessage, isError: true);
            pinNotifier.setError(backendMessage);
            return;
          }
        }
      } catch (_) {}

      TopSnackbar.show(
        context,
        message: 'Failed to create PIN. Please try again.',
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
          leading: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              FocusScope.of(context).unfocus();
              pinNotifier.resetForm();
              setState(() {
                _localPin = '';
                _errorMessage = '';
              });
              Navigator.of(context).pop();
            },
            child: Stack(
              alignment: AlignmentGeometry.center,
              children: [
                SvgPicture.asset(
                  "assets/icons/svgs/notificationn.svg",
                  height: 40,
                  color: Theme.of(context).colorScheme.surface,
                ),
                SizedBox(
                  height: 40,
                  width: 40,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Icon(
                        Icons.arrow_back_ios,
                        size: 20,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.topCenter,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool isWide = constraints.maxWidth > 600;
                  return SingleChildScrollView(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isWide ? 400 : double.infinity,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isWide ? 24 : 18,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(height: 24),

                                  Text(
                                    "Confirm transaction PIN",
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

                                  SizedBox(height: 24),

                                  // Subtitle
                                  Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 18,
                                        ),
                                        child: Text(
                                          "Please re-enter your 4-digit transaction PIN to confirm. This ensures you remember it correctly.",
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
                                      )
                                      .animate()
                                      .fadeIn(
                                        delay: 100.ms,
                                        duration: 300.ms,
                                        curve: Curves.easeOutCubic,
                                      )
                                      .slideY(
                                        begin: 0.2,
                                        end: 0,
                                        delay: 100.ms,
                                        duration: 300.ms,
                                        curve: Curves.easeOutCubic,
                                      ),

                                  SizedBox(height: 24),
                                ],
                              ),
                            ),

                            // Passcode widget
                            Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 18),
                                  child: PasscodeWidget(
                                    passcodeLength: 4,
                                    currentPasscode: _localPin,
                                    onPasscodeChanged: (value) {
                                      _updateLocalPin(value);
                                      // Auto-submit when PIN is complete
                                      if (value.length == 4) {
                                        _verifyAndCreatePin(value);
                                      }
                                    },
                                  ),
                                )
                                .animate()
                                .fadeIn(
                                  delay: 200.ms,
                                  duration: 300.ms,
                                  curve: Curves.easeOutCubic,
                                )
                                .slideY(
                                  begin: 0.3,
                                  end: 0,
                                  delay: 200.ms,
                                  duration: 300.ms,
                                  curve: Curves.easeOutCubic,
                                )
                                .scale(
                                  begin: const Offset(0.98, 0.98),
                                  end: const Offset(1.0, 1.0),
                                  delay: 200.ms,
                                  duration: 300.ms,
                                  curve: Curves.easeOutCubic,
                                ),

                            // Error message
                            if (_errorMessage.isNotEmpty ||
                                ref
                                    .watch(transactionPinProvider)
                                    .errorMessage
                                    .isNotEmpty) ...[
                              SizedBox(height: 16),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 18),
                                child: Text(
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
                              ),
                            ],

                            SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  );
                },
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
            const SizedBox.shrink(), // Empty space
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
                    fontSize: 24,
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
