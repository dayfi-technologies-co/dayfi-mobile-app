import 'package:dayfi/models/user_model.dart';

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
      return levelNumber ?? 1;
    }

    // Handle numeric strings
    final levelNumber = int.tryParse(user.level!);
    return levelNumber ?? 1;
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
        return 'You\'re currently on Tier 1. Submit required documents to access Tier 2 and send higher amounts.';
      case 2:
        return 'You\'re currently on Tier 2. Complete additional verification to access Tier 3 and send higher amounts.';
      case 3:
        return 'You\'re currently on Tier 3. You have access to the highest transfer limits.';
      default:
        return 'You\'re currently on Tier 1. Submit required documents to access higher tiers and send higher amounts.';
    }
  }

  /// Get next tier information for upgrade prompts
  static String getNextTierInfo(User? user) {
    final tierLevel = getCurrentTierLevel(user);
    switch (tierLevel) {
      case 1:
        return 'Upgrade to Tier 2';
      case 2:
        return 'Upgrade to Tier 3';
      case 3:
        return 'You\'re on the highest tier';
      default:
        return 'Upgrade to Tier 2';
    }
  }

  /// Check if user can upgrade to next tier
  static bool canUpgrade(User? user) {
    final tierLevel = getCurrentTierLevel(user);
    return tierLevel < 3;
  }

  /// Get tier limits information
  static Map<String, String> getTierLimits(User? user) {
    final tierLevel = getCurrentTierLevel(user);
    switch (tierLevel) {
      case 1:
        return {
          'monthly': '1,000 USD',
          'yearly': '10,000 USD',
          'description':
              'No verification required. However, you have a transfer limit of 1,000 USD per month and 10,000 USD per year.',
        };
      case 2:
        return {
          'monthly': '20,000 USD',
          'yearly': '100,000 USD',
          'description':
              'You can send up to 20,000 USD per month and 100,000 USD per year.',
        };
      case 3:
        return {
          'monthly': '100,000 USD',
          'yearly': '300,000 USD',
          'description':
              'You can send up to 100,000 USD per month and 300,000 USD per year.',
        };
      default:
        return {
          'monthly': '1,000 USD',
          'yearly': '10,000 USD',
          'description':
              'No verification required. However, you have a transfer limit of 1,000 USD per month and 10,000 USD per year.',
        };
    }
  }
}
