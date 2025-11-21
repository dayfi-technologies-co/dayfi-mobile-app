import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/services/kyc/kyc_service.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/app_locator.dart';
import 'package:flutter_svg/svg.dart';

// Tier information data class
class TierInfo {
  final String icon;
  final String title;
  final String description;

  TierInfo({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class AccountLimitsView extends ConsumerStatefulWidget {
  const AccountLimitsView({super.key});

  @override
  ConsumerState<AccountLimitsView> createState() => _AccountLimitsViewState();
}

class _AccountLimitsViewState extends ConsumerState<AccountLimitsView> {
  @override
  Widget build(BuildContext context) {
    final currentTierAsync = ref.watch(currentKycTierProvider);
    final kycService = ref.read(kycServiceProvider);
    // appRouter is imported from app_locator.dart

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => appRouter.pop(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.onSurface,
            // size: 20.sp,
          ),
        ),
        title: Text(
          "Account Limits",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontFamily: 'CabinetGrotesk',
            fontSize: 19.sp, // height: 1.6,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tier 1 Card
              _buildTierCard(
                tier: KycTier.tier1,
                isCurrentTier: currentTierAsync.valueOrNull == KycTier.tier1,
                isCompleted: true, // Tier 1 is always completed
                kycService: kycService,
              ),
              SizedBox(height: 20.h),

              // Tier 2 Card
              _buildTierCard(
                tier: KycTier.tier2,
                isCurrentTier: currentTierAsync.valueOrNull == KycTier.tier2,
                isCompleted: (currentTierAsync.valueOrNull?.level ?? 0) >= 2,
                kycService: kycService,
              ),
              SizedBox(height: 20.h),

              // Tier 3 Card
              // _buildTierCard(
              //   tier: KycTier.tier3,
              //   isCurrentTier: currentTierAsync.valueOrNull == KycTier.tier3,
              //   isCompleted: (currentTierAsync.valueOrNull?.level ?? 0) >= 3,
              //   kycService: kycService,
              // ),
              SizedBox(height: 50.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTierCard({
    required KycTier tier,
    required bool isCurrentTier,
    required bool isCompleted,
    required KycService kycService,
    bool isTier4 = false,
  }) {
    // Get tier-specific colors and descriptions
    final tierInfo = _getTierInfo(tier, isTier4);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        // border: Border.all(color: AppColors.warning400.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral500.withOpacity(0.065),
            blurRadius: 8.0,
            offset: const Offset(0, 8),
            spreadRadius: .8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with medal icon and title
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Medal Icon
              Image.asset(tierInfo.icon, height: 40.h),
              SizedBox(width: 12.w),

              // body
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          tierInfo.title,
                          style: AppTypography.titleMedium.copyWith(
                            fontFamily: 'CabinetGrotesk',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            // color: AppColors.neutral800,
                          ),
                        ),

                        // Checkmark for current tier
                        if (isCurrentTier)
                          SvgPicture.asset(
                            'assets/icons/svgs/circle-check.svg',
                            color: AppColors.purple500ForTheme(context),
                          ),
                      ],
                    ),
                    SizedBox(height: 8.h),

                    // Description
                    Text(
                      tierInfo.description,
                      style: AppTypography.bodyMedium.copyWith(
                        fontFamily: 'Karla',
                        letterSpacing: -.3,
                        fontSize: 14.sp,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),

                    // Increase limit button for current tier
                    // if (isCurrentTier)
                    //   GestureDetector(
                    //     onTap: () => _navigateToVerification(tier),
                    //     child: Container(
                    //       padding: EdgeInsets.only(top: 10.h),
                    //       child: Text(
                    //         "Increase limit",
                    //         style: AppTypography.bodyMedium.copyWith(
                    //        fontFamily: 'CabinetGrotesk',
                    //           fontSize: 12.sp,
                    //           fontWeight: FontWeight.w600,
                    //           color: AppColors.purple500ForTheme(context),
                    //           // decoration: TextDecoration.underline,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToVerification(KycTier tier) {
    switch (tier) {
      case KycTier.tier1:
        // Tier 1 is already completed
        break;
      case KycTier.tier2:
        appRouter.pushNamed(
          AppRoute.uploadDocumentsView,
          arguments: {'showBackButton': true},
        );
        break;
      case KycTier.tier3:
        // TODO: Navigate to Tier 3 verification when implemented
        appRouter.pushNamed(
          AppRoute.uploadDocumentsView,
          arguments: {'showBackButton': true},
        );
        break;
    }
  }

  // Get tier-specific information
  TierInfo _getTierInfo(KycTier tier, bool isTier4) {
    switch (tier) {
      case KycTier.tier1:
        return TierInfo(
          icon: "assets/icons/pngs/tier1.png",
          title: "Tier 1",
          description:
              "No verification required. However, you have a transfer limit of 1,000 USD per month and 10,000 USD per year.",
        );
      case KycTier.tier2:
        return TierInfo(
          icon: "assets/icons/pngs/tier2.png",
          title: "Tier 2",
          description:
              "You can send up to 20,000 USD per month and 100,000 USD per year when you complete your verification.",
        );
      case KycTier.tier3:
        return TierInfo(
          icon: "assets/icons/pngs/tier3.png",
          title: "Tier 3",
          description:
              "You can send up to 100,000 USD per month and 300,000 USD per year when you complete your verification.",
        );
    }
  }
}
