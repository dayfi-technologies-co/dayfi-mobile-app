import 'package:dayfi/common/constants/product_features.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/features/dayflow/daybudget_flow.dart';
import 'package:dayfi/features/legal/privacy_notice.dart';
import 'package:dayfi/features/legal/terms_of_use.dart';
import 'package:dayfi/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:dayfi/services/local/intercom_support_service.dart';

/// Navigation helpers for profile / more settings rows.
abstract final class ProfileSettingsNavigation {
  static void toUserProfile() => appRouter.pushNamed(AppRoute.userProfileView);

  static void toAccountLimits() => appRouter.pushNamed(AppRoute.accountLimitsView);

  static void toTransactions() => appRouter.pushNamed(AppRoute.transactionsView);

  static void toBudgets() {
    if (!ProductFeatures.budgets) return;
    appRouter.pushNamed(AppRoute.budgetsView);
  }

  static Future<void> toDayFlow(BuildContext context) async {
    if (!ProductFeatures.dayFlowAutopay) return;
    await DayBudgetFlow.open(context);
  }

  static void toRecipients() => appRouter.pushNamed(
        AppRoute.recipientsView,
        arguments: {'fromProfile': true, 'fromSendView': false},
      );

  static void toRecoveryPhrase() =>
      appRouter.pushNamed(AppRoute.recoveryPhraseView);

  static void toChangeTransactionPin() =>
      appRouter.pushNamed(AppRoute.changeTransactionPinOldView);

  static void toResetTransactionPin() =>
      appRouter.pushNamed(AppRoute.resetTransactionPinIntroView);

  static Future<void> toBiometricSetup({bool fromProfile = true}) async {
    await appRouter.pushNamed(
      AppRoute.biometricSetupView,
      arguments: {
        'fromProfile': fromProfile,
        'fromSignup': !fromProfile,
      },
    );
  }

  static Future<void> contactUs(BuildContext context) async {
    try {
      await IntercomSupportService.openContactSupport();
    } catch (_) {
      if (context.mounted) {
        TopSnackbar.show(
          context,
          message: 'Unable to open support chat. Please try again later.',
          isError: true,
        );
      }
    }
  }

  static void toFaqs() => appRouter.pushNamed(AppRoute.faqView);

  static void toTerms(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TermsOfUseView()),
    );
  }

  static void toPrivacy(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PrivacyNoticeView()),
    );
  }
}
