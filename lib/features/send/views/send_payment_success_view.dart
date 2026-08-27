import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/buttons/secondary_button.dart';
import 'package:dayfi/common/widgets/transaction_processing_overlay.dart';
import 'package:dayfi/features/send/helpers/send_success_navigation.dart';
import 'package:dayfi/features/send/vm/send_viewmodel.dart';
import 'package:dayfi/features/transactions/vm/transactions_viewmodel.dart';
import 'package:dayfi/common/helpers/ngn_bank_transfer_partner.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/common/utils/haptic_helper.dart';
import 'package:dayfi/common/utils/share_origin.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/models/wallet_transaction.dart';
import 'package:dayfi/models/payment_response.dart' as payment;

class SendPaymentSuccessView extends ConsumerStatefulWidget {
  final Map<String, dynamic> recipientData;
  final Map<String, dynamic> selectedData;
  final Map<String, dynamic> paymentData;
  final payment.PaymentData? collectionData;
  final String? transactionId;

  const SendPaymentSuccessView({
    super.key,
    required this.recipientData,
    required this.selectedData,
    required this.paymentData,
    this.collectionData,
    this.transactionId,
  });

  @override
  ConsumerState<SendPaymentSuccessView> createState() =>
      _SendPaymentSuccessViewState();
}

class _SendPaymentSuccessViewState extends ConsumerState<SendPaymentSuccessView> {
  WalletTransaction? _transaction;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    TransactionProcessingOverlay.hide();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_refreshTransactionHistory());
    });
  }

  Future<void> _refreshTransactionHistory() async {
    final id = widget.transactionId;
    if (id == null) return;

    final cached = SendSuccessNavigation.findInProvider(ref, id);
    if (cached != null) {
      if (mounted) setState(() => _transaction = cached);
      unawaited(ref.read(transactionsProvider.notifier).loadTransactions());
      return;
    }

    try {
      await ref.read(transactionsProvider.notifier).loadTransactions();
      final match = SendSuccessNavigation.findInProvider(ref, id);
      if (!mounted) return;
      setState(() => _transaction = match);

      if (match != null) {
        AppLogger.info('Transaction prefetched: $id');
      } else {
        AppLogger.error('Transaction not found: $id');
      }
    } catch (e) {
      AppLogger.error('Failed to fetch transaction: $e');
    }
  }

  bool _showsNgnBankPartnerFootnote() {
    if (_transaction != null &&
        NgnBankTransferPartner.matchesTransaction(_transaction!)) {
      return true;
    }
    return NgnBankTransferPartner.matchesSendFlow(
      selectedData: widget.selectedData,
      recipientData: widget.recipientData,
    );
  }

  String _successFootnote() {
    if (_showsNgnBankPartnerFootnote()) {
      return NgnBankTransferPartner.successFootnote;
    }

    final method =
        widget.selectedData['recipientDeliveryMethod']?.toLowerCase();
    final provider = switch (method) {
      'bank' || 'p2p' => 'the bank',
      'mobile_money' || 'momo' => 'the mobile money provider',
      'dayfi_tag' => 'Dayfi',
      _ => 'the provider',
    };
    return 'The recipient account is expected to be credited within 5 minutes, '
        'subject to notification by $provider';
  }

  Future<void> _shareReceipt(BuildContext shareContext) async {
    HapticHelper.lightImpact();
    final sendState = ref.read(sendViewModelProvider);
    final amountFromData = double.tryParse(
          widget.selectedData['sendAmount']
                  ?.toString()
                  .replaceAll(RegExp(r'[,\s]'), '') ??
              '',
        ) ??
        double.tryParse(sendState.sendAmount.toString()) ??
        0.0;
    final receiveFromData = double.tryParse(
      widget.selectedData['receiveAmount']
              ?.toString()
              .replaceAll(RegExp(r'[,\s]'), '') ??
          '',
    );
    final currency = widget.selectedData['sendCurrency']?.toString() ??
        widget.selectedData['debitCurrency']?.toString() ??
        widget.selectedData['cryptoAsset']?.toString() ??
        sendState.sendCurrency;
    final receiveCurrency = widget.selectedData['receiveCurrency']?.toString() ??
        sendState.receiverCurrency;
    final receiveAmount = receiveFromData ??
        double.tryParse(sendState.receiverAmount.toString());
    final sendSymbol = _getCurrencySymbol(currency);
    final receiveSymbol = _getCurrencySymbol(receiveCurrency);
    final recipient = widget.recipientData['name'] ?? 'Recipient';
    final txnId = widget.transactionId ?? _transaction?.id ?? 'N/A';
    final date = DateTime.now().toLocal();

    final buffer = StringBuffer()
      ..writeln('Transfer Successful!')
      ..writeln('You sent: $sendSymbol${_formatAmount(amountFromData)}')
      ..writeln('Recipient: $recipient');

    if (receiveAmount != null &&
        receiveAmount > 0 &&
        !_isSameCurrencyPair(currency, receiveCurrency)) {
      buffer.writeln(
        'Recipient gets: $receiveSymbol${_formatAmount(receiveAmount)}',
      );
    }

    buffer
      ..writeln('Transaction ID: $txnId')
      ..writeln('Date: ${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}')
      ..writeln()
      ..write(_successFootnote());

    try {
      await Share.share(
        buffer.toString(),
        subject: 'Dayfi Transfer Receipt',
        sharePositionOrigin: sharePositionOrigin(shareContext),
      );
    } catch (e) {
      AppLogger.error('Share receipt failed: $e');
      if (mounted) {
        TopSnackbar.show(
          context,
          message: 'Unable to share receipt. Please try again.',
          isError: true,
        );
      }
    }
  }

  Future<void> _viewTransaction() async {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);
    try {
      await SendSuccessNavigation.openTransactionDetailsOrList(
        ref: ref,
        transactionId: widget.transactionId,
        prefetchedTransaction: _transaction,
      );
    } finally {
      if (mounted) setState(() => _isNavigating = false);
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
        return 'KSh';
      case 'UGX':
        return 'USh';
      case 'TZS':
        return 'TSh';
      case 'ZAR':
        return 'R';
      default:
        return '$currencyCode ';
    }
  }

  // Helper method to format amount with commas
  String _formatAmount(double amount) {
    // Format with 2 decimal places and add thousand separators
    final parts = amount.toStringAsFixed(2).split('.');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return '$integerPart.${parts[1]}';
  }

  /// Home-style amount: smaller currency symbol, larger figures.
  Widget _buildStyledAmount({
    required String symbol,
    required double amount,
    required double figureFontSize,
  }) {
    final formatted = _formatAmount(amount);
    final split = formatted.split('.');
    final whole = split[0];
    final decimals = split.length > 1 ? '.${split[1]}' : '.00';
    final symbolSize = figureFontSize * 0.75;

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: symbol,
            style: TextStyle(
              fontSize: symbolSize,
              height: 1,
              fontFamily: 'FunnelDisplay',
              fontWeight: FontWeight.w600,
              color: AppColors.neutral0,
              letterSpacing: -0.5,
            ),
          ),
          TextSpan(
            text: whole,
            style: TextStyle(
              fontSize: figureFontSize,
              height: 1,
              fontFamily: 'FunnelDisplay',
              fontWeight: FontWeight.w600,
              color: AppColors.neutral0,
              letterSpacing: -1,
            ),
          ),
          TextSpan(
            text: decimals,
            style: TextStyle(
              fontSize: figureFontSize,
              height: 1,
              fontFamily: 'FunnelDisplay',
              fontWeight: FontWeight.w600,
              color: AppColors.neutral0,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final sendState = ref.watch(sendViewModelProvider);
    final amountFromData = double.tryParse(
          widget.selectedData['sendAmount']
                  ?.toString()
                  .replaceAll(RegExp(r'[,\s]'), '') ??
              '',
        ) ??
        double.tryParse(
          widget.selectedData['receiveAmount']
                  ?.toString()
                  .replaceAll(RegExp(r'[,\s]'), '') ??
              '',
        );
    final amount =
        amountFromData ?? double.tryParse(sendState.sendAmount.toString()) ?? 0.0;
    final receiveFromData = double.tryParse(
      widget.selectedData['receiveAmount']
              ?.toString()
              .replaceAll(RegExp(r'[,\s]'), '') ??
          '',
    );
    final currency = widget.selectedData['sendCurrency']?.toString() ??
        widget.selectedData['debitCurrency']?.toString() ??
        widget.selectedData['cryptoAsset']?.toString() ??
        sendState.sendCurrency;
    final receiveCurrency = widget.selectedData['receiveCurrency']?.toString() ??
        sendState.receiverCurrency;
    final receiveAmount = receiveFromData ??
        (_isSameCurrencyPair(currency, receiveCurrency) ? amount : null) ??
        double.tryParse(sendState.receiverAmount.toString()) ??
        0.0;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppColors.purple900,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth > 600;
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWide ? 500 : double.infinity,
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWide ? 24 : 18,
                      vertical: 8,
                    ),
                    child: _buildSuccessView(
                      amount,
                      currency,
                      receiveAmount,
                      receiveCurrency,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSuccessView(double amount, String currency, double receiveAmount, String receiveCurrency) {
    final sendSymbol = _getCurrencySymbol(currency);
    final receiveSymbol = _getCurrencySymbol(receiveCurrency);
    final isSameCurrency = _isSameCurrencyPair(currency, receiveCurrency);
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        SizedBox(height: 12),
        Column(
          children: [
            SizedBox(
              width: 132,
              height: 132,
              child: SvgPicture.asset('assets/icons/svgs/successs.svg'),
            ),
            SizedBox(height: 32),
            Text(
              'Transfer Successful',
              style: AppTypography.headlineLarge.copyWith(
                fontFamily: 'FunnelDisplay',
                fontSize: 24,
                height: 1.2,
                fontWeight: FontWeight.w500,
                color: AppColors.neutral0,
                letterSpacing: -0.6,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Column(
              children: [
                Text(
                  'You sent',
                  style: AppTypography.bodyMedium.copyWith(
                    fontFamily: 'Chirp',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.neutral0.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4),
                _buildStyledAmount(
                  symbol: sendSymbol,
                  amount: amount,
                  figureFontSize: 40,
                ),
                if (!isSameCurrency && receiveAmount > 0) ...[
                  SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.neutral0.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Recipient gets',
                          style: AppTypography.bodyMedium.copyWith(
                            fontFamily: 'Chirp',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.neutral0.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 4),
                        _buildStyledAmount(
                          symbol: receiveSymbol,
                          amount: receiveAmount,
                          figureFontSize: 24,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Text(
                _successFootnote(),
                style: AppTypography.bodyLarge.copyWith(
                  fontFamily: 'Chirp',
                  fontSize: 16,
                  color: AppColors.neutral0.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        Column(
          children: [
            PrimaryButton(
              text: 'View transactions',
              onPressed: _viewTransaction,
              isLoading: _isNavigating,
              backgroundColor: Colors.white,
              textColor: AppColors.purple500,
              borderRadius: 38,
              height: 48,
              fullWidth: true,
              applyFeatureInset: false,
              fontFamily: 'Chirp',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
            const SizedBox(height: 12),
            Builder(
              builder: (shareContext) {
                return SecondaryButton(
                  text: 'Share transaction',
                  onPressed: () => _shareReceipt(shareContext),
                  backgroundColor: Colors.transparent,
                  textColor: AppColors.neutral0,
                  borderColor: AppColors.neutral0,
                  borderRadius: 38,
                  height: 48,
                  fullWidth: true,
                  applyFeatureInset: false,
                  fontFamily: 'Chirp',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  String _normalizeCurrencyCode(String code) {
    final c = code.toUpperCase();
    if (c == 'USDC' || c == 'USDT') return 'USD';
    if (c == 'EURC') return 'EUR';
    return c;
  }

  bool _isSameCurrencyPair(String sendCode, String receiveCode) {
    return _normalizeCurrencyCode(sendCode) ==
        _normalizeCurrencyCode(receiveCode);
  }
}
