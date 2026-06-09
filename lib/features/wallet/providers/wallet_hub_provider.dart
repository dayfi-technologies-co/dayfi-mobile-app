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

  Future<void> load({bool showLoading = true, bool syncCrypto = false}) async {
    final showSpinner = showLoading && state.hub == null;
    if (showSpinner) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }
    try {
      final hub = await _walletService.fetchWalletHub(syncCrypto: syncCrypto);
      state = WalletHubState(hub: hub, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load balances',
      );
    }
  }

  Future<void> refresh({bool syncCrypto = false}) =>
      load(showLoading: false, syncCrypto: syncCrypto);
}

final walletHubProvider =
    StateNotifierProvider<WalletHubNotifier, WalletHubState>((ref) {
  return WalletHubNotifier();
});

/// Pay-with / display currency for Send (maps to global USD balance).
final selectedDebitCurrencyProvider = StateProvider<String>((ref) => 'USD');
