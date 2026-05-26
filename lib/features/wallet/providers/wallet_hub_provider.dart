import 'package:dayfi/app_locator.dart';
import 'package:dayfi/models/wallet_hub.dart';
import 'package:dayfi/services/remote/wallet_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WalletHubState {
  final WalletHubSnapshot? hub;
  final bool isLoading;
  final String? errorMessage;

  const WalletHubState({
    this.hub,
    this.isLoading = false,
    this.errorMessage,
  });

  WalletHubState copyWith({
    WalletHubSnapshot? hub,
    bool? isLoading,
    String? errorMessage,
  }) {
    return WalletHubState(
      hub: hub ?? this.hub,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class WalletHubNotifier extends StateNotifier<WalletHubState> {
  WalletHubNotifier() : super(const WalletHubState());

  final WalletService _walletService = walletService;

  Future<void> load({bool showLoading = true}) async {
    if (showLoading && state.hub == null) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }
    try {
      final hub = await _walletService.fetchWalletHub();
      state = WalletHubState(hub: hub, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load balances',
      );
    }
  }

  Future<void> refresh() => load(showLoading: false);
}

final walletHubProvider =
    StateNotifierProvider<WalletHubNotifier, WalletHubState>((ref) {
  return WalletHubNotifier();
});

/// Wallet the user chose to debit on Send (Yellow Card / username / crypto).
final selectedDebitCurrencyProvider = StateProvider<String>((ref) => 'USD');
