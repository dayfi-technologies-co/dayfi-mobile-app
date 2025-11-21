import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/features/send/vm/send_viewmodel.dart';
import 'package:dayfi/common/utils/number_formatter.dart';
import 'package:dayfi/common/utils/string_utils.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'dart:async';
import 'package:dayfi/services/remote/payment_service.dart';
import 'package:dayfi/models/payment_response.dart' as payment;
import 'package:dayfi/models/payment_response.dart' show Network, Channel;
import 'package:dayfi/models/user_model.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/common/utils/phone_country_utils.dart';
import 'package:dayfi/features/send/views/send_payment_success_view.dart';
import 'package:dayfi/services/local/crashlytics_service.dart';
import 'package:dayfi/services/local/local_cache.dart';
import 'package:intercom_flutter/intercom_flutter.dart';

class BankTransferAmountView extends ConsumerStatefulWidget {
  final Map<String, dynamic> selectedData;
  final Map<String, dynamic> recipientData;
  final Map<String, dynamic> senderData;
  final Map<String, dynamic> paymentData;

  const BankTransferAmountView({
    super.key,
    required this.selectedData,
    required this.recipientData,
    required this.senderData,
    required this.paymentData,
  });

  @override
  ConsumerState<BankTransferAmountView> createState() =>
      _BankTransferAmountViewState();
}

class _BankTransferAmountViewState
    extends ConsumerState<BankTransferAmountView> {
  late TextEditingController _amountController;
  final FocusNode _amountFocus = FocusNode();
  String _amountError = '';
  bool _isLoading = false;

  // Payment processing state
  payment.PaymentData? _currentPaymentData;
  Timer? _countdownTimer;
  Duration _remainingTime = const Duration(minutes: 30);

  // Constants
  static const String _targetCountry = 'NG';
  static const String _targetCurrency = 'NGN';
  static const String _targetStatus = 'active';
  static const String _targetRampType = 'deposit';
  static const Set<String> _validChannelTypes = {
    'bank',
    'p2p',
    'bank_transfer',
  };

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _amountController.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  void _validateAmount(String value) {
    setState(() {
      _amountError = '';

      if (value.isEmpty) {
        _amountError = 'Please enter an amount';
        return;
      }

      // Remove commas for validation
      final cleanValue = NumberFormatterUtils.removeCommas(value);
      final amount = double.tryParse(cleanValue);

      if (amount == null || amount <= 0) {
        _amountError = 'Please enter a valid amount';
        return;
      }

      // Check minimum limit (1000 NGN)
      const double minAmount = 1000;
      if (amount < minAmount) {
        _amountError = 'Amount must be at least 1000 NGN';
        return;
      }

      // Check maximum limit (5000000 NGN)
      const double maxAmount = 5000000;
      if (amount > maxAmount) {
        _amountError = 'Amount must be less than 5000000 NGN';
        return;
      }

      // Check minimum limit from viewmodel if available
      final sendState = ref.read(sendViewModelProvider);
      final viewModel = ref.read(sendViewModelProvider.notifier);
      final minLimit = viewModel.sendMinimumLimit;

      if (minLimit != null && amount < minLimit) {
        final minAmountFormatted =
            StringUtils.formatCurrency(
              minLimit.toStringAsFixed(2),
              sendState.sendCurrency,
            ).split('.')[0];
        _amountError = 'Minimum amount is $minAmountFormatted';
        return;
      }
    });
  }

  bool _isAmountValid() {
    if (_amountController.text.isEmpty) return false;

    final cleanValue = NumberFormatterUtils.removeCommas(
      _amountController.text,
    );
    final amount = double.tryParse(cleanValue);

    if (amount == null || amount <= 0) return false;

    // Check minimum limit (1000 NGN)
    const double minAmount = 1000;
    if (amount < minAmount) return false;

    // Check maximum limit (5000000 NGN)
    const double maxAmount = 5000000;
    if (amount > maxAmount) return false;

    final viewModel = ref.read(sendViewModelProvider.notifier);
    final minLimit = viewModel.sendMinimumLimit;

    if (minLimit != null && amount < minLimit) return false;

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final sendState = ref.watch(sendViewModelProvider);
    final isAmountValid = _isAmountValid();

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            "Enter Amount",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
           fontFamily: 'CabinetGrotesk',
               fontSize: 19.sp, height: 1.6,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          centerTitle: true,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 4.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Subtitle
                      Text(
                        "Enter the amount you want to recieve",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Karla',
                          letterSpacing: -.3,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 36.h),

                      // Amount field
                      _buildAmountField(sendState),

                      // Show validation error
                      if (_amountError.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 14),
                          child: Text(
                            _amountError,
                            style: TextStyle(
                              color: AppColors.error400,
                              fontSize: 13.sp,
                              fontFamily: 'Karla',
                              letterSpacing: -.3,
                              fontWeight: FontWeight.w400,
                              height: 1.4,
                            ),
                          ),
                        )
                      else
                        const SizedBox.shrink(),

                      SizedBox(height: 40.h),

                      // Submit Button
                      PrimaryButton(
                        borderRadius: 38,
                        text: "Process Payment",
                        onPressed:
                            isAmountValid && !_isLoading
                                ? () => _handleContinue()
                                : null,
                        backgroundColor:
                            isAmountValid && !_isLoading
                                ? AppColors.purple500
                                : AppColors.purple500.withOpacity(.25),
                        height: 48.000.h,
                        isLoading: _isLoading,
                        textColor:
                            isAmountValid && !_isLoading
                                ? AppColors.neutral0
                                : AppColors.neutral0.withOpacity(.65),
                        fontFamily: 'Karla',
                        letterSpacing: -.8,
                        fontSize: 18,
                        width: double.infinity,
                        fullWidth: true,
                      ),
                      SizedBox(height: 50.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountField(SendState sendState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount',
          style: AppTypography.titleMedium.copyWith(
            fontFamily: 'Karla',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: -.3,
            height: 1.450,
            color: Theme.of(
              context,
            ).textTheme.bodyLarge!.color!.withOpacity(.75),
          ),
          textAlign: TextAlign.start,
        ),
        SizedBox(height: 4),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(color: AppColors.neutral500.withOpacity(0.1)),
            ],
          ),
          child: TextField(
            cursorColor: AppColors.primary600,
            controller: _amountController,
            focusNode: _amountFocus,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [NumberWithCommasFormatter()],
            enableInteractiveSelection: true,
            onChanged: (value) {
              _validateAmount(value);
            },
            style: AppTypography.bodyLarge.copyWith(
              fontFamily: 'Karla',
              fontSize: 27.sp,
              letterSpacing: -.3,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: '0.00',
              hintStyle: AppTypography.bodyLarge.copyWith(
                fontFamily: 'Karla',
                fontSize: 27.sp,
                letterSpacing: -.3,
                fontWeight: FontWeight.w400,
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withOpacity(.25),
              ),
              fillColor: Theme.of(context).colorScheme.surface,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.only(
                right: 16.w,
                top: 16.h,
                bottom: 16.h,
                left: -4.w,
              ),
              prefixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Country flag
                  Text(
                    sendState.sendCurrency,
                    style: AppTypography.bodyMedium.copyWith(
                   fontFamily: 'CabinetGrotesk',
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  SvgPicture.asset(
                    _getFlagPath(sendState.sendCountry),
                    height: 24.0.h,
                  ),
                  SizedBox(width: 12.w),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleContinue() {
    // Update the viewmodel with the amount
    final cleanValue = NumberFormatterUtils.removeCommas(
      _amountController.text,
    );
    ref.read(sendViewModelProvider.notifier).updateSendAmount(cleanValue);

    // Process bank transfer payment
    _processBankTransferPayment();
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
          } else
            fallbackChannel ??= channel;
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

  // Helper function to get flag SVG path from country code
  String _getFlagPath(String? countryCode) {
    switch (countryCode?.toUpperCase()) {
      case 'NG':
        return 'assets/icons/svgs/world_flags/nigeria.svg';
      case 'GH':
        return 'assets/icons/svgs/world_flags/ghana.svg';
      case 'RW':
        return 'assets/icons/svgs/world_flags/rwanda.svg';
      case 'KE':
        return 'assets/icons/svgs/world_flags/kenya.svg';
      case 'UG':
        return 'assets/icons/svgs/world_flags/uganda.svg';
      case 'TZ':
        return 'assets/icons/svgs/world_flags/tanzania.svg';
      case 'ZA':
        return 'assets/icons/svgs/world_flags/south africa.svg';
      case 'BF':
        return 'assets/icons/svgs/world_flags/burkina faso.svg';
      case 'BJ':
        return 'assets/icons/svgs/world_flags/benin.svg';
      case 'BW':
        return 'assets/icons/svgs/world_flags/botswana.svg';
      case 'CD':
        return 'assets/icons/svgs/world_flags/democratic republic of congo.svg';
      case 'CG':
        return 'assets/icons/svgs/world_flags/republic of the congo.svg';
      case 'CI':
        return 'assets/icons/svgs/world_flags/ivory coast.svg';
      case 'CM':
        return 'assets/icons/svgs/world_flags/cameroon.svg';
      case 'GA':
        return 'assets/icons/svgs/world_flags/gabon.svg';
      case 'MW':
        return 'assets/icons/svgs/world_flags/malawi.svg';
      case 'SN':
        return 'assets/icons/svgs/world_flags/senegal.svg';
      case 'TG':
        return 'assets/icons/svgs/world_flags/togo.svg';
      case 'ZM':
        return 'assets/icons/svgs/world_flags/zambia.svg';
      case 'US':
        return 'assets/icons/svgs/world_flags/united states.svg';
      case 'GB':
        return 'assets/icons/svgs/world_flags/united kingdom.svg';
      case 'CA':
        return 'assets/icons/svgs/world_flags/canada.svg';
      default:
        return 'assets/icons/svgs/world_flags/nigeria.svg'; // fallback
    }
  }

  /// Fetch user data asynchronously (for parallel execution)
  Future<User?> _fetchUserData() async {
    try {
      final localCache = locator<LocalCache>();
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
    return formatted.startsWith('+234') ? formatted : '+234$cleanedNumber';
  }

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
        r'No buy rate for currency (\w+)',
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
    return raw;
  }

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
                // Error icon
                Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  child: SvgPicture.asset('assets/icons/svgs/cautionn.svg'),
                ),
                SizedBox(height: 24.h),
                // Title
                Text(
                  'Payment Error',
                  style: AppTypography.titleLarge.copyWith(
                 fontFamily: 'CabinetGrotesk',
                     fontSize: 19.sp, height: 1.6,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                // Retry button
                PrimaryButton(
                  text: 'Retry',
                  onPressed: () {
                    Navigator.of(context).pop();
                    onRetry();
                  },
                  backgroundColor: AppColors.purple500,
                  textColor: AppColors.neutral0,
                  borderRadius: 38,
                  height: 48.000.h,
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
                    "Cancel",
                    style: AppTypography.bodyMedium.copyWith(
                      fontFamily: 'Karla',
                      fontSize: 16.sp,
                      letterSpacing: -0.8,
                      fontWeight: FontWeight.w400,
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
            _onTimerExpired();
          }
        });
      }
    });
  }

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
              height: MediaQuery.of(context).size.height * 0.87,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
              child: Column(
                children: [
                  SizedBox(height: 18.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(height: 24.h, width: 22.w),
                        Text(
                          'Payment Details',
                          style: AppTypography.titleLarge.copyWith(
                         fontFamily: 'CabinetGrotesk',
                            fontSize: 14.sp,
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
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
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
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(width: 4.w),
                                Image.asset(
                                  "assets/images/idea.png",
                                  height: 20.h,
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(
                                    'When paying into this account, ensure the name on the bank account matches your verified name on Dayfi App.',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.copyWith(
                                      fontSize: 14.sp,
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
                                    fontSize: 12.sp,
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
                                  height: 56.h,
                                ),

                                // Expiration warning
                                Row(
                                  children: [
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
                          height: 48.000.h,
                          textColor: AppColors.neutral0,
                          fontFamily: 'Karla',
                          letterSpacing: -.8,
                          fontSize: 18,
                          width: double.infinity,
                          fullWidth: true,
                          borderRadius: 38,
                        ),
                      ],
                    ),
                  ),

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
                            message:
                                'Unable to open support chat. Please try again later.',
                            isError: true,
                          );
                        }
                      }
                    },
                    backgroundColor: Colors.transparent,
                    textColor: AppColors.purple500ForTheme(context),
                    height: 48.000.h,
                    fontFamily: 'Karla',
                    letterSpacing: -.8,
                    fontSize: 18,
                    width: double.infinity,
                    fullWidth: true,
                    borderRadius: 40.r,
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
             fontFamily: 'karla',
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: -.3,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (showCopy) ...[
              SizedBox(width: 8.w),
              Semantics(
                button: true,
                label: 'Copy $label',
                hint: 'Double tap to copy to clipboard',
                child: GestureDetector(
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
              ),
            ],
          ],
        ),
      ],
    );
  }
}
