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
import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';

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
            fontSize: 28.00,
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
        padding: EdgeInsets.symmetric(horizontal: 18.w),
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

            // Only show account details if it's a wallet top-up and fee is 0.00
            if (_isWalletTopUp() && _isFeeZero()) ...[
              _buildBankAccountDetails(),
              SizedBox(height: 16.h),
            ],

            // Hide transaction details and recipient details for wallet top-ups and collections
            if (!_isWalletTopUp() &&
                !widget.transaction.status.toLowerCase().contains(
                  'collection',
                )) ...[
              // Account Details
              _buildAccountDetails(),
              SizedBox(height: 16.h),

              // Recipient Details
              _buildRecipientDetails(),
              SizedBox(height: 16.h),
            ],

            // Payment Summary
            _buildPaymentSummary(),

            // Action Buttons (for failed transactions)
            // if (_shouldShowActionButtons()) ...[
            //   SizedBox(height: 32.h),
            //   _buildActionButtons(),
            // ],
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHeader() {
    final amount = _getTransactionAmount();
    final recipientName = _getRecipientDisplayName();
    final dateTime = _formatDateTime(widget.transaction.timestamp);
    final isCollection = widget.transaction.status.toLowerCase().contains(
      'collection',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Amount
        Text(
          amount.split('.')[0],

          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontFamily: 'CabinetGrotesk',
            fontSize: 32.sp,
            letterSpacing: -.6,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),

        SizedBox(height: 8.h),

        // Recipient
        Row(
          children: [
            // Transaction Type Icon (Inflow/Outflow)
            SizedBox(
              width: 56.w,
              height: 56.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  SvgPicture.asset(
                    'assets/icons/svgs/transactions.svg',
                    height: 56.sp,
                    color: _getTransactionTypeColor(
                      widget.transaction.status,
                    ).withOpacity(0.35),
                  ),
                  // Foreground icon
                  Center(
                    child: SvgPicture.asset(
                      _getTransactionTypeIcon(widget.transaction.status),
                      height: 24.sp,
                      color: _getTransactionTypeColor(
                        widget.transaction.status,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCollection ? "Wallet Top Up" : recipientName,
                    style: AppTypography.bodyLarge.copyWith(
                      fontFamily: 'Karla',
                      fontSize: 16.sp,
                      letterSpacing: -.3,
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
            SizedBox(width: 12.w),
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
      width: 56.w,
      height: 56.w,
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
      case 'success-payment':
      case 'success':
        return 'assets/icons/svgs/circle-check.svg';
      case 'pending':
      case 'pending-collection':
      case 'pending-payment':
        return "assets/icons/svgs/exclamation-circle.svg";
      case 'failed':
      case 'failed-collection':
      case 'failed-payment':
        return "assets/icons/svgs/circle-x.svg";
      default:
        return "assets/icons/svgs/info-circle.svg";
    }
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'failed':
      case 'failed-collection':
      case 'failed-payment':
        return AppColors.error500.withOpacity(0.1);
      case 'pending':
      case 'pending-collection':
      case 'pending-payment':
        return AppColors.warning500.withOpacity(0.1);
      case 'success-collection':
      case 'success-payment':
      case 'success':
        return AppColors.success500.withOpacity(0.1);
      default:
        return AppColors.info500.withOpacity(0.1);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success-collection':
      case 'success-payment':
      case 'success':
        return AppColors.success500;
      case 'pending':
      case 'pending-collection':
      case 'pending-payment':
        return AppColors.warning500;
      case 'failed':
      case 'failed-collection':
      case 'failed-payment':
        return AppColors.error500;
      default:
        return AppColors.neutral500;
    }
  }

  Widget _buildStatusTimeline() {
    final status = widget.transaction.status.toLowerCase();
    final sendAmount = _getTransactionAmount();
    final receiveAmount = _getReceiveAmount();
    final recipientDisplayName = _getRecipientDisplayName();
    final dateTime = _formatDateTime(widget.transaction.timestamp);
    // Get recipient name for timeline (without "To " prefix)
    final recipientName =
        recipientDisplayName.startsWith('To ')
            ? recipientDisplayName.substring(3)
            : recipientDisplayName;

    final isTopUp = _isWalletTopUp();
    final transferPhrase = isTopUp ? "top up" : "transfer";

    // Determine if this is a collection or payment transaction
    final isCollection = status.contains('collection');
    final isPayment = status.contains('payment');
    final isSuccess = status.contains('success');
    final isPending = status.contains('pending');

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          // First item: Transaction initiated
          _buildTimelineItem(
            isCompleted: true,
            isActive: true,
            date: dateTime.split(',')[0],
            title:
                isSuccess && isCollection
                    ? "You received $sendAmount into your wallet"
                    : isSuccess && isPayment
                    ? "You sent $sendAmount to $recipientName"
                    : isCollection
                    ? "You set up wallet funding of $sendAmount"
                    : "You've set up a $transferPhrase of $sendAmount to $recipientName",
            isFirst: true,
            isLast: isSuccess, // If successful, this is the last item to show
          ),

          // Only show additional timeline items if transaction is not yet successful
          if (!isSuccess) ...[
            SizedBox(height: 20.h),

            // Second item for collections: Waiting for transfer
            if (isCollection)
              _buildTimelineItem(
                isCompleted: false,
                isActive: isPending,
                date: dateTime.split(',')[0],
                title: "We're waiting for your funds",
                isFirst: false,
                isLast: false,
              ),

            // Second item for payments: Processing payment
            if (isPayment)
              _buildTimelineItem(
                isCompleted: false,
                isActive: isPending,
                date: dateTime.split(',')[0],
                title: "We're processing your payment",
                isFirst: false,
                isLast: isTopUp, // Hide third item for wallet top-ups
              ),

            // Third item for collections: Funds received into wallet
            if (isCollection && isPending) ...[
              SizedBox(height: 20.h),
              _buildTimelineItem(
                isCompleted: false,
                isActive: false,
                date: dateTime.split(',')[0],
                title: "You'll receive $sendAmount into your wallet",
                isFirst: false,
                isLast: true,
              ),
            ],

            // Third item for payments: Recipient receives funds (only for non-top-ups and pending)
            if (isPayment && !isTopUp && isPending) ...[
              SizedBox(height: 20.h),
              _buildTimelineItem(
                isCompleted: false,
                isActive: false,
                date: dateTime.split(',')[0],
                title:
                    "$recipientName should receive your $transferPhrase of $receiveAmount by ${_getExpectedDeliveryDate()}",
                isFirst: false,
                isLast: true,
              ),
            ],
          ],
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Timeline indicator
        Column(
          children: [
            if (!isFirst)
              Container(
                width: 2.w,
                height: 24.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: statusColor.withOpacity(0.2),
                    width: 1,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      isCompleted
                          ? AppColors.success500
                          : isActive
                          ? AppColors.warning500
                          : Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.2),
                      isCompleted
                          ? AppColors.success500.withOpacity(0.3)
                          : isActive
                          ? AppColors.warning500.withOpacity(0.3)
                          : Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
            Container(
              width: 16.w,
              height: 16.w,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child:
                    isCompleted
                        ? SvgPicture.asset(
                          'assets/icons/svgs/circle-check.svg',

                          colorFilter: ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        )
                        : isActive
                        ? Container(
                          width: 6.w,
                          height: 6.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        )
                        : null,
              ),
            ),
            if (!isLast)
              Container(
                width: 2.w,
                height: 24.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: statusColor.withOpacity(0.2),
                    width: 1,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      isCompleted
                          ? AppColors.success500.withOpacity(0.3)
                          : isActive
                          ? AppColors.warning500.withOpacity(0.3)
                          : Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.1),
                      isCompleted
                          ? AppColors.success500
                          : isActive
                          ? AppColors.warning500
                          : Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.2),
                    ],
                  ),
                ),
              ),
          ],
        ),

        SizedBox(width: 20.w),

        // Content
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            // decoration: BoxDecoration(
            //   color: backgroundColor,
            //   borderRadius: BorderRadius.circular(12.r),
            //   border: Border.all(color: statusColor.withOpacity(0.2), width: 1),
            // ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: AppTypography.bodySmall.copyWith(
                    fontFamily: 'Karla',
                    fontSize: 11.sp,
                    letterSpacing: 0.5,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    fontFamily: 'Karla',
                    fontSize: 14.sp,
                    letterSpacing: -0.2,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountDetails() {
    final isDayfiTransfer =
        widget.transaction.source.accountType?.toLowerCase() == 'dayfi' ||
        widget.transaction.beneficiary.accountType?.toLowerCase() == 'dayfi';

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Transaction Details",
            style: AppTypography.bodyLarge.copyWith(
              fontFamily: 'CabinetGrotesk',
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 16.h),
          if (isDayfiTransfer)
            _buildDetailRow(
              "DayFi Tag",
              widget.transaction.beneficiary.accountNumber != null &&
                      widget.transaction.beneficiary.accountNumber!.isNotEmpty
                  ? (widget.transaction.beneficiary.accountNumber!.startsWith(
                        '@',
                      )
                      ? widget.transaction.beneficiary.accountNumber!
                      : '@${widget.transaction.beneficiary.accountNumber!}')
                  : "N/A",
            )
          else
            _buildDetailRow(
              "Account number",
              widget.transaction.source.accountNumber ?? "N/A",
            ),
          if (!isDayfiTransfer) _buildDetailRow("Bank", _getBankName()),
          _buildDetailRow(
            "Send type",
            isDayfiTransfer
                ? "DayFi Tag"
                : _getChannelDisplayName(widget.transaction.sendChannel),
          ),
          _buildDetailRow(
            "Transaction ID",
            widget.transaction.id.substring(0, 8).toUpperCase(),
          ),
          _buildDetailRow(
            "Status",
            _getStatusTextDisplay(widget.transaction.status),
          ),
          if (widget.transaction.reason != null &&
              widget.transaction.reason!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Divider(
              height: 16.h,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            ),
            SizedBox(height: 8.h),

            _buildDetailRow(
              "Description",
              _capitalizeWords(widget.transaction.reason!),
            ),
          ],
        ],
      ),
    );
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

  String _getStatusTextDisplay(String status) {
    switch (status.toLowerCase()) {
      case 'success-collection':
      case 'success-payment':
      case 'success':
        return 'Completed';
      case 'pending-collection':
      case 'pending-payment':
      case 'pending':
        return 'Pending';
      case 'failed-collection':
      case 'failed-payment':
      case 'failed':
        return 'Failed';
      default:
        return 'Unknown';
    }
  }

  Widget _buildRecipientDetails() {
    final isDayfiTransfer =
        widget.transaction.source.accountType?.toLowerCase() == 'dayfi' ||
        widget.transaction.beneficiary.accountType?.toLowerCase() == 'dayfi';

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recipient Details",
            style: AppTypography.bodyLarge.copyWith(
              fontFamily: 'CabinetGrotesk',
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 16.h),
          _buildDetailRow("Name", widget.transaction.beneficiary.name),
          if (isDayfiTransfer &&
              widget.transaction.beneficiary.accountNumber != null &&
              widget.transaction.beneficiary.accountNumber!.isNotEmpty)
            _buildDetailRow(
              "DayFi Tag",
              widget.transaction.beneficiary.accountNumber!.startsWith('@')
                  ? widget.transaction.beneficiary.accountNumber!
                  : '@${widget.transaction.beneficiary.accountNumber!}',
            ),
          if (isDayfiTransfer &&
              widget.transaction.beneficiary.accountNumber != null &&
              widget.transaction.beneficiary.accountNumber!.isNotEmpty)
            _buildDetailRow(
              "Username",
              widget.transaction.beneficiary.accountNumber!.startsWith('@')
                  ? widget.transaction.beneficiary.accountNumber!.substring(1)
                  : widget.transaction.beneficiary.accountNumber!,
            ),
          // _buildDetailRow(
          //   "Phone",
          //   widget.transaction.beneficiary.phone,
          // ),
          // _buildDetailRow(
          //   "Email",
          //   widget.transaction.beneficiary.email,
          // ),
          if (widget.transaction.beneficiary.country.isNotEmpty)
            _buildDetailRow(
              "Country",
              _getCountryName(widget.transaction.beneficiary.country),
            ),
          // _buildDetailRow(
          //   "Address",
          //   widget.transaction.beneficiary.address,
          // ),
          // _buildDetailRow(
          //   "ID Type",
          //   _getIDTypeDisplay(widget.transaction.beneficiary.idType),
          // ),
          // _buildDetailRow(
          //   "ID Number",
          //   widget.transaction.beneficiary.idNumber,
          // ),
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
                textAlign: TextAlign.end,
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
    final isTopUp = _isWalletTopUp();
    final isFeeZero = _isFeeZero();

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Payment Summary",
            style: AppTypography.bodyLarge.copyWith(
              fontFamily: 'CabinetGrotesk',
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 16.h),
          _buildSummaryRow(
            "Reference number",
            widget.transaction.id,
            showCopy: true,
          ),
          if (!isTopUp) ...[
            _buildSummaryRow(
              "Exchange rate",
              exchangeRate,
              isLoading: _isRatesLoading,
            ),
            _buildSummaryRow(
              "Recipient got",
              receiveAmount,
              isLoading: _isRatesLoading,
            ),
          ],
          // Only show fee if it's not zero
          if (!isFeeZero) _buildSummaryRow("Fee", fee),
          Divider(
            height: 24.h,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
          ),
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
    bool isDescription = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isDescription ? 0 : 12.h),
      child:
          isDescription
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.bodyMedium.copyWith(
                      fontFamily: 'Karla',
                      fontSize: 14.sp,
                      letterSpacing: -.4,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    value,
                    style: AppTypography.bodyMedium.copyWith(
                      fontFamily: 'Karla',
                      fontSize: 14.sp,
                      letterSpacing: -.2,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.8),
                      height: 1.4,
                    ),
                  ),
                ],
              )
              : Row(
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
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
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
                            child:
                                isLoading
                                    ? SizedBox(
                                      width: 20.w,
                                      height: 20.w,
                                      child:
                                          LoadingAnimationWidget.horizontalRotatingDots(
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
                                        fontWeight:
                                            isTotal
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                      ),
                                      textAlign: TextAlign.end,
                                    ),
                          ),
                        ),

                        if (showCopy) ...[
                          SizedBox(width: 8.w),
                          Semantics(
                            button: true,
                            label: 'Copy reference number',
                            hint: 'Double tap to copy to clipboard',
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Clipboard.setData(ClipboardData(text: value));
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
          text: "I have paid",
          onPressed: () {
            _showPaymentConfirmationDialog();
          },
          borderRadius: 56.r,
          backgroundColor: AppColors.success500,
          width: double.infinity,
          height: 56.h,
        ),
        SizedBox(height: 12.h),
        PrimaryButton(
          text: "I have not paid",
          onPressed: () {
            // TODO: Implement not paid action
            _showNotPaidDialog();
          },
          width: double.infinity,
          height: 56.h,
          borderRadius: 56.r,
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
          borderRadius: 56.r,
          width: double.infinity,
          height: 56.h,
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
      final formattedAmount = StringUtils.formatNumberWithCommas(
        _calculatedReceiveAmount,
      );
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
    final formattedAmount = StringUtils.formatNumberWithCommas('0.00');
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
      case 'CDF':
        return 'CDF ';
      default:
        return '$currencyCode ';
    }
  }

  /// Calculate total amount paid
  String _calculateTotal() {
    if (widget.transaction.sendAmount != null &&
        widget.transaction.sendAmount! > 0) {
      // Fee is now 0, so total is just the send amount
      final feeAmount = 0.0; // TODO: Get actual fee from transaction data
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
    if (widget.transaction.sendAmount == null ||
        widget.transaction.sendAmount! <= 0) {
      return;
    }

    setState(() {
      _isRatesLoading = true;
    });

    try {
      // Fetch rates for both currencies in parallel
      final sendCurrency = 'NGN';
      final receiveCurrency = _getCurrencyCodeFromCountry(
        widget.transaction.beneficiary.country,
      );

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

    final sendSellRate = double.tryParse(
      _sendCurrencyRates!['sell']?.toString() ?? '',
    );
    final receiveBuyRate = double.tryParse(
      _receiveCurrencyRates!['buy']?.toString() ?? '',
    );

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
    final receiveCurrency = _getCurrencyCodeFromCountry(
      widget.transaction.beneficiary.country,
    );
    final receiveSymbol = _getCurrencySymbolFromCode(receiveCurrency);

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
  }

  String _formatDateTime(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp).toLocal();
      // Subtract 1 hour to correct timezone offset
      final correctedDateTime = dateTime.subtract(const Duration(hours: 1));

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final transactionDate = DateTime(
        correctedDateTime.year,
        correctedDateTime.month,
        correctedDateTime.day,
      );

      String dateStr;
      if (transactionDate == today) {
        dateStr = "Today";
      } else if (transactionDate == today.subtract(const Duration(days: 1))) {
        dateStr = "Yesterday";
      } else {
        dateStr =
            "${correctedDateTime.day}${_getOrdinalSuffix(correctedDateTime.day)} ${_getMonthName(correctedDateTime.month)}";
      }

      final timeStr =
          "${correctedDateTime.hour.toString().padLeft(2, '0')}:${correctedDateTime.minute.toString().padLeft(2, '0')} ${correctedDateTime.hour >= 12 ? 'PM' : 'AM'}";

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
      // Check if it's a DayFi transfer
      if (widget.transaction.source.accountType?.toLowerCase() == 'dayfi' ||
          widget.transaction.beneficiary.accountType?.toLowerCase() ==
              'dayfi') {
        return 'DayFi';
      }

      // Try to get network name from send view model
      final sendState = ref.read(sendViewModelProvider);

      // Find network by network ID
      if (widget.transaction.source.networkId != null &&
          widget.transaction.source.networkId!.isNotEmpty) {
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
      if (widget.transaction.source.accountType?.toLowerCase() == 'dayfi') {
        return 'DayFi';
      }
      return widget.transaction.source.accountType?.toUpperCase() ?? 'Unknown';
    }
  }

  void _showPaymentConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => _buildPaymentConfirmationDialog(),
    );
  }

  Widget _buildPaymentConfirmationDialog() {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: Container(
        padding: EdgeInsets.all(28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.success400, AppColors.success600],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success500.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Are you sure you have completed the payment?',
              style: TextStyle(
                fontFamily: 'CabinetGrotesk',
                fontSize: 19.sp,
                // height: 1.6,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            PrimaryButton(
              text: 'Yes, Confirm',
              onPressed: () {
                Navigator.pop(context);
                // TODO: Implement payment confirmation logic
              },
              backgroundColor: AppColors.purple500,
              textColor: AppColors.neutral0,
              borderRadius: 56,
              height: 56.h,
              width: double.infinity,
              fullWidth: true,
              fontFamily: 'Karla',
              fontSize: 18,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.8,
            ),
            SizedBox(height: 12.h),
            SecondaryButton(
              text: 'Cancel',
              onPressed: () => Navigator.pop(context),
              borderColor: Colors.transparent,
              textColor: AppColors.purple500ForTheme(context),
              width: double.infinity,
              fullWidth: true,
              height: 56.h,
              borderRadius: 56,
              fontFamily: 'Karla',
              fontSize: 18,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.8,
            ),
          ],
        ),
      ),
    );
  }

  void _showNotPaidDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => _buildNotPaidDialog(),
    );
  }

  Widget _buildNotPaidDialog() {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: Container(
        padding: EdgeInsets.all(28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.warning400, AppColors.warning600],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.warning500.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Please complete your payment to proceed with the transfer.',
              style: TextStyle(
                fontFamily: 'CabinetGrotesk',
                fontSize: 19.sp,
                // height: 1.6,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            PrimaryButton(
              text: 'OK',
              onPressed: () => Navigator.pop(context),
              backgroundColor: AppColors.purple500,
              textColor: AppColors.neutral0,
              borderRadius: 56,
              height: 56.h,
              width: double.infinity,
              fullWidth: true,
              fontFamily: 'Karla',
              fontSize: 18,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.8,
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => _buildCancelDialog(),
    );
  }

  Widget _buildCancelDialog() {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: Container(
        padding: EdgeInsets.all(28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.error400, AppColors.error600],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.error500.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Are you sure you want to cancel this transfer?',
              style: TextStyle(
                fontFamily: 'CabinetGrotesk',
                fontSize: 19.sp,
                // height: 1.6,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            PrimaryButton(
              text: 'Yes, Cancel Transfer',
              onPressed: () {
                Navigator.pop(context);
                // TODO: Implement cancel transfer logic
              },
              backgroundColor: AppColors.error500,
              textColor: Colors.white,
              borderRadius: 56,
              height: 56.h,
              width: double.infinity,
              fullWidth: true,
              fontFamily: 'Karla',
              fontSize: 18,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.8,
            ),
            SizedBox(height: 12.h),
            SecondaryButton(
              text: 'No, Keep Transfer',
              onPressed: () => Navigator.pop(context),
              borderColor: Colors.transparent,
              textColor: AppColors.purple500ForTheme(context),
              width: double.infinity,
              fullWidth: true,
              height: 56.h,
              borderRadius: 56,
              fontFamily: 'Karla',
              fontSize: 18,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.8,
            ),
          ],
        ),
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

  /// Get channel display name
  String _getChannelDisplayName(String? channel) {
    if (channel == null || channel.isEmpty) return 'N/A';

    switch (channel.toLowerCase()) {
      case 'dayfi':
      case 'dayfi_tag':
        return 'DayFi Tag';
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

  /// Get country name from country code
  String _getCountryName(String countryCode) {
    switch (countryCode.toUpperCase()) {
      case 'CD':
        return 'Democratic Republic of Congo';
      case 'RW':
        return 'Rwanda';
      case 'NG':
        return 'Nigeria';
      case 'KE':
        return 'Kenya';
      case 'UG':
        return 'Uganda';
      case 'TZ':
        return 'Tanzania';
      case 'ZA':
        return 'South Africa';
      case 'BW':
        return 'Botswana';
      case 'GH':
        return 'Ghana';
      case 'SN':
        return 'Senegal';
      case 'CI':
        return 'Côte d\'Ivoire';
      case 'CM':
        return 'Cameroon';
      case 'BF':
        return 'Burkina Faso';
      case 'ML':
        return 'Mali';
      case 'NE':
        return 'Niger';
      case 'TD':
        return 'Chad';
      case 'CF':
        return 'Central African Republic';
      case 'GA':
        return 'Gabon';
      case 'CG':
        return 'Republic of Congo';
      case 'AO':
        return 'Angola';
      case 'ZM':
        return 'Zambia';
      case 'ZW':
        return 'Zimbabwe';
      case 'MW':
        return 'Malawi';
      case 'MZ':
        return 'Mozambique';
      case 'MG':
        return 'Madagascar';
      case 'MU':
        return 'Mauritius';
      case 'SC':
        return 'Seychelles';
      case 'KM':
        return 'Comoros';
      case 'DJ':
        return 'Djibouti';
      case 'ET':
        return 'Ethiopia';
      case 'ER':
        return 'Eritrea';
      case 'SO':
        return 'Somalia';
      case 'SS':
        return 'South Sudan';
      case 'SD':
        return 'Sudan';
      case 'EG':
        return 'Egypt';
      case 'LY':
        return 'Libya';
      case 'TN':
        return 'Tunisia';
      case 'DZ':
        return 'Algeria';
      case 'MA':
        return 'Morocco';
      case 'LR':
        return 'Liberia';
      case 'SL':
        return 'Sierra Leone';
      case 'GN':
        return 'Guinea';
      case 'GW':
        return 'Guinea-Bissau';
      case 'CV':
        return 'Cape Verde';
      case 'ST':
        return 'São Tomé and Príncipe';
      case 'GQ':
        return 'Equatorial Guinea';
      case 'BI':
        return 'Burundi';
      default:
        return countryCode;
    }
  }

  /// Check if this is a wallet top-up transaction
  bool _isWalletTopUp() {
    final profileState = ref.read(profileViewModelProvider);
    final user = profileState.user;

    if (user != null) {
      final userFullName =
          '${user.firstName} ${user.lastName}'.trim().toUpperCase();
      final beneficiaryName =
          widget.transaction.beneficiary.name.trim().toUpperCase();
      return beneficiaryName == userFullName ||
          beneficiaryName == 'SELF FUNDING' ||
          beneficiaryName.contains('SELF') &&
              beneficiaryName.contains('FUNDING');
    }

    return false;
  }

  /// Check if fee is zero
  bool _isFeeZero() {
    final fee = _getTransactionFee();
    // Remove currency symbol and check if it's 0.00
    final feeValue = fee.replaceAll(RegExp(r'[^\d.]'), '');
    final feeAmount = double.tryParse(feeValue) ?? 0.0;
    return feeAmount == 0.0;
  }

  /// Build bank account details for wallet top-up
  Widget _buildBankAccountDetails() {
    final isDayfiTransfer =
        widget.transaction.source.accountType?.toLowerCase() == 'dayfi' ||
        widget.transaction.beneficiary.accountType?.toLowerCase() == 'dayfi';

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isDayfiTransfer ? "DayFi Tag Details" : "Bank Account Details",
            style: AppTypography.bodyLarge.copyWith(
              fontFamily: 'CabinetGrotesk',
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 16.h),
          if (isDayfiTransfer) ...[
            if (widget.transaction.beneficiary.accountNumber != null &&
                widget.transaction.beneficiary.accountNumber!.isNotEmpty)
              _buildDetailRow(
                "DayFi Tag",
                widget.transaction.beneficiary.accountNumber!.startsWith('@')
                    ? widget.transaction.beneficiary.accountNumber!
                    : '@${widget.transaction.beneficiary.accountNumber!}',
              ),
            if (widget.transaction.beneficiary.name.isNotEmpty)
              _buildDetailRow("Username", widget.transaction.beneficiary.name),
          ] else ...[
            if (widget.transaction.source.accountNumber != null &&
                widget.transaction.source.accountNumber!.isNotEmpty)
              _buildDetailRow(
                "Account number",
                widget.transaction.source.accountNumber!,
              ),
            _buildDetailRow("Bank", _getBankName()),
          ],
        ],
      ),
    );
  }

  String _getRecipientDisplayName() {
    // Check if this is a DayFi tag transfer
    final isDayfiTransfer =
        widget.transaction.source.accountType?.toLowerCase() == 'dayfi' ||
        widget.transaction.beneficiary.accountType?.toLowerCase() == 'dayfi';

    if (isDayfiTransfer) {
      // For DayFi transfers, show the recipient's DayFi tag
      if (widget.transaction.beneficiary.accountNumber != null &&
          widget.transaction.beneficiary.accountNumber!.isNotEmpty) {
        final tag = widget.transaction.beneficiary.accountNumber!;
        final displayTag =
            tag.startsWith('@') ? tag.toUpperCase() : '@${tag.toUpperCase()}';
        return 'To $displayTag';
      }
      // Fallback to beneficiary name if no account number
      return 'To ${widget.transaction.beneficiary.name.toUpperCase()}';
    }

    final profileState = ref.read(profileViewModelProvider);
    final user = profileState.user;

    if (user != null) {
      // Build user's full name from first name and last name
      final userFullName =
          '${user.firstName} ${user.lastName}'.trim().toUpperCase();
      final beneficiaryName =
          widget.transaction.beneficiary.name.trim().toUpperCase();

      // Check if beneficiary name matches user's full name or is SELF FUNDING
      if (beneficiaryName == userFullName ||
          beneficiaryName == 'SELF FUNDING' ||
          beneficiaryName.contains('SELF') &&
              beneficiaryName.contains('FUNDING')) {
        return 'WALLET FUNDED';
      }
    }

    // Default: return "To [beneficiary name]" in uppercase
    return 'To ${widget.transaction.beneficiary.name.toUpperCase()}';
  }

  // Get transaction type icon (inflow/outflow)
  String _getTransactionTypeIcon(String status) {
    // Collection = money coming in (inflow)
    if (status.toLowerCase().contains('collection')) {
      return 'assets/icons/svgs/arrow-narrow-down.svg'; // Down arrow for inflow
    }
    // Payment = money going out (outflow)
    else if (status.toLowerCase().contains('payment')) {
      return 'assets/icons/svgs/arrow-narrow-up.svg'; // Up arrow for outflow
    }
    return 'assets/icons/svgs/info-circle.svg';
  }

  // Get transaction type color (inflow/outflow)
  Color _getTransactionTypeColor(String status) {
    // Collection = money coming in (green)
    if (status.toLowerCase().contains('collection')) {
      return AppColors.success500;
    }
    // Payment = money going out (orange/warning)
    else if (status.toLowerCase().contains('payment')) {
      return AppColors.warning500;
    }
    return AppColors.neutral500;
  }
}
