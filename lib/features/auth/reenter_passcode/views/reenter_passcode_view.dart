import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/auth/reenter_passcode/vm/reenter_passcode_viewmodel.dart';

class ReenterPasscodeView extends ConsumerStatefulWidget {
  final bool isFromSignup;

  const ReenterPasscodeView({super.key, this.isFromSignup = false});

  @override
  ConsumerState<ReenterPasscodeView> createState() =>
      _ReenterPasscodeViewState();
}

class _ReenterPasscodeViewState extends ConsumerState<ReenterPasscodeView> {
  @override
  void initState() {
    super.initState();
    // Reset form when view is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(reenterPasscodeProvider(widget.isFromSignup).notifier)
          .resetForm();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reenterPasscodeState = ref.watch(
      reenterPasscodeProvider(widget.isFromSignup),
    );
    final reenterPasscodeNotifier = ref.read(
      reenterPasscodeProvider(widget.isFromSignup).notifier,
    );

    return GestureDetector(
      onTap: () {
        // Dismiss keyboard and remove focus from all text fields
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppBar(
                    scrolledUnderElevation: 0,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    elevation: 0,
                    leading: IconButton(
                      onPressed: () {
                        reenterPasscodeNotifier.resetForm();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back_ios_new),
                    ),
                    title: Text(
                      "Confirm passcode",
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(
                        fontFamily: 'CabinetGrotesk',
                        fontSize: 28.00,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 12.h),

                        // Subtitle
                        Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24.w),
                              child: Text(
                                "Please enter your 4-digit passcode again to confirm. This ensures you remember it correctly.",
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

                        SizedBox(height: 40.h),
                      ],
                    ),
                  ),

                  // Passcode widget
                  Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: PasscodeWidget(
                          passcodeLength: 4,
                          currentPasscode: reenterPasscodeState.passcode,
                          onPasscodeChanged:
                              (value) => reenterPasscodeNotifier.updatePasscode(
                                value,
                                context,
                              ),
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
                  if (reenterPasscodeState.errorMessage.isNotEmpty) ...[
                    SizedBox(height: 16.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        reenterPasscodeState.errorMessage,
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
                  ],

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
        SizedBox(height: MediaQuery.of(context).size.width * 0.2),
        // Passcode dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            passcodeLength,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      index < currentPasscode.length
                          ? AppColors.purple500
                          : Colors.transparent,
                  border: Border.all(color: AppColors.purple500, width: 2),
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: 32.h),
        SizedBox(height: 32.h),

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: Center(child: Icon(icon, color: AppColors.purple500)),
      ),
    );
  }
}
