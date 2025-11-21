import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dayfi/common/utils/haptic_helper.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/send/vm/transaction_pin_viewmodel.dart';
import 'package:dayfi/services/local/secure_storage.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/routes/route.dart';

class ResetTransactionPinNewView extends ConsumerStatefulWidget {
  const ResetTransactionPinNewView({super.key});

  @override
  ConsumerState<ResetTransactionPinNewView> createState() =>
      _ResetTransactionPinNewViewState();
}

class _ResetTransactionPinNewViewState
    extends ConsumerState<ResetTransactionPinNewView> {
  final SecureStorageService _secureStorage = locator<SecureStorageService>();
  String _localPin = '';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transactionPinProvider.notifier).resetForm();
    });
  }

  void _updateLocalPin(String value) {
    setState(() {
      _localPin = value;
      _errorMessage = '';
    });
    ref.read(transactionPinProvider.notifier).updatePin(value);
  }

  bool _validatePin(String pin) {
    if (pin.length != 4) {
      return false;
    }
    if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
      setState(() {
        _errorMessage = 'PIN must contain only numbers';
      });
      return false;
    }
    if (RegExp(r'(\d)\1{3}').hasMatch(pin)) {
      setState(() {
        _errorMessage = 'PIN cannot be all the same number';
      });
      return false;
    }
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

    if (!_validatePin(_localPin)) {
      return;
    }

    // Store new pin temporarily before navigating
    await _secureStorage.write('temp_reset_transaction_pin', _localPin);

    // Navigate to confirm PIN view
    appRouter.pushNamed(AppRoute.resetTransactionPinConfirmView);
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
            "Create New Transaction PIN",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
           fontFamily: 'CabinetGrotesk',
               fontSize: 19.sp, height: 1.6,
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
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 4.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18.w),
                          child: Text(
                            "Please create a new 4-digit transaction PIN. This PIN will be required for all wallet transfers.",
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Karla',
                              letterSpacing: -.3,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: PasscodeWidget(
                      passcodeLength: 4,
                      currentPasscode: _localPin,
                      onPasscodeChanged: (value) {
                        _updateLocalPin(value);
                      },
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.width * 0.15),
                  if (_localPin.length == 4)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: PrimaryButton(
                        text: 'Continue',
                        onPressed: _localPin.length == 4 &&
                                _errorMessage.isEmpty
                            ? _handleContinue
                            : null,
                        height: 48.000.h,
                        backgroundColor: _localPin.length == 4 &&
                                _errorMessage.isEmpty
                            ? AppColors.purple500
                            : AppColors.purple500ForTheme(
                              context,
                            ).withOpacity(.25),
                        textColor: _localPin.length == 4 &&
                                _errorMessage.isEmpty
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
                  fontSize: 70.sp,
                  letterSpacing: -10,
               fontFamily: 'CabinetGrotesk',
                  fontWeight: FontWeight.w700,
                  color: index < currentPasscode.length
                      ? AppColors.purple500ForTheme(context)
                      : AppColors.neutral400,
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
                fontSize: 25.60,
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
              child: Icon(icon, color: AppColors.purple500ForTheme(context))),
        ),
      ),
    );
  }
}
