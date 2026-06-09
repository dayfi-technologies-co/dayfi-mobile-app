import 'package:dayfi/models/user_model.dart';

/// Tier 2 = BVN + Smile selfie. Tier 3 = NIN only.
enum KycVerificationMode { tier2, tier3 }

/// Utility class for handling tier-related information and display logic
class TierUtils {
  /// Get the current tier level from user model
  static int getCurrentTierLevel(User? user) {
    if (user?.level == null || user!.level!.isEmpty) {
      return 1; // Default to Tier 1
    }

    // Parse level from format like "level-1", "level-2", etc.
    final levelString = user.level!.toLowerCase();
    if (levelString.startsWith('level-')) {
      final levelNumber = int.tryParse(levelString.substring(6));
      if (levelNumber == null || levelNumber < 1) return 1;
      return levelNumber.clamp(1, 3);
    }

    // Handle numeric strings
    final levelNumber = int.tryParse(user.level!);
    return (levelNumber ?? 1).clamp(1, 3);
  }

  static bool hasBvnVerified(User? user) {
    if (user == null) return false;
    if (user.idType?.toUpperCase() == 'BVN' &&
        (user.idNumber?.trim().length ?? 0) == 11) {
      return true;
    }
    return getCurrentTierLevel(user) >= 2;
  }

  /// True when the profile has a BVN on file (required for Flutterwave NGN VA).
  static bool hasBvnOnProfile(User? user) {
    if (user == null) return false;
    final idType = user.idType?.toUpperCase() ?? '';
    final idNum = user.idNumber?.trim() ?? '';
    return idType.contains('BVN') && idNum.length == 11;
  }

  /// Tier 2+ with BVN saved — matches backend before POST /wallets/add/fiat/ngn.
  static bool canProvisionNgnVirtualAccount(User? user) {
    if (user == null) return false;
    return getCurrentTierLevel(user) >= 2 && hasBvnOnProfile(user);
  }

  static bool hasNinVerified(User? user) {
    if (user == null) return false;
    final idType = user.idType?.toUpperCase() ?? '';
    final idNum = user.idNumber?.trim() ?? '';
    if (idType.contains('NIN') && idNum.length == 11) return true;
    return getCurrentTierLevel(user) >= 3;
  }

  /// Get tier display name (e.g., "Tier 1", "Tier 2")
  static String getTierDisplayName(User? user) {
    final tierLevel = getCurrentTierLevel(user);
    return 'Tier $tierLevel';
  }

  /// Get tier icon asset path
  static String getTierIconPath(User? user) {
    final tierLevel = getCurrentTierLevel(user);
    return 'assets/icons/pngs/tier$tierLevel.png';
  }

  /// Get tier color based on level
  static String getTierColor(User? user) {
    final tierLevel = getCurrentTierLevel(user);
    switch (tierLevel) {
      case 1:
        return 'info600';
      case 2:
        return 'success600';
      case 3:
        return 'warning600';
      default:
        return 'info600';
    }
  }

  /// Get tier description for upgrade prompts
  static String getTierDescription(User? user) {
    final tierLevel = getCurrentTierLevel(user);
    switch (tierLevel) {
      case 1:
        return 'You\'re currently on Tier 1. Complete BVN and selfie verification to unlock Tier 2, send money, and get your NGN account.';
      case 2:
        if (hasNinVerified(user)) {
          return 'You\'re currently on Tier 2. You have access to higher transfer limits.';
        }
        return 'You\'re currently on Tier 2. Verify your NIN to unlock Tier 3 and the highest transfer limits.';
      case 3:
        return 'You\'re on Tier 3 with the highest transfer limits.';
      default:
        return 'You\'re currently on Tier 1. Complete verification to access higher tiers.';
    }
  }

  /// Get next tier information for upgrade prompts
  static String getNextTierInfo(User? user) {
    if (needsTier2(user)) return 'Upgrade to Tier 2';
    if (needsTier3(user)) return 'Upgrade to Tier 3';
    return 'You\'re on the highest tier';
  }

  static bool needsTier2(User? user) =>
      getCurrentTierLevel(user) < 2 || !hasBvnVerified(user);

  static bool needsTier3(User? user) {
    final tier = getCurrentTierLevel(user);
    return tier >= 2 && tier < 3 && !hasNinVerified(user);
  }

  /// Check if user can upgrade to next tier
  static bool canUpgrade(User? user) => needsTier2(user) || needsTier3(user);

  /// Get tier limits information
  static Map<String, String> getTierLimits(User? user) {
    final tierLevel = getCurrentTierLevel(user);
    switch (tierLevel) {
      case 1:
        return {
          'monthly': '1,500,000 NGN',
          'yearly': '5,000,000 NGN',
          'description':
              'No verification required. However, you have a transfer limit of 1,500,000 NGN per month and 5,000,000 NGN per year.',
        };
      case 2:
        return {
          'monthly': '30,000,000 NGN',
          'yearly': '150,000,000 NGN',
          'description':
              'You can send up to 30,000,000 NGN per month and 150,000,000 NGN per year.',
        };
      case 3:
        return {
          'monthly': '150,000,000 NGN',
          'yearly': '450,000,000 NGN',
          'description':
              'You can send up to 150,000,000 NGN per month and 450,000,000 NGN per year.',
        };
      default:
        return {
          'monthly': '1,500,000 NGN',
          'yearly': '5,000,000 NGN',
          'description':
              'No verification required. However, you have a transfer limit of 1,500,000 NGN per month and 5,000,000 NGN per year.',
        };
    }
  }
}
