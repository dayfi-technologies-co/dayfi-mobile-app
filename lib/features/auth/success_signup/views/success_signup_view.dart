import 'package:dayfi/common/widgets/buttons/buttons.dart';
import 'package:lottie/lottie.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dayfi/routes/route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/app_locator.dart';

class SuccessSignupView extends ConsumerWidget {
  const SuccessSignupView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Note: Signup success notification is now triggered in main_view.dart
    // when user first lands on the home screen after signup
    // This ensures the notification is shown at the right time

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            // Confetti Lottie animation
            Positioned.fill(
              child: IgnorePointer(
                child: Lottie.asset(
                  'assets/icons/svgs/confetti.json',
                  fit: BoxFit.cover,
                  repeat: false,
                ),
              ),
            ),
            // Main content
            SafeArea(
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
                        padding: EdgeInsets.symmetric(
                          horizontal: isWide ? 24 : 18,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 32),
                            _buildContentCard(context, isWide),
                            SizedBox(height: 32),
                            _buildNextStepButton(context),
                            SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.purple50,
            AppColors.neutral50,
            AppColors.purple100.withOpacity(0.3),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildBackgroundElements(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          // Floating circles
          Positioned(
            top: 100,
            left: -50,
            child: _buildFloatingCircle(
              size: 120,
              color: AppColors.purple100.withOpacity(0.3),
            ),
          ),
          Positioned(
            top: 200,
            right: -30,
            child: _buildFloatingCircle(
              size: 80,
              color: AppColors.purple300.withOpacity(0.2),
            ),
          ),
          Positioned(
            bottom: 150,
            left: -20,
            child: _buildFloatingCircle(
              size: 100,
              color: AppColors.purple100.withOpacity(0.4),
            ),
          ),
          Positioned(
            bottom: 250,
            right: -40,
            child: _buildFloatingCircle(
              size: 60,
              color: AppColors.purple100.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingCircle({required double size, required Color color}) {
    return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .fadeIn(duration: 2000.ms, curve: Curves.easeInOut)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.2, 1.2),
          duration: 3000.ms,
          curve: Curves.easeInOut,
        );
  }

  Widget _buildSuccessIcon(BuildContext context) {
    return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.purple500ForTheme(context),
                AppColors.purple600,
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.purple500ForTheme(context).withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(Icons.check_rounded, color: AppColors.neutral0, size: 60),
        )
        .animate()
        .fadeIn(delay: 200.ms, duration: 600.ms, curve: Curves.easeOutCubic)
        .scale(
          begin: const Offset(0.0, 0.0),
          end: const Offset(1.0, 1.0),
          delay: 200.ms,
          duration: 600.ms,
          curve: Curves.elasticOut,
        )
        .then()
        .shimmer(duration: 1000.ms, color: AppColors.neutral0.withOpacity(0.3));
  }

  Widget _buildContentCard(BuildContext context, bool isWide) {
    return Column(
          children: [
            // Celebration emoji
            Text("🎉", style: TextStyle(fontSize: 56))
                .animate()
                .fadeIn(
                  delay: 400.ms,
                  duration: 500.ms,
                  curve: Curves.easeOutCubic,
                )
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1.0, 1.0),
                  delay: 400.ms,
                  duration: 500.ms,
                  curve: Curves.elasticOut,
                ),

            SizedBox(height: 24),

            // Title
            Text(
                  "Welcome onboard!",
                  style: AppTypography.headlineMedium.copyWith(
                    fontFamily: 'FunnelDisplay',
                    fontSize: isWide ? 32 : 28,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                    // height: 1.2,
                    // letterSpacing: -.4,
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

            SizedBox(height: 12),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                    "Account created! Start sending money to your loved ones",
                    style: AppTypography.bodyLarge.copyWith(
                      fontFamily: 'Chirp',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.neutral600,
                      height: 1.2,
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
            ),

            // SizedBox(height: 32),

            // // Features list
            // _buildFeaturesList(),
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

  Widget _buildFeaturesList(BuildContext context) {
    final features = [
      {"icon": "💸", "text": "Send money instantly"},
      {"icon": "🌍", "text": "Global transfers"},
      {"icon": "🔒", "text": "Secure & encrypted"},
    ];

    return Column(
      children:
          features.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, String> feature = entry.value;

            return Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Text(feature["icon"]!, style: TextStyle(fontSize: 24)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature["text"]!,
                          style: AppTypography.bodyMedium.copyWith(
                            fontFamily: 'Chirp',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyLarge!.color!.withOpacity(.85),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(
                  delay: (700 + (index * 100)).ms,
                  duration: 300.ms,
                  curve: Curves.easeOutCubic,
                )
                .slideX(
                  begin: -0.2,
                  end: 0,
                  delay: (700 + (index * 100)).ms,
                  duration: 300.ms,
                  curve: Curves.easeOutCubic,
                );
          }).toList(),
    );
  }

  Widget _buildNextStepButton(BuildContext context) {
    return PrimaryButton(
          text: "Complete Profile",
          borderRadius: 38,
          onPressed:
              () => appRouter.pushNamed(AppRoute.completePersonalInfoView),
          backgroundColor: AppColors.purple500,
          height: 48.00000,
          textColor: AppColors.neutral0,
          fontFamily: 'Chirp',
          letterSpacing: -.70,
          fontSize: 18,
          width: double.infinity,
          fullWidth: true,
        )
        .animate()
        .fadeIn(delay: 1000.ms, duration: 500.ms, curve: Curves.easeOutCubic)
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
        );
  }
}
