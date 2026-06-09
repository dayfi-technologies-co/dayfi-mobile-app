import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/common/constants/username_copy.dart';
import 'package:flutter/material.dart';

/// One-time intro screens for the six home quick actions.
class FeatureIntroKeys {
  static const String send = 'feature_intro_seen_send';
  static const String add = 'feature_intro_seen_add';
  static const String swap = 'feature_intro_seen_swap';
  static const String pay = 'feature_intro_seen_pay';
  static const String invest = 'feature_intro_seen_invest';
  static const String budget = 'feature_intro_seen_budget';
}

enum DayfiHomeFeature {
  send,
  add,
  swap,
  pay,
  invest,
  budget,
}

extension DayfiHomeFeatureX on DayfiHomeFeature {
  String get storageKey {
    switch (this) {
      case DayfiHomeFeature.send:
        return FeatureIntroKeys.send;
      case DayfiHomeFeature.add:
        return FeatureIntroKeys.add;
      case DayfiHomeFeature.swap:
        return FeatureIntroKeys.swap;
      case DayfiHomeFeature.pay:
        return FeatureIntroKeys.pay;
      case DayfiHomeFeature.invest:
        return FeatureIntroKeys.invest;
      case DayfiHomeFeature.budget:
        return FeatureIntroKeys.budget;
    }
  }

  String get title {
    switch (this) {
      case DayfiHomeFeature.send:
        return 'Send money globally';
      case DayfiHomeFeature.add:
        return 'Add money to your wallet';
      case DayfiHomeFeature.swap:
        return 'Swap between currencies';
      case DayfiHomeFeature.pay:
        return 'Pay bills in seconds';
      case DayfiHomeFeature.invest:
        return 'Grow with daily interest';
      case DayfiHomeFeature.budget:
        return 'Plan & automate spending';
    }
  }

  String get subtitle {
    switch (this) {
      case DayfiHomeFeature.send:
        return UsernameCopy.sendIntro;
      case DayfiHomeFeature.add:
        return 'Top up via username, bank transfer, or crypto.';
      case DayfiHomeFeature.swap:
        return 'Convert USD, GBP, EUR, NGN and more at live rates.';
      case DayfiHomeFeature.pay:
        return 'Airtime, data, cable, utilities, and more.';
      case DayfiHomeFeature.invest:
        return 'Named pots with daily interest — withdraw anytime.';
      case DayfiHomeFeature.budget:
        return 'Plan spending and automate sends and bills with DayFlow.';
    }
  }

  /// Screen title after intro (Send money, Add money, etc.).
  String get screenTitle {
    switch (this) {
      case DayfiHomeFeature.send:
        return 'Send money';
      case DayfiHomeFeature.add:
        return 'Add money';
      case DayfiHomeFeature.swap:
        return 'Swap money';
      case DayfiHomeFeature.pay:
        return 'Pay bills';
      case DayfiHomeFeature.invest:
        return 'DayEarn';
      case DayfiHomeFeature.budget:
        return 'DayFlow';
    }
  }

  String get ctaLabel {
    switch (this) {
      case DayfiHomeFeature.send:
        return 'Start sending';
      case DayfiHomeFeature.add:
        return 'Add money';
      case DayfiHomeFeature.swap:
        return 'Start swapping';
      case DayfiHomeFeature.pay:
        return 'Pay a bill';
      case DayfiHomeFeature.invest:
        return 'Create DayEarn';
      case DayfiHomeFeature.budget:
        return 'Talk to DayFlow';
    }
  }

  String get imageAsset {
    switch (this) {
      case DayfiHomeFeature.send:
        return 'assets/images/upload_doc.png';
      case DayfiHomeFeature.add:
        return 'assets/images/upload_doc.png';
      case DayfiHomeFeature.swap:
        return 'assets/images/upload_doc.png';
      case DayfiHomeFeature.pay:
        return 'assets/images/upload_doc.png';
      case DayfiHomeFeature.invest:
        return 'assets/images/upload_doc.png';
      case DayfiHomeFeature.budget:
        return 'assets/images/upload_doc.png';
    }
  }

  /// Full-screen intro background — one distinct color per feature (no orange).
  Color get introBackgroundColor {
    switch (this) {
      case DayfiHomeFeature.send:
        return AppColors.info500; // Blue — global transfers
      case DayfiHomeFeature.add:
        return AppColors.success600; // Green — add money
      case DayfiHomeFeature.swap:
        return AppColors.purple600; // Purple — currency swap
      case DayfiHomeFeature.pay:
        return AppColors.primary500; // Teal — bills & utilities
      case DayfiHomeFeature.invest:
        return AppColors.warning600; // Gold — DayEarn
      case DayfiHomeFeature.budget:
        return AppColors.pink500; // Pink — budgets & limits
    }
  }

  /// Primary CTA label on white button.
  Color get introCtaTextColor => introBackgroundColor;
}
