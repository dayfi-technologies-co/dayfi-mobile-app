import 'package:dayfi/services/local/local_cache.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/models/wallet.dart';
import 'package:dayfi/services/remote/wallet_service.dart';
import 'package:dayfi/common/utils/app_logger.dart';

class HomeState {
  final List<Wallet> wallets;
  final Wallet? primaryWallet;
  final bool isLoading;
  final String? errorMessage;

  const HomeState({
    this.wallets = const [],
    this.primaryWallet,
    this.isLoading = false,
    this.errorMessage,
  });

  /// Get the primary wallet balance (first wallet or NGN wallet)
  String get balance {
    if (primaryWallet != null) {
      return primaryWallet!.balance;
    }
    if (wallets.isNotEmpty) {
      return wallets.first.balance;
    }
    return '0.00';
  }

  /// Get the currency of the primary wallet
  String get currency {
    if (primaryWallet != null) {
      return primaryWallet!.currency;
    }
    if (wallets.isNotEmpty) {
      return wallets.first.currency;
    }
    return 'NGN';
  }

  /// Get formatted balance with currency symbol
  String get formattedBalance {
    if (primaryWallet != null) {
      return primaryWallet!.formattedBalance;
    }
    if (wallets.isNotEmpty) {
      return wallets.first.formattedBalance;
    }
    return '₦0.00';
  }

  /// Get currency symbol
  String get currencySymbol {
    final curr = currency.toUpperCase();
    switch (curr) {
      case 'NGN':
        return '₦';
      case 'USD':
        return '\$';
      case 'GBP':
        return '£';
      case 'EUR':
        return '€';
      default:
        return curr;
    }
  }

  HomeState copyWith({
    List<Wallet>? wallets,
    Wallet? primaryWallet,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HomeState(
      wallets: wallets ?? this.wallets,
      primaryWallet: primaryWallet ?? this.primaryWallet,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class HomeViewModel extends StateNotifier<HomeState> {
    final LocalCache _localCache = locator<LocalCache>();
  final WalletService _walletService = walletService;

  HomeViewModel() : super(const HomeState());

  /// Fetch wallet details from API, with local cache fallback
  Future<void> fetchWalletDetails({bool isInitialLoad = false}) async {
    // Try to load cached wallets first
    if (state.wallets.isEmpty) {
      final cached = _localCache.getFromLocalCache('wallets');
      if (cached != null) {
        try {
          final List<dynamic> walletsJson = (cached is String) ? (walletsFromJson(cached)) : (cached as List<dynamic>);
          final wallets = walletsJson.map((e) => Wallet.fromJson(e)).toList();
          Wallet? primaryWallet = wallets.firstWhere((w) => w.currency.toUpperCase() == 'NGN', orElse: () => wallets.first);
          state = state.copyWith(wallets: wallets, primaryWallet: primaryWallet, isLoading: false);
        } catch (_) {}
      }
    }
    // Only show loading if no cache
    final shouldShowLoading = state.wallets.isEmpty;
    state = state.copyWith(isLoading: shouldShowLoading, errorMessage: null);
    try {
      AppLogger.info('Fetching wallet details from API...');
      final response = await _walletService.fetchWalletDetails();
      if (response.wallets.isEmpty) {
        AppLogger.warning('No wallets found in response');
        state = state.copyWith(wallets: [], primaryWallet: null, isLoading: false, errorMessage: null);
        return;
      }
      Wallet? primaryWallet;
      for (final wallet in response.wallets) {
        if (wallet.currency.toUpperCase() == 'NGN') {
          primaryWallet = wallet;
          break;
        }
      }
      primaryWallet ??= response.wallets.first;
      // Cache wallets
      await _localCache.saveToLocalCache(key: 'wallets', value: response.wallets.map((e) => e.toJson()).toList());
      state = state.copyWith(wallets: response.wallets, primaryWallet: primaryWallet, isLoading: false, errorMessage: null);
    } catch (e) {
      AppLogger.error('Error fetching wallet details: $e');
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to load wallet balance. Please try again.');
    }
  }

  /// Refresh wallet details
  Future<void> refreshWalletDetails() async {
    await fetchWalletDetails();
  }

  /// Initialize wallet data (call this when view loads)
  Future<void> initialize() async {
    await fetchWalletDetails(isInitialLoad: true);
  }
}

// Provider for HomeViewModel
final homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, HomeState>((ref) {
  return HomeViewModel();
});

