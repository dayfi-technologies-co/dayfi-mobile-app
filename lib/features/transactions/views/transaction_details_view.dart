import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/common/constants/username_copy.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/common/widgets/dayfi_loading_indicator.dart';
import 'package:dayfi/common/widgets/dayfi_screen_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/models/wallet_transaction.dart';
import 'package:dayfi/common/widgets/buttons/buttons.dart';
import 'package:dayfi/common/widgets/buttons/help_button.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/services/local/intercom_support_service.dart';
import 'package:dayfi/common/utils/string_utils.dart';
import 'package:dayfi/features/send/vm/send_viewmodel.dart';
import 'package:dayfi/services/remote/payment_service.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:dayfi/models/payment_response.dart' as payment;
import 'package:dayfi/features/recipients/helpers/recipient_history_helper.dart';
import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';
import 'package:dayfi/common/helpers/ngn_bank_transfer_partner.dart';
import 'package:dayfi/common/helpers/wallet_transaction_display.dart';
import 'package:dayfi/common/helpers/wallet_transaction_labels.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'package:dayfi/features/transactions/widgets/transaction_receipt_widget.dart';
import 'package:dayfi/common/utils/share_origin.dart';
import 'package:dayfi/common/utils/available_balance_calculator.dart';

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

  // Screenshot controller for sharing
  final ScreenshotController _screenshotController = ScreenshotController();

  // Services
  final PaymentService _paymentService = locator<PaymentService>();

  /// Get the effective status of the transaction (considering expiry)
  String get _effectiveStatus => AvailableBalanceCalculator.getEffectiveStatus(widget.transaction);

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
      appBar: DayfiScreenAppBar(
        title: 'Transaction Details',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: HelpButton(onTap: _navigateToContactUs),
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth > 600;
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isWide ? 500 : double.infinity,
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: isWide ? 24 : 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 16),

                    // Transaction Header
                    _buildTransactionHeader(),

                    SizedBox(height: 24),

                    // Status Timeline
                    _buildStatusTimeline(),

                    SizedBox(height: 20),

                    if (_shouldShowBankAccountDetails()) ...[
                      _buildBankAccountDetails(),
                      SizedBox(height: 16),
                    ],

                    if (_isBillPayment() || _isBillReversal()) ...[
                      _buildBillDetails(),
                      SizedBox(height: 16),
                      _buildPaymentSummary(),
                    ] else if (!_isWalletTopUp()) ...[
                      // Account Details
                      if (!_effectiveStatus.toLowerCase().contains(
                        'collection',
                      ))
                        _buildAccountDetails(),
                      if (!_effectiveStatus.toLowerCase().contains(
                        'collection',
                      ))
                        SizedBox(height: 16),

                      // Sender Details (for collections) or Recipient Details (for payments)
                      _effectiveStatus.toLowerCase().contains(
                            'collection',
                          )
                          ? _buildSenderDetails()
                          : _buildRecipientDetails(),
                      SizedBox(height: 16),
                      _buildPaymentSummary(),
                    ] else ...[
                      _buildPaymentSummary(),
                    ],

                    SizedBox(height: 18),

                    Builder(
                      builder: (shareContext) {
                        return TextButton(
                          style: TextButton.styleFrom(
                            splashFactory: NoSplash.splashFactory,
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.transparent,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            alignment: Alignment.center,
                          ),
                          onPressed: () =>
                              _shareTransactionReceipt(shareContext),
                          child: Text(
                            'Share transaction',
                            style: TextStyle(
                              fontFamily: 'Chirp',
                              color: AppColors.purple500ForTheme(context),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -.40,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTransactionHeader() {
    final amount = _getTransactionAmount();
    final recipientName = WalletTransactionDisplay.detailPrimaryLabel(
      widget.transaction,
    );
    final networkSubtitle =
        WalletTransactionDisplay.outboundNetworkSubtitle(widget.transaction);
    final payoutProfile = WalletTransactionDisplay.resolveLocalPayout(
      widget.transaction,
    );
    final showLocalPayoutNgn =
        payoutProfile.isPayout && payoutProfile.hasLocalReceive;
    final dateTime = _formatDateTime(widget.transaction.timestamp);
    final isCollection = _effectiveStatus.toLowerCase().contains(
      'collection',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Amount
        Text(
          _formatHeaderAmount(amount),

          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontFamily: 'FunnelDisplay',
            fontSize: 24,
            letterSpacing: -.25,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        if (showLocalPayoutNgn) ...[
          SizedBox(height: 4),
          Text(
            WalletTransactionDisplay.payoutReceiveAmountText(
                  widget.transaction,
                ) ??
                '',
            style: AppTypography.bodyMedium.copyWith(
              fontFamily: 'Karla',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: -.2,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withOpacity(0.65),
            ),
          ),
        ],

        SizedBox(height: 8),

        // Recipient
        Row(
          children: [
            // Transaction Type Icon (Inflow/Outflow)
            SizedBox(
              width: 40,
              height: 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  SvgPicture.asset(
                    'assets/icons/svgs/account.svg',
                    height: 40,
                    color: WalletTransactionDisplay.typeIconColor(
                      widget.transaction,
                    ),
                  ),
                  // Foreground icon
                  Center(
                    child: SvgPicture.asset(
                      WalletTransactionDisplay.typeIconAsset(
                        widget.transaction,
                      ),
                      height: WalletTransactionDisplay.typeIconHeight(
                        widget.transaction,
                      ),
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipientName,
                    style: AppTypography.bodyLarge.copyWith(
                      fontFamily: 'Chirp',
                      fontSize: 16,
                      letterSpacing: -.25,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  if (networkSubtitle != null && networkSubtitle.isNotEmpty) ...[
                    SizedBox(height: 4),
                    Text(
                      networkSubtitle,
                      style: AppTypography.bodyMedium.copyWith(
                        fontFamily: 'Chirp',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -.2,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.65),
                      ),
                    ),
                  ],
                  if (WalletTransactionDisplay.ngnBankDepositFx(
                        widget.transaction,
                      ) !=
                      null &&
                      !WalletTransactionDisplay.isCrossBorderBankSend(
                        widget.transaction,
                      )) ...[
                    SizedBox(height: 4),
                    Text(
                      WalletTransactionDisplay.formatNgnBankDepositSubtitle(
                        widget.transaction,
                      ),
                      style: AppTypography.bodyMedium.copyWith(
                        fontFamily: 'Chirp',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -.2,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.65),
                      ),
                    ),
                  ],

                  Text(
                    dateTime,
                    style: AppTypography.bodyMedium.copyWith(
                      fontFamily: 'Chirp',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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
            // SizedBox(width: 12),
            // _buildStatusIcon(),
          ],
        ),

        SizedBox(height: 4),

        // Date
      ],
    );
  }

  Widget _buildStatusIcon() {
    final status = _effectiveStatus.toLowerCase();

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: _getStatusBackgroundColor(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: SvgPicture.asset(
          _getStatusIcon(status),
          height: 44,
          width: 44,
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
      case 'expired-payment':
        return "assets/icons/svgs/circle-x.svg";
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
      case 'expired-payment':
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
        return Theme.of(context).colorScheme.primary.withOpacity(0.1);
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
      case 'expired-payment':
        return AppColors.error500;
      default:
        return AppColors.neutral500;
    }
  }

  Widget _buildStatusTimeline() {
    final status = _effectiveStatus.toLowerCase().replaceAll('_', '-');
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

    final isFailed = status.contains('failed');
    final isExpired = status.contains('expired');
    final isOutboundSend =
        WalletTransactionLabels.isDebit(widget.transaction) &&
        (isPayment ||
            WalletTransactionDisplay.isCrossBorderBankSend(widget.transaction));
    final isFailedOrExpiredPayment =
        isOutboundSend && (isFailed || isExpired);

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildTimelineItem(
            isCompleted: true,
            isActive: false,
            date: dateTime.split(',')[0],
            title: () {
              final featureTimeline =
                  WalletTransactionLabels.statusTimelineTitle(
                widget.transaction,
                sendAmount,
              );
              if (featureTimeline.isNotEmpty) return featureTimeline;
              if (isSuccess && isCollection) {
                return "You received $sendAmount into your balance";
              }
              if (isSuccess && isPayment) {
                return "You sent $sendAmount to ${recipientName.replaceAll("Sent to ", "")}";
              }
              if (isCollection) {
                return "You set up a balance top-up of $sendAmount";
              }
              return "You've set up a $transferPhrase of $sendAmount to $recipientName";
            }(),
            isFirst: true,
            isLast: isSuccess,
          ),

          if (isFailedOrExpiredPayment) ...[
            SizedBox(height: 8),
            _buildTimelineItem(
              isCompleted: true,
              isActive: false,
              date: dateTime.split(',')[0],
              title: "We're processing your payment",
              isFirst: false,
              isLast: false, 
            ),
            SizedBox(height: 8),
            _buildTimelineItem(
              isCompleted: true,
              isActive: false,
              date: dateTime.split(',')[0],
              title:
                  isExpired ? "Transaction expired" : "Transaction failed",
              isFirst: false,
              isLast: false,
            ),
            SizedBox(height: 8),
            _buildTimelineItem(
              isCompleted: true,
              isActive: false,
              date: dateTime.split(',')[0],
              title: "Your balance has been credited back",
              isFirst: false,
              isLast: true,
            ),
          ] else if (!isSuccess) ...[
            SizedBox(height: 8),

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

            // For failed or expired collections, show failure/expiry only
            if (!isPending &&
                (isFailed || isExpired) &&
                !isFailedOrExpiredPayment) ...[
              SizedBox(height: 8),
              _buildTimelineItem(
                isCompleted: false,
                isActive: false,
                date: dateTime.split(',')[0],
                title:
                    isExpired ? "Transaction expired" : "Transaction failed",
                isFirst: false,
                isLast: true,
              ),
            ],

            // Legacy failed-payment branch (wallet sends use isFailedOrExpiredPayment above)
            if (!isPending &&
                (isFailed || isExpired) &&
                isPayment &&
                !isFailedOrExpiredPayment) ...[
              SizedBox(height: 8),
              _buildTimelineItem(
                isCompleted: false,
                isActive: false,
                date: dateTime.split(',')[0],
                title:
                    isExpired ? "Transaction expired" : "Transaction failed",
                isFirst: false,
                isLast: false,
              ),
              SizedBox(height: 20),
              _buildTimelineItem(
                isCompleted: false,
                isActive: false,
                date: dateTime.split(',')[0],
                title: "Your balance has been credited back",
                isFirst: false,
                isLast: true,
              ),
            ],

            // Third item for collections: Funds received into wallet
            if (isCollection && isPending) ...[
              SizedBox(height: 20),
              _buildTimelineItem(
                isCompleted: false,
                isActive: false,
                date: dateTime.split(',')[0],
                title: "You'll receive $sendAmount into your balance",
                isFirst: false,
                isLast: true,
              ),
            ],

            // Third item for payments: Recipient receives funds (only for non-top-ups and pending)
            if (isPayment && !isTopUp && isPending) ...[
              SizedBox(height: 20),
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
           Container(
              width: 16,
              height: 16,
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
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        )
                        : null,
              ),
            ),
          
          ],
        ),

        SizedBox(width: 20),

        // Content
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            // decoration: BoxDecoration(
            //   color: backgroundColor,
            //   borderRadius: BorderRadius.circular(12),
            //   border: Border.all(color: statusColor.withOpacity(0.2), width: 1),
            // ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: AppTypography.bodySmall.copyWith(
                    fontFamily: 'Chirp',
                    fontSize: 12.5,
                    letterSpacing: -.25,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    fontFamily: 'Chirp',
                    fontSize: 14,
                    letterSpacing: -0.2,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.2,
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
    final tx = widget.transaction;
    final kind = RecipientHistoryHelper.transactionKind(tx);
    final isP2p = kind == TransactionRecipientKind.p2p;
    final isCrypto = kind == TransactionRecipientKind.crypto;
    final isMobile = kind == TransactionRecipientKind.mobile;
    final isWalletBankSend = RecipientHistoryHelper.isWalletFundedBankSend(tx);
    final payoutCurrency =
        WalletTransactionDisplay.payoutCurrencyLabel(tx);
    final currency =
        payoutCurrency ?? RecipientHistoryHelper.inferLedgerCurrency(tx);

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Transaction Details",
            style: AppTypography.bodySmall.copyWith(
              fontFamily: 'Chirp',
              fontSize: 12.5,
              letterSpacing: -.25,
              height: 1.2,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          SizedBox(height: 16),
          if (isP2p) ...[
            _buildDetailRow(
              UsernameCopy.label,
              RecipientHistoryHelper.p2pUsername(tx) ??
                  (RecipientHistoryHelper.p2pTagFromTransaction(tx) != null
                      ? '@${RecipientHistoryHelper.p2pTagFromTransaction(tx)}'
                      : 'N/A'),
            ),
          ] else if (isCrypto) ...[
            _buildDetailRow(
              'Wallet address',
              RecipientHistoryHelper.truncateAddress(
                RecipientHistoryHelper.cryptoAddress(tx),
              ),
            ),
            _buildDetailRow(
              'Network',
              RecipientHistoryHelper.cryptoNetworkLabel(tx).isNotEmpty
                  ? RecipientHistoryHelper.cryptoNetworkLabel(tx)
                  : 'Stellar',
            ),
            _buildDetailRow(
              'Asset',
              RecipientHistoryHelper.cryptoAssetLabel(tx),
            ),
          ] else if (isMobile) ...[
            _buildDetailRow(
              'Phone number',
              tx.source.accountNumber ?? 'N/A',
            ),
            _buildDetailRow('Provider', _getBankName()),
          ] else if (isWalletBankSend) ...[
            _buildDetailRow('Paid from', 'Global USD wallet'),
            _buildDetailRow(
              'Destination bank',
              RecipientHistoryHelper.transactionRecipientBank(tx) ??
                  _getBankName(),
            ),
          ] else ...[
            _buildDetailRow(
              "Account number",
              tx.source.accountNumber ?? "N/A",
            ),
            _buildDetailRow("Bank", _getBankName()),
          ],
          _buildDetailRow(
            "Send type",
            WalletTransactionLabels.sendTypeLabel(tx).isNotEmpty
                ? WalletTransactionLabels.sendTypeLabel(tx)
                : _getChannelDisplayName(
                    isP2p
                        ? 'p2p'
                        : isCrypto
                            ? 'crypto'
                            : (tx.receiveChannel ?? tx.sendChannel),
                  ),
          ),
          if (currency != null && currency.isNotEmpty)
            _buildDetailRow('Currency', currency),
          _buildDetailRow(
            "Transaction ID",
            tx.id.substring(0, tx.id.length > 12 ? 12 : tx.id.length).toUpperCase(),
          ),
          _buildDetailRow(
            "Status",
            _getStatusTextDisplay(_effectiveStatus),
          ),
          if (tx.reason != null && tx.reason!.isNotEmpty) ...[
            SizedBox(height: 8),
            Divider(
              height: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            ),
            SizedBox(height: 8),
            _buildDetailRow(
              "Description",
              WalletTransactionDisplay.humanReason(tx),
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
        return 'Success';
      case 'pending-collection':
      case 'pending-payment':
      case 'pending':
        return 'Pending';
      case 'expired-payment':
        return 'Expired';
      case 'failed-collection':
      case 'failed-payment':
      case 'failed':
        return 'Failed';
      default:
        return 'Unknown';
    }
  }

  Widget _buildSenderDetails() {
    final isDayfiTransfer =
        widget.transaction.source.accountType?.toLowerCase() == 'dayfi' ||
        widget.transaction.beneficiary.accountType?.toLowerCase() == 'dayfi';

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Sender Details",
            style: AppTypography.bodySmall.copyWith(
              fontFamily: 'Chirp',
              fontSize: 12.5,
              letterSpacing: -.25,
              height: 1.2,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          SizedBox(height: 16),
          _buildDetailRow(
            "Name",
            widget.transaction.beneficiary.name.isNotEmpty
                ? widget.transaction.beneficiary.name
                : 'Self funding',
          ),
          if (isDayfiTransfer &&
              widget.transaction.beneficiary.accountNumber != null &&
              widget.transaction.beneficiary.accountNumber!.isNotEmpty)
            _buildDetailRow(
              UsernameCopy.label,
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
          if (widget.transaction.beneficiary.country.isNotEmpty)
            _buildDetailRow(
              "Country",
              _getCountryName(widget.transaction.beneficiary.country),
            ),
        ],
      ),
    );
  }

  Widget _buildRecipientDetails() {
    final tx = widget.transaction;
    if (WalletTransactionLabels.isDayEarn(tx) ||
        WalletTransactionLabels.isDayFlow(tx)) {
      final product =
          WalletTransactionLabels.isDayEarn(tx) ? 'DayEarn' : 'DayFlow';
      final potName = tx.beneficiary.accountNumber?.trim();
      final displayName = (potName != null && potName.isNotEmpty)
          ? potName
          : tx.beneficiary.name;
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plan details',
              style: AppTypography.bodySmall.copyWith(
                fontFamily: 'Chirp',
                fontSize: 12.5,
                letterSpacing: -.25,
                height: 1.2,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Product', product),
            _buildDetailRow('Name', displayName),
            _buildDetailRow(
              'Type',
              WalletTransactionLabels.isCredit(tx)
                  ? '$product withdrawal'
                  : '$product ${WalletTransactionLabels.isDayFlow(tx) ? 'lock' : 'deposit'}',
            ),
          ],
        ),
      );
    }

    final kind = RecipientHistoryHelper.transactionKind(tx);
    final isP2p = kind == TransactionRecipientKind.p2p;
    final isCrypto = kind == TransactionRecipientKind.crypto;
    final isMobile = kind == TransactionRecipientKind.mobile;
    final countryCode = RecipientHistoryHelper.recipientCountryCode(tx);

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recipient Details",
            style: AppTypography.bodySmall.copyWith(
              fontFamily: 'Chirp',
              fontSize: 12.5,
              letterSpacing: -.25,
              height: 1.2,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          SizedBox(height: 16),
          _buildDetailRow(
            "Name",
            RecipientHistoryHelper.transactionRecipientName(tx),
          ),
          if (isP2p) ...[
            _buildDetailRow(
              UsernameCopy.label,
              RecipientHistoryHelper.p2pUsername(tx) ??
                  (RecipientHistoryHelper.p2pTagFromTransaction(tx) != null
                      ? '@${RecipientHistoryHelper.p2pTagFromTransaction(tx)}'
                      : 'N/A'),
            ),
          ] else if (isCrypto) ...[
            _buildDetailRow(
              'Wallet address',
              RecipientHistoryHelper.truncateAddress(
                RecipientHistoryHelper.cryptoAddress(tx),
              ),
            ),
            _buildDetailRow(
              'Network',
              RecipientHistoryHelper.cryptoNetworkLabel(tx).isNotEmpty
                  ? RecipientHistoryHelper.cryptoNetworkLabel(tx)
                  : 'Stellar',
            ),
          ] else if (isMobile) ...[
            _buildDetailRow(
              'Phone number',
              tx.source.accountNumber ?? tx.beneficiary.phone,
            ),
          ] else ...[
            if (tx.source.accountNumber?.trim().isNotEmpty == true)
              _buildDetailRow('Account number', tx.source.accountNumber!.trim()),
            _buildDetailRow(
              'Bank',
              RecipientHistoryHelper.transactionRecipientBank(tx) ??
                  _getBankName(),
            ),
          ],
          if (countryCode.isNotEmpty)
            _buildDetailRow(
              isCrypto ? 'Region' : 'Country',
              _getCountryName(countryCode),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                fontFamily: 'Chirp',
                fontSize: 14,
                letterSpacing: -.4,
                fontWeight: FontWeight.w500,
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
                  fontFamily: 'Chirp',
                  fontSize: 16,
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
    final status = _effectiveStatus.toLowerCase();
    final ngnFx = WalletTransactionDisplay.ngnBankDepositFx(widget.transaction);
    final transferUsd = WalletTransactionDisplay.outboundTransferAmount(
      widget.transaction,
    );
    final showAmountSent =
        !isTopUp &&
        transferUsd != null &&
        transferUsd > 0 &&
        WalletTransactionDisplay.hasSeparateTransferFee(widget.transaction);
    final amountSentLabel = showAmountSent
        ? '\$${StringUtils.formatNumberWithCommas(transferUsd.toStringAsFixed(2))}'
        : null;

    if (_isBillReversal()) {
      return _buildBillRefundSummary(receiveAmount);
    }

    if (_isBillPayment()) {
      return _buildBillPaymentSummary(total);
    }

    if (ngnFx != null) {
      return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deposit Summary',
              style: AppTypography.bodySmall.copyWith(
                fontFamily: 'Chirp',
                fontSize: 12.5,
                letterSpacing: -.25,
                height: 1.2,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            SizedBox(height: 16),
            _buildSummaryRow(
              "Reference number",
              widget.transaction.id,
              showCopy: true,
            ),
            _buildSummaryRow(
              'Exchange rate',
              WalletTransactionDisplay.formatNgnPerUsd(ngnFx.ngnPerUsd),
            ),
            // Padding(
            //   padding: const EdgeInsets.only(bottom: 12),
            //   child: Text(
            //     WalletTransactionDisplay.ngnBankDepositRateFootnote,
            //     style: AppTypography.bodySmall.copyWith(
            //       fontFamily: 'Chirp',
            //       fontSize: 11.5,
            //       height: 1.3,
            //       color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
            //     ),
            //   ),
            // ),
            _buildSummaryRow(
              'Amount received',
              '₦${StringUtils.formatNumberWithCommas(ngnFx.ngnAmount.toStringAsFixed(2))}',
            ),
            _buildSummaryRow(
              'Wallet credit (USD)',
              '\$${StringUtils.formatNumberWithCommas(ngnFx.usdCredited.toStringAsFixed(2))}',
            ),
            Divider(
              height: 24,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            ),
            _buildSummaryRow(
              'Total received',
              '\$${StringUtils.formatNumberWithCommas(ngnFx.usdCredited.toStringAsFixed(2))}',
              isTotal: true,
            ),
          ],
        ),
      );
    }

    // Determine the recipient amount label based on transaction status
    String recipientLabel;
    if (status.contains('success')) {
      recipientLabel = "Recipient got";
    } else if (status.contains('failed') || status.contains('expired')) {
      recipientLabel = "Recipient would have got";
    } else if (status.contains('pending')) {
      recipientLabel = "Recipient will get";
    } else {
      recipientLabel = "Recipient got";
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _summarySectionTitle(),
            style: AppTypography.bodySmall.copyWith(
              fontFamily: 'Chirp',
              fontSize: 12.5,
              letterSpacing: -.25,
              height: 1.2,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          SizedBox(height: 16),
          _buildSummaryRow(
            "Reference number",
            widget.transaction.id,
            showCopy: true,
          ),
          if (!isTopUp && !_isDepositIncome()) ...[
            _buildSummaryRow(
              "Exchange rate",
              exchangeRate,
              isLoading: _isRatesLoading,
            ),
            if (amountSentLabel != null)
              _buildSummaryRow('Amount sent', amountSentLabel),
            _buildSummaryRow(
              recipientLabel,
              receiveAmount,
              isLoading: _isRatesLoading,
            ),
            if (NgnBankTransferPartner.matchesTransaction(widget.transaction)) ...[
              _buildSummaryRow(
                'Processing partner',
                NgnBankTransferPartner.name,
              ),
              _buildSummaryRow(
                'Expected credit',
                NgnBankTransferPartner.expectedCredit,
              ),
            ],
          ] else if (_isDepositIncome()) ...[
            _buildSummaryRow('Amount received', receiveAmount),
          ],
          if (!_isDepositIncome() || !_isFeeZero())
            _buildSummaryRow("Fee", fee),
          Divider(
            height: 24,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
          ),
          _buildSummaryRow(
            _totalSummaryLabel(),
            _isDepositIncome() ? _calculateDepositTotal() : total,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBillDetails() {
    final tx = widget.transaction;
    final biller = WalletTransactionLabels.billerDisplayName(tx);
    final customerId = WalletTransactionLabels.billCustomerId(tx);

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isBillReversal() ? 'Refund details' : 'Bill details',
            style: AppTypography.bodySmall.copyWith(
              fontFamily: 'Chirp',
              fontSize: 12.5,
              letterSpacing: -.25,
              height: 1.2,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          SizedBox(height: 16),
          if (!_isBillReversal()) ...[
            _buildDetailRow('Biller', biller),
            if (customerId != null) _buildDetailRow('Customer ID', customerId),
          ] else ...[
            _buildDetailRow(
              'Original reference',
              WalletTransactionLabels.billOriginalReference(tx) ?? tx.id,
            ),
          ],
          _buildDetailRow(
            'Send type',
            WalletTransactionLabels.sendTypeLabel(tx).isNotEmpty
                ? WalletTransactionLabels.sendTypeLabel(tx)
                : 'Bill pay',
          ),
          _buildDetailRow(
            'Status',
            _getStatusTextDisplay(_effectiveStatus),
          ),
        ],
      ),
    );
  }

  Widget _buildBillPaymentSummary(String total) {
    final headline = WalletTransactionLabels.billDetailHeadline(widget.transaction);
    final fx = WalletTransactionDisplay.billPaymentFx(widget.transaction);
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$headline summary',
            style: AppTypography.bodySmall.copyWith(
              fontFamily: 'Chirp',
              fontSize: 12.5,
              letterSpacing: -.25,
              height: 1.2,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          SizedBox(height: 16),
          _buildSummaryRow(
            'Reference number',
            widget.transaction.id,
            showCopy: true,
          ),
          if (fx != null) ...[
            if (fx.rateNgnPerUsd != null)
              _buildSummaryRow(
                'Exchange rate',
                WalletTransactionDisplay.formatNgnPerUsd(fx.ngnPerUsd),
              ),
            _buildSummaryRow(
              'Bill amount',
              '₦${StringUtils.formatNumberWithCommas(fx.ngnAmount.toStringAsFixed(2))}',
            ),
            _buildSummaryRow(
              'Wallet debit (USD)',
              '\$${StringUtils.formatNumberWithCommas(fx.usdCredited.toStringAsFixed(2))}',
            ),
          ] else
            _buildSummaryRow(
              'Amount paid',
              total,
            ),
          Divider(
            height: 24,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
          ),
          _buildSummaryRow(
            'Total paid',
            total,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBillRefundSummary(String amount) {
    final headline = WalletTransactionLabels.billDetailHeadline(widget.transaction);
    final fx = WalletTransactionDisplay.billPaymentFx(widget.transaction);
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$headline summary',
            style: AppTypography.bodySmall.copyWith(
              fontFamily: 'Chirp',
              fontSize: 12.5,
              letterSpacing: -.25,
              height: 1.2,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          SizedBox(height: 16),
          _buildSummaryRow(
            'Reference number',
            widget.transaction.id,
            showCopy: true,
          ),
          if (fx != null) ...[
            if (fx.rateNgnPerUsd != null)
              _buildSummaryRow(
                'Exchange rate',
                WalletTransactionDisplay.formatNgnPerUsd(fx.ngnPerUsd),
              ),
            _buildSummaryRow(
              'Bill amount',
              '₦${StringUtils.formatNumberWithCommas(fx.ngnAmount.toStringAsFixed(2))}',
            ),
            _buildSummaryRow(
              'Wallet credit (USD)',
              '\$${StringUtils.formatNumberWithCommas(fx.usdCredited.toStringAsFixed(2))}',
            ),
          ] else
            _buildSummaryRow('Amount refunded', amount),
          Divider(
            height: 24,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
          ),
          _buildSummaryRow(
            'Total returned',
            amount,
            isTotal: true,
          ),
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
      padding: EdgeInsets.only(bottom: isDescription ? 0 : 12),
      child:
          isDescription
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.bodyMedium.copyWith(
                      fontFamily: 'Chirp',
                      fontSize: 14,
                      letterSpacing: -.4,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    value,
                    style: AppTypography.bodyMedium.copyWith(
                      fontFamily: 'Chirp',
                      fontSize: 16,
                      letterSpacing: -.2,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.8),
                      height: 1.2,
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
                        fontFamily: 'Chirp',
                        fontSize: 14,
                        letterSpacing: -.4,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                  SizedBox(width: 24),
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
                                      width: 20,
                                      height: 20,
                                      child:
                                          LoadingAnimationWidget.horizontalRotatingDots(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                            size: 20,
                                          ),
                                    )
                                    : Text(
                                      value,
                                      style: AppTypography.bodyMedium.copyWith(
                                        fontFamily: 'Chirp',
                                        fontSize: 16,
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
                          SizedBox(width: 8),
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
                                height: 20,
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
          borderRadius: 56,
          backgroundColor: AppColors.success500,
          width: double.infinity,
          height: 56,
        ),
        SizedBox(height: 12),
        PrimaryButton(
          text: "I have not paid",
          onPressed: () {
            // TODO: Implement not paid action
            _showNotPaidDialog();
          },
          width: double.infinity,
          height: 56,
          borderRadius: 56,
          backgroundColor: Theme.of(context).colorScheme.surface,
          textColor: Theme.of(context).colorScheme.onSurface,
        ),
        SizedBox(height: 12),
        PrimaryButton(
          text: "Cancel transfer",
          onPressed: () {
            // TODO: Implement cancel transfer
            _showCancelDialog();
          },
          borderRadius: 56,
          width: double.infinity,
          height: 56,
          backgroundColor: AppColors.error500,
          textColor: Colors.white,
        ),
      ],
    );
  }

  String _formatHeaderAmount(String amount) {
    if (amount == 'N/A') return amount;
    final ngnFx = WalletTransactionDisplay.ngnBankDepositFx(widget.transaction);
    if (ngnFx != null) {
      final formatted = StringUtils.formatNumberWithCommas(
        ngnFx.usdCredited.toStringAsFixed(2),
      );
      return '\$$formatted';
    }
    final numeric = amount.replaceAll(RegExp(r'[^\d.]'), '');
    final parsed = double.tryParse(numeric.replaceAll(',', ''));
    if (parsed == null) return amount;
    final ledger = widget.transaction.ledgerCurrency?.toUpperCase() ?? '';
    final symbol = ledger.isNotEmpty
        ? _ledgerCurrencySymbol(ledger)
        : _paymentCurrencySymbol();
    final formatted = StringUtils.formatNumberWithCommas(parsed.toStringAsFixed(2));
    return '$symbol$formatted';
  }

  bool _isDepositIncome() =>
      WalletTransactionDisplay.isDepositIncome(widget.transaction);

  String _summarySectionTitle() =>
      _isDepositIncome() ? 'Deposit Summary' : 'Payment Summary';

  String _totalSummaryLabel() =>
      _isDepositIncome() ? 'Total received' : 'Total paid';

  String _calculateDepositTotal() {
    final receive = _getReceiveAmount();
    if (receive != 'N/A') return receive;
    return _getTransactionAmount();
  }

  bool _shouldShowActionButtons() {
    final status = _effectiveStatus.toLowerCase();
    return status == 'failed' || status == 'failed-collection' || status == 'expired-payment';
  }

  String _getTransactionAmount() {
    final ngnFx = WalletTransactionDisplay.ngnBankDepositFx(widget.transaction);
    if (ngnFx != null) {
      final formatted = StringUtils.formatNumberWithCommas(
        ngnFx.usdCredited.toStringAsFixed(2),
      );
      return '\$$formatted';
    }

    if (WalletTransactionDisplay.isCrossBorderBankSend(widget.transaction) ||
        WalletTransactionDisplay.resolveLocalPayout(widget.transaction).isPayout) {
      final amount = WalletTransactionDisplay.payoutSendAmountText(
        widget.transaction,
      );
      if (amount != 'N/A') return amount;
    }

    if (WalletTransactionLabels.isDebit(widget.transaction) &&
        (widget.transaction.ledgerCurrency ?? 'USD').toUpperCase() == 'USD' &&
        ((widget.transaction.receiveAmount ?? 0) >= 50 ||
            (widget.transaction.sendAmount ?? 0) >= 50)) {
      final header = WalletTransactionDisplay.amountText(widget.transaction);
      if (header != 'N/A') return header;
    }

    if (WalletTransactionDisplay.hasSeparateTransferFee(widget.transaction)) {
      final transfer = WalletTransactionDisplay.outboundTransferAmount(
        widget.transaction,
      );
      if (transfer != null && transfer > 0) {
        final formatted = StringUtils.formatNumberWithCommas(
          transfer.toStringAsFixed(2),
        );
        return '\$$formatted';
      }
    }

    // USD wallet debits: never label NGN-scale receive_amount as USD.
    if (WalletTransactionLabels.isDebit(widget.transaction) &&
        (widget.transaction.ledgerCurrency ?? 'USD').toUpperCase() == 'USD' &&
        (widget.transaction.receiveAmount ?? 0) >= 50) {
      final usd = WalletTransactionDisplay.outboundTransferAmount(
        widget.transaction,
      );
      if (usd != null && usd > 0) {
        return WalletTransactionDisplay.payoutSendAmountText(widget.transaction);
      }
    }

    // For pending transactions, use calculated amount from API if available
    final isPending = _effectiveStatus.toLowerCase().contains('pending');
    if (isPending && _calculatedReceiveAmount.isNotEmpty) {
      final currencyCode = _getCurrencyCodeFromCountry(
        widget.transaction.beneficiary.country,
      );
      final currencySymbol = _getCurrencySymbolFromCode(currencyCode);
      final formattedAmount = StringUtils.formatNumberWithCommas(
        _calculatedReceiveAmount,
      );
      return '$currencySymbol$formattedAmount';
    }

    // For completed/expired transactions, use the actual receive amount from transaction data
    if (widget.transaction.receiveAmount != null &&
        widget.transaction.receiveAmount! > 0 &&
        !WalletTransactionDisplay.resolveLocalPayout(widget.transaction).isPayout) {
      final ledger = widget.transaction.ledgerCurrency?.toUpperCase() ?? '';
      final currencySymbol = ledger.isNotEmpty
          ? _ledgerCurrencySymbol(ledger)
          : _getCurrencySymbolFromCode(
              _getCurrencyCodeFromCountry(widget.transaction.beneficiary.country),
            );
      final formattedAmount = StringUtils.formatNumberWithCommas(
        widget.transaction.receiveAmount!.toStringAsFixed(2),
      );
      return '$currencySymbol$formattedAmount';
    } else if (widget.transaction.sendAmount != null &&
        widget.transaction.sendAmount! > 0) {
      final ledger = widget.transaction.ledgerCurrency?.toUpperCase() ?? '';
      final currencySymbol = ledger.isNotEmpty
          ? _ledgerCurrencySymbol(ledger)
          : '₦';
      final formattedAmount = StringUtils.formatNumberWithCommas(
        widget.transaction.sendAmount!.toStringAsFixed(2),
      );
      return '$currencySymbol$formattedAmount';
    } else {
      return 'N/A';
    }
  }

  String _ledgerCurrencySymbol(String currency) {
    switch (currency) {
      case 'USD':
        return r'$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'NGN':
        return '₦';
      default:
        return '₦';
    }
  }

  String _effectivePaymentCurrency() {
    final ledger = widget.transaction.ledgerCurrency?.trim().toUpperCase() ?? '';
    if (ledger.isNotEmpty) return ledger;

    final reason = widget.transaction.reason?.toLowerCase() ?? '';
    if (reason.startsWith('p2p:') ||
        reason.contains('via p2p') ||
        widget.transaction.sendChannel == 'wallet') {
      if (widget.transaction.sendAmount != null &&
          widget.transaction.sendAmount! > 0) {
        return _getCurrencyCodeFromCountry(widget.transaction.beneficiary.country);
      }
    }

    return _getCurrencyCodeFromCountry(widget.transaction.beneficiary.country);
  }

  String _paymentCurrencySymbol() =>
      _getCurrencySymbolFromCode(_effectivePaymentCurrency());

  String _getReceiveAmount() {
    final payoutReceive = WalletTransactionDisplay.payoutReceiveAmountText(
      widget.transaction,
    );
    if (payoutReceive != null && payoutReceive.isNotEmpty) {
      return payoutReceive;
    }

    // Guard: NGN-scale receive on USD wallet must not use $.
    if (WalletTransactionLabels.isDebit(widget.transaction) &&
        (widget.transaction.ledgerCurrency ?? 'USD').toUpperCase() == 'USD' &&
        (widget.transaction.receiveAmount ?? 0) >= 50) {
      return WalletTransactionDisplay.formatNgnWhole(
        widget.transaction.receiveAmount!,
      );
    }

    final currencySymbol = _paymentCurrencySymbol();

    // Use calculated amount from API if available (for any transaction status)
    if (_calculatedReceiveAmount.isNotEmpty) {
      final formattedAmount = StringUtils.formatNumberWithCommas(
        _calculatedReceiveAmount,
      );
      return '$currencySymbol$formattedAmount';
    }

    // For completed transactions, calculate receive amount if not stored
    if (widget.transaction.receiveAmount != null &&
        widget.transaction.receiveAmount! > 0) {
      final formattedAmount = StringUtils.formatNumberWithCommas(
        widget.transaction.receiveAmount!.toStringAsFixed(2),
      );
      return '$currencySymbol$formattedAmount';
    } else if (widget.transaction.sendAmount != null &&
        widget.transaction.sendAmount! > 0) {
      // Same-currency wallet transfers (P2P, bank) — recipient gets send amount
      final convertedAmount = _calculateReceiveAmountFromSend();
      if (convertedAmount != null) {
        final formattedAmount = StringUtils.formatNumberWithCommas(
          convertedAmount.toStringAsFixed(2),
        );
        return '$currencySymbol$formattedAmount';
      } else {
        final formattedAmount = StringUtils.formatNumberWithCommas(
          widget.transaction.sendAmount!.toStringAsFixed(2),
        );
        return '$currencySymbol$formattedAmount';
      }
    } else {
      return 'N/A';
    }
  }

  /// Get currency code from country code
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

  /// Get transaction fee
  String _getTransactionFee() {
    final currencySymbol = _paymentCurrencySymbol();

    double? fee = widget.transaction.fee;
    if (fee == null || fee <= 0) {
      final meta = widget.transaction.ledgerMetadata?['feeUsd'];
      if (meta is num) {
        fee = meta.toDouble();
      } else {
        fee = double.tryParse('${meta ?? ''}');
      }
    }

    if (fee != null && fee > 0) {
      final formattedAmount = StringUtils.formatNumberWithCommas(
        fee.toStringAsFixed(2),
      );
      return '$currencySymbol$formattedAmount';
    }

    final formattedAmount = StringUtils.formatNumberWithCommas('0.00');
    return '$currencySymbol$formattedAmount';
  }

  /// Get exchange rate display
  String _getExchangeRate() {
    final payoutRate = WalletTransactionDisplay.payoutExchangeRateText(
      widget.transaction,
    );
    if (payoutRate != null && payoutRate.isNotEmpty) {
      return payoutRate;
    }

    if (WalletTransactionLabels.isDebit(widget.transaction) &&
        (widget.transaction.ledgerCurrency ?? 'USD').toUpperCase() == 'USD' &&
        (widget.transaction.receiveAmount ?? 0) >= 50) {
      final usd = WalletTransactionDisplay.outboundTransferAmount(
        widget.transaction,
      );
      final ngn = widget.transaction.receiveAmount;
      if (usd != null && usd > 0 && ngn != null && ngn >= 50) {
        return WalletTransactionDisplay.formatNgnPerUsd(ngn / usd);
      }
    }

    final paymentCurrency = _effectivePaymentCurrency();
    final paymentSymbol = _paymentCurrencySymbol();

    // Same-currency transfers (P2P username, same-wallet bank)
    if (widget.transaction.sendAmount != null &&
        widget.transaction.receiveAmount != null &&
        widget.transaction.sendAmount == widget.transaction.receiveAmount) {
      return '${paymentSymbol}1 = ${paymentSymbol}1';
    }
    if (widget.transaction.sendAmount != null &&
        widget.transaction.receiveAmount == null &&
        (widget.transaction.reason?.toLowerCase().startsWith('p2p:') ?? false)) {
      return '${paymentSymbol}1 = ${paymentSymbol}1';
    }

    // Use calculated rate from API if available
    if (_exchangeRate.isNotEmpty) {
      return _exchangeRate;
    }

    // Fallback to calculation from transaction data
    if (widget.transaction.sendAmount != null &&
        widget.transaction.receiveAmount != null &&
        widget.transaction.sendAmount! > 0 &&
        widget.transaction.receiveAmount! > 0 &&
        !WalletTransactionDisplay.resolveLocalPayout(widget.transaction).isPayout) {
      final usdSend = WalletTransactionDisplay.outboundTransferAmount(
            widget.transaction,
          ) ??
          (WalletTransactionDisplay.isUsdDebitAmount(
                widget.transaction.sendAmount!,
                widget.transaction,
              )
              ? widget.transaction.sendAmount!
              : null);
      final sendAmount = usdSend ?? widget.transaction.sendAmount!;
      final rate = widget.transaction.receiveAmount! / sendAmount;
      const sendCurrency = 'USD';
      final receiveCurrency =
          (widget.transaction.receiveAmount ?? 0) >= 50 &&
                  (widget.transaction.ledgerCurrency ?? 'USD')
                          .toUpperCase() ==
                      'USD'
              ? 'NGN'
              : _getCurrencyCodeFromCountry(
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
      final receiveCurrency = _effectivePaymentCurrency();
      final sendSymbol = _paymentCurrencySymbol();
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

  /// Calculate total amount paid (transfer + fee).
  String _calculateTotal() {
    final currencySymbol = _paymentCurrencySymbol();
    final total = WalletTransactionDisplay.outboundTotalDebited(
      widget.transaction,
    );
    if (total != null && total > 0) {
      final formattedAmount = StringUtils.formatNumberWithCommas(
        total.toStringAsFixed(2),
      );
      return '$currencySymbol$formattedAmount';
    }
    if (widget.transaction.sendAmount != null &&
        widget.transaction.sendAmount! > 0) {
      final feeAmount = widget.transaction.fee ?? 0.0;
      final transfer =
          WalletTransactionDisplay.outboundTransferAmount(widget.transaction) ??
          widget.transaction.sendAmount!;
      final totalAmount = transfer + feeAmount;
      final formattedAmount = StringUtils.formatNumberWithCommas(
        totalAmount.toStringAsFixed(2),
      );
      return '$currencySymbol$formattedAmount';
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
      final sendCurrency = _effectivePaymentCurrency();
      final receiveCurrency = _effectivePaymentCurrency();

      await Future.wait([
        _fetchRates(sendCurrency),
        _fetchRates(receiveCurrency),
      ]);

      // Calculate exchange rate and converted amount
      _calculateExchangeRateAndAmount();
    } catch (e) {
      // Handle error - could show a snackbar or fallback
      // print('Error fetching exchange rates: $e');
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
      // print('Error fetching rates for $currency: $e');
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

  /// Calculate receive amount from send amount using current exchange rates
  double? _calculateReceiveAmountFromSend() {
    if (_sendCurrencyRates == null ||
        _receiveCurrencyRates == null ||
        widget.transaction.sendAmount == null) {
      return null;
    }

    final sendSellRate = double.tryParse(
      _sendCurrencyRates!['sell']?.toString() ?? '',
    );
    final receiveBuyRate = double.tryParse(
      _receiveCurrencyRates!['buy']?.toString() ?? '',
    );

    if (sendSellRate == null || receiveBuyRate == null || receiveBuyRate == 0) {
      return null;
    }

    // Calculate exchange rate and converted amount
    final rate = receiveBuyRate / sendSellRate;
    final sendAmount = widget.transaction.sendAmount!;
    return sendAmount * rate;
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

      final hour =
          dateTime.hour > 12
              ? dateTime.hour - 12
              : (dateTime.hour == 0 ? 12 : dateTime.hour);
      final period = dateTime.hour >= 12 ? 'PM' : 'AM';
      final timeStr =
          "${hour.toString()}:${dateTime.minute.toString().padLeft(2, '0')} $period";

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
    final bank = RecipientHistoryHelper.transactionRecipientBank(
      widget.transaction,
    );
    if (bank != null && bank.isNotEmpty) {
      return bank;
    }

    if (WalletTransactionDisplay.isCrossBorderBankSend(widget.transaction)) {
      final cross = WalletTransactionDisplay.crossBorderBankName(
        widget.transaction,
      );
      if (cross != null && cross.isNotEmpty) {
        return cross;
      }
    }

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
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
            SizedBox(height: 24),
            Text(
              'Are you sure you have completed the payment?',
              style: TextStyle(
                fontFamily: 'FunnelDisplay',
                fontSize: 20,
                // height: 1.6,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            PrimaryButton(
              text: 'Yes, Confirm',
              onPressed: () {
                Navigator.pop(context);
                // TODO: Implement payment confirmation logic
              },
              backgroundColor: AppColors.purple500,
              textColor: AppColors.neutral0,
              borderRadius: 56,
              height: 56,
              width: double.infinity,
              fullWidth: true,
              fontFamily: 'Chirp',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.3,
            ),
            SizedBox(height: 12),
            SecondaryButton(
              text: 'Cancel',
              onPressed: () => Navigator.pop(context),
              borderColor: Colors.transparent,
              textColor: AppColors.purple500ForTheme(context),
              width: double.infinity,
              fullWidth: true,
              height: 56,
              borderRadius: 56,
              fontFamily: 'Chirp',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.3,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
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
            SizedBox(height: 24),
            Text(
              'Please complete your payment to proceed with the transfer.',
              style: TextStyle(
                fontFamily: 'FunnelDisplay',
                fontSize: 20,
                // height: 1.6,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            PrimaryButton(
              text: 'OK',
              onPressed: () => Navigator.pop(context),
              backgroundColor: AppColors.purple500,
              textColor: AppColors.neutral0,
              borderRadius: 56,
              height: 56,
              width: double.infinity,
              fullWidth: true,
              fontFamily: 'Chirp',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.3,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
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
            SizedBox(height: 24),
            Text(
              'Are you sure you want to cancel this transfer?',
              style: TextStyle(
                fontFamily: 'FunnelDisplay',
                fontSize: 20,
                // height: 1.6,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            PrimaryButton(
              text: 'Yes, Cancel Transfer',
              onPressed: () {
                Navigator.pop(context);
                // TODO: Implement cancel transfer logic
              },
              backgroundColor: AppColors.error500,
              textColor: Colors.white,
              borderRadius: 56,
              height: 56,
              width: double.infinity,
              fullWidth: true,
              fontFamily: 'Chirp',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.3,
            ),
            SizedBox(height: 12),
            SecondaryButton(
              text: 'No, Keep Transfer',
              onPressed: () => Navigator.pop(context),
              borderColor: Colors.transparent,
              textColor: AppColors.purple500ForTheme(context),
              width: double.infinity,
              fullWidth: true,
              height: 56,
              borderRadius: 56,
              fontFamily: 'Chirp',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.3,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToContactUs() async {
    try {
      await IntercomSupportService.openContactSupport();
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

  /// Share transaction receipt as an image
  Future<void> _shareTransactionReceipt(BuildContext shareContext) async {
    final shareOrigin = sharePositionOrigin(shareContext);
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const DayfiLoadingIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Generating receipt...',
                        style: TextStyle(
                          fontFamily: 'Chirp',
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      );

      // print('Starting receipt generation...');

      // Capture the receipt widget as an image with timeout
      final imageBytes = await _screenshotController
          .captureFromWidget(
            Material(
              color: Colors.white,
              child: TransactionReceiptWidget(
                transaction: widget.transaction,
                exchangeRate: _getExchangeRate(),
                receiveAmount: _getReceiveAmount(),
                fee: _getTransactionFee(),
                total: _calculateTotal(),
              ),
            ),
            pixelRatio: 2.5, // Reduced from 3.0 for better performance
            context: context,
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Receipt generation timed out');
            },
          );

      // print('Receipt generated successfully, size: ${imageBytes.length} bytes');

      // Save to temporary directory
      final directory = await getTemporaryDirectory();
      final imagePath =
          '${directory.path}/transaction_receipt_${widget.transaction.id}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(imageBytes);

      // print('Image saved to: $imagePath');

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Share the image
      await Share.shareXFiles(
        [XFile(imagePath)],
        text:
            'Transaction Receipt - ${widget.transaction.id.substring(0, 8).toUpperCase()}',
        subject: 'DayFi Transaction Receipt',
        sharePositionOrigin: shareOrigin,
      );

      // print('Share completed successfully');

      // Optional: Clean up the temporary file after a delay
      Future.delayed(const Duration(seconds: 30), () {
        if (imageFile.existsSync()) {
          imageFile.delete();
        }
      });
    } catch (e) {
      // print('Error sharing receipt: $e');
      // print('Stack trace: $stackTrace');

      // Close loading dialog if still open
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Show detailed error message
      if (mounted) {
        TopSnackbar.show(
          context,
          message: 'Failed to share transaction: ${e.toString()}',
          isError: true,
        );
      }
    }
  }

  /// Get channel display name - handles various payment channel types
  String _getChannelDisplayName(String? channel) {
    if (channel == null || channel.isEmpty) return 'N/A';

    final normalizedChannel = channel.toLowerCase().trim();

    // Dayfi internal transfers
    if (normalizedChannel == 'dayfi' ||
        normalizedChannel == 'dayfi_tag' ||
        normalizedChannel == 'dayfi-tag' ||
        normalizedChannel == 'p2p' ||
        normalizedChannel == 'peer_to_peer' ||
        normalizedChannel == 'peer-to-peer') {
      return 'P2P';
    }

    // Bank transfers
    if (normalizedChannel == 'bank' ||
        normalizedChannel == 'bank_transfer' ||
        normalizedChannel == 'bank-transfer' ||
        normalizedChannel == 'banktransfer') {
      return 'Bank Transfer';
    }

    // EFT (Electronic Funds Transfer)
    if (normalizedChannel == 'eft' ||
        normalizedChannel == 'electronic_funds_transfer' ||
        normalizedChannel == 'electronic-funds-transfer') {
      return 'EFT';
    }

    // Mobile Money
    if (normalizedChannel == 'mobile_money' ||
        normalizedChannel == 'mobile-money' ||
        normalizedChannel == 'mobilemoney' ||
        normalizedChannel == 'momo' ||
        normalizedChannel == 'mobile') {
      return 'Mobile Money';
    }

    // Spenn
    if (normalizedChannel == 'spenn') {
      return 'Spenn';
    }

    // Cash Pickup
    if (normalizedChannel == 'cash_pickup' ||
        normalizedChannel == 'cash-pickup' ||
        normalizedChannel == 'cashpickup' ||
        normalizedChannel == 'cash') {
      return 'Cash Pickup';
    }

    // Digital Wallet
    if (normalizedChannel == 'wallet' ||
        normalizedChannel == 'digital_wallet' ||
        normalizedChannel == 'digital-wallet') {
      return 'Digital Wallet';
    }

    // Card Payment
    if (normalizedChannel == 'card' ||
        normalizedChannel == 'card_payment' ||
        normalizedChannel == 'card-payment' ||
        normalizedChannel == 'debit' ||
        normalizedChannel == 'credit') {
      return 'Card Payment';
    }

    // Airtime
    if (normalizedChannel == 'airtime' ||
        normalizedChannel == 'airtime_topup' ||
        normalizedChannel == 'airtime-topup') {
      return 'Airtime';
    }

    // Default: Format the channel name nicely (replace underscores/dashes, capitalize)
    return channel
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(' ')
        .map(
          (word) =>
              word.isNotEmpty
                  ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
                  : '',
        )
        .join(' ');
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

  bool _isBillPayment() =>
      WalletTransactionDisplay.isBillPayment(widget.transaction);

  bool _isBillReversal() =>
      WalletTransactionDisplay.isBillReversal(widget.transaction);

  /// Check if this is a wallet top-up transaction
  bool _isWalletTopUp() {
    if (_isBillReversal()) return false;
    if (WalletTransactionDisplay.isDepositIncome(widget.transaction)) {
      return true;
    }

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

  bool _shouldShowBankAccountDetails() {
    if (!_isWalletTopUp() || !_isFeeZero()) return false;
    if (WalletTransactionDisplay.isNgnBankDeposit(widget.transaction)) {
      return false;
    }

    final isDayfiTransfer =
        widget.transaction.source.accountType?.toLowerCase() == 'dayfi' ||
        widget.transaction.beneficiary.accountType?.toLowerCase() == 'dayfi';

    if (isDayfiTransfer) {
      return (widget.transaction.beneficiary.accountNumber?.isNotEmpty ??
              false) ||
          widget.transaction.beneficiary.name.isNotEmpty;
    }

    final hasAccount =
        widget.transaction.source.accountNumber?.isNotEmpty ?? false;
    final bankName = _getBankName();
    return hasAccount ||
        !WalletTransactionDisplay.isPlaceholderDetail(bankName);
  }

  /// Build bank account details for wallet top-up
  Widget _buildBankAccountDetails() {
    final isDayfiTransfer =
        widget.transaction.source.accountType?.toLowerCase() == 'dayfi' ||
        widget.transaction.beneficiary.accountType?.toLowerCase() == 'dayfi';
    final bankName = _getBankName();

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isDayfiTransfer ? UsernameCopy.details : "Bank Account Details",
            style: AppTypography.bodySmall.copyWith(
              fontFamily: 'Chirp',
              fontSize: 12.5,
              letterSpacing: -.25,
              height: 1.2,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          SizedBox(height: 16),
          if (isDayfiTransfer) ...[
            if (widget.transaction.beneficiary.accountNumber != null &&
                widget.transaction.beneficiary.accountNumber!.isNotEmpty)
              _buildDetailRow(
                UsernameCopy.label,
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
            if (!WalletTransactionDisplay.isPlaceholderDetail(bankName))
              _buildDetailRow("Bank", bankName),
          ],
        ],
      ),
    );
  }

  String _getRecipientDisplayName() {
    if (_isBillReversal()) {
      return WalletTransactionLabels.detailHeadline(widget.transaction);
    }
    if (_isBillPayment()) {
      return WalletTransactionLabels.detailHeadline(widget.transaction);
    }

    final featureHeadline =
        WalletTransactionLabels.detailHeadline(widget.transaction);
    if (featureHeadline.isNotEmpty) return featureHeadline;

    final isCollection = _effectiveStatus.toLowerCase().contains(
      'collection',
    );
    final isPayment = _effectiveStatus.toLowerCase().contains(
      'payment',
    );

    // Check if this is a Dayfi Tag transfer
    final isDayfiTransfer =
        widget.transaction.source.accountType?.toLowerCase() == 'dayfi' ||
        widget.transaction.beneficiary.accountType?.toLowerCase() == 'dayfi';

    // For collection (incoming money)
    if (isCollection) {
      if (widget.transaction.receiveChannel?.toLowerCase() == 'crypto') {
        return 'Money added via crypto';
      }
      if (widget.transaction.receiveChannel?.toLowerCase() == 'bank') {
        return 'Money added via NGN bank account';
      }
      if (isDayfiTransfer &&
          widget.transaction.beneficiary.accountNumber != null &&
          widget.transaction.beneficiary.accountNumber!.isNotEmpty) {
        final tag = widget.transaction.beneficiary.accountNumber!;
        final displayTag = tag.startsWith('@') ? tag : '@$tag';
        return 'Money received from $displayTag';
      }
      return 'Money added to your wallet';
    }

    if (isPayment &&
        (WalletTransactionLabels.isInvestment(widget.transaction) ||
            WalletTransactionLabels.isDayEarn(widget.transaction) ||
            WalletTransactionLabels.isDayFlow(widget.transaction))) {
      return WalletTransactionLabels.detailHeadline(widget.transaction);
    }

    if (isCollection &&
        (WalletTransactionLabels.isDayEarn(widget.transaction) ||
            WalletTransactionLabels.isDayFlow(widget.transaction))) {
      return WalletTransactionLabels.detailHeadline(widget.transaction);
    }

    // For payment (outgoing money)
    if (isPayment) {
      if (WalletTransactionDisplay.isCrossBorderBankSend(widget.transaction) ||
          WalletTransactionDisplay.isUsdWalletLocalPayout(widget.transaction) ||
          RecipientHistoryHelper.isWalletFundedBankSend(widget.transaction)) {
        return WalletTransactionDisplay.detailPrimaryLabel(widget.transaction);
      }

      if (RecipientHistoryHelper.isP2pTransaction(widget.transaction) ||
          RecipientHistoryHelper.isCryptoTransaction(widget.transaction)) {
        final name = RecipientHistoryHelper.transactionRecipientName(
          widget.transaction,
        );
        if (!RecipientHistoryHelper.isGenericRecipientName(name)) {
          return name;
        }
        final username = RecipientHistoryHelper.p2pUsername(widget.transaction);
        if (username != null) return username;
      }

      if (isDayfiTransfer &&
          widget.transaction.beneficiary.accountNumber != null &&
          widget.transaction.beneficiary.accountNumber!.isNotEmpty) {
        final tag = widget.transaction.beneficiary.accountNumber!;
        return tag.startsWith('@') ? tag : '@$tag';
      }

      final resolvedName = RecipientHistoryHelper.transactionRecipientName(
        widget.transaction,
      );
      if (!RecipientHistoryHelper.isGenericRecipientName(resolvedName)) {
        return resolvedName;
      }

      return widget.transaction.beneficiary.name;
    }

    // Fallback to beneficiary name
    return widget.transaction.beneficiary.name.toUpperCase();
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
