import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/buttons/secondary_button.dart';
import 'package:dayfi/features/auth/biometric_setup/vm/biometric_setup_viewmodel.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:dayfi/app_locator.dart';

class BiometricSetupView extends ConsumerStatefulWidget {
  final bool fromProfile;
  final bool fromSignup;

  const BiometricSetupView({
    super.key,
    this.fromProfile = true,
    this.fromSignup = false,
  });

  @override
  ConsumerState<BiometricSetupView> createState() => _BiometricSetupViewState();
}

class _BiometricSetupViewState extends ConsumerState<BiometricSetupView> {
  bool _autoPrompted = false;

  @override
  Widget build(BuildContext context) {
    ref.listen(biometricSetupProvider, (previous, next) {
      if (!_autoPrompted &&
          !next.isBusy &&
          next.isAvailable &&
          next.isEnrolled &&
          !next.isEnabled) {
        _autoPrompted = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ref.read(biometricSetupProvider.notifier).enableBiometrics(context);
          }
        });
      }
    });

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
                      const SizedBox(height: 32),
                      _buildContentCard(context, biometricState, isWide),
                      const SizedBox(height: 32),
                      _buildActionButtons(
                        context,
                        biometricState,
                        biometricNotifier,
                      ),
                      const SizedBox(height: 32),
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
    final title = state.isEnabled
        ? '${state.biometricDescription} enabled'
        : 'Enable ${state.biometricDescription}';

    return Column(
          children: [
            Text(
                  title,
                  style: AppTypography.headlineMedium.copyWith(
                    fontFamily: 'FunnelDisplay',
                    fontSize: isWide ? 32 : 28,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
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

            const SizedBox(height: 16),

            Text(
                  state.isEnabled
                      ? 'Taking you back…'
                      : state.isAvailable && state.isEnrolled
                      ? state.hasBothFaceAndFingerprint
                          ? 'Use Face ID or fingerprint to sign in quickly and securely.'
                          : 'Use your ${state.biometricType.toLowerCase()} to sign in quickly and securely.'
                      : state.errorMessage.isNotEmpty
                      ? state.errorMessage
                      : 'Setting up biometric authentication…',
                  style: AppTypography.bodyLarge.copyWith(
                    fontFamily: 'Chirp',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                    color:
                        state.isEnabled ||
                            (state.isAvailable && state.isEnrolled)
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
              const SizedBox(height: 24),
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
    if (state.isEnabled) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        if (state.isAvailable && !state.isEnabled)
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
              ),

        if (state.isAvailable && !state.isEnabled)
          const SizedBox(height: 12),

        SecondaryButton(
              text: state.isBusy ? '' : 'Do it later',
              borderRadius: 38,
              onPressed: state.isBusy
                  ? null
                  : () async {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop(false);
                    } else if (appRouter.canPop()) {
                      appRouter.pop(false);
                    } else {
                      await appRouter.pushMainAndClearStack();
                    }
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
            ),

        if (!state.isAvailable || !state.isEnrolled)
          Padding(
            padding: const EdgeInsets.only(top: 12),
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
}
