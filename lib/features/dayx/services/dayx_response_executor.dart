import 'package:dayfi/features/dayx/models/dayx_intent.dart';
import 'package:dayfi/features/dayx/widgets/dayx_navigation.dart';
import 'package:dayfi/features/dayflow/dayflow_flow.dart';
import 'package:dayfi/services/local/biometric_service.dart';
import 'package:dayfi/services/local/intercom_support_service.dart';
import 'package:flutter/material.dart';

/// Shared intent routing for chat and voice overlays.
abstract final class DayxResponseExecutor {
  static bool isSupportIntent(DayxIntent? intent) {
    if (intent == null) return false;
    if (intent.action == DayxIntentActions.openSupport) return true;
    if (intent.action != DayxIntentActions.navigate) return false;
    final target = intent.params['target']?.toString().trim().toLowerCase() ?? '';
    return target == DayxNavigateTargets.support ||
        target == 'customer_support' ||
        target == 'contact_support';
  }

  static Future<void> routeTo({
    required BuildContext context,
    required String target,
    required DayxChangeTab changeTab,
    void Function(String target)? onNavigate,
  }) async {
    if (onNavigate != null) {
      onNavigate(target);
      return;
    }
    DayxNavigation.handle(
      context: context,
      target: target,
      changeTab: changeTab,
    );
  }

  static Future<void> handleNavigateIntent({
    required BuildContext context,
    required DayxIntent intent,
    required DayxChangeTab changeTab,
    void Function(String target)? onNavigate,
    required VoidCallback dismissOverlay,
  }) async {
    if (intent.action != DayxIntentActions.navigate) return;
    final target = intent.params['target']?.toString();
    if (target == null) return;
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!context.mounted) return;
    dismissOverlay();
    await routeTo(
      context: context,
      target: target,
      changeTab: changeTab,
      onNavigate: onNavigate,
    );
  }

  static Future<void> openSupport({required VoidCallback dismissOverlay}) async {
    await Future<void>.delayed(const Duration(milliseconds: 280));
    dismissOverlay();
    await IntercomSupportService.openContactSupport();
  }

  static Future<bool> confirmTransferWithBiometric() {
    return BiometricService.authenticateWithPlatformMessaging(
      customReason: 'Confirm this transfer to continue',
    );
  }

  /// Legacy send navigation removed — money flows stay inside DayX overlays.
  static Future<void> openSendAfterVerification({
    required BuildContext context,
    required VoidCallback dismissOverlay,
    DayxTransferProposal? proposal,
  }) async {
    dismissOverlay();
  }

  static Future<void> openDayFlow({
    required BuildContext context,
    required VoidCallback dismissOverlay,
  }) async {
    dismissOverlay();
    await Future<void>.delayed(const Duration(milliseconds: 280));
    if (!context.mounted) return;
    await DayFlowFlow.openOverlay(context);
  }
}
