import 'package:flutter_riverpod/flutter_riverpod.dart';

class SendState {
  final String sendAmount;
  final String receiverAmount;
  final String sendCurrency;
  final String receiverCurrency;
  final String fee;
  final String totalToPay;
  final String exchangeRate;
  final bool showUpgradePrompt;
  final bool isLoading;

  const SendState({
    this.sendAmount = '',
    this.receiverAmount = '',
    this.sendCurrency = 'NGN',
    this.receiverCurrency = 'NGN',
    this.fee = '200.00',
    this.totalToPay = '0.00',
    this.exchangeRate = '₦1 = ₦1',
    this.showUpgradePrompt = true,
    this.isLoading = false,
  });

  SendState copyWith({
    String? sendAmount,
    String? receiverAmount,
    String? sendCurrency,
    String? receiverCurrency,
    String? fee,
    String? totalToPay,
    String? exchangeRate,
    bool? showUpgradePrompt,
    bool? isLoading,
  }) {
    return SendState(
      sendAmount: sendAmount ?? this.sendAmount,
      receiverAmount: receiverAmount ?? this.receiverAmount,
      sendCurrency: sendCurrency ?? this.sendCurrency,
      receiverCurrency: receiverCurrency ?? this.receiverCurrency,
      fee: fee ?? this.fee,
      totalToPay: totalToPay ?? this.totalToPay,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      showUpgradePrompt: showUpgradePrompt ?? this.showUpgradePrompt,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SendViewModel extends StateNotifier<SendState> {
  SendViewModel() : super(const SendState());

  void initialize() {
    // Initialize any required data
    state = state.copyWith(isLoading: false);
  }

  void updateAmount(String amount) {
    if (amount.isEmpty) {
      state = state.copyWith(
        sendAmount: '',
        receiverAmount: '',
        totalToPay: '0.00',
      );
      return;
    }

    final parsedAmount = double.tryParse(amount);
    if (parsedAmount == null) return;

    // Calculate fee (simplified calculation)
    final fee = _calculateFee(parsedAmount);
    final totalToPay = parsedAmount + fee;
    final receiverAmount = _calculateReceiverAmount(parsedAmount);

    state = state.copyWith(
      sendAmount: amount,
      receiverAmount: receiverAmount.toStringAsFixed(2),
      fee: fee.toStringAsFixed(2),
      totalToPay: totalToPay.toStringAsFixed(2),
    );
  }

  void updateCurrency(String currency, bool isSendCurrency) {
    if (isSendCurrency) {
      state = state.copyWith(sendCurrency: currency);
    } else {
      state = state.copyWith(receiverCurrency: currency);
    }
    
    // Update exchange rate based on currency selection
    _updateExchangeRate();
  }

  void dismissUpgradePrompt() {
    state = state.copyWith(showUpgradePrompt: false);
  }

  double _calculateFee(double amount) {
    // Simplified fee calculation - 2% of amount with minimum of 200 NGN
    final percentageFee = amount * 0.02;
    return percentageFee > 200 ? percentageFee : 200.0;
  }

  double _calculateReceiverAmount(double amount) {
    // Simplified calculation - subtract fee
    final fee = _calculateFee(amount);
    return amount - fee;
  }

  void _updateExchangeRate() {
    // Simplified exchange rate logic
    String rate;
    if (state.sendCurrency == state.receiverCurrency) {
      rate = '₦1 = ₦1';
    } else if (state.sendCurrency == 'NGN' && state.receiverCurrency == 'USD') {
      rate = '₦1 = \$0.0007';
    } else if (state.sendCurrency == 'NGN' && state.receiverCurrency == 'GBP') {
      rate = '₦1 = £0.0005';
    } else if (state.sendCurrency == 'NGN' && state.receiverCurrency == 'EUR') {
      rate = '₦1 = €0.0006';
    } else {
      rate = '${state.sendCurrency}1 = ${state.receiverCurrency}1';
    }
    
    state = state.copyWith(exchangeRate: rate);
  }
}

final sendViewModelProvider = StateNotifierProvider<SendViewModel, SendState>((ref) {
  return SendViewModel();
});
