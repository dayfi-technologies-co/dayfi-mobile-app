import 'package:dayfi/models/payment_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
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
  final PaymentData? collectionData;
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
              children: [
                // Top illustrations
                Expanded(
                  flex: 2,
                  child: Stack(
                    children: [
                      // Hand illustration (left side)
                      Positioned(
                        left: 0,
                        top: 40.h,
                        child: Container(
                          width: 120.w,
                          height: 120.w,
                          decoration: BoxDecoration(
                            color: AppColors.neutral0.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/icons/svgs/hand-illustration.svg',
                              width: 80.w,
                              height: 80.w,
                            ),
                          ),
                        ),
                      ),

                      // Star/flower illustration (right side)
                      Positioned(
                        right: 0,
                        top: 20.h,
                        child: Container(
                          width: 100.w,
                          height: 100.w,
                          decoration: BoxDecoration(
                            color: AppColors.warning500.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/icons/svgs/star-illustration.svg',
                              width: 60.w,
                              height: 60.w,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Main content
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Success message
                      Text(
                        'Your payment is on its way',
                        style: AppTypography.headlineLarge.copyWith(
                          fontFamily: 'CabinetGrotesk',
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.neutral0,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 16.h),

                      // Subtitle
                      Text(
                        'Your transfer has been initiated and will be processed shortly. You will receive a confirmation email.',
                        style: AppTypography.bodyLarge.copyWith(
                          fontFamily: 'Karla',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.neutral0.withOpacity(0.9),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 48.h),

                      // Action buttons
                      Column(
                        children: [
                          // View Transaction button
                          PrimaryButton(
                            text: 'View Transaction',
                            onPressed: () async {
                              // Trigger send success notification
                              try {
                                final sendState = ref.read(
                                  sendViewModelProvider,
                                );
                                await NotificationService().triggerSendSuccess(
                                  recipientName:
                                      recipientData['name'] ?? 'Recipient',
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

                              // Navigate to transaction details
                              _navigateToTransactionDetails(context);
                            },
                            backgroundColor: AppColors.neutral0,
                            textColor: AppColors.purple500,
                            borderRadius: 38,
                            height: 60.h,
                            width: double.infinity,
                            fullWidth: true,
                            fontFamily: 'Karla',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -.8,
                          ),

                          SizedBox(height: 16.h),

                          // Back to Home button
                          SecondaryButton(
                            text: 'Back to Home',
                            onPressed: () async {
                              // Trigger send success notification
                              try {
                                final sendState = ref.read(
                                  sendViewModelProvider,
                                );
                                await NotificationService().triggerSendSuccess(
                                  recipientName:
                                      recipientData['name'] ?? 'Recipient',
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
                              _navigateToMainViewWithCleanStack(
                                context,
                                tabIndex: 1,
                              );
                            },
                            backgroundColor: Colors.transparent,
                            textColor: AppColors.neutral0,
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

                // Bottom spacing
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Navigate to transaction details
  void _navigateToTransactionDetails(BuildContext context) {
    // Navigate to transaction details with actual collection data
    if (collectionData != null) {
      Navigator.pushNamed(
        context,
          AppRoute.transactionDetailsView,
        arguments: collectionData,
      );
    } else {
      // Fallback to main view if no collection data
      _navigateToMainViewWithCleanStack(context, tabIndex: 1);
    }
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
