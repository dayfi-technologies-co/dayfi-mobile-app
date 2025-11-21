import 'package:dayfi/models/payment_response.dart' as payment;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/common/widgets/buttons/secondary_button.dart';
import 'package:dayfi/features/send/vm/send_viewmodel.dart';
import 'package:dayfi/features/transactions/vm/transactions_viewmodel.dart';
import 'package:dayfi/features/recipients/vm/recipients_viewmodel.dart';
import 'package:dayfi/services/notification_service.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/common/utils/app_logger.dart';

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

class _SendPaymentSuccessViewState
    extends ConsumerState<SendPaymentSuccessView> {
  bool _notificationTriggered = false;

  @override
  void initState() {
    super.initState();
    // Trigger success notification when view loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerSuccessNotification();
    });
  }

  Future<void> _triggerSuccessNotification() async {
    if (_notificationTriggered) return;
    _notificationTriggered = true;

    try {
      final sendState = ref.read(sendViewModelProvider);
      final recipientName = widget.recipientData['name'] ?? 'Recipient';
      final amount = sendState.sendAmount;
      final currency = sendState.sendCurrency;
      final txnId = widget.transactionId ??
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
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 4.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(height: 12.h),

                Column(
                  children: [
                    SizedBox(
                      width: 132.w,
                      height: 132.w,
                      child: SvgPicture.asset('assets/icons/svgs/successs.svg'),
                    ),

                    SizedBox(height: 32.h),

                    Text(
                      'We\'re processing your transfer. You\'ll receive a confirmation once your payment is verified.',
                      style: AppTypography.headlineLarge.copyWith(
                     fontFamily: 'CabinetGrotesk',
                        fontSize: 22.sp, height: 1.7,
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
                      text: 'Back to Home',
                      onPressed: () async {
                        // Refresh transactions and beneficiaries data
                        try {
                          // Refresh transactions
                          ref
                              .read(transactionsProvider.notifier)
                              .loadTransactions();
                          // Refresh recipients
                          ref
                              .read(recipientsProvider.notifier)
                              .loadBeneficiaries();
                        } catch (e) {
                          AppLogger.error('Failed to refresh data: $e');
                        }

                        // Navigate to main view with clean stack (Transactions tab)
                        _navigateToMainViewWithCleanStack(context, tabIndex: 0);
                      },
                      backgroundColor: Colors.white,
                      textColor: AppColors.purple500,
                      borderColor: AppColors.neutral0,
                      borderRadius: 38,
                      height: 48.000.h,
                      width: double.infinity,
                      fullWidth: true,
                      fontFamily: 'Karla',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -.8,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Navigate to main view with clean navigation stack
  void _navigateToMainViewWithCleanStack(
    BuildContext context, {
    int tabIndex = 1,
  }) {
    // Clear the navigation stack and navigate to main view with specified tab
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoute.mainView,
      (Route route) => false, // Remove all previous routes
      arguments: tabIndex,
    );
  }
}
