import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/send/vm/transaction_pin_viewmodel.dart';
import 'package:dayfi/services/local/secure_storage.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
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
            size: 20.sp,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          title: Text(
            "Create Transaction PIN",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
           fontFamily: 'FunnelDisplay',
               fontSize: 24.sp, // height: 1.6,
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
            bottom: false,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 4.h),
                        Padding(
                              padding: EdgeInsets.symmetric(horizontal: 18.w),
                              child: Text(
                                "Please create a 4-digit PIN for your transactions. This PIN will be required for all wallet transfers.",
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Karla',
                                  letterSpacing: -.6,
                                  height: 1.4,
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
                        // SizedBox(height: 40.h),
                      ],
                    ),
                  ),
                  Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        child: PasscodeWidget(
                          passcodeLength: 4,
                          currentPasscode: _localPin,
                          onPasscodeChanged: (value) async {
                            _updateLocalPin(value);
                            // Don't auto-submit - wait for button click
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
                  SizedBox(height: MediaQuery.of(context).size.width * 0.15),
                  // Continue button - only show when PIN is complete
                  if (_localPin.length == 4)
                    Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18.w),
                          child: PrimaryButton(
                            text: 'Re-enter PIN',
                            onPressed:
                                _localPin.length == 4 && _errorMessage.isEmpty
                                    ? _handleContinue
                                    : null,
                            height: 48.00000.h,
                            backgroundColor:
                                _localPin.length == 4 && _errorMessage.isEmpty
                                    ? AppColors.purple500
                                    : AppColors.purple500ForTheme(
                            context,
                          ).withOpacity(.15),
                            textColor:
                                _localPin.length == 4 && _errorMessage.isEmpty
                                    ? AppColors.neutral0
                                    : AppColors.neutral0.withOpacity(0.5),
                            fontFamily: 'Karla',
                            letterSpacing: -.70,
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
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: Text(
                      _errorMessage.isNotEmpty
                          ? _errorMessage
                          : ref.watch(transactionPinProvider).errorMessage,
                      style: TextStyle(
                        fontFamily: 'Karla',
                        fontSize: 13.sp,
                        color: Colors.red.shade800,
                        letterSpacing: -0.4,
                        fontWeight: FontWeight.w500,
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
               fontFamily: 'FunnelDisplay',
                  fontWeight: FontWeight.w700,
                  color:
                      index < currentPasscode.length
                          ? AppColors.purple500ForTheme(context)
                          : AppColors.neutral400,
                ),
              ),

              // Container(
              //   width: 24,
              //   height: 24,
              //   decoration: BoxDecoration(
              //     shape: BoxShape.circle,
              //     color:
              //         index < currentPasscode.length
              //             ? AppColors.purple500ForTheme(context)
              //             : Colors.transparent,
              //     border: Border.all(color: AppColors.purple500ForTheme(context), width: 2),
              //   ),
              // ),
            ),
          ),
        ),
        // SizedBox(height: 32.h),
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
                    fontSize: 32.sp,
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
      builder: (context) => GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
          ),
          child: Center(child: Icon(icon, color: AppColors.purple500ForTheme(context),     size: 20.sp)),
        ),
      ),
    );
  }
}
