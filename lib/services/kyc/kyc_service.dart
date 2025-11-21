import 'package:dayfi/services/local/secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/app_locator.dart';

enum KycTier {
  tier1('Tier 1', 1),
  tier2('Tier 2', 2),
  tier3('Tier 3', 3);

  const KycTier(this.displayName, this.level);
  final String displayName;
  final int level;
}

class KycLimits {
  final int singleTransactionLimit;
  final int dailyTransactionLimit;
  final int maxWalletBalance;

  const KycLimits({
    required this.singleTransactionLimit,
    required this.dailyTransactionLimit,
    required this.maxWalletBalance,
  });

  // Tier 1 limits (Basic KYC)
  static const KycLimits tier1 = KycLimits(
    singleTransactionLimit: 50000, // ₦50,000
    dailyTransactionLimit: 300000, // ₦300,000
    maxWalletBalance: 300000, // ₦300,000
  );

  // Tier 2 limits (Standard KYC)
  static const KycLimits tier2 = KycLimits(
    singleTransactionLimit: 200000, // ₦200,000
    dailyTransactionLimit: 500000, // ₦500,000
    maxWalletBalance: 500000, // ₦500,000
  );

  // Tier 3 limits (Full KYC)
  static const KycLimits tier3 = KycLimits(
    singleTransactionLimit: 1000000, // ₦1,000,000
    dailyTransactionLimit: 5000000, // ₦5,000,000
    maxWalletBalance: 5000000, // ₦5,000,000
  );

  static KycLimits getLimitsForTier(KycTier tier) {
    switch (tier) {
      case KycTier.tier1:
        return tier1;
      case KycTier.tier2:
        return tier2;
      case KycTier.tier3:
        return tier3;
    }
  }

  String formatAmount(int amount) {
    if (amount >= 1000000) {
      return '₦${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '₦${(amount / 1000).toStringAsFixed(0)}k';
    } else {
      return '₦${amount.toString()}';
    }
  }
}

class KycService {
  final SecureStorageService _secureStorage;
  static const String _kycTierKey = 'kyc_tier';
  static const String _kycCompletedKey = 'kyc_completed';

  KycService({required SecureStorageService secureStorage})
      : _secureStorage = secureStorage;

  // Get current KYC tier
  Future<KycTier> getCurrentTier() async {
    final tierString = await _secureStorage.read(_kycTierKey);
    
    return KycTier.values.firstWhere(
      (tier) => tier.level.toString() == tierString,
      orElse: () => KycTier.tier1,
    );
  }

  // Set KYC tier
  Future<void> setKycTier(KycTier tier) async {
    await _secureStorage.write(_kycTierKey, tier.level.toString());
  }

  // Check if KYC is completed for a specific tier
  Future<bool> isKycCompletedForTier(KycTier tier) async {
    final currentTier = await getCurrentTier();
    return currentTier.level >= tier.level;
  }

  // Get limits for current tier
  Future<KycLimits> getCurrentLimits() async {
    final currentTier = await getCurrentTier();
    return KycLimits.getLimitsForTier(currentTier);
  }

  // Check if transaction is within limits
  Future<bool> isTransactionWithinLimits({
    required int amount,
    required int dailySpent,
  }) async {
    final limits = await getCurrentLimits();
    return amount <= limits.singleTransactionLimit &&
           (dailySpent + amount) <= limits.dailyTransactionLimit;
  }

  // Get remaining daily limit
  Future<int> getRemainingDailyLimit(int dailySpent) async {
    final limits = await getCurrentLimits();
    return (limits.dailyTransactionLimit - dailySpent).clamp(0, limits.dailyTransactionLimit);
  }

  // Check if wallet balance is within limits
  Future<bool> isWalletBalanceWithinLimits(int currentBalance) async {
    final limits = await getCurrentLimits();
    return currentBalance <= limits.maxWalletBalance;
  }

  // Get KYC requirements for a tier
  List<String> getKycRequirementsForTier(KycTier tier) {
    switch (tier) {
      case KycTier.tier1:
        return [
          'Full Name',
          'Phone Number',
          'Date of Birth',
          'Address (optional)',
          'Email (optional)',
          'BVN (optional but recommended)',
        ];
      case KycTier.tier2:
        return [
          'All Tier 1 requirements',
          'Valid Government-issued ID',
          'BVN (mandatory)',
          'Photo/Selfie verification',
        ];
      case KycTier.tier3:
        return [
          'All Tier 2 requirements',
          'Proof of Address',
          'Additional verification',
        ];
    }
  }

  // Get tier benefits
  List<String> getTierBenefits(KycTier tier) {
    final limits = KycLimits.getLimitsForTier(tier);
    return [
      'Single Transaction: ${limits.formatAmount(limits.singleTransactionLimit)}',
      'Daily Limit: ${limits.formatAmount(limits.dailyTransactionLimit)}',
      'Max Wallet Balance: ${limits.formatAmount(limits.maxWalletBalance)}',
    ];
  }

  // Upgrade to next tier
  Future<bool> upgradeToNextTier() async {
    final currentTier = await getCurrentTier();
    
    if (currentTier == KycTier.tier3) {
      return false; // Already at highest tier
    }
    
    final nextTier = KycTier.values.firstWhere(
      (tier) => tier.level == currentTier.level + 1,
    );
    
    await setKycTier(nextTier);
    return true;
  }

  // Reset KYC (for testing purposes)
  Future<void> resetKyc() async {
    await _secureStorage.delete(_kycTierKey);
    await _secureStorage.delete(_kycCompletedKey);
  }
}

// Provider
final kycServiceProvider = Provider<KycService>((ref) {
  return KycService(secureStorage: secureStorage);
});

// Current KYC tier provider
final currentKycTierProvider = FutureProvider<KycTier>((ref) {
  final kycService = ref.read(kycServiceProvider);
  return kycService.getCurrentTier();
});

// Current KYC limits provider
final currentKycLimitsProvider = FutureProvider<KycLimits>((ref) {
  final kycService = ref.read(kycServiceProvider);
  return kycService.getCurrentLimits();
});
