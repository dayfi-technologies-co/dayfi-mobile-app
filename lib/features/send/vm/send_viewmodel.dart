import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/services/remote/payment_service.dart';
import 'package:dayfi/models/payment_response.dart';
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
    );
  }
}

class SendViewModel extends StateNotifier<SendState> {
  final PaymentService _paymentService = paymentService;
  
  // Simple cache for API responses
  static List<Channel>? _cachedChannels;
  static List<Network>? _cachedNetworks;
  static DateTime? _channelsCacheTime;
  static DateTime? _networksCacheTime;
  static const Duration _cacheValidityDuration = Duration(minutes: 5);
  
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
      AppLogger.debug('SendViewModel already initialized or initializing, skipping...');
      return;
    }
    
    _isInitializing = true;
    AppLogger.debug('🚀 Initializing SendViewModel...');
    
    // Reset state to clear any cached data
    _resetSendState();
    
    // Initialize any required data
    state = state.copyWith(isLoading: true);

    try {
      // Fetch available currencies from channels API with retry mechanism
      await _fetchAvailableCurrenciesWithRetry();
      
      // After fetching channels, set up default delivery methods and fetch rates
      await _setupDefaultSelections();
      
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
      state = state.copyWith(
        isRatesLoading: true,
        showRatesLoading: true,
      );
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
    state = state.copyWith(
      sendAmount: '',
      receiverAmount: '',
      fee: '0.00',
      totalToPay: '0.00',
      exchangeRate: '', // Will be set by _updateExchangeRate after currencies are set
    );
  }

  Future<void> _setupDefaultSelections() async {
    AppLogger.debug('Setting up default selections');
    
    // Set default send currency to NGN
    await _setDefaultSendCurrency('NG', 'NGN');
    
    // Set default receive currency to NG-NGN
    await _setDefaultReceiveCurrency('NG', 'NGN');
    
    // Set default sender channel ID
    _setDefaultSenderChannelId();
    
    // Fetch rates for both currencies in parallel to avoid multiple sequential calls
    await _fetchRatesForBothCurrencies();
  }

  Future<void> _setDefaultSendCurrency(String country, String currency) async {
    AppLogger.debug('Setting default send currency: $country - $currency');
    
    // Find the first available sender delivery method for this country-currency combination
    String? firstSenderDeliveryMethod;
    
    final availableChannels = state.channels
        .where((channel) => 
            channel.country == country && 
            channel.currency == currency &&
            channel.status == 'active' &&
            (channel.rampType == 'deposit' || 
             channel.rampType == 'receive' || 
             channel.rampType == 'funding'))
        .toList();
    
    if (availableChannels.isNotEmpty) {
      // Get unique channel types and sort them alphabetically
      final channelTypes = availableChannels
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

  Future<void> _setDefaultReceiveCurrency(String country, String currency) async {
    AppLogger.debug('Setting default receive currency: $country - $currency');
    
    // Find the first available delivery method from backend channels
    String? firstDeliveryMethod;
    
    final availableChannels = state.channels
        .where((channel) => 
            channel.country == country && 
            channel.currency == currency &&
            channel.status == 'active' &&
            (channel.rampType == 'withdrawal' || 
             channel.rampType == 'withdraw' || 
             channel.rampType == 'payout'))
        .toList();
    
    if (availableChannels.isNotEmpty) {
      // Get unique channel types
      final channelTypes = availableChannels
          .map((channel) => channel.channelType ?? 'Unknown')
          .toSet()
          .toList();
      
      if (channelTypes.isNotEmpty) {
        // For NGN to NGN transfers, always prioritize DayFi Tag
        final isNgnToNgn = state.sendCurrency == 'NGN' && currency == 'NGN';
        if (isNgnToNgn) {
          // Always select DayFi Tag for NGN to NGN, even if not in API channels
          firstDeliveryMethod = 'dayfi_tag';
        } else {
          // Otherwise, sort alphabetically and use first
          channelTypes.sort();
          firstDeliveryMethod = channelTypes.first;
        }
      }
    } else {
      // Even if no channels available, for NGN to NGN, default to DayFi Tag
      final isNgnToNgn = state.sendCurrency == 'NGN' && currency == 'NGN';
      if (isNgnToNgn) {
        firstDeliveryMethod = 'dayfi_tag';
      }
    }
    
    state = state.copyWith(
      receiverCountry: country,
      receiverCurrency: currency,
      selectedDeliveryMethod: firstDeliveryMethod ?? '',
    );
    
    // Don't fetch rates here - will be done in _fetchRatesForBothCurrencies
  }

  void _setDefaultSenderChannelId() {
    AppLogger.debug('Setting default sender channel ID');
    
    // Find the first available deposit channel for Nigeria NGN
    final depositChannels = state.channels
        .where((channel) => 
            channel.country == 'NG' && 
            channel.currency == 'NGN' &&
            channel.status == 'active' &&
            channel.rampType == 'deposit')
        .toList();
    
    if (depositChannels.isNotEmpty) {
      final defaultChannelId = depositChannels.first.id;
      AppLogger.debug('Default sender channel ID: $defaultChannelId');
      print('🔵 SENDER CHANNEL ID SET: $defaultChannelId');
      
      state = state.copyWith(
        selectedSenderChannelId: defaultChannelId,
      );
    } else {
      AppLogger.warning('No deposit channels found for NG-NGN');
      print('🔴 NO SENDER CHANNEL FOUND');
    }
  }

  /// Fetch rates for both send and receive currencies in parallel
  Future<void> _fetchRatesForBothCurrencies() async {
    try {
      AppLogger.debug('Fetching rates for both currencies: ${state.sendCurrency} and ${state.receiverCurrency}');
      _updateRatesLoadingState(true);
      
      // Fetch rates for both currencies in parallel
      final futures = <Future>[];
      
      if (state.sendCurrency.isNotEmpty) {
        futures.add(_fetchRates(state.sendCurrency));
      }
      
      if (state.receiverCurrency.isNotEmpty && state.receiverCurrency != state.sendCurrency) {
        futures.add(_fetchRates(state.receiverCurrency));
      }
      
      // Wait for all rate fetches to complete
      await Future.wait(futures);
      
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
      try {
        AppLogger.debug('🔄 Fetching currencies attempt $attempt/$_maxRetries');
        await _fetchAvailableCurrencies();
        return; // Success, exit retry loop
      } catch (e) {
        AppLogger.warning('⚠️ Attempt $attempt failed: $e');
        
        if (attempt < _maxRetries) {
          AppLogger.debug('⏳ Waiting ${_retryDelay.inSeconds}s before retry...');
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
          DateTime.now().difference(_channelsCacheTime!) < _cacheValidityDuration) {
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
          await _fetchNetworks();
          
          state = state.copyWith(
            availableCurrencies: currencies,
            channels: channels,
          );
          AppLogger.info('Updated state with ${currencies.length} currencies and ${channels.length} channels');
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
    
    // Use default currencies and empty channels
    final fallbackCurrencies = ['NGN', 'RWF', 'USD', 'EUR', 'GBP'];
    
    state = state.copyWith(
      availableCurrencies: fallbackCurrencies,
      channels: [],
      networks: [],
    );
    
    AppLogger.info('Fallback data set with ${fallbackCurrencies.length} currencies');
  }

  Future<void> _fetchNetworks() async {
    try {
      AppLogger.debug('Fetching networks from API');

      // Check cache first
      if (_cachedNetworks != null && 
          _networksCacheTime != null && 
          DateTime.now().difference(_networksCacheTime!) < _cacheValidityDuration) {
        AppLogger.debug('Using cached networks data');
        state = state.copyWith(networks: _cachedNetworks!);
        return;
      }

      final response = await _paymentService.fetchNetworks();

      // Check if we have valid data and networks
      if (response.data?.networks != null &&
          response.data!.networks!.isNotEmpty) {
        final networks = response.data!.networks!;

        // Only proceed if the API call was successful
        if (!response.error) {
        // Update cache
        _cachedNetworks = networks;
        _networksCacheTime = DateTime.now();
        
        state = state.copyWith(networks: networks);
        AppLogger.info('Updated state with ${networks.length} networks');
        } else {
          AppLogger.warning('Networks API call failed: ${response.message}');
          // Don't throw error - networks are optional, continue with empty list
        }
      } else {
        AppLogger.warning('No networks data available');
        // Don't throw error - networks are optional, continue with empty list
      }
    } catch (e) {
      AppLogger.error('Error fetching networks: $e');
      // Don't rethrow - networks are optional, continue with empty list
    }
  }

  /// Process channels data (used for both fresh API calls and cached data)
  void _processChannelsData(List<Channel> channels) {
    // Extract unique currencies from channels
    final currencies = channels
        .where((channel) => channel.currency != null && channel.currency!.isNotEmpty)
        .map((channel) => channel.currency!)
        .toSet()
        .toList()
      ..sort();

    state = state.copyWith(
      availableCurrencies: currencies,
      channels: channels,
    );
    AppLogger.info('Processed ${currencies.length} currencies and ${channels.length} channels');
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
    
    final availableChannels = state.channels
        .where((channel) => 
            channel.country == country && 
            channel.currency == currency &&
            channel.status == 'active' &&
            (channel.rampType == 'deposit' || 
             channel.rampType == 'receive' || 
             channel.rampType == 'funding'))
        .toList();
    
    if (availableChannels.isNotEmpty) {
      // Get unique channel types and sort them alphabetically
      final channelTypes = availableChannels
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
    String? updatedRecipientDeliveryMethod;
    final isNgnToNgn = currency == 'NGN' && state.receiverCurrency == 'NGN';
    
    if (isNgnToNgn && state.receiverCountry.isNotEmpty) {
      // Always set DayFi Tag for NGN to NGN transfers
      updatedRecipientDeliveryMethod = 'dayfi_tag';
      AppLogger.debug('🔄 NGN to NGN detected in updateSendCountry, setting DayFi Tag');
    }
    
    state = state.copyWith(
      sendCountry: country,
      sendCurrency: currency,
      selectedSenderDeliveryMethod: firstSenderDeliveryMethod ?? '',
      selectedSenderChannelId: selectedSenderChannelId ?? '',
      selectedDeliveryMethod: updatedRecipientDeliveryMethod ?? state.selectedDeliveryMethod,
    );
    
    // Fetch rates for both currencies in parallel
    await _fetchRatesForBothCurrencies();
  }

  Future<void> updateReceiveCountry(String country, String currency) async {
    AppLogger.debug('🔄 updateReceiveCountry called: country=$country, currency=$currency');
    AppLogger.debug('🔄 Current state: send=${state.sendCurrency}, receive=${state.receiverCurrency}');
    
    // Find the first available delivery method from backend channels
    String? firstDeliveryMethod;
    
    final availableChannels = state.channels
        .where((channel) => 
            channel.country == country && 
            channel.currency == currency &&
            channel.status == 'active' &&
            (channel.rampType == 'withdrawal' || 
             channel.rampType == 'withdraw' || 
             channel.rampType == 'payout' ||
             channel.rampType == 'deposit' ||
             channel.rampType == 'receive'))
        .toList();
    
    AppLogger.debug('🔄 Found ${availableChannels.length} available channels for $country-$currency');
    
    if (availableChannels.isNotEmpty) {
      // Get unique channel types
      final channelTypes = availableChannels
          .map((channel) => channel.channelType ?? 'Unknown')
          .toSet()
          .toList();
      
      if (channelTypes.isNotEmpty) {
        // For NGN to NGN transfers, always prioritize DayFi Tag
        final isNgnToNgn = state.sendCurrency == 'NGN' && currency == 'NGN';
        if (isNgnToNgn) {
          // Always select DayFi Tag for NGN to NGN, even if not in API channels
          firstDeliveryMethod = 'dayfi_tag';
          AppLogger.debug('🔄 NGN to NGN detected, selecting DayFi Tag');
        } else {
          // Otherwise, sort alphabetically and use first
          channelTypes.sort();
          firstDeliveryMethod = channelTypes.first;
        }
      }
    } else {
      // Even if no channels available, for NGN to NGN, default to DayFi Tag
      final isNgnToNgn = state.sendCurrency == 'NGN' && currency == 'NGN';
      if (isNgnToNgn) {
        firstDeliveryMethod = 'dayfi_tag';
        AppLogger.debug('🔄 NGN to NGN detected, no channels but selecting DayFi Tag');
      }
    }
    
    state = state.copyWith(
      receiverCountry: country,
      receiverCurrency: currency,
      selectedDeliveryMethod: firstDeliveryMethod ?? '',
    );
    
    AppLogger.debug('🔄 Updated state: send=${state.sendCurrency}, receive=${state.receiverCurrency}');
    
    // Fetch rates for both currencies in parallel
    await _fetchRatesForBothCurrencies();
  }

  void updateSendAmount(String amount) {
    AppLogger.debug('updateSendAmount: $amount');
    // Clean the amount - remove commas and whitespace
    final cleanAmount = amount.replaceAll(RegExp(r'[,\s]'), '').trim();
    
    // If empty, set to empty string
    if (cleanAmount.isEmpty) {
      state = state.copyWith(sendAmount: '');
      state = state.copyWith(receiverAmount: ''); // Clear receive amount when send is empty
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
      state = state.copyWith(sendAmount: ''); // Clear send amount when receive is empty
      _calculateTotal();
      return;
    }
    
    state = state.copyWith(receiverAmount: cleanAmount);
    _updateSendAmountFromReceive();
  }

  void _updateReceiveAmountFromSend() {
    // Clean the amount - remove commas and whitespace
    final cleanAmount = state.sendAmount.replaceAll(RegExp(r'[,\s]'), '').trim();
    
    if (cleanAmount.isEmpty) {
      state = state.copyWith(receiverAmount: '');
      return;
    }
    
    final sendAmount = double.tryParse(cleanAmount);
    AppLogger.debug('_updateReceiveAmountFromSend: sendAmount=$sendAmount');
    if (sendAmount != null && sendAmount > 0) {
      // Special case: if both currencies are the same, use 1:1 rate
      if (state.sendCurrency == state.receiverCurrency) {
        AppLogger.debug('Same currency detected in _updateReceiveAmountFromSend: 1:1 rate');
        state = state.copyWith(
          receiverAmount: sendAmount.toStringAsFixed(2),
        );
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
    final cleanAmount = state.receiverAmount.replaceAll(RegExp(r'[,\s]'), '').trim();
    
    if (cleanAmount.isEmpty) {
      state = state.copyWith(sendAmount: '');
      return;
    }
    
    final receiveAmount = double.tryParse(cleanAmount);
    if (receiveAmount != null && receiveAmount > 0) {
      // Special case: if both currencies are the same, use 1:1 rate
      if (state.sendCurrency == state.receiverCurrency) {
        state = state.copyWith(
          sendAmount: receiveAmount.toStringAsFixed(2),
        );
        return;
      }
      
      final exchangeRate = _calculateExchangeRate();
      if (exchangeRate != null && exchangeRate > 0) {
        final convertedAmount = receiveAmount / exchangeRate;
        state = state.copyWith(
          sendAmount: convertedAmount.toStringAsFixed(2),
        );
      } else {
        state = state.copyWith(sendAmount: '');
      }
    } else {
      state = state.copyWith(sendAmount: '');
    }
  }

  void updateDeliveryMethod(String method) {
    state = state.copyWith(selectedDeliveryMethod: method);
  }

  void updateSenderDeliveryMethod(String method) {
    state = state.copyWith(selectedSenderDeliveryMethod: method);
  }

  void _calculateTotal() {
    final sendAmount = double.tryParse(state.sendAmount.replaceAll(RegExp(r'[^\d.]'), ''));
    final fee = double.tryParse(state.fee.replaceAll(RegExp(r'[^\d.]'), ''));
    
    if (sendAmount != null && sendAmount > 0 && fee != null) {
      final total = sendAmount + fee;
      state = state.copyWith(totalToPay: total.toStringAsFixed(2));
      AppLogger.debug('Calculated total: $sendAmount + $fee = $total');
    } else {
      // Reset total to 0 when no amount is entered
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
      final receiveCode = state.receiveCurrencyRates?['code'] ?? state.receiverCurrency;
      
      // Get currency symbols instead of codes
      final sendSymbol = _getCurrencySymbol(sendCode);
      final receiveSymbol = _getCurrencySymbol(receiveCode);
      
      return '$sendSymbol${1.toStringAsFixed(0)} = $receiveSymbol${rate.toStringAsFixed(2)}';
    }
    return 'Rate not available';
  }

  // Get minimum limit for selected send country and currency
  double? get sendMinimumLimit {
    final sendChannels = state.channels
        .where((channel) => 
            channel.country == state.sendCountry && 
            channel.currency == state.sendCurrency &&
            channel.status == 'active' &&
            (channel.rampType == 'deposit' || 
             channel.rampType == 'receive' || 
             channel.rampType == 'funding'))
        .toList();
    
    if (sendChannels.isEmpty) return null;
    
    // Get the minimum limit from all available channels
    final minLimits = sendChannels
        .map((channel) => channel.min ?? 0.0)
        .where((min) => min > 0)
        .toList();
    
    if (minLimits.isEmpty) return null;
    
    return minLimits.reduce((a, b) => a < b ? a : b);
  }

  // Check if send amount meets minimum requirement
  bool get isSendAmountValid {
    // Remove commas and whitespace for parsing
    final cleanAmount = state.sendAmount.replaceAll(RegExp(r'[,\s]'), '');
    
    // Check if amount is empty
    if (cleanAmount.isEmpty || cleanAmount.trim().isEmpty) {
      return false;
    }
    
    final sendAmount = double.tryParse(cleanAmount);
    final minLimit = sendMinimumLimit;
    
    if (sendAmount == null || sendAmount <= 0 || minLimit == null) {
      return false;
    }
    
    return sendAmount >= minLimit;
  }

  double? _calculateExchangeRate() {
    if (state.sendCurrencyRates == null || state.receiveCurrencyRates == null) {
      AppLogger.debug('Missing rates: send=${state.sendCurrencyRates != null}, receive=${state.receiveCurrencyRates != null}');
      return null;
    }

    // Check if rates have valid buy/sell values
    final sendHasValidRates = state.sendCurrencyRates!['hasValidRates'] == true;
    final receiveHasValidRates = state.receiveCurrencyRates!['hasValidRates'] == true;
    
    if (!sendHasValidRates || !receiveHasValidRates) {
      AppLogger.warning('Currency rates not available - send: $sendHasValidRates, receive: $receiveHasValidRates');
      return null;
    }

    final sendSellRate = double.tryParse(state.sendCurrencyRates!['sell']?.toString() ?? '');
    final receiveBuyRate = double.tryParse(state.receiveCurrencyRates!['buy']?.toString() ?? '');

    AppLogger.debug('💱 Exchange Rate Calculation:');
    AppLogger.debug('   Send Currency: ${state.sendCurrency} (${state.sendCurrencyRates?['code']})');
    AppLogger.debug('   Receive Currency: ${state.receiverCurrency} (${state.receiveCurrencyRates?['code']})');
    AppLogger.debug('   Send Sell Rate: $sendSellRate');
    AppLogger.debug('   Receive Buy Rate: $receiveBuyRate');

    if (sendSellRate == null || receiveBuyRate == null || receiveBuyRate == 0) {
      AppLogger.warning('Invalid rates: sendSell=$sendSellRate, receiveBuy=$receiveBuyRate');
      return null;
    }

    // To convert from send currency to receive currency:
    // We need to know how much receive currency we get for 1 send currency
    // The correct calculation should be: (Receive Buy Rate) / (Send Sell Rate)
    // This gives us: 1 Send Currency = X Receive Currency
    final rate = receiveBuyRate / sendSellRate;
    AppLogger.debug('📈 Calculated rate: $receiveBuyRate / $sendSellRate = $rate');
    return rate;
  }

  void _updateExchangeRate() {
    AppLogger.debug('🔄 _updateExchangeRate called: send=${state.sendCurrency}, receive=${state.receiverCurrency}');
    
    // Special case: if both currencies are the same, show 1:1 rate
    if (state.sendCurrency == state.receiverCurrency && state.sendCurrency.isNotEmpty && state.receiverCurrency.isNotEmpty) {
      final sendCode = state.sendCurrencyRates?['code'] ?? state.sendCurrency;
      final receiveCode = state.receiveCurrencyRates?['code'] ?? state.receiverCurrency;
      
      // Get currency symbols instead of codes
      final sendSymbol = _getCurrencySymbol(sendCode);
      final receiveSymbol = _getCurrencySymbol(receiveCode);
      
      AppLogger.debug('🔄 Same currency detected: $sendCode -> $receiveCode');
      AppLogger.debug('🔄 Currency symbols: $sendSymbol -> $receiveSymbol');
      
      // Show 1:1 rate for same currencies
      final displayText = '$sendSymbol${1.toStringAsFixed(0)} = $receiveSymbol${1.toStringAsFixed(0)}';
      
      AppLogger.debug('📊 Exchange rate display (same currency): $displayText');
      
      // Only update if the exchange rate has actually changed
      if (state.exchangeRate != displayText) {
        state = state.copyWith(exchangeRate: displayText);
        // Update amounts when exchange rate changes
        _updateReceiveAmountFromSend();
      }
      return;
    }
    
    AppLogger.debug('🔄 Different currencies detected, proceeding with normal rate calculation');
    
    // Check if rates are available before calculating
    final sendHasValidRates = state.sendCurrencyRates?['hasValidRates'] == true;
    final receiveHasValidRates = state.receiveCurrencyRates?['hasValidRates'] == true;
    
    if (!sendHasValidRates || !receiveHasValidRates) {
      // Rates not available for one or both currencies
      final sendCode = state.sendCurrencyRates?['code'] ?? state.sendCurrency;
      final receiveCode = state.receiveCurrencyRates?['code'] ?? state.receiverCurrency;
      
      String displayText;
      if (!sendHasValidRates && !receiveHasValidRates) {
        displayText = 'Not available for $sendCode to $receiveCode';
      } else if (!sendHasValidRates) {
        displayText = 'Not available for $sendCode';
      } else {
        displayText = 'Not available for $receiveCode';
      }
      
      AppLogger.warning('❌ Rates not available: $displayText');
      
      if (state.exchangeRate != displayText) {
        state = state.copyWith(exchangeRate: displayText);
        // Don't update amounts when rates aren't available
        state = state.copyWith(receiverAmount: '');
      }
      return;
    }
    
    final rate = _calculateExchangeRate();
    if (rate != null) {
      final sendCode = state.sendCurrencyRates?['code'] ?? state.sendCurrency;
      final receiveCode = state.receiveCurrencyRates?['code'] ?? state.receiverCurrency;
      
      // Get currency symbols instead of codes
      final sendSymbol = _getCurrencySymbol(sendCode);
      final receiveSymbol = _getCurrencySymbol(receiveCode);
      
      AppLogger.debug('🔄 Updating exchange rate: $sendCode -> $receiveCode, rate: $rate');
      
      // Show a more meaningful amount for weak currencies
      // If rate is very small (< 0.1), show 100 units instead of 1
      String displayText;
      if (rate < 0.1) {
        final hundredRate = rate * 100;
        displayText = '$sendSymbol${100.toStringAsFixed(0)} = $receiveSymbol${hundredRate.toStringAsFixed(2)}';
      } else if (rate < 1.0) {
        final thousandRate = rate * 1000;
        displayText = '$sendSymbol${1000.toStringAsFixed(0)} = $receiveSymbol${thousandRate.toStringAsFixed(2)}';
      } else {
        displayText = '$sendSymbol${1.toStringAsFixed(0)} = $receiveSymbol${rate.toStringAsFixed(2)}';
      }
      
      AppLogger.debug('📊 Exchange rate display: $displayText');
      
      // Only update if the exchange rate has actually changed
      if (state.exchangeRate != displayText) {
        state = state.copyWith(exchangeRate: displayText);
        // Update amounts when exchange rate changes
        _updateReceiveAmountFromSend();
      }
    } else {
      AppLogger.warning('❌ Exchange rate calculation returned null');
      
      // Set appropriate message when rate calculation fails
      final sendCode = state.sendCurrencyRates?['code'] ?? state.sendCurrency;
      final receiveCode = state.receiveCurrencyRates?['code'] ?? state.receiverCurrency;
      final displayText = 'Not available for $sendCode to $receiveCode';
      
      if (state.exchangeRate != displayText) {
        state = state.copyWith(exchangeRate: displayText);
        // Don't update amounts when rates aren't available
        state = state.copyWith(receiverAmount: '');
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
    try {
      AppLogger.debug('Fetching rates for currency: $currency');
      
      final response = await _paymentService.fetchRates(currency: currency);
      
      AppLogger.debug('Rates response status: ${response.statusCode}');
      
      if (response.statusCode == 200 && response.data != null) {
        final paymentData = response.data as PaymentData;
        final rates = paymentData.rates;
        
        if (rates != null && rates.isNotEmpty) {
          final rate = rates.first;
          
          // Check if buy and sell rates are actually available
          final hasValidRates = rate.buy != null && rate.sell != null;
          
          // Convert Rate object to Map for storage
          final rateData = {
            'buy': hasValidRates ? rate.buy!.toString() : null,
            'sell': hasValidRates ? rate.sell!.toString() : null,
            'locale': rate.locale ?? '',
            'rateId': rate.rateId ?? '',
            'code': rate.code ?? '',
            'updatedAt': rate.updatedAt ?? '',
            'hasValidRates': hasValidRates, // Flag to indicate if rates are valid
          };
          
          AppLogger.debug('Updated rate data for $currency - hasValidRates: $hasValidRates');
          
          if (currency == state.sendCurrency) {
            AppLogger.debug('Setting send currency rates');
            state = state.copyWith(sendCurrencyRates: rateData);
          } else if (currency == state.receiverCurrency) {
            AppLogger.debug('Setting receive currency rates');
            state = state.copyWith(receiveCurrencyRates: rateData);
          }
        } else {
          AppLogger.warning('No rates returned for currency: $currency');
          // Set rate data with no valid rates
          final rateData = {
            'buy': null,
            'sell': null,
            'locale': '',
            'rateId': '',
            'code': currency,
            'updatedAt': '',
            'hasValidRates': false,
          };
          
          if (currency == state.sendCurrency) {
            state = state.copyWith(sendCurrencyRates: rateData);
          } else if (currency == state.receiverCurrency) {
            state = state.copyWith(receiveCurrencyRates: rateData);
          }
        }
      }
    } catch (e) {
      AppLogger.error('Error fetching rates for $currency: $e');
      
      // If rates fetch fails, set null values to indicate unsupported currency
      final rateData = {
        'buy': null,
        'sell': null,
        'locale': '',
        'rateId': '',
        'code': currency,
        'updatedAt': '',
        'hasValidRates': false,
      };
      
      if (currency == state.sendCurrency) {
        state = state.copyWith(sendCurrencyRates: rateData);
      } else if (currency == state.receiverCurrency) {
        state = state.copyWith(receiveCurrencyRates: rateData);
      }
    }
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
    final receiveHasValidRates = state.receiveCurrencyRates?['hasValidRates'] == true;
    
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
}

final sendViewModelProvider = StateNotifierProvider<SendViewModel, SendState>((ref) {
  return SendViewModel();
});
