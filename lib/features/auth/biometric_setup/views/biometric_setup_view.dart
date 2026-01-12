import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/buttons/secondary_button.dart';
import 'package:dayfi/features/auth/biometric_setup/vm/biometric_setup_viewmodel.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/routes/route.dart';

class BiometricSetupView extends ConsumerStatefulWidget {
  const BiometricSetupView({super.key});

  @override
  ConsumerState<BiometricSetupView> createState() => _BiometricSetupViewState();
}

class _BiometricSetupViewState extends ConsumerState<BiometricSetupView> {
  @override
  Widget build(BuildContext context) {
    final biometricState = ref.watch(biometricSetupProvider);
    final biometricNotifier = ref.read(biometricSetupProvider.notifier);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth > 600;
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWide ? 400 : double.infinity,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isWide ? 24 : 18),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 32),
                      _buildContentCard(context, biometricState, isWide),
                      SizedBox(height: 32),
                      _buildActionButtons(
                        context,
                        biometricState,
                        biometricNotifier,
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
    );
  }

  Widget _buildContentCard(
    BuildContext context,
    BiometricSetupState state,
    bool isWide,
  ) {
    return Column(
          children: [
            // Biometric icon
            // Container(
            //   width: 80,
            //   height: 80,
            //   decoration: BoxDecoration(
            //     gradient: LinearGradient(
            //       begin: Alignment.topLeft,
            //       end: Alignment.bottomRight,
            //       colors: [AppColors.purple400, AppColors.orange500],
            //     ),
            //     shape: BoxShape.circle,
            //     boxShadow: [
            //       BoxShadow(
            //         color: AppColors.purple500ForTheme(
            //           context,
            //         ).withOpacity(0.15),
            //         blurRadius: 20,
            //         spreadRadius: 2,
            //         offset: const Offset(0, 4),
            //       ),
            //     ],
            //   ),
            //   child: Padding(
            //     padding: const EdgeInsets.all(10.0),
            //     child: SvgPicture.asset(
            //       state.hasBothFaceAndFingerprint
            //           ? "assets/icons/svgs/security-safe.svg"
            //           : state.biometricType.toLowerCase().contains('face')
            //           ? "assets/icons/svgs/face-id.svg"
            //           : "assets/icons/svgs/face-id..svg",
            //       color: Colors.white,
            //       height: 24,
            //     ),
            //   ),
            // ),

            // SizedBox(height: 24),

            // Title
            Text(
                  "Enable ${state.biometricDescription}",
                  style: AppTypography.headlineMedium.copyWith(
                    fontFamily: 'FunnelDisplay',
                    fontSize: isWide ? 32 : 28,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                    // height: 1.2,
                    letterSpacing: -.25,
                  ),
                  textAlign: TextAlign.center,
                )
                .animate()
                .fadeIn(
                  delay: 500.ms,
                  duration: 400.ms,
                  curve: Curves.easeOutCubic,
                )
                .slideY(
                  begin: 0.3,
                  end: 0,
                  delay: 500.ms,
                  duration: 400.ms,
                  curve: Curves.easeOutCubic,
                ),

            SizedBox(height: 16),

            // Subtitle
            Text(
                  state.isAvailable && state.isEnrolled
                      ? state.hasBothFaceAndFingerprint
                          ? "Use your Face ID or Fingerprint to quickly and securely access your account"
                          : "Use your ${state.biometricType.toLowerCase()} to quickly and securely access your account"
                      : state.errorMessage.isNotEmpty
                      ? state.errorMessage
                      : "Setting up biometric authentication...",

                  style: AppTypography.bodyLarge.copyWith(
                    fontFamily: 'Chirp',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                    color:
                        state.isAvailable && state.isEnrolled
                            ? Theme.of(
                              context,
                            ).textTheme.bodyLarge!.color!.withOpacity(.75)
                            : AppColors.error500,
                  ),
                  textAlign: TextAlign.center,
                )
                .animate()
                .fadeIn(
                  delay: 600.ms,
                  duration: 400.ms,
                  curve: Curves.easeOutCubic,
                )
                .slideY(
                  begin: 0.3,
                  end: 0,
                  delay: 600.ms,
                  duration: 400.ms,
                  curve: Curves.easeOutCubic,
                ),

            if (state.isBusy) ...[
              SizedBox(height: 24),
              LoadingAnimationWidget.horizontalRotatingDots(
                color: AppColors.purple500ForTheme(context),
                size: 20,
              ),
            ],
          ],
        )
        .animate()
        .fadeIn(delay: 300.ms, duration: 500.ms, curve: Curves.easeOutCubic)
        .slideY(
          begin: 0.4,
          end: 0,
          delay: 300.ms,
          duration: 500.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildActionButtons(
    BuildContext context,
    BiometricSetupState state,
    BiometricSetupNotifier notifier,
  ) {
    return Column(
      children: [
        // Enable biometrics button
        if (state.isAvailable && state.isEnrolled && !state.isEnabled)
          PrimaryButton(
                text: "Enable ${state.biometricDescription}",
                borderRadius: 38,
                onPressed:
                    state.isBusy
                        ? null
                        : () => notifier.enableBiometrics(context),
                backgroundColor: AppColors.purple500,
                height: 48.00000,
                textColor: state.isBusy
                    ? AppColors.neutral0.withOpacity(.20)
                    : AppColors.neutral0,
                fontFamily: 'Chirp',
                letterSpacing: -.70,
                fontSize: 18,
                width: double.infinity,
                fullWidth: true,
              )
              .animate()
              .fadeIn(
                delay: 1000.ms,
                duration: 500.ms,
                curve: Curves.easeOutCubic,
              )
              .slideY(
                begin: 0.3,
                end: 0,
                delay: 1000.ms,
                duration: 500.ms,
                curve: Curves.easeOutCubic,
              )
              .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.0, 1.0),
                delay: 1000.ms,
                duration: 500.ms,
                curve: Curves.easeOutCubic,
              ),

        if (state.isAvailable && state.isEnrolled && !state.isEnabled)
          SizedBox(height: 12),

        // Skip button
        SecondaryButton(
              text: state.isBusy ? "" : "Do it later",
              borderRadius: 38,
              onPressed: () async {
                // Close dialog first to avoid navigation conflicts
                // Navigator.of(dialogContext).pop();
                // Wait a frame to ensure dialog is fully closed before showing snackbar
                // await Future.delayed(const Duration(milliseconds: 100));
                // if (parentContext.mounted) {
                // await notifier.skipBiometrics(parentContext);
                // Navigate after snackbar is shown
                await Future.delayed(const Duration(milliseconds: 200));
                // if (parentContext.mounted) {
                appRouter.pushNamed(AppRoute.mainView);
                // }
                // }
              },
              borderColor: Colors.transparent,
              height: 48.00000,
              textColor: AppColors.purple500ForTheme(context),
              fontFamily: 'Chirp',
              letterSpacing: -.70,
              fontSize: 18,
              width: double.infinity,
              fullWidth: true,
            )
            .animate()
            .fadeIn(
              delay: 1000.ms,
              duration: 500.ms,
              curve: Curves.easeOutCubic,
            )
            .slideY(
              begin: 0.3,
              end: 0,
              delay: 1000.ms,
              duration: 500.ms,
              curve: Curves.easeOutCubic,
            )
            .scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1.0, 1.0),
              delay: 1000.ms,
              duration: 500.ms,
              curve: Curves.easeOutCubic,
            ),

        // Retry button if there's an error
        if (!state.isAvailable || !state.isEnrolled)
          Padding(
            padding: EdgeInsets.only(top: 12),
            child: TextButton(
              onPressed: state.isBusy ? null : () => notifier.retrySetup(),
              child: Text(
                'Retry',
                style: TextStyle(
                  fontFamily: 'Chirp',
                  color: AppColors.purple500ForTheme(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -.25,
                  height: 1.2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showSkipDialog(
    BuildContext context,
    BiometricSetupNotifier notifier,
    BiometricSetupState state,
  ) {
    // Capture parent context for use after dialog closes
    final parentContext = context;
    bool dialogLoading = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (BuildContext dialogContext) => StatefulBuilder(
            builder: (context, setStateSB) {
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
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.purple400, AppColors.orange500],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.purple500ForTheme(
                                context,
                              ).withOpacity(0.15),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: SvgPicture.asset(
                            state.hasBothFaceAndFingerprint
                                ? "assets/icons/svgs/security-safe.svg"
                                : state.biometricType.toLowerCase().contains(
                                  'face',
                                )
                                ? "assets/icons/svgs/face-id.svg"
                                : "assets/icons/svgs/face-id..svg",
                            color: Colors.white,
                            height: 24,
                          ),
                        ),
                      ),

                      SizedBox(height: 24),

                      // Title with auth view styling
                      Text(
                        'Do you want to enable ${state.biometricDescription} later?',
                        style: TextStyle(
                          fontFamily: 'FunnelDisplay',
                          fontSize: 24, // height: 1.6,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 16),

                      if (dialogLoading) ...[
                        SizedBox(height: 8),
                        LoadingAnimationWidget.horizontalRotatingDots(
                          color: AppColors.purple500ForTheme(context),
                          size: 22,
                        ),
                        SizedBox(height: 16),
                      ],

                      // Continue button with auth view styling
                      PrimaryButton(
                        text: dialogLoading ? '' : 'Yes, I\'ll do it later',
                        onPressed:
                            dialogLoading
                                ? null
                                : () async {
                                  setStateSB(() {
                                    dialogLoading = true;
                                  });
                                  // Close dialog first to avoid navigation conflicts
                                  Navigator.of(dialogContext).pop();
                                  // Wait a frame to ensure dialog is fully closed before showing snackbar
                                  await Future.delayed(
                                    const Duration(milliseconds: 100),
                                  );
                                  if (parentContext.mounted) {
                                    await notifier.skipBiometrics(
                                      parentContext,
                                    );
                                    // Navigate after snackbar is shown
                                    await Future.delayed(
                                      const Duration(milliseconds: 500),
                                    );
                                    if (parentContext.mounted) {
                                      appRouter.pushNamed(AppRoute.mainView);
                                    }
                                  }
                                },
                        backgroundColor: AppColors.purple500,
                        textColor: dialogLoading
                            ? AppColors.neutral0.withOpacity(.20)
                            : AppColors.neutral0,
                        borderRadius: 38,
                        height: 48.00000,
                        width: double.infinity,
                        fullWidth: true,
                        fontFamily: 'Chirp',
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.3,
                      ),
                      SizedBox(height: 12),

                      // Cancel button with auth view styling
                      SecondaryButton(
                        text: 'No, enable it now',
                        onPressed:
                            dialogLoading
                                ? null
                                : () {
                                  Navigator.of(dialogContext).pop();
                                  notifier.enableBiometrics(parentContext);
                                },
                        borderColor: Colors.transparent,
                        textColor: AppColors.purple500ForTheme(context),
                        width: double.infinity,
                        fullWidth: true,
                        height: 48.00000,
                        borderRadius: 38,
                        fontFamily: 'Chirp',
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.3,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }
}
