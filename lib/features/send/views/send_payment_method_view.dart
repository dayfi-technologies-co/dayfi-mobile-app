import 'dart:developer';

import 'package:dayfi/common/widgets/buttons/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/services/remote/payment_service.dart';
import 'package:dayfi/services/transaction_monitor_service.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/features/send/vm/send_viewmodel.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/models/payment_response.dart' as payment;
import 'package:dayfi/models/wallet_transaction.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/features/send/views/send_payment_success_view.dart';
import 'dart:async';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/common/utils/error_handler.dart';
import 'package:dayfi/services/local/crashlytics_service.dart';
import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';

class SendPaymentMethodView extends ConsumerStatefulWidget {
  final Map<String, dynamic> selectedData;
  final Map<String, dynamic> recipientData;
  final Map<String, dynamic> senderData;
  final Map<String, dynamic> paymentData;

  const SendPaymentMethodView({
    super.key,
    required this.selectedData,
    required this.recipientData,
    required this.senderData,
    required this.paymentData,
  });

  @override
  ConsumerState<SendPaymentMethodView> createState() =>
      _SendPaymentMethodViewState();
}

class _SendPaymentMethodViewState extends ConsumerState<SendPaymentMethodView> {
  bool _isLoading = false;
  String? _selectedPaymentMethod; // No default selection
  payment.PaymentData? _currentPaymentData; // Store the current payment data
  Timer? _countdownTimer;
  Duration _remainingTime = const Duration(minutes: 30);

  @override
  void initState() {
    super.initState();

    // Update viewModel with selected data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateViewModelWithSelectedData();
    });
  }

  dynamic _findSelectedChannel(SendState sendState) {
    final recipientChannels =
        sendState.channels
            .where(
              (channel) =>
                  channel.country == sendState.receiverCountry &&
                  channel.currency == sendState.receiverCurrency &&
                  channel.status == 'active' &&
                  channel.channelType == sendState.selectedDeliveryMethod,
            )
            .toList();

    final validChannels =
        recipientChannels
            .where(
              (channel) =>
                  channel.rampType == 'deposit' ||
                  channel.rampType == 'collection' ||
                  channel.rampType == 'withdrawal' ||
                  channel.rampType == 'withdraw' ||
                  channel.rampType == 'payout',
            )
            .toList();

    return validChannels.isNotEmpty
        ? validChannels.first
        : (recipientChannels.isNotEmpty ? recipientChannels.first : null);
  }

  Map<String, dynamic> _buildCollectionRequest({
    required SendState sendState,
    required dynamic selectedChannel,
  }) {
    // Check if this is a crypto funding request
    final isCrypto = widget.selectedData['cryptoCurrency'] != null ||
        widget.selectedData['cryptoNetwork'] != null;
    
    final requestData = {
      "amount": double.tryParse(
        sendState.sendAmount.replaceAll(RegExp(r'[^\d.]'), ''),
      ) ?? 0,
      "currency": sendState.sendCurrency,
      "channelId": widget.selectedData['senderChannelId'] ?? "",
      "channelName":
          selectedChannel.channelType ??
          widget.selectedData['recipientDeliveryMethod'] ??
          (isCrypto ? "Digital Dollar" : "Bank Transfer"),
      "country": sendState.sendCountry,
      "reason": widget.paymentData['reason'] ?? "Money Transfer",
      "receiveChannel":
          widget.selectedData['recipientChannelId'] ?? selectedChannel.id ?? "",
      "receiveNetwork": widget.recipientData['networkId'] ?? "",
      "receiveAmount":
          double.tryParse(
            widget.selectedData['receiveAmount']?.toString() ?? '0',
          ) ??
          0,
      "recipient": {
        "name": widget.recipientData['name'] ?? 'Recipient',
        "country": widget.recipientData['country'] ?? sendState.receiverCountry,
        "phone": widget.recipientData['phone'] ?? '+2340000000000',
        "address": widget.recipientData['address'] ?? 'Not provided',
        "dob": widget.recipientData['dob'] ?? '1990-01-01',
        "email": widget.recipientData['email'] ?? 'recipient@example.com',
        "idNumber": widget.recipientData['idNumber'] ?? 'A12345678',
        "idType": widget.recipientData['idType'] ?? 'passport',
      },
      "source": {
        "accountType": isCrypto ? "crypto" : "bank",
        "accountNumber": widget.recipientData['accountNumber'] ?? 
            widget.recipientData['walletAddress'] ?? 
            (isCrypto ? "" : "1111111111"),
        "networkId": widget.recipientData['networkId'] ?? 
            widget.selectedData['cryptoNetwork'] ?? "",
      },
      "metadata": {
        "customerId": widget.senderData['userId'] ?? "12345",
        "orderId": "COLL-${DateTime.now().millisecondsSinceEpoch}",
        "description": widget.paymentData['description'] ?? "",
      },
    };

    // Add crypto-specific fields if this is a crypto request
    if (isCrypto) {
      requestData["cryptoCurrency"] = widget.selectedData['cryptoCurrency'] ?? "";
      requestData["cryptoNetwork"] = widget.selectedData['cryptoNetwork'] ?? "";
      requestData["walletAddress"] = widget.recipientData['walletAddress'] ?? 
          widget.selectedData['walletAddress'] ?? "";
      if (widget.selectedData['requiresMemo'] == true) {
        requestData["memo"] = widget.recipientData['memo'] ?? 
            widget.selectedData['memo'] ?? "";
      }
    }

    return requestData;
  }

  Map<String, dynamic> _buildPaymentMonitoringData({
    required SendState sendState,
    required dynamic selectedChannel,
  }) {
    return {
      "amount": double.tryParse(
        sendState.sendAmount.replaceAll(RegExp(r'[^\d.]'), ''),
      ) ?? 0,
      "currency": sendState.sendCurrency,
      "channelId": widget.selectedData['senderChannelId'] ?? "",
      "channelName":
          selectedChannel.channelType ??
          widget.selectedData['recipientDeliveryMethod'] ??
          "Bank Transfer",
      "country": sendState.sendCountry,
      "reason": widget.paymentData['reason'] ?? "Money Transfer",
      "receiveChannel":
          widget.selectedData['recipientChannelId'] ?? selectedChannel.id ?? "",
      "receiveNetwork": widget.recipientData['networkId'] ?? "",
      "receiveAmount":
          double.tryParse(
            widget.selectedData['receiveAmount']?.toString() ?? '0',
          ) ??
          0,
      "recipient": {
        "name": widget.recipientData['name'] ?? 'Recipient',
        "country": widget.recipientData['country'] ?? sendState.receiverCountry,
        "phone": widget.recipientData['phone'] ?? '+2340000000000',
        "address": widget.recipientData['address'] ?? '',
        "email": widget.recipientData['email'] ?? '',
        "idNumber": widget.recipientData['idNumber'] ?? '',
        "idType": widget.recipientData['idType'] ?? 'passport',
        "dob": widget.recipientData['dob'] ?? '',
      },
      "source": {
        "accountType": widget.recipientData['accountType'] ?? 'bank',
        "accountNumber": widget.recipientData['accountNumber'] ?? '',
        "networkId": widget.recipientData['networkId'] ?? '',
      },
    };
  }

  String _mapCollectionError(String raw, SendState sendState) {
    if (raw.contains('No buy rate for currency')) {
      final currencyMatch = RegExp(
        r'No buy rate for currency (\\w+)',
      ).firstMatch(raw);
      final currency =
          currencyMatch?.group(1) ??
          sendState.receiverCurrency ??
          'selected currency';
      return 'Exchange rates not available for $currency. Please select a different currency or try again later.';
    }
    if (raw.contains('RedirectUrl param is required')) {
      return 'Payment processing requires additional configuration. Please try again or contact support.';
    }
    if (raw.contains('Invalid channel rampType')) {
      return 'Invalid payment channel. Please try a different payment method.';
    }
    if (raw.contains('500')) {
      return 'Server error. Please try again later.';
    }
    if (raw.contains('DioException')) {
      return 'Unable to process payment. Please check your connection and try again.';
    }
    return ErrorHandler.handleApiError(raw);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _updateViewModelWithSelectedData() {
    final sendState = ref.read(sendViewModelProvider.notifier);

    // Update send amount if available
    if (widget.selectedData['sendAmount'] != null) {
      sendState.updateSendAmount(widget.selectedData['sendAmount'].toString());
    }
  }

  /// Start the countdown timer
  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _remainingTime = const Duration(minutes: 30);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingTime.inSeconds > 0) {
            _remainingTime = Duration(seconds: _remainingTime.inSeconds - 1);
          } else {
            _countdownTimer?.cancel();
            // Timer expired - you might want to show an alert or refresh
            _onTimerExpired();
          }
        });
      }
    });
  }

  /// Handle timer expiration
  void _onTimerExpired() {
    // Show alert or refresh the payment details
    if (mounted) {
      _showTimerExpiredDialog();
    }
  }

  /// Show timer expired dialog
  void _showTimerExpiredDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Payment Expired'),
            content: const Text(
              'The payment details have expired. Please create a new payment.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Go back to previous screen
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  /// Format remaining time as MM:SS
  String _formatRemainingTime() {
    final minutes = _remainingTime.inMinutes;
    final seconds = _remainingTime.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _handleDayfiTagSelection() async {
    log('handleDayfiTagSelection');
    
    // DayFi Tag to DayFi Tag transfers are limited to NGN (Nigerian Naira) only
    final sendState = ref.read(sendViewModelProvider);
    const dayfiTagAllowedCurrency = 'NGN';
    
    // Validate currency restriction: DayFi Tag transfers only support NGN
    if (sendState.receiverCurrency != dayfiTagAllowedCurrency) {
      ErrorHandler.showError(
        context,
        'DayFi Tag transfers are only available for NGN (Nigerian Naira). Please select NGN as the recipient currency to use DayFi Tag.',
      );
      return;
    }
    
    // Check if user has a DayFi Tag
    final profileState = ref.read(profileViewModelProvider);
    final user = profileState.user;
    final dayfiId = user?.dayfiId;

    if (dayfiId == null || dayfiId.isEmpty) {
      // User doesn't have a DayFi Tag, show explanation and navigate to creation
      final result = await Navigator.pushNamed(context, AppRoute.dayfiTagExplanationView);
      // If user created a DayFi Tag, refresh profile and show bottom sheet
      if (result != null && result is String) {
        // Refresh profile to get updated user data
        await ref.read(profileViewModelProvider.notifier).loadUserProfile();
        // Show bottom sheet with the newly created DayFi Tag
        if (mounted) {
          _showDayfiTagBottomSheet(result);
        }
      }
    } else {
      // User has a DayFi Tag, show bottom sheet
      _showDayfiTagBottomSheet(dayfiId);
    }
  }

  void _showDayfiTagBottomSheet(String dayfiId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              SizedBox(height: 18.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(height: 22.h, width: 22.w),
                    Text(
                      'Your DayFi Tag',
                      style: AppTypography.titleLarge.copyWith(
                        fontFamily: 'CabinetGrotesk',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Image.asset(
                        "assets/icons/pngs/cancelicon.png",
                        height: 22.h,
                        width: 22.w,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withOpacity(0.25),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(width: 4.w),
                            Image.asset(
                              "assets/images/idea.png",
                              height: 18.h,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                'Share your DayFi Tag with friends and family. They can send you money instantly using this tag.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                  fontSize: 12.5.sp,
                                  fontFamily: 'Karla',
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: -0.4,
                                  height: 1.5,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 24.h,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withOpacity(0.2),
                            width: 1.0,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8.h),
                            Text(
                              'Your DayFi Tag:',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                fontFamily: 'CabinetGrotesk',
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            _buildDetailRow(
                              'DayFi Tag',
                              dayfiId.startsWith('@') ? dayfiId : '@$dayfiId',
                              showCopy: true,
                            ),
                            SizedBox(height: 24.h),
                            Text(
                              'Share this tag with anyone who wants to send you money. They can use it to transfer funds directly to your wallet.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                fontFamily: 'Karla',
                                fontWeight: FontWeight.w400,
                                letterSpacing: -0.4,
                                fontSize: 14.sp,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(24.w),
                child: PrimaryButton(
                  text: 'I\'ve Shared My Tag',
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to success screen or main view
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SendPaymentSuccessView(
                          recipientData: widget.recipientData,
                          selectedData: widget.selectedData,
                          paymentData: widget.paymentData,
                          collectionData: null,
                          transactionId: null,
                        ),
                      ),
                    );
                  },
                  backgroundColor: AppColors.purple500,
                  height: 60.h,
                  textColor: AppColors.neutral0,
                  fontFamily: 'Karla',
                  letterSpacing: -.8,
                  fontSize: 18,
                  width: double.infinity,
                  fullWidth: true,
                  borderRadius: 40.r,
                ),
              ),
            ],
          ),
        );
      },
    );
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
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
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
                ).colorScheme.primaryContainer.withOpacity(0.25),
                borderRadius: BorderRadius.circular(4.r),
                // border: Border.all(
                //   color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                //   width: 1.0,
                // ),
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
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            _buildPaymentMethodCard(sendState),

            SizedBox(height: 48.h),
            PrimaryButton(
              text:
                  _selectedPaymentMethod != null
                      ? 'Pay with $_selectedPaymentMethod'
                      : 'Select a Payment Method',
              onPressed:
                  _selectedPaymentMethod != null ? _processPayment : null,
              isLoading: _isLoading,
              height: 60.h,
              backgroundColor:
                  _selectedPaymentMethod != null
                      ? AppColors.purple500
                      : AppColors.purple500.withOpacity(.25),
              textColor:
                  _selectedPaymentMethod != null
                      ? AppColors.neutral0
                      : AppColors.neutral0.withOpacity(.5),
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
    return Column(
      children: [
        // DayFi ID
        _buildPaymentMethodOption(
          title: 'DayFi Tag',
          description:
              'Share your DayFi ID with friends and family using DayFi. Funds will arrive immediately. (NGN only)',
          iconColor: AppColors.orange500,
          isSelected: _selectedPaymentMethod == 'DayFi Tag',
          isEnabled: sendState.receiverCurrency == 'NGN',
          onTap: () {
            if (sendState.receiverCurrency != 'NGN') {
              ErrorHandler.showError(
                context,
                'DayFi Tag transfers are only available for NGN (Nigerian Naira). Please select NGN as the recipient currency.',
              );
              return;
            }
            setState(() {
              _selectedPaymentMethod = 'DayFi Tag';
            });
          },
        ),

        SizedBox(height: 16.h),

        // Bank Transfer Card
        _buildPaymentMethodOption(
          title: 'Bank Transfer',
          description:
              'Send up to ${sendState.sendCurrency} 15,000,000.00 via virtual account. Funds will arrive within 10 minutes.',
          iconColor: AppColors.pink400,
          isSelected: _selectedPaymentMethod == 'Bank Transfer',
          isEnabled: true,
          onTap: () {
            setState(() {
              _selectedPaymentMethod = 'Bank Transfer';
            });
          },
        ),

        SizedBox(height: 16.h),

        // Digital Dollar Card
        _buildPaymentMethodOption(
          title: 'Digital Dollar',
          description:
              'Pay with a digital dollar wallet via stable coin and wallet address. Cross-border made easy.',
          iconColor: AppColors.success400,
          isSelected: _selectedPaymentMethod == 'Digital Dollar',
          isEnabled: true,
          onTap: () {
            setState(() {
              _selectedPaymentMethod = 'Digital Dollar';
            });
          },
        ),

        SizedBox(height: 16.h),

        // Debit Card Card
        _buildPaymentMethodOption(
          title: 'Debit Card',
          description:
              'Tap (NFC) or scan your debit card for instant payment. Secure and fast transactions.',
          iconColor: AppColors.info400,
          isSelected: _selectedPaymentMethod == 'Debit Card',
          isEnabled: false,
          onTap: null, // Disabled
        ),
      ],
    );
  }

  Widget _buildPaymentMethodOption({
    required String title,
    required String description,
    required Color iconColor,
    required bool isSelected,
    required bool isEnabled,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : () => _showComingSoonMessage(title),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          left: 16.w,
          top: 16.h,
          bottom: 16.h,
          right: 12.w,
        ),
        decoration: BoxDecoration(
          color:
              isEnabled
                  ? Theme.of(context).colorScheme.surface
                  : Theme.of(context).colorScheme.surface.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12.r),
          border:
              isSelected
                  ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: .75,
                  )
                  : Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0),
                    width: .75,
                  ),
          boxShadow: [
            BoxShadow(
              color:
                  isEnabled
                      ? AppColors.neutral500.withOpacity(0.0375)
                      : AppColors.neutral500.withOpacity(0.02),
              blurRadius: 8.0,
              offset: const Offset(0, 8),
              spreadRadius: .8,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: isEnabled ? iconColor : iconColor.withOpacity(0.4),
                borderRadius: BorderRadius.circular(24.r),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontFamily: 'CabinetGrotesk',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color:
                              isEnabled
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      title == "DayFi Tag"
                          ? Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warning400.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Free',
                                  style: AppTypography.labelSmall.copyWith(
                                    fontFamily: 'Karla',
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.warning600,
                                  ),
                                ),
                              ],
                            ),
                          )
                          : const SizedBox.shrink(),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12.5.sp,
                      fontFamily: 'Karla',
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.4,
                      height: 1.3,
                      color:
                          isEnabled
                              ? Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6)
                              : Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 24.w),
            // Circle check icon for selected state or Coming Soon badge
            if (isSelected)
              SvgPicture.asset(
                'assets/icons/svgs/circle-check.svg',
                color: Theme.of(context).colorScheme.primary,
                height: 24.sp,
                width: 24.sp,
              )
            else if (!isEnabled)
              _buildComingSoonBadge()
            else
              SizedBox(width: 24.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildComingSoonBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.neutral400.withOpacity(.5),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(
        'Coming Soon',
        style: AppTypography.labelSmall.copyWith(
          color: Colors.white,
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          fontFamily: 'Karla',
          letterSpacing: -.2,
        ),
      ),
    );
  }

  void _showComingSoonMessage(String paymentMethod) {
    TopSnackbar.show(
      context,
      message:
          '$paymentMethod payment method is coming soon! Stay tuned for updates.',
      isError: false,
    );
  }

  void _processPayment() async {
    // Safety check - should not be called without a selection
    if (_selectedPaymentMethod == null) {
      return;
    }

    // If Digital Dollar is selected, navigate to crypto channels instead
    if (_selectedPaymentMethod == 'Digital Dollar') {
      appRouter.pushNamed(AppRoute.cryptoChannelsView);
      return;
    }

    // If DayFi Tag is selected, handle DayFi Tag flow
    if (_selectedPaymentMethod == 'DayFi Tag') {
      _handleDayfiTagSelection();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final sendState = ref.read(sendViewModelProvider);

      // Validate that we have exchange rates for the currencies
      if (sendState.sendCurrencyRates == null ||
          sendState.receiveCurrencyRates == null) {
        ErrorHandler.showError(
          context,
          'Exchange rates not available for the selected currencies. Please try again.',
        );
        return;
      }

      // Check if we have valid buy/sell rates
      final sendRates = sendState.sendCurrencyRates;
      final receiveRates = sendState.receiveCurrencyRates;

      if (sendRates?['buy'] == 'N/A' || receiveRates?['buy'] == 'N/A') {
        ErrorHandler.showError(
          context,
          'Exchange rates not available for ${sendState.receiverCurrency}. Please select a different currency or try again later.',
        );
        return;
      }

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

      // Resolve the best channel for this transaction
      final selectedChannel = _findSelectedChannel(sendState);

      // If no valid channel is found, show an error
      if (selectedChannel == null) {
        TopSnackbar.show(
          context,
          message:
              'No valid payment channel found for ${sendState.receiverCountry}/${sendState.receiverCurrency}',
          isError: true,
        );
        return;
      }

      // Determine if redirectUrl is required for this channel/country
      final requiresRedirectUrl = _requiresRedirectUrl(
        selectedChannel,
        sendState.receiverCountry,
      );

      // Debug logs for collection data
      AppLogger.debug(
        'Recipient account: ${widget.recipientData['accountNumber']}',
      );
      AppLogger.debug(
        'Recipient networkId: ${widget.recipientData['networkId']}',
      );
      AppLogger.debug('UserId: ${widget.senderData['userId']}');
      AppLogger.debug(
        'Sender channelId: ${widget.selectedData['senderChannelId']}',
      );

      // Prepare the request data using real data from the flow
      final requestData = _buildCollectionRequest(
        sendState: sendState,
        selectedChannel: selectedChannel,
      );

      // Debug log for source object and channelId
      AppLogger.debug('Source: ${requestData["source"]}');
      AppLogger.debug('Metadata: ${requestData["metadata"]}');
      AppLogger.debug('Collection channelId: ${requestData["channelId"]}');

      // Add redirectUrl if required for this channel
      if (requiresRedirectUrl) {
        requestData["redirectUrl"] = _getRedirectUrl();
      }

      // Also add redirectUrl for South Africa and other countries that commonly require it
      // final commonRedirectCountries = [
      //   'ZA',
      //   'ZA-South Africa',
      //   'South Africa',
      //   'US',
      //   'GB',
      //   'CA',
      // ];
      // if (commonRedirectCountries.contains(sendState.receiverCountry)) {
      //   requestData["redirectUrl"] = _getRedirectUrl();
      // }

      // Make the API call
      final response = await locator<PaymentService>().createCollection(
        requestData,
      );

      if (mounted) {
        if (!response.error && response.data != null) {
          // Store the payment data for later use
          _currentPaymentData = response.data!;

          // Add transaction to monitoring for automatic payment creation
          final collectionSequenceId =
              response.data?.id ?? response.data?.sequenceId;
          if (collectionSequenceId != null) {
            final transactionMonitor = ref.read(transactionMonitorProvider);

            // Prepare payment data for when status reaches success-collection
            final paymentData = _buildPaymentMonitoringData(
              sendState: sendState,
              selectedChannel: selectedChannel,
            );

            // Add to monitoring
            transactionMonitor.addTransactionToMonitoring(
              transactionId: collectionSequenceId,
              collectionSequenceId: collectionSequenceId,
              paymentData: paymentData,
            );

            AppLogger.info(
              'Added transaction $collectionSequenceId to monitoring for automatic payment creation',
            );
          }

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
              'reason':
                  response.message.isNotEmpty
                      ? response.message
                      : 'Payment processing failed',
            },
          );
          // Show error with retry option
          _showErrorWithRetry(
            context,
            message:
                response.message.isNotEmpty
                    ? response.message
                    : 'Payment processing failed',
            onRetry: () => _processPayment(),
          );
        }
      }
    } catch (e, st) {
      // Report to Crashlytics
      try {
        await locator<CrashlyticsService>().reportError(e, st);
      } catch (_) {}
      if (mounted) {
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

        // Map to user-friendly error
        final errorMessage = _mapCollectionError(e.toString(), sendState);

        // Show error with retry option
        _showErrorWithRetry(
          context,
          message: errorMessage,
          onRetry: () => _processPayment(),
        );
        AppLogger.error(errorMessage, error: e, stackTrace: st);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Determines if a redirectUrl is required for the given channel and country
  bool _requiresRedirectUrl(dynamic channel, String country) {
    // Countries that typically require redirectUrl for payment processing
    final redirectRequiredCountries = ['ZA', 'ZA-South Africa', 'South Africa'];

    // Channel types that typically require redirectUrl
    final redirectRequiredChannels = ['card', 'online', 'web', 'redirect'];

    // Check if country requires redirect
    if (redirectRequiredCountries.contains(country)) {
      return true;
    }

    // Check if channel type requires redirect
    if (channel?.channelType != null) {
      final channelType = channel.channelType.toLowerCase();
      if (redirectRequiredChannels.any((type) => channelType.contains(type))) {
        return true;
      }
    }

    return false;
  }

  /// Generates the appropriate redirect URL for the app
  String _getRedirectUrl() {
    // For mobile apps, this should be a deep link or custom URL scheme
    // For now, using a generic success URL - replace with your actual app's deep link
    return 'dayfi://payment/success';

    // Alternative options:
    // return 'https://yourdomain.com/payment/success';
    // return 'com.dayfi.app://payment/success';
  }

  /// Formats a number with thousands separators (commas)
  String _formatNumber(double amount) {
    // Format number with thousands separators
    String formatted = amount.toStringAsFixed(2);
    List<String> parts = formatted.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : '00';

    // Add commas for thousands separators
    String formattedInteger = '';
    for (int i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        formattedInteger += ',';
      }
      formattedInteger += integerPart[i];
    }

    return '$formattedInteger.$decimalPart';
  }

  void _showBankDetailsBottomSheet(payment.PaymentData collectionData) {
    // Start the countdown timer when showing bank details
    _startCountdownTimer();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Update the modal state when countdown changes
            _countdownTimer?.cancel();
            _countdownTimer = Timer.periodic(const Duration(seconds: 1), (
              timer,
            ) {
              if (mounted) {
                setModalState(() {
                  if (_remainingTime.inSeconds > 0) {
                    _remainingTime = Duration(
                      seconds: _remainingTime.inSeconds - 1,
                    );
                  } else {
                    _countdownTimer?.cancel();
                    _onTimerExpired();
                  }
                });
              }
            });

            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
              child: Column(
                children: [
                  SizedBox(height: 18.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(height: 22.h, width: 22.w),
                        Text(
                          'Payment Details',
                          style: AppTypography.titleLarge.copyWith(
                            fontFamily: 'CabinetGrotesk',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Image.asset(
                            "assets/icons/pngs/cancelicon.png",
                            height: 22.h,
                            width: 22.w,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Instruction banner
                          Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(4.r),
                              // border: Border.all(
                              //   color: Theme.of(
                              //     context,
                              //   ).colorScheme.primary.withOpacity(0.3),
                              //   width: 1.0,
                              // ),
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
                                    'When paying into this account, ensure the name on the bank account matches your verified name on Skrrt.',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.copyWith(
                                      fontSize: 12.5.sp,
                                      fontFamily: 'Karla',
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: -0.4,
                                      height: 1.5,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 12.h),

                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 24.h,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outline.withOpacity(0.2),
                                width: 1.0,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 8.h),

                                // Transfer details
                                Text(
                                  'Transfer details:',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleLarge?.copyWith(
                                    fontFamily: 'CabinetGrotesk',
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                SizedBox(height: 16.h),

                                // Amount to send
                                _buildDetailRow(
                                  'Amount to send',
                                  '₦${_formatNumber(collectionData.convertedAmount ?? 0.0)}',
                                  showCopy: true,
                                ),

                                SizedBox(height: 12.h),

                                // Account number
                                _buildDetailRow(
                                  'Account number',
                                  collectionData.bankInfo?.accountNumber ??
                                      'N/A',
                                  showCopy: true,
                                ),

                                SizedBox(height: 12.h),
                                _buildDetailRow(
                                  'Account name',
                                  collectionData.bankInfo?.accountName ?? 'N/A',
                                  showCopy: true,
                                ),

                                SizedBox(height: 12.h),

                                // Bank name
                                _buildDetailRow(
                                  'Bank name',
                                  collectionData.bankInfo?.name ?? 'N/A',
                                ),

                                Divider(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outline.withOpacity(0.2),
                                  height: 48.h,
                                ),

                                // Expiration warning
                                Row(
                                  children: [
                                    // Icon(
                                    //   Icons.info_outline,
                                    //   color: AppColors.warning600,
                                    //   size: 20.w,
                                    // ),
                                    // SizedBox(width: 12.w),
                                    Expanded(
                                      child: Text(
                                        'The account details is valid for only this transaction and it expires in ${_formatRemainingTime()} minutes.',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.copyWith(
                                          fontFamily: 'Karla',
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: -0.4,
                                          fontSize: 14.sp,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 8.h),
                              ],
                            ),
                          ),

                          SizedBox(height: 18.h),

                          // Instruction text
                          Text(
                            'Tap the "I have paid" button below after completing your transfer.',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              letterSpacing: -.3,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.95),
                            ),
                          ),

                          SizedBox(height: 24.h),
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
                            // Navigate to success screen and clear all previous routes
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => SendPaymentSuccessView(
                                      recipientData: widget.recipientData,
                                      selectedData: widget.selectedData,
                                      paymentData: widget.paymentData,
                                      collectionData: _currentPaymentData,
                                      transactionId:
                                          _currentPaymentData?.id ??
                                          _currentPaymentData?.sequenceId,
                                    ),
                              ),
                              (Route route) =>
                                  false, // Remove all previous routes
                            );
                          },
                          backgroundColor: AppColors.purple500,
                          height: 60.h,
                          textColor: AppColors.neutral0,
                          fontFamily: 'Karla',
                          letterSpacing: -.8,
                          fontSize: 18,
                          width: double.infinity,
                          fullWidth: true,
                          borderRadius: 38,
                        ),

                        // SizedBox(height: 12.h),

                        // Change payment method button
                        // SecondaryButton(
                        //   text: 'Change payment method',
                        //   onPressed: () => Navigator.pop(context),
                        //   backgroundColor: Colors.transparent,
                        //   textColor: AppColors.purple500,
                        //   borderColor: AppColors.purple500,
                        //   height: 60.h,
                        //   borderRadius: 38,
                        //   fontFamily: 'Karla',
                        //   letterSpacing: -.8,
                        //   fontSize: 18,
                        //   width: double.infinity,
                        //   fullWidth: true,
                        // ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),
                ],
              ),
            );
          },
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
            letterSpacing: -.3,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
                  // Add haptic feedback for better UX
                  HapticFeedback.lightImpact();

                  Clipboard.setData(ClipboardData(text: value));
                  TopSnackbar.show(
                    context,
                    message: label == 'DayFi Tag' 
                        ? 'DayFi Tag copied to clipboard' 
                        : 'Account number copied to clipboard',
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
      ],
    );
  }

  /// Creates a WalletTransaction from PaymentData for navigation purposes
  WalletTransaction _createWalletTransactionFromPaymentData(
    payment.PaymentData paymentData,
  ) {
    final sendState = ref.read(sendViewModelProvider);

    return WalletTransaction(
      id: paymentData.id ?? 'TXN-${DateTime.now().millisecondsSinceEpoch}',
      sendChannel: paymentData.channelId,
      sendNetwork: paymentData.source?.networkId,
      sendAmount: paymentData.amount,
      receiveChannel: paymentData.channelId,
      receiveNetwork: paymentData.source?.networkId,
      receiveAmount: paymentData.convertedAmount,
      status: paymentData.status ?? 'pending-collection',
      reason:
          paymentData.reason ??
          widget.paymentData['reason'] ??
          'Money Transfer',
      timestamp: paymentData.createdAt ?? DateTime.now().toIso8601String(),
      beneficiary: Beneficiary(
        id: paymentData.recipient?.email ?? 'unknown',
        name:
            paymentData.recipient?.name ??
            widget.recipientData['name'] ??
            'Recipient',
        country: paymentData.recipient?.country ?? sendState.receiverCountry,
        phone:
            paymentData.recipient?.phone ??
            widget.recipientData['phone'] ??
            '+2340000000000',
        address:
            paymentData.recipient?.address ??
            widget.recipientData['address'] ??
            'Not provided',
        dob:
            paymentData.recipient?.dob ??
            widget.recipientData['dob'] ??
            '1990-01-01',
        email:
            paymentData.recipient?.email ??
            widget.recipientData['email'] ??
            'recipient@example.com',
        idNumber:
            paymentData.recipient?.idNumber ??
            widget.recipientData['idNumber'] ??
            'A12345678',
        idType:
            paymentData.recipient?.idType ??
            widget.recipientData['idType'] ??
            'passport',
      ),
      source: Source(
        id: paymentData.source?.networkId,
        accountType: paymentData.source?.accountType ?? 'bank',
        accountNumber:
            paymentData.source?.accountNumber ??
            widget.selectedData['accountNumber'] ??
            '1111111111',
        networkId:
            paymentData.source?.networkId ??
            widget.selectedData['networkId'] ??
            '31cfcc77-8904-4f86-879c-a0d18b4b9365',
        beneficiaryId: paymentData.recipient?.email,
      ),
    );
  }

  /// Navigates to main view with clean navigation stack
  void _navigateToMainViewWithCleanStack({int tabIndex = 1}) {
    // Clear the navigation stack and navigate to main view with specified tab
    appRouter.pushNamedAndRemoveUntil(
      AppRoute.mainView,
      (Route route) => false, // Remove all previous routes
      arguments: tabIndex,
    );
  }

  /// Navigates to transaction details after going to main view
  void _navigateToTransactionDetails() {
    if (_currentPaymentData == null) return;

    // First navigate to main view with clean stack
    _navigateToMainViewWithCleanStack(tabIndex: 1);

    // Then navigate to transaction details after a short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      final transaction = _createWalletTransactionFromPaymentData(
        _currentPaymentData!,
      );
      appRouter.pushNamed(
        AppRoute.transactionDetailsView,
        arguments: transaction,
      );
    });
  }

  /// Show error dialog with retry option
  void _showErrorWithRetry(
    BuildContext context, {
    required String message,
    required VoidCallback onRetry,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            'Payment Error',
            style: AppTypography.titleLarge.copyWith(
              fontFamily: 'CabinetGrotesk',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            message,
            style: AppTypography.bodyMedium.copyWith(fontFamily: 'Karla'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Go back to previous screen
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
            PrimaryButton(
              text: 'Retry',
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              backgroundColor: AppColors.purple500,
              textColor: AppColors.neutral0,
              height: 40.h,
              width: 80.w,
              borderRadius: 20.r,
            ),
          ],
        );
      },
    );
  }
}
