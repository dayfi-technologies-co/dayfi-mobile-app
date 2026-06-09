import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/constants/storage_keys.dart';
import 'package:dayfi/features/wallet/constants/global_wallet.dart';
import 'package:dayfi/services/remote/payment_service.dart';
import 'package:dayfi/services/remote/wallet_service.dart';
import 'package:dayfi/services/local/secure_storage.dart';
import 'package:dayfi/features/send/services/ngn_banks_cache.dart';
import 'package:dayfi/models/payment_response.dart';
import 'package:dayfi/models/fees_response.dart';
import 'package:dayfi/features/send/constants/yellow_card_corridors.dart';
import 'package:dayfi/features/send/helpers/send_amount_limits.dart';
import 'package:dayfi/features/send/constants/send_copy.dart';
import 'package:dayfi/features/send/send_flow.dart';
import 'package:dayfi/core/auth/unauthorized_navigation_guard.dart';
import 'package:dayfi/common/utils/app_logger.dart';

class CountryOption {
  final String code;
  final String name;
  final String currency;
  final String flag;

  CountryOption({
    required this.code,
    required this.name,
    required this.currency,
    required this.flag,
  });
}

class SendState {
  final String sendAmount;
  final String receiverAmount;
  final String sendCurrency;
  final String receiverCurrency;
  final String sendCountry;
  final String receiverCountry;
  final String fee;
  final String totalToPay;
  final String exchangeRate;
  final bool showUpgradePrompt;
  final bool isLoading;
  final List<String> availableCurrencies;
  final List<Channel> channels;
  final List<Network> networks;
  final List<Channel> availableDeliveryMethods;
  final String selectedDeliveryMethod;
  final String selectedSenderDeliveryMethod;
  final String selectedSenderChannelId;
  final List<CountryOption> availableCountries;
  final Map<String, dynamic>? sendCurrencyRates;
  final Map<String, dynamic>? receiveCurrencyRates;
  final bool isRatesLoading;
  final bool showRatesLoading;
  final bool hasValidRates;
  final FeesData? feesData;

  const SendState({
    this.sendAmount = '',
    this.receiverAmount = '',
    this.sendCurrency = 'NGN',
    this.receiverCurrency = 'NGN',
    this.sendCountry = 'NG',
    this.receiverCountry = 'NG',
    this.fee = '0.00',
    this.totalToPay = '0.00',
    this.exchangeRate = '₦1 = ₦1',
    this.showUpgradePrompt = true,
    this.isLoading = false,
    this.availableCurrencies = const [],
    this.channels = const [],
    this.networks = const [],
    this.availableDeliveryMethods = const [],
    this.selectedDeliveryMethod = '',
    this.selectedSenderDeliveryMethod = '',
    this.selectedSenderChannelId = '',
    this.availableCountries = const [],
    this.sendCurrencyRates,
    this.receiveCurrencyRates,
    this.isRatesLoading = false,
    this.showRatesLoading = false,
    this.hasValidRates = true,
    this.feesData,
  });

  SendState copyWith({
    String? sendAmount,
    String? receiverAmount,
    String? sendCurrency,
    String? receiverCurrency,
    String? sendCountry,
    String? receiverCountry,
    String? fee,
    String? totalToPay,
    String? exchangeRate,
    bool? showUpgradePrompt,
    bool? isLoading,
    List<String>? availableCurrencies,
    List<Channel>? channels,
    List<Network>? networks,
    List<Channel>? availableDeliveryMethods,
    String? selectedDeliveryMethod,
    String? selectedSenderDeliveryMethod,
    String? selectedSenderChannelId,
    List<CountryOption>? availableCountries,
    Map<String, dynamic>? sendCurrencyRates,
    Map<String, dynamic>? receiveCurrencyRates,
    bool? isRatesLoading,
    bool? showRatesLoading,
    bool? hasValidRates,
    FeesData? feesData,
  }) {
    return SendState(
      sendAmount: sendAmount ?? this.sendAmount,
      receiverAmount: receiverAmount ?? this.receiverAmount,
      sendCurrency: sendCurrency ?? this.sendCurrency,
      receiverCurrency: receiverCurrency ?? this.receiverCurrency,
      sendCountry: sendCountry ?? this.sendCountry,
      receiverCountry: receiverCountry ?? this.receiverCountry,
      fee: fee ?? this.fee,
      totalToPay: totalToPay ?? this.totalToPay,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      showUpgradePrompt: showUpgradePrompt ?? this.showUpgradePrompt,
      isLoading: isLoading ?? this.isLoading,
      availableCurrencies: availableCurrencies ?? this.availableCurrencies,
      channels: channels ?? this.channels,
      networks: networks ?? this.networks,
      availableDeliveryMethods:
          availableDeliveryMethods ?? this.availableDeliveryMethods,
      selectedDeliveryMethod:
          selectedDeliveryMethod ?? this.selectedDeliveryMethod,
      selectedSenderDeliveryMethod:
          selectedSenderDeliveryMethod ?? this.selectedSenderDeliveryMethod,
      selectedSenderChannelId:
          selectedSenderChannelId ?? this.selectedSenderChannelId,
      availableCountries: availableCountries ?? this.availableCountries,
      sendCurrencyRates: sendCurrencyRates ?? this.sendCurrencyRates,
      receiveCurrencyRates: receiveCurrencyRates ?? this.receiveCurrencyRates,
      isRatesLoading: isRatesLoading ?? this.isRatesLoading,
      showRatesLoading: showRatesLoading ?? this.showRatesLoading,
      hasValidRates: hasValidRates ?? this.hasValidRates,
      feesData: feesData ?? this.feesData,
    );
  }
}

class SendViewModel extends StateNotifier<SendState> {
  final PaymentService _paymentService = paymentService;
  final WalletService _walletService = walletService;
  final SecureStorageService _secureStorage = locator<SecureStorageService>();

  // Simple cache for API responses
  static List<Channel>? _cachedChannels;
  static DateTime? _channelsCacheTime;
  static const Duration _cacheValidityDuration = Duration(minutes: 5);

  // Rate caching to minimize API calls
  static final Map<String, Map<String, dynamic>> _cachedRates = {};
  static final Map<String, DateTime> _ratesCacheTime = {};
  static const Duration _ratesCacheValidityDuration = Duration(minutes: 2);

  Map<String, dynamic>? _walletExchangeRates;
  DateTime? _walletRatesCacheTime;
  static const Duration _walletRatesCacheValidityDuration = Duration(
    minutes: 5,
  );

  // Debouncing mechanism for loading states
  Timer? _loadingDebounceTimer;
  static const Duration _loadingDebounceDelay = Duration(milliseconds: 500);

  // Initialization guard to prevent multiple initializations
  bool _isInitialized = false;
  bool _isInitializing = false;

  // Retry mechanism
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  SendViewModel() : super(const SendState());

  @override
  void dispose() {
    _loadingDebounceTimer?.cancel();
    super.dispose();
  }

  Future<void> initialize() async {
    // Prevent multiple initializations
    if (_isInitialized || _isInitializing) {
      AppLogger.debug(
        'SendViewModel already initialized or initializing, skipping...',
      );
      return;
    }

    _isInitializing = true;
    AppLogger.debug('🚀 Initializing SendViewModel...');

    if (!await _hasActiveSession()) {
      AppLogger.info('⏭️ Skipping SendViewModel initialization: no active session');
      _isInitializing = false;
      return;
    }

    // Preserve existing amounts during initialization
    final existingSendAmount = state.sendAmount;
    final existingReceiveAmount = state.receiverAmount;
    final hasExistingAmounts =
        existingSendAmount.isNotEmpty || existingReceiveAmount.isNotEmpty;

    // Preserve existing receiver country/currency during initialization
    final existingReceiverCountry = state.receiverCountry;
    final existingReceiverCurrency = state.receiverCurrency;
    final existingDeliveryMethod = state.selectedDeliveryMethod;
    final hasExistingReceiver =
        existingReceiverCountry.isNotEmpty &&
        existingReceiverCurrency.isNotEmpty;

    final existingSendCountry = state.sendCountry;
    final existingSendCurrency = state.sendCurrency;
    final hasExistingSend =
        existingSendCountry.isNotEmpty &&
        existingSendCurrency.isNotEmpty &&
        !(existingSendCurrency == 'NGN' &&
            existingSendCountry == 'NG' &&
            existingReceiverCurrency == 'NGN');

    AppLogger.debug(
      '💰 Preserving amounts: send=$existingSendAmount, receive=$existingReceiveAmount',
    );
    if (hasExistingReceiver) {
      AppLogger.debug(
        '🌍 Preserving receiver: country=$existingReceiverCountry, currency=$existingReceiverCurrency, method=$existingDeliveryMethod',
      );
    }

    // Initialize any required data
    state = state.copyWith(isLoading: true);

    try {
      // Fetch available currencies from channels API with retry mechanism
      await _fetchAvailableCurrenciesWithRetry();

      // After fetching channels, set up default delivery methods and fetch rates
      await _setupDefaultSelections();

      // Fetch fees data
      AppLogger.debug('🔄 About to call _fetchFees()');
      await _fetchFees();
      AppLogger.debug('🔄 _fetchFees() completed');

      await _fetchPaymentNetworks();
      unawaited(prefetchNigerianBanks());

      // Restore amounts after initialization if they existed
      if (hasExistingAmounts) {
        AppLogger.debug(
          '♻️ Restoring preserved amounts: send=$existingSendAmount, receive=$existingReceiveAmount',
        );
        state = state.copyWith(
          sendAmount: existingSendAmount,
          receiverAmount: existingReceiveAmount,
        );
      }

      // Restore receiver country/currency after initialization if they existed
      if (hasExistingReceiver) {
        AppLogger.debug(
          '♻️ Restoring preserved receiver: country=$existingReceiverCountry, currency=$existingReceiverCurrency, method=$existingDeliveryMethod',
        );
        state = state.copyWith(
          receiverCountry: existingReceiverCountry,
          receiverCurrency: existingReceiverCurrency,
          selectedDeliveryMethod: existingDeliveryMethod,
        );
      }

      if (hasExistingSend) {
        AppLogger.debug(
          '♻️ Restoring preserved sender: country=$existingSendCountry, currency=$existingSendCurrency',
        );
        state = state.copyWith(
          sendCountry: existingSendCountry,
          sendCurrency: existingSendCurrency,
        );
      }

      if (state.channels.isEmpty) {
        _useFallbackData();
      }

      _isInitialized = true;
      AppLogger.info('✅ SendViewModel initialized successfully');
    } catch (e) {
      // If API fails, keep default currencies
      AppLogger.error('❌ Failed to initialize SendViewModel: $e');
      _isInitialized = false; // Allow retry
    } finally {
      _isInitializing = false;
      state = state.copyWith(isLoading: false);
      _calculateTotal(); // Calculate initial total
    }
  }

  /// Debounced loading state update to prevent rapid flickering
  void _updateRatesLoadingState(bool isLoading) {
    // Cancel any existing timer
    _loadingDebounceTimer?.cancel();

    if (isLoading) {
      // Show loading immediately when starting
      state = state.copyWith(isRatesLoading: true, showRatesLoading: true);
    } else {
      // Debounce hiding the loading state
      _loadingDebounceTimer = Timer(_loadingDebounceDelay, () {
        if (mounted) {
          state = state.copyWith(
            isRatesLoading: false,
            showRatesLoading: false,
          );
        }
      });
    }
  }

  void _resetSendState() {
    // Reset all form fields to default values
    // This should only be called explicitly (e.g., after successful transaction)
    state = state.copyWith(
      sendAmount: '',
      receiverAmount: '',
      fee: '0.00',
      totalToPay: '0.00',
      exchangeRate:
          '', // Will be set by _updateExchangeRate after currencies are set
    );
  }

  /// Public method to reset the send form (call this after successful transaction)
  void resetSendForm() {
    AppLogger.debug('🔄 Resetting send form');
    _resetSendState();
    _calculateTotal();
  }

  Future<void> _setupDefaultSelections() async {
    AppLogger.debug('Setting up default selections');

    final hasExistingReceiver =
        state.receiverCountry.isNotEmpty &&
        state.receiverCurrency.isNotEmpty;

    final hasExistingSend =
        state.sendCountry.isNotEmpty &&
        state.sendCurrency.isNotEmpty &&
        !(state.sendCurrency == 'NGN' &&
            state.sendCountry == 'NG' &&
            state.receiverCurrency == 'NGN');

    if (!hasExistingSend) {
      // Set default send currency to NGN when no explicit pay-with was configured
      await _setDefaultSendCurrency('NG', 'NGN');
    }

    // Only set default receive currency if not already set (preserve explicitly set values)

    if (!hasExistingReceiver) {
      // Set default receive currency to NG-NGN only if no receiver is set
      await _setDefaultReceiveCurrency('NG', 'NGN');
    } else {
      AppLogger.debug(
        'Preserving existing receiver: ${state.receiverCountry} - ${state.receiverCurrency}',
      );
    }

    // Set default sender channel ID
    _setDefaultSenderChannelId();

    // Fetch rates for both currencies in parallel to avoid multiple sequential calls
    await _fetchRatesForBothCurrencies();
  }

  Future<void> _setDefaultSendCurrency(String country, String currency) async {
    AppLogger.debug('Setting default send currency: $country - $currency');

    // Find the first available sender delivery method for this country-currency combination
    String? firstSenderDeliveryMethod;

    final availableChannels =
        state.channels
            .where(
              (channel) =>
                  channel.country == country &&
                  channel.currency == currency &&
                  channel.status == 'active' &&
                  (channel.rampType == 'deposit' ||
                      channel.rampType == 'receive' ||
                      channel.rampType == 'funding'),
            )
            .toList();

    if (availableChannels.isNotEmpty) {
      // Get unique channel types and sort them alphabetically
      final channelTypes =
          availableChannels
              .map((channel) => channel.channelType ?? 'Unknown')
              .toSet()
              .toList()
            ..sort();

      if (channelTypes.isNotEmpty) {
        firstSenderDeliveryMethod = channelTypes.first;
      }
    }

    state = state.copyWith(
      sendCountry: country,
      sendCurrency: currency,
      selectedSenderDeliveryMethod: firstSenderDeliveryMethod ?? '',
    );

    // Don't fetch rates here - will be done in _fetchRatesForBothCurrencies
  }

  Future<void> _setDefaultReceiveCurrency(
    String country,
    String currency,
  ) async {
    AppLogger.debug('Setting default receive currency: $country - $currency');

    // Find the first available delivery method from backend channels
    String? firstDeliveryMethod;

    final availableChannels =
        state.channels
            .where(
              (channel) =>
                  channel.country == country &&
                  channel.currency == currency &&
                  channel.status == 'active' &&
                  (channel.rampType == 'withdrawal' ||
                      channel.rampType == 'withdraw' ||
                      channel.rampType == 'payout'),
            )
            .toList();

    if (availableChannels.isNotEmpty) {
      // Get unique channel types
      final channelTypes =
          availableChannels
              .map((channel) => channel.channelType ?? 'Unknown')
              .toSet()
              .toList();

      // For NGN to NGN transfers, always prioritize Dayfi Tag
      final isNgnToNgn = state.sendCurrency == 'NGN' && currency == 'NGN';
      if (isNgnToNgn) {
        // Only set to Dayfi Tag if no delivery method is selected yet
        if (state.selectedDeliveryMethod.isEmpty) {
          firstDeliveryMethod = 'dayfi_tag';
        }
      } else {
        // Otherwise, sort alphabetically and use first
        channelTypes.sort();
        firstDeliveryMethod = channelTypes.first;
      }
    } else {
      // Even if no channels available, for NGN to NGN, default to Dayfi Tag only if not already selected
      final isNgnToNgn = state.sendCurrency == 'NGN' && currency == 'NGN';
      if (isNgnToNgn && state.selectedDeliveryMethod.isEmpty) {
        firstDeliveryMethod = 'dayfi_tag';
      }
    }

    if (firstDeliveryMethod != null) {
      state = state.copyWith(
        receiverCountry: country,
        receiverCurrency: currency,
        selectedDeliveryMethod: firstDeliveryMethod,
      );
    } else {
      state = state.copyWith(
        receiverCountry: country,
        receiverCurrency: currency,
      );
    }

    // Don't fetch rates here - will be done in _fetchRatesForBothCurrencies
  }

  void _setDefaultSenderChannelId() {
    AppLogger.debug('Setting default sender channel ID');

    // Find the first available deposit channel for Nigeria NGN
    final depositChannels =
        state.channels
            .where(
              (channel) =>
                  channel.country == 'NG' &&
                  channel.currency == 'NGN' &&
                  channel.status == 'active' &&
                  channel.rampType == 'deposit',
            )
            .toList();

    if (depositChannels.isNotEmpty) {
      final defaultChannelId = depositChannels.first.id;
      AppLogger.debug('Default sender channel ID: $defaultChannelId');
      // print('🔵 SENDER CHANNEL ID SET: $defaultChannelId');

      state = state.copyWith(selectedSenderChannelId: defaultChannelId);
    } else {
      AppLogger.warning('No deposit channels found for NG-NGN');
      // print('🔴 NO SENDER CHANNEL FOUND');
    }
  }

  /// Fetch rates for both send and receive currencies in parallel
  Future<void> _fetchRatesForBothCurrencies() async {
    if (!await _hasActiveSession()) {
      AppLogger.info('⏭️ Skipping rates fetch: no active session');
      return;
    }
    try {
      AppLogger.debug(
        'Fetching rates for both currencies: ${state.sendCurrency} and ${state.receiverCurrency}',
      );
      _updateRatesLoadingState(true);

      await _ensureWalletExchangeRates();

      // Fetch corridor rates in parallel after wallet matrix is ready.
      final futures = <Future>[];

      if (state.sendCurrency.isNotEmpty) {
        futures.add(_fetchRates(state.sendCurrency));
      }

      if (state.receiverCurrency.isNotEmpty &&
          state.receiverCurrency != state.sendCurrency) {
        futures.add(_fetchRates(state.receiverCurrency));
      }

      if (futures.isNotEmpty) {
        await Future.wait(futures);
      }

      // Same-currency pairs only fetch one rate payload; mirror it so stale
      // receive rates (e.g. default NGN) are not used for display or FX math.
      if (state.sendCurrency.isNotEmpty &&
          state.sendCurrency == state.receiverCurrency &&
          state.sendCurrencyRates != null) {
        state = state.copyWith(receiveCurrencyRates: state.sendCurrencyRates);
      }

      // Update exchange rate after all rates are fetched
      _updateExchangeRate();
    } catch (e) {
      AppLogger.error('Error fetching rates for both currencies: $e');
    } finally {
      _updateRatesLoadingState(false);
    }
  }

  /// Fetch currencies with retry mechanism
  Future<void> _fetchAvailableCurrenciesWithRetry() async {
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      if (!await _hasActiveSession()) {
        AppLogger.info('🛑 Aborting currency retries: no active session');
        return;
      }
      try {
        AppLogger.debug('🔄 Fetching currencies attempt $attempt/$_maxRetries');
        await _fetchAvailableCurrencies();
        return; // Success, exit retry loop
      } catch (e) {
        if (_isUnauthorizedError(e) || !await _hasActiveSession()) {
          AppLogger.info(
            '🛑 Stopping currency retries after unauthorized/session loss',
          );
          return;
        }
        AppLogger.warning('⚠️ Attempt $attempt failed: $e');

        if (attempt < _maxRetries) {
          AppLogger.debug(
            '⏳ Waiting ${_retryDelay.inSeconds}s before retry...',
          );
          await Future.delayed(_retryDelay);
        } else {
          AppLogger.error('❌ All retry attempts failed, using fallback data');
          // Use fallback data instead of throwing
          _useFallbackData();
        }
      }
    }
  }

  Future<void> _fetchAvailableCurrencies() async {
    try {
      AppLogger.debug('Fetching currencies from channels API');

      // Check cache first
      if (_cachedChannels != null &&
          _channelsCacheTime != null &&
          DateTime.now().difference(_channelsCacheTime!) <
              _cacheValidityDuration) {
        AppLogger.debug('Using cached channels data');
        _processChannelsData(_cachedChannels!);
        return;
      }

      final response = await _paymentService.fetchChannels();

      // Check if we have valid data and channels
      if (response.data?.channels != null &&
          response.data!.channels!.isNotEmpty) {
        final channels = response.data!.channels!;

        // Only proceed if the API call was successful
        if (!response.error) {
          // Extract unique currencies from channels and cast to String
          final currencies =
              channels
                  .map((channel) => channel.currency)
                  .where((currency) => currency != null && currency.isNotEmpty)
                  .cast<String>() // Cast to String to fix the type error
                  .toSet()
                  .toList()
                ..sort();

          // Update cache
          _cachedChannels = channels;
          _channelsCacheTime = DateTime.now();

          // Fetch networks alongside channels
          await _fetchPaymentNetworks();

          state = state.copyWith(
            availableCurrencies: currencies,
            channels: channels,
          );
          AppLogger.info(
            'Updated state with ${currencies.length} currencies and ${channels.length} channels',
          );
        } else {
          AppLogger.warning('Channels API call failed: ${response.message}');
          throw Exception('Failed to fetch channels: ${response.message}');
        }
      } else {
        AppLogger.warning('No channels data available');
        throw Exception('No channels data available');
      }
    } catch (e) {
      AppLogger.error('Error fetching currencies: $e');
      rethrow;
    }
  }

  /// Use fallback data when API fails
  void _useFallbackData() {
    AppLogger.info('🆘 Using fallback data due to API failures');

    // Keep Dayfi Tag + NGN bank synthetics so send flows still work offline.
    _processChannelsData([]);

    final fallbackCurrencies = {
      ...kCoreSendCurrencies,
      for (final c in kYellowCardOffRampCorridors) c.currency,
    }.toList()
      ..sort();

    state = state.copyWith(
      availableCurrencies: fallbackCurrencies,
      networks: [],
    );

    AppLogger.info('Fallback data set with synthetic channels');
  }

  Future<void> prefetchNigerianBanks() async {
    if (!await _hasActiveSession()) return;
    try {
      final banks = await NgnBanksCache.load(_paymentService);
      AppLogger.info('Prefetched ${banks.length} Nigerian banks (Flutterwave)');
    } catch (e) {
      AppLogger.warning('NGN banks prefetch skipped: $e');
    }
  }

  /// Flutterwave NGN banks — never mixed into [state.networks] (YC only).
  Future<List<Network>> loadNigerianBanks({bool forceRefresh = false}) async {
    if (!forceRefresh && NgnBanksCache.hasFreshCache) {
      return NgnBanksCache.cached!;
    }
    return NgnBanksCache.load(_paymentService);
  }

  /// Resolve bank/network label from YC networks or Flutterwave NG cache.
  Network? findNetworkById(String? networkId) {
    if (networkId == null || networkId.isEmpty) return null;
    for (final n in state.networks) {
      if (n.id == networkId) return n;
    }
    final ng = NgnBanksCache.cached;
    if (ng != null) {
      for (final n in ng) {
        if (n.id == networkId) return n;
        final code = n.code;
        if (code is String && code == networkId) return n;
      }
    }
    return null;
  }

  /// Resolve Yellow Card payout channel for bank/mobile sends.
  String? resolveRecipientChannelId({
    required String receiveCountry,
    required String receiveCurrency,
    required String deliveryMethod,
    String? networkId,
    String? existingChannelId,
  }) {
    final explicit = existingChannelId?.trim();
    if (explicit != null && explicit.isNotEmpty) return explicit;

    final network = findNetworkById(networkId);
    if (network?.channelIds != null && network!.channelIds!.isNotEmpty) {
      for (final cid in network.channelIds!) {
        final id = cid.trim();
        if (id.isEmpty) continue;
        if (state.channels.any((c) => c.id == id)) return id;
      }
      final first = network.channelIds!.first.trim();
      if (first.isNotEmpty) return first;
    }

    final method = deliveryMethod.toLowerCase();
    final isBank =
        method == 'bank' ||
        method == 'bank_transfer' ||
        method == 'p2p' ||
        method == 'eft' ||
        method == 'peer_to_peer' ||
        method == 'peer-to-peer';

    for (final c in state.channels) {
      final id = c.id?.trim();
      if (id == null || id.isEmpty) continue;
      if (c.country != receiveCountry || c.currency != receiveCurrency) {
        continue;
      }
      if (c.status != null && c.status != 'active') continue;
      final ramp = (c.rampType ?? '').toLowerCase();
      if (!['withdrawal', 'withdraw', 'payout'].contains(ramp)) continue;
      final type = (c.channelType ?? '').toLowerCase();
      if (isBank) {
        if (['bank', 'bank_transfer', 'p2p', 'eft'].contains(type)) {
          return id;
        }
      } else if (type == method ||
          ['mobile_money', 'momo', 'phone', 'mobile'].contains(type)) {
        return id;
      }
    }

    if (receiveCountry == 'NG' && receiveCurrency == 'NGN' && isBank) {
      return 'ngn_bank_flutterwave';
    }

    return null;
  }

  Future<void> _fetchPaymentNetworks() async {
    try {
      AppLogger.debug('Fetching Yellow Card networks from API');
      final response = await _paymentService.fetchNetworks();
      if (response.error) {
        AppLogger.warning('Networks API error: ${response.message}');
        return;
      }
      final list = response.data?.networks;
      if (list != null && list.isNotEmpty) {
        state = state.copyWith(networks: list);
        AppLogger.info('Updated state with ${list.length} payment networks');
      } else {
        AppLogger.warning('No networks in API response');
      }
    } catch (e) {
      AppLogger.error('Error fetching payment networks: $e');
    }
  }

  /// Reload networks (e.g. before Add Recipient for ZA/KE).
  Future<void> refreshPaymentNetworks() async {
    await _fetchPaymentNetworks();
  }

  Future<void> _fetchFees() async {
    if (!await _hasActiveSession()) {
      AppLogger.info('⏭️ Skipping fees fetch: no active session');
      return;
    }
    try {
      AppLogger.debug('🔄 Starting to fetch fees from API');
      final response = await _paymentService.fetchFees();
      AppLogger.debug(
        '🔄 Fees API response received: success=${response.success}',
      );

      if (response.success) {
        state = state.copyWith(feesData: response.data);
        AppLogger.debug(
          'Updated state with fees data: ${response.data.transfer.dayfiToDayfi}, ${response.data.transfer.dayfiToBank}',
        );
        AppLogger.info('✅ Updated state with fees data');
        // Recalculate fee after fetching fees data
        _calculateFee();
      } else {
        AppLogger.warning('⚠️ Fees API call failed: ${response.message}');
        // Don't throw error - fees are optional, continue with default fee
      }
    } catch (e) {
      AppLogger.error('❌ Error fetching fees: $e');
      // Don't rethrow - fees are optional, continue with default fee
    }
  }

  void _calculateFee() {
    AppLogger.debug(
      '🔄 _calculateFee called, feesData is null: ${state.feesData == null}',
    );

    String fee = '0.00';

    // Determine fee based on delivery method
    final deliveryMethod = state.selectedDeliveryMethod.toLowerCase();
    final isDayfiTagOrId =
        deliveryMethod == 'dayfi_tag' ||
        deliveryMethod == 'dayfi_id' ||
        deliveryMethod == 'dayfi' ||
        deliveryMethod.contains('dayfi');

    AppLogger.debug(
      'Calculating fee for delivery method: "${state.selectedDeliveryMethod}", isDayfiTagOrId: $isDayfiTagOrId',
    );

    if (isDayfiTagOrId) {
      fee = '0.00';
      AppLogger.debug('Dayfi Tag/ID transfer - fee: \$0 (FREE)');
    } else {
      final apiFeeUsd = state.feesData?.transfer.dayfiToBank;
      final feeUsd =
          (apiFeeUsd != null && apiFeeUsd > 0)
              ? apiFeeUsd.toDouble()
              : SendCopy.transferFeeUsd;
      fee = feeUsd.toStringAsFixed(2);
      AppLogger.debug('Bank/other delivery method - fee: \$$fee');
    }

    state = state.copyWith(fee: fee);
    _calculateTotal();
  }

  /// Platform fee in USD (from backend / [SendCopy.transferFeeUsd]).
  double get transferFeeUsd {
    final parsed = double.tryParse(
      state.fee.replaceAll(RegExp(r'[^\d.]'), ''),
    );
    return parsed ?? SendCopy.transferFeeUsd;
  }

  /// Fee converted into the current send / pay-with currency for totals.
  double get feeInSendCurrency => _feeInSendCurrency();

  /// True when Enter Amount can proceed without Yellow Card FX (same fiat pair).
  bool get isSameFiatCurrency =>
      state.sendCurrency.isNotEmpty &&
      state.receiverCurrency.isNotEmpty &&
      state.sendCurrency.toUpperCase() == state.receiverCurrency.toUpperCase();

  /// Dayfi Tag and same-currency bank/P2P do not require Yellow Card channels.
  bool get hasRequiredChannels {
    final method = state.selectedDeliveryMethod.toLowerCase();
    if (method == 'dayfi_tag') return true;
    if (method == 'crypto' || method == 'cryptocurrency') return true;
    if (isSameFiatCurrency &&
        (method == 'bank' ||
            method == 'bank_transfer' ||
            method.contains('bank'))) {
      return true;
    }
    return state.channels.isNotEmpty;
  }

  /// Process channels data (used for both fresh API calls and cached data)
  void _processChannelsData(List<Channel> channels) {
    // Add synthetic Dayfi Tag channel for NGN
    final hasDayfiTag = channels.any(
      (c) => c.channelType?.toLowerCase() == 'dayfi_tag',
    );
    if (!hasDayfiTag) {
      channels.add(
        Channel(
          channelType: 'dayfi_tag',
          country: 'NG',
          currency: 'NGN',
          status: 'active',
          rampType: 'withdrawal',
          min: 0,
          max: 999999999,
          id: 'dayfi_tag_synthetic',
        ),
      );
    }

    for (final entry in [
      ('USD', 'US', 'dayfi_tag_usd'),
      ('EUR', 'EU', 'dayfi_tag_eur'),
      ('GBP', 'GB', 'dayfi_tag_gbp'),
    ]) {
      final cur = entry.$1;
      final country = entry.$2;
      final id = entry.$3;
      final hasTag = channels.any(
        (c) =>
            c.channelType?.toLowerCase() == 'dayfi_tag' && c.currency == cur,
      );
      if (!hasTag) {
        channels.add(
          Channel(
            channelType: 'dayfi_tag',
            country: country,
            currency: cur,
            status: 'active',
            rampType: 'withdrawal',
            min: 0,
            max: 999999999,
            id: id,
          ),
        );
      }
    }

    final hasNgnBank = channels.any(
      (c) =>
          c.currency == 'NGN' &&
          c.country == 'NG' &&
          {
            'bank',
            'bank_transfer',
            'p2p',
            'peer_to_peer',
          }.contains(c.channelType?.toLowerCase()),
    );
    if (!hasNgnBank) {
      channels.add(
        Channel(
          channelType: 'bank_transfer',
          country: 'NG',
          currency: 'NGN',
          status: 'active',
          rampType: 'withdrawal',
          min: 100,
          max: 5000000,
          id: 'ngn_bank_flutterwave',
        ),
      );
    }

    mergeYellowCardFallbackChannels(channels);

    final currencies =
        channels
            .where(
              (channel) =>
                  channel.currency != null && channel.currency!.isNotEmpty,
            )
            .map((channel) => channel.currency!)
            .toSet()
            .toList()
          ..sort();

    state = state.copyWith(availableCurrencies: currencies, channels: channels);
    AppLogger.info(
      'Processed ${currencies.length} currencies and ${channels.length} channels',
    );

    if (isSameFiatCurrency) {
      _updateExchangeRate();
    }
  }

  /// Find the network that contains the given channel ID
  Network? _findNetworkForChannel(String? channelId) {
    if (channelId == null || state.networks.isEmpty) return null;

    for (final network in state.networks) {
      if (network.channelIds?.contains(channelId) == true) {
        return network;
      }
    }
    return null;
  }

  /// Get the network name for a given channel
  String? getNetworkNameForChannel(Channel channel) {
    final network = _findNetworkForChannel(channel.id);
    if (network == null) return null;

    // Return the network name
    return network.name;
  }

  Future<void> updateSendCountry(String country, String currency) async {
    // Find the first available sender delivery method for this country-currency combination
    String? firstSenderDeliveryMethod;
    String? selectedSenderChannelId;

    final availableChannels =
        state.channels
            .where(
              (channel) =>
                  channel.country == country &&
                  channel.currency == currency &&
                  channel.status == 'active' &&
                  (channel.rampType == 'deposit' ||
                      channel.rampType == 'receive' ||
                      channel.rampType == 'funding'),
            )
            .toList();

    if (availableChannels.isNotEmpty) {
      // Get unique channel types and sort them alphabetically
      final channelTypes =
          availableChannels
              .map((channel) => channel.channelType ?? 'Unknown')
              .toSet()
              .toList()
            ..sort();

      if (channelTypes.isNotEmpty) {
        firstSenderDeliveryMethod = channelTypes.first;
      }

      // Set the first available channel as the sender channel ID
      selectedSenderChannelId = availableChannels.first.id;
    }

    // Check if we need to update recipient delivery method for NGN to NGN
    // Only set default if no delivery method is already selected
    String? updatedRecipientDeliveryMethod;
    final isNgnToNgn = currency == 'NGN' && state.receiverCurrency == 'NGN';

    if (isNgnToNgn &&
        state.receiverCountry.isNotEmpty &&
        state.selectedDeliveryMethod.isEmpty) {
      // Only set Dayfi Tag for NGN to NGN transfers if no method is already selected
      updatedRecipientDeliveryMethod = 'dayfi_tag';
      AppLogger.debug(
        '🔄 NGN to NGN detected in updateSendCountry, setting Dayfi Tag (no method selected)',
      );
    }

    state = state.copyWith(
      sendCountry: country,
      sendCurrency: currency,
      selectedSenderDeliveryMethod: firstSenderDeliveryMethod ?? '',
      selectedSenderChannelId: selectedSenderChannelId ?? '',
      selectedDeliveryMethod:
          updatedRecipientDeliveryMethod ?? state.selectedDeliveryMethod,
    );

    // Recalculate fee if delivery method changed
    if (updatedRecipientDeliveryMethod != null) {
      _calculateFee();
    }

    // Rates hydrate in background — don't block delivery-method UI.
    unawaited(_fetchRatesForBothCurrencies());
  }

  Future<void> updateReceiveCountry(String country, String currency) async {
    AppLogger.debug(
      '🔄 updateReceiveCountry called: country=$country, currency=$currency',
    );
    AppLogger.debug(
      '🔄 Current state: send=${state.sendCurrency}, receive=${state.receiverCurrency}',
    );

    // Normalize country code to uppercase
    final normalizedCountry = country.toUpperCase();

    // Find the first available delivery method from backend channels
    String? firstDeliveryMethod;

    final availableChannels =
        state.channels
            .where(
              (channel) =>
                  channel.country == normalizedCountry &&
                  channel.currency == currency &&
                  channel.status == 'active' &&
                  (channel.rampType == 'withdrawal' ||
                      channel.rampType == 'withdraw' ||
                      channel.rampType == 'payout' ||
                      channel.rampType == 'deposit' ||
                      channel.rampType == 'receive'),
            )
            .toList();

    AppLogger.debug(
      '🔄 Found ${availableChannels.length} available channels for $normalizedCountry-$currency',
    );

    if (availableChannels.isNotEmpty) {
      // Get unique channel types
      final channelTypes =
          availableChannels
              .map((channel) => channel.channelType ?? 'Unknown')
              .toSet()
              .toList();

      if (channelTypes.isNotEmpty) {
        // For NGN to NGN transfers, prioritize Dayfi Tag only if no method selected
        final isNgnToNgn = state.sendCurrency == 'NGN' && currency == 'NGN';
        if (isNgnToNgn && state.selectedDeliveryMethod.isEmpty) {
          // Only select Dayfi Tag for NGN to NGN if no method is already selected
          firstDeliveryMethod = 'dayfi_tag';
          AppLogger.debug(
            '🔄 NGN to NGN detected, selecting Dayfi Tag (no method selected)',
          );
        } else if (!isNgnToNgn) {
          // For non-NGN to NGN, sort alphabetically and use first
          channelTypes.sort();
          firstDeliveryMethod = channelTypes.first;
        }
        // If isNgnToNgn and a method is already selected, don't override it
      }
    } else {
      // Even if no channels available, for NGN to NGN, default to Dayfi Tag only if not selected
      final isNgnToNgn = state.sendCurrency == 'NGN' && currency == 'NGN';
      if (isNgnToNgn && state.selectedDeliveryMethod.isEmpty) {
        firstDeliveryMethod = 'dayfi_tag';
        AppLogger.debug(
          '🔄 NGN to NGN detected, no channels but selecting Dayfi Tag (no method selected)',
        );
      }
    }

    state = state.copyWith(
      receiverCountry: normalizedCountry,
      receiverCurrency: currency,
      selectedDeliveryMethod:
          firstDeliveryMethod ?? state.selectedDeliveryMethod,
    );

    // Recalculate fee based on new delivery method
    _calculateFee();

    AppLogger.debug(
      '🔄 Updated state: send=${state.sendCurrency}, receive=${state.receiverCurrency}',
    );

    // Rates hydrate in background — don't block delivery-method UI.
    unawaited(_fetchRatesForBothCurrencies());
  }

  /// Native-chain amount entry (e.g. XLM reserve). Pair with
  /// [restoreSendCurrencyAfterStablecoinAmountStep] when popping the amount screen.
  void setSendCurrencyForStablecoinAmountStep(String currencyCode) {
    final code = currencyCode.trim().toUpperCase();
    if (code.isEmpty) return;
    state = state.copyWith(sendCurrency: code);
  }

  void restoreSendCurrencyAfterStablecoinAmountStep(String previousCode) {
    final code = previousCode.trim();
    if (code.isEmpty) return;
    state = state.copyWith(sendCurrency: code);
  }

  void updateSendAmount(String amount) {
    AppLogger.debug('updateSendAmount: $amount');
    // Clean the amount - remove commas and whitespace
    final cleanAmount = amount.replaceAll(RegExp(r'[,\s]'), '').trim();

    // If empty, set to empty string
    if (cleanAmount.isEmpty) {
      state = state.copyWith(sendAmount: '');
      state = state.copyWith(
        receiverAmount: '',
      ); // Clear receive amount when send is empty
      _calculateTotal();
      return;
    }

    state = state.copyWith(sendAmount: cleanAmount);
    _updateReceiveAmountFromSend();
    _calculateTotal();
  }

  void updateReceiveAmount(String amount) {
    // Clean the amount - remove commas and whitespace
    final cleanAmount = amount.replaceAll(RegExp(r'[,\s]'), '').trim();

    // If empty, set to empty string
    if (cleanAmount.isEmpty) {
      state = state.copyWith(receiverAmount: '');
      state = state.copyWith(
        sendAmount: '',
      ); // Clear send amount when receive is empty
      _calculateTotal();
      return;
    }

    state = state.copyWith(receiverAmount: cleanAmount);
    _updateSendAmountFromReceive();
    _calculateTotal();
  }

  void _updateReceiveAmountFromSend() {
    // Clean the amount - remove commas and whitespace
    final cleanAmount =
        state.sendAmount.replaceAll(RegExp(r'[,\s]'), '').trim();

    if (cleanAmount.isEmpty) {
      state = state.copyWith(receiverAmount: '');
      return;
    }

    final sendAmount = double.tryParse(cleanAmount);
    AppLogger.debug('_updateReceiveAmountFromSend: sendAmount=$sendAmount');
    if (sendAmount != null && sendAmount > 0) {
      // Special case: if both currencies are the same, use 1:1 rate
      if (state.sendCurrency == state.receiverCurrency) {
        AppLogger.debug(
          'Same currency detected in _updateReceiveAmountFromSend: 1:1 rate',
        );
        state = state.copyWith(receiverAmount: sendAmount.toStringAsFixed(2));
        AppLogger.debug('Updated receiverAmount to: ${state.receiverAmount}');
        return;
      }

      final exchangeRate = _calculateExchangeRate();
      AppLogger.debug('Exchange rate: $exchangeRate');
      if (exchangeRate != null) {
        final convertedAmount = sendAmount * exchangeRate;
        AppLogger.debug('Converted amount: $convertedAmount');
        state = state.copyWith(
          receiverAmount: convertedAmount.toStringAsFixed(2),
        );
        AppLogger.debug('Updated receiverAmount to: ${state.receiverAmount}');
      } else {
        AppLogger.warning('Exchange rate is null');
        state = state.copyWith(receiverAmount: '');
      }
    } else {
      AppLogger.warning('Send amount is null or <= 0');
      state = state.copyWith(receiverAmount: '');
    }
  }

  void _updateSendAmountFromReceive() {
    // Clean the amount - remove commas and whitespace
    final cleanAmount =
        state.receiverAmount.replaceAll(RegExp(r'[,\s]'), '').trim();

    if (cleanAmount.isEmpty) {
      state = state.copyWith(sendAmount: '');
      return;
    }

    final receiveAmount = double.tryParse(cleanAmount);
    if (receiveAmount != null && receiveAmount > 0) {
      // Special case: if both currencies are the same, use 1:1 rate
      if (state.sendCurrency == state.receiverCurrency) {
        state = state.copyWith(sendAmount: receiveAmount.toStringAsFixed(2));
        return;
      }

      final exchangeRate = _calculateExchangeRate();
      if (exchangeRate != null && exchangeRate > 0) {
        final convertedAmount = receiveAmount / exchangeRate;
        state = state.copyWith(sendAmount: convertedAmount.toStringAsFixed(2));
      } else {
        state = state.copyWith(sendAmount: '');
      }
    } else {
      state = state.copyWith(sendAmount: '');
    }
  }

  void updateDeliveryMethod(String method) {
    state = state.copyWith(selectedDeliveryMethod: method);
    _calculateFee();
  }

  void updateSenderDeliveryMethod(String method) {
    state = state.copyWith(selectedSenderDeliveryMethod: method);
  }

  /// Transfer fee is always denominated in USD; convert for pay-with currency.
  double _feeInSendCurrency() {
    final feeUsd = double.tryParse(
      state.fee.replaceAll(RegExp(r'[^\d.]'), ''),
    );
    if (feeUsd == null || feeUsd <= 0) return 0;

    final send = state.sendCurrency.toUpperCase();
    if (send == 'USD') return feeUsd;

    final sendPerUsd = _platformCrossRate('USD', send);
    if (sendPerUsd != null && sendPerUsd > 0) {
      return feeUsd * sendPerUsd;
    }
    return feeUsd;
  }

  void _calculateTotal() {
    final sendAmount = double.tryParse(
      state.sendAmount.replaceAll(RegExp(r'[^\d.]'), ''),
    );
    final feeInSend = _feeInSendCurrency();

    if (sendAmount != null && sendAmount > 0) {
      final total = sendAmount + feeInSend;
      state = state.copyWith(totalToPay: total.toStringAsFixed(2));
      AppLogger.debug(
        'Calculated total: $sendAmount ${state.sendCurrency} + \$${state.fee} fee ($feeInSend) = $total',
      );
    } else {
      state = state.copyWith(totalToPay: '0.00');
    }
  }

  // Getter to access the current exchange rate
  double? get currentExchangeRate => _calculateExchangeRate();

  // Getter to get formatted exchange rate string
  String get formattedExchangeRate {
    final rate = _calculateExchangeRate();
    if (rate != null) {
      final sendCode = state.sendCurrencyRates?['code'] ?? state.sendCurrency;
      final receiveCode =
          state.receiveCurrencyRates?['code'] ?? state.receiverCurrency;

      // Get currency symbols instead of codes
      final sendSymbol = _getCurrencySymbol(sendCode);
      final receiveSymbol = _getCurrencySymbol(receiveCode);

      return '$sendSymbol${1.toStringAsFixed(0)} = $receiveSymbol${rate.toStringAsFixed(2)}';
    }
    return 'Rate not available';
  }

  // Get minimum limit for selected send country and currency
  double? get sendMinimumLimit {
    final sendChannels =
        state.channels
            .where(
              (channel) =>
                  channel.country == state.sendCountry &&
                  channel.currency == state.sendCurrency &&
                  channel.status == 'active' &&
                  (channel.rampType == 'deposit' ||
                      channel.rampType == 'receive' ||
                      channel.rampType == 'funding'),
            )
            .toList();

    if (sendChannels.isEmpty) return null;

    // Get the minimum limit from all available channels
    final minLimits =
        sendChannels
            .map((channel) => channel.min ?? 0.0)
            .where((min) => min > 0)
            .toList();

    if (minLimits.isEmpty) return null;

    return minLimits.reduce((a, b) => a < b ? a : b);
  }

  SendAmountValidation get sendAmountValidation {
    final cleanSend = state.sendAmount.replaceAll(RegExp(r'[,\s]'), '').trim();
    if (cleanSend.isEmpty) {
      return SendAmountValidation.invalid('Enter valid amount');
    }

    final sendAmount = double.tryParse(cleanSend);
    if (sendAmount == null || sendAmount <= 0) {
      return SendAmountValidation.invalid('Enter valid amount');
    }

    final cleanReceive =
        state.receiverAmount.replaceAll(RegExp(r'[,\s]'), '').trim();
    final receiveAmount =
        cleanReceive.isEmpty ? null : double.tryParse(cleanReceive);

    return SendAmountLimits.validate(
      deliveryMethod: state.selectedDeliveryMethod,
      sendCurrency: state.sendCurrency,
      receiveCountry: state.receiverCountry,
      receiveCurrency: state.receiverCurrency,
      sendAmount: sendAmount,
      receiveAmount: receiveAmount,
    );
  }

  // Check if send amount meets minimum requirement
  bool get isSendAmountValid => sendAmountValidation.isValid;

  Future<void> _ensureWalletExchangeRates() async {
    if (_walletExchangeRates != null &&
        _walletRatesCacheTime != null &&
        DateTime.now().difference(_walletRatesCacheTime!) <
            _walletRatesCacheValidityDuration) {
      return;
    }
    try {
      _walletExchangeRates = await _walletService.fetchWalletExchangeRates();
      _walletRatesCacheTime = DateTime.now();
    } catch (e) {
      AppLogger.error('Failed to fetch wallet exchange rates: $e');
    }
  }

  double? _platformCrossRate(String from, String to) {
    final fromCode = from.toUpperCase();
    final toCode = to.toUpperCase();
    if (fromCode == toCode) return 1.0;

    final rates = _walletExchangeRates?['rates'];
    if (rates is! Map) return null;

    final direct = rates['${fromCode}_$toCode'];
    if (direct != null) {
      final parsed = double.tryParse(direct.toString());
      if (parsed != null && parsed > 0) return parsed;
    }

    final inverse = rates['${toCode}_$fromCode'];
    if (inverse != null) {
      final parsed = double.tryParse(inverse.toString());
      if (parsed != null && parsed > 0) return 1 / parsed;
    }

    return null;
  }

  String _exchangeRateDisplayText(double rate, String sendCode, String receiveCode) {
    final sendSymbol = _getCurrencySymbol(sendCode);
    final receiveSymbol = _getCurrencySymbol(receiveCode);

    if (rate < 0.1) {
      final hundredRate = rate * 100;
      return '$sendSymbol${100.toStringAsFixed(0)} = $receiveSymbol${hundredRate.toStringAsFixed(2)}';
    }
    if (rate < 1.0) {
      final thousandRate = rate * 1000;
      return '$sendSymbol${1000.toStringAsFixed(0)} = $receiveSymbol${thousandRate.toStringAsFixed(2)}';
    }
    return '$sendSymbol${1.toStringAsFixed(0)} = $receiveSymbol${rate.toStringAsFixed(2)}';
  }

  bool _shouldUsePlatformWalletRates() {
    return isGlobalPayCurrency(state.sendCurrency) ||
        isGlobalPayCurrency(state.receiverCurrency);
  }

  double? _calculateExchangeRate() {
    if (_shouldUsePlatformWalletRates()) {
      final platformRate = _platformCrossRate(
        state.sendCurrency,
        state.receiverCurrency,
      );
      if (platformRate != null && platformRate > 0) {
        return platformRate;
      }
    }

    if (state.sendCurrencyRates == null || state.receiveCurrencyRates == null) {
      AppLogger.debug(
        'Missing rates: send=${state.sendCurrencyRates != null}, receive=${state.receiveCurrencyRates != null}',
      );
      return null;
    }

    // Check if rates have valid buy/sell values
    final sendHasValidRates = state.sendCurrencyRates!['hasValidRates'] == true;
    final receiveHasValidRates =
        state.receiveCurrencyRates!['hasValidRates'] == true;

    if (!sendHasValidRates || !receiveHasValidRates) {
      AppLogger.warning(
        'Currency rates not available - send: $sendHasValidRates, receive: $receiveHasValidRates',
      );
      return null;
    }

    final sendSellRate = double.tryParse(
      state.sendCurrencyRates!['sell']?.toString() ?? '',
    );
    final receiveBuyRate = double.tryParse(
      state.receiveCurrencyRates!['buy']?.toString() ?? '',
    );

    AppLogger.debug('💱 Exchange Rate Calculation:');
    AppLogger.debug(
      '   Send Currency: ${state.sendCurrency} (${state.sendCurrencyRates?['code']})',
    );
    AppLogger.debug(
      '   Receive Currency: ${state.receiverCurrency} (${state.receiveCurrencyRates?['code']})',
    );
    AppLogger.debug('   Send Sell Rate: $sendSellRate');
    AppLogger.debug('   Receive Buy Rate: $receiveBuyRate');

    if (sendSellRate == null || receiveBuyRate == null || receiveBuyRate == 0) {
      AppLogger.warning(
        'Invalid rates: sendSell=$sendSellRate, receiveBuy=$receiveBuyRate',
      );
      return null;
    }

    // To convert from send currency to receive currency:
    // We need to know how much receive currency we get for 1 send currency
    // The correct calculation should be: (Receive Buy Rate) / (Send Sell Rate)
    // This gives us: 1 Send Currency = X Receive Currency
    final rate = receiveBuyRate / sendSellRate;
    AppLogger.debug(
      '📈 Calculated rate: $receiveBuyRate / $sendSellRate = $rate',
    );
    return rate;
  }

  void _updateExchangeRate() {
    AppLogger.debug(
      '🔄 _updateExchangeRate called: send=${state.sendCurrency}, receive=${state.receiverCurrency}',
    );

    // Special case: if both currencies are the same, show 1:1 rate
    if (state.sendCurrency == state.receiverCurrency &&
        state.sendCurrency.isNotEmpty &&
        state.receiverCurrency.isNotEmpty) {
      // Use live currency codes — rate maps may still reflect a prior corridor
      // (e.g. NGN defaults) when send/receive were aligned to the same fiat.
      final sendCode = state.sendCurrency;
      final receiveCode = state.receiverCurrency;

      // Get currency symbols instead of codes
      final sendSymbol = _getCurrencySymbol(sendCode);
      final receiveSymbol = _getCurrencySymbol(receiveCode);

      AppLogger.debug('🔄 Same currency detected: $sendCode -> $receiveCode');
      AppLogger.debug('🔄 Currency symbols: $sendSymbol -> $receiveSymbol');

      // Show 1:1 rate for same currencies
      final displayText =
          '$sendSymbol${1.toStringAsFixed(0)} = $receiveSymbol${1.toStringAsFixed(0)}';

      AppLogger.debug('📊 Exchange rate display (same currency): $displayText');

      // Only update if the exchange rate has actually changed
      if (state.exchangeRate != displayText) {
        state = state.copyWith(exchangeRate: displayText);
        // Update amounts when exchange rate changes
        _updateReceiveAmountFromSend();
        _calculateTotal();
      }
      return;
    }

    AppLogger.debug(
      '🔄 Different currencies detected, proceeding with normal rate calculation',
    );

    if (_shouldUsePlatformWalletRates()) {
      final platformRate = _platformCrossRate(
        state.sendCurrency,
        state.receiverCurrency,
      );
      if (platformRate != null && platformRate > 0) {
        final sendCode = state.sendCurrency;
        final receiveCode = state.receiverCurrency;
        final displayText = _exchangeRateDisplayText(
          platformRate,
          sendCode,
          receiveCode,
        );
        AppLogger.debug('📊 Platform wallet exchange rate: $displayText');

        if (state.exchangeRate != displayText || !state.hasValidRates) {
          state = state.copyWith(
            exchangeRate: displayText,
            hasValidRates: true,
          );
          _updateReceiveAmountFromSend();
          _calculateTotal();
        }
        return;
      }
    }

    // Check if rates are available before calculating
    final sendHasValidRates = state.sendCurrencyRates?['hasValidRates'] == true;
    final receiveHasValidRates =
        state.receiveCurrencyRates?['hasValidRates'] == true;

    if (!sendHasValidRates || !receiveHasValidRates) {
      // Rates not available for one or both currencies
      final sendCode = state.sendCurrencyRates?['code'] ?? state.sendCurrency;
      final receiveCode =
          state.receiveCurrencyRates?['code'] ?? state.receiverCurrency;

      String displayText;
      if (!sendHasValidRates && !receiveHasValidRates) {
        displayText = 'Not available for $sendCode to $receiveCode';
      } else if (!sendHasValidRates) {
        displayText = 'Not available for $sendCode';
      } else {
        displayText = 'Not available for $receiveCode';
      }

      AppLogger.warning('❌ Rates not available: $displayText');

      if (state.exchangeRate != displayText || state.hasValidRates) {
        state = state.copyWith(
          exchangeRate: displayText,
          hasValidRates: false,
          // Don't update amounts when rates aren't available
          receiverAmount: '',
        );
      }
      return;
    }

    final rate = _calculateExchangeRate();
    if (rate != null) {
      final sendCode = state.sendCurrencyRates?['code'] ?? state.sendCurrency;
      final receiveCode =
          state.receiveCurrencyRates?['code'] ?? state.receiverCurrency;

      // Get currency symbols instead of codes
      final sendSymbol = _getCurrencySymbol(sendCode);
      final receiveSymbol = _getCurrencySymbol(receiveCode);

      AppLogger.debug(
        '🔄 Updating exchange rate: $sendCode -> $receiveCode, rate: $rate',
      );

      // Show a more meaningful amount for weak currencies
      // If rate is very small (< 0.1), show 100 units instead of 1
      String displayText;
      if (rate < 0.1) {
        final hundredRate = rate * 100;
        displayText =
            '$sendSymbol${100.toStringAsFixed(0)} = $receiveSymbol${hundredRate.toStringAsFixed(2)}';
      } else if (rate < 1.0) {
        final thousandRate = rate * 1000;
        displayText =
            '$sendSymbol${1000.toStringAsFixed(0)} = $receiveSymbol${thousandRate.toStringAsFixed(2)}';
      } else {
        displayText =
            '$sendSymbol${1.toStringAsFixed(0)} = $receiveSymbol${rate.toStringAsFixed(2)}';
      }

      AppLogger.debug('📊 Exchange rate display: $displayText');

      // Only update if the exchange rate has actually changed
      if (state.exchangeRate != displayText || !state.hasValidRates) {
        state = state.copyWith(exchangeRate: displayText, hasValidRates: true);
        // Update amounts when exchange rate changes
        _updateReceiveAmountFromSend();
        _calculateTotal();
      }
    } else {
      AppLogger.warning('❌ Exchange rate calculation returned null');

      // Set appropriate message when rate calculation fails
      final sendCode = state.sendCurrencyRates?['code'] ?? state.sendCurrency;
      final receiveCode =
          state.receiveCurrencyRates?['code'] ?? state.receiverCurrency;
      final displayText = 'Not available for $sendCode to $receiveCode';

      if (state.exchangeRate != displayText || state.hasValidRates) {
        state = state.copyWith(
          exchangeRate: displayText,
          hasValidRates: false,
          // Don't update amounts when rates aren't available
          receiverAmount: '',
        );
      }
    }
  }

  // Helper method to get currency symbol from currency code
  String _getCurrencySymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'NGN':
        return '₦';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'RWF':
        return 'RWF ';
      case 'GHS':
        return 'GH₵';
      case 'KES':
        return 'KSh ';
      case 'UGX':
        return 'USh ';
      case 'TZS':
        return 'TSh ';
      case 'ZAR':
        return 'R';
      default:
        return '$currencyCode ';
    }
  }

  Future<void> _fetchRates(String currency) async {
    if (!await _hasActiveSession()) {
      AppLogger.info('⏭️ Skipping rates fetch for $currency: no active session');
      return;
    }
    try {
      AppLogger.debug('Fetching rates for currency: $currency');

      // Check cache first
      if (_cachedRates.containsKey(currency) &&
          _ratesCacheTime.containsKey(currency) &&
          DateTime.now().difference(_ratesCacheTime[currency]!) <
              _ratesCacheValidityDuration) {
        AppLogger.debug('Using cached rates for $currency');
        final cachedRateData = _cachedRates[currency]!;

        if (currency == state.sendCurrency) {
          state = state.copyWith(sendCurrencyRates: cachedRateData);
        } else if (currency == state.receiverCurrency) {
          state = state.copyWith(receiveCurrencyRates: cachedRateData);
        }
        return;
      }

      final response = await _paymentService.fetchRates(currency: currency);

      AppLogger.debug('Rates response status: ${response.statusCode}');

      Map<String, dynamic>? rateData;

      if (response.statusCode == 200 && response.data != null) {
        final paymentData = response.data as PaymentData;
        final rates = paymentData.rates;

        if (rates != null && rates.isNotEmpty) {
          final rate = rates.first;

          // Check if buy and sell rates are actually available
          final hasValidRates = rate.buy != null && rate.sell != null;

          // Convert Rate object to Map for storage
          rateData = {
            'buy': hasValidRates ? rate.buy!.toString() : null,
            'sell': hasValidRates ? rate.sell!.toString() : null,
            'locale': rate.locale ?? '',
            'rateId': rate.rateId ?? '',
            'code': rate.code ?? '',
            'updatedAt': rate.updatedAt ?? '',
            'hasValidRates':
                hasValidRates, // Flag to indicate if rates are valid
          };
        } else {
          AppLogger.warning('No rates returned for currency: $currency');
          rateData = {
            'buy': null,
            'sell': null,
            'locale': '',
            'rateId': '',
            'code': currency,
            'updatedAt': '',
            'hasValidRates': false,
          };
        }
      }

      rateData ??= {
        'buy': null,
        'sell': null,
        'locale': '',
        'rateId': '',
        'code': currency,
        'updatedAt': '',
        'hasValidRates': false,
      };

      if (rateData['hasValidRates'] != true && isGlobalPayCurrency(currency)) {
        final fallback = _synthesizeGlobalPayRateData(currency);
        if (fallback != null) {
          rateData = fallback;
        }
      }

      _cachedRates[currency] = rateData;
      _ratesCacheTime[currency] = DateTime.now();

      AppLogger.debug(
        'Updated rate data for $currency - hasValidRates: ${rateData['hasValidRates']}',
      );

      if (currency == state.sendCurrency) {
        state = state.copyWith(sendCurrencyRates: rateData);
      } else if (currency == state.receiverCurrency) {
        state = state.copyWith(receiveCurrencyRates: rateData);
      }
    } catch (e) {
      AppLogger.error('Error fetching rates for $currency: $e');

      var rateData = {
        'buy': null,
        'sell': null,
        'locale': '',
        'rateId': '',
        'code': currency,
        'updatedAt': '',
        'hasValidRates': false,
      };

      if (isGlobalPayCurrency(currency)) {
        final fallback = _synthesizeGlobalPayRateData(currency);
        if (fallback != null) {
          rateData = fallback;
        }
      }

      if (currency == state.sendCurrency) {
        state = state.copyWith(sendCurrencyRates: rateData);
      } else if (currency == state.receiverCurrency) {
        state = state.copyWith(receiveCurrencyRates: rateData);
      }
    }
  }

  Map<String, dynamic>? _synthesizeGlobalPayRateData(String currency) {
    final code = currency.toUpperCase();
    if (!isGlobalPayCurrency(code)) return null;

    if (code == 'USD') {
      return {
        'buy': '1',
        'sell': '1',
        'locale': '',
        'rateId': '',
        'code': code,
        'updatedAt': '',
        'hasValidRates': true,
      };
    }

    final usdToCode = _platformCrossRate('USD', code);
    final codeToUsd = _platformCrossRate(code, 'USD');
    if (usdToCode == null || codeToUsd == null) return null;

    return {
      'buy': usdToCode.toString(),
      'sell': codeToUsd.toString(),
      'locale': '',
      'rateId': '',
      'code': code,
      'updatedAt': '',
      'hasValidRates': true,
    };
  }

  /// Check if a currency is supported (has valid exchange rates)
  bool isCurrencySupported(String currency) {
    if (currency == state.sendCurrency) {
      return state.sendCurrencyRates?['hasValidRates'] == true;
    } else if (currency == state.receiverCurrency) {
      return state.receiveCurrencyRates?['hasValidRates'] == true;
    }
    return false;
  }

  /// Check if exchange rates are available for current currency pair
  bool get hasValidExchangeRates {
    // Same currency always has valid rates (1:1)
    if (state.sendCurrency == state.receiverCurrency) {
      return true;
    }

    // Check if both currencies have valid rates
    final sendHasValidRates = state.sendCurrencyRates?['hasValidRates'] == true;
    final receiveHasValidRates =
        state.receiveCurrencyRates?['hasValidRates'] == true;

    return sendHasValidRates && receiveHasValidRates;
  }

  /// Reset initialization state to allow re-initialization
  void resetInitialization() {
    AppLogger.debug('🔄 Resetting SendViewModel initialization state');
    _isInitialized = false;
    _isInitializing = false;
  }

  /// Force re-initialization (useful for retry scenarios)
  Future<void> forceReinitialize() async {
    AppLogger.debug('🔄 Force re-initializing SendViewModel');
    resetInitialization();
    await initialize();
  }

  /// Check if the viewmodel is currently initializing
  bool get isInitializing => _isInitializing;

  /// Check if the viewmodel has been initialized
  bool get isInitialized => _isInitialized;

  Future<bool> _hasActiveSession() async {
    if (UnauthorizedNavigationGuard.isActive) return false;
    final token = await _secureStorage.read(StorageKeys.token);
    return token.trim().isNotEmpty;
  }

  bool _isUnauthorizedError(Object error) {
    final msg = error.toString().toLowerCase();
    return msg.contains('401') ||
        msg.contains('unauthorized') ||
        msg.contains('session expired') ||
        msg.contains('please provide a token');
  }
}

final sendViewModelProvider = StateNotifierProvider<SendViewModel, SendState>((
  ref,
) {
  return SendViewModel();
});
