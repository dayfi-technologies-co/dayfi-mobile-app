import 'package:dayfi/common/utils/kyc_flow_navigation.dart';
import 'package:dayfi/common/utils/tier_utils.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tier upgrade prompt — shown on Profile / User profile when the user can upgrade.
class ProfileUpgradeCard extends ConsumerWidget {
  const ProfileUpgradeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(profileViewModelProvider).user;

    if (!TierUtils.canUpgrade(user)) {
      return const SizedBox.shrink();
    }

    final tierDescription = TierUtils.getTierDescription(user);
    final nextTierInfo = TierUtils.getNextTierInfo(user);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Image.asset('assets/icons/pngs/account_4.png', height: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Increase transfer limit',
                  style: AppTypography.titleMedium.copyWith(
                    fontFamily: 'FunnelDisplay',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    text: '$tierDescription ',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Chirp',
                      letterSpacing: -.250,
                      height: 1.2,
                    ),
                    children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: GestureDetector(
                          onTap: () {
                            KycFlowNavigation.startUpgrade(
                              context,
                              ref: ref,
                              showBackButton: true,
                              showIntro: TierUtils.needsTier2(user),
                            );
                          },
                          child: Text(
                            nextTierInfo,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Chirp',
                              letterSpacing: -.4,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
