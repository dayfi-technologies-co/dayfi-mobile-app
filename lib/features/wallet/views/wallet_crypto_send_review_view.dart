import 'dart:math' show pi;

import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/helpers/transaction_pin_flow.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/recipients/helpers/recipient_history_helper.dart';
import 'package:dayfi/features/send/constants/send_copy.dart';
import 'package:dayfi/features/wallet/constants/crypto_network_catalog.dart';
import 'package:dayfi/features/send/vm/transaction_pin_viewmodel.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/services/remote/payment_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WalletCryptoSendReviewView extends ConsumerStatefulWidget {
  final Map<String, dynamic> draft;

  const WalletCryptoSendReviewView({super.key, required this.draft});

  @override
  ConsumerState<WalletCryptoSendReviewView> createState() =>
      _WalletCryptoSendReviewViewState();
}

class _WalletCryptoSendReviewViewState
    extends ConsumerState<WalletCryptoSendReviewView> {
  bool _submitting = false;

  String get _asset => widget.draft['asset']?.toString() ?? 'USDC';
  String get _displayCurrency {
    switch (_asset.toUpperCase()) {
      case 'EURC':
        return 'EUR';
      default:
        return 'USD';
    }
  }

  String get _network => widget.draft['network']?.toString() ?? 'stellar';
  String get _to => widget.draft['to']?.toString() ?? '';
  String get _amount => widget.draft['amount']?.toString() ?? '0';
  String? get _memo => widget.draft['memo']?.toString();

  String _networkLabel() {
    return CryptoNetworkCatalog.networkName(
      CryptoNetworkCatalog.defaultsForReceive(),
      _network.toLowerCase(),
    );
  }

  double get _networkFeeUsd {
    final fromDraft = widget.draft['selectedData'];
    if (fromDraft is Map) {
      final v = double.tryParse(fromDraft['cryptoNetworkFeeUsd']?.toString() ?? '');
      if (v != null) return v;
    }
    return CryptoNetworkCatalog.find(
          CryptoNetworkCatalog.defaultsForReceive(),
          _network.toLowerCase(),
        )?.estimatedNetworkFeeUsd ??
        0;
  }

  double get _platformFeeUsd {
    final fromDraft = widget.draft['selectedData'];
    if (fromDraft is Map) {
      final v = double.tryParse(fromDraft['cryptoPlatformFeeUsd']?.toString() ?? '');
      if (v != null) return v;
    }
    return SendCopy.transferFeeUsd;
  }

  String _formatNumber(double amount) {
    final formatted = amount.toStringAsFixed(2);
    final parts = formatted.split('.');
    final integerPart = parts[0];
    final buffer = StringBuffer();
    for (var i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) buffer.write(',');
      buffer.write(integerPart[i]);
    }
    return '${buffer.toString()}.${parts[1]}';
  }

  Future<void> _confirm() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    final hash = await TransactionPinFlow.requestPinAndRun<String?>(
      context: context,
      ref: ref,
      returnRoute: AppRoute.walletCryptoSendReviewView,
      returnArguments: {'draft': widget.draft},
      task: (pin) async {
        final response = await locator<PaymentService>().sendCrypto(
          to: _to,
          amount: _amount,
          asset: _asset,
          network: _network,
          memo: _memo ?? '',
          pin: pin,
        );
        if (response.success) return response.hash ?? '';
        throw Exception(
          response.message.isNotEmpty ? response.message : 'Crypto send failed',
        );
      },
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (hash == null) {
      ref.read(transactionPinProvider.notifier).resetForm();
      return;
    }

    final recipientLabel = RecipientHistoryHelper.truncateAddress(_to);
    appRouter.pushNamedAndRemoveUntil(
      AppRoute.sendPaymentSuccessView,
      (route) => false,
      arguments: {
        'recipientData': {'name': recipientLabel},
        'selectedData': {
          'sendAmount': _amount,
          'sendCurrency': _displayCurrency,
          'receiveAmount': _amount,
          'receiveCurrency': _displayCurrency,
          'cryptoAsset': _asset,
          'cryptoNetwork': _networkLabel(),
          'recipientDeliveryMethod': 'crypto',
        },
        'paymentData': {
          'hash': hash,
          'reason': SendCopy.defaultTransferReason,
        },
        'transactionId': hash,
      },
    );
  }

  Widget _getDetailIcon(String label) {
    switch (label.toLowerCase()) {
      case 'transfer amount':
        return Transform.rotate(
          angle: -pi / 2,
          child: SvgPicture.asset('assets/icons/svgs/fee.svg', height: 24),
        );
      case 'total':
        return SvgPicture.asset('assets/icons/svgs/total.svg', height: 24);
      case 'recipient':
        return Padding(
          padding: const EdgeInsets.all(1),
          child: Image.asset('assets/icons/pngs/account_4.png', height: 22),
        );
      case 'delivery method':
        return SvgPicture.asset('assets/icons/svgs/delivery.svg', height: 24);
      case 'network':
        return SvgPicture.asset('assets/icons/svgs/brand-stellar.svg', height: 22);
      case 'transfer time':
        return SvgPicture.asset('assets/icons/svgs/time.svg', height: 24);
      default:
        return SvgPicture.asset('assets/icons/svgs/fee.svg', height: 24);
    }
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isTotal = false,
    double bottomPadding = 12,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _getDetailIcon(label),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontFamily: 'Chirp',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontFamily: 'Chirp',
                fontSize: 14,
                fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final amountValue = double.tryParse(_amount.replaceAll(',', '')) ?? 0;
    final networkFee = _networkFeeUsd;
    final platformFee = _platformFeeUsd;
    final totalValue = amountValue + networkFee + platformFee;
    final amountLabel = '${_formatNumber(amountValue)} $_displayCurrency';
    final networkFeeLabel = '${_formatNumber(networkFee)} $_displayCurrency';
    final platformFeeLabel = '${_formatNumber(platformFee)} $_displayCurrency';
    final totalLabel = '${_formatNumber(totalValue)} $_displayCurrency';
    final recipientLabel = RecipientHistoryHelper.truncateAddress(_to);
    final deliveryLabel = '$_displayCurrency · ${_networkLabel()}';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: .5,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leadingWidth: 72,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/svgs/notificationn.svg',
                height: 40,
                color: Theme.of(context).colorScheme.surface,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        title: Text(
          'Review Transfer',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontFamily: 'FunnelDisplay',
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Text(
                  'Confirm the details of your transfer before sending',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Chirp',
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transfer Details',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontFamily: 'Chirp',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildDetailRow('Transfer Amount', amountLabel),
                      _buildDetailRow('Recipient', recipientLabel),
                      _buildDetailRow('Delivery Method', deliveryLabel),
                      _buildDetailRow('Network', _networkLabel()),
                      if (_memo != null && _memo!.trim().isNotEmpty)
                        _buildDetailRow('Memo', _memo!.trim()),
                      _buildDetailRow('Network fee', networkFeeLabel),
                      _buildDetailRow('Platform fee', platformFeeLabel),
                      Divider(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                        height: 24,
                      ),
                      _buildDetailRow('Total', totalLabel, isTotal: true),
                      _buildDetailRow('Transfer Time', 'Instant', bottomPadding: 0),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
              child: PrimaryButton(
                text: 'Confirm Payment',
                onPressed: _submitting ? null : _confirm,
                isLoading: _submitting,
                fullWidth: true,
                borderRadius: 40,
                height: 48,
                backgroundColor: AppColors.purple500ForTheme(context),
                textColor: AppColors.neutral0,
                fontFamily: 'Chirp',
                letterSpacing: -.7,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
