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
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/features/send/vm/send_viewmodel.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/models/payment_response.dart' as payment;
import 'package:dayfi/models/payment_response.dart' show Network, Channel;
import 'package:dayfi/models/user_model.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/features/send/views/send_payment_success_view.dart';
import 'dart:async';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/common/utils/error_handler.dart';
import 'package:dayfi/services/local/crashlytics_service.dart';
import 'package:dayfi/services/remote/wallet_service.dart';
import 'package:dayfi/features/send/views/bank_transfer_amount_view.dart';
import 'package:dayfi/common/utils/phone_country_utils.dart';
import 'package:dayfi/features/home/vm/home_viewmodel.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:intercom_flutter/intercom_flutter.dart';

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
  bool _isCheckingWallet = false;

  // Constants
  static const String _defaultPhone = '+2340000000000';
  static const String _targetCountry = 'NG';
  static const String _targetCurrency = 'NGN';
  static const String _targetStatus = 'active';
  static const String _targetRampType = 'deposit';
  static const Set<String> _validChannelTypes = {
    'bank',
    'p2p',
    'bank_transfer',
  };
  static const List<String> _redirectCountries = [
    'ZA',
    'ZA-South Africa',
    'South Africa',
  ];
  static const List<String> _redirectChannels = [
    'card',
    'online',
    'web',
    'redirect',
  ];

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
    required String encryptedPin,
  }) {
    // Check if this is a crypto funding request
    final isCrypto =
        widget.selectedData['cryptoCurrency'] != null ||
        widget.selectedData['cryptoNetwork'] != null;

    final requestData = {
      "amount":
          double.tryParse(
            sendState.sendAmount.replaceAll(RegExp(r'[^\d.]'), ''),
          ) ??
          0,
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
      "encryptedPin": encryptedPin,
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
        "accountNumber":
            widget.recipientData['accountNumber'] ??
            widget.recipientData['walletAddress'] ??
            (isCrypto ? "" : "1111111111"),
        "networkId":
            widget.recipientData['networkId'] ??
            widget.selectedData['cryptoNetwork'] ??
            "",
      },
      "metadata": {
        "customerId": widget.senderData['userId'] ?? "12345",
        "orderId": "COLL-${DateTime.now().millisecondsSinceEpoch}",
        "description": widget.paymentData['description'] ?? "",
      },
    };

    // Add crypto-specific fields if this is a crypto request
    if (isCrypto) {
      requestData["cryptoCurrency"] =
          widget.selectedData['cryptoCurrency'] ?? "";
      requestData["cryptoNetwork"] = widget.selectedData['cryptoNetwork'] ?? "";
      requestData["walletAddress"] =
          widget.recipientData['walletAddress'] ??
          widget.selectedData['walletAddress'] ??
          "";
      if (widget.selectedData['requiresMemo'] == true) {
        requestData["memo"] =
            widget.recipientData['memo'] ?? widget.selectedData['memo'] ?? "";
      }
    }

    return requestData;
  }

  String _mapCollectionError(String raw, SendState sendState) {
    if (raw.contains('No buy rate for currency')) {
      final currencyMatch = RegExp(
        r'No buy rate for currency (\\w+)',
      ).firstMatch(raw);
      final currency =
          currencyMatch?.group(1) ??
          (sendState.receiverCurrency.isNotEmpty
              ? sendState.receiverCurrency
              : 'selected currency');
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

    // Fast path: Check cached wallet data first (no network call)
    final homeState = ref.read(homeViewModelProvider);
    String? dayfiId;

    // Check cached wallets first - super fast!
    if (homeState.wallets.isNotEmpty) {
      for (final wallet in homeState.wallets) {
        if (wallet.dayfiId.isNotEmpty) {
          dayfiId = wallet.dayfiId;
          break; // Found it, exit early
        }
      }
    }

    // If not found in cache, check primary wallet
    if (dayfiId == null &&
        homeState.primaryWallet?.dayfiId.isNotEmpty == true) {
      dayfiId = homeState.primaryWallet!.dayfiId;
    }

    // If found in cache, show bottom sheet immediately (no loading, no network call)
    if (dayfiId != null && dayfiId.isNotEmpty) {
      _showDayfiTagBottomSheet(dayfiId);
      return;
    }

    // Only fetch from network if cache is empty (rare case)
    try {
      setState(() {
        _isCheckingWallet = true;
      });

      final walletService = locator<WalletService>();
      final walletResponse = await walletService.fetchWalletDetails();

      // Check if any wallet has a non-empty Dayfi ID
      for (final wallet in walletResponse.wallets) {
        if (wallet.dayfiId.isNotEmpty) {
          dayfiId = wallet.dayfiId;
          break; // Found it, exit early
        }
      }

      if (mounted) {
        setState(() {
          _isCheckingWallet = false;
        });
      }

      if (dayfiId != null && dayfiId.isNotEmpty) {
        _showDayfiTagBottomSheet(dayfiId);
      } else {
        // User doesn't have a DayFi Tag, navigate to creation
        final result = await Navigator.pushNamed(
          context,
          AppRoute.dayfiTagExplanationView,
        );
        if (result != null && result is String && mounted) {
          _showDayfiTagBottomSheet(result);
        }
      }
    } catch (e) {
      AppLogger.error('Error checking Dayfi ID: $e');
      if (mounted) {
        setState(() {
          _isCheckingWallet = false;
        });
        // Navigate to explanation view
        await Navigator.pushNamed(context, AppRoute.dayfiTagExplanationView);
      }
    }
  }

  void _showDayfiTagBottomSheet(String dayfiId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (BuildContext context) {
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
                    SizedBox(height: 24.h, width: 22.w),
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
                        height: 24.h,
                        width: 24.w,
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
                          color: Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(width: 4.w),
                            Image.asset("assets/images/idea.png", height: 18.h),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                'Share your DayFi Tag with friends and family for instant money transfers.',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(
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
                      SizedBox(height: 18.h),
                      CustomTextField(
                        label: "dayfi ID",
                        hintText: "",
                        enableInteractiveSelection: false,
                        shouldReadOnly: true,
                        controller: TextEditingController(
                          text: dayfiId.startsWith('@') ? dayfiId : '@$dayfiId',
                        ),
                        onChanged: (value) {},
                        keyboardType: TextInputType.text,
                        suffixIcon: Container(
                          constraints: BoxConstraints.tightForFinite(),
                          margin: EdgeInsets.symmetric(
                            vertical: 12.0.h,
                            horizontal: 10.0.w,
                          ),
                          height: 32.h,
                          child: GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(
                                  text: dayfiId.startsWith('@') ? dayfiId : '@$dayfiId',
                                ),
                              );
                              TopSnackbar.show(
                                context,
                                message: 'DayFi Tag copied to clipboard',
                                isError: false,
                              );
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.copy,
                                  color: AppColors.purple500ForTheme(context),
                                  size: 20.sp,
                                ),
                                SizedBox(width: 3.w),
                                Text(
                                  dayfiId.startsWith('@') ? dayfiId : '@$dayfiId',
                                  style: TextStyle(
                                    fontFamily: 'Karla',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16.sp,
                                    letterSpacing: 0.00,
                                    height: 1.450,
                                    color: AppColors.purple500ForTheme(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 48.h),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    PrimaryButton(
                      text: 'Next - Close',
                      onPressed: () {
                        Navigator.pop(context);
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
                    SizedBox(height: 20.h),
                    PrimaryButton(
                      text: 'Do you need help?',
                      onPressed: () async {
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
                      },
                      backgroundColor: Colors.transparent,
                      textColor: AppColors.purple500ForTheme(context),
                      height: 60.h,
                      fontFamily: 'Karla',
                      letterSpacing: -.8,
                      fontSize: 18,
                      width: double.infinity,
                      fullWidth: true,
                      borderRadius: 40.r,
                    ),
                    SizedBox(height: 20.h),
                  ],
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
          'Funding Methods',
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
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 4.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Choose a funding method that works for you",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                fontFamily: 'Karla',
                letterSpacing: -.6,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 36.h),

            // Payment Method Card
            // Container(
            //   padding: EdgeInsets.all(12.w),
            //   decoration: BoxDecoration(
            //     color: Theme.of(
            //       context,
            //     ).colorScheme.primaryContainer.withOpacity(0.25),
            //     borderRadius: BorderRadius.circular(4.r),
            //     // border: Border.all(
            //     //   color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            //     //   width: 1.0,
            //     // ),
            //   ),
            //   child: Row(
            //     crossAxisAlignment: CrossAxisAlignment.center,
            //     children: [
            //       SizedBox(width: 4.w),
            //       Image.asset(
            //         "assets/images/idea.png",
            //         height: 18.h,
            //         // color: Theme.of(context).colorScheme.primary,
            //       ),
            //       SizedBox(width: 12.w),
            //       Expanded(
            //         child: Text(
            //           "Please prepare your KYC documents in case we require verification to complete this transaction.",
            //           style: Theme.of(context).textTheme.bodySmall?.copyWith(
            //             fontSize: 12.5.sp,
            //             fontFamily: 'Karla',
            //             fontWeight: FontWeight.w400,
            //             letterSpacing: -0.4,
            //             height: 1.5,
            //             color: Theme.of(context).colorScheme.primary,
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            _buildPaymentMethodCard(sendState),

            SizedBox(height: 40.h),
            PrimaryButton(
              text:
                  _isCheckingWallet
                      ? 'Checking...'
                      : _selectedPaymentMethod != null
                      ? _selectedPaymentMethod == 'DayFi Tag'
                          ? 'Continue'
                          : 'Pay with $_selectedPaymentMethod'
                      : 'Select a Funding Method',
              onPressed:
                  (_selectedPaymentMethod != null && !_isCheckingWallet)
                      ? _processPayment
                      : null,
              isLoading: _isLoading || _isCheckingWallet,
              height: 60.h,
              backgroundColor:
                  (_selectedPaymentMethod != null && !_isCheckingWallet)
                      ? AppColors.purple500
                      : AppColors.purple500.withOpacity(.25),
              textColor:
                  (_selectedPaymentMethod != null && !_isCheckingWallet)
                      ? AppColors.neutral0
                      : AppColors.neutral0.withOpacity(.5),
              fontFamily: 'Karla',
              letterSpacing: -.8,
              fontSize: 18,
              width: double.infinity,
              fullWidth: true,
              borderRadius: 40.r,
            ),

            SizedBox(height: 40.h),
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
          icon: Stack(
            alignment: AlignmentDirectional.center,

            children: [
              SvgPicture.asset(
                'assets/icons/svgs/bankk.svg',
                height: 32.sp,
                width: 32.sp,
                color: AppColors.neutral500,
              ),
              Text(
                '@',
                style: TextStyle(
                  fontFamily: 'CabinetGrotesk',
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          title: 'DayFi Tag',
          description:
              'Share your DayFi Tag with friends and family. Instant transfers. (NGN only)',
          iconColor: AppColors.orange500,
          isSelected: _selectedPaymentMethod == 'DayFi Tag',
          isEnabled: true,
          onTap: () {
            // if (sendState.receiverCurrency != 'NGN') {
            //   ErrorHandler.showError(
            //     context,
            //     'DayFi Tag transfers are only available for NGN (Nigerian Naira). Please select NGN as the recipient currency.',
            //   );
            //   return;
            // }
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
          icon: SvgPicture.asset(
            'assets/icons/svgs/bankk.svg',
            height: 32.sp,
            width: 32.sp,
          ),
          onTap: () {
            setState(() {
              _selectedPaymentMethod = 'Bank Transfer';
            });
          },
        ),

        SizedBox(height: 16.h),

        // Digital Dollar Card
        _buildPaymentMethodOption(
          icon: Opacity(
            opacity: .4,
            child: SvgPicture.asset(
              'assets/icons/svgs/cryptoo.svg',
              height: 32.sp,
              width: 32.sp,
            ),
          ),
          title: 'Digital Dollar',
          description:
              'Pay with a digital dollar wallet via stable coin and wallet address. Cross-border made easy.',
          iconColor: AppColors.success400,
          isSelected: _selectedPaymentMethod == 'Digital Dollar',
          isEnabled: false,
          onTap: null, // Disabled
        ),

        SizedBox(height: 16.h),

        // Debit Card Card
        _buildPaymentMethodOption(
          icon: Opacity(
            opacity: .4,
            child: SvgPicture.asset(
              'assets/icons/svgs/cardd.svg',
              height: 32.sp,
              width: 32.sp,
            ),
          ),
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
    required Widget icon,
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
                    color: AppColors.purple500ForTheme(context),
                    width: .75,
                  )
                  : Border.all(
                    color: AppColors.purple500ForTheme(context).withOpacity(0),
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
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32.w,
                        height: 32.w,
                        // padding: EdgeInsets.all(2.h),
                        decoration: BoxDecoration(
                          // color: isEnabled ? iconColor : iconColor.withOpacity(.25),
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        child: icon,
                      ),
                      SizedBox(width: 12.w),
                      Row(
                        children: [
                          Text(
                            title,
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              fontFamily: 'CabinetGrotesk',
                              fontSize: 18.sp,
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
                color: AppColors.purple500ForTheme(context),
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
    // TopSnackbar.show(
    //   context,
    //   message:
    //       '$paymentMethod payment method is coming soon! Stay tuned for updates.',
    //   isError: false,
    // );
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

    // For Bank Transfer, navigate to amount entry screen first
    if (_selectedPaymentMethod == 'Bank Transfer') {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => BankTransferAmountView(
                selectedData: widget.selectedData,
                recipientData: widget.recipientData,
                senderData: widget.senderData,
                paymentData: widget.paymentData,
              ),
        ),
      );

      // If amount was entered successfully, proceed with payment
      if (result == true) {
        await _processBankTransferPayment();
      }
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
      // Note: For Bank Transfer, encryptedPin should already be included via PIN flow
      final requestData = _buildCollectionRequest(
        sendState: sendState,
        selectedChannel: selectedChannel,
        encryptedPin: '', // This won't be used for non-Bank Transfer methods
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

  /// Format a number with thousands separators (commas)
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
                        SizedBox(height: 24.h, width: 22.w),
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
                            height: 24.h,
                            width: 24.w,
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
                        //   textColor: AppColors.purple500ForTheme(context),
                        //   borderColor: AppColors.purple500ForTheme(context),
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
                    message:
                        label == 'DayFi Tag'
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

  /// Fetch user data asynchronously (for parallel execution)
  Future<User?> _fetchUserData() async {
    try {
      final userData = await localCache.getUser();
      if (userData.isNotEmpty && userData.containsKey('user_id')) {
        final user = User.fromJson(userData);
        AppLogger.info(
          'Loaded app user data: ${user.firstName} ${user.lastName}',
        );
        return user;
      } else {
        AppLogger.warning('User data not found or invalid');
        return null;
      }
    } catch (e) {
      AppLogger.error('Error loading user data: $e');
      return null;
    }
  }

  /// Format phone number to international format (optimized)
  String _formatPhoneNumber(String? rawPhoneNumber, String countryCode) {
    if (rawPhoneNumber == null ||
        rawPhoneNumber.isEmpty ||
        rawPhoneNumber == '0000000000') {
      return '+2340000000000'; // Default fallback
    }

    // Clean the phone number: remove all non-digits first
    String cleanedNumber = rawPhoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // Remove leading 0 if present (local prefix that should be replaced with country code)
    if (cleanedNumber.startsWith('0')) {
      cleanedNumber = cleanedNumber.substring(1);
    }

    // Use PhoneCountryUtils to format the phone number
    final formatted = PhoneCountryUtils.formatPhoneNumber(
      cleanedNumber,
      countryCode.isNotEmpty ? countryCode : 'NG',
    );

    // Ensure it starts with + (formatPhoneNumber should handle this, but double-check)
    return formatted.startsWith('+234') ? formatted : '+234$formatted';
  }

  /// Process bank transfer payment after amount entry
  Future<void> _processBankTransferPayment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final sendState = ref.read(sendViewModelProvider);
      final paymentService = locator<PaymentService>();

      // Analytics: collection creation started (non-blocking)
      analyticsService.logEvent(
        name: 'collection_creation_started',
        parameters: {
          'amount': sendState.sendAmount,
          'currency': sendState.sendCurrency,
          'recipient_country': sendState.receiverCountry,
          'delivery_method': sendState.selectedDeliveryMethod,
        },
      );

      // Parallel fetch: channels, networks, and user data simultaneously
      AppLogger.info(
        'Fetching channels, networks, and user data in parallel...',
      );
      final results = await Future.wait([
        paymentService.fetchChannels(),
        paymentService.fetchNetworks(),
        _fetchUserData(),
      ], eagerError: false);

      // Extract results
      final channelsResponse = results[0] as payment.PaymentResponse;
      final networksResponse = results[1] as payment.PaymentResponse;
      final currentUser = results[2] as User?;

      // Validate channels response
      if (channelsResponse.error || channelsResponse.data?.channels == null) {
        if (mounted) {
          TopSnackbar.show(
            context,
            message: 'Failed to fetch payment channels. Please try again.',
            isError: true,
          );
        }
        return;
      }

      // Validate networks response
      if (networksResponse.error || networksResponse.data?.networks == null) {
        if (mounted) {
          TopSnackbar.show(
            context,
            message: 'Failed to fetch payment networks. Please try again.',
            isError: true,
          );
        }
        return;
      }

      final channels = channelsResponse.data!.channels!;
      final networks = networksResponse.data!.networks!;
      AppLogger.info(
        'Fetched ${channels.length} channels and ${networks.length} networks',
      );

      // Optimized filtering: pre-compute lowercase channel types and filter efficiently
      Channel? bankChannel;
      Channel? fallbackChannel;

      for (final channel in channels) {
        // Early exit conditions for performance
        if (channel.country != _targetCountry ||
            channel.currency != _targetCurrency ||
            channel.status != _targetStatus ||
            channel.rampType != _targetRampType) {
          continue;
        }

        final channelTypeLower = channel.channelType?.toLowerCase();
        if (channelTypeLower != null &&
            _validChannelTypes.contains(channelTypeLower)) {
          // Prefer bank channel
          if ((channelTypeLower == 'bank' ||
                  channelTypeLower == 'bank_transfer') &&
              bankChannel == null) {
            bankChannel = channel;
            // ignore: prefer_conditional_assignment
          } else if (fallbackChannel == null) {
            fallbackChannel = channel;
          }
        }
      }

      // Select channel (prefer bank over fallback)
      final selectedChannel = bankChannel ?? fallbackChannel;
      if (selectedChannel == null) {
        if (mounted) {
          TopSnackbar.show(
            context,
            message:
                'No active deposit channel found for Nigeria NGN. Please try again later.',
            isError: true,
          );
        }
        return;
      }

      AppLogger.info(
        'Selected channel: ${selectedChannel.id} - ${selectedChannel.channelType}',
      );

      // Find network using Map for O(1) lookup instead of O(n) iteration
      final channelId = selectedChannel.id;
      Network? selectedNetwork;

      if (channelId != null) {
        // Create a map of channel IDs to networks for fast lookup
        for (final network in networks) {
          if (network.channelIds?.contains(channelId) == true) {
            selectedNetwork = network;
            break; // Found, exit early
          }
        }
      }

      if (selectedNetwork == null) {
        AppLogger.warning('No network found for channel ${selectedChannel.id}');
      } else {
        AppLogger.info(
          'Found network: ${selectedNetwork.id} - ${selectedNetwork.name}',
        );
      }

      // Build collection request payload (pre-compute values)
      final amount =
          double.tryParse(
            sendState.sendAmount.replaceAll(RegExp(r'[^\d.]'), ''),
          ) ??
          0.0;

      // Get recipient country for phone formatting
      final recipientCountry =
          currentUser?.country ??
          widget.recipientData['country'] ??
          sendState.receiverCountry;

      // Format phone number efficiently (only if needed)
      final rawPhoneNumber =
          currentUser?.phoneNumber ?? widget.recipientData['phone'];
      final formattedPhoneNumber = _formatPhoneNumber(
        rawPhoneNumber,
        recipientCountry.isNotEmpty ? recipientCountry : 'NG',
      );

      final requestData = {
        "amount": amount,
        "currency": sendState.sendCurrency,
        "channelId": selectedChannel.id ?? "",
        "channelName":
            selectedNetwork?.name ??
            selectedChannel.channelType ??
            "Bank Transfer",
        "country": sendState.sendCountry,
        "reason": widget.paymentData['reason'] ?? "Funding wallet",
        "receiveChannel": selectedChannel.id ?? "",
        "receiveNetwork": selectedNetwork?.id ?? "",
        "receiveAmount": amount,
        "recipient": {
          "name":
              currentUser != null
                  ? '${currentUser.firstName} ${currentUser.lastName}'.trim()
                  : widget.recipientData['name'] ?? 'Self Funding',
          "country": recipientCountry,
          "phone": formattedPhoneNumber,
          "address":
              currentUser?.address ??
              widget.recipientData['address'] ??
              'Not provided',
          "dob":
              currentUser?.dateOfBirth ??
              widget.recipientData['dob'] ??
              '1990-01-01',
          "email":
              currentUser?.email ??
              widget.recipientData['email'] ??
              'recipient@example.com',
          "idNumber":
              currentUser?.idNumber ??
              widget.recipientData['idNumber'] ??
              'A12345678',
          "idType":
              currentUser?.idType ??
              widget.recipientData['idType'] ??
              'passport',
        },
        "source": {
          "accountType": "bank",
          "accountNumber":
              widget.recipientData['accountNumber'] ??
              widget.recipientData['walletAddress'] ??
              "1111111111",
          "networkId":
              selectedNetwork?.id ?? widget.recipientData['networkId'] ?? "",
        },
        "metadata": {
          "customerId":
              currentUser?.userId ?? widget.senderData['userId'] ?? "12345",
          "orderId": "COLL-${DateTime.now().millisecondsSinceEpoch}",
          "description": widget.paymentData['description'] ?? "",
        },
      };

      AppLogger.debug('Collection request payload: $requestData');

      // Determine if redirectUrl is required for this channel/country
      final requiresRedirectUrl = _requiresRedirectUrl(
        selectedChannel,
        sendState.receiverCountry,
      );

      // Add redirectUrl if required for this channel
      if (requiresRedirectUrl) {
        requestData["redirectUrl"] = _getRedirectUrl();
      }

      // Step 6: Make the API call to create collection
      AppLogger.info('Creating collection...');
      final response = await paymentService.createCollection(requestData);

      if (mounted) {
        if (!response.error && response.data != null) {
          // Store the payment data for later use
          _currentPaymentData = response.data!;

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
            onRetry: () => _processBankTransferPayment(),
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
          onRetry: () => _processBankTransferPayment(),
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
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),

          child: Container(
            padding: EdgeInsets.all(28.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Biometric icon
                Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: BoxDecoration(
                    // gradient: LinearGradient(
                    //   begin: Alignment.topLeft,
                    //   end: Alignment.bottomRight,
                    //   colors: [
                    //     AppColors.purple500ForTheme(context).withOpacity(0.1),
                    //     AppColors.purple500ForTheme(context).withOpacity(0.05),
                    //   ],
                    // ),
                    shape: BoxShape.circle,
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: AppColors.purple500ForTheme(context).withOpacity(0.1),
                    //     blurRadius: 20,
                    //     spreadRadius: 2,
                    //     offset: const Offset(0, 4),
                    //   ),
                    // ],
                  ),
                  // child: Icon(
                  //   Icons.security_rounded,
                  //   color: AppColors.purple500ForTheme(context),
                  //   size: 40.w,
                  // ),
                  child: SvgPicture.asset('assets/icons/svgs/cautionn.svg'),
                ),

                SizedBox(height: 24.h),

                // Title
                Text(
                  'Payment Error',
                  style: AppTypography.titleLarge.copyWith(
                    fontFamily: 'CabinetGrotesk',
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),

                // SizedBox(height: 16.h),

                // // Description
                // Text(
                //   message,
                //   style: AppTypography.bodyMedium.copyWith(
                //     fontFamily: 'Karla',
                //     fontSize: 14.sp,
                //     fontWeight: FontWeight.w400,
                //     color: Theme.of(
                //       context,
                //     ).colorScheme.onSurface.withOpacity(0.7),
                //     height: 1.4,
                //   ),
                //   textAlign: TextAlign.center,
                // ),
                SizedBox(height: 24.h),

                // Enable button
                PrimaryButton(
                  text: 'Retry',
                  onPressed: () {
                    Navigator.of(context).pop();
                    onRetry();
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
                  letterSpacing: -0.8,
                ),
                SizedBox(height: 12.h),

                // Skip button
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Go back to previous screen
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: AppTypography.bodyMedium.copyWith(
                      fontFamily: 'Karla',
                      fontSize: 16.sp,
                      letterSpacing: -0.8,
                      fontWeight: FontWeight.w400,
                      color: AppColors.neutral300,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
