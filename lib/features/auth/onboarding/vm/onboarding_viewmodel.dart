import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dayfi/app_locator.dart';
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
  OnboardingState({
    required this.page,
    this.isLoading = false,
    this.message,
    this.isSuccess = false,
    this.action,
  });

  OnboardingState copyWith({
    int? page,
    bool? isLoading,
    String? message,
    bool? isSuccess,
    String? action,
  }) {
    return OnboardingState(
      page: page ?? this.page,
      isLoading: isLoading ?? this.isLoading,
      message: message,
      isSuccess: isSuccess ?? false,
      action: action ?? this.action,
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
    clientId:
        "826631103417-uc5f8ruhc8av1ncunkpufu9dpa1190ar.apps.googleusercontent.com",
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
    if (response.data != null) {
      final loginNotifier = locator<LoginNotifier>();
      final authData = response.data;
      final token = authData?.token ?? '';
      final user = authData?.user;
      final email = user?.email ?? fallbackEmail;
      action = authData?.action;
      await loginNotifier.saveGoogleAuthData(
        token: token,
        userJson: user != null ? user.toJson() : {},
        email: email,
        password: '',
      );
    }
    state = state.copyWith(
      isLoading: false,
      message: '$providerLabel sign-in successful!',
      isSuccess: true,
      action: action,
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
      if (accessToken == null || accessToken.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          message: 'Could not obtain Google access token.',
          isSuccess: false,
        );
        return;
      }
      final response =
          await _authService.googleAuth(authToken: accessToken);
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

  bool get isLastPage => state.page == 3;
  bool get isFirstPage => state.page == 0;
}

final onboardingViewModelProvider =
    StateNotifierProvider<OnboardingViewModel, OnboardingState>((ref) {
  return OnboardingViewModel();
});
