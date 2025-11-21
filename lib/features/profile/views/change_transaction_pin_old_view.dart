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

class ChangeTransactionPinOldView extends ConsumerStatefulWidget {
  const ChangeTransactionPinOldView({super.key});

  @override
  ConsumerState<ChangeTransactionPinOldView> createState() =>
      _ChangeTransactionPinOldViewState();
}

class _ChangeTransactionPinOldViewState
    extends ConsumerState<ChangeTransactionPinOldView> {
  final SecureStorageService _secureStorage = locator<SecureStorageService>();
  String _localPin = '';
  String _errorMessage = '';
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Reset the shared provider state when entering this view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transactionPinProvider.notifier).resetForm();
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

  Future<void> _handleContinue() async {
    if (_localPin.length != 4) {
      return;
    }

    // Validate PIN
    if (!_validatePin(_localPin)) {
      // Error message already set in _validatePin
      return;
    }

    // Store old pin temporarily before navigating
    await _secureStorage.write('temp_old_transaction_pin', _localPin);

    // Navigate to new PIN view
    appRouter.pushNamed(AppRoute.changeTransactionPinNewView);
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
            "Enter Old Transaction PIN",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
               fontFamily: 'CabinetGrotesk',
                   fontSize: 19.sp, // height: 1.6,
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
                            "Please enter your current 4-digit transaction PIN to continue.",
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
                  // Continue button - only show when PIN is complete
                  if (_localPin.length == 4)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: PrimaryButton(
                        text: 'Set New PIN',
                        onPressed: _localPin.length == 4 &&
                                _errorMessage.isEmpty &&
                                !_isLoading
                            ? _handleContinue
                            : null,
                        isLoading: _isLoading,
                        showLoadingIndicator: true,
                        height: 48.000.h,
                        backgroundColor: _localPin.length == 4 &&
                                _errorMessage.isEmpty &&
                                !_isLoading
                            ? AppColors.purple500
                            : AppColors.purple500ForTheme(
                            context,
                          ).withOpacity(.25),
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

