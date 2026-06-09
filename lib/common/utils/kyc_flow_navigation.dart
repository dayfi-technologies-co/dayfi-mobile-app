import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/utils/tier_utils.dart';
import 'package:dayfi/features/auth/upload_documents/views/upload_documents_view.dart';
import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';
import 'package:dayfi/models/user_model.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/services/remote/network/network_service.dart';
import 'package:dayfi/services/remote/smile_kyc_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Result returned when a KYC upgrade screen pops after verification.
class KycUpgradeOutcome {
  final bool success;
  final String? message;

  const KycUpgradeOutcome({required this.success, this.message});

  static KycUpgradeOutcome? fromPopResult(Object? result) {
    if (result == true) {
      return const KycUpgradeOutcome(success: true);
    }
    if (result is Map && result['success'] == true) {
      final raw = result['message'];
      return KycUpgradeOutcome(
        success: true,
        message: raw is String && raw.trim().isNotEmpty ? raw.trim() : null,
      );
    }
    if (result == null) return null;
    return const KycUpgradeOutcome(success: false);
  }
}

/// Central routing for Tier 2 (BVN + Smile selfie) and Tier 3 (NIN) verification.
class KycFlowNavigation {
  KycFlowNavigation._();

  static bool needsTier2(User? user) =>
      TierUtils.getCurrentTierLevel(user) < 2 || !TierUtils.hasBvnVerified(user);

  static bool needsTier3(User? user) {
    final tier = TierUtils.getCurrentTierLevel(user);
    return tier >= 2 && tier < 3 && !TierUtils.hasNinVerified(user);
  }

  static bool canUpgrade(User? user) => needsTier2(user) || needsTier3(user);

  static DateTime? _lastKycFetchTime;
  static bool? _cachedCanSendMoney;
  static const Duration _kycCacheTtl = Duration(seconds: 30);

  /// Warm KYC cache on Enter Amount so Review Transfer can navigate immediately.
  static Future<void> prefetchCanSendMoney(WidgetRef ref) {
    return refreshAndCanSendMoney(ref);
  }

  /// Refresh KYC from server and return whether the user can send money.
  static Future<bool> refreshAndCanSendMoney(
    WidgetRef ref, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        _lastKycFetchTime != null &&
        _cachedCanSendMoney != null &&
        DateTime.now().difference(_lastKycFetchTime!) < _kycCacheTtl) {
      return _cachedCanSendMoney!;
    }

    bool canSend;
    try {
      final status = await SmileKycApiService(networkService).fetchKycStatus();
      await ref
          .read(profileViewModelProvider.notifier)
          .applyKycProfileSnapshot(status);
      if (status['canSendMoney'] == true) {
        canSend = true;
      } else if (status['nextVerificationStep']?.toString() == 'none') {
        canSend = true;
      } else {
        canSend = false;
      }
    } catch (_) {
      final user = ref.read(profileViewModelProvider).user;
      canSend = !needsTier2(user);
    }

    _lastKycFetchTime = DateTime.now();
    _cachedCanSendMoney = canSend;
    return canSend;
  }

  /// Opens the correct next verification step for the user's current tier.
  /// Returns outcome when verification completed successfully.
  static Future<KycUpgradeOutcome?> startUpgrade(
    BuildContext context, {
    required WidgetRef ref,
    bool showBackButton = true,
    bool fromSignup = false,
    bool showIntro = true,
  }) async {
    final user = ref.read(profileViewModelProvider).user;

    if (!canUpgrade(user)) return null;

    if (needsTier2(user)) {
      if (showIntro && !fromSignup) {
        await _pushIntro(context, showBackButton: showBackButton);
        return null;
      }
      return _pushTier2(
        context,
        showBackButton: showBackButton,
        fromSignup: fromSignup,
      );
    }

    if (needsTier3(user)) {
      return _pushTier3(
        context,
        showBackButton: showBackButton,
        fromSignup: fromSignup,
      );
    }

    return null;
  }

  /// Tier 2: BVN + Smile face verification.
  static Future<KycUpgradeOutcome?> startTier2(
    BuildContext context, {
    bool showBackButton = true,
    bool fromSignup = false,
  }) {
    return _pushTier2(
      context,
      showBackButton: showBackButton,
      fromSignup: fromSignup,
    );
  }

  /// Tier 3: NIN verification (requires Tier 2).
  static Future<KycUpgradeOutcome?> startTier3(
    BuildContext context, {
    bool showBackButton = true,
    bool fromSignup = false,
  }) {
    return _pushTier3(
      context,
      showBackButton: showBackButton,
      fromSignup: fromSignup,
    );
  }

  static Future<void> _pushIntro(
    BuildContext context, {
    required bool showBackButton,
  }) async {
    if (showBackButton) {
      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (context) => UploadDocumentsView(showBackButton: true),
        ),
      );
      return;
    }

    await appRouter.pushNamed(
      AppRoute.uploadDocumentsView,
      arguments: {'showBackButton': false},
    );
  }

  static Future<KycUpgradeOutcome?> _pushTier2(
    BuildContext context, {
    required bool showBackButton,
    required bool fromSignup,
  }) async {
    final result = await appRouter.pushNamed<Object?>(
      AppRoute.smileKycView,
      arguments: {
        'showBackButton': showBackButton,
        'fromSignup': fromSignup,
        'mode': KycVerificationMode.tier2.name,
      },
    );
    return KycUpgradeOutcome.fromPopResult(result);
  }

  static Future<KycUpgradeOutcome?> _pushTier3(
    BuildContext context, {
    required bool showBackButton,
    required bool fromSignup,
  }) async {
    final result = await appRouter.pushNamed<Object?>(
      AppRoute.smileKycView,
      arguments: {
        'showBackButton': showBackButton,
        'fromSignup': fromSignup,
        'mode': KycVerificationMode.tier3.name,
      },
    );
    return KycUpgradeOutcome.fromPopResult(result);
  }
}
