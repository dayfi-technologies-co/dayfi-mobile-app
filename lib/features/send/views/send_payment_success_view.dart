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

class SendPaymentSuccessView extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    return WillPopScope(
      onWillPop: () async => false, // Disable device back button
      child: Scaffold(
        backgroundColor: AppColors.purple500,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 4.h),
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
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.neutral0,
                        height: 1.2,
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
                        // Trigger send success notification
                        try {
                          final sendState = ref.read(sendViewModelProvider);
                          await NotificationService().triggerSendSuccess(
                            recipientName: recipientData['name'] ?? 'Recipient',
                            amount: sendState.sendAmount,
                            currency: sendState.sendCurrency,
                            transactionId:
                                transactionId ??
                                collectionData?.id ??
                                'TXN-${DateTime.now().millisecondsSinceEpoch}',
                          );
                        } catch (e) {
                          // Handle error silently
                        }

                        // Refresh transactions and Beneficiaries data
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
                          // Handle error silently
                        }

                        // Navigate to main view with clean stack (Transactions tab)
                        _navigateToMainViewWithCleanStack(context, tabIndex: 0);
                      },
                      backgroundColor: Colors.white,
                      textColor: AppColors.purple500,
                      borderColor: AppColors.neutral0,
                      borderRadius: 38,
                      height: 60.h,
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
