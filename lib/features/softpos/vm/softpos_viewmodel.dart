import 'package:flutter_riverpod/flutter_riverpod.dart';

class SoftposState {
  final bool isLoading;
  final String? errorMessage;

  const SoftposState({
    this.isLoading = false,
    this.errorMessage,
  });

  SoftposState copyWith({
    bool? isLoading,
    String? errorMessage,
  }) {
    return SoftposState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class SoftposViewModel extends StateNotifier<SoftposState> {
  SoftposViewModel() : super(const SoftposState());
}

final softposViewModelProvider =
    StateNotifierProvider<SoftposViewModel, SoftposState>((ref) {
  return SoftposViewModel();
});
