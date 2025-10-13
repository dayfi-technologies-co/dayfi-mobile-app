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

  const SendState({
    this.sendAmount = '',
    this.receiverAmount = '',
    this.sendCurrency = 'NGN',
    this.receiverCurrency = 'RWF',
    this.sendCountry = 'NG',
    this.receiverCountry = 'RW',
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

  SendViewModel() : super(const SendState());

  Future<void> initialize() async {
    // Reset state to clear any cached data
    _resetSendState();
    
    // Initialize any required data
    state = state.copyWith(isLoading: true);

    try {
      // Fetch available currencies from channels API
      await _fetchAvailableCurrencies();
      
      // After fetching channels, set up default delivery methods and fetch rates
      await _setupDefaultSelections();
    } catch (e) {
      // If API fails, keep default currencies
      AppLogger.error('Failed to fetch currencies: $e');
    } finally {
      state = state.copyWith(isLoading: false);
      _calculateTotal(); // Calculate initial total
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
    
    // Set default receive currency to RW-RWF
    await _setDefaultReceiveCurrency('RW', 'RWF');
    
    // Set default sender channel ID
    _setDefaultSenderChannelId();
    
    // Update exchange rate after all currencies are set
    _updateExchangeRate();
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
    
    // Fetch rates for the default send currency
    await _fetchRates(currency);
  }

  Future<void> _setDefaultReceiveCurrency(String country, String currency) async {
    AppLogger.debug('Setting default receive currency: $country - $currency');
    
    // Find the first available delivery method for this country-currency combination
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
      // Get unique channel types and sort them alphabetically
      final channelTypes = availableChannels
          .map((channel) => channel.channelType ?? 'Unknown')
          .toSet()
          .toList()
        ..sort();
      
      if (channelTypes.isNotEmpty) {
        firstDeliveryMethod = channelTypes.first;
      }
    }
    
    state = state.copyWith(
      receiverCountry: country,
      receiverCurrency: currency,
      selectedDeliveryMethod: firstDeliveryMethod ?? '',
    );
    
    // Fetch rates for the default receive currency
    await _fetchRates(currency);
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
    
    state = state.copyWith(
      sendCountry: country,
      sendCurrency: currency,
      selectedSenderDeliveryMethod: firstSenderDeliveryMethod ?? '',
      selectedSenderChannelId: selectedSenderChannelId ?? '',
    );
    
    // Fetch rates for the new send currency and wait for completion
    await _fetchRates(currency);
    
    // Update exchange rate after currency change (rates are now fetched)
    _updateExchangeRate();
  }

  Future<void> updateReceiveCountry(String country, String currency) async {
    AppLogger.debug('🔄 updateReceiveCountry called: country=$country, currency=$currency');
    AppLogger.debug('🔄 Current state: send=${state.sendCurrency}, receive=${state.receiverCurrency}');
    
    // Find the first available delivery method for this country-currency combination
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
      // Get unique channel types and sort them alphabetically
      final channelTypes = availableChannels
          .map((channel) => channel.channelType ?? 'Unknown')
          .toSet()
          .toList()
        ..sort();
      
      if (channelTypes.isNotEmpty) {
        firstDeliveryMethod = channelTypes.first;
      }
    }
    
    state = state.copyWith(
      receiverCountry: country,
      receiverCurrency: currency,
      selectedDeliveryMethod: firstDeliveryMethod ?? '',
    );
    
    AppLogger.debug('🔄 Updated state: send=${state.sendCurrency}, receive=${state.receiverCurrency}');
    
    // Fetch rates for the new receive currency and wait for completion
    await _fetchRates(currency);
    
    // Update exchange rate after currency change (rates are now fetched)
    _updateExchangeRate();
  }

  void updateSendAmount(String amount) {
    AppLogger.debug('updateSendAmount: $amount');
    state = state.copyWith(sendAmount: amount);
    _updateReceiveAmountFromSend();
    _calculateTotal();
  }

  void updateReceiveAmount(String amount) {
    state = state.copyWith(receiverAmount: amount);
    _updateSendAmountFromReceive();
  }

  void _updateReceiveAmountFromSend() {
    final sendAmount = double.tryParse(state.sendAmount);
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
      }
    } else {
      AppLogger.warning('Send amount is null or <= 0');
      state = state.copyWith(receiverAmount: '');
    }
  }

  void _updateSendAmountFromReceive() {
    final receiveAmount = double.tryParse(state.receiverAmount);
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
    final sendAmount = double.tryParse(state.sendAmount);
    final minLimit = sendMinimumLimit;
    
    if (sendAmount == null || minLimit == null) return false;
    
    return sendAmount >= minLimit;
  }

  double? _calculateExchangeRate() {
    if (state.sendCurrencyRates == null || state.receiveCurrencyRates == null) {
      AppLogger.debug('Missing rates: send=${state.sendCurrencyRates != null}, receive=${state.receiveCurrencyRates != null}');
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
      state = state.copyWith(exchangeRate: displayText);
      
      // Update amounts when exchange rate changes
      _updateReceiveAmountFromSend();
      return;
    }
    
    AppLogger.debug('🔄 Different currencies detected, proceeding with normal rate calculation');
    
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
      state = state.copyWith(exchangeRate: displayText);
      
      // Update amounts when exchange rate changes
      _updateReceiveAmountFromSend();
    } else {
      AppLogger.warning('❌ Exchange rate calculation returned null');
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
      state = state.copyWith(isRatesLoading: true);
      
      final response = await _paymentService.fetchRates(currency: currency);
      
      AppLogger.debug('Rates response status: ${response.statusCode}');
      
      if (response.statusCode == 200 && response.data != null) {
        final paymentData = response.data as PaymentData;
        final rates = paymentData.rates;
        
        if (rates != null && rates.isNotEmpty) {
          final rate = rates.first;
          
          // Convert Rate object to Map for storage
          final rateData = {
            'buy': rate.buy?.toString() ?? 'N/A',
            'sell': rate.sell?.toString() ?? 'N/A',
            'locale': rate.locale ?? '',
            'rateId': rate.rateId ?? '',
            'code': rate.code ?? '',
            'updatedAt': rate.updatedAt ?? '',
          };
          
          AppLogger.debug('Updated rate data for $currency');
          
          if (currency == state.sendCurrency) {
            AppLogger.debug('Setting send currency rates');
            state = state.copyWith(sendCurrencyRates: rateData);
          } else if (currency == state.receiverCurrency) {
            AppLogger.debug('Setting receive currency rates');
            state = state.copyWith(receiveCurrencyRates: rateData);
          }
          
          // Update exchange rate after setting rates
          _updateExchangeRate();
        }
      }
    } catch (e) {
      AppLogger.error('Error fetching rates for $currency: $e');
      
      // If rates fetch fails, set N/A values to indicate unsupported currency
      final rateData = {
        'buy': 'N/A',
        'sell': 'N/A',
        'locale': '',
        'rateId': '',
        'code': currency,
        'updatedAt': '',
      };
      
      if (currency == state.sendCurrency) {
        state = state.copyWith(sendCurrencyRates: rateData);
      } else if (currency == state.receiverCurrency) {
        state = state.copyWith(receiveCurrencyRates: rateData);
      }
    } finally {
      state = state.copyWith(isRatesLoading: false);
    }
  }

  /// Check if a currency is supported (has valid exchange rates)
  bool isCurrencySupported(String currency) {
    if (currency == state.sendCurrency) {
      return state.sendCurrencyRates?['buy'] != 'N/A' && state.sendCurrencyRates?['buy'] != null;
    } else if (currency == state.receiverCurrency) {
      return state.receiveCurrencyRates?['buy'] != 'N/A' && state.receiveCurrencyRates?['buy'] != null;
    }
    return false;
  }
}

final sendViewModelProvider = StateNotifierProvider<SendViewModel, SendState>((ref) {
  return SendViewModel();
});
