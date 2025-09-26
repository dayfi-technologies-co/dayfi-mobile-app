// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedNavigatorGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i57;

import 'package:dayfi/data/models/transaction_history_model.dart' as _i58;
import 'package:dayfi/data/models/wallet_reponse.dart' as _i56;
import 'package:dayfi/ui/views/add_funds/add_funds_view.dart' as _i26;
import 'package:dayfi/ui/views/add_funds_options/add_funds_options_view.dart'
    as _i27;
import 'package:dayfi/ui/views/amount_entry/amount_entry_view.dart' as _i41;
import 'package:dayfi/ui/views/blog/blog_view.dart' as _i47;
import 'package:dayfi/ui/views/blog/blog_viewmodel.dart' as _i59;
import 'package:dayfi/ui/views/blog_detail/blog_detail_view.dart' as _i48;
import 'package:dayfi/ui/views/cards/cards_view.dart' as _i36;
import 'package:dayfi/ui/views/coin_detail/coin_detail_view.dart' as _i21;
import 'package:dayfi/ui/views/coins/coins_view.dart' as _i17;
import 'package:dayfi/ui/views/create_passcode/create_passcode_view.dart'
    as _i31;
import 'package:dayfi/ui/views/digital_dollar/digital_dollar_view.dart' as _i51;
import 'package:dayfi/ui/views/faqs/faqs_view.dart' as _i49;
import 'package:dayfi/ui/views/forgot_password/forgot_password_view.dart'
    as _i7;
import 'package:dayfi/ui/views/home/home_view.dart' as _i2;
import 'package:dayfi/ui/views/kyc_levels/kyc_levels_view.dart' as _i23;
import 'package:dayfi/ui/views/kyc_success/kyc_success_view.dart' as _i35;
import 'package:dayfi/ui/views/level_one_part_a/level_one_part_a_view.dart'
    as _i19;
import 'package:dayfi/ui/views/level_one_part_b/level_one_part_b_view.dart'
    as _i20;
import 'package:dayfi/ui/views/link_a_bank/link_a_bank_view.dart' as _i34;
import 'package:dayfi/ui/views/linked_banks/linked_banks_view.dart' as _i33;
import 'package:dayfi/ui/views/login/login_view.dart' as _i6;
import 'package:dayfi/ui/views/main/main_view.dart' as _i11;
import 'package:dayfi/ui/views/main/main_viewmodel.dart' as _i55;
import 'package:dayfi/ui/views/passcode/passcode_view.dart' as _i30;
import 'package:dayfi/ui/views/password_change/password_change_view.dart'
    as _i16;
import 'package:dayfi/ui/views/payment_setup/payment_setup_view.dart' as _i25;
import 'package:dayfi/ui/views/personalise_card/personalise_card_view.dart'
    as _i38;
import 'package:dayfi/ui/views/prepaid_info/prepaid_info_view.dart' as _i37;
import 'package:dayfi/ui/views/profile/profile_view.dart' as _i13;
import 'package:dayfi/ui/views/recipient_details/recipient_details_view.dart'
    as _i40;
import 'package:dayfi/ui/views/reenter_passcode/reenter_passcode_view.dart'
    as _i32;
import 'package:dayfi/ui/views/reset_password/reset_password_view.dart' as _i9;
import 'package:dayfi/ui/views/send_funds/send_funds_view.dart' as _i28;
import 'package:dayfi/ui/views/send_funds_options/send_funds_options_view.dart'
    as _i29;
import 'package:dayfi/ui/views/settings/settings_view.dart' as _i12;
import 'package:dayfi/ui/views/signup/signup_view.dart' as _i5;
import 'package:dayfi/ui/views/splash/splash_view.dart' as _i3;
import 'package:dayfi/ui/views/startup/startup_view.dart' as _i4;
import 'package:dayfi/ui/views/success/success_view.dart' as _i10;
import 'package:dayfi/ui/views/swap/swap_view.dart' as _i24;
import 'package:dayfi/ui/views/tranfers_details_selection/tranfers_details_selection_view.dart'
    as _i39;
import 'package:dayfi/ui/views/transaction_details/transaction_details_view.dart'
    as _i45;
import 'package:dayfi/ui/views/transaction_history/transaction_history_view.dart'
    as _i50;
import 'package:dayfi/ui/views/transaction_pin_change/transaction_pin_change_view.dart'
    as _i15;
import 'package:dayfi/ui/views/transaction_pin_confirm/transaction_pin_confirm_view.dart'
    as _i43;
import 'package:dayfi/ui/views/transaction_pin_new/transaction_pin_new_view.dart'
    as _i42;
import 'package:dayfi/ui/views/transaction_pin_set/transaction_pin_set_view.dart'
    as _i14;
import 'package:dayfi/ui/views/verify_email/verify_email_view.dart' as _i8;
import 'package:dayfi/ui/views/verify_phone/verify_phone_view.dart' as _i18;
import 'package:dayfi/ui/views/virtual_card_details/virtual_card_details_view.dart'
    as _i53;
import 'package:dayfi/ui/views/wallet/wallet_view.dart' as _i46;
import 'package:dayfi/ui/views/wallet_address_info/wallet_address_info_view.dart'
    as _i52;
import 'package:dayfi/ui/views/wallet_details/wallet_details_view.dart' as _i44;
import 'package:dayfi/ui/views/wallets/wallets_view.dart' as _i22;
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as _i54;
import 'package:stacked/stacked.dart' as _i1;
import 'package:stacked_services/stacked_services.dart' as _i60;

class Routes {
  static const homeView = '/home-view';

  static const splashView = '/splash-view';

  static const startupView = '/startup-view';

  static const signupView = '/signup-view';

  static const loginView = '/login-view';

  static const forgotPasswordView = '/forgot-password-view';

  static const verifyEmailView = '/verify-email-view';

  static const resetPasswordView = '/reset-password-view';

  static const successView = '/success-view';

  static const mainView = '/main-view';

  static const settingsView = '/settings-view';

  static const profileView = '/profile-view';

  static const transactionPinSetView = '/transaction-pin-set-view';

  static const transactionPinChangeView = '/transaction-pin-change-view';

  static const passwordChangeView = '/password-change-view';

  static const coinsView = '/coins-view';

  static const verifyPhoneView = '/verify-phone-view';

  static const levelOnePartAView = '/level-one-part-aView';

  static const levelOnePartBView = '/level-one-part-bView';

  static const coinDetailView = '/coin-detail-view';

  static const walletsView = '/wallets-view';

  static const kycLevelsView = '/kyc-levels-view';

  static const swapView = '/swap-view';

  static const paymentSetupView = '/payment-setup-view';

  static const addFundsView = '/add-funds-view';

  static const addFundsOptionsView = '/add-funds-options-view';

  static const sendFundsView = '/send-funds-view';

  static const sendFundsOptionsView = '/send-funds-options-view';

  static const passcodeView = '/passcode-view';

  static const createPasscodeView = '/create-passcode-view';

  static const reenterPasscodeView = '/reenter-passcode-view';

  static const linkedBanksView = '/linked-banks-view';

  static const linkABankView = '/link-abank-view';

  static const kycSuccessView = '/kyc-success-view';

  static const cardsView = '/cards-view';

  static const prepaidInfoView = '/prepaid-info-view';

  static const personaliseCardView = '/personalise-card-view';

  static const transfersDetailsSelectionView =
      '/transfers-details-selection-view';

  static const recipientDetailsView = '/recipient-details-view';

  static const amountEntryView = '/amount-entry-view';

  static const transactionPinNewView = '/transaction-pin-new-view';

  static const transactionPinConfirmView = '/transaction-pin-confirm-view';

  static const walletDetailsView = '/wallet-details-view';

  static const transactionDetailsView = '/transaction-details-view';

  static const walletView = '/wallet-view';

  static const blogView = '/blog-view';

  static const blogDetailView = '/blog-detail-view';

  static const faqsView = '/faqs-view';

  static const transactionHistoryView = '/transaction-history-view';

  static const digitalDollarView = '/digital-dollar-view';

  static const walletAddressInfoView = '/wallet-address-info-view';

  static const virtualCardDetailsView = '/virtual-card-details-view';

  static const all = <String>{
    homeView,
    splashView,
    startupView,
    signupView,
    loginView,
    forgotPasswordView,
    verifyEmailView,
    resetPasswordView,
    successView,
    mainView,
    settingsView,
    profileView,
    transactionPinSetView,
    transactionPinChangeView,
    passwordChangeView,
    coinsView,
    verifyPhoneView,
    levelOnePartAView,
    levelOnePartBView,
    coinDetailView,
    walletsView,
    kycLevelsView,
    swapView,
    paymentSetupView,
    addFundsView,
    addFundsOptionsView,
    sendFundsView,
    sendFundsOptionsView,
    passcodeView,
    createPasscodeView,
    reenterPasscodeView,
    linkedBanksView,
    linkABankView,
    kycSuccessView,
    cardsView,
    prepaidInfoView,
    personaliseCardView,
    transfersDetailsSelectionView,
    recipientDetailsView,
    amountEntryView,
    transactionPinNewView,
    transactionPinConfirmView,
    walletDetailsView,
    transactionDetailsView,
    walletView,
    blogView,
    blogDetailView,
    faqsView,
    transactionHistoryView,
    digitalDollarView,
    walletAddressInfoView,
    virtualCardDetailsView,
  };
}

class StackedRouter extends _i1.RouterBase {
  final _routes = <_i1.RouteDef>[
    _i1.RouteDef(Routes.homeView, page: _i2.HomeView),
    _i1.RouteDef(Routes.splashView, page: _i3.SplashView),
    _i1.RouteDef(Routes.startupView, page: _i4.StartupView),
    _i1.RouteDef(Routes.signupView, page: _i5.SignupView),
    _i1.RouteDef(Routes.loginView, page: _i6.LoginView),
    _i1.RouteDef(Routes.forgotPasswordView, page: _i7.ForgotPasswordView),
    _i1.RouteDef(Routes.verifyEmailView, page: _i8.VerifyEmailView),
    _i1.RouteDef(Routes.resetPasswordView, page: _i9.ResetPasswordView),
    _i1.RouteDef(Routes.successView, page: _i10.SuccessView),
    _i1.RouteDef(Routes.mainView, page: _i11.MainView),
    _i1.RouteDef(Routes.settingsView, page: _i12.SettingsView),
    _i1.RouteDef(Routes.profileView, page: _i13.ProfileView),
    _i1.RouteDef(
      Routes.transactionPinSetView,
      page: _i14.TransactionPinSetView,
    ),
    _i1.RouteDef(
      Routes.transactionPinChangeView,
      page: _i15.TransactionPinChangeView,
    ),
    _i1.RouteDef(Routes.passwordChangeView, page: _i16.PasswordChangeView),
    _i1.RouteDef(Routes.coinsView, page: _i17.CoinsView),
    _i1.RouteDef(Routes.verifyPhoneView, page: _i18.VerifyPhoneView),
    _i1.RouteDef(Routes.levelOnePartAView, page: _i19.LevelOnePartAView),
    _i1.RouteDef(Routes.levelOnePartBView, page: _i20.LevelOnePartBView),
    _i1.RouteDef(Routes.coinDetailView, page: _i21.CoinDetailView),
    _i1.RouteDef(Routes.walletsView, page: _i22.WalletsView),
    _i1.RouteDef(Routes.kycLevelsView, page: _i23.KycLevelsView),
    _i1.RouteDef(Routes.swapView, page: _i24.SwapView),
    _i1.RouteDef(Routes.paymentSetupView, page: _i25.PaymentSetupView),
    _i1.RouteDef(Routes.addFundsView, page: _i26.AddFundsView),
    _i1.RouteDef(Routes.addFundsOptionsView, page: _i27.AddFundsOptionsView),
    _i1.RouteDef(Routes.sendFundsView, page: _i28.SendFundsView),
    _i1.RouteDef(Routes.sendFundsOptionsView, page: _i29.SendFundsOptionsView),
    _i1.RouteDef(Routes.passcodeView, page: _i30.PasscodeView),
    _i1.RouteDef(Routes.createPasscodeView, page: _i31.CreatePasscodeView),
    _i1.RouteDef(Routes.reenterPasscodeView, page: _i32.ReenterPasscodeView),
    _i1.RouteDef(Routes.linkedBanksView, page: _i33.LinkedBanksView),
    _i1.RouteDef(Routes.linkABankView, page: _i34.LinkABankView),
    _i1.RouteDef(Routes.kycSuccessView, page: _i35.KycSuccessView),
    _i1.RouteDef(Routes.cardsView, page: _i36.CardsView),
    _i1.RouteDef(Routes.prepaidInfoView, page: _i37.PrepaidInfoView),
    _i1.RouteDef(Routes.personaliseCardView, page: _i38.PersonaliseCardView),
    _i1.RouteDef(
      Routes.transfersDetailsSelectionView,
      page: _i39.TransfersDetailsSelectionView,
    ),
    _i1.RouteDef(Routes.recipientDetailsView, page: _i40.RecipientDetailsView),
    _i1.RouteDef(Routes.amountEntryView, page: _i41.AmountEntryView),
    _i1.RouteDef(
      Routes.transactionPinNewView,
      page: _i42.TransactionPinNewView,
    ),
    _i1.RouteDef(
      Routes.transactionPinConfirmView,
      page: _i43.TransactionPinConfirmView,
    ),
    _i1.RouteDef(Routes.walletDetailsView, page: _i44.WalletDetailsView),
    _i1.RouteDef(
      Routes.transactionDetailsView,
      page: _i45.TransactionDetailsView,
    ),
    _i1.RouteDef(Routes.walletView, page: _i46.WalletView),
    _i1.RouteDef(Routes.blogView, page: _i47.BlogView),
    _i1.RouteDef(Routes.blogDetailView, page: _i48.BlogDetailView),
    _i1.RouteDef(Routes.faqsView, page: _i49.FaqsView),
    _i1.RouteDef(
      Routes.transactionHistoryView,
      page: _i50.TransactionHistoryView,
    ),
    _i1.RouteDef(Routes.digitalDollarView, page: _i51.DigitalDollarView),
    _i1.RouteDef(
      Routes.walletAddressInfoView,
      page: _i52.WalletAddressInfoView,
    ),
    _i1.RouteDef(
      Routes.virtualCardDetailsView,
      page: _i53.VirtualCardDetailsView,
    ),
  ];

  final _pagesMap = <Type, _i1.StackedRouteFactory>{
    _i2.HomeView: (data) {
      final args = data.getArgs<HomeViewArguments>(nullOk: false);
      return _i54.MaterialPageRoute<dynamic>(
        builder:
            (context) => _i2.HomeView(key: args.key, mainModel: args.mainModel),
        settings: data,
      );
    },
    _i3.SplashView: (data) {
      final args = data.getArgs<SplashViewArguments>(
        orElse: () => const SplashViewArguments(),
      );
      return _i54.MaterialPageRoute<dynamic>(
        builder: (context) => _i3.SplashView(key: args.key),
        settings: data,
      );
    },
    _i4.StartupView: (data) {
      final args = data.getArgs<StartupViewArguments>(
        orElse: () => const StartupViewArguments(),
      );
      return _i54.MaterialPageRoute<dynamic>(
        builder: (context) => _i4.StartupView(key: args.key),
        settings: data,
      );
    },
    _i5.SignupView: (data) {
      final args = data.getArgs<SignupViewArguments>(
        orElse: () => const SignupViewArguments(),
      );
      return _i54.MaterialPageRoute<dynamic>(
        builder: (context) => _i5.SignupView(key: args.key),
        settings: data,
      );
    },
    _i6.LoginView: (data) {
      final args = data.getArgs<LoginViewArguments>(
        orElse: () => const LoginViewArguments(),
      );
      return _i54.MaterialPageRoute<dynamic>(
        builder: (context) => _i6.LoginView(key: args.key),
        settings: data,
      );
    },
    _i7.ForgotPasswordView: (data) {
      final args = data.getArgs<ForgotPasswordViewArguments>(
        orElse: () => const ForgotPasswordViewArguments(),
      );
      return _i54.MaterialPageRoute<dynamic>(
        builder: (context) => _i7.ForgotPasswordView(key: args.key),
        settings: data,
      );
    },
    _i8.VerifyEmailView: (data) {
      final args = data.getArgs<VerifyEmailViewArguments>(nullOk: false);
      return _i54.MaterialPageRoute<dynamic>(
        builder:
            (context) => _i8.VerifyEmailView(
              key: args.key,
              isSignUp: args.isSignUp,
              email: args.email,
              password: args.password,
            ),
        settings: data,
      );
    },
    _i9.ResetPasswordView: (data) {
      final args = data.getArgs<ResetPasswordViewArguments>(nullOk: false);
      return _i54.MaterialPageRoute<dynamic>(
        builder:
            (context) =>
                _i9.ResetPasswordView(key: args.key, email: args.email),
        settings: data,
      );
    },
    _i10.SuccessView: (data) {
      final args = data.getArgs<SuccessViewArguments>(
        orElse: () => const SuccessViewArguments(),
      );
      return _i54.MaterialPageRoute<dynamic>(
        builder: (context) => _i10.SuccessView(key: args.key),
        settings: data,
      );
    },
    _i11.MainView: (data) {
      final args = data.getArgs<MainViewArguments>(
        orElse: () => const MainViewArguments(),
      );
      return _i54.MaterialPageRoute<dynamic>(
        builder: (context) => _i11.MainView(key: args.key, index: args.index),
        settings: data,
      );
    },
    _i12.SettingsView: (data) {
      final args = data.getArgs<SettingsViewArguments>(nullOk: false);
      return _i54.MaterialPageRoute<dynamic>(
        builder:
            (context) =>
                _i12.SettingsView(key: args.key, mainModel: args.mainModel),
        settings: data,
      );
    },
    _i13.ProfileView: (data) {
      final args = data.getArgs<ProfileViewArguments>(
        orElse: () => const ProfileViewArguments(),
      );
      return _i54.MaterialPageRoute<dynamic>(
        builder: (context) => _i13.ProfileView(key: args.key),
        settings: data,
      );
    },
    _i14.TransactionPinSetView: (data) {
      final args = data.getArgs<TransactionPinSetViewArguments>(
        orElse: () => const TransactionPinSetViewArguments(),
      );
      return _i54.MaterialPageRoute<dynamic>(
        builder: (context) => _i14.TransactionPinSetView(key: args.key),
        settings: data,
      );
    },
    _i15.TransactionPinChangeView: (data) {
      final args = data.getArgs<TransactionPinChangeViewArguments>(
        orElse: () => const TransactionPinChangeViewArguments(),
      );
      return _i54.MaterialPageRoute<dynamic>(
        builder: (context) => _i15.TransactionPinChangeView(key: args.key),
        settings: data,
      );
    },
    _i16.PasswordChangeView: (data) {
      final args = data.getArgs<PasswordChangeViewArguments>(
        orElse: () => const PasswordChangeViewArguments(),
      );
      return _i54.MaterialPageRoute<dynamic>(
        builder: (context) => _i16.PasswordChangeView(key: args.key),
        settings: data,
      );
    },
    _i17.CoinsView: (data) {
      final args = data.getArgs<CoinsViewArguments>(
        orElse: () => const CoinsViewArguments(),
      );
      return _i54.MaterialPageRoute<dynamic>(
        builder: (context) => _i17.CoinsView(key: args.key),
        settings: data,
      );
    },
    _i18.VerifyPhoneView: (data) {
      final args = data.getArgs<VerifyPhoneViewArguments>(nullOk: false);
      return _i54.MaterialPageRoute<dynamic>(
        builder:
            (context) => _i18.VerifyPhoneView(
              key: args.key,
              phoneNumber: args.phoneNumber,
              country: args.country,
              state: args.state,
              street: args.street,
              city: args.city,
              postalCode: args.postalCode,
              address: args.address,
              gender: args.gender,
              dob: args.dob,
            ),
        settings: data,
      );
    },
    _i19.LevelOnePartAView: (data) {
      final args = data.getArgs<LevelOnePartAViewArguments>(
        orElse: () => const LevelOnePartAViewArguments(),
      );
      return _i54.MaterialPageRoute<dynamic>(
        builder: (context) => _i19.LevelOnePartAView(key: args.key),
        settings: data,
      );
    },
    _i20.LevelOnePartBView: (data) {
      final args = data.getArgs<LevelOnePartBViewArguments>(nullOk: false);
      return _i54.MaterialPageRoute<dynamic>(
        builder:
            (context) => _i20.LevelOnePartBView(
              key: args.key,
              country: args.country,
              state: args.state,
              street: args.street,
              city: args.city,
              postalCode: args.postalCode,
              address: args.address,
            ),
        settings: data,
      );
    },
    _i21.CoinDetailView: (data) {
      final args = data.getArgs<CoinDetailViewArguments>(nullOk: false);
      return _i54.MaterialPageRoute<dynamic>(
        builder:
            (context) => _i21.CoinDetailView(
              key: args.key,
              coinId: args.coinId,
              coinName: args.coinName,
              coinPrice: args.coinPrice,
              priceChange: args.priceChange,
              marketCap: args.marketCap,
              popularity: args.popularity,
            ),
        settings: data,
      );
    },
    _i22.WalletsView: (data) {
      final args = data.getArgs<WalletsViewArguments>(nullOk: false);
      return _i54.MaterialPageRoute<dynamic>(
        builder:
            (context) =>
                _i22.WalletsView(key: args.key, mainModel: args.mainModel),
        settings: data,
      );
    },
    _i23.KycLevelsView: (data) {
      final args = data.getArgs<KycLevelsViewArguments>(
        orElse: () => const KycLevelsViewArguments(),
      );
      return _i54.MaterialPageRoute<dynamic>(
        builder: (context) => _i23.KycLevelsView(key: args.key),
        settings: data,
      );
    },
    _i24.SwapView: (data) {
      final args = data.getArgs<SwapViewArguments>(nullOk: false);
      return _i54.MaterialPageRoute<dynamic>(
        builder:
            (context) => _i24.SwapView(key: args.key, wallets: args.wallets),
        settings: data,
      );
    },
    _i25.PaymentSetupView: (data) {
      final args = data.getArgs<PaymentSetupViewArguments>(nullOk: false);
      return _i54.MaterialPageRoute<dynamic>(
        builder:
            (context) => _i25.PaymentSetupView(
              key: args.key,
              readCard: args.readCard,
              selectedPaymentMethod: args.selectedPaymentMethod,
              amount: args.amount,
              isReceive: args.isReceive,
            ),
        settings: data,
      );
    },
    _i26.AddFundsView: (data) {
      final args = data.getArgs<AddFundsViewArguments>(nullOk: false);
      return _i54.MaterialPageRoute<dynamic>(
        builder:
            (context) => _i26.AddFundsView(
              key: args.key,
              currency: args.currency,
              userIcon: args.userIcon,
              name: args.name,
              username: args.username,
              addFundType: args.addFundType,
              openNFCbottomSheet: args.openNFCbottomSheet,
            ),
        settings: data,
      );
    },
    _i27.AddFundsOptionsView: (data) {
      final args = data.getArgs<AddFundsOptionsViewArguments>(
        orElse: () => const AddFundsOptionsViewArguments(),
      );
      return _i54.MaterialPageRoute<dynamic>(
        builder: (context) => _i27.AddFundsOptionsView(key: args.key),
        settings: data,
      );
    },
    _i28.SendFundsView: (data) {
      final args = data.getArgs<SendFundsViewArguments>(nullOk: false);
      return _i54.MaterialPageRoute<dynamic>(
        builder:
            (context) => _i28.SendFundsView(
              key: args.key,
              currency: args.currency,
              userIcon: args.userIcon,
              name: args.name,
              username: args.username,
              sendFundType: args.sendFundType,
            ),
        settings: data,
      );
    },
    _i29.SendFundsOptionsView: (data) {
      final args = data.getArgs<SendFundsOptionsViewArguments>(
        orElse: () => const SendFundsOptionsViewArguments(),
      );
      return _i54.MaterialPageRoute<dynamic>(
        builder: (context) => _i29.SendFundsOptionsView(key: args.key),
        settings: data,
      );
    },
    _i30.PasscodeView: (data) {
      final args = data.getArgs<PasscodeViewArguments>(
        orElse: () => const PasscodeViewArguments(),
      );
      return _i54.MaterialPageRoute<dynamic>(
        builder: (context) => _i30.PasscodeView(key: args.key),
        settings: data,
      );
    },
    _i31.CreatePasscodeView: (data) {
      final args = data.getArgs<CreatePasscodeViewArguments>(
        orElse: () => const CreatePasscodeViewArguments(),
      );
      return _i54.MaterialPageRoute<dynamic>(
        builder: (context) => _i31.CreatePasscodeView(key: args.key),
        settings: data,
      );
    },
    _i32.ReenterPasscodeView: (data) {
      final args = data.getArgs<ReenterPasscodeViewArguments>(
        orElse: () => const ReenterPasscodeViewArguments(),
      );
      return _i54.MaterialPageRoute<dynamic>(
        builder: (context) => _i32.ReenterPasscodeView(key: args.key),
        settings: data,
      );
    },
    _i33.LinkedBanksView: (data) {
      final args = data.getArgs<LinkedBanksViewArguments>(
        orElse: () => const LinkedBanksViewArguments(),
      );
      return _i54.MaterialPageRoute<dynamic>(
        builder: (context) => _i33.LinkedBanksView(key: args.key),
        settings: data,
      );
    },
    _i34.LinkABankView: (data) {
      final args = data.getArgs<LinkABankViewArguments>(
        orElse: () => const LinkABankViewArguments(),
      );
      return _i54.MaterialPageRoute<dynamic>(
        builder: (context) => _i34.LinkABankView(key: args.key),
        settings: data,
      );
    },
    _i35.KycSuccessView: (data) {
      final args = data.getArgs<KycSuccessViewArguments>(
        orElse: () => const KycSuccessViewArguments(),
      );
      return _i54.MaterialPageRoute<dynamic>(
        builder: (context) => _i35.KycSuccessView(key: args.key),
        settings: data,
      );
    },
    _i36.CardsView: (data) {
      final args = data.getArgs<CardsViewArguments>(
        orElse: () => const CardsViewArguments(),
      );
      return _i54.MaterialPageRoute<dynamic>(
        builder: (context) => _i36.CardsView(key: args.key),
        settings: data,
      );
    },
    _i37.PrepaidInfoView: (data) {
      final args = data.getArgs<PrepaidInfoViewArguments>(
        orElse: () => const PrepaidInfoViewArguments(),
      );
      return _i54.MaterialPageRoute<dynamic>(
        builder:
            (context) =>
                _i37.PrepaidInfoView(key: args.key, isVCard: args.isVCard),
        settings: data,
      );
    },
    _i38.PersonaliseCardView: (data) {
      final args = data.getArgs<PersonaliseCardViewArguments>(
        orElse: () => const PersonaliseCardViewArguments(),
      );
      return _i54.MaterialPageRoute<dynamic>(
        builder: (context) => _i38.PersonaliseCardView(key: args.key),
        settings: data,
      );
    },
    _i39.TransfersDetailsSelectionView: (data) {
      final args = data.getArgs<TransfersDetailsSelectionViewArguments>(
        nullOk: false,
      );
      return _i54.MaterialPageRoute<dynamic>(
        builder:
            (context) => _i39.TransfersDetailsSelectionView(
              key: args.key,
              dayfiId: args.dayfiId,
              wallet: args.wallet,
            ),
        settings: data,
      );
    },
    _i40.RecipientDetailsView: (data) {
      final args = data.getArgs<RecipientDetailsViewArguments>(
        orElse: () => const RecipientDetailsViewArguments(),
      );
      return _i54.MaterialPageRoute<dynamic>(
        builder: (context) => _i40.RecipientDetailsView(key: args.key),
        settings: data,
      );
    },
    _i41.AmountEntryView: (data) {
      final args = data.getArgs<AmountEntryViewArguments>(nullOk: false);
      return _i54.MaterialPageRoute<dynamic>(
        builder:
            (context) => _i41.AmountEntryView(
              key: args.key,
              accountNumber: args.accountNumber,
              bankCode: args.bankCode,
              accountName: args.accountName,
              bankName: args.bankName,
              beneficiaryName: args.beneficiaryName,
              wallet: args.wallet,
            ),
        settings: data,
      );
    },
    _i42.TransactionPinNewView: (data) {
      final args = data.getArgs<TransactionPinNewViewArguments>(nullOk: false);
      return _i54.MaterialPageRoute<dynamic>(
        builder:
            (context) => _i42.TransactionPinNewView(args.oldPIN, key: args.key),
        settings: data,
      );
    },
    _i43.TransactionPinConfirmView: (data) {
      final args = data.getArgs<TransactionPinConfirmViewArguments>(
        nullOk: false,
      );
      return _i54.MaterialPageRoute<dynamic>(
        builder:
            (context) =>
                _i43.TransactionPinConfirmView(key: args.key, pin: args.pin),
        settings: data,
      );
    },
    _i44.WalletDetailsView: (data) {
      final args = data.getArgs<WalletDetailsViewArguments>(nullOk: false);
      return _i54.MaterialPageRoute<dynamic>(
        builder:
            (context) =>
                _i44.WalletDetailsView(key: args.key, wallet: args.wallet),
        settings: data,
      );
    },
    _i45.TransactionDetailsView: (data) {
      final args = data.getArgs<TransactionDetailsViewArguments>(nullOk: false);
      return _i54.MaterialPageRoute<dynamic>(
        builder:
            (context) => _i45.TransactionDetailsView(
              args.wallet,
              key: args.key,
              transaction: args.transaction,
            ),
        settings: data,
      );
    },
    _i46.WalletView: (data) {
      final args = data.getArgs<WalletViewArguments>(nullOk: false);
      return _i54.MaterialPageRoute<dynamic>(
        builder:
            (context) => _i46.WalletView(
              args.wallet,
              args.walletTransactions,
              args.wallets,
              key: args.key,
            ),
        settings: data,
      );
    },
    _i47.BlogView: (data) {
      final args = data.getArgs<BlogViewArguments>(
        orElse: () => const BlogViewArguments(),
      );
      return _i54.MaterialPageRoute<dynamic>(
        builder: (context) => _i47.BlogView(key: args.key),
        settings: data,
      );
    },
    _i48.BlogDetailView: (data) {
      final args = data.getArgs<BlogDetailViewArguments>(nullOk: false);
      return _i54.MaterialPageRoute<dynamic>(
        builder:
            (context) => _i48.BlogDetailView(key: args.key, blog: args.blog),
        settings: data,
      );
    },
    _i49.FaqsView: (data) {
      final args = data.getArgs<FaqsViewArguments>(
        orElse: () => const FaqsViewArguments(),
      );
      return _i54.MaterialPageRoute<dynamic>(
        builder: (context) => _i49.FaqsView(key: args.key),
        settings: data,
      );
    },
    _i50.TransactionHistoryView: (data) {
      final args = data.getArgs<TransactionHistoryViewArguments>(
        orElse: () => const TransactionHistoryViewArguments(),
      );
      return _i54.MaterialPageRoute<dynamic>(
        builder: (context) => _i50.TransactionHistoryView(key: args.key),
        settings: data,
      );
    },
    _i51.DigitalDollarView: (data) {
      return _i54.MaterialPageRoute<dynamic>(
        builder: (context) => _i51.DigitalDollarView(),
        settings: data,
      );
    },
    _i52.WalletAddressInfoView: (data) {
      final args = data.getArgs<WalletAddressInfoViewArguments>(nullOk: false);
      return _i54.MaterialPageRoute<dynamic>(
        builder:
            (context) => _i52.WalletAddressInfoView(
              address: args.address,
              currency: args.currency,
              network: args.network,
            ),
        settings: data,
      );
    },
    _i53.VirtualCardDetailsView: (data) {
      final args = data.getArgs<VirtualCardDetailsViewArguments>(
        orElse: () => const VirtualCardDetailsViewArguments(),
      );
      return _i54.MaterialPageRoute<dynamic>(
        builder: (context) => _i53.VirtualCardDetailsView(key: args.key),
        settings: data,
      );
    },
  };

  @override
  List<_i1.RouteDef> get routes => _routes;

  @override
  Map<Type, _i1.StackedRouteFactory> get pagesMap => _pagesMap;
}

class HomeViewArguments {
  const HomeViewArguments({this.key, required this.mainModel});

  final _i54.Key? key;

  final _i55.MainViewModel mainModel;

  @override
  String toString() {
    return '{"key": "$key", "mainModel": "$mainModel"}';
  }

  @override
  bool operator ==(covariant HomeViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.mainModel == mainModel;
  }

  @override
  int get hashCode {
    return key.hashCode ^ mainModel.hashCode;
  }
}

class SplashViewArguments {
  const SplashViewArguments({this.key});

  final _i54.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant SplashViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class StartupViewArguments {
  const StartupViewArguments({this.key});

  final _i54.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant StartupViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class SignupViewArguments {
  const SignupViewArguments({this.key});

  final _i54.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant SignupViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class LoginViewArguments {
  const LoginViewArguments({this.key});

  final _i54.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant LoginViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class ForgotPasswordViewArguments {
  const ForgotPasswordViewArguments({this.key});

  final _i54.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant ForgotPasswordViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class VerifyEmailViewArguments {
  const VerifyEmailViewArguments({
    this.key,
    this.isSignUp = false,
    required this.email,
    this.password = "",
  });

  final _i54.Key? key;

  final bool isSignUp;

  final String email;

  final String password;

  @override
  String toString() {
    return '{"key": "$key", "isSignUp": "$isSignUp", "email": "$email", "password": "$password"}';
  }

  @override
  bool operator ==(covariant VerifyEmailViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key &&
        other.isSignUp == isSignUp &&
        other.email == email &&
        other.password == password;
  }

  @override
  int get hashCode {
    return key.hashCode ^
        isSignUp.hashCode ^
        email.hashCode ^
        password.hashCode;
  }
}

class ResetPasswordViewArguments {
  const ResetPasswordViewArguments({this.key, required this.email});

  final _i54.Key? key;

  final String email;

  @override
  String toString() {
    return '{"key": "$key", "email": "$email"}';
  }

  @override
  bool operator ==(covariant ResetPasswordViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.email == email;
  }

  @override
  int get hashCode {
    return key.hashCode ^ email.hashCode;
  }
}

class SuccessViewArguments {
  const SuccessViewArguments({this.key});

  final _i54.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant SuccessViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class MainViewArguments {
  const MainViewArguments({this.key, this.index = 0});

  final _i54.Key? key;

  final int index;

  @override
  String toString() {
    return '{"key": "$key", "index": "$index"}';
  }

  @override
  bool operator ==(covariant MainViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.index == index;
  }

  @override
  int get hashCode {
    return key.hashCode ^ index.hashCode;
  }
}

class SettingsViewArguments {
  const SettingsViewArguments({this.key, required this.mainModel});

  final _i54.Key? key;

  final _i55.MainViewModel mainModel;

  @override
  String toString() {
    return '{"key": "$key", "mainModel": "$mainModel"}';
  }

  @override
  bool operator ==(covariant SettingsViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.mainModel == mainModel;
  }

  @override
  int get hashCode {
    return key.hashCode ^ mainModel.hashCode;
  }
}

class ProfileViewArguments {
  const ProfileViewArguments({this.key});

  final _i54.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant ProfileViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class TransactionPinSetViewArguments {
  const TransactionPinSetViewArguments({this.key});

  final _i54.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant TransactionPinSetViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class TransactionPinChangeViewArguments {
  const TransactionPinChangeViewArguments({this.key});

  final _i54.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant TransactionPinChangeViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class PasswordChangeViewArguments {
  const PasswordChangeViewArguments({this.key});

  final _i54.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant PasswordChangeViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class CoinsViewArguments {
  const CoinsViewArguments({this.key});

  final _i54.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant CoinsViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class VerifyPhoneViewArguments {
  const VerifyPhoneViewArguments({
    this.key,
    required this.phoneNumber,
    required this.country,
    required this.state,
    required this.street,
    required this.city,
    required this.postalCode,
    required this.address,
    required this.gender,
    required this.dob,
  });

  final _i54.Key? key;

  final String phoneNumber;

  final String country;

  final String state;

  final String street;

  final String city;

  final String postalCode;

  final String address;

  final String gender;

  final String dob;

  @override
  String toString() {
    return '{"key": "$key", "phoneNumber": "$phoneNumber", "country": "$country", "state": "$state", "street": "$street", "city": "$city", "postalCode": "$postalCode", "address": "$address", "gender": "$gender", "dob": "$dob"}';
  }

  @override
  bool operator ==(covariant VerifyPhoneViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key &&
        other.phoneNumber == phoneNumber &&
        other.country == country &&
        other.state == state &&
        other.street == street &&
        other.city == city &&
        other.postalCode == postalCode &&
        other.address == address &&
        other.gender == gender &&
        other.dob == dob;
  }

  @override
  int get hashCode {
    return key.hashCode ^
        phoneNumber.hashCode ^
        country.hashCode ^
        state.hashCode ^
        street.hashCode ^
        city.hashCode ^
        postalCode.hashCode ^
        address.hashCode ^
        gender.hashCode ^
        dob.hashCode;
  }
}

class LevelOnePartAViewArguments {
  const LevelOnePartAViewArguments({this.key});

  final _i54.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant LevelOnePartAViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class LevelOnePartBViewArguments {
  const LevelOnePartBViewArguments({
    this.key,
    required this.country,
    required this.state,
    required this.street,
    required this.city,
    required this.postalCode,
    required this.address,
  });

  final _i54.Key? key;

  final String country;

  final String state;

  final String street;

  final String city;

  final String postalCode;

  final String address;

  @override
  String toString() {
    return '{"key": "$key", "country": "$country", "state": "$state", "street": "$street", "city": "$city", "postalCode": "$postalCode", "address": "$address"}';
  }

  @override
  bool operator ==(covariant LevelOnePartBViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key &&
        other.country == country &&
        other.state == state &&
        other.street == street &&
        other.city == city &&
        other.postalCode == postalCode &&
        other.address == address;
  }

  @override
  int get hashCode {
    return key.hashCode ^
        country.hashCode ^
        state.hashCode ^
        street.hashCode ^
        city.hashCode ^
        postalCode.hashCode ^
        address.hashCode;
  }
}

class CoinDetailViewArguments {
  const CoinDetailViewArguments({
    this.key,
    required this.coinId,
    required this.coinName,
    required this.coinPrice,
    required this.priceChange,
    required this.marketCap,
    required this.popularity,
  });

  final _i54.Key? key;

  final String coinId;

  final String coinName;

  final dynamic coinPrice;

  final double priceChange;

  final dynamic marketCap;

  final dynamic popularity;

  @override
  String toString() {
    return '{"key": "$key", "coinId": "$coinId", "coinName": "$coinName", "coinPrice": "$coinPrice", "priceChange": "$priceChange", "marketCap": "$marketCap", "popularity": "$popularity"}';
  }

  @override
  bool operator ==(covariant CoinDetailViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key &&
        other.coinId == coinId &&
        other.coinName == coinName &&
        other.coinPrice == coinPrice &&
        other.priceChange == priceChange &&
        other.marketCap == marketCap &&
        other.popularity == popularity;
  }

  @override
  int get hashCode {
    return key.hashCode ^
        coinId.hashCode ^
        coinName.hashCode ^
        coinPrice.hashCode ^
        priceChange.hashCode ^
        marketCap.hashCode ^
        popularity.hashCode;
  }
}

class WalletsViewArguments {
  const WalletsViewArguments({this.key, required this.mainModel});

  final _i54.Key? key;

  final _i55.MainViewModel mainModel;

  @override
  String toString() {
    return '{"key": "$key", "mainModel": "$mainModel"}';
  }

  @override
  bool operator ==(covariant WalletsViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.mainModel == mainModel;
  }

  @override
  int get hashCode {
    return key.hashCode ^ mainModel.hashCode;
  }
}

class KycLevelsViewArguments {
  const KycLevelsViewArguments({this.key});

  final _i54.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant KycLevelsViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class SwapViewArguments {
  const SwapViewArguments({this.key, required this.wallets});

  final _i54.Key? key;

  final List<_i56.Wallet> wallets;

  @override
  String toString() {
    return '{"key": "$key", "wallets": "$wallets"}';
  }

  @override
  bool operator ==(covariant SwapViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.wallets == wallets;
  }

  @override
  int get hashCode {
    return key.hashCode ^ wallets.hashCode;
  }
}

class PaymentSetupViewArguments {
  const PaymentSetupViewArguments({
    this.key,
    required this.readCard,
    required this.selectedPaymentMethod,
    required this.amount,
    this.isReceive = true,
  });

  final _i54.Key? key;

  final _i57.Future<bool> Function() readCard;

  final String selectedPaymentMethod;

  final _i54.TextEditingController amount;

  final bool isReceive;

  @override
  String toString() {
    return '{"key": "$key", "readCard": "$readCard", "selectedPaymentMethod": "$selectedPaymentMethod", "amount": "$amount", "isReceive": "$isReceive"}';
  }

  @override
  bool operator ==(covariant PaymentSetupViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key &&
        other.readCard == readCard &&
        other.selectedPaymentMethod == selectedPaymentMethod &&
        other.amount == amount &&
        other.isReceive == isReceive;
  }

  @override
  int get hashCode {
    return key.hashCode ^
        readCard.hashCode ^
        selectedPaymentMethod.hashCode ^
        amount.hashCode ^
        isReceive.hashCode;
  }
}

class AddFundsViewArguments {
  const AddFundsViewArguments({
    this.key,
    required this.currency,
    required this.userIcon,
    required this.name,
    required this.username,
    required this.addFundType,
    required this.openNFCbottomSheet,
  });

  final _i54.Key? key;

  final String currency;

  final String userIcon;

  final String name;

  final String username;

  final String addFundType;

  final void Function() openNFCbottomSheet;

  @override
  String toString() {
    return '{"key": "$key", "currency": "$currency", "userIcon": "$userIcon", "name": "$name", "username": "$username", "addFundType": "$addFundType", "openNFCbottomSheet": "$openNFCbottomSheet"}';
  }

  @override
  bool operator ==(covariant AddFundsViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key &&
        other.currency == currency &&
        other.userIcon == userIcon &&
        other.name == name &&
        other.username == username &&
        other.addFundType == addFundType &&
        other.openNFCbottomSheet == openNFCbottomSheet;
  }

  @override
  int get hashCode {
    return key.hashCode ^
        currency.hashCode ^
        userIcon.hashCode ^
        name.hashCode ^
        username.hashCode ^
        addFundType.hashCode ^
        openNFCbottomSheet.hashCode;
  }
}

class AddFundsOptionsViewArguments {
  const AddFundsOptionsViewArguments({this.key});

  final _i54.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant AddFundsOptionsViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class SendFundsViewArguments {
  const SendFundsViewArguments({
    this.key,
    required this.currency,
    required this.userIcon,
    required this.name,
    required this.username,
    required this.sendFundType,
  });

  final _i54.Key? key;

  final String currency;

  final String userIcon;

  final String name;

  final String username;

  final String sendFundType;

  @override
  String toString() {
    return '{"key": "$key", "currency": "$currency", "userIcon": "$userIcon", "name": "$name", "username": "$username", "sendFundType": "$sendFundType"}';
  }

  @override
  bool operator ==(covariant SendFundsViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key &&
        other.currency == currency &&
        other.userIcon == userIcon &&
        other.name == name &&
        other.username == username &&
        other.sendFundType == sendFundType;
  }

  @override
  int get hashCode {
    return key.hashCode ^
        currency.hashCode ^
        userIcon.hashCode ^
        name.hashCode ^
        username.hashCode ^
        sendFundType.hashCode;
  }
}

class SendFundsOptionsViewArguments {
  const SendFundsOptionsViewArguments({this.key});

  final _i54.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant SendFundsOptionsViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class PasscodeViewArguments {
  const PasscodeViewArguments({this.key});

  final _i54.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant PasscodeViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class CreatePasscodeViewArguments {
  const CreatePasscodeViewArguments({this.key});

  final _i54.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant CreatePasscodeViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class ReenterPasscodeViewArguments {
  const ReenterPasscodeViewArguments({this.key});

  final _i54.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant ReenterPasscodeViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class LinkedBanksViewArguments {
  const LinkedBanksViewArguments({this.key});

  final _i54.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant LinkedBanksViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class LinkABankViewArguments {
  const LinkABankViewArguments({this.key});

  final _i54.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant LinkABankViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class KycSuccessViewArguments {
  const KycSuccessViewArguments({this.key});

  final _i54.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant KycSuccessViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class CardsViewArguments {
  const CardsViewArguments({this.key});

  final _i54.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant CardsViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class PrepaidInfoViewArguments {
  const PrepaidInfoViewArguments({this.key, this.isVCard = false});

  final _i54.Key? key;

  final bool isVCard;

  @override
  String toString() {
    return '{"key": "$key", "isVCard": "$isVCard"}';
  }

  @override
  bool operator ==(covariant PrepaidInfoViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.isVCard == isVCard;
  }

  @override
  int get hashCode {
    return key.hashCode ^ isVCard.hashCode;
  }
}

class PersonaliseCardViewArguments {
  const PersonaliseCardViewArguments({this.key});

  final _i54.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant PersonaliseCardViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class TransfersDetailsSelectionViewArguments {
  const TransfersDetailsSelectionViewArguments({
    this.key,
    required this.dayfiId,
    required this.wallet,
  });

  final _i54.Key? key;

  final String dayfiId;

  final _i56.Wallet wallet;

  @override
  String toString() {
    return '{"key": "$key", "dayfiId": "$dayfiId", "wallet": "$wallet"}';
  }

  @override
  bool operator ==(covariant TransfersDetailsSelectionViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key &&
        other.dayfiId == dayfiId &&
        other.wallet == wallet;
  }

  @override
  int get hashCode {
    return key.hashCode ^ dayfiId.hashCode ^ wallet.hashCode;
  }
}

class RecipientDetailsViewArguments {
  const RecipientDetailsViewArguments({this.key});

  final _i54.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant RecipientDetailsViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class AmountEntryViewArguments {
  const AmountEntryViewArguments({
    this.key,
    required this.accountNumber,
    required this.bankCode,
    required this.accountName,
    required this.bankName,
    required this.beneficiaryName,
    required this.wallet,
  });

  final _i54.Key? key;

  final String accountNumber;

  final String bankCode;

  final String accountName;

  final String bankName;

  final String beneficiaryName;

  final _i56.Wallet wallet;

  @override
  String toString() {
    return '{"key": "$key", "accountNumber": "$accountNumber", "bankCode": "$bankCode", "accountName": "$accountName", "bankName": "$bankName", "beneficiaryName": "$beneficiaryName", "wallet": "$wallet"}';
  }

  @override
  bool operator ==(covariant AmountEntryViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key &&
        other.accountNumber == accountNumber &&
        other.bankCode == bankCode &&
        other.accountName == accountName &&
        other.bankName == bankName &&
        other.beneficiaryName == beneficiaryName &&
        other.wallet == wallet;
  }

  @override
  int get hashCode {
    return key.hashCode ^
        accountNumber.hashCode ^
        bankCode.hashCode ^
        accountName.hashCode ^
        bankName.hashCode ^
        beneficiaryName.hashCode ^
        wallet.hashCode;
  }
}

class TransactionPinNewViewArguments {
  const TransactionPinNewViewArguments({required this.oldPIN, this.key});

  final String? oldPIN;

  final _i54.Key? key;

  @override
  String toString() {
    return '{"oldPIN": "$oldPIN", "key": "$key"}';
  }

  @override
  bool operator ==(covariant TransactionPinNewViewArguments other) {
    if (identical(this, other)) return true;
    return other.oldPIN == oldPIN && other.key == key;
  }

  @override
  int get hashCode {
    return oldPIN.hashCode ^ key.hashCode;
  }
}

class TransactionPinConfirmViewArguments {
  const TransactionPinConfirmViewArguments({this.key, required this.pin});

  final _i54.Key? key;

  final String pin;

  @override
  String toString() {
    return '{"key": "$key", "pin": "$pin"}';
  }

  @override
  bool operator ==(covariant TransactionPinConfirmViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.pin == pin;
  }

  @override
  int get hashCode {
    return key.hashCode ^ pin.hashCode;
  }
}

class WalletDetailsViewArguments {
  const WalletDetailsViewArguments({this.key, required this.wallet});

  final _i54.Key? key;

  final _i56.Wallet wallet;

  @override
  String toString() {
    return '{"key": "$key", "wallet": "$wallet"}';
  }

  @override
  bool operator ==(covariant WalletDetailsViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.wallet == wallet;
  }

  @override
  int get hashCode {
    return key.hashCode ^ wallet.hashCode;
  }
}

class TransactionDetailsViewArguments {
  const TransactionDetailsViewArguments({
    required this.wallet,
    this.key,
    required this.transaction,
  });

  final _i56.Wallet wallet;

  final _i54.Key? key;

  final _i58.WalletTransaction transaction;

  @override
  String toString() {
    return '{"wallet": "$wallet", "key": "$key", "transaction": "$transaction"}';
  }

  @override
  bool operator ==(covariant TransactionDetailsViewArguments other) {
    if (identical(this, other)) return true;
    return other.wallet == wallet &&
        other.key == key &&
        other.transaction == transaction;
  }

  @override
  int get hashCode {
    return wallet.hashCode ^ key.hashCode ^ transaction.hashCode;
  }
}

class WalletViewArguments {
  const WalletViewArguments({
    required this.wallet,
    required this.walletTransactions,
    required this.wallets,
    this.key,
  });

  final _i56.Wallet wallet;

  final List<_i58.WalletTransaction> walletTransactions;

  final List<_i56.Wallet> wallets;

  final _i54.Key? key;

  @override
  String toString() {
    return '{"wallet": "$wallet", "walletTransactions": "$walletTransactions", "wallets": "$wallets", "key": "$key"}';
  }

  @override
  bool operator ==(covariant WalletViewArguments other) {
    if (identical(this, other)) return true;
    return other.wallet == wallet &&
        other.walletTransactions == walletTransactions &&
        other.wallets == wallets &&
        other.key == key;
  }

  @override
  int get hashCode {
    return wallet.hashCode ^
        walletTransactions.hashCode ^
        wallets.hashCode ^
        key.hashCode;
  }
}

class BlogViewArguments {
  const BlogViewArguments({this.key});

  final _i54.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant BlogViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class BlogDetailViewArguments {
  const BlogDetailViewArguments({this.key, required this.blog});

  final _i54.Key? key;

  final _i59.Article blog;

  @override
  String toString() {
    return '{"key": "$key", "blog": "$blog"}';
  }

  @override
  bool operator ==(covariant BlogDetailViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.blog == blog;
  }

  @override
  int get hashCode {
    return key.hashCode ^ blog.hashCode;
  }
}

class FaqsViewArguments {
  const FaqsViewArguments({this.key});

  final _i54.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant FaqsViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class TransactionHistoryViewArguments {
  const TransactionHistoryViewArguments({this.key});

  final _i54.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant TransactionHistoryViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class WalletAddressInfoViewArguments {
  const WalletAddressInfoViewArguments({
    required this.address,
    required this.currency,
    required this.network,
  });

  final String address;

  final String currency;

  final String network;

  @override
  String toString() {
    return '{"address": "$address", "currency": "$currency", "network": "$network"}';
  }

  @override
  bool operator ==(covariant WalletAddressInfoViewArguments other) {
    if (identical(this, other)) return true;
    return other.address == address &&
        other.currency == currency &&
        other.network == network;
  }

  @override
  int get hashCode {
    return address.hashCode ^ currency.hashCode ^ network.hashCode;
  }
}

class VirtualCardDetailsViewArguments {
  const VirtualCardDetailsViewArguments({this.key});

  final _i54.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant VirtualCardDetailsViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

extension NavigatorStateExtension on _i60.NavigationService {
  Future<dynamic> navigateToHomeView({
    _i54.Key? key,
    required _i55.MainViewModel mainModel,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.homeView,
      arguments: HomeViewArguments(key: key, mainModel: mainModel),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToSplashView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.splashView,
      arguments: SplashViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToStartupView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.startupView,
      arguments: StartupViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToSignupView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.signupView,
      arguments: SignupViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToLoginView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.loginView,
      arguments: LoginViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToForgotPasswordView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.forgotPasswordView,
      arguments: ForgotPasswordViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToVerifyEmailView({
    _i54.Key? key,
    bool isSignUp = false,
    required String email,
    String password = "",
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.verifyEmailView,
      arguments: VerifyEmailViewArguments(
        key: key,
        isSignUp: isSignUp,
        email: email,
        password: password,
      ),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToResetPasswordView({
    _i54.Key? key,
    required String email,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.resetPasswordView,
      arguments: ResetPasswordViewArguments(key: key, email: email),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToSuccessView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.successView,
      arguments: SuccessViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToMainView({
    _i54.Key? key,
    int index = 0,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.mainView,
      arguments: MainViewArguments(key: key, index: index),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToSettingsView({
    _i54.Key? key,
    required _i55.MainViewModel mainModel,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.settingsView,
      arguments: SettingsViewArguments(key: key, mainModel: mainModel),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToProfileView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.profileView,
      arguments: ProfileViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToTransactionPinSetView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.transactionPinSetView,
      arguments: TransactionPinSetViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToTransactionPinChangeView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.transactionPinChangeView,
      arguments: TransactionPinChangeViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToPasswordChangeView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.passwordChangeView,
      arguments: PasswordChangeViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToCoinsView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.coinsView,
      arguments: CoinsViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToVerifyPhoneView({
    _i54.Key? key,
    required String phoneNumber,
    required String country,
    required String state,
    required String street,
    required String city,
    required String postalCode,
    required String address,
    required String gender,
    required String dob,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.verifyPhoneView,
      arguments: VerifyPhoneViewArguments(
        key: key,
        phoneNumber: phoneNumber,
        country: country,
        state: state,
        street: street,
        city: city,
        postalCode: postalCode,
        address: address,
        gender: gender,
        dob: dob,
      ),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToLevelOnePartAView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.levelOnePartAView,
      arguments: LevelOnePartAViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToLevelOnePartBView({
    _i54.Key? key,
    required String country,
    required String state,
    required String street,
    required String city,
    required String postalCode,
    required String address,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.levelOnePartBView,
      arguments: LevelOnePartBViewArguments(
        key: key,
        country: country,
        state: state,
        street: street,
        city: city,
        postalCode: postalCode,
        address: address,
      ),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToCoinDetailView({
    _i54.Key? key,
    required String coinId,
    required String coinName,
    required dynamic coinPrice,
    required double priceChange,
    required dynamic marketCap,
    required dynamic popularity,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.coinDetailView,
      arguments: CoinDetailViewArguments(
        key: key,
        coinId: coinId,
        coinName: coinName,
        coinPrice: coinPrice,
        priceChange: priceChange,
        marketCap: marketCap,
        popularity: popularity,
      ),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToWalletsView({
    _i54.Key? key,
    required _i55.MainViewModel mainModel,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.walletsView,
      arguments: WalletsViewArguments(key: key, mainModel: mainModel),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToKycLevelsView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.kycLevelsView,
      arguments: KycLevelsViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToSwapView({
    _i54.Key? key,
    required List<_i56.Wallet> wallets,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.swapView,
      arguments: SwapViewArguments(key: key, wallets: wallets),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToPaymentSetupView({
    _i54.Key? key,
    required _i57.Future<bool> Function() readCard,
    required String selectedPaymentMethod,
    required _i54.TextEditingController amount,
    bool isReceive = true,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.paymentSetupView,
      arguments: PaymentSetupViewArguments(
        key: key,
        readCard: readCard,
        selectedPaymentMethod: selectedPaymentMethod,
        amount: amount,
        isReceive: isReceive,
      ),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToAddFundsView({
    _i54.Key? key,
    required String currency,
    required String userIcon,
    required String name,
    required String username,
    required String addFundType,
    required void Function() openNFCbottomSheet,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.addFundsView,
      arguments: AddFundsViewArguments(
        key: key,
        currency: currency,
        userIcon: userIcon,
        name: name,
        username: username,
        addFundType: addFundType,
        openNFCbottomSheet: openNFCbottomSheet,
      ),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToAddFundsOptionsView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.addFundsOptionsView,
      arguments: AddFundsOptionsViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToSendFundsView({
    _i54.Key? key,
    required String currency,
    required String userIcon,
    required String name,
    required String username,
    required String sendFundType,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.sendFundsView,
      arguments: SendFundsViewArguments(
        key: key,
        currency: currency,
        userIcon: userIcon,
        name: name,
        username: username,
        sendFundType: sendFundType,
      ),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToSendFundsOptionsView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.sendFundsOptionsView,
      arguments: SendFundsOptionsViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToPasscodeView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.passcodeView,
      arguments: PasscodeViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToCreatePasscodeView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.createPasscodeView,
      arguments: CreatePasscodeViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToReenterPasscodeView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.reenterPasscodeView,
      arguments: ReenterPasscodeViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToLinkedBanksView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.linkedBanksView,
      arguments: LinkedBanksViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToLinkABankView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.linkABankView,
      arguments: LinkABankViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToKycSuccessView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.kycSuccessView,
      arguments: KycSuccessViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToCardsView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.cardsView,
      arguments: CardsViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToPrepaidInfoView({
    _i54.Key? key,
    bool isVCard = false,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.prepaidInfoView,
      arguments: PrepaidInfoViewArguments(key: key, isVCard: isVCard),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToPersonaliseCardView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.personaliseCardView,
      arguments: PersonaliseCardViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToTransfersDetailsSelectionView({
    _i54.Key? key,
    required String dayfiId,
    required _i56.Wallet wallet,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.transfersDetailsSelectionView,
      arguments: TransfersDetailsSelectionViewArguments(
        key: key,
        dayfiId: dayfiId,
        wallet: wallet,
      ),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToRecipientDetailsView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.recipientDetailsView,
      arguments: RecipientDetailsViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToAmountEntryView({
    _i54.Key? key,
    required String accountNumber,
    required String bankCode,
    required String accountName,
    required String bankName,
    required String beneficiaryName,
    required _i56.Wallet wallet,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.amountEntryView,
      arguments: AmountEntryViewArguments(
        key: key,
        accountNumber: accountNumber,
        bankCode: bankCode,
        accountName: accountName,
        bankName: bankName,
        beneficiaryName: beneficiaryName,
        wallet: wallet,
      ),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToTransactionPinNewView({
    required String? oldPIN,
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.transactionPinNewView,
      arguments: TransactionPinNewViewArguments(oldPIN: oldPIN, key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToTransactionPinConfirmView({
    _i54.Key? key,
    required String pin,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.transactionPinConfirmView,
      arguments: TransactionPinConfirmViewArguments(key: key, pin: pin),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToWalletDetailsView({
    _i54.Key? key,
    required _i56.Wallet wallet,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.walletDetailsView,
      arguments: WalletDetailsViewArguments(key: key, wallet: wallet),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToTransactionDetailsView({
    required _i56.Wallet wallet,
    _i54.Key? key,
    required _i58.WalletTransaction transaction,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.transactionDetailsView,
      arguments: TransactionDetailsViewArguments(
        wallet: wallet,
        key: key,
        transaction: transaction,
      ),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToWalletView({
    required _i56.Wallet wallet,
    required List<_i58.WalletTransaction> walletTransactions,
    required List<_i56.Wallet> wallets,
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.walletView,
      arguments: WalletViewArguments(
        wallet: wallet,
        walletTransactions: walletTransactions,
        wallets: wallets,
        key: key,
      ),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToBlogView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.blogView,
      arguments: BlogViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToBlogDetailView({
    _i54.Key? key,
    required _i59.Article blog,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.blogDetailView,
      arguments: BlogDetailViewArguments(key: key, blog: blog),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToFaqsView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.faqsView,
      arguments: FaqsViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToTransactionHistoryView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.transactionHistoryView,
      arguments: TransactionHistoryViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToDigitalDollarView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  ]) async {
    return navigateTo<dynamic>(
      Routes.digitalDollarView,

      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToWalletAddressInfoView({
    required String address,
    required String currency,
    required String network,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.walletAddressInfoView,
      arguments: WalletAddressInfoViewArguments(
        address: address,
        currency: currency,
        network: network,
      ),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToVirtualCardDetailsView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return navigateTo<dynamic>(
      Routes.virtualCardDetailsView,
      arguments: VirtualCardDetailsViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithHomeView({
    _i54.Key? key,
    required _i55.MainViewModel mainModel,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.homeView,
      arguments: HomeViewArguments(key: key, mainModel: mainModel),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithSplashView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.splashView,
      arguments: SplashViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithStartupView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.startupView,
      arguments: StartupViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithSignupView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.signupView,
      arguments: SignupViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithLoginView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.loginView,
      arguments: LoginViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithForgotPasswordView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.forgotPasswordView,
      arguments: ForgotPasswordViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithVerifyEmailView({
    _i54.Key? key,
    bool isSignUp = false,
    required String email,
    String password = "",
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.verifyEmailView,
      arguments: VerifyEmailViewArguments(
        key: key,
        isSignUp: isSignUp,
        email: email,
        password: password,
      ),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithResetPasswordView({
    _i54.Key? key,
    required String email,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.resetPasswordView,
      arguments: ResetPasswordViewArguments(key: key, email: email),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithSuccessView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.successView,
      arguments: SuccessViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithMainView({
    _i54.Key? key,
    int index = 0,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.mainView,
      arguments: MainViewArguments(key: key, index: index),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithSettingsView({
    _i54.Key? key,
    required _i55.MainViewModel mainModel,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.settingsView,
      arguments: SettingsViewArguments(key: key, mainModel: mainModel),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithProfileView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.profileView,
      arguments: ProfileViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithTransactionPinSetView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.transactionPinSetView,
      arguments: TransactionPinSetViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithTransactionPinChangeView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.transactionPinChangeView,
      arguments: TransactionPinChangeViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithPasswordChangeView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.passwordChangeView,
      arguments: PasswordChangeViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithCoinsView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.coinsView,
      arguments: CoinsViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithVerifyPhoneView({
    _i54.Key? key,
    required String phoneNumber,
    required String country,
    required String state,
    required String street,
    required String city,
    required String postalCode,
    required String address,
    required String gender,
    required String dob,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.verifyPhoneView,
      arguments: VerifyPhoneViewArguments(
        key: key,
        phoneNumber: phoneNumber,
        country: country,
        state: state,
        street: street,
        city: city,
        postalCode: postalCode,
        address: address,
        gender: gender,
        dob: dob,
      ),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithLevelOnePartAView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.levelOnePartAView,
      arguments: LevelOnePartAViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithLevelOnePartBView({
    _i54.Key? key,
    required String country,
    required String state,
    required String street,
    required String city,
    required String postalCode,
    required String address,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.levelOnePartBView,
      arguments: LevelOnePartBViewArguments(
        key: key,
        country: country,
        state: state,
        street: street,
        city: city,
        postalCode: postalCode,
        address: address,
      ),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithCoinDetailView({
    _i54.Key? key,
    required String coinId,
    required String coinName,
    required dynamic coinPrice,
    required double priceChange,
    required dynamic marketCap,
    required dynamic popularity,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.coinDetailView,
      arguments: CoinDetailViewArguments(
        key: key,
        coinId: coinId,
        coinName: coinName,
        coinPrice: coinPrice,
        priceChange: priceChange,
        marketCap: marketCap,
        popularity: popularity,
      ),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithWalletsView({
    _i54.Key? key,
    required _i55.MainViewModel mainModel,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.walletsView,
      arguments: WalletsViewArguments(key: key, mainModel: mainModel),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithKycLevelsView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.kycLevelsView,
      arguments: KycLevelsViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithSwapView({
    _i54.Key? key,
    required List<_i56.Wallet> wallets,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.swapView,
      arguments: SwapViewArguments(key: key, wallets: wallets),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithPaymentSetupView({
    _i54.Key? key,
    required _i57.Future<bool> Function() readCard,
    required String selectedPaymentMethod,
    required _i54.TextEditingController amount,
    bool isReceive = true,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.paymentSetupView,
      arguments: PaymentSetupViewArguments(
        key: key,
        readCard: readCard,
        selectedPaymentMethod: selectedPaymentMethod,
        amount: amount,
        isReceive: isReceive,
      ),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithAddFundsView({
    _i54.Key? key,
    required String currency,
    required String userIcon,
    required String name,
    required String username,
    required String addFundType,
    required void Function() openNFCbottomSheet,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.addFundsView,
      arguments: AddFundsViewArguments(
        key: key,
        currency: currency,
        userIcon: userIcon,
        name: name,
        username: username,
        addFundType: addFundType,
        openNFCbottomSheet: openNFCbottomSheet,
      ),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithAddFundsOptionsView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.addFundsOptionsView,
      arguments: AddFundsOptionsViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithSendFundsView({
    _i54.Key? key,
    required String currency,
    required String userIcon,
    required String name,
    required String username,
    required String sendFundType,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.sendFundsView,
      arguments: SendFundsViewArguments(
        key: key,
        currency: currency,
        userIcon: userIcon,
        name: name,
        username: username,
        sendFundType: sendFundType,
      ),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithSendFundsOptionsView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.sendFundsOptionsView,
      arguments: SendFundsOptionsViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithPasscodeView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.passcodeView,
      arguments: PasscodeViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithCreatePasscodeView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.createPasscodeView,
      arguments: CreatePasscodeViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithReenterPasscodeView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.reenterPasscodeView,
      arguments: ReenterPasscodeViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithLinkedBanksView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.linkedBanksView,
      arguments: LinkedBanksViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithLinkABankView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.linkABankView,
      arguments: LinkABankViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithKycSuccessView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.kycSuccessView,
      arguments: KycSuccessViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithCardsView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.cardsView,
      arguments: CardsViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithPrepaidInfoView({
    _i54.Key? key,
    bool isVCard = false,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.prepaidInfoView,
      arguments: PrepaidInfoViewArguments(key: key, isVCard: isVCard),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithPersonaliseCardView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.personaliseCardView,
      arguments: PersonaliseCardViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithTransfersDetailsSelectionView({
    _i54.Key? key,
    required String dayfiId,
    required _i56.Wallet wallet,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.transfersDetailsSelectionView,
      arguments: TransfersDetailsSelectionViewArguments(
        key: key,
        dayfiId: dayfiId,
        wallet: wallet,
      ),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithRecipientDetailsView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.recipientDetailsView,
      arguments: RecipientDetailsViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithAmountEntryView({
    _i54.Key? key,
    required String accountNumber,
    required String bankCode,
    required String accountName,
    required String bankName,
    required String beneficiaryName,
    required _i56.Wallet wallet,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.amountEntryView,
      arguments: AmountEntryViewArguments(
        key: key,
        accountNumber: accountNumber,
        bankCode: bankCode,
        accountName: accountName,
        bankName: bankName,
        beneficiaryName: beneficiaryName,
        wallet: wallet,
      ),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithTransactionPinNewView({
    required String? oldPIN,
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.transactionPinNewView,
      arguments: TransactionPinNewViewArguments(oldPIN: oldPIN, key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithTransactionPinConfirmView({
    _i54.Key? key,
    required String pin,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.transactionPinConfirmView,
      arguments: TransactionPinConfirmViewArguments(key: key, pin: pin),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithWalletDetailsView({
    _i54.Key? key,
    required _i56.Wallet wallet,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.walletDetailsView,
      arguments: WalletDetailsViewArguments(key: key, wallet: wallet),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithTransactionDetailsView({
    required _i56.Wallet wallet,
    _i54.Key? key,
    required _i58.WalletTransaction transaction,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.transactionDetailsView,
      arguments: TransactionDetailsViewArguments(
        wallet: wallet,
        key: key,
        transaction: transaction,
      ),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithWalletView({
    required _i56.Wallet wallet,
    required List<_i58.WalletTransaction> walletTransactions,
    required List<_i56.Wallet> wallets,
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.walletView,
      arguments: WalletViewArguments(
        wallet: wallet,
        walletTransactions: walletTransactions,
        wallets: wallets,
        key: key,
      ),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithBlogView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.blogView,
      arguments: BlogViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithBlogDetailView({
    _i54.Key? key,
    required _i59.Article blog,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.blogDetailView,
      arguments: BlogDetailViewArguments(key: key, blog: blog),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithFaqsView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.faqsView,
      arguments: FaqsViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithTransactionHistoryView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.transactionHistoryView,
      arguments: TransactionHistoryViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithDigitalDollarView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  ]) async {
    return replaceWith<dynamic>(
      Routes.digitalDollarView,

      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithWalletAddressInfoView({
    required String address,
    required String currency,
    required String network,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.walletAddressInfoView,
      arguments: WalletAddressInfoViewArguments(
        address: address,
        currency: currency,
        network: network,
      ),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> replaceWithVirtualCardDetailsView({
    _i54.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  }) async {
    return replaceWith<dynamic>(
      Routes.virtualCardDetailsView,
      arguments: VirtualCardDetailsViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }
}
