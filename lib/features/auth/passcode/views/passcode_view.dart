import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/buttons/secondary_button.dart';
import 'package:dayfi/common/utils/haptic_helper.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Removed flutter_animate usage in favor of a single AnimatedOpacity fade-in
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/auth/passcode/vm/passcode_viewmodel.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class PasscodeView extends ConsumerStatefulWidget {
  const PasscodeView({super.key});

  @override
  ConsumerState<PasscodeView> createState() => _PasscodeViewState();
}

class _PasscodeViewState extends ConsumerState<PasscodeView> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    // Load user data when the view is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(passcodeProvider.notifier).loadUser();
      if (mounted) {
        setState(() {
          _visible = true;
        });
      }
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
            bottom: false,
            child: AnimatedOpacity(
              opacity: _visible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool isWide = constraints.maxWidth > 600;
                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isWide ? 400 : double.infinity,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isWide ? 24.0 : 32.0,
                          vertical: 16.0,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(flex: 1),

                            Padding(
                              padding: EdgeInsets.only(bottom: 0),
                              child: Image.asset(
                                "assets/icons/pngs/account_4.png",
                                height: isWide ? 96 : 84,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Welcome text
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isWide ? 16.0 : 32.0,
                              ),
                              child: Text(
                                    'Welcome back, ${_capitalize(passcodeState.user?.firstName ?? '')}',

                                    textAlign: TextAlign.center,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.displayLarge?.copyWith(
                                      color:
                                          Theme.of(
                                            context,
                                          ).textTheme.headlineLarge?.color,
                                      fontSize:
                                          MediaQuery.of(context).size.width >
                                                  600
                                              ? 32
                                              : 28,
                                      letterSpacing: -.250,
                                      fontWeight: FontWeight.w900,
                                      // fontWeight: FontWeight.w100,
                                      fontFamily: 'FunnelDisplay',
                                      // letterspacing: 0,
                                      height: 1,
                                    ),
                                    maxLines: 2,
                                  )
                                  .animate()
                                  .fadeIn(duration: 600.ms)
                                  .slideY(begin: 0.25, end: 0, duration: 600.ms)
                                  .then()
                                  .shimmer(
                                    duration: 1800.ms,
                                    color: Theme.of(
                                      context,
                                    ).scaffoldBackgroundColor.withOpacity(0.4),
                                    angle: 20,
                                  ),
                            ),

                            // SizedBox(height: 12),
                            // // Instruction text
                            // Padding(
                            //   padding: const EdgeInsets.symmetric(horizontal: 18.0),
                            //   child: Text(
                            //     'Enter your 4-digit passcode to continue.',
                            //     style: TextStyle(
                            //       // color: AppColors.neutral800,
                            //       fontSize: 16,
                            //       fontWeight: FontWeight.w500, //
                            //       fontFamily: 'Chirp',
                            //       letterSpacing: -.25,
                            //       height: 1.2,
                            //     ),
                            //     textAlign: TextAlign.center,
                            //   ),
                            // ),
                            SizedBox(height: 32),

                            // Loading indicator or passcode dots
                            if (passcodeState.isVerifying)
                              SizedBox(
                                width: 24,
                                height: 24,
                                child:
                                    LoadingAnimationWidget.horizontalRotatingDots(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      size: 24,
                                    ),
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
                                      width: isWide ? 28 : 24,
                                      height: isWide ? 28 : 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                            index <
                                                    passcodeState
                                                        .passcode
                                                        .length
                                                ? AppColors.purple500ForTheme(
                                                  context,
                                                )
                                                : Colors.transparent,
                                        border: Border.all(
                                          color: AppColors.purple500ForTheme(
                                            context,
                                          ),
                                          width: 1.50,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),

                            SizedBox(
                              height:
                                  isWide
                                      ? 60
                                      : MediaQuery.of(context).size.width * .2,
                            ),

                            // Number pad
                            SizedBox(
                              width: isWide ? 320 : 420,
                              child: GridView.count(
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
                                            : "assets/icons/svgs/face-id.svg",
                                    icon:
                                        passcodeState.hasFaceId
                                            ? Icons.face
                                            : Icons.fingerprint,

                                    onTap:
                                        passcodeState.isBiometricAvailable
                                            ? () async {
                                              final authenticated =
                                                  await passcodeNotifier
                                                      .authenticateWithBiometrics();
                                              if (!authenticated) {
                                                TopSnackbar.show(
                                                  context,
                                                  message:
                                                      'Biometric check failed. Use your passcode instead.',
                                                  isError: true,
                                                );
                                              }
                                            }
                                            : () {
                                              // Distinguish between device not having biometrics
                                              // and biometrics being available on device but not enabled for the app
                                              if (passcodeState
                                                      .isDeviceBiometricAvailable &&
                                                  !passcodeState
                                                      .isBiometricEnabled) {
                                                TopSnackbar.show(
                                                  context,
                                                  message:
                                                      'Biometrics are available but not enabled for this app.',
                                                  isError: true,
                                                );
                                              } else {
                                                TopSnackbar.show(
                                                  context,
                                                  message:
                                                      'This device doesn’t support biometric authentication.',
                                                  isError: true,
                                                );
                                              }
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
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Logout option
                            Center(
                              child: Text.rich(
                                textAlign: TextAlign.center,
                                TextSpan(
                                  text: "Wrong account? ",
                                  style: TextStyle(
                                    fontFamily: 'Chirp',
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color!
                                        .withOpacity(.85),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: -.25,
                                    height: 1.450,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "Sign out",
                                      style: TextStyle(
                                        fontFamily: 'Chirp',
                                        color: AppColors.purple500ForTheme(
                                          context,
                                        ),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: -.25,
                                        height: 1.2,
                                      ),
                                      recognizer:
                                          TapGestureRecognizer()
                                            ..onTap = () {
                                              _showLogoutDialog();
                                            },
                                    ),
                                  ],
                                ),
                                semanticsLabel: '',
                              ),
                            ),

                            const Spacer(flex: 1),
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

        if (passcodeState.isVerifying)
          Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: true,
            body: Opacity(
              opacity: 0.5,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black,
              ),
            ),
          ),
      ],
    );
  }

  // Show Logout Dialog
  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => _buildLogoutDialog(),
    );
  }

  // Logout Dialog Widget
  Widget _buildLogoutDialog() {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogIcon(),
            SizedBox(height: 24),
            _buildDialogTitle(),
            SizedBox(height: 16),
            _buildDialogButtons(),
          ],
        ),
      ),
    );
  }

  // Dialog Icon
  Widget _buildDialogIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.error400, AppColors.error600],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.error500.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }

  // Dialog Title
  Widget _buildDialogTitle() {
    return Text(
      'Are you sure you want to logout? You will be asked to create a new passcode.',
      style: TextStyle(
        fontFamily: 'FunnelDisplay',
        fontSize: 24, // height: 1.6,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurface,
        letterSpacing: -0.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  // Dialog Buttons
  Widget _buildDialogButtons() {
    return Column(
      children: [
        _buildDialogLogoutButton(),
        SizedBox(height: 12),
        _buildCancelButton(),
      ],
    );
  }

  // Logout Button
  Widget _buildDialogLogoutButton() {
    final passcodeNotifier = ref.read(passcodeProvider.notifier);
    return PrimaryButton(
      text: 'Yes, Logout',
      onPressed: () {
        passcodeNotifier.logout(ref);
      },
      backgroundColor: AppColors.purple500,
      textColor: AppColors.neutral0,
      borderRadius: 38.0,
      height: 48.00000,
      width: double.infinity,
      fullWidth: true,
      fontFamily: 'Chirp',
      fontSize: 18,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.8,
    );
  }

  // Cancel Button
  Widget _buildCancelButton() {
    return SecondaryButton(
      text: 'Cancel',
      onPressed: () => Navigator.pop(context),
      borderColor: Colors.transparent,
      textColor: AppColors.purple500ForTheme(context),
      width: double.infinity,
      fullWidth: true,
      height: 48.00000,
      borderRadius: 38.0,
      fontFamily: 'Chirp',
      fontSize: 18,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.8,
    );
  }

  Widget _buildNumberButton(
    String number,
    PasscodeNotifier notifier,
    int index,
  ) {
    return GestureDetector(
      onTap: () {
        HapticHelper.lightImpact();
        notifier.addDigit(number);
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
      // ).animate().fadeIn(
      //   duration: 300.ms,
      //   curve: Curves.easeOutCubic,
      //   delay: Duration(milliseconds: 300 + (index * 20)),
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
          child:
              (icon == Icons.fingerprint || icon == Icons.face)
                  ? SvgPicture.asset(
                    iconSvg,
                    height: 32,
                    color: AppColors.purple500ForTheme(context),
                  )
                  : Icon(
                    icon,
                    size:
                        (icon == Icons.fingerprint || icon == Icons.face)
                            ? 32
                            : 24,
                    color: AppColors.purple500ForTheme(context),
                  ),
        ),
      ),
      // ).animate().fadeIn(
      //   duration: 300.ms,
      //   curve: Curves.easeOutCubic,
      //   delay: Duration(milliseconds: 300 + (index * 20)),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }
}
