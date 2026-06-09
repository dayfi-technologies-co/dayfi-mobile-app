import 'dart:async';

import 'package:dayfi/models/payment_response.dart' as payment;
import 'package:dayfi/models/wallet_transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/common/widgets/buttons/secondary_button.dart';
import 'package:dayfi/features/send/helpers/send_success_navigation.dart';
import 'package:dayfi/features/send/vm/send_viewmodel.dart';
import 'package:dayfi/features/transactions/vm/transactions_viewmodel.dart';
import 'package:dayfi/services/notification_service.dart';
import 'package:dayfi/common/utils/app_logger.dart';

class SendCollectionSuccessView extends ConsumerStatefulWidget {
  final Map<String, dynamic> recipientData;
  final Map<String, dynamic> selectedData;
  final Map<String, dynamic> paymentData;
  final payment.PaymentData? collectionData;
  final String? transactionId;

  const SendCollectionSuccessView({
    super.key,
    required this.recipientData,
    required this.selectedData,
    required this.paymentData,
    this.collectionData,
    this.transactionId,
  });

  @override
  ConsumerState<SendCollectionSuccessView> createState() =>
      _SendCollectionSuccessViewState();
}

class _SendCollectionSuccessViewState
    extends ConsumerState<SendCollectionSuccessView> {
  bool _notificationTriggered = false;
  WalletTransaction? _transaction;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_triggerSuccessNotification());
      unawaited(_prefetchTransaction());
    });
  }

  Future<void> _prefetchTransaction() async {
    final id = widget.transactionId ?? widget.collectionData?.id;
    if (id == null || id.isEmpty) return;

    try {
      await ref.read(transactionsProvider.notifier).loadTransactions();
      final transactions = ref.read(transactionsProvider).transactions;
      final match = SendSuccessNavigation.findTransaction(transactions, id);
      if (!mounted) return;
      if (match != null) setState(() => _transaction = match);
    } catch (e) {
      AppLogger.error('Failed to prefetch collection transaction: $e');
    }
  }

  Future<void> _triggerSuccessNotification() async {
    if (_notificationTriggered) return;
    _notificationTriggered = true;

    try {
      final sendState = ref.read(sendViewModelProvider);
      final recipientName = widget.recipientData['name'] ?? 'Recipient';
      final amount = sendState.sendAmount;
      final currency = sendState.sendCurrency;
      final txnId =
          widget.transactionId ??
          widget.collectionData?.id ??
          'TXN-${DateTime.now().millisecondsSinceEpoch}';

      AppLogger.info(
        'Triggering transfer success notification for $recipientName',
      );

      await NotificationService().triggerSendSuccess(
        recipientName: recipientName,
        amount: amount,
        currency: currency,
        transactionId: txnId,
      );

      AppLogger.info('Transfer success notification sent successfully');
    } catch (e) {
      AppLogger.error('Failed to trigger success notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable device back button
      child: Scaffold(
        backgroundColor: AppColors.purple500,
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(height: 12),

                        Column(
                          children: [
                            SizedBox(
                              width: 132,
                              height: 132,
                              child: SvgPicture.asset(
                                'assets/icons/svgs/successs.svg',
                              ),
                            ),

                            SizedBox(height: 32),

                            Text(
                              'We\'re processing your transfer. You\'ll receive a confirmation once your payment is verified.',
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
                          ],
                        ),

                        Column(
                          children: [
                            SecondaryButton(
                              text: 'View transaction',
                              onPressed: _viewTransaction,
                              isLoading: _isNavigating,
                              backgroundColor: Colors.white,
                              textColor: AppColors.purple500,
                              borderColor: AppColors.neutral0,
                              borderRadius: 38,
                              height: 48.00000,
                              width: double.infinity,
                              fullWidth: true,
                              fontFamily: 'Chirp',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -.70,
                            ),
                          ],
                        ),
                      ],
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

  Future<void> _viewTransaction() async {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);
    try {
      await SendSuccessNavigation.openTransactionDetailsOrList(
        ref: ref,
        transactionId:
            widget.transactionId ??
            widget.collectionData?.id ??
            widget.collectionData?.sequenceId,
        prefetchedTransaction: _transaction,
      );
    } finally {
      if (mounted) setState(() => _isNavigating = false);
    }
  }
}
