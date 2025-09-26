import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingViewModel extends StateNotifier<int> {
  OnboardingViewModel() : super(0);

  void nextPage() {
    if (state < 3) {
      state = state + 1;
    }
  }

  void previousPage() {
    if (state > 0) {
      state = state - 1;
    }
  }

  void goToPage(int page) {
    if (page >= 0 && page <= 3) {
      state = page;
    }
  }

  bool get isLastPage => state == 3;
  bool get isFirstPage => state == 0;
}

final onboardingViewModelProvider = StateNotifierProvider<OnboardingViewModel, int>((ref) {
  return OnboardingViewModel();
});
