import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/auth/passcode/vm/passcode_viewmodel.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';

class PasscodeView extends ConsumerStatefulWidget {
  const PasscodeView({super.key});

  @override
  ConsumerState<PasscodeView> createState() => _PasscodeViewState();
}

class _PasscodeViewState extends ConsumerState<PasscodeView> {
  @override
  void initState() {
    super.initState();
    // Load user data when the view is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(passcodeProvider.notifier).loadUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final passcodeState = ref.watch(passcodeProvider);
    final passcodeNotifier = ref.read(passcodeProvider.notifier);

    // Show error snackbar if there's an error message
    if (passcodeState.errorMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        TopSnackbar.show(
          context,
          message: passcodeState.errorMessage,
          isError: true,
        );
        passcodeNotifier.clearError();
      });
    }

    return Stack(
      children: [
        // Advanced animated background with gradient

        // Main content
        Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 16.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 1),

                  // User avatar
                  CircleAvatar(
                        radius: 40,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        // backgroundImage: const NetworkImage(
                        //   'https://avatar.iran.liara.run/public/52',
                        // ),
                      )
                      .animate()
                      .fadeIn(duration: 300.ms, curve: Curves.easeOutCubic),

                  const SizedBox(height: 16),

                  // Welcome text
                  Text(
                        'Welcome back, ${(passcodeState.user != null && passcodeState.user!.firstName.isNotEmpty) ? passcodeState.user!.firstName : ''}',
                        style: TextStyle(
                          fontFamily: 'CabinetGrotesk',
                          fontSize: 28.00,
                          fontWeight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                      .animate()
                      .fadeIn(
                        duration: 300.ms,
                        curve: Curves.easeOutCubic,
                        delay: 50.ms,
                      ),

                  SizedBox(height: 12.h),
                  // Instruction text
                  Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          'Enter your 4-digit passcode to continue.',
                          style: TextStyle(
                            // color: AppColors.neutral800,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400, //
                            fontFamily: 'Karla',
                            letterSpacing: -.6,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                      .animate()
                      .fadeIn(
                        duration: 300.ms,
                        curve: Curves.easeOutCubic,
                        delay: 150.ms,
                      ),

                  SizedBox(height: 40.h),

                  // Loading indicator or passcode dots
                  if (passcodeState.isVerifying)
                    CupertinoActivityIndicator(color: AppColors.purple500)
                        .animate()
                        .fadeIn(
                          duration: 300.ms,
                          curve: Curves.easeOutCubic,
                          delay: 200.ms,
                        )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6.0,
                              ),
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      index < passcodeState.passcode.length
                                          ? AppColors.purple500
                                          : Colors.transparent,
                                  border: Border.all(
                                    color: AppColors.purple500,
                                    width: 1.50,
                                  ),
                                ),
                              ),
                            )
                            .animate()
                            .fadeIn(
                              duration: 300.ms,
                              curve: Curves.easeOutCubic,
                              delay: Duration(milliseconds: 200 + (index * 30)),
                            );
                      }),
                    ),

                  SizedBox(height: MediaQuery.of(context).size.width * .2),

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
                            return _buildNumberButton(
                              number,
                              passcodeNotifier,
                              index,
                            );
                          }),
                       
                          _buildIconButton(
                            iconSvg:
                                passcodeState.hasFaceId
                                    ? "assets/icons/svgs/face-id.svg"
                                    : "assets/icons/svgs/fingerprint.svg",
                            icon:
                                passcodeState.hasFaceId
                                    ? Icons.face
                                    : Icons.fingerprint,
                            onTap: passcodeState.isBiometricAvailable
                                ? () async {
                                  final authenticated =
                                      await passcodeNotifier
                                          .authenticateWithBiometrics();
                                  if (!authenticated) {
                                    TopSnackbar.show(
                                      context,
                                      message:
                                          'Biometric authentication failed. Please use your passcode.',
                                      isError: true,
                                    );
                                  }
                                }
                                : () {
                                  TopSnackbar.show(
                                    context,
                                    message:
                                        'Biometric authentication is not available on this device',
                                    isError: true,
                                  );
                                },
                            index: 9,
                          ),
                          _buildNumberButton('0', passcodeNotifier, 10),
                          _buildIconButton(
                            iconSvg: "",
                            icon: Icons.arrow_back_ios,
                            onTap: passcodeNotifier.removeDigit,
                            index: 11,
                          ),
                        ],
                      )
                      .animate()
                      .fadeIn(
                        duration: 300.ms,
                        curve: Curves.easeOutCubic,
                        delay: 300.ms,
                      ),

                  const SizedBox(height: 32),

                  // Logout option
                  Center(
                        child: Text.rich(
                          textAlign: TextAlign.center,
                          TextSpan(
                            text: "Wrong account? ",
                            style: TextStyle(
                              fontFamily: 'Karla',
                              color: AppColors.neutral700,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400,
                              letterSpacing: -.6,
                              height: 1.450,
                            ),
                            children: [
                              TextSpan(
                                text: "Sign out",
                                style: TextStyle(
                                  fontFamily: 'Karla',
                                  color: AppColors.purple500,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -.3,
                                  height: 1.4,
                                ),
                                recognizer:
                                    TapGestureRecognizer()
                                      ..onTap = () {
                                        passcodeNotifier.logout(ref);
                                      },
                              ),
                            ],
                          ),
                          semanticsLabel: '',
                        ),
                      )
                      .animate()
                      .fadeIn(
                        duration: 300.ms,
                        curve: Curves.easeOutCubic,
                        delay: 400.ms,
                      ),

                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberButton(
    String number,
    PasscodeNotifier notifier,
    int index,
  ) {
    return GestureDetector(
          onTap: () => notifier.addDigit(number),
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
        )
        .animate()
        .fadeIn(
          duration: 300.ms,
          curve: Curves.easeOutCubic,
          delay: Duration(milliseconds: 300 + (index * 20)),
        );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String iconSvg,
    required VoidCallback onTap,
    required int index,
  }) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
          onTap: onTap,
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
            ),
            child: Center(
              child:
                  (icon == Icons.fingerprint || icon == Icons.face)
                      ? SvgPicture.asset(
                        iconSvg,
                        height: 36,
                        color: AppColors.purple500,
                      )
                      : Icon(
                        icon,
                        size:
                            (icon == Icons.fingerprint || icon == Icons.face)
                                ? 36
                                : 24,
                        color: AppColors.purple500,
                      ),
            ),
          ),
        )
        .animate()
        .fadeIn(
          duration: 300.ms,
          curve: Curves.easeOutCubic,
          delay: Duration(milliseconds: 300 + (index * 20)),
        );
  }
}
