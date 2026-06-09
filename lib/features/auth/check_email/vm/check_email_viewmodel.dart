import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/services/remote/auth_service.dart';
import 'package:dayfi/services/remote/network/api_error.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/common/constants/analytics_events.dart';
import 'package:dayfi/common/utils/connectivity_utils.dart';

/// =======================
/// STATE
/// =======================
class CheckEmailState {
  final String email;
  final bool isBusy;
  final String emailError;

  const CheckEmailState({
    this.email = '',
    this.isBusy = false,
    this.emailError = '',
  });

  bool get isFormValid => email.isNotEmpty && emailError.isEmpty;

  CheckEmailState copyWith({String? email, bool? isBusy, String? emailError}) {
    return CheckEmailState(
      email: email ?? this.email,
      isBusy: isBusy ?? this.isBusy,
      emailError: emailError ?? this.emailError,
    );
  }
}

/// =======================
/// NOTIFIER
/// =======================
class CheckEmailNotifier extends StateNotifier<CheckEmailState> {
  final AuthService _authService = authService;

  CheckEmailNotifier() : super(const CheckEmailState());

  void setEmail(String value) {
    state = state.copyWith(email: value, emailError: _validateEmail(value));
  }

  String _validateEmail(String value) {
    if (value.isEmpty) {
      return 'Please enter your email address';
    }

    if (!RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address (e.g. name@email.com)';
    }

    return '';
  }

  Future<void> validateEmail(BuildContext context) async {
    if (!state.isFormValid) return;

    state = state.copyWith(isBusy: true);

    try {
      analyticsService.logEvent(
        name: AnalyticsEvents.signupStarted,
        parameters: {'email': state.email},
      );

      AppLogger.info('Checking email: ${state.email}');

      final response = await _authService.validateEmail(email: state.email.toLowerCase());

      // ✅ Success (2xx)
      // TopSnackbar.show(context, message: response.message, isError: false);

      analyticsService.logEvent(
        name: AnalyticsEvents.signupCompleted,
        parameters: {'email': state.email},
      );

      // await Future.delayed(const Duration(milliseconds: 1000));

      if (response.message.toLowerCase().contains('does not exist')) {
        if (!context.mounted) return;
        appRouter.pushNamed(
          AppRoute.signupView,
          arguments: SignupViewArguments(email: state.email),
        );
      } else if (response.message.toLowerCase().contains('already exists')) {
        if (!context.mounted) return;
        appRouter.pushNamed(
          AppRoute.loginView,
          arguments: LoginViewArguments(email: state.email),
        );
      }
    }
    /// Network layer wraps failures in [ApiError] (see [NetworkService.call]).
    on ApiError catch (e) {
      final backendMessage =
          e.errorDescription ??
          e.apiErrorModel?.message ??
          'Something went wrong. Please try again.';

      AppLogger.error('Email validation failed (ApiError): $backendMessage');

      final lower = backendMessage.toLowerCase();
      final duplicateEmail = e.errorType == 400 &&
          (lower.contains('already exist') ||
              lower.contains('already in use') ||
              lower.contains('log in'));

      await analyticsService.logEvent(
        name: AnalyticsEvents.signupFailed,
        parameters: {
          'email': state.email,
          'reason':
              duplicateEmail ? 'existing_account' : backendMessage,
        },
      );

      if (!context.mounted) return;

      // Existing account: go to sign-in instead of only showing an error banner.
      if (duplicateEmail) {
        final lower = backendMessage.toLowerCase();
        if (lower.contains('google') || lower.contains('apple')) {
          TopSnackbar.show(context, message: backendMessage, isError: true);
          return;
        }
        appRouter.pushNamed(
          AppRoute.loginView,
          arguments: LoginViewArguments(email: state.email),
        );
        return;
      }

      TopSnackbar.show(context, message: backendMessage, isError: true);
    }
    on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;
      final backendMessage = data is Map && data['message'] != null
          ? data['message'].toString()
          : 'Something went wrong. Please try again.';

      AppLogger.error('Email validation failed [$statusCode]: $backendMessage');

      await analyticsService.logEvent(
        name: AnalyticsEvents.signupFailed,
        parameters: {'email': state.email, 'reason': backendMessage},
      );

      if (!context.mounted) return;
      TopSnackbar.show(context, message: backendMessage, isError: true);
    }
    /// =======================
    /// ✅ FALLBACK ERROR
    /// =======================
    catch (e) {
      AppLogger.error('Unexpected error: $e');

      final errorMessage = await ConnectivityUtils.getErrorMessage(e);

      await analyticsService.logEvent(
        name: AnalyticsEvents.signupFailed,
        parameters: {'email': state.email, 'reason': errorMessage},
      );

      if (!context.mounted) return;
      TopSnackbar.show(context, message: errorMessage, isError: true);
    } finally {
      state = state.copyWith(isBusy: false);
    }
  }

  void resetForm() {
    state = const CheckEmailState();
  }
}

/// =======================
/// PROVIDER
/// =======================
final checkEmailProvider =
    StateNotifierProvider<CheckEmailNotifier, CheckEmailState>(
      (ref) => CheckEmailNotifier(),
    );

/// =======================
/// ROUTE ARGUMENTS
/// =======================
class SignupViewArguments {
  final String email;
  const SignupViewArguments({required this.email});
}

class LoginViewArguments {
  final String email;
  const LoginViewArguments({required this.email});
}
