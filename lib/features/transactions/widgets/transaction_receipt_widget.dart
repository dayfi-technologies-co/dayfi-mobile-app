import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
          if (!_isWalletTopUp()) ...[
            _buildRecipientDetails(),
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
        Image.asset('assets/icons/pngs/logoo.png', height: 32),
        Text(
          'Transaction Receipt',
          style: TextStyle(
            fontFamily: 'Chirp',
            fontSize: 12,
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
      statusText = 'Completed';
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
          fontWeight: FontWeight.w700,
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
            fontSize: 36,
            fontWeight: FontWeight.w700,
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
            fontSize: 12,
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
            fontWeight: FontWeight.w700,
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
              ? 'Dayfi Tag'
              : _getChannelDisplayName(transaction.sendChannel),
        ),
        if (transaction.reason != null && transaction.reason!.isNotEmpty)
          _buildDetailRow('Description', _capitalizeWords(transaction.reason!)),
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
              fontWeight: FontWeight.w700,
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
              'Dayfi Tag',
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
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
            ),
          ),
          SizedBox(height: 12),
          _buildDetailRow('Name', transaction.beneficiary.name),
          if (isDayfiTransfer &&
              transaction.beneficiary.accountNumber != null &&
              transaction.beneficiary.accountNumber!.isNotEmpty)
            _buildDetailRow(
              'Dayfi Tag',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Summary',
          style: TextStyle(
            fontFamily: 'Chirp',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
        SizedBox(height: 12),
        if (!_isWalletTopUp()) ...[
          _buildDetailRow('Exchange Rate', exchangeRate),
          _buildDetailRow('Recipient Got', receiveAmount),
        ],
        _buildDetailRow('Fee', fee),
        SizedBox(height: 8),
        Container(height: 1, color: AppColors.neutral200),
        SizedBox(height: 8),
        _buildDetailRow('Total Paid', total, isBold: true),
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
            fontSize: 12,
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
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.neutral600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Chirp',
              fontSize: 12,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: AppColors.neutral900,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getTransactionAmount() {
    if (transaction.sendAmount != null && transaction.sendAmount! > 0) {
      final formattedAmount = StringUtils.formatNumberWithCommas(
        transaction.sendAmount!.toStringAsFixed(2),
      );
      return '₦$formattedAmount';
    } else if (transaction.receiveAmount != null &&
        transaction.receiveAmount! > 0) {
      final formattedAmount = StringUtils.formatNumberWithCommas(
        transaction.receiveAmount!.toStringAsFixed(2),
      );
      return '₦$formattedAmount';
    } else {
      return 'N/A';
    }
  }

  String _getRecipientDisplayName() {
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
    if (status.contains('success')) return 'Completed';
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
    return transaction.beneficiary.name.trim().toUpperCase().contains(
          'SELF FUNDING',
        ) ||
        transaction.beneficiary.name.trim().toUpperCase().contains('WALLET');
  }

  bool _isDayfiTransfer() {
    return transaction.source.accountType?.toLowerCase() == 'dayfi' ||
        transaction.beneficiary.accountType?.toLowerCase() == 'dayfi';
  }

  String _getChannelDisplayName(String? channel) {
    if (channel == null || channel.isEmpty) return 'N/A';

    switch (channel.toLowerCase()) {
      case 'dayfi':
      case 'dayfi_tag':
        return 'Dayfi Tag';
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
}
