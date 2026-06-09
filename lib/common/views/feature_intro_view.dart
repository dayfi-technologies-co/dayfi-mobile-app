import 'package:dayfi/common/constants/feature_intro_keys.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/buttons/secondary_button.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FeatureIntroView extends StatelessWidget {
  final DayfiHomeFeature feature;
  final VoidCallback onPrimary;
  final VoidCallback? onLater;
  final bool showLaterButton;

  const FeatureIntroView({
    super.key,
    required this.feature,
    required this.onPrimary,
    this.onLater,
    this.showLaterButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: feature.introBackgroundColor,
        body: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isWide ? 400 : double.infinity,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWide ? 24 : 18,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.only(left: 28),
                          child: Image.asset(
                            feature.imageAsset,
                            width: isWide
                                ? 180
                                : MediaQuery.sizeOf(context).width * 0.5,
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              feature.title,
                              style: AppTypography.headlineMedium.copyWith(
                                fontFamily: 'FunnelDisplay',
                                fontSize: isWide ? 32 : 28,
                                height: 1.2,
                                fontWeight: FontWeight.w600,
                                color: AppColors.neutral0,
                              ),
                              textAlign: TextAlign.center,
                            )
                                .animate()
                                .fadeIn(delay: 300.ms, duration: 400.ms),
                            const SizedBox(height: 18),
                            Text(
                              feature.subtitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Chirp',
                                    color: AppColors.neutral100,
                                    letterSpacing: -.25,
                                    height: 1.2,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: PrimaryButton(
                                text: feature.ctaLabel,
                                borderRadius: 38,
                                onPressed: onPrimary,
                                backgroundColor: Colors.white,
                                height: 48,
                                textColor: feature.introCtaTextColor,
                                fontFamily: 'Chirp',
                                letterSpacing: -.70,
                                fontSize: 18,
                                width: double.infinity,
                                fullWidth: true,
                              ),
                            ),
                            if (showLaterButton && onLater != null) ...[
                              const SizedBox(height: 12),
                              SecondaryButton(
                                text: "I'll explore later",
                                borderRadius: 38,
                                onPressed: onLater,
                                borderColor: Colors.transparent,
                                height: 48,
                                textColor: AppColors.neutral0,
                                fontFamily: 'Chirp',
                                letterSpacing: -.70,
                                fontSize: 18,
                                width: double.infinity,
                                fullWidth: true,
                              ),
                            ],
                            const SizedBox(height: 24),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
