import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/flavors.dart';
import 'package:dayfi/services/remote/payment_service.dart';
import 'package:dayfi/services/remote/network/url_config.dart';
import 'package:dayfi/models/payment_response.dart';

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
  final List<Channel> availableDeliveryMethods;
  final String selectedDeliveryMethod;
  final String selectedSenderDeliveryMethod;
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
    this.fee = '10.00',
    this.totalToPay = '0.00',
    this.exchangeRate = '₦1 = ₦1',
    this.showUpgradePrompt = true,
    this.isLoading = false,
    this.availableCurrencies = const [],
    this.channels = const [],
    this.availableDeliveryMethods = const [],
    this.selectedDeliveryMethod = '',
    this.selectedSenderDeliveryMethod = '',
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
    List<Channel>? availableDeliveryMethods,
    String? selectedDeliveryMethod,
    String? selectedSenderDeliveryMethod,
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
      availableDeliveryMethods:
          availableDeliveryMethods ?? this.availableDeliveryMethods,
      selectedDeliveryMethod:
          selectedDeliveryMethod ?? this.selectedDeliveryMethod,
      selectedSenderDeliveryMethod:
          selectedSenderDeliveryMethod ?? this.selectedSenderDeliveryMethod,
      availableCountries: availableCountries ?? this.availableCountries,
      sendCurrencyRates: sendCurrencyRates ?? this.sendCurrencyRates,
      receiveCurrencyRates: receiveCurrencyRates ?? this.receiveCurrencyRates,
      isRatesLoading: isRatesLoading ?? this.isRatesLoading,
    );
  }
}

class SendViewModel extends StateNotifier<SendState> {
  final PaymentService _paymentService = paymentService;

  SendViewModel() : super(const SendState());

  Future<void> initialize() async {
    // Initialize any required data
    state = state.copyWith(isLoading: true);

    try {
      // Fetch available currencies from channels API
      await _fetchAvailableCurrencies();
      
      // After fetching channels, set up default delivery methods and fetch rates
      await _setupDefaultSelections();
    } catch (e) {
      // If API fails, keep default currencies
      print('Failed to fetch currencies: $e');
    } finally {
      state = state.copyWith(isLoading: false);
      _calculateTotal(); // Calculate initial total
    }
  }

  Future<void> _setupDefaultSelections() async {
    print('🎯 Setting up default selections...');
    
    // Set default send currency to NGN
    await _setDefaultSendCurrency('NG', 'NGN');
    
    // Set default receive currency to RW-RWF
    await _setDefaultReceiveCurrency('RW', 'RWF');
  }

  Future<void> _setDefaultSendCurrency(String country, String currency) async {
    print('🎯 Setting default send currency: $country - $currency');
    
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
    print('🎯 Setting default receive currency: $country - $currency');
    
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

  Future<void> _fetchAvailableCurrencies() async {
    try {
      print('🔄 Fetching currencies from channels API...');
      print('🌐 Base URL: ${F.baseUrl}');
      print('🔗 Full URL: ${F.baseUrl}${UrlConfig.fetchChannels}');

      final response = await _paymentService.fetchChannels();

      print(
        '📡 API Response - Error: ${response.error}, Message: ${response.message}',
      );
      print('📡 Status Code: ${response.statusCode}');
      print('📊 Channels count: ${response.data?.channels?.length ?? 0}');

      // Check if we have valid data and channels
      if (response.data?.channels != null &&
          response.data!.channels!.isNotEmpty) {
        final channels = response.data!.channels!;
        print(
          '📋 Raw channels data: ${channels.take(3).map((c) => '${c.currency ?? 'N/A'} (${c.country ?? 'N/A'})').join(', ')}...',
        );

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

          print('💰 Extracted currencies: $currencies');
          state = state.copyWith(
            availableCurrencies: currencies,
            channels: channels,
          );
          print('✅ Updated state with ${currencies.length} currencies and ${channels.length} channels');
        } else {
          print('❌ API call failed with error: ${response.message}');
        }
      } else {
        print('❌ No channels data available');
        print('🔍 Response data: ${response.data}');
      }
    } catch (e) {
      print('💥 Error fetching currencies: $e');
      print('🔍 Error type: ${e.runtimeType}');
    }
  }

  void updateSendCountry(String country, String currency) {
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
    
    // Fetch rates for the new send currency
    _fetchRates(currency);
    
    // Update exchange rate after currency change
    _updateExchangeRate();
  }

  void updateReceiveCountry(String country, String currency) {
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
    
    // Fetch rates for the new receive currency
    _fetchRates(currency);
    
    // Update exchange rate after currency change
    _updateExchangeRate();
  }

  void updateSendAmount(String amount) {
    print('🔄 updateSendAmount called with: $amount');
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
    print('🔄 _updateReceiveAmountFromSend: sendAmount=$sendAmount');
    if (sendAmount != null && sendAmount > 0) {
      final exchangeRate = _calculateExchangeRate();
      print('🔄 Exchange rate: $exchangeRate');
      if (exchangeRate != null) {
        final convertedAmount = sendAmount * exchangeRate;
        print('🔄 Converted amount: $convertedAmount');
        state = state.copyWith(
          receiverAmount: convertedAmount.toStringAsFixed(2),
        );
        print('🔄 Updated receiverAmount to: ${state.receiverAmount}');
      } else {
        print('❌ Exchange rate is null');
      }
    } else {
      print('❌ Send amount is null or <= 0');
      state = state.copyWith(receiverAmount: '');
    }
  }

  void _updateSendAmountFromReceive() {
    final receiveAmount = double.tryParse(state.receiverAmount);
    if (receiveAmount != null && receiveAmount > 0) {
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
    
    if (sendAmount != null && fee != null) {
      final total = sendAmount + fee;
      state = state.copyWith(totalToPay: total.toStringAsFixed(2));
      print('💰 Calculated total: $sendAmount + $fee = $total');
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
      print('❌ Missing rates: send=${state.sendCurrencyRates != null}, receive=${state.receiveCurrencyRates != null}');
      return null;
    }

    final sendSellRate = double.tryParse(state.sendCurrencyRates!['sell']?.toString() ?? '');
    final receiveBuyRate = double.tryParse(state.receiveCurrencyRates!['buy']?.toString() ?? '');

    print('🔍 Exchange Rate Calculation:');
    print('   NGN Sell Rate: $sendSellRate');
    print('   GHS Buy Rate: $receiveBuyRate');
    print('   NGN Rates: ${state.sendCurrencyRates}');
    print('   GHS Rates: ${state.receiveCurrencyRates}');

    if (sendSellRate == null || receiveBuyRate == null || receiveBuyRate == 0) {
      print('❌ Invalid rates: sendSell=$sendSellRate, receiveBuy=$receiveBuyRate');
      return null;
    }

    // To convert from NGN to GHS:
    // We need to know how much GHS we get for 1 NGN
    // The correct calculation should be: (GHS Buy Rate) / (NGN Sell Rate)
    // This gives us: 1 NGN = X GHS
    final rate = receiveBuyRate / sendSellRate;
    print('✅ Calculated rate: $receiveBuyRate / $sendSellRate = $rate');
    return rate;
  }

  void _updateExchangeRate() {
    final rate = _calculateExchangeRate();
    if (rate != null) {
      final sendCode = state.sendCurrencyRates?['code'] ?? state.sendCurrency;
      final receiveCode = state.receiveCurrencyRates?['code'] ?? state.receiverCurrency;
      
      // Get currency symbols instead of codes
      final sendSymbol = _getCurrencySymbol(sendCode);
      final receiveSymbol = _getCurrencySymbol(receiveCode);
      
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
      
      state = state.copyWith(exchangeRate: displayText);
      
      // Update amounts when exchange rate changes
      _updateReceiveAmountFromSend();
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
      print('🔄 Fetching rates for currency: $currency');
      state = state.copyWith(isRatesLoading: true);
      
      final response = await _paymentService.fetchRates(currency: currency);
      
      print('📊 Response status: ${response.statusCode}');
      print('📊 Response data type: ${response.data.runtimeType}');
      
      if (response.statusCode == 200 && response.data != null) {
        final paymentData = response.data as PaymentData;
        final rates = paymentData.rates;
        print('📊 Rates from PaymentData: $rates');
        
        if (rates != null && rates.isNotEmpty) {
          final rate = rates.first;
          print('📊 First rate: buy=${rate.buy}, sell=${rate.sell}, code=${rate.code}');
          
          // Convert Rate object to Map for storage
          final rateData = {
            'buy': rate.buy?.toString() ?? 'N/A',
            'sell': rate.sell?.toString() ?? 'N/A',
            'locale': rate.locale ?? '',
            'rateId': rate.rateId ?? '',
            'code': rate.code ?? '',
            'updatedAt': rate.updatedAt ?? '',
          };
          
          print('📊 Converted rate data: $rateData');
          print('📊 Current send currency: ${state.sendCurrency}');
          print('📊 Current receive currency: ${state.receiverCurrency}');
          
          if (currency == state.sendCurrency) {
            print('📊 Setting send currency rates');
            state = state.copyWith(sendCurrencyRates: rateData);
          } else if (currency == state.receiverCurrency) {
            print('📊 Setting receive currency rates');
            state = state.copyWith(receiveCurrencyRates: rateData);
          }
          
          // Update exchange rate after setting rates
          _updateExchangeRate();
        }
      }
    } catch (e) {
      print('Error fetching rates for $currency: $e');
    } finally {
      state = state.copyWith(isRatesLoading: false);
    }
  }
}

final sendViewModelProvider = StateNotifierProvider<SendViewModel, SendState>((ref) {
  return SendViewModel();
});
