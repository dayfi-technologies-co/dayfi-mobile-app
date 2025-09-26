import 'package:flutter_riverpod/flutter_riverpod.dart';

class SuccessSignupViewModel extends StateNotifier<SuccessSignupState> {
  SuccessSignupViewModel() : super(const SuccessSignupState());

  /// Navigate to create passcode screen
  void navigateToCreatePasscode() {
    // This will be called when the user taps "Let's go!" button
    // The navigation will be handled by the parent widget
  }
}

class SuccessSignupState {
  const SuccessSignupState();

  SuccessSignupState copyWith() {
    return const SuccessSignupState();
  }
}

// Provider for the success signup viewmodel
final successSignupProvider = StateNotifierProvider<SuccessSignupViewModel, SuccessSignupState>(
  (ref) => SuccessSignupViewModel(),
);
