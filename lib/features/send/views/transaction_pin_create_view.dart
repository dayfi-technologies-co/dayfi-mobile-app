import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/send/vm/transaction_pin_viewmodel.dart';
import 'package:dayfi/services/local/secure_storage.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/common/utils/haptic_helper.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';

class TransactionPinCreateView extends ConsumerStatefulWidget {
  final String? returnRoute;
  final Map<String, dynamic>? returnArguments;

  const TransactionPinCreateView({
    super.key,
    this.returnRoute,
    this.returnArguments,
  });

  @override
  ConsumerState<TransactionPinCreateView> createState() =>
      _TransactionPinCreateViewState();
}

class _TransactionPinCreateViewState
    extends ConsumerState<TransactionPinCreateView> {
  String _localPin = '';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Reset the shared provider state when entering this view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transactionPinProvider.notifier).resetForm();
      // Listen for provider errors and show TopSnackbar when backend/VM sets an error
      ref.listen<TransactionPinState>(transactionPinProvider, (previous, next) {
        if (next.errorMessage.isNotEmpty) {
          TopSnackbar.show(context, message: next.errorMessage, isError: true);
        }
      });
      _showSecurityDialog();
    });
  }

  void _showSecurityDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Security icon with enhanced styling
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  child: SvgPicture.asset('assets/icons/svgs/cautionn.svg'),
                ),

                SizedBox(height: 24),

                // Title with auth view styling
                Text(
                  'For your security, please avoid easy-to-guess PINs. e.g. 1234, 2222',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontFamily: 'Chirp',
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.8,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 16),

                // Continue button with auth view styling
                PrimaryButton(
                  text: 'Close',
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  backgroundColor: AppColors.purple500,
                  textColor: AppColors.neutral0,
                  borderRadius: 38,
                  height: 48.00000,
                  width: double.infinity,
                  fullWidth: true,
                  fontFamily: 'Chirp',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -.70,
                ),
              ],
            ),
          ),
        );
      },
    );
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
    // Check for repeated digits (e.g., 1111, 2222)
    if (RegExp(r'(\d)\1{3}').hasMatch(pin)) {
      setState(() {
        _errorMessage = 'PIN cannot be all the same number';
      });
      return false;
    }
    // Check for sequential digits (e.g., 1234, 4321)
    if (_isSequential(pin)) {
      setState(() {
        _errorMessage = 'PIN cannot be sequential';
      });
      return false;
    }
    return true;
  }

  bool _isSequential(String pin) {
    final digits = pin.split('').map((e) => int.parse(e)).toList();
    bool ascending = true;
    bool descending = true;

    for (int i = 1; i < digits.length; i++) {
      if (digits[i] != digits[i - 1] + 1) {
        ascending = false;
      }
      if (digits[i] != digits[i - 1] - 1) {
        descending = false;
      }
    }

    return ascending || descending;
  }

  Future<void> _handleContinue() async {
    if (_localPin.length != 4) {
      return;
    }

    // Validate PIN
    if (!_validatePin(_localPin)) {
      // Error message already set in _validatePin
      return;
    }

    // Store temp pin and return route info before navigating
    final secureStorage = locator<SecureStorageService>();
    await secureStorage.write('temp_transaction_pin', _localPin);
    // Store return route info
    if (widget.returnRoute != null) {
      await secureStorage.write(
        'transaction_pin_return_route',
        widget.returnRoute!,
      );
      if (widget.returnArguments != null) {
        final argumentsJson = json.encode(widget.returnArguments);
        await secureStorage.write(
          'transaction_pin_return_arguments',
          argumentsJson,
        );
      }
    }

    appRouter.pushNamed(AppRoute.transactionPinReenterView);
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
                                    "Create transaction PIN",
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
                                          "Please create a 4-digit PIN for your transactions. This PIN will be required for all wallet transfers.",
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
                                    onPasscodeChanged: (value) async {
                                      _updateLocalPin(value);
                                      // Auto-submit when PIN is complete
                                      if (value.length == 4) {
                                        _handleContinue();
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

// Reuse PasscodeWidget from create_passcode_view.dart
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
