import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/models/wallet_transaction.dart';
import 'package:dayfi/common/widgets/buttons/buttons.dart';
import 'package:dayfi/common/widgets/buttons/help_button.dart';
import 'package:dayfi/app_locator.dart';
import 'package:intercom_flutter/intercom_flutter.dart';
import 'package:dayfi/common/utils/string_utils.dart';
import 'package:dayfi/features/send/vm/send_viewmodel.dart';
import 'package:dayfi/services/remote/payment_service.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:dayfi/models/payment_response.dart' as payment;

class TransactionDetailsView extends ConsumerStatefulWidget {
  final WalletTransaction transaction;

  const TransactionDetailsView({super.key, required this.transaction});

  @override
  ConsumerState<TransactionDetailsView> createState() =>
      _TransactionDetailsViewState();
}

class _TransactionDetailsViewState
    extends ConsumerState<TransactionDetailsView> {
  // Rate fetching state
  bool _isRatesLoading = false;
  Map<String, dynamic>? _sendCurrencyRates;
  Map<String, dynamic>? _receiveCurrencyRates;
  String _calculatedReceiveAmount = '';
  String _exchangeRate = '';
  
  // Services
  final PaymentService _paymentService = locator<PaymentService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      analyticsService.trackScreenView(screenName: 'TransactionDetailsView');
      _fetchExchangeRates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.onSurface,
            // size: 20.sp,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Trans. Details",
          style: AppTypography.titleLarge.copyWith(
            fontFamily: 'CabinetGrotesk',
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: HelpButton(onTap: _navigateToContactUs),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),

            // Transaction Header
            _buildTransactionHeader(),

            SizedBox(height: 24.h),

            // Status Timeline
            _buildStatusTimeline(),

            SizedBox(height: 20.h),

            // Account Details
            _buildAccountDetails(),

            SizedBox(height: 20.h),

            // Payment Summary
            _buildPaymentSummary(),

            // Action Buttons (for failed transactions)
            if (_shouldShowActionButtons()) ...[
              SizedBox(height: 32.h),
              _buildActionButtons(),
            ],

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHeader() {
    final amount = _getTransactionAmount();
    final recipientName = widget.transaction.beneficiary.name.toUpperCase();
    final dateTime = _formatDateTime(widget.transaction.timestamp);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Amount
        Text(
          amount.split('.')[0],
          style: AppTypography.headlineLarge.copyWith(
            fontFamily: 'CabinetGrotesk',
            fontSize: 32.sp,
            letterSpacing: -.6,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),

        SizedBox(height: 8.h),

        // Recipient
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "To $recipientName",
                    style: AppTypography.bodyLarge.copyWith(
                      fontFamily: 'Karla',
                      fontSize: 16.sp,
                      letterSpacing: -.6,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),

                  Text(
                    dateTime,
                    style: AppTypography.bodyMedium.copyWith(
                      fontFamily: 'Karla',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -.4,
                      height: 1.450,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            _buildStatusIcon(),
          ],
        ),

        SizedBox(height: 4.h),

        // Date
      ],
    );
  }

  Widget _buildStatusIcon() {
    final status = widget.transaction.status.toLowerCase();

    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: _getStatusBackgroundColor(status),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Center(
        child: SvgPicture.asset(
          _getStatusIcon(status),
          height: 44.sp,
          width: 44.sp,
          colorFilter: ColorFilter.mode(
            _getStatusColor(status),
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  String _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'success-collection':
      case 'success':
        return 'assets/icons/svgs/circle-check.svg';
      case 'pending':
      case 'pending-collection':
        return "assets/icons/svgs/exclamation-circle.svg";
      case 'failed':
      case 'failed-collection':
        return "assets/icons/svgs/circle-x.svg";
      default:
        return "assets/icons/svgs/info-circle.svg";
    }
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'failed':
      case 'failed-collection':
        return AppColors.error500.withOpacity(0.1);
      case 'pending':
      case 'pending-collection':
        return AppColors.warning500.withOpacity(0.1);
      case 'success-collection':
      case 'success':
        return AppColors.success500.withOpacity(0.1);
      default:
        return AppColors.info500.withOpacity(0.1);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success-collection':
      case 'success':
        return AppColors.success500;
      case 'pending':
      case 'pending-collection':
        return AppColors.warning500;
      case 'failed':
      case 'failed-collection':
        return AppColors.error500;
      default:
        return AppColors.neutral500;
    }
  }

  Widget _buildStatusTimeline() {
    final status = widget.transaction.status.toLowerCase();
    final sendAmount = _getTransactionAmount();
    final receiveAmount = _getReceiveAmount();
    final recipientName = widget.transaction.beneficiary.name.toUpperCase();
    final dateTime = _formatDateTime(widget.transaction.timestamp);

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          _buildTimelineItem(
            isCompleted: true,
            isActive: true,
            date: dateTime.split(',')[0],
            title: "You've set up a transfer of $sendAmount to $recipientName",
            isFirst: true,
          ),
          SizedBox(height: 20.h),

          _buildTimelineItem(
            isCompleted:
                status == 'success-collection' || status == 'completed',
            isActive: status == 'pending' || status == 'pending-collection',
            date: dateTime.split(',')[0],
            title: "We're waiting to receive your funds",
            isFirst: false,
          ),
          SizedBox(height: 20.h),

          _buildTimelineItem(
            isCompleted:
                status == 'success-collection' || status == 'completed',
            isActive: false,
            date: dateTime.split(',')[0],
            title:
                "$recipientName should receive your transfer of $receiveAmount by ${_getExpectedDeliveryDate()}",
            isFirst: false,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required bool isCompleted,
    required bool isActive,
    required String date,
    required String title,
    required bool isFirst,
    bool isLast = false,
  }) {
    Color statusColor;
    if (isCompleted) {
      statusColor = AppColors.success500;
    } else if (isActive) {
      statusColor = AppColors.warning500;
    } else {
      statusColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.3);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            if (!isFirst)
              Container(
                width: 2.w,
                height: 20.h,
                color:
                    isCompleted
                        ? AppColors.success500
                        : isActive
                        ? AppColors.warning500
                        : Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.3),
              ),
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2.w,
                height: 20.h,
                color:
                    isCompleted
                        ? AppColors.success500
                        : isActive
                        ? AppColors.warning500
                        : Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.3),
              ),
          ],
        ),

        SizedBox(width: 24.w),

        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date,
                style: AppTypography.bodySmall.copyWith(
                  fontFamily: 'Karla',
                  fontSize: 12,
                  letterSpacing: -.4,
                  height: 1.450,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                title,
                style: AppTypography.bodyMedium.copyWith(
                  fontFamily: 'Karla',
                  fontSize: 15.sp,
                  letterSpacing: -.4,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountDetails() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   "Account Details",
          //   style: AppTypography.bodyLarge.copyWith(
          //     fontFamily: 'CabinetGrotesk',
          //     fontSize: 16.sp,
          //     fontWeight: FontWeight.w600,
          //     color: Theme.of(context).colorScheme.onSurface,
          //   ),
          // ),
          // SizedBox(height: 16.h),
          _buildDetailRow(
            "Account number",
            widget.transaction.source.accountNumber ?? "N/A",
          ),
          _buildDetailRow("Bank", _getBankName()),
          _buildDetailRow("Reason", widget.transaction.reason ?? "N/A"),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                fontFamily: 'Karla',
                fontSize: 14.sp,
                letterSpacing: -.4,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                value,
                style: AppTypography.bodyMedium.copyWith(
                  fontFamily: 'Karla',
                  fontSize: 15.sp,
                  letterSpacing: -.4,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary() {
    final receiveAmount = _getReceiveAmount();
    final fee = _getTransactionFee();
    final total = _calculateTotal();
    final exchangeRate = _getExchangeRate();

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryRow(
            "Reference number",
            widget.transaction.id,
            showCopy: true,
          ),
          _buildSummaryRow("Exchange rate", exchangeRate, isLoading: _isRatesLoading),
          _buildSummaryRow("Recipient got", receiveAmount, isLoading: _isRatesLoading),
          _buildSummaryRow("Fee", fee),
          _buildSummaryRow("Total paid", total, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool showCopy = false,
    bool isTotal = false,
    bool isLoading = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                fontFamily: 'Karla',
                fontSize: 14.sp,
                letterSpacing: -.4,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          SizedBox(width: 24.w),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: isLoading
                        ? SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: LoadingAnimationWidget.horizontalRotatingDots(
                              color: AppColors.primary600,
                              size: 20,
                            ),
                          )
                        : Text(
                            value,
                            style: AppTypography.bodyMedium.copyWith(
                              fontFamily: 'Karla',
                              fontSize: 15.sp,
                              letterSpacing: -.4,
                              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                  ),
                ),

                if (showCopy) ...[
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      TopSnackbar.show(
                        context,
                        message: 'Reference number copied',
                      );
                    },
                    child: SvgPicture.asset(
                      "assets/icons/svgs/copy.svg",
                      height: 20.w,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        PrimaryButton(
          text: "I've paid",
          onPressed: () {
            // TODO: Implement payment confirmation
            _showPaymentConfirmationDialog();
          },
          width: double.infinity,
          height: 48.h,
        ),
        SizedBox(height: 12.h),
        PrimaryButton(
          text: "I've not paid",
          onPressed: () {
            // TODO: Implement not paid action
            _showNotPaidDialog();
          },
          width: double.infinity,
          height: 48.h,
          backgroundColor: Theme.of(context).colorScheme.surface,
          textColor: Theme.of(context).colorScheme.onSurface,
        ),
        SizedBox(height: 12.h),
        PrimaryButton(
          text: "Cancel transfer",
          onPressed: () {
            // TODO: Implement cancel transfer
            _showCancelDialog();
          },
          width: double.infinity,
          height: 48.h,
          backgroundColor: AppColors.error500,
          textColor: Colors.white,
        ),
      ],
    );
  }

  bool _shouldShowActionButtons() {
    final status = widget.transaction.status.toLowerCase();
    return status == 'failed' || status == 'failed-collection';
  }

  String _getTransactionAmount() {
    if (widget.transaction.sendAmount != null &&
        widget.transaction.sendAmount! > 0) {
      final formattedAmount = StringUtils.formatNumberWithCommas(
        widget.transaction.sendAmount!.toStringAsFixed(2),
      );
      return '₦$formattedAmount';
    } else if (widget.transaction.receiveAmount != null &&
        widget.transaction.receiveAmount! > 0) {
      final formattedAmount = StringUtils.formatNumberWithCommas(
        widget.transaction.receiveAmount!.toStringAsFixed(2),
      );
      return '₦$formattedAmount';
    } else {
      return 'N/A';
    }
  }

  String _getReceiveAmount() {
    // Use calculated amount from API if available
    if (_calculatedReceiveAmount.isNotEmpty) {
      final currencyCode = _getCurrencyCodeFromCountry(
        widget.transaction.beneficiary.country,
      );
      final currencySymbol = _getCurrencySymbolFromCode(currencyCode);
      final formattedAmount = StringUtils.formatNumberWithCommas(_calculatedReceiveAmount);
      return '$currencySymbol$formattedAmount';
    }
    
    // Fallback to transaction data
    if (widget.transaction.receiveAmount != null &&
        widget.transaction.receiveAmount! > 0) {
      final currencyCode = _getCurrencyCodeFromCountry(
        widget.transaction.beneficiary.country,
      );
      final currencySymbol = _getCurrencySymbolFromCode(currencyCode);
      final formattedAmount = StringUtils.formatNumberWithCommas(
        widget.transaction.receiveAmount!.toStringAsFixed(2),
      );
      return '$currencySymbol$formattedAmount';
    } else if (widget.transaction.sendAmount != null &&
        widget.transaction.sendAmount! > 0) {
      // Fallback to send amount if receive amount is not available
      final formattedAmount = StringUtils.formatNumberWithCommas(
        widget.transaction.sendAmount!.toStringAsFixed(2),
      );
      return '₦$formattedAmount';
    } else {
      return 'N/A';
    }
  }

  /// Get currency code from country code
  String _getCurrencyCodeFromCountry(String country) {
    switch (country.toUpperCase()) {
      case 'NG':
        return 'NGN';
      case 'RW':
        return 'RWF';
      case 'GH':
        return 'GHS';
      case 'KE':
        return 'KES';
      case 'UG':
        return 'UGX';
      case 'TZ':
        return 'TZS';
      case 'ZA':
        return 'ZAR';
      case 'BW':
        return 'BWP';
      case 'SN':
      case 'CI':
      case 'BF':
      case 'ML':
      case 'NE':
      case 'TD':
      case 'CF':
        return 'XOF';
      case 'CM':
      case 'GQ':
      case 'GA':
      case 'CG':
      case 'CD':
      case 'AO':
        return 'XAF';
      case 'US':
        return 'USD';
      case 'GB':
        return 'GBP';
      case 'EU':
        return 'EUR';
      default:
        return 'NGN'; // Default to Naira
    }
  }

  /// Get transaction fee
  String _getTransactionFee() {
    // For now, return a placeholder fee
    // TODO: Get actual fee from transaction data when available
    final formattedAmount = StringUtils.formatNumberWithCommas('1.00');
    return '₦$formattedAmount';
  }

  /// Get exchange rate display
  String _getExchangeRate() {
    // Use calculated rate from API if available
    if (_exchangeRate.isNotEmpty) {
      return _exchangeRate;
    }
    
    // Fallback to calculation from transaction data
    if (widget.transaction.sendAmount != null &&
        widget.transaction.receiveAmount != null &&
        widget.transaction.sendAmount! > 0 &&
        widget.transaction.receiveAmount! > 0) {
      // Calculate the exchange rate: receiveAmount / sendAmount
      final rate =
          widget.transaction.receiveAmount! / widget.transaction.sendAmount!;
      final sendCurrency = 'NGN';
      final receiveCurrency = _getCurrencyCodeFromCountry(
        widget.transaction.beneficiary.country,
      );

      // Get currency symbols
      final sendSymbol = _getCurrencySymbolFromCode(sendCurrency);
      final receiveSymbol = _getCurrencySymbolFromCode(receiveCurrency);

      // Format the exchange rate similar to send_view.dart
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

      return displayText;
    } else {
      // Fallback: try to get a reasonable exchange rate based on common currency pairs
      final receiveCurrency = _getCurrencyCodeFromCountry(
        widget.transaction.beneficiary.country,
      );
      final sendSymbol = '₦';
      final receiveSymbol = _getCurrencySymbolFromCode(receiveCurrency);
      
      // Provide a fallback rate based on common currency pairs
      // This is a simplified approach - in production, you might want to fetch real rates
      switch (receiveCurrency) {
        case 'RWF':
          return '$sendSymbol${1.toStringAsFixed(0)} = $receiveSymbol${1.20.toStringAsFixed(2)}';
        case 'GHS':
          return '$sendSymbol${1.toStringAsFixed(0)} = $receiveSymbol${0.15.toStringAsFixed(2)}';
        case 'KES':
          return '$sendSymbol${1.toStringAsFixed(0)} = $receiveSymbol${2.50.toStringAsFixed(2)}';
        case 'UGX':
          return '$sendSymbol${1.toStringAsFixed(0)} = $receiveSymbol${15.00.toStringAsFixed(2)}';
        case 'TZS':
          return '$sendSymbol${1.toStringAsFixed(0)} = $receiveSymbol${2.80.toStringAsFixed(2)}';
        case 'ZAR':
          return '$sendSymbol${1.toStringAsFixed(0)} = $receiveSymbol${0.25.toStringAsFixed(2)}';
        default:
          return '$sendSymbol${1.toStringAsFixed(0)} = $receiveSymbol${1.00.toStringAsFixed(2)}';
      }
    }
  }

  /// Get currency symbol from currency code (matching send_view.dart)
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
        return 'USh ';
      case 'TZS':
        return 'TSh ';
      case 'ZAR':
        return 'R';
      case 'BWP':
        return 'P';
      case 'XOF':
        return 'CFA';
      case 'XAF':
        return 'FCFA';
      default:
        return '$currencyCode ';
    }
  }

  /// Calculate total amount paid
  String _calculateTotal() {
    if (widget.transaction.sendAmount != null &&
        widget.transaction.sendAmount! > 0) {
      // Add fee to send amount
      final feeAmount = 1.0; // TODO: Get actual fee from transaction data
      final totalAmount = widget.transaction.sendAmount! + feeAmount;
      final formattedAmount = StringUtils.formatNumberWithCommas(
        totalAmount.toStringAsFixed(2),
      );
      return '₦$formattedAmount';
    } else {
      return 'N/A';
    }
  }

  /// Fetch exchange rates for both send and receive currencies
  Future<void> _fetchExchangeRates() async {
    if (widget.transaction.sendAmount == null || widget.transaction.sendAmount! <= 0) {
      return;
    }

    setState(() {
      _isRatesLoading = true;
    });

    try {
      // Fetch rates for both currencies in parallel
      final sendCurrency = 'NGN';
      final receiveCurrency = _getCurrencyCodeFromCountry(widget.transaction.beneficiary.country);
      
      await Future.wait([
        _fetchRates(sendCurrency),
        _fetchRates(receiveCurrency),
      ]);

      // Calculate exchange rate and converted amount
      _calculateExchangeRateAndAmount();
    } catch (e) {
      // Handle error - could show a snackbar or fallback
      print('Error fetching exchange rates: $e');
    } finally {
      setState(() {
        _isRatesLoading = false;
      });
    }
  }

  /// Fetch rates for a specific currency
  Future<void> _fetchRates(String currency) async {
    try {
      final response = await _paymentService.fetchRates(currency: currency);
      
      if (response.statusCode == 200 && response.data != null) {
        final paymentData = response.data as payment.PaymentData;
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
          
          if (currency == 'NGN') {
            _sendCurrencyRates = rateData;
          } else {
            _receiveCurrencyRates = rateData;
          }
        }
      }
    } catch (e) {
      print('Error fetching rates for $currency: $e');
    }
  }

  /// Calculate exchange rate and converted amount
  void _calculateExchangeRateAndAmount() {
    if (_sendCurrencyRates == null || _receiveCurrencyRates == null) {
      return;
    }

    final sendSellRate = double.tryParse(_sendCurrencyRates!['sell']?.toString() ?? '');
    final receiveBuyRate = double.tryParse(_receiveCurrencyRates!['buy']?.toString() ?? '');

    if (sendSellRate == null || receiveBuyRate == null || receiveBuyRate == 0) {
      return;
    }

    // Calculate exchange rate: receiveBuyRate / sendSellRate
    final rate = receiveBuyRate / sendSellRate;
    
    // Calculate converted amount
    final sendAmount = widget.transaction.sendAmount!;
    final convertedAmount = sendAmount * rate;
    
    // Update state
    setState(() {
      _calculatedReceiveAmount = convertedAmount.toStringAsFixed(2);
      _exchangeRate = _formatExchangeRate(rate);
    });
  }

  /// Format exchange rate for display
  String _formatExchangeRate(double rate) {
    final sendSymbol = '₦';
    final receiveCurrency = _getCurrencyCodeFromCountry(widget.transaction.beneficiary.country);
    final receiveSymbol = _getCurrencySymbolFromCode(receiveCurrency);
    
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
    
    return displayText;
  }

  String _formatDateTime(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final transactionDate = DateTime(
        dateTime.year,
        dateTime.month,
        dateTime.day,
      );

      String dateStr;
      if (transactionDate == today) {
        dateStr = "Today";
      } else if (transactionDate == today.subtract(const Duration(days: 1))) {
        dateStr = "Yesterday";
      } else {
        dateStr =
            "${dateTime.day}${_getOrdinalSuffix(dateTime.day)} ${_getMonthName(dateTime.month)}";
      }

      final timeStr =
          "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.hour >= 12 ? 'PM' : 'AM'}";

      return "$dateStr, $timeStr";
    } catch (e) {
      return timestamp;
    }
  }

  String _getOrdinalSuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  String _getExpectedDeliveryDate() {
    try {
      final dateTime = DateTime.parse(widget.transaction.timestamp);
      final deliveryDate = dateTime.add(const Duration(minutes: 60));
      return "${deliveryDate.day}${_getOrdinalSuffix(deliveryDate.day)} ${_getMonthName(deliveryDate.month)}, ${deliveryDate.year}";
    } catch (e) {
      return "01 Oct, 2025";
    }
  }

  String _getBankName() {
    try {
      // Try to get network name from send view model
      final sendState = ref.read(sendViewModelProvider);

      // Find network by network ID
      if (widget.transaction.source.networkId != null) {
        final network = sendState.networks.firstWhere(
          (network) => network.id == widget.transaction.source.networkId,
          orElse: () => throw StateError('No element'),
        );

        return network.name ?? 'Unknown Network';
      }

      // Fallback to account type
      return widget.transaction.source.accountType?.toUpperCase() ?? 'Unknown';
    } catch (e) {
      // Fallback to account type if there's an error
      return widget.transaction.source.accountType?.toUpperCase() ?? 'Unknown';
    }
  }

  void _showPaymentConfirmationDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Confirm Payment"),
            content: Text("Are you sure you have completed the payment?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // TODO: Implement payment confirmation logic
                },
                child: Text("Confirm"),
              ),
            ],
          ),
    );
  }

  void _showNotPaidDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Payment Not Completed"),
            content: Text(
              "Please complete your payment to proceed with the transfer.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("OK"),
              ),
            ],
          ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Cancel Transfer"),
            content: Text("Are you sure you want to cancel this transfer?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("No"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // TODO: Implement cancel transfer logic
                },
                child: Text("Yes, Cancel"),
              ),
            ],
          ),
    );
  }

  void _navigateToContactUs() async {
    try {
      await Intercom.instance.displayMessenger();
    } catch (e) {
      // Fallback in case Intercom fails
      if (mounted) {
        TopSnackbar.show(
          context,
          message: 'Unable to open support chat. Please try again later.',
          isError: true,
        );
      }
    }
  }
}
