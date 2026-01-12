import 'package:dayfi/common/widgets/error_state_widget.dart';
import 'package:dayfi/common/widgets/shimmer_widgets.dart';
import 'dart:convert';
import 'dart:developer';

import 'package:dayfi/common/constants/storage_keys.dart';
import 'package:dayfi/common/widgets/buttons/buttons.dart';
import 'package:dayfi/services/local/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dayfi/common/utils/haptic_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:share_plus/share_plus.dart';

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
  /// Helper to get country name from code
  String _getCountryName(String? countryCode) {
    switch (countryCode?.toUpperCase()) {
      case 'NG':
        return 'Nigeria';
      case 'GH':
        return 'Ghana';
      case 'RW':
        return 'Rwanda';
      case 'KE':
        return 'Kenya';
      case 'UG':
        return 'Uganda';
      case 'TZ':
        return 'Tanzania';
      case 'ZA':
        return 'South Africa';
      case 'BF':
        return 'Burkina Faso';
      case 'BJ':
        return 'Benin';
      case 'BW':
        return 'Botswana';
      case 'CD':
        return 'Democratic Republic of Congo';
      case 'CG':
        return 'Republic of Congo';
      case 'CI':
        return 'Côte d\'Ivoire';
      case 'CM':
        return 'Cameroon';
      case 'GA':
        return 'Gabon';
      case 'MW':
        return 'Malawi';
      case 'ML':
        return 'Mali';
      case 'SN':
        return 'Senegal';
      case 'TG':
        return 'Togo';
      case 'ZM':
        return 'Zambia';
      case 'US':
        return 'United States';
      case 'GB':
        return 'United Kingdom';
      case 'CA':
        return 'Canada';
      default:
        return countryCode ?? 'Unknown';
    }
  }

  payment.PaymentData? _currentPaymentData; // Store the current payment data
  Timer? _countdownTimer;
  Duration _remainingTime = const Duration(minutes: 30);

  bool _isCheckingWallet = false;
  bool _isLoading = false;

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
    // Name mismatch error (Nigeria only)
    if (raw.contains('name') && raw.contains('match') ||
        raw.toLowerCase().contains('name mismatch') ||
        raw.toLowerCase().contains('name does not match') ||
        raw.toLowerCase().contains('payer name')) {
      return 'The name on your bank account doesn\'t match your verified name on Dayfi App. Please ensure you\'re paying from an account that matches your registered name.';
    }
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

      // Check if any wallet has a non-empty Dayfi Tag
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
        // User doesn't have a Dayfi Tag, navigate to creation
        final result = await Navigator.pushNamed(
          context,
          AppRoute.dayfiTagExplanationView,
        );
        if (result != null && result is String && mounted) {
          _showDayfiTagBottomSheet(result);
        }
      }
    } catch (e) {
      AppLogger.error('Error checking Dayfi Tag: $e');
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
      barrierColor: Colors.black.withOpacity(0.85),
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              SizedBox(height: 18),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(height: 40, width: 40),
                    Text(
                      'My Dayfi Tag',
                      style: AppTypography.titleLarge.copyWith(
                        fontFamily: 'FunnelDisplay',
                        fontSize: 20,
                        // height: 1.6,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),

                    InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap:
                          () => {
                            Navigator.pop(context),
                            FocusScope.of(context).unfocus(),
                          },
                      child: Stack(
                        alignment: AlignmentGeometry.center,
                        children: [
                          SvgPicture.asset(
                            "assets/icons/svgs/notificationn.svg",
                            height: 40,
                            color: Theme.of(context).colorScheme.surface,
                          ),
                          SizedBox(
                            height: 40,
                            width: 40,
                            child: Center(
                              child: Image.asset(
                                "assets/icons/pngs/cancelicon.png",
                                height: 20,
                                width: 20,
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyLarge!.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 18),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Opacity(
                          opacity: .85,
                          child: Text(
                            'Share your Dayfi Tag with friends and family for instant money transfers.',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Chirp',
                              letterSpacing: -.25,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(height: 32),
                      CustomTextField(
                        label: "Dayfi Tag",
                        hintText: "",
                        enableInteractiveSelection: false,
                        shouldReadOnly: true,
                        controller: TextEditingController(
                          text: dayfiId.startsWith('@') ? dayfiId : '@$dayfiId',
                        ),
                        // textStyle: TextStyle(
                        //   fontFamily: 'Chirp',
                        //   fontWeight: FontWeight.w600,
                        //   fontSize: 16,
                        //   letterSpacing: 0.00,
                        //   height: 1.450,
                        //   color: AppColors.purple500ForTheme(context),
                        // ),
                        onChanged: (value) {},
                        keyboardType: TextInputType.text,
                        suffixIcon: Container(
                          width: 150,
                          alignment:
                              Alignment.centerRight, // Align to the right
                          constraints: BoxConstraints.tightForFinite(),
                          margin: EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 10.0,
                          ),
                          height: 32,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Copy button
                              GestureDetector(
                                onTap: () {
                                  HapticHelper.lightImpact();
                                  Clipboard.setData(
                                    ClipboardData(
                                      text:
                                          dayfiId.startsWith('@')
                                              ? dayfiId
                                              : '@$dayfiId',
                                    ),
                                  );
                                  TopSnackbar.show(
                                    context,
                                    message: 'Dayfi Tag copied to clipboard',
                                    isError: false,
                                  );
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "copy",
                                      style: TextStyle(
                                        fontFamily: 'Chirp',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                        letterSpacing: 0.00,
                                        height: 1.450,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    SvgPicture.asset(
                                      "assets/icons/svgs/copy.svg",
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      height: 16,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 16),
                              // Share button
                              GestureDetector(
                                onTap: () async {
                                  HapticHelper.lightImpact();
                                  try {
                                    final tagToShare =
                                        dayfiId.startsWith('@')
                                            ? dayfiId
                                            : '@$dayfiId';
                                    await Share.share(
                                      'Send me money on DayFi! My tag is $tagToShare\n\nDownload DayFi: https://dayfi.co',
                                      subject: 'My Dayfi Tag',
                                    );
                                  } catch (e) {
                                    if (mounted) {
                                      TopSnackbar.show(
                                        context,
                                        message:
                                            'Unable to share. Please try again.',
                                        isError: true,
                                      );
                                    }
                                  }
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "share",
                                      style: TextStyle(
                                        fontFamily: 'Chirp',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                        letterSpacing: 0.00,
                                        height: 1.450,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    SvgPicture.asset(
                                      "assets/icons/svgs/share.svg",
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      height: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  children: [
                    PrimaryButton(
                      text: 'Close',
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      backgroundColor: AppColors.purple500,
                      height: 48.00000,
                      textColor: AppColors.neutral0,
                      fontFamily: 'Chirp',
                      letterSpacing: -.70,
                      fontSize: 18,
                      width: double.infinity,
                      fullWidth: true,
                      borderRadius: 40,
                    ),
                    SizedBox(height: 20),

                    InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      onTap: () async {
                        try {
                          await Intercom.instance.displayMessenger();
                        } catch (e) {
                          // Fallback in case Intercom fails
                          if (mounted) {
                            TopSnackbar.show(
                              context,
                              message:
                                  'Unable to open support chat. Please try again later.',
                              isError: true,
                            );
                          }
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Text(
                          'Do you need help?',
                          style: TextStyle(
                            fontFamily: 'Chirp',
                            color: AppColors.purple500ForTheme(context),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -.25,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),
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
        scrolledUnderElevation: .5,
        foregroundColor: Theme.of(context).scaffoldBackgroundColor,
        shadowColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,

        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leadingWidth: 72,
        leading: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap:
              () => {Navigator.pop(context), FocusScope.of(context).unfocus()},
          child: Stack(
            alignment: AlignmentGeometry.center,
            children: [
              SvgPicture.asset(
                "assets/icons/svgs/notificationn.svg",
                height: 40,
                color: Theme.of(context).colorScheme.surface,
              ),
              SizedBox(
                height: 40,
                width: 40,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(
                      Icons.arrow_back_ios,
                      size: 20,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                      // size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // ),

        //  IconButton(
        //   icon: Icon(
        //     Icons.arrow_back_ios,
        //     size: 20,
        //     color: Theme.of(context).colorScheme.onSurface,
        //     // size: 20,
        //   ),
        //   onPressed: () => Navigator.pop(context),
        // ),
        title: Text(
          'Topup Wallet',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontFamily: 'FunnelDisplay',
            fontSize: 24,
            // height: 1.6,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
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
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 24 : 18,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isWide ? 24 : 24,
                      ),
                      child: Text(
                        "How would you like to top up your wallet to start sending across borders?",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Chirp',
                          letterSpacing: -.25,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 36),
                    FutureBuilder<Widget>(
                      future: _buildPaymentMethodCard(sendState),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return ShimmerWidgets.recipientListShimmer(
                            context,
                            itemCount: 6,
                          );
                        }
                        if (snapshot.hasError) {
                          return ErrorStateWidget(
                            message: 'Failed to load payment methods',
                            details: snapshot.error?.toString(),
                            onRetry: () => setState(() {}),
                          );
                        }
                        return snapshot.data ?? SizedBox.shrink();
                      },
                    ),
                    SizedBox(height: 32),
                    // Removed the select funding method button; navigation is now on card tap
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

  // ...existing code...
  Future<Widget> _buildPaymentMethodCard(SendState sendState) async {
    // Read user country from secure storage
    final secureStorage = locator<SecureStorageService>();
    final userJson = await secureStorage.read(StorageKeys.user);
    User? user;
    if (userJson != null && userJson.isNotEmpty) {
      try {
        user = User.fromJson(json.decode(userJson));
      } catch (e) {
        user = null;
      }
    }
    final userCountryName = user?.country ?? 'NG';
    // Try to get the country code from the name
    String userCountryCode = 'NG';
    // Reverse lookup: if userCountryName is a name, get code
    final countryCodes = {
      'Nigeria': 'NG',
      'Ghana': 'GH',
      'Rwanda': 'RW',
      'Kenya': 'KE',
      'Uganda': 'UG',
      'Tanzania': 'TZ',
      'South Africa': 'ZA',
      'Burkina Faso': 'BF',
      'Benin': 'BJ',
      'Botswana': 'BW',
      'Democratic Republic of Congo': 'CD',
      'Republic of Congo': 'CG',
      'Côte d\'Ivoire': 'CI',
      'Cameroon': 'CM',
      'Gabon': 'GA',
      'Malawi': 'MW',
      'Mali': 'ML',
      'Senegal': 'SN',
      'Togo': 'TG',
      'Zambia': 'ZM',
      'United States': 'US',
      'United Kingdom': 'GB',
      'Canada': 'CA',
    };
    if (countryCodes.containsKey(userCountryName)) {
      userCountryCode = countryCodes[userCountryName]!;
    } else if (userCountryName.length == 2) {
      userCountryCode = userCountryName.toUpperCase();
    }

    // Filter deposit channels for user's country
    final depositChannels =
        sendState.channels
            .where(
              (channel) =>
                  channel.rampType == 'deposit' &&
                  channel.status == 'active' &&
                  channel.country?.toUpperCase() == userCountryCode,
            )
            .toList();

    return Column(
      children: [
        // Dayfi Tag (always static)
        _buildPaymentMethodOption(
          icon: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              SvgPicture.asset(
                'assets/icons/svgs/swap.svg',
                height: 40,
                color: Theme.of(context).textTheme.bodyLarge!.color,
              ),
              SvgPicture.asset(
                "assets/icons/svgs/at.svg",
                height: 28,
                color: Theme.of(context).colorScheme.surface,
              ),
            ],
          ),
          title: 'Via Dayfi Tag',
          description:
              'Share your Dayfi Tag with friends and family. Instant transfers. (NGN only)',
          iconColor: Theme.of(context).colorScheme.primary,
          isSelected: false,
          isEnabled: true,
          onTap: () {
            _handleDayfiTagSelection();
          },
        ),
        SizedBox(height: 16),

        // Dynamically render deposit channels for user's country
        ...depositChannels.map((channel) {
          // Choose icon and title based on channel type
          Widget iconWidget = Stack(
            alignment: AlignmentDirectional.center,
            children: [
              SvgPicture.asset(
                'assets/icons/svgs/swap.svg',
                height: 40,
                color: Theme.of(context).textTheme.bodyLarge!.color,
              ),
              SvgPicture.asset(
                channel.channelType == 'bank' ||
                        channel.channelType == 'bank_transfer' ||
                        channel.channelType == 'p2p'
                    ? "assets/icons/svgs/building-bank.svg"
                    : "assets/icons/svgs/currency-dollar.svg",
                height: 28,
                color: Theme.of(context).colorScheme.surface,
              ),
            ],
          );

          String title =
              'Via ${channel.channelType == 'bank' || channel.channelType == 'bank_transfer' ? 'Bank Transfer' : (channel.channelType ?? 'Deposit')}';

          // Description: add NG clause only for Nigeria
          String description =
              'Send up to ${sendState.sendCurrency} 5,000,000.00 via virtual account.';
          if (channel.country == 'NG') {
            description += ' Payer name must match your registered name.';
          }

          return Column(
            children: [
              _buildPaymentMethodOption(
                icon: iconWidget,
                title:
                    channel.channelType == 'p2p'
                        ? "Bank Transfer (P2P)"
                        : title,
                description: description,
                iconColor: AppColors.pink400,
                isSelected: false,
                isEnabled: true,
                onTap: () async {
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
                  if (result == true) {
                    await _processBankTransferPayment();
                  }
                },
              ),
              SizedBox(height: 16),
            ],
          );
        }).toList(),

        // Optionally, add a disabled Digital Dollar card if needed
        Opacity(
          opacity: .4,
          child: _buildPaymentMethodOption(
            icon: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/svgs/swap.svg',
                  height: 40,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
                SvgPicture.asset(
                  "assets/icons/svgs/currency-dollar.svg",
                  height: 28,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ],
            ),
            title: 'Via Digital Dollar',
            description:
                'Pay with a digital dollar wallet via stable coin and wallet address. Cross-border made easy.',
            iconColor: AppColors.success400,
            isSelected: false,
            isEnabled: false,
            onTap: null, // Disabled
          ),
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
        padding: EdgeInsets.only(left: 16, top: 16, bottom: 16, right: 16),
        decoration: BoxDecoration(
          color:
              isEnabled
                  ? Theme.of(context).colorScheme.surface
                  : Theme.of(context).colorScheme.surface.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color:
                  isEnabled
                      ? AppColors.neutral500.withOpacity(0.0375)
                      : AppColors.neutral500.withOpacity(0.02),
              blurRadius: 12,
              offset: const Offset(0, 8),
              spreadRadius: .8,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: icon,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              title,
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(
                                fontFamily: 'Chirp',
                                fontSize: 18,
                                letterSpacing: -.25,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(width: 12),
                            title == "Dayfi Tag"
                                ? Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning400.withOpacity(
                                      0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'FREE',
                                    style: AppTypography.labelSmall.copyWith(
                                      fontFamily: 'Chirp',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: .3,
                                      height: 1.2,
                                      color: AppColors.warning600,
                                    ),
                                  ),
                                )
                                : const SizedBox.shrink(),
                          ],
                        ),
                        SizedBox(height: 4),
                        Opacity(
                          opacity: .7,
                          child: Text(
                            description,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                              fontFamily: 'Chirp',
                              letterSpacing: -.25,
                              fontSize: 14,
                            ),
                          ),
                        ),

                        if (!isEnabled)
                          Align(
                            alignment: AlignmentGeometry.centerRight,
                            child: _buildComingSoonBadge(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 32),
            Icon(Icons.chevron_right, color: AppColors.neutral400, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildComingSoonBadge() {
    return Container(
      margin: EdgeInsets.only(top: 12),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.neutral600,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Coming Soon',
        style: AppTypography.labelSmall.copyWith(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          fontFamily: 'Chirp',
          letterSpacing: -.25,
          height: 1.2,
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
      barrierColor: Colors.black.withOpacity(0.85),
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
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
              height: MediaQuery.of(context).size.height * 0.74,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  SizedBox(height: 18),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(height: 40, width: 40),
                        Text(
                          'Payment Details',
                          style: AppTypography.titleLarge.copyWith(
                            fontFamily: 'FunnelDisplay',
                            fontSize: 20,
                            // height: 1.6,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap:
                              () => {
                                Navigator.pop(context),
                                FocusScope.of(context).unfocus(),
                              },
                          child: Stack(
                            alignment: AlignmentGeometry.center,
                            children: [
                              SvgPicture.asset(
                                "assets/icons/svgs/notificationn.svg",
                                height: 40,
                                color: Theme.of(context).colorScheme.surface,
                              ),
                              SizedBox(
                                height: 40,
                                width: 40,
                                child: Center(
                                  child: Image.asset(
                                    "assets/icons/pngs/cancelicon.png",
                                    height: 20,
                                    width: 20,
                                    color:
                                        Theme.of(
                                          context,
                                        ).textTheme.bodyLarge!.color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Instruction banner
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(12),
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
                                SizedBox(width: 4),
                                Image.asset(
                                  "assets/images/idea.png",
                                  height: 20,
                                  // color: Theme.of(context).colorScheme.primary,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'When paying into this account, ensure the name on the bank account matches your verified name on Dayfi App.',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.copyWith(
                                      fontSize: 14,
                                      fontFamily: 'Chirp',
                                      fontWeight: FontWeight.w500,
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
                          SizedBox(height: 12),

                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 24,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
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
                                SizedBox(height: 8),

                                // Transfer details
                                Text(
                                  'Transfer details:',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleLarge?.copyWith(
                                    fontFamily: 'Chirp',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: -.2,
                                    height: 1.450,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color!
                                        .withOpacity(.75),
                                  ),
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                SizedBox(height: 16),

                                // Amount to send
                                _buildDetailRow(
                                  'Amount to send',
                                  '₦${_formatNumber(collectionData.convertedAmount ?? 0.0)}',
                                  showCopy: true,
                                ),

                                SizedBox(height: 12),

                                // Account number
                                _buildDetailRow(
                                  'Account number',
                                  collectionData.bankInfo?.accountNumber ??
                                      'N/A',
                                  showCopy: true,
                                ),

                                SizedBox(height: 12),
                                _buildDetailRow(
                                  'Account name',
                                  collectionData.bankInfo?.accountName ?? 'N/A',
                                  showCopy: true,
                                ),

                                SizedBox(height: 12),

                                // Bank name
                                _buildDetailRow(
                                  'Bank name',
                                  collectionData.bankInfo?.name ?? 'N/A',
                                ),

                                Divider(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outline.withOpacity(0.2),
                                  height: 56,
                                ),

                                // Expiration warning
                                Row(
                                  children: [
                                    // Icon(
                                    //   Icons.info_outline,
                                    //   color: AppColors.warning600,
                                    //   size: 20,
                                    // ),
                                    // SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'The account details is valid for only this transaction and it expires in ${_formatRemainingTime()} minutes.',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.copyWith(
                                          fontFamily: 'Chirp',
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: -0.4,
                                          fontSize: 14,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 8),
                              ],
                            ),
                          ),

                          SizedBox(height: 18),

                          // Instruction text
                          Text(
                            'Tap the "I have paid" button below after completing your transfer.',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              letterSpacing: -.25,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.95),
                            ),
                          ),

                          SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // Action buttons
                  Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // I have paid button
                        PrimaryButton(
                          text: 'I have paid',
                          onPressed: () {
                            Navigator.pop(context);
                            // Navigate to success screen and clear all previous routes
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoute.sendCollectionSuccessView,
                              (Route route) =>
                                  false, // Remove all previous routes
                              arguments: {
                                'recipientData': widget.recipientData,
                                'selectedData': widget.selectedData,
                                'paymentData': widget.paymentData,
                                'collectionData': _currentPaymentData,
                                'transactionId':
                                    _currentPaymentData?.id ??
                                    _currentPaymentData?.sequenceId,
                              },
                            );
                          },
                          backgroundColor: AppColors.purple500,
                          height: 48.00000,
                          textColor: AppColors.neutral0,
                          fontFamily: 'Chirp',
                          letterSpacing: -.70,
                          fontSize: 18,
                          width: double.infinity,
                          fullWidth: true,
                          borderRadius: 38,
                        ),

                        // SizedBox(height: 12),

                        // Change payment method button
                        // SecondaryButton(
                        //   text: 'Change payment method',
                        //   onPressed: () => Navigator.pop(context),
                        //   backgroundColor: Colors.transparent,
                        //   textColor: AppColors.purple500ForTheme(context),
                        //   borderColor: AppColors.purple500ForTheme(context),
                        //   height: 48.00000,
                        //   borderRadius: 38,
                        //   fontFamily: 'Chirp',
                        //   letterSpacing: -.70,
                        //   fontSize: 18,
                        //   width: double.infinity,
                        //   fullWidth: true,
                        // ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),
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
            letterSpacing: -.25,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontFamily: 'FunnelDisplay',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (showCopy) ...[
              SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  // Add haptic feedback for better UX
                  HapticFeedback.lightImpact();

                  Clipboard.setData(ClipboardData(text: value));
                  TopSnackbar.show(
                    context,
                    message:
                        label == 'Dayfi Tag'
                            ? 'Dayfi Tag copied to clipboard'
                            : 'Account number copied to clipboard',
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

      // Determine if redirectUrl is required for this country/country
      final requiresRedirectUrl = _requiresRedirectUrl(
        selectedChannel,
        sendState.receiverCountry,
      );

      // Add redirectUrl if required for this country
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
            borderRadius: BorderRadius.circular(24),
          ),

          child: Container(
            padding: EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Biometric icon
                Container(
                  width: 64,
                  height: 64,
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
                  //   size: 40,
                  // ),
                  child: SvgPicture.asset('assets/icons/svgs/cautionn.svg'),
                ),

                SizedBox(height: 24),

                // Title
                Text(
                  'Payment Error',
                  style: AppTypography.titleLarge.copyWith(
                    fontFamily: 'FunnelDisplay',
                    fontSize: 18,
                    // height: 1.6,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),

                // SizedBox(height: 16),

                // // Description
                // Text(
                //   message,
                //   style: AppTypography.bodyMedium.copyWith(
                //     fontFamily: 'Chirp',
                //     fontSize: 14,
                //     fontWeight: FontWeight.w500,
                //     color: Theme.of(
                //       context,
                //     ).colorScheme.onSurface.withOpacity(0.7),
                //     height: 1.2,
                //   ),
                //   textAlign: TextAlign.center,
                // ),
                SizedBox(height: 24),

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
                  height: 48.00000,
                  width: double.infinity,
                  fullWidth: true,
                  fontFamily: 'Chirp',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.3,
                ),
                SizedBox(height: 12),

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
                      fontFamily: 'Chirp',
                      fontSize: 16,
                      letterSpacing: -0.3,
                      fontWeight: FontWeight.w500,
                      color: AppColors.neutral400,
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
