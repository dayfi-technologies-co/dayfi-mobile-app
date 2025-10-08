import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/services/remote/payment_service.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/features/send/vm/send_viewmodel.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/models/payment_response.dart';
import 'package:dayfi/features/transactions/vm/transactions_viewmodel.dart';
import 'package:dayfi/features/recipients/vm/recipients_viewmodel.dart';

class SendPaymentMethodView extends ConsumerStatefulWidget {
  final Map<String, dynamic> selectedData;
  final Map<String, dynamic> recipientData;
  final Map<String, dynamic> paymentData;

  const SendPaymentMethodView({
    Key? key,
    required this.selectedData,
    required this.recipientData,
    required this.paymentData,
  }) : super(key: key);

  @override
  ConsumerState<SendPaymentMethodView> createState() =>
      _SendPaymentMethodViewState();
}

class _SendPaymentMethodViewState extends ConsumerState<SendPaymentMethodView> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Update viewModel with selected data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateViewModelWithSelectedData();
    });
  }

  void _updateViewModelWithSelectedData() {
    final sendState = ref.read(sendViewModelProvider.notifier);
    
    // Update send amount if available
    if (widget.selectedData['sendAmount'] != null) {
      sendState.updateSendAmount(widget.selectedData['sendAmount'].toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final sendState = ref.watch(sendViewModelProvider);
    
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Payment Method',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontFamily: 'CabinetGrotesk',
            fontSize: 28.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.8,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment Method Card
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  width: 1.0,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 4.w),
                  Image.asset(
                    "assets/images/idea.png",
                    height: 18.h,
                    // color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      "Please prepare your KYC documents in case we require verification to complete this transaction.",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 12.5.sp,
                        fontFamily: 'Karla',
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.4,
                        height: 1.5,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(.75),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            _buildPaymentMethodCard(sendState),

            SizedBox(height: 48.h),
            PrimaryButton(
              text: 'Pay with Bank Transfer',
              onPressed: _processPayment,
              isLoading: _isLoading,
              height: 60.h,
              backgroundColor: AppColors.purple500,
              textColor: AppColors.neutral0,
              fontFamily: 'Karla',
              letterSpacing: -.8,
              fontSize: 18,
              width: double.infinity,
              fullWidth: true,
              borderRadius: 40.r,
            ),

            SizedBox(height: 100.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(SendState sendState) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.purple500, width: .5),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple500.withOpacity(0.1),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30.w,
                height: 30.w,
                decoration: BoxDecoration(
                  color: AppColors.pink400,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                // child: SvgPicture.asset(icon, color: iconColor, height: 20.sp),
              ),

              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pay with Bank Transfer',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontFamily: 'CabinetGrotesk',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Send up to ${sendState.sendCurrency} 15,000,000.00 via virtual account. Funds will arrive within 10 minutes.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12.5.sp,
                        fontFamily: 'Karla',
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.4,
                        height: 1.3,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // SizedBox(height: 16.h),
          
          // // Transfer Summary
          // Container(
          //   width: double.infinity,
          //   padding: EdgeInsets.all(12.w),
          //   decoration: BoxDecoration(
          //     color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          //     borderRadius: BorderRadius.circular(8.r),
          //   ),
          //   child: Column(
          //     children: [
          //       _buildSummaryRow('Amount to Send', '${sendState.sendCurrency} ${sendState.sendAmount}'),
          //       SizedBox(height: 8.h),
          //       _buildSummaryRow('Transfer Fee', '${sendState.sendCurrency} ${sendState.fee}'),
          //       SizedBox(height: 8.h),
          //       _buildSummaryRow('Total', '${sendState.sendCurrency} ${sendState.totalToPay}', isTotal: true),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }


  void _processPayment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final sendState = ref.read(sendViewModelProvider);
      
      // Analytics: collection creation started
      analyticsService.logEvent(
        name: 'collection_creation_started',
        parameters: {
          'amount': sendState.sendAmount,
          'currency': sendState.sendCurrency,
          'recipient_country': sendState.receiverCountry,
          'delivery_method': sendState.selectedDeliveryMethod,
        },
      );
      
      // Get the real channel information
      // First, let's try to find channels that match the recipient country and currency
      final recipientChannels = sendState.channels
          .where((channel) =>
              channel.country == sendState.receiverCountry &&
              channel.currency == sendState.receiverCurrency &&
              channel.status == 'active' &&
              channel.channelType == sendState.selectedDeliveryMethod)
          .toList();
      
      
      // Try to find a channel with a valid rampType for collections
      // For create-collections, we might need channels with 'deposit' or 'collection' rampType
      final validChannels = recipientChannels
          .where((channel) =>
              channel.rampType == 'deposit' ||
              channel.rampType == 'collection' ||
              channel.rampType == 'withdrawal' ||
              channel.rampType == 'withdraw' ||
              channel.rampType == 'payout')
          .toList();
      
      final selectedChannel = validChannels.isNotEmpty ? validChannels.first : recipientChannels.isNotEmpty ? recipientChannels.first : null;
      
      
      // If no valid channel is found, show an error
      if (selectedChannel == null) {
        TopSnackbar.show(
          context,
          message: 'No valid payment channel found for ${sendState.receiverCountry}/${sendState.receiverCurrency}',
          isError: true,
        );
        return;
      }

      // Prepare the request data using real data from the flow
      final requestData = {
        "amount": int.parse(sendState.sendAmount.replaceAll(RegExp(r'[^\d]'), '')),
        "currency": sendState.sendCurrency,
        "channelId": selectedChannel.id ?? widget.selectedData['networkId'] ?? "af944f0c-ba70-47c7-86dc-1bad5a6ab4e4",
        "channelName": selectedChannel.channelType ?? widget.selectedData['recipientDeliveryMethod'] ?? "Bank Transfer",
        "country": sendState.sendCountry,
        "reason": widget.paymentData['reason'] ?? "Money Transfer", // Use selected reason
        "recipient": {
          "name": widget.recipientData['name'] ?? 'John Doe',
          "country": widget.recipientData['country'] ?? sendState.receiverCountry,
          "phone": widget.recipientData['phone'] ?? '+2347012345678',
          "address": widget.recipientData['address'] ?? '12 Example Street, Lagos',
          "dob": widget.recipientData['dob'] ?? '1990-01-01',
          "email": widget.recipientData['email'] ?? 'john.doe@example.com',
          "idNumber": widget.recipientData['idNumber'] ?? 'A12345678',
          "idType": widget.recipientData['idType'] ?? 'passport'
        },
        "source": {
          "accountType": "bank",
          "accountNumber": widget.recipientData['accountNumber'] ?? "1111111111", // Use real account number
          "networkId": widget.recipientData['networkId'] ?? "31cfcc77-8904-4f86-879c-a0d18b4b9365" // Use real network ID
        },
        "metadata": {
          "customerId": "12345", // TODO: Get real customer ID from auth
          "orderId": "COLL-${DateTime.now().millisecondsSinceEpoch}", // Generate order ID
          "description": widget.paymentData['description'] ?? "", // Include description if provided
        }
      };

      // Make the API call
      final response = await locator<PaymentService>().createCollection(requestData);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (!response.error && response.data != null) {
          // Analytics: collection creation completed
          analyticsService.logEvent(
            name: 'collection_creation_completed',
            parameters: {
              'amount': sendState.sendAmount,
              'currency': sendState.sendCurrency,
              'recipient_country': sendState.receiverCountry,
              'delivery_method': sendState.selectedDeliveryMethod,
              'collection_id': response.data?.id ?? 'unknown',
            },
          );
          // Show bank details bottom sheet
          _showBankDetailsBottomSheet(response.data!);
        } else {
          // Analytics: collection creation failed
          analyticsService.logEvent(
            name: 'collection_creation_failed',
            parameters: {
              'amount': sendState.sendAmount,
              'currency': sendState.sendCurrency,
              'recipient_country': sendState.receiverCountry,
              'delivery_method': sendState.selectedDeliveryMethod,
              'reason': response.message.isNotEmpty ? response.message : 'Payment processing failed',
            },
          );
          TopSnackbar.show(
            context,
            message: response.message.isNotEmpty ? response.message : 'Payment processing failed',
            isError: true,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Analytics: collection creation failed (exception)
        final sendState = ref.read(sendViewModelProvider);
        analyticsService.logEvent(
          name: 'collection_creation_failed',
          parameters: {
            'amount': sendState.sendAmount,
            'currency': sendState.sendCurrency,
            'recipient_country': sendState.receiverCountry,
            'delivery_method': sendState.selectedDeliveryMethod,
            'reason': e.toString(),
            'error_type': 'exception',
          },
        );
        
        // Check if it's a DioException with specific error message
        String errorMessage = 'Error processing payment: $e';
        if (e.toString().contains('Invalid channel rampType')) {
          errorMessage = 'Invalid payment channel. Please try a different payment method.';
        } else if (e.toString().contains('500')) {
          errorMessage = 'Server error. Please try again later.';
        }
        
        TopSnackbar.show(
          context,
          message: errorMessage,
          isError: true,
        );
      }
    }
  }

  void _showBankDetailsBottomSheet(PaymentData collectionData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.r),
              topRight: Radius.circular(24.r),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              
              // Header
              Padding(
                padding: EdgeInsets.all(24.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Payment Details',
                      style: AppTypography.titleLarge.copyWith(
                        fontFamily: 'CabinetGrotesk',
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 24.w,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Instruction banner
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: AppColors.primary50.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.primary500.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.primary600,
                              size: 20.w,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                'When paying into this account, ensure the name on the bank account matches your verified name on Send.',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontFamily: 'Karla',
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.primary600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 24.h),
                      
                      // Transfer details
                      Text(
                        'Transfer details:',
                        style: AppTypography.titleMedium.copyWith(
                          fontFamily: 'CabinetGrotesk',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      
                      SizedBox(height: 16.h),
                      
                      // Amount to send
                      _buildDetailRow(
                        'Amount to send',
                        '${collectionData.currency} ${collectionData.amount}',
                        showCopy: true,
                      ),
                      
                      SizedBox(height: 12.h),
                      
                      // Account number
                      _buildDetailRow(
                        'Account number',
                        collectionData.bankInfo?.accountNumber ?? 'N/A',
                        showCopy: true,
                      ),
                      
                      SizedBox(height: 12.h),
                      
                      // Bank name
                      _buildDetailRow(
                        'Bank name',
                        collectionData.bankInfo?.name ?? 'N/A',
                      ),
                      
                      SizedBox(height: 24.h),
                      
                      // Expiration warning
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: AppColors.warning50.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.warning500.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.warning600,
                              size: 20.w,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                'The account details is valid for only this transaction and it expires in 30:58 minutes.',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontFamily: 'Karla',
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.warning600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 24.h),
                      
                      // Instruction text
                      Text(
                        'Tap the "I have paid" button below after completing your transfer.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: 'Karla',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              ),
              
              // Action buttons
              Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  children: [
                    // I have paid button
                    PrimaryButton(
                      text: 'I have paid',
                      onPressed: () {
                        Navigator.pop(context);
                        _showPaymentSuccessDialog();
                      },
                      backgroundColor: AppColors.purple500,
                      textColor: AppColors.neutral0,
                      borderRadius: 12.r,
                      height: 56.h,
                      width: double.infinity,
                      fullWidth: true,
                      fontFamily: 'Karla',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    
                    SizedBox(height: 12.h),
                    
                    // Change payment method button
                    PrimaryButton(
                      text: 'Change payment method',
                      onPressed: () => Navigator.pop(context),
                      backgroundColor: Colors.transparent,
                      textColor: AppColors.purple500,
                      borderRadius: 12.r,
                      height: 56.h,
                      width: double.infinity,
                      fullWidth: true,
                      fontFamily: 'Karla',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      borderColor: AppColors.purple500,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool showCopy = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontFamily: 'Karla',
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontFamily: 'CabinetGrotesk',
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (showCopy) ...[
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  TopSnackbar.show(
                    context,
                    message: 'Account number copied to clipboard',
                  );
                },
                child: Icon(
                  Icons.copy,
                  size: 16.w,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Container(
            padding: EdgeInsets.all(28.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success icon
                Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.success500.withOpacity(0.1),
                        AppColors.success500.withOpacity(0.05),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success500.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: AppColors.success500,
                    size: 40.w,
                  ),
                ),

                SizedBox(height: 24.h),

                // Title
                Text(
                  'Transfer Initiated Successfully!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontFamily: 'CabinetGrotesk',
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 16.h),

                // Subtitle
                Text(
                  'Your transfer has been initiated and will be processed shortly. You will receive a confirmation email.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Karla',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 24.h),

                // Done button
                PrimaryButton(
                  text: 'Done',
                  onPressed: () async {
                    Navigator.of(context).pop(); // Close dialog
                    
                    // Refresh transactions and recipients data
                    try {
                      // Refresh transactions
                      ref.read(transactionsProvider.notifier).loadTransactions();
                      // Refresh recipients
                      ref.read(recipientsProvider.notifier).loadBeneficiaries();
                    } catch (e) {
                      // Handle error silently or show user-friendly message
                    }
                    
                    Navigator.of(context).pop(); // Go back to main screen
                  },
                  backgroundColor: AppColors.purple500,
                  textColor: AppColors.neutral0,
                  borderRadius: 38,
                  height: 60.h,
                  width: double.infinity,
                  fullWidth: true,
                  fontFamily: 'Karla',
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -.8,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
