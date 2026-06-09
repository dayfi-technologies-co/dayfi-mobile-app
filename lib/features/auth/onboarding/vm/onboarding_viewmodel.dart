import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/helpers/biometric_preferences.dart';
import 'package:dayfi/core/google_auth_config.dart';
import 'package:dayfi/models/auth_response.dart';
import 'package:dayfi/features/auth/login/vm/login_viewmodel.dart';
import 'package:dayfi/services/remote/auth_service.dart';
import 'package:dayfi/services/remote/network/api_error.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class OnboardingState {
  final int page;
  final bool isLoading;
  final String? message;
  final bool isSuccess;
  final String? action;
  final bool isReturningUser;
  OnboardingState({
    required this.page,
    this.isLoading = false,
    this.message,
    this.isSuccess = false,
    this.action,
    this.isReturningUser = false,
  });

  OnboardingState copyWith({
    int? page,
    bool? isLoading,
    String? message,
    bool? isSuccess,
    String? action,
    bool? isReturningUser,
  }) {
    return OnboardingState(
      page: page ?? this.page,
      isLoading: isLoading ?? this.isLoading,
      message: message,
      isSuccess: isSuccess ?? false,
      action: action ?? this.action,
      isReturningUser: isReturningUser ?? this.isReturningUser,
    );
  }
}

class OnboardingViewModel extends StateNotifier<OnboardingState> {
  void clearMessage() {
    state = state.copyWith(message: null);
  }

  OnboardingViewModel() : super(OnboardingState(page: 0));

  final AuthService _authService = authService;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: GoogleAuthConfig.webClientId ?? GoogleAuthConfig.iosClientId,
    serverClientId: GoogleAuthConfig.serverClientId,
    scopes: ['email', 'profile'],
  );

  String _formatAuthFailure(Object e) {
    if (e is ApiError) {
      return e.errorDescription ??
          e.apiErrorModel?.message ??
          e.toString();
    }
    return e.toString();
  }

  Future<void> _finalizeSocialAuth(
    AuthResponse response, {
    required String fallbackEmail,
    required String providerLabel,
  }) async {
    String? action;
    var isReturningUser = false;
    if (response.data != null) {
      final loginNotifier = locator<LoginNotifier>();
      final authData = response.data;
      final token = authData?.token ?? '';
      final user = authData?.user;
      final email = user?.email ?? fallbackEmail;
      action = authData?.action;
      final phone = user?.phoneNumber?.trim() ?? '';
      isReturningUser = action == 'login' || phone.isNotEmpty;
      await loginNotifier.saveGoogleAuthData(
        token: token,
        userJson: user != null ? user.toJson() : {},
        email: email,
        password: '',
      );
      if (isReturningUser) {
        await BiometricPreferences.schedulePostLoginBiometricPrompt();
      }
    }
    state = state.copyWith(
      isLoading: false,
      message: '$providerLabel sign-in successful!',
      isSuccess: true,
      action: action,
      isReturningUser: isReturningUser,
    );
  }

  Future<void> signInAndGetGoogleToken() async {
    state = state.copyWith(isLoading: true, message: null, isSuccess: false);
    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        state = state.copyWith(
          isLoading: false,
          message: 'User cancelled Google sign-in',
          isSuccess: false,
        );
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;
      final authToken =
          (accessToken != null && accessToken.isNotEmpty)
              ? accessToken
              : idToken;
      if (authToken == null || authToken.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          message:
              'Could not obtain Google sign-in token. Check Google OAuth setup for this app flavor.',
          isSuccess: false,
        );
        return;
      }
      final response =
          await _authService.googleAuth(authToken: authToken);
      await _finalizeSocialAuth(
        response,
        fallbackEmail: googleUser.email,
        providerLabel: 'Google',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        message: _formatAuthFailure(e),
        isSuccess: false,
      );
    }
  }

  String _randomNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> signInWithApple() async {
    state = state.copyWith(isLoading: true, message: null, isSuccess: false);
    try {
      final available = await SignInWithApple.isAvailable();
      if (!available) {
        state = state.copyWith(
          isLoading: false,
          message: 'Sign in with Apple is not available on this device.',
          isSuccess: false,
        );
        return;
      }

      final rawNonce = _randomNonce();
      final nonce = _sha256ofString(rawNonce);

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final identityToken = credential.identityToken;
      if (identityToken == null || identityToken.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          message: 'Could not obtain Apple identity token.',
          isSuccess: false,
        );
        return;
      }

      final response = await _authService.appleAuth(
        authToken: identityToken,
        nonce: rawNonce,
        firstName: credential.givenName,
        lastName: credential.familyName,
      );

      final fallbackEmail = credential.email ?? '';

      await _finalizeSocialAuth(
        response,
        fallbackEmail: fallbackEmail,
        providerLabel: 'Apple',
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        state = state.copyWith(
          isLoading: false,
          message: 'User cancelled Apple sign-in',
          isSuccess: false,
        );
        return;
      }
      // ASAuthorizationError 1000 often means missing entitlements / capability or simulator without Apple ID.
      final isConfigOrSimulator = e.code == AuthorizationErrorCode.unknown ||
          e.code == AuthorizationErrorCode.failed;
      state = state.copyWith(
        isLoading: false,
        message: isConfigOrSimulator
            ? 'Apple Sign-In could not start. Delete the app, clean build in Xcode, then reinstall. On Simulator, sign in to an Apple ID under Settings. Confirm the App ID enables Sign In with Apple for this bundle ID.'
            : e.toString(),
        isSuccess: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        message: _formatAuthFailure(e),
        isSuccess: false,
      );
    }
  }

  void nextPage() {
    if (state.page < 3) {
      state = state.copyWith(page: state.page + 1);
    }
  }

  void previousPage() {
    if (state.page > 0) {
      state = state.copyWith(page: state.page - 1);
    }
  }

  void goToPage(int page) {
    if (page >= 0 && page <= 3) {
      state = state.copyWith(page: page);
    }
  }

  /// Clears success flag and message after post-auth navigation (avoids
  /// treating the success string as an error snackbar on the next frame).
  void consumeAuthSuccess() {
    state = state.copyWith(
      isSuccess: false,
      message: null,
      page: 0,
      isReturningUser: false,
    );
  }

  bool get isLastPage => state.page == 3;
  bool get isFirstPage => state.page == 0;
}

final onboardingViewModelProvider =
    StateNotifierProvider<OnboardingViewModel, OnboardingState>((ref) {
  return OnboardingViewModel();
});
