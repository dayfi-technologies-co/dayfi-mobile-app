import 'package:flutter_riverpod/flutter_riverpod.dart';

class SoftposInfoState {
  final bool isAgreed;
  final bool isLoading;
  final String? errorMessage;

  const SoftposInfoState({
    this.isAgreed = false,
    this.isLoading = false,
    this.errorMessage,
  });

  SoftposInfoState copyWith({
    bool? isAgreed,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SoftposInfoState(
      isAgreed: isAgreed ?? this.isAgreed,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class SoftposInfoViewModel extends StateNotifier<SoftposInfoState> {
  SoftposInfoViewModel() : super(const SoftposInfoState());

  void setAgreed(bool value) {
    state = state.copyWith(isAgreed: value);
  }
}

final softposInfoViewModelProvider =
    StateNotifierProvider<SoftposInfoViewModel, SoftposInfoState>((ref) {
  return SoftposInfoViewModel();
});
