import 'package:dayfi/services/local/local_cache.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/models/wallet.dart';
import 'package:dayfi/models/wallet_hub.dart';
import 'package:dayfi/services/remote/wallet_service.dart';
import 'package:dayfi/common/utils/app_logger.dart';

class HomeState {
  final List<Wallet> wallets;
  final Wallet? primaryWallet;
  final TotalAvailableBalance? totalAvailableBalance;
  final bool isLoading;
  final String? errorMessage;

  const HomeState({
    this.wallets = const [],
    this.primaryWallet,
    this.totalAvailableBalance,
    this.isLoading = false,
    this.errorMessage,
  });

  /// Hero balance — unified USD (Grey-style total available balance).
  String get balance {
    if (totalAvailableBalance != null) {
      return totalAvailableBalance!.amount.toStringAsFixed(2);
    }
    if (primaryWallet != null) {
      return primaryWallet!.balance;
    }
    return '0.00';
  }

  String get currency => 'USD';

  String get formattedBalance {
    if (totalAvailableBalance != null) {
      return totalAvailableBalance!.formatted;
    }
    if (primaryWallet != null) {
      return primaryWallet!.formattedBalance;
    }
    return '\$0.00';
  }

  String get currencySymbol => '\$';

  HomeState copyWith({
    List<Wallet>? wallets,
    Wallet? primaryWallet,
    TotalAvailableBalance? totalAvailableBalance,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HomeState(
      wallets: wallets ?? this.wallets,
      primaryWallet: primaryWallet ?? this.primaryWallet,
      totalAvailableBalance:
          totalAvailableBalance ?? this.totalAvailableBalance,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class HomeViewModel extends StateNotifier<HomeState> {
  static const _walletsCacheKey = 'wallets';
  static const _balanceCacheKey = 'totalAvailableBalance';

  final LocalCache _localCache = locator<LocalCache>();
  final WalletService _walletService = walletService;

  HomeViewModel() : super(const HomeState());

  TotalAvailableBalance? _readCachedTotalBalance() {
    final cached = _localCache.getFromLocalCache(_balanceCacheKey);
    if (cached is! Map) return null;
    try {
      return TotalAvailableBalance.fromJson(
        Map<String, dynamic>.from(cached),
      );
    } catch (_) {
      return null;
    }
  }

  /// Fetch wallet details from API, with local cache fallback
  Future<void> fetchWalletDetails({
    bool isInitialLoad = false,
    bool forceRefresh = false,
  }) async {
    TotalAvailableBalance? cachedBalance;
    if (!forceRefresh) {
      cachedBalance = _readCachedTotalBalance();
      if (state.totalAvailableBalance == null && cachedBalance != null) {
        state = state.copyWith(totalAvailableBalance: cachedBalance);
      }

      if (state.wallets.isEmpty) {
        final cached = _localCache.getFromLocalCache(_walletsCacheKey);
        if (cached != null) {
          try {
            final List<dynamic> walletsJson =
                (cached is String) ? (walletsFromJson(cached)) : (cached as List<dynamic>);
            final wallets = walletsJson.map((e) => Wallet.fromJson(e)).toList();
            final primaryWallet = wallets.cast<Wallet?>().firstWhere(
              (w) => w?.currency.toUpperCase() == 'USD',
              orElse: () => wallets.isNotEmpty ? wallets.first : null,
            );
            state = state.copyWith(
              wallets: wallets,
              primaryWallet: primaryWallet,
              totalAvailableBalance:
                  state.totalAvailableBalance ?? cachedBalance,
            );
          } catch (_) {}
        }
      }
    }

    final hasDisplayedBalance = state.totalAvailableBalance != null;
    final shouldShowLoading = !hasDisplayedBalance && state.wallets.isEmpty;
    state = state.copyWith(isLoading: shouldShowLoading, errorMessage: null);
    try {
      AppLogger.info('Fetching wallet details from API...');
      final hub = await _walletService.fetchWalletHub();
      final wallets = hub.ledgerWallets;
      final primaryWallet = wallets.cast<Wallet?>().firstWhere(
            (w) => w?.currency.toUpperCase() == 'USD',
            orElse: () => wallets.isNotEmpty ? wallets.first : null,
          );
      if (wallets.isNotEmpty) {
        await _localCache.saveToLocalCache(
          key: _walletsCacheKey,
          value: wallets.map((e) => e.toJson()).toList(),
        );
      }
      await _localCache.saveToLocalCache(
        key: _balanceCacheKey,
        value: {
          'currency': hub.totalAvailableBalance.currency,
          'amount': hub.totalAvailableBalance.amount,
          'formatted': hub.totalAvailableBalance.formatted,
        },
      );
      state = state.copyWith(
        wallets: wallets,
        primaryWallet: primaryWallet,
        totalAvailableBalance: hub.totalAvailableBalance,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      AppLogger.error('Error fetching wallet details: $e');
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to load wallet balance. Please try again.');
    }
  }

  /// Refresh wallet details
  Future<void> refreshWalletDetails() async {
    await fetchWalletDetails(forceRefresh: true);
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

