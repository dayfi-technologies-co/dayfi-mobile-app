import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/send/vm/transaction_pin_viewmodel.dart';
import 'package:dayfi/services/remote/payment_service.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/services/local/secure_storage.dart';
import 'package:dayfi/common/constants/storage_keys.dart';
import 'package:dayfi/features/send/vm/send_viewmodel.dart';
import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';
import 'package:dayfi/services/transaction_monitor_service.dart';
import 'package:dayfi/routes/route.dart';
import 'dart:async';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:flutter/cupertino.dart';

class RegularTransferTransactionPinView extends ConsumerStatefulWidget {
  final Map<String, dynamic> selectedData;
  final Map<String, dynamic> recipientData;
  final Map<String, dynamic> senderData;
  final Map<String, dynamic> paymentData;
  final String reason;
  final String description;

  const RegularTransferTransactionPinView({
    super.key,
    required this.selectedData,
    required this.recipientData,
    required this.senderData,
    required this.paymentData,
    required this.reason,
    required this.description,
  });

  @override
  ConsumerState<RegularTransferTransactionPinView> createState() =>
      _RegularTransferTransactionPinViewState();
}

class _RegularTransferTransactionPinViewState
    extends ConsumerState<RegularTransferTransactionPinView> {
  final SecureStorageService _secureStorage = locator<SecureStorageService>();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Check if user has transaction pin
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowPinEntry();
    });
  }

  Future<void> _checkAndShowPinEntry() async {
    final profileState = ref.read(profileViewModelProvider);
    final user = profileState.user;
    final hasTransactionPin =
        user?.transactionPin != null && user!.transactionPin!.isNotEmpty;

    if (!hasTransactionPin) {
      // Navigate to create pin with return route info
      appRouter
          .pushNamed(
            AppRoute.transactionPinCreateView,
            arguments: {
              'returnRoute': AppRoute.sendReviewView,
              'returnArguments': {
                'selectedData': widget.selectedData,
                'recipientData': widget.recipientData,
                'senderData': widget.senderData,
              },
            },
          )
          .then((value) {
            // After creating pin, check again and show enter pin
            _checkAndShowPinEntry();
          });
    } else {
      // Show PIN entry bottom sheet
      _showPinEntryBottomSheet();
    }
  }

  void _showPinEntryBottomSheet() {
        showModalBottomSheet(
      barrierColor: Colors.black.withOpacity(0.85),
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder:
          (context) => TransactionPinBottomSheet(
            onPinEntered: _handlePinEntered,
            isProcessing: _isProcessing,
          ),
    );
  }

  Future<void> _handlePinEntered(String pin) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Get user to verify transaction pin exists
      final userJson = await _secureStorage.read(StorageKeys.user);
      if (userJson.isEmpty) {
        throw Exception('User not found');
      }

      // For now, sending plain pin - backend should handle encryption
      final encryptedPin = pin; // TODO: Encrypt with bcrypt if needed

      final sendState = ref.read(sendViewModelProvider);
      final paymentService = locator<PaymentService>();

      // Build collection request similar to send_payment_method_view.dart
      final requestData = _buildCollectionRequest(
        sendState: sendState,
        encryptedPin: encryptedPin,
      );

      // Call createCollection API
      final response = await paymentService.createCollection(requestData);

      if (response.error == false && response.data != null) {
        AppLogger.info('Collection created successfully');

        // Store the payment data
        final collectionData = response.data!;

        // Add transaction to monitoring for automatic payment creation
        final collectionSequenceId =
            collectionData.id ?? collectionData.sequenceId;
        if (collectionSequenceId != null) {
          final transactionMonitor = ref.read(transactionMonitorProvider);

          // Prepare payment data for when status reaches success-collection
          final paymentMonitorData = _buildPaymentMonitoringData(
            sendState: sendState,
          );

          // Add to monitoring
          transactionMonitor.addTransactionToMonitoring(
            transactionId: collectionSequenceId,
            collectionSequenceId: collectionSequenceId,
            paymentData: paymentMonitorData,
          );

          AppLogger.info(
            'Added transaction $collectionSequenceId to monitoring for automatic payment creation',
          );
        }

        // Close bottom sheet
        Navigator.pop(context);

        // Navigate to success screen
        appRouter.pushNamedAndRemoveUntil(
          AppRoute.sendPaymentSuccessView,
          (Route route) => false, // Remove all previous routes
          arguments: {
            'recipientData': widget.recipientData,
            'selectedData': widget.selectedData,
            'paymentData': widget.paymentData,
            'collectionData': collectionData,
            'transactionId': collectionSequenceId,
          },
        );
      } else {
        throw Exception(
          response.message.isNotEmpty
              ? response.message
              : 'Failed to create collection',
        );
      }
    } catch (e) {
      AppLogger.error('Error creating collection: $e');

      // Close bottom sheet if open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      TopSnackbar.show(
        context,
        message: 'Failed to initiate transfer: ${e.toString()}',
        isError: true,
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Map<String, dynamic> _buildCollectionRequest({
    required SendState sendState,
    required String encryptedPin,
  }) {
    // Check if this is a crypto funding request
    final isCrypto =
        widget.selectedData['cryptoCurrency'] != null ||
        widget.selectedData['cryptoNetwork'] != null;

    // Find selected channel
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

    final selectedChannel =
        validChannels.isNotEmpty
            ? validChannels.first
            : (recipientChannels.isNotEmpty ? recipientChannels.first : null);

    final requestData = {
      "amount":
          double.tryParse(
            sendState.sendAmount.replaceAll(RegExp(r'[^\d.]'), ''),
          ) ??
          0,
      "currency": sendState.sendCurrency,
      "channelId": widget.selectedData['senderChannelId'] ?? "",
      "channelName":
          selectedChannel?.channelType ??
          widget.selectedData['recipientDeliveryMethod'] ??
          (isCrypto ? "Digital Dollar" : "Bank Transfer"),
      "country": sendState.sendCountry,
      "reason": widget.reason.isNotEmpty ? widget.reason : "Money Transfer",
      "receiveChannel":
          widget.selectedData['recipientChannelId'] ??
          selectedChannel?.id ??
          "",
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
            widget.selectedData['networkId'] ??
            "",
      },
      "sender": {
        "name":
            widget.senderData['name'] ??
            '${widget.senderData['firstName'] ?? ''} ${widget.senderData['lastName'] ?? ''}'
                .trim(),
        "country": widget.senderData['country'] ?? sendState.sendCountry,
        "phone": widget.senderData['phone'] ?? '+2340000000000',
        "address": widget.senderData['address'] ?? 'Not provided',
        "dob": widget.senderData['dob'] ?? '1990-01-01',
        "email": widget.senderData['email'] ?? 'sender@example.com',
        "idNumber": widget.senderData['idNumber'] ?? 'A12345678',
        "idType": widget.senderData['idType'] ?? 'passport',
      },
      "metadata": {
        "customerId": widget.senderData['userId'] ?? "12345",
        "orderId": "COLL-${DateTime.now().millisecondsSinceEpoch}",
        "description": widget.description.isNotEmpty ? widget.description : "",
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

  Map<String, dynamic> _buildPaymentMonitoringData({
    required SendState sendState,
  }) {
    return {
      "amount":
          double.tryParse(
            sendState.sendAmount.replaceAll(RegExp(r'[^\d.]'), ''),
          ) ??
          0,
      "currency": sendState.sendCurrency,
      "channelId": widget.selectedData['senderChannelId'] ?? "",
      "receiveChannel": widget.selectedData['recipientChannelId'] ?? "",
      "receiveNetwork": widget.recipientData['networkId'] ?? "",
      "receiveAmount":
          double.tryParse(
            widget.selectedData['receiveAmount']?.toString() ?? '0',
          ) ??
          0,
      "recipient": widget.recipientData,
      "sender": widget.senderData,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.transparent, body: Container());
  }
}

class TransactionPinBottomSheet extends ConsumerStatefulWidget {
  final Function(String) onPinEntered;
  final bool isProcessing;

  const TransactionPinBottomSheet({
    super.key,
    required this.onPinEntered,
    required this.isProcessing,
  });

  @override
  ConsumerState<TransactionPinBottomSheet> createState() =>
      _TransactionPinBottomSheetState();
}

class _TransactionPinBottomSheetState
    extends ConsumerState<TransactionPinBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final pinState = ref.watch(transactionPinProvider);
    final pinNotifier = ref.read(transactionPinProvider.notifier);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
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
                  'Enter Transaction PIN',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontFamily: 'FunnelDisplay',
                    fontSize: 16.sp,
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
          SizedBox(height: 32.h),

          // PIN dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              4,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Container(
                  width: 24,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        index < pinState.pin.length
                            ? AppColors.purple500ForTheme(context)
                            : Colors.transparent,
                    border: Border.all(
                      color: AppColors.purple500ForTheme(context),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 40.h),

          // Number pad
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              childAspectRatio: 1.5,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ...List.generate(9, (index) {
                  final number = (index + 1).toString();
                  return _buildNumberButton(number, () {
                    if (pinState.pin.length < 4 && !widget.isProcessing) {
                      final newPin = pinState.pin + number;
                      pinNotifier.updatePin(newPin);
                      if (newPin.length == 4) {
                        Future.delayed(Duration(milliseconds: 300), () {
                          widget.onPinEntered(newPin);
                        });
                      }
                    }
                  });
                }),
                const SizedBox.shrink(),
                _buildNumberButton('0', () {
                  if (pinState.pin.length < 4 && !widget.isProcessing) {
                    final newPin = '${pinState.pin}0';
                    pinNotifier.updatePin(newPin);
                    if (newPin.length == 4) {
                      Future.delayed(Duration(milliseconds: 300), () {
                        widget.onPinEntered(newPin);
                      });
                    }
                  }
                }),
                _buildIconButton(
                  icon: Icons.arrow_back_ios,

                  onTap: () {
                    if (pinState.pin.isNotEmpty && !widget.isProcessing) {
                      pinNotifier.updatePin(
                        pinState.pin.substring(0, pinState.pin.length - 1),
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          if (widget.isProcessing) ...[
            SizedBox(height: 16.h),
            CupertinoActivityIndicator(),
            SizedBox(height: 16.h),
          ],

          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildNumberButton(String number, VoidCallback onTap) {
    return Builder(
      builder:
          (context) => InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            borderRadius: BorderRadius.circular(100),
            onTap: widget.isProcessing ? null : onTap,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Center(
                child: Text(
                  number,
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontFamily: 'FunnelDisplay',
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: widget.isProcessing ? null : onTap,
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: Center(
          child: Icon(icon, color: AppColors.purple500ForTheme(context), size: 20.sp,),
        ),
      ),
    );
  }
}

