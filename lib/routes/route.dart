import 'dart:io';

import 'package:dayfi/features/recipients/views/recipients_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dayfi/features/auth/login/views/login_view.dart';
import 'package:dayfi/features/auth/splash/views/splash_view.dart';
import 'package:dayfi/features/auth/signup/views/signup_view.dart';
import 'package:dayfi/features/auth/verify_email/views/verify_email_view.dart';
import 'package:dayfi/features/auth/success_signup/views/success_signup_view.dart';
import 'package:dayfi/features/auth/create_passcode/views/create_passcode_view.dart';
import 'package:dayfi/features/auth/reenter_passcode/views/reenter_passcode_view.dart';
import 'package:dayfi/features/auth/forgot_password/views/forgot_password_view.dart';
import 'package:dayfi/features/auth/reset_password/views/reset_password_view.dart';
import 'package:dayfi/features/auth/passcode/views/passcode_view.dart';
import 'package:dayfi/features/auth/complete_personal_information/views/complete_personal_information_view.dart';
import 'package:dayfi/features/auth/upload_documents/views/upload_documents_view.dart';
import 'package:dayfi/features/auth/bvn_nin_verification/views/bvn_nin_verification_view.dart';
import 'package:dayfi/features/auth/biometric_setup/views/biometric_setup_view.dart';
import 'package:dayfi/features/auth/dayfi_tag/views/dayfi_tag_explanation_view.dart';
import 'package:dayfi/features/auth/dayfi_tag/views/create_dayfi_tag_view.dart';
import 'package:dayfi/features/main/views/main_view.dart';
import 'package:dayfi/features/auth/onboarding/views/onboarding_view.dart';
import 'package:dayfi/features/profile/edit_profile/views/edit_profile_view.dart';
import 'package:dayfi/features/profile/account_limits/views/account_limits_view.dart';
import 'package:dayfi/features/transactions/views/transaction_details_view.dart';
import 'package:dayfi/features/transactions/views/transactions_view.dart';
import 'package:dayfi/models/wallet_transaction.dart';
import 'package:dayfi/features/send/views/send_fetch_crypto_channels.dart';
import 'package:dayfi/features/send/views/send_crypto_networks_view.dart';
import 'package:dayfi/features/send/views/send_add_recipients_view.dart';
import 'package:dayfi/features/send/views/send_dayfi_id_view.dart';
import 'package:dayfi/features/send/views/send_dayfi_id_review_view.dart';
import 'package:dayfi/features/send/views/send_recipient_view.dart';
import 'package:dayfi/features/send/views/send_review_view.dart';
import 'package:dayfi/features/send/views/regular_transfer_transaction_pin_view.dart';
import 'package:dayfi/features/send/views/send_payment_success_view.dart';
import 'package:dayfi/features/send/views/transaction_pin_create_view.dart';
import 'package:dayfi/features/send/views/transaction_pin_reenter_view.dart';
import 'package:dayfi/features/send/views/send_payment_method_view.dart';
import 'package:dayfi/features/profile/views/change_transaction_pin_old_view.dart';
import 'package:dayfi/features/profile/views/change_transaction_pin_new_view.dart';
import 'package:dayfi/features/profile/views/change_transaction_pin_confirm_view.dart';

class VerifyEmailViewArguments {
  final bool isSignUp;
  final String email;
  final String password;

  const VerifyEmailViewArguments({
    required this.isSignUp,
    required this.email,
    this.password = "",
  });
}

class AppRoute {
  static RouteSettings globalrouteSettings = const RouteSettings();

  static const String splashView = '/splashView';
  static const String onboardingView = '/onboardingView';
  static const String loginView = '/loginView';
  static const String signupView = '/signupView';
  static const String verifyEmailView = '/verifyEmailView';
  static const String successSignupView = '/successSignupView';
  static const String createPasscodeView = '/createPasscodeView';
  static const String reenterPasscodeView = '/reenterPasscodeView';
  static const String forgotPasswordView = '/forgotPasswordView';
  static const String resetPasswordView = '/resetPasswordView';
  static const String passcodeView = '/passcodeView';
  static const String completePersonalInfoView = '/completePersonalInfoView';
  static const String uploadDocumentsView = '/uploadDocumentsView';
  static const String bvnNinVerificationView = '/bvnNinVerificationView';
  static const String biometricSetupView = '/biometricSetupView';
  static const String mainView = '/mainView';
  static const String recipientsView = '/recipientsView';
  static const String editProfileView = '/editProfileView';
  static const String accountLimitsView = '/accountLimitsView';
  static const String transactionDetailsView = '/transactionDetailsView';
  static const String transactionsView = '/transactionsView';
  static const String cryptoChannelsView = '/cryptoChannelsView';
  static const String cryptoNetworksView = '/cryptoNetworksView';
  static const String addRecipientsView = '/addRecipientsView';
  static const String dayfiTagExplanationView = '/dayfiTagExplanationView';
  static const String createDayfiTagView = '/createDayfiTagView';
  static const String sendDayfiIdView = '/sendDayfiIdView';
  static const String sendDayfiIdReviewView = '/sendDayfiIdReviewView';
  static const String sendRecipientView = '/sendRecipientView';
  static const String sendReviewView = '/sendReviewView';
  static const String regularTransferTransactionPinView = '/regularTransferTransactionPinView';
  static const String sendPaymentSuccessView = '/sendPaymentSuccessView';
  static const String transactionPinCreateView = '/transactionPinCreateView';
  static const String transactionPinReenterView = '/transactionPinReenterView';
  static const String sendPaymentMethodView = '/sendPaymentMethodView';
  static const String changeTransactionPinOldView = '/changeTransactionPinOldView';
  static const String changeTransactionPinNewView = '/changeTransactionPinNewView';
  static const String changeTransactionPinConfirmView = '/changeTransactionPinConfirmView';

  static Route getRoute(RouteSettings routeSettings) {
    globalrouteSettings = routeSettings;
    switch (routeSettings.name) {
      case loginView:
        bool showBackButton = routeSettings.arguments as bool? ?? true;
        return _getPageRoute(
          routeSettings,
          LoginView(showBackButton: showBackButton),
        );
      case splashView:
        return _getPageRoute(routeSettings, const SplashView());
      case onboardingView:
        return _getPageRoute(routeSettings, const OnboardingView());
      case signupView:
        return _getPageRoute(routeSettings, const SignupView());
      case verifyEmailView:
        VerifyEmailViewArguments args =
            routeSettings.arguments as VerifyEmailViewArguments;
        return _getPageRoute(
          routeSettings,
          VerifyEmailView(
            isSignUp: args.isSignUp,
            email: args.email,
            password: args.password,
          ),
        );
      case successSignupView:
        return _getPageRoute(routeSettings, const SuccessSignupView());
      case createPasscodeView:
        bool isFromSignup = routeSettings.arguments as bool? ?? false;
        return _getPageRoute(
          routeSettings,
          CreatePasscodeView(isFromSignup: isFromSignup),
        );
      case reenterPasscodeView:
        bool isFromSignup = routeSettings.arguments as bool? ?? false;
        return _getPageRoute(
          routeSettings,
          ReenterPasscodeView(isFromSignup: isFromSignup),
        );
      case forgotPasswordView:
        return _getPageRoute(routeSettings, const ForgotPasswordView());
      case resetPasswordView:
        String email = routeSettings.arguments as String;
        return _getPageRoute(routeSettings, ResetPasswordView(email: email));
      case passcodeView:
        return _getPageRoute(routeSettings, const PasscodeView());
      case completePersonalInfoView:
        return _getPageRoute(
          routeSettings,
          const CompletePersonalInformationView(),
        );
      case uploadDocumentsView:
        // Check if arguments contain showBackButton parameter
        final showBackButton =
            routeSettings.arguments is Map<String, dynamic>
                ? (routeSettings.arguments
                            as Map<String, dynamic>)['showBackButton']
                        as bool? ??
                    false
                : false;
        return _getPageRoute(
          routeSettings,
          UploadDocumentsView(showBackButton: showBackButton),
        );
      case bvnNinVerificationView:
        return _getPageRoute(
          routeSettings,
          const BvnNinVerificationView(),
        );
      case biometricSetupView:
        return _getPageRoute(routeSettings, const BiometricSetupView());
      case mainView:
        int initialTabIndex = routeSettings.arguments as int? ?? 0;
        return _getPageRoute(
          routeSettings,
          MainView(key: mainViewKey, initialTabIndex: initialTabIndex),
        );

      case recipientsView:
        return _getPageRoute(routeSettings, const RecipientsView());
      case editProfileView:
        return _getPageRoute(routeSettings, const EditProfileView());

      case accountLimitsView:
        return _getPageRoute(routeSettings, const AccountLimitsView());
      case transactionDetailsView:
        WalletTransaction transaction =
            routeSettings.arguments as WalletTransaction;
        return _getPageRoute(
          routeSettings,
          TransactionDetailsView(transaction: transaction),
        );
      case transactionsView:
        return _getPageRoute(routeSettings, const TransactionsView());
      case cryptoChannelsView:
        return _getPageRoute(
          routeSettings,
          const SendFetchCryptoChannelsView(),
        );
      case cryptoNetworksView:
        Map<String, dynamic> channel =
            routeSettings.arguments as Map<String, dynamic>;
        return _getPageRoute(
          routeSettings,
          SendCryptoNetworksView(selectedChannel: channel),
        );
      case addRecipientsView:
        final selectedData =
            routeSettings.arguments as Map<String, dynamic>? ?? {};
        return _getPageRoute(
          routeSettings,
          SendAddRecipientsView(selectedData: selectedData),
        );
      case dayfiTagExplanationView:
        return _getPageRoute(
          routeSettings,
          const DayfiTagExplanationView(),
        );
      case createDayfiTagView:
        return _getPageRoute(
          routeSettings,
          const CreateDayfiTagView(),
        );
      case sendDayfiIdView:
        final selectedData =
            routeSettings.arguments as Map<String, dynamic>? ?? {};
        return _getPageRoute(
          routeSettings,
          SendDayfiIdView(selectedData: selectedData),
        );
      case transactionPinCreateView:
        final args = routeSettings.arguments as Map<String, dynamic>? ?? {};
        return _getPageRoute(
          routeSettings,
          TransactionPinCreateView(
            returnRoute: args['returnRoute'] as String?,
            returnArguments: args['returnArguments'] as Map<String, dynamic>?,
          ),
        );
      case transactionPinReenterView:
        return _getPageRoute(
          routeSettings,
          const TransactionPinReenterView(),
        );
      case sendPaymentMethodView:
        final args = routeSettings.arguments as Map<String, dynamic>? ?? {};
        return _getPageRoute(
          routeSettings,
          SendPaymentMethodView(
            selectedData: args['selectedData'] as Map<String, dynamic>? ?? {},
            recipientData: args['recipientData'] as Map<String, dynamic>? ?? {},
            senderData: args['senderData'] as Map<String, dynamic>? ?? {},
            paymentData: args['paymentData'] as Map<String, dynamic>? ?? {},
          ),
        );
      case sendDayfiIdReviewView:
        final args = routeSettings.arguments as Map<String, dynamic>? ?? {};
        return _getPageRoute(
          routeSettings,
          SendDayfiIdReviewView(
            selectedData: args['selectedData'] as Map<String, dynamic>? ?? {},
            dayfiId: args['dayfiId'] as String? ?? '',
          ),
        );
      case sendRecipientView:
        final selectedData =
            routeSettings.arguments as Map<String, dynamic>? ?? {};
        return _getPageRoute(
          routeSettings,
          SendRecipientView(selectedData: selectedData),
        );
      case sendReviewView:
        final args = routeSettings.arguments as Map<String, dynamic>? ?? {};
        return _getPageRoute(
          routeSettings,
          SendReviewView(
            selectedData: args['selectedData'] as Map<String, dynamic>? ?? {},
            recipientData: args['recipientData'] as Map<String, dynamic>? ?? {},
            senderData: args['senderData'] as Map<String, dynamic>? ?? {},
          ),
        );
      case regularTransferTransactionPinView:
        final args = routeSettings.arguments as Map<String, dynamic>? ?? {};
        return _getPageRoute(
          routeSettings,
          RegularTransferTransactionPinView(
            selectedData: args['selectedData'] as Map<String, dynamic>? ?? {},
            recipientData: args['recipientData'] as Map<String, dynamic>? ?? {},
            senderData: args['senderData'] as Map<String, dynamic>? ?? {},
            paymentData: args['paymentData'] as Map<String, dynamic>? ?? {},
            reason: args['reason'] as String? ?? '',
            description: args['description'] as String? ?? '',
          ),
        );
      case sendPaymentSuccessView:
        final args = routeSettings.arguments as Map<String, dynamic>? ?? {};
        return _getPageRoute(
          routeSettings,
          SendPaymentSuccessView(
            recipientData: args['recipientData'] as Map<String, dynamic>? ?? {},
            selectedData: args['selectedData'] as Map<String, dynamic>? ?? {},
            paymentData: args['paymentData'] as Map<String, dynamic>? ?? {},
            collectionData: args['collectionData'],
            transactionId: args['transactionId'] as String?,
          ),
        );
      case changeTransactionPinOldView:
        return _getPageRoute(
          routeSettings,
          const ChangeTransactionPinOldView(),
        );
      case changeTransactionPinNewView:
        return _getPageRoute(
          routeSettings,
          const ChangeTransactionPinNewView(),
        );
      case changeTransactionPinConfirmView:
        return _getPageRoute(
          routeSettings,
          const ChangeTransactionPinConfirmView(),
        );

      default:
        return _getPageRoute(routeSettings, const LoginView());
    }
  }

  static Route _getPageRoute(
    RouteSettings routeSettings,
    Widget screen, {
    bool isFullScreen = false,
  }) {
    if (Platform.isIOS) {
      return CupertinoPageRoute(
        settings: routeSettings,
        builder: (context) {
          return screen;
        },
        fullscreenDialog: isFullScreen,
      );
    }
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (context) {
        return screen;
      },
      fullscreenDialog: isFullScreen,
    );
  }
}
