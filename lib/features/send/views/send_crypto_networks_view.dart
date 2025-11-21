import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/common/widgets/buttons/buttons.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/services/remote/payment_service.dart';
import 'package:dayfi/services/transaction_monitor_service.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/features/send/vm/send_viewmodel.dart';
import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';
import 'package:dayfi/models/payment_response.dart' as payment;
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/common/utils/error_handler.dart';
import 'package:dayfi/services/local/crashlytics_service.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class SendCryptoNetworksView extends ConsumerStatefulWidget {
  final Map<String, dynamic> selectedChannel;

  const SendCryptoNetworksView({super.key, required this.selectedChannel});

  @override
  ConsumerState<SendCryptoNetworksView> createState() =>
      _SendCryptoNetworksViewState();
}

class _SendCryptoNetworksViewState
    extends ConsumerState<SendCryptoNetworksView> {
  String? _selectedNetwork;
  bool _isLoading = false;
  Timer? _countdownTimer;
  Duration _remainingTime = const Duration(minutes: 30);
  payment.PaymentData? _currentPaymentData;

  Color _getNetworkColor(String networkKey) {
    switch (networkKey.toUpperCase()) {
      case 'ERC20':
        return Colors.blue;
      case 'BSC':
      case 'BNB':
        return Colors.orange;
      case 'POLYGON':
      case 'POL':
        return Colors.purple;
      case 'SOL':
      case 'SOLANA':
        return Colors.cyan;
      case 'CELO':
        return Colors.yellow;
      case 'XLM':
        return Colors.red;
      case 'BASE':
        return Colors.blueAccent;
      case 'TRC20':
      case 'TRON':
        return Colors.orange;
      default:
        return AppColors.success400;
    }
  }

  String? _getNetworkIconPath(String networkKey) {
    switch (networkKey.toUpperCase()) {
      case 'ERC20':
        return 'assets/icons/svgs/ethereum-eth-logo.svg';
      case 'BSC':
      case 'BNB':
        return null; // No icon found
      case 'POLYGON':
      case 'POL':
        return 'assets/icons/pngs/polygon-matic-logo.png';
      case 'SOL':
      case 'SOLANA':
        return 'assets/icons/pngs/solana-sol-logo.png';
      case 'CELO':
        return 'assets/icons/pngs/celo-celo-logo.png';
      case 'XLM':
        return 'assets/icons/svgs/stellar-xlm-logo.svg';
      case 'BASE':
        return null; // No icon found
      case 'TRC20':
      case 'TRON':
        return 'assets/icons/pngs/tron-trx-logo.png';
      default:
        return null;
    }
  }

  bool _isPNGIcon(String networkKey) {
    switch (networkKey.toUpperCase()) {
      case 'POLYGON':
      case 'POL':
      case 'SOL':
      case 'SOLANA':
      case 'CELO':
      case 'TRC20':
      case 'TRON':
        return true;
      default:
        return false;
    }
  }

  Widget _buildNetworkCard(MapEntry<String, dynamic> networkEntry) {
    final networkKey = networkEntry.key;
    final network = networkEntry.value as Map<String, dynamic>;
    final name = network['name'] ?? networkKey;
    final enabled = network['enabled'] ?? false;
    final requiresMemo = network['requiresMemo'] ?? false;
    // final activities = network['activities'] as List? ?? [];
    final isSelected = _selectedNetwork == networkKey;

    return GestureDetector(
      onTap:
          enabled
              ? () {
                setState(() {
                  _selectedNetwork = networkKey;
                });
              }
              : () {
                TopSnackbar.show(
                  context,
                  message: '$name network is not available',
                  isError: false,
                );
              },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color:
                isSelected && enabled
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
            width: .75,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.neutral500.withOpacity(0.0375),
              blurRadius: 8.0,
              offset: const Offset(0, 8),
              spreadRadius: 0.8,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child:
                    _getNetworkIconPath(networkKey) != null
                        ? _isPNGIcon(networkKey)
                            ? Image.asset(
                              _getNetworkIconPath(networkKey)!,
                              width: 32.w,
                              height: 32.w,
                              fit: BoxFit.contain,
                            )
                            : SvgPicture.asset(
                              _getNetworkIconPath(networkKey)!,
                              width: 32.w,
                              height: 32.w,
                              fit: BoxFit.contain,
                              colorFilter: null,
                            )
                        : Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color:
                                enabled
                                    ? _getNetworkColor(
                                      networkKey,
                                    ).withOpacity(0.15)
                                    : AppColors.neutral400.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Center(
                            child: Text(
                              networkKey,
                              style: AppTypography.labelSmall.copyWith(
                                fontFamily: 'Karla',
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w700,
                                color:
                                    enabled
                                        ? _getNetworkColor(networkKey)
                                        : AppColors.neutral600,
                              ),
                            ),
                          ),
                        ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        networkKey,
                        style: AppTypography.titleMedium.copyWith(
                          fontFamily: 'CabinetGrotesk',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color:
                              enabled
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      Text(
                        " ($name)",
                        style: AppTypography.bodySmall.copyWith(
                          fontFamily: 'CabinetGrotesk',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.3,
                          height: 1.5,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),

                      if (requiresMemo) ...[
                        SizedBox(width: 8.w),
                        Container(
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
                                'Memo',
                                style: AppTypography.labelSmall.copyWith(
                                  fontFamily: 'Karla',
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.warning600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),

                  // if (activities.isNotEmpty) ...[
                  //   SizedBox(height: 4.h),
                  //   Wrap(
                  //     spacing: 6.w,
                  //     runSpacing: 4.h,
                  //     children:
                  //         activities.map((activity) {
                  //           return Container(
                  //             padding: EdgeInsets.symmetric(
                  //               horizontal: 8.w,
                  //               vertical: 4.h,
                  //             ),
                  //             decoration: BoxDecoration(
                  //               color: AppColors.purple500ForTheme(context).withOpacity(0.15),
                  //               borderRadius: BorderRadius.circular(8.r),
                  //             ),
                  //             child: Text(
                  //               activity.toString().toUpperCase(),
                  //               style: AppTypography.labelSmall.copyWith(
                  //                 fontFamily: 'Karla',
                  //                 fontSize: 8.sp,
                  //                 fontWeight: FontWeight.w600,
                  //                 color: AppColors.purple500ForTheme(context),
                  //               ),
                  //             ),
                  //           );
                  //         }).toList(),
                  //   ),
                  // ],
                ],
              ),
            ),
            SizedBox(width: 12.w),
            if (isSelected && enabled)
              SvgPicture.asset(
                'assets/icons/svgs/circle-check.svg',
                color: Theme.of(context).colorScheme.primary,
                height: 24.sp,
                width: 24.sp,
              )
            else if (!enabled)
              Text(
                'Unavailable',
                style: AppTypography.labelSmall.copyWith(
                  fontFamily: 'Karla',
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral400,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleContinue() async {
    if (_selectedNetwork == null) {
      TopSnackbar.show(
        context,
        message: 'Please select a network',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get send state and user data
      final sendState = ref.read(sendViewModelProvider);
      final profileState = ref.read(profileViewModelProvider);
      final user = profileState.user;

      // Get the selected network data
      final networks =
          widget.selectedChannel['networks'] as Map<String, dynamic>? ?? {};
      final selectedNetworkData =
          networks[_selectedNetwork] as Map<String, dynamic>? ?? {};

      // Build collection request for crypto funding
      final requestData = _buildCryptoCollectionRequest(
        sendState: sendState,
        user: user,
        selectedNetworkData: selectedNetworkData,
      );

      AppLogger.debug('Crypto collection request: $requestData');

      // Call createCollection API
      final response = await locator<PaymentService>().createCollection(
        requestData,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (!response.error && response.data != null) {
          _currentPaymentData = response.data!;

          // Add transaction to monitoring
          // final collectionSequenceId =
          //     response.data?.id ?? response.data?.sequenceId;
          // if (collectionSequenceId != null) {
          //   final transactionMonitor = ref.read(transactionMonitorProvider);
          //   transactionMonitor.addTransactionToMonitoring(
          //     transactionId: collectionSequenceId,
          //     collectionSequenceId: collectionSequenceId,
          //     paymentData: requestData,
          //   );
          // }

          // Show crypto wallet details bottom sheet
          _showCryptoWalletDetailsBottomSheet(response.data!);
        } else {
          ErrorHandler.showError(
            context,
            response.message.isNotEmpty
                ? response.message
                : 'Failed to create crypto funding request. Please try again.',
          );
        }
      }
    } catch (e, st) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        try {
          await locator<CrashlyticsService>().reportError(e, st);
        } catch (_) {}

        ErrorHandler.showError(
          context,
          'An error occurred while processing your request. Please try again.',
        );
      }
    }
  }

  /// Format date to ISO format (YYYY-MM-DD) for API
  String _formatDateOfBirthToISO(String dateString) {
    if (dateString.isEmpty) return '1990-01-01';

    try {
      // If already in ISO format (YYYY-MM-DD), return as is
      if (dateString.contains('-') && dateString.length == 10) {
        return dateString;
      }

      // If in DD/MM/YYYY format, convert to ISO
      if (dateString.contains('/')) {
        final parts = dateString.split('/');
        if (parts.length == 3) {
          final day = parts[0].padLeft(2, '0');
          final month = parts[1].padLeft(2, '0');
          final year = parts[2];
          return '$year-$month-$day';
        }
      }

      // Try to parse as DateTime and format to ISO
      final date = DateTime.parse(dateString);
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    } catch (e) {
      // If parsing fails, return default
      return '1990-01-01';
    }
  }

  Map<String, dynamic> _buildCryptoCollectionRequest({
    required SendState sendState,
    required dynamic user,
    required Map<String, dynamic> selectedNetworkData,
  }) {
    final cryptoNetwork = _selectedNetwork ?? '';
    final cryptoCurrency = widget.selectedChannel['code'] ?? '';

    // Get crypto channel ID
    final cryptoChannelId =
        widget.selectedChannel['id'] ??
        widget.selectedChannel['channelId'] ??
        cryptoNetwork;

    return {
      "channelId": cryptoChannelId,
      "amount":
          double.tryParse(
            sendState.sendAmount.replaceAll(RegExp(r'[^\d.]'), ''),
          ) ??
          0,
      "currency": sendState.sendCurrency,
      "channelName": widget.selectedChannel['name'] ?? "Digital Dollar",
      "country": "NG",
      "receiveChannel": cryptoChannelId,
      "receiveNetwork": cryptoNetwork,
      "receiveAmount": double.tryParse(
        sendState.receiverAmount.replaceAll(RegExp(r'[^\d.]'), ''),
      ) ?? 0,
      "recipient": {
        "name":
            user != null ? '${user.firstName} ${user.lastName}'.trim() : 'User',
        "phone": user?.phoneNumber ?? '+2340000000000',
        "email": user?.email ?? 'user@example.com',
        "country": user?.country ?? sendState.sendCountry,
        "address": user?.address ?? 'Not provided',
        "dob": _formatDateOfBirthToISO(user?.dateOfBirth ?? '1990-01-01'),
        "idType": user?.idType ?? 'passport',
        "idNumber": user?.idNumber ?? 'A12345678',
      },
      "source": {
        "accountNumber":
            "1111111111",
        "networkId": "995eb625-e23b-4d0b-bd90-18ce44cc17a3",
        "accountType": "bank",
      },

      "metadata": {"customerId": 12345, "orderId": "COLL-17622499732600", "description":"" ,}
    };
  }

  @override
  Widget build(BuildContext context) {
    final channelCode = widget.selectedChannel['code'] ?? 'currency';
    final networks =
        widget.selectedChannel['networks'] as Map<String, dynamic>? ?? {};

    // Filter to show only enabled networks, excluding BASE
    final enabledNetworks =
        networks.entries
            .where(
              (entry) =>
                  entry.value['enabled'] == true &&
                  entry.key.toUpperCase() != 'BASE',
            )
            .toList();

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
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Select Network',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontFamily: 'CabinetGrotesk',
            fontSize: 19.sp,
            // height: 1.6,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Selected currency info
            // Container(
            //   padding: EdgeInsets.all(16.w),
            //   decoration: BoxDecoration(
            //     color: Theme.of(context).colorScheme.surface,
            //     borderRadius: BorderRadius.circular(12.r),
            //     boxShadow: [
            //       BoxShadow(
            //         color: AppColors.neutral500.withOpacity(0.0375),
            //         blurRadius: 8.0,
            //         offset: const Offset(0, 8),
            //         spreadRadius: 0.8,
            //       ),
            //     ],
            //   ),
            //   child: Row(
            //     children: [
            //       Container(
            //         width: 56.w,
            //         height: 56.w,
            //         decoration: BoxDecoration(
            //           color: Theme.of(context).colorScheme.surface,
            //           borderRadius: BorderRadius.circular(8.r),
            //         ),
            //         child: Center(
            //           child: _getCryptoIconPath(channelCode) != null
            //               ? channelCode.toUpperCase() == 'CUSD'
            //                   ? Image.asset(
            //                       _getCryptoIconPath(channelCode)!,
            //                       width: 56.w,
            //                       height: 56.w,
            //                       fit: BoxFit.contain,
            //                     )
            //                   : SvgPicture.asset(
            //                       _getCryptoIconPath(channelCode)!,
            //                       width: 56.w,
            //                       height: 56.w,
            //                       fit: BoxFit.contain,
            //                     )
            //               : Text(
            //                   channelCode,
            //                   style: AppTypography.titleLarge.copyWith(
            //                  fontFamily: 'CabinetGrotesk',
            //                      fontSize: 19.sp, // height: 1.6,
            //                     fontWeight: FontWeight.w700,
            //                     color: AppColors.purple500ForTheme(context),
            //                   ),
            //                 ),
            //         ),
            //       ),
            //       SizedBox(width: 16.w),
            //       Expanded(
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             Text(
            //               channelCode,
            //               style: AppTypography.titleLarge.copyWith(
            //              fontFamily: 'CabinetGrotesk',
            //                 fontSize: 14.sp,
            //                 fontWeight: FontWeight.w600,
            //                 color: Theme.of(context).colorScheme.onSurface,
            //               ),
            //             ),
            //             Text(
            //               channelName,
            //               style: AppTypography.bodySmall.copyWith(
            //                 fontFamily: 'Karla',
            //                 fontSize: 9.sp,
            //                 fontWeight: FontWeight.w400,
            //                 color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            Text(
              'What network do you want to use for $channelCode?',
              style: AppTypography.titleLarge.copyWith(
                fontFamily: 'CabinetGrotesk',
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 32.h),

            if (enabledNetworks.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 56.h),
                  child: Column(
                    children: [
                      Icon(
                        Icons.network_check_outlined,
                        size: 64.sp,
                        color: AppColors.neutral400,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No Networks Available',
                        style: AppTypography.titleLarge.copyWith(
                          fontFamily: 'CabinetGrotesk',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'No networks are currently enabled for this currency',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium.copyWith(
                          fontFamily: 'Karla',
                          fontSize: 14.sp,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...enabledNetworks.map((networkEntry) {
                return _buildNetworkCard(networkEntry);
              }),

            SizedBox(height: 40.h),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: AppColors.neutral500.withOpacity(0.05),
              blurRadius: 20.0,
              offset: const Offset(0, -4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: SafeArea(
          child: PrimaryButton(
            text:
                _isLoading
                    ? 'Processing...'
                    : _selectedNetwork != null
                    ? 'Continue with ${enabledNetworks.firstWhere((e) => e.key == _selectedNetwork).value['name']}'
                    : 'Select a Network',
            onPressed:
                (_selectedNetwork != null && !_isLoading)
                    ? _handleContinue
                    : null,
            isLoading: _isLoading,
            backgroundColor:
                _selectedNetwork != null && !_isLoading
                    ? AppColors.purple500
                    : AppColors.purple500.withOpacity(.25),
            textColor:
                _selectedNetwork != null && !_isLoading
                    ? AppColors.neutral0
                    : AppColors.neutral0.withOpacity(.65),
            height: 48.000.h,
            fontFamily: 'Karla',
            letterSpacing: -.8,
            fontSize: 18,
            width: double.infinity,
            fullWidth: true,
            borderRadius: 40.r,
          ),
        ),
      ),
    );
  }

  void _startCountdownTimer() {
    _remainingTime = const Duration(minutes: 30);
    _countdownTimer?.cancel();
  }

  void _onTimerExpired() {
    if (mounted) {
      Navigator.pop(context);
      TopSnackbar.show(
        context,
        message: 'Payment details have expired. Please create a new request.',
        isError: true,
      );
    }
  }

  String _formatRemainingTime() {
    final minutes = _remainingTime.inMinutes;
    return minutes.toString();
  }

  String _formatNumber(double amount) {
    String formatted = amount.toStringAsFixed(2);
    List<String> parts = formatted.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : '00';

    String formattedInteger = '';
    for (int i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        formattedInteger += ',';
      }
      formattedInteger += integerPart[i];
    }

    return '$formattedInteger.$decimalPart';
  }

  Widget _buildDetailRow(String label, String value, {bool showCopy = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              letterSpacing: -.3,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontFamily: 'CabinetGrotesk',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showCopy) ...[
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Clipboard.setData(ClipboardData(text: value));
                    TopSnackbar.show(context, message: 'Copied to clipboard');
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
        ),
      ],
    );
  }

  void _showCryptoWalletDetailsBottomSheet(payment.PaymentData collectionData) {
    _startCountdownTimer();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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

            final sendState = ref.read(sendViewModelProvider);
            final cryptoCurrency = widget.selectedChannel['code'] ?? '';
            final cryptoNetwork = _selectedNetwork ?? '';
            final networks =
                widget.selectedChannel['networks'] as Map<String, dynamic>? ??
                {};
            final selectedNetworkData =
                networks[_selectedNetwork] as Map<String, dynamic>? ?? {};
            final networkName = selectedNetworkData['name'] ?? cryptoNetwork;

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
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(height: 24.h, width: 22.w),
                        Text(
                          'Crypto Wallet Details',
                          style: AppTypography.titleLarge.copyWith(
                            fontFamily: 'CabinetGrotesk',
                            fontSize: 14.sp,
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
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
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
                                Image.asset(
                                  "assets/images/idea.png",
                                  height: 20.h,
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(
                                    'Send the exact amount to the wallet address below. Ensure you use the correct network (${networkName.toUpperCase()}) to avoid loss of funds.',
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
                                _buildDetailRow(
                                  'Amount to send',
                                  '${sendState.receiverCurrency} ${_formatNumber(collectionData.convertedAmount ?? 0.0)}',
                                  showCopy: true,
                                ),
                                SizedBox(height: 12.h),
                                _buildDetailRow(
                                  'Cryptocurrency',
                                  cryptoCurrency.toUpperCase(),
                                ),
                                SizedBox(height: 12.h),
                                _buildDetailRow(
                                  'Network',
                                  networkName.toUpperCase(),
                                ),
                                SizedBox(height: 12.h),
                                _buildDetailRow(
                                  'Wallet Address',
                                  collectionData.fiatWallet ??
                                      collectionData.reference ??
                                      'Address will be generated',
                                  showCopy: true,
                                ),
                                if (selectedNetworkData['requiresMemo'] ==
                                    true) ...[
                                  SizedBox(height: 12.h),
                                  _buildDetailRow(
                                    'Memo/Tag',
                                    collectionData.reference ??
                                        'Memo will be provided',
                                    showCopy: true,
                                  ),
                                ],
                                Divider(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outline.withOpacity(0.2),
                                  height: 56.h,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'The wallet address is valid for only this transaction and it expires in ${_formatRemainingTime()} minutes.',
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
                          SizedBox(height: 24.h),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(24.w),
                    child: PrimaryButton(
                      text: 'I\'ve Sent the Payment',
                      onPressed: () {
                        Navigator.pop(context);
                        // Navigate to success screen or main view
                        Navigator.pop(context); // Close crypto network view
                      },
                      backgroundColor: AppColors.purple500,
                      height: 48.000.h,
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
      },
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
