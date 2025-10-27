import 'package:dayfi/models/payment_response.dart' as payment;
import 'package:dayfi/models/wallet_transaction.dart';
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
                // Top illustrations
                // Main content
                SizedBox(height: 12.h),

                Column(
                  children: [
                    SizedBox(
                      width: 120.w,
                      height: 120.w,
                      child: SvgPicture.asset('assets/icons/svgs/successs.svg'),
                    ),

                    SizedBox(height: 32.h),

                    Text(
                      'Your payment is on its way',
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

                    // SizedBox(height: 16.h),

                    // // Subtitle
                    // Text(
                    //   'Your transfer has been initiated and will be processed shortly. You will receive a confirmation email.',
                    //   style: AppTypography.bodyLarge.copyWith(
                    //     fontSize: 16.sp,
                    //     fontWeight: FontWeight.w400,
                    //     fontFamily: 'Karla',
                    //     color: AppColors.neutral50,
                    //     letterSpacing: -.6,
                    //     height: 1.4,
                    //   ),
                    //   textAlign: TextAlign.center,
                    // ),
                  ],
                ),

                Column(
                  children: [
                    // View Transaction button
                    PrimaryButton(
                      text: 'View Transaction',
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
                        _navigateToMainViewWithCleanStack(context, tabIndex: 1);
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

                // Bottom spacing
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Navigate to transaction details with clean history
  void _navigateToTransactionDetailsWithCleanHistory(BuildContext context) {
    if (collectionData != null) {
      // Convert PaymentData to WalletTransaction for the route
      final walletTransaction = _convertPaymentDataToWalletTransaction(
        collectionData!,
      );

      // Clear route history and navigate to main view (Transactions tab)
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoute.mainView,
        (Route route) => false, // Remove all previous routes
        arguments: 1, // Transactions tab index
      );

      // Then navigate to transaction details after a short delay
      Future.delayed(const Duration(milliseconds: 100), () {
        if (context.mounted) {
          Navigator.pushNamed(
            context,
            AppRoute.transactionDetailsView,
            arguments: walletTransaction,
          );
        }
      });
    } else {
      // Fallback to main view if no collection data
      _navigateToMainViewWithCleanStack(context, tabIndex: 1);
    }
  }

  /// Navigate to transaction details
  void _navigateToTransactionDetails(BuildContext context) {
    // Navigate to transaction details with actual collection data
    if (collectionData != null) {
      // Convert PaymentData to WalletTransaction for the route
      final walletTransaction = _convertPaymentDataToWalletTransaction(
        collectionData!,
      );
      Navigator.pushNamed(
        context,
        AppRoute.transactionDetailsView,
        arguments: walletTransaction,
      );
    } else {
      // Fallback to main view if no collection data
      _navigateToMainViewWithCleanStack(context, tabIndex: 1);
    }
  }

  /// Convert PaymentData to WalletTransaction
  WalletTransaction _convertPaymentDataToWalletTransaction(
    payment.PaymentData paymentData,
  ) {
    return WalletTransaction(
      id: paymentData.id ?? 'TXN-${DateTime.now().millisecondsSinceEpoch}',
      sendChannel: selectedData['senderChannelId'],
      sendNetwork: selectedData['senderNetworkId'],
      sendAmount: double.tryParse(
        selectedData['sendAmount']?.toString() ?? '0',
      ),
      receiveChannel: selectedData['recipientChannelId'],
      receiveNetwork: recipientData['networkId'],
      receiveAmount: double.tryParse(
        selectedData['receiveAmount']?.toString() ?? '0',
      ),
      status: 'pending-collection',
      reason: paymentData.reason ?? 'Money Transfer',
      timestamp: DateTime.now().toIso8601String(),
      beneficiary: Beneficiary(
        id: 'ben-${DateTime.now().millisecondsSinceEpoch}',
        name: recipientData['name'] ?? 'Recipient',
        country: recipientData['country'] ?? 'NG',
        phone: recipientData['phone'] ?? '+2340000000000',
        address: recipientData['address'] ?? 'Not provided',
        dob: recipientData['dob'] ?? '1990-01-01',
        email: recipientData['email'] ?? 'recipient@example.com',
        idNumber: recipientData['idNumber'] ?? 'A12345678',
        idType: recipientData['idType'] ?? 'passport',
      ),
      source: Source(
        id: paymentData.source?.networkId,
        accountType: paymentData.source?.accountType ?? 'bank',
        accountNumber: paymentData.source?.accountNumber ?? '1111111111',
        networkId:
            paymentData.source?.networkId ??
            '31cfcc77-8904-4f86-879c-a0d18b4b9365',
        beneficiaryId: paymentData.recipient?.email,
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
