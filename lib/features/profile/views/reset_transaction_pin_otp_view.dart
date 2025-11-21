import 'package:dayfi/app_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/text_fields/pin_text_field.dart';
import 'package:dayfi/features/profile/vm/reset_transaction_pin_viewmodel.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ResetTransactionPinOtpView extends ConsumerStatefulWidget {
  final String email;

  const ResetTransactionPinOtpView({super.key, required this.email});

  @override
  ConsumerState<ResetTransactionPinOtpView> createState() =>
      _ResetTransactionPinOtpViewState();
}

class _ResetTransactionPinOtpViewState
    extends ConsumerState<ResetTransactionPinOtpView> {
  String _otp = '';
  bool _isResending = false;
  bool _canResend = false;
  int _remainingTime = 60;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendOtp();
      _startTimer();
    });
  }

  void _startTimer() {
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _remainingTime--;
          if (_remainingTime <= 0) {
            _canResend = true;
          } else {
            _startTimer();
          }
        });
      }
    });
  }

  Future<void> _sendOtp() async {
    final notifier = ref.read(resetTransactionPinProvider.notifier);
    final success = await notifier.sendResetOtp(widget.email);
    if (!success && mounted) {
      TopSnackbar.show(
        context,
        message: 'Failed to send OTP. Please try again.',
        isError: true,
      );
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isResending = true;
      _canResend = false;
      _remainingTime = 60;
    });

    await _sendOtp();
    _startTimer();

    setState(() {
      _isResending = false;
    });
  }

  Future<void> _verifyOtp() async {
    if (_otp.length != 6) {
      TopSnackbar.show(
        context,
        message: 'Please enter a 6-digit OTP',
        isError: true,
      );
      return;
    }

    final notifier = ref.read(resetTransactionPinProvider.notifier);
    final success = await notifier.verifyResetOtp(_otp);

    if (success && mounted) {
      appRouter.pushNamed(AppRoute.resetTransactionPinNewView);
    } else if (mounted) {
      final state = ref.read(resetTransactionPinProvider);
      TopSnackbar.show(
        context,
        message:
            state.errorMessage.isNotEmpty
                ? state.errorMessage
                : 'Failed to verify OTP',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final resetState = ref.watch(resetTransactionPinProvider);

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        resizeToAvoidBottomInset: false,
        body: GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppBar(
                    scrolledUnderElevation: 0,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    elevation: 0,
                    leading: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back_ios_new),
                    ),
                    title: Text(
                      "Verify Your Email",
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(
                     fontFamily: 'CabinetGrotesk',
                        fontSize: 22.40,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12.h),
                        Text(
                              "We've sent a verification code to your email address (${widget.email}).\nPlease check your email inbox and enter the 6-digit code below to reset your transaction PIN.",
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
                        SizedBox(height: 28.h),
                        PinTextField(
                              length: 6,
                              onTextChanged: (value) {
                                setState(() {
                                  _otp = value;
                                });
                              },
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
                        SizedBox(height: 24.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!_canResend) ...[
                              Icon(
                                Icons.timer_outlined,
                                color: AppColors.neutral400,
                                size: 16.r,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                "Resend in ${_remainingTime}s",
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Karla',
                                  color: AppColors.neutral400,
                                ),
                              ),
                            ] else ...[
                              GestureDetector(
                                onTap: _isResending ? null : _resendOtp,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (_isResending) ...[
                                      SizedBox(
                                        width: 20.r,
                                        height: 20.r,
                                        child:
                                            LoadingAnimationWidget.horizontalRotatingDots(
                                              color: AppColors.neutral0,
                                              size: 20,
                                            ),
                                      ),
                                      SizedBox(width: 8.w),
                                    ],
                                    Text(
                                      _isResending
                                          ? "Sending new code..."
                                          : "Send new code",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.copyWith(
                                        fontFamily: 'Karla',
                                        color:
                                            _isResending
                                                ? Theme.of(
                                                  context,
                                                ).colorScheme.onSurface
                                                : AppColors.purple500ForTheme(
                                                  context,
                                                ),
                                        fontSize: _isResending ? 14.sp : 16.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 40.h),
                        PrimaryButton(
                          borderRadius: 38,
                          text: "Verify OTP",
                          onPressed:
                              _otp.length == 6 && !resetState.isLoading
                                  ? _verifyOtp
                                  : null,
                          enabled: _otp.length == 6 && !resetState.isLoading,
                          isLoading: resetState.isLoading,
                          backgroundColor:
                              _otp.length == 6
                                  ? AppColors.purple500ForTheme(context)
                                  : AppColors.purple500ForTheme(
                                    context,
                                  ).withOpacity(.25),
                          height: 48.000.h,
                          textColor:
                              _otp.length == 6
                                  ? AppColors.neutral0
                                  : AppColors.neutral0.withOpacity(.65),
                          fontFamily: 'Karla',
                          letterSpacing: -.8,
                          fontSize: 18,
                          width: 375.w,
                          fullWidth: true,
                        ),
                        SizedBox(height: 200.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
