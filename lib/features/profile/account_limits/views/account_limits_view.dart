import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/services/kyc/kyc_service.dart';
import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';
import 'package:dayfi/common/utils/kyc_flow_navigation.dart';
import 'package:dayfi/common/utils/tier_utils.dart';
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
    final profileState = ref.watch(profileViewModelProvider);
    final user = profileState.user;

    final userTierLevel = TierUtils.getCurrentTierLevel(user);
    KycTier userTier;
    switch (userTierLevel) {
      case 1:
        userTier = KycTier.tier1;
        break;
      case 2:
        userTier = KycTier.tier2;
        break;
      case 3:
        userTier = KycTier.tier3;
        break;
      default:
        userTier = KycTier.tier1;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: .5,
        foregroundColor: Theme.of(context).scaffoldBackgroundColor,
        shadowColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => appRouter.pop(),
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        title: Text(
          "Account Limits",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontFamily: 'FunnelDisplay',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWide = constraints.maxWidth > 600;
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isWide ? 500 : double.infinity,
            ),
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 24 : 18,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Tier 1 Card
                    _buildTierCard(
                      tier: KycTier.tier1,
                      isCurrentTier: userTier == KycTier.tier1,
                      isCompleted: true, // Tier 1 is always completed
                      userTierLevel: userTierLevel,
                    ),
                    SizedBox(height: 20),

                    // Tier 2 Card
                    _buildTierCard(
                      tier: KycTier.tier2,
                      isCurrentTier: userTier == KycTier.tier2,
                      isCompleted: userTierLevel >= 2,
                      userTierLevel: userTierLevel,
                    ),

                    SizedBox(height: 20),

                    _buildTierCard(
                      tier: KycTier.tier3,
                      isCurrentTier: userTier == KycTier.tier3,
                      isCompleted: userTierLevel >= 3,
                      userTierLevel: userTierLevel,
                    ),

                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTierCard({
    required KycTier tier,
    required bool isCurrentTier,
    required bool isCompleted,
    required int userTierLevel,
    bool isTier4 = false,
  }) {
    // Get tier-specific colors and descriptions
    final tierInfo = _getTierInfo(tier, isTier4);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(tierInfo.icon, height: 40),
              SizedBox(width: 12),
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
                            fontFamily: 'FunnelDisplay',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isCurrentTier)
                          SvgPicture.asset(
                            'assets/icons/svgs/circle-check.svg',
                            color: AppColors.purple500ForTheme(context),
                          ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      tierInfo.description,
                      style: AppTypography.bodyMedium.copyWith(
                        fontFamily: 'Chirp',
                        letterSpacing: -.25,
                        fontSize: 14,
                        height: 1.2,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    // Increase limit CTA for current tier when upgrade is available
                    if (isCurrentTier && _shouldShowIncreaseLimit(tier, userTierLevel))
                      GestureDetector(
                        onTap: () => _navigateToVerification(tier),
                        child: Container(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            "Increase limit",
                            style: AppTypography.bodyMedium.copyWith(
                              fontFamily: 'Chirp',
                              fontSize: 16,
                              letterSpacing: -.25,
                              fontWeight: FontWeight.w600,
                              color: AppColors.purple500ForTheme(context),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _shouldShowIncreaseLimit(KycTier tier, int userTierLevel) {
    if (tier == KycTier.tier1 && userTierLevel == 1) return true;
    if (tier == KycTier.tier2 && userTierLevel == 2) return true;
    return false;
  }

  void _navigateToVerification(KycTier tier) {
    switch (tier) {
      case KycTier.tier1:
        KycFlowNavigation.startUpgrade(
          context,
          ref: ref,
          showBackButton: true,
          showIntro: true,
        );
        break;
      case KycTier.tier2:
        KycFlowNavigation.startTier3(context, showBackButton: true);
        break;
      case KycTier.tier3:
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
              "No verification required. However, you have a transfer limit of 1,500,000 NGN per month and 5,000,000 NGN per year.",
        );
      case KycTier.tier2:
        return TierInfo(
          icon: "assets/icons/pngs/tier2.png",
          title: "Tier 2",
          description:
              "You can send up to 30,000,000 NGN per month and 150,000,000 NGN per year when you complete your verification.",
        );
      case KycTier.tier3:
        return TierInfo(
          icon: "assets/icons/pngs/tier3.png",
          title: "Tier 3",
          description:
              "You can send up to 150,000,000 NGN per month and 450,000,000 NGN per year when you complete your verification.",
        );
    }
  }
}
