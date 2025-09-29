import 'dart:io';

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
import 'package:dayfi/features/auth/biometric_setup/views/biometric_setup_view.dart';
import 'package:dayfi/features/main/views/main_view.dart';
import 'package:dayfi/features/auth/onboarding/views/onboarding_view.dart';
import 'package:dayfi/features/profile/edit_profile/views/edit_profile_view.dart';

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
  static const String biometricSetupView = '/biometricSetupView';
  static const String mainView = '/mainView';
  static const String editProfileView = '/editProfileView';

  static Route getRoute(RouteSettings routeSettings) {
    globalrouteSettings = routeSettings;
    switch (routeSettings.name) {
      case loginView:
        bool showBackButton = routeSettings.arguments as bool? ?? true;
        return _getPageRoute(routeSettings, LoginView(showBackButton: showBackButton));
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
        return _getPageRoute(routeSettings, CreatePasscodeView(isFromSignup: isFromSignup));
      case reenterPasscodeView:
        bool isFromSignup = routeSettings.arguments as bool? ?? false;
        return _getPageRoute(routeSettings, ReenterPasscodeView(isFromSignup: isFromSignup));
      case forgotPasswordView:
        return _getPageRoute(routeSettings, const ForgotPasswordView());
      case resetPasswordView:
        String email = routeSettings.arguments as String;
        return _getPageRoute(routeSettings, ResetPasswordView(email: email));
      case passcodeView:
        return _getPageRoute(routeSettings, const PasscodeView());
      case completePersonalInfoView:
        return _getPageRoute(routeSettings, const CompletePersonalInformationView());
      case biometricSetupView:
        return _getPageRoute(routeSettings, const BiometricSetupView());
      case mainView:
        return _getPageRoute(routeSettings, const MainView());
      case editProfileView:
        return _getPageRoute(routeSettings, const EditProfileView());

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
