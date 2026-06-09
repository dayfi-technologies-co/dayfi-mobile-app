import 'package:flutter/material.dart';
import 'package:dayfi/common/constants/username_copy.dart';

import 'package:dayfi/common/helpers/wallet_transaction_display.dart';
import 'package:dayfi/common/helpers/wallet_transaction_labels.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/models/wallet_transaction.dart';
import 'package:dayfi/common/utils/string_utils.dart';
import 'package:intl/intl.dart';

/// Widget designed for capturing and sharing transaction receipts
/// This widget is optimized for screenshot/PDF generation
class TransactionReceiptWidget extends StatelessWidget {
  final WalletTransaction transaction;
  final String exchangeRate;
  final String receiveAmount;
  final String fee;
  final String total;

  const TransactionReceiptWidget({
    super.key,
    required this.transaction,
    required this.exchangeRate,
    required this.receiveAmount,
    required this.fee,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 375,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with logo
          _buildHeader(),
          SizedBox(height: 24),

          // Transaction Status Badge
          _buildStatusBadge(),
          SizedBox(height: 24),

          // Amount
          _buildAmountSection(context),
          SizedBox(height: 24),

          // Divider
          Container(height: 1, color: AppColors.neutral200),
          SizedBox(height: 24),

          // Transaction Details
          _buildTransactionDetails(),
          SizedBox(height: 20),

          // Recipient Details (if not a wallet top-up)
          if (!_isWalletTopUp() && !_isBillPayment() && !_isBillReversal()) ...[
            _buildRecipientDetails(),
            SizedBox(height: 20),
          ],

          if (_isBillPayment() || _isBillReversal()) ...[
            _buildBillDetails(),
            SizedBox(height: 20),
          ],

          // Payment Summary
          _buildPaymentSummary(),
          SizedBox(height: 24),

          // Footer
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo
        Image.asset('assets/images/logo_splash.png', height: 32),
        Text(
          'Transaction Receipt',
          style: TextStyle(
            fontFamily: 'Chirp',
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: AppColors.neutral600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final status = transaction.status.toLowerCase();
    Color badgeColor;
    String statusText;

    if (status.contains('success')) {
      badgeColor = AppColors.success500;
      statusText = 'Success';
    } else if (status.contains('pending')) {
      badgeColor = AppColors.warning500;
      statusText = 'Pending';
    } else if (status.contains('failed')) {
      badgeColor = AppColors.error500;
      statusText = 'Failed';
    } else {
      badgeColor = AppColors.neutral500;
      statusText = 'Unknown';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusText.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Chirp',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: badgeColor,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildAmountSection(BuildContext context) {
    final amount = _getTransactionAmount();
    final recipientName = _getRecipientDisplayName();
    final dateTime = _formatDateTime(transaction.timestamp);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          amount,
          style: TextStyle(
            fontFamily: 'FunnelDisplay',
            fontSize: 40,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral900,
          ),
        ),
        SizedBox(height: 8),
        Text(
          recipientName,
          style: TextStyle(
            fontFamily: 'Chirp',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(
              context,
            ).textTheme.bodyLarge!.color!.withOpacity(.85),
          ),
        ),
        SizedBox(height: 4),
        Text(
          dateTime,
          style: TextStyle(
            fontFamily: 'Chirp',
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: AppColors.neutral500,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionDetails() {
    final isDayfiTransfer = _isDayfiTransfer();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transaction Details',
          style: TextStyle(
            fontFamily: 'Chirp',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral900,
          ),
        ),
        SizedBox(height: 12),
        _buildDetailRow(
          'Transaction ID',
          transaction.id.substring(0, 8).toUpperCase(),
        ),
        _buildDetailRow('Date', _formatDateTime(transaction.timestamp)),
        _buildDetailRow('Status', _getStatusText()),
        _buildDetailRow(
          'Send Type',
          isDayfiTransfer
              ? UsernameCopy.label
              : _getChannelDisplayName(transaction.sendChannel),
        ),
        if (transaction.reason != null && transaction.reason!.isNotEmpty)
          _buildDetailRow(
            'Description',
            WalletTransactionDisplay.humanReason(transaction),
          ),
      ],
    );
  }

  Widget _buildRecipientDetails() {
    final isCollection = transaction.status.toLowerCase().contains(
      'collection',
    );
    final isPayment = transaction.status.toLowerCase().contains('payment');
    final isDayfiTransfer = _isDayfiTransfer();

    // For COLLECTION (money IN) - show sender details
    if (isCollection) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sender Details',
            style: TextStyle(
              fontFamily: 'Chirp',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral900,
            ),
          ),
          SizedBox(height: 12),
          _buildDetailRow(
            'Name',
            transaction.beneficiary.name.isNotEmpty
                ? transaction.beneficiary.name
                : 'Self funding',
          ),
          if (isDayfiTransfer &&
              transaction.beneficiary.accountNumber != null &&
              transaction.beneficiary.accountNumber!.isNotEmpty)
            _buildDetailRow(
              UsernameCopy.label,
              transaction.beneficiary.accountNumber!.startsWith('@')
                  ? transaction.beneficiary.accountNumber!
                  : '@${transaction.beneficiary.accountNumber!}',
            ),
          if (transaction.beneficiary.country.isNotEmpty)
            _buildDetailRow(
              'Country',
              _getCountryName(transaction.beneficiary.country),
            ),
        ],
      );
    }

    // For PAYMENT (money OUT) - show recipient details
    if (isPayment) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recipient Details',
            style: TextStyle(
              fontFamily: 'Chirp',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral900,
            ),
          ),
          SizedBox(height: 12),
          _buildDetailRow('Name', transaction.beneficiary.name),
          if (isDayfiTransfer &&
              transaction.beneficiary.accountNumber != null &&
              transaction.beneficiary.accountNumber!.isNotEmpty)
            _buildDetailRow(
              UsernameCopy.label,
              transaction.beneficiary.accountNumber!.startsWith('@')
                  ? transaction.beneficiary.accountNumber!
                  : '@${transaction.beneficiary.accountNumber!}',
            ),
          if (transaction.beneficiary.country.isNotEmpty)
            _buildDetailRow(
              'Country',
              _getCountryName(transaction.beneficiary.country),
            ),
        ],
      );
    }

    // Fallback
    return SizedBox.shrink();
  }

  Widget _buildPaymentSummary() {
    if (_isBillReversal()) {
      return _buildBillRefundSummary();
    }
    if (_isBillPayment()) {
      return _buildBillPaymentSummary();
    }

    final isDeposit = WalletTransactionDisplay.isDepositIncome(transaction);
    final ngnFx = WalletTransactionDisplay.ngnBankDepositFx(transaction);
    final hideFee = isDeposit && fee.replaceAll(RegExp(r'[^\d.]'), '') == '0.00';

    if (ngnFx != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Deposit Summary',
            style: TextStyle(
              fontFamily: 'Chirp',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral900,
            ),
          ),
          SizedBox(height: 12),
          _buildDetailRow(
            'Exchange rate',
            WalletTransactionDisplay.formatNgnPerUsd(ngnFx.ngnPerUsd),
          ),
          // Padding(
          //   padding: const EdgeInsets.only(bottom: 8),
          //   child: Text(
          //     WalletTransactionDisplay.ngnBankDepositRateFootnote,
          //     style: TextStyle(
          //       fontFamily: 'Chirp',
          //       fontSize: 11,
          //       height: 1.3,
          //       color: AppColors.neutral500,
          //     ),
          //   ),
          // ),
          _buildDetailRow(
            'Amount received',
            '₦${StringUtils.formatNumberWithCommas(ngnFx.ngnAmount.toStringAsFixed(2))}',
          ),
          _buildDetailRow(
            'Wallet credit (USD)',
            '\$${StringUtils.formatNumberWithCommas(ngnFx.usdCredited.toStringAsFixed(2))}',
          ),
          SizedBox(height: 8),
          Container(height: 1, color: AppColors.neutral200),
          SizedBox(height: 8),
          _buildDetailRow(
            'Total received',
            '\$${StringUtils.formatNumberWithCommas(ngnFx.usdCredited.toStringAsFixed(2))}',
            isBold: true,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isDeposit ? 'Deposit Summary' : 'Payment Summary',
          style: TextStyle(
            fontFamily: 'Chirp',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral900,
          ),
        ),
        SizedBox(height: 12),
        if (!_isWalletTopUp() && !isDeposit) ...[
          _buildDetailRow('Exchange Rate', exchangeRate),
          _buildDetailRow('Recipient Got', receiveAmount),
        ] else if (isDeposit) ...[
          _buildDetailRow('Amount received', receiveAmount),
        ],
        if (!hideFee) _buildDetailRow('Fee', fee),
        SizedBox(height: 8),
        Container(height: 1, color: AppColors.neutral200),
        SizedBox(height: 8),
        _buildDetailRow(
          isDeposit ? 'Total received' : 'Total Paid',
          isDeposit ? receiveAmount : total,
          isBold: true,
        ),
      ],
    );
  }

  Widget _buildBillDetails() {
    final biller = WalletTransactionLabels.billerDisplayName(transaction);
    final customerId = WalletTransactionLabels.billCustomerId(transaction);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isBillReversal() ? 'Refund Details' : 'Bill Details',
          style: TextStyle(
            fontFamily: 'Chirp',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral900,
          ),
        ),
        SizedBox(height: 12),
        if (!_isBillReversal()) ...[
          _buildDetailRow('Biller', biller),
          if (customerId != null) _buildDetailRow('Customer ID', customerId),
        ] else
          _buildDetailRow(
            'Original reference',
            WalletTransactionLabels.billOriginalReference(transaction) ??
                transaction.id,
          ),
      ],
    );
  }

  Widget _buildBillPaymentSummary() {
    final headline =
        WalletTransactionLabels.billDetailHeadline(transaction);
    final fx = WalletTransactionDisplay.billPaymentFx(transaction);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$headline summary',
          style: TextStyle(
            fontFamily: 'Chirp',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral900,
          ),
        ),
        SizedBox(height: 12),
        if (fx != null) ...[
          if (fx.rateNgnPerUsd != null)
            _buildDetailRow(
              'Exchange rate',
              WalletTransactionDisplay.formatNgnPerUsd(fx.ngnPerUsd),
            ),
          _buildDetailRow(
            'Bill amount',
            '₦${StringUtils.formatNumberWithCommas(fx.ngnAmount.toStringAsFixed(2))}',
          ),
          _buildDetailRow(
            'Wallet debit (USD)',
            '\$${StringUtils.formatNumberWithCommas(fx.usdCredited.toStringAsFixed(2))}',
          ),
        ] else
          _buildDetailRow('Amount paid', total),
        SizedBox(height: 8),
        Container(height: 1, color: AppColors.neutral200),
        SizedBox(height: 8),
        _buildDetailRow('Total paid', total, isBold: true),
      ],
    );
  }

  Widget _buildBillRefundSummary() {
    final fx = WalletTransactionDisplay.billPaymentFx(transaction);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Refund Summary',
          style: TextStyle(
            fontFamily: 'Chirp',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral900,
          ),
        ),
        SizedBox(height: 12),
        if (fx != null) ...[
          if (fx.rateNgnPerUsd != null)
            _buildDetailRow(
              'Exchange rate',
              WalletTransactionDisplay.formatNgnPerUsd(fx.ngnPerUsd),
            ),
          _buildDetailRow(
            'Bill amount',
            '₦${StringUtils.formatNumberWithCommas(fx.ngnAmount.toStringAsFixed(2))}',
          ),
          _buildDetailRow(
            'Wallet credit (USD)',
            '\$${StringUtils.formatNumberWithCommas(fx.usdCredited.toStringAsFixed(2))}',
          ),
        ] else
          _buildDetailRow('Amount refunded', receiveAmount),
        SizedBox(height: 8),
        Container(height: 1, color: AppColors.neutral200),
        SizedBox(height: 8),
        _buildDetailRow('Total returned', receiveAmount, isBold: true),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Container(height: 1, color: AppColors.neutral200),
        SizedBox(height: 16),
        Text(
          'Thank you for using DayFi',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Chirp',
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: AppColors.neutral500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'For support, contact us via the app',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Chirp',
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.neutral400,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Chirp',
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: AppColors.neutral600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Chirp',
              fontSize: 12.5,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
              color: AppColors.neutral900,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getTransactionAmount() {
    final ngnFx = WalletTransactionDisplay.ngnBankDepositFx(transaction);
    if (ngnFx != null) {
      return '\$${StringUtils.formatNumberWithCommas(ngnFx.usdCredited.toStringAsFixed(2))}';
    }

    if (WalletTransactionDisplay.resolveLocalPayout(transaction).isPayout ||
        WalletTransactionDisplay.isCrossBorderBankSend(transaction)) {
      return WalletTransactionDisplay.payoutSendAmountText(transaction);
    }

    if (WalletTransactionLabels.isDebit(transaction) &&
        (transaction.ledgerCurrency ?? 'USD').toUpperCase() == 'USD' &&
        ((transaction.receiveAmount ?? 0) >= 50 ||
            (transaction.sendAmount ?? 0) >= 50)) {
      final header = WalletTransactionDisplay.amountText(transaction);
      if (header != 'N/A') return header;
    }

    if (transaction.receiveAmount != null && transaction.receiveAmount! > 0) {
      final currencyCode = _getCurrencyCodeFromCountry(
        transaction.beneficiary.country,
      );
      final currencySymbol = _getCurrencySymbolFromCode(currencyCode);
      final formattedAmount = StringUtils.formatNumberWithCommas(
        transaction.receiveAmount!.toStringAsFixed(2),
      );
      return '$currencySymbol$formattedAmount';
    } else if (transaction.sendAmount != null && transaction.sendAmount! > 0) {
      final formattedAmount = StringUtils.formatNumberWithCommas(
        transaction.sendAmount!.toStringAsFixed(2),
      );
      return '₦$formattedAmount';
    } else {
      return 'N/A';
    }
  }

  String _getRecipientDisplayName() {
    if (_isBillReversal()) {
      return WalletTransactionLabels.detailHeadline(transaction);
    }
    if (_isBillPayment()) {
      return WalletTransactionLabels.detailHeadline(transaction);
    }

    final isCollection = transaction.status.toLowerCase().contains(
      'collection',
    );
    final isPayment = transaction.status.toLowerCase().contains('payment');
    final isDayfiTransfer = _isDayfiTransfer();

    // For COLLECTION (money IN)
    if (isCollection) {
      if (_isWalletTopUp()) {
        return 'Wallet Top Up';
      }
      if (isDayfiTransfer &&
          transaction.beneficiary.accountNumber != null &&
          transaction.beneficiary.accountNumber!.isNotEmpty) {
        final tag = transaction.beneficiary.accountNumber!;
        final displayTag = tag.startsWith('@') ? tag : '@$tag';
        return 'Money received from $displayTag';
      }
      return 'Money added to your wallet';
    }

    // For PAYMENT (money OUT)
    if (isPayment) {
      // if (_isWalletTopUp()) {
      //   return 'Topped up your wallet';
      // }
      if (isDayfiTransfer &&
          transaction.beneficiary.accountNumber != null &&
          transaction.beneficiary.accountNumber!.isNotEmpty) {
        final tag = transaction.beneficiary.accountNumber!;
        final displayTag = tag.startsWith('@') ? tag : '@$tag';
        return 'Sent money to $displayTag';
      }
      return 'Sent to ${transaction.beneficiary.name}';
    }

    // Fallback
    if (_isWalletTopUp()) {
      return 'Wallet Top Up';
    }
    return 'To ${transaction.beneficiary.name}';
  }

  String _formatDateTime(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp).toLocal();
      return DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);
    } catch (e) {
      return timestamp;
    }
  }

  String _getStatusText() {
    final status = transaction.status.toLowerCase();
    if (status.contains('success')) return 'Success';
    if (status.contains('pending')) return 'Pending';
    if (status.contains('failed')) return 'Failed';
    return 'Unknown';
  }

  String _capitalizeWords(String text) {
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  String _getCountryName(String countryCode) {
    final Map<String, String> countries = {
      'CD': 'DR Congo',
      'RW': 'Rwanda',
      'NG': 'Nigeria',
      'KE': 'Kenya',
      'UG': 'Uganda',
      'TZ': 'Tanzania',
      'ZA': 'South Africa',
      'GH': 'Ghana',
      'BW': 'Botswana',
    };
    return countries[countryCode.toUpperCase()] ?? countryCode;
  }

  bool _isWalletTopUp() {
    if (_isBillReversal()) return false;
    if (WalletTransactionDisplay.isDepositIncome(transaction)) return true;
    final name = transaction.beneficiary.name.trim().toUpperCase();
    return name.contains('SELF FUNDING') ||
        name.contains('WALLET') ||
        name == 'WALLET TOP UP';
  }

  bool _isBillPayment() => WalletTransactionLabels.isBillPayment(transaction);

  bool _isBillReversal() => WalletTransactionLabels.isBillReversal(transaction);

  bool _isDayfiTransfer() {
    return transaction.source.accountType?.toLowerCase() == 'dayfi' ||
        transaction.beneficiary.accountType?.toLowerCase() == 'dayfi';
  }

  String _getChannelDisplayName(String? channel) {
    if (channel == null || channel.isEmpty) return 'N/A';

    switch (channel.toLowerCase()) {
      case 'dayfi':
      case 'dayfi_tag':
        return UsernameCopy.label;
      case 'bank':
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'mobile_money':
      case 'momo':
        return 'Mobile Money';
      case 'spenn':
        return 'Spenn';
      case 'cash_pickup':
        return 'Cash Pickup';
      case 'wallet':
        return 'Digital Wallet';
      case 'card':
        return 'Card Payment';
      default:
        return channel;
    }
  }

  String _getCurrencyCodeFromCountry(String country) {
    final upperCountry = country.toUpperCase();
    switch (upperCountry) {
      case 'NG':
      case 'NIGERIA':
        return 'NGN';
      case 'RW':
      case 'RWANDA':
        return 'RWF';
      case 'GH':
      case 'GHANA':
        return 'GHS';
      case 'KE':
      case 'KENYA':
        return 'KES';
      case 'UG':
      case 'UGANDA':
        return 'UGX';
      case 'TZ':
      case 'TANZANIA':
        return 'TZS';
      case 'ZA':
      case 'SOUTH AFRICA':
      case 'SA':
        return 'ZAR';
      case 'BW':
      case 'BOTSWANA':
        return 'BWP';
      case 'SN':
      case 'SENEGAL':
      case 'CI':
      case 'COTE D\'IVOIRE':
      case 'IVORY COAST':
      case 'BF':
      case 'BURKINA FASO':
      case 'ML':
      case 'MALI':
      case 'NE':
      case 'NIGER':
      case 'TD':
      case 'CHAD':
      case 'CF':
      case 'CENTRAL AFRICAN REPUBLIC':
        return 'XOF';
      case 'CM':
      case 'CAMEROON':
      case 'GQ':
      case 'EQUATORIAL GUINEA':
      case 'GA':
      case 'GABON':
      case 'CG':
      case 'CONGO':
      case 'CD':
      case 'DEMOCRATIC REPUBLIC OF CONGO':
      case 'AO':
      case 'ANGOLA':
        return 'XAF';
      case 'US':
      case 'USA':
      case 'UNITED STATES':
        return 'USD';
      case 'GB':
      case 'UK':
      case 'UNITED KINGDOM':
      case 'ENGLAND':
        return 'GBP';
      case 'EU':
      case 'EUROPE':
        return 'EUR';
      default:
        return 'NGN'; // Default to Naira
    }
  }

  String _getCurrencySymbolFromCode(String currencyCode) {
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
        return 'UGX ';
      case 'TZS':
        return 'TSh ';
      case 'ZAR':
        return 'R ';
      case 'BWP':
        return 'P ';
      case 'XOF':
        return 'CFA ';
      case 'XAF':
        return 'FCFA ';
      default:
        return '₦';
    }
  }
}
