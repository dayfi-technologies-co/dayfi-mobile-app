import 'package:dayfi/app_locator.dart';
import 'package:dayfi/features/auth/login/vm/login_viewmodel.dart';
import 'package:dayfi/services/remote/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  Future<void> signInAndGetGoogleToken() async {
    state = state.copyWith(isLoading: true, message: null, isSuccess: false);
    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        state = state.copyWith(isLoading: false, message: "User cancelled Google sign-in", isSuccess: false);
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final response = await _authService.googleAuth(authToken: accessToken!);
      // Save token and user data for Google auth (mimic email login)
      String? action;
      if (response.data != null) {
        final loginNotifier = locator<LoginNotifier>();
        final authData = response.data;
        final token = authData.token ?? '';
        final user = authData.user;
        final email = user?.email ?? googleUser.email;
        // Try to get action from authData if present
        if (response.data != null) {
          action = response.data?.action;
        }
        // Password is not available for Google, so store empty string
        await loginNotifier.saveGoogleAuthData(
          token: token,
          userJson: user != null ? user.toJson() : {},
          email: email,
          password: '',
        );
      }
      state = state.copyWith(isLoading: false, message: "Google sign-in successful!", isSuccess: true, action: action);
    } catch (e) {
      state = state.copyWith(isLoading: false, message: e.toString(), isSuccess: false);
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
