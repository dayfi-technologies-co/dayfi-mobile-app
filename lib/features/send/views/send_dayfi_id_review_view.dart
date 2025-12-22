import 'dart:math';
import 'package:dayfi/common/utils/haptic_helper.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/services/remote/payment_service.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/features/send/vm/transaction_pin_viewmodel.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';

class SendDayfiIdReviewView extends ConsumerStatefulWidget {
  final Map<String, dynamic> selectedData;
  final String dayfiId;

  const SendDayfiIdReviewView({
    super.key,
    required this.selectedData,
    required this.dayfiId,
  });

  @override
  ConsumerState<SendDayfiIdReviewView> createState() =>
      _SendDayfiIdReviewViewState();
}

class _SendDayfiIdReviewViewState extends ConsumerState<SendDayfiIdReviewView>
    with WidgetsBindingObserver {
  final _descriptionController = TextEditingController();
  final _reasonController = TextEditingController();
  String _selectedReason = '';
  final bool _isLoading = false;
  // ignore: unused_field
  bool _isProcessingPin = false;
  final ValueNotifier<bool> _isProcessingPinNotifier = ValueNotifier<bool>(
    false,
  );
  Map<String, dynamic>? _paymentData;
  bool _hasCheckedPinOnResume = false;

  final List<Map<String, String>> _reasons = [
    {'emoji': '🎁', 'name': 'Gift'},
    {'emoji': '🏠', 'name': 'Housing'},
    {'emoji': '🛒', 'name': 'Groceries'},
    {'emoji': '✈️', 'name': 'Travel'},
    {'emoji': '🏥', 'name': 'Health'},
    {'emoji': '🎬', 'name': 'Entertainment'},
    {'emoji': '🏫', 'name': 'School Fees'},
    {'emoji': '💡', 'name': 'Bills'},
    {'emoji': '❓', 'name': 'Other'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _descriptionController.addListener(() {
      setState(() {});
    });

    // Refresh profile to get latest PIN status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileViewModelProvider.notifier).loadUserProfile();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _descriptionController.dispose();
    _reasonController.dispose();
    _isProcessingPinNotifier.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _hasCheckedPinOnResume) {
      // Refresh profile when app resumes and we've already checked PIN
      _refreshProfileAndCheckPin();
    }
  }

  Future<void> _refreshProfileAndCheckPin() async {
    await ref.read(profileViewModelProvider.notifier).loadUserProfile();
    final profileState = ref.read(profileViewModelProvider);
    final user = profileState.user;
    final hasTransactionPin =
        user?.transactionPin != null && user!.transactionPin!.isNotEmpty;

    if (hasTransactionPin &&
        _paymentData != null &&
        _selectedReason.isNotEmpty) {
      // User just created PIN, show entry bottom sheet
      _hasCheckedPinOnResume = false; // Reset flag
      _showPinEntryBottomSheet();
    }
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

  String _getCurrencySymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'NGN':
        return '₦';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return '$currencyCode ';
    }
  }

  void _proceedToPayment() {
    if (_selectedReason.isEmpty) {
      TopSnackbar.show(
        context,
        message: 'Please select a reason for transfer',
        isError: true,
      );
      return;
    }

    _paymentData = {
      ...widget.selectedData,
      'dayfiId': widget.dayfiId,
      'reason': _selectedReason,
      'description': _descriptionController.text.trim(),
    };

    // Set flag to check PIN on resume
    _hasCheckedPinOnResume = true;

    // Check and handle transaction PIN
    _checkAndHandleTransactionPin();
  }

  /// Check if user has transaction PIN and handle accordingly
  Future<void> _checkAndHandleTransactionPin() async {
    // Refresh profile first to get latest PIN status
    await ref.read(profileViewModelProvider.notifier).loadUserProfile();

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
              'returnRoute': AppRoute.sendDayfiIdReviewView,
              'returnArguments': {
                'selectedData': widget.selectedData,
                'dayfiId': widget.dayfiId,
              },
            },
          )
          .then((_) async {
            // When user returns from PIN creation, refresh profile and check again
            await ref.read(profileViewModelProvider.notifier).loadUserProfile();
            final updatedProfileState = ref.read(profileViewModelProvider);
            final updatedUser = updatedProfileState.user;
            final nowHasPin =
                updatedUser?.transactionPin != null &&
                updatedUser!.transactionPin!.isNotEmpty;

            if (nowHasPin &&
                _paymentData != null &&
                _selectedReason.isNotEmpty) {
              // Show PIN entry bottom sheet
              _hasCheckedPinOnResume = false; // Reset flag
              _showPinEntryBottomSheet();
            }
          });
    } else {
      // Show PIN entry bottom sheet
      _hasCheckedPinOnResume = false; // Reset flag
      _showPinEntryBottomSheet();
    }
  }

  /// Show PIN entry bottom sheet
  void _showPinEntryBottomSheet() {
    // Reset PIN state before showing bottom sheet
    ref.read(transactionPinProvider.notifier).resetForm();
    // Reset processing state
    _isProcessingPinNotifier.value = false;

    showModalBottomSheet(
      barrierColor: Colors.black.withOpacity(0.85),
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder:
          (bottomSheetContext) => ValueListenableBuilder<bool>(
            valueListenable: _isProcessingPinNotifier,
            builder: (context, isProcessing, child) {
              return TransactionPinBottomSheet(
                onPinEntered: _handlePinEntered,
                isProcessing: isProcessing,
              );
            },
          ),
    );
  }

  /// Handle PIN entry and process payment
  Future<void> _handlePinEntered(String pin) async {
    // Update processing state (this will trigger modal rebuild via ValueNotifier)
    _isProcessingPin = true;
    _isProcessingPinNotifier.value = true;

    try {
      // For now, sending plain pin - backend should handle encryption
      final encryptedPin = pin; // TODO: Encrypt with bcrypt if needed

      final paymentService = locator<PaymentService>();
      final amount =
          double.tryParse(
            widget.selectedData['sendAmount']?.toString() ?? '0',
          ) ??
          0;

      // Call initiateWalletTransfer API
      final response = await paymentService.initiateWalletTransfer(
        dayfiId: widget.dayfiId,
        amount: amount.toInt(),
        encryptedPin: encryptedPin,
      );

      if (response.error == false) {
        AppLogger.info('Wallet transfer initiated successfully');

        // Close bottom sheet
        Navigator.pop(context);

        // Navigate to success screen
        appRouter.pushNamedAndRemoveUntil(
          AppRoute.sendPaymentSuccessView,
          (Route route) => false, // Remove all previous routes
          arguments: {
            'recipientData': {'name': '@${widget.dayfiId}'},
            'selectedData': widget.selectedData,
            'paymentData': _paymentData ?? {},
            'transactionId':
                response.data?.id?.toString() ??
                response.data?.sequenceId?.toString(),
          },
        );
      } else {
        // Check if error is PIN-related
        final errorMessage =
            response.message.isNotEmpty
                ? response.message
                : 'Failed to initiate transfer';

        // Clear PIN if error is PIN-related
        if (errorMessage.toLowerCase().contains('pin') ||
            errorMessage.toLowerCase().contains('incorrect') ||
            errorMessage.toLowerCase().contains('invalid')) {
          ref.read(transactionPinProvider.notifier).resetForm();
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      AppLogger.error('Error initiating wallet transfer: $e');

      // Clear PIN on error
      ref.read(transactionPinProvider.notifier).resetForm();

      // Determine user-friendly message based on error
      String userFriendlyMessage;
      final errorString = e.toString().toLowerCase();

      if (errorString.contains('pin') || errorString.contains('incorrect')) {
        userFriendlyMessage = 'Incorrect PIN. Please try again.';
      } else if (errorString.contains('insufficient') ||
          errorString.contains('balance')) {
        userFriendlyMessage =
            'Insufficient wallet balance. Please fund your wallet and try again.';
      } else {
        // Prefer backend-provided message when available
        userFriendlyMessage =
            e.toString().isNotEmpty
                ? e.toString()
                : 'Failed to initiate transfer. Please try again.';
      }

      // Show error as a top snackbar (keeps bottom sheet open for retry)
      TopSnackbar.show(context, message: userFriendlyMessage, isError: true);
    } finally {
      // Reset processing state (this will trigger modal rebuild via ValueNotifier)
      _isProcessingPin = false;
      _isProcessingPinNotifier.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sendAmount =
        double.tryParse(widget.selectedData['sendAmount']?.toString() ?? '0') ??
        0;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
          automaticallyImplyLeading: false,
          title: Text(
            'Review Transfer',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontFamily: 'FunnelDisplay',
              fontSize: 20, // height: 1.6,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          centerTitle: true,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth > 600;
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
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
                          horizontal: isWide ? 24 : 18,
                        ),
                        child: Text(
                          "Confirm the details of your transfer before sending",
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
                      SizedBox(height: 32),

                      // Reason Selection
                      _buildReasonSelection(),

                      SizedBox(height: 24),

                      // Transfer Details
                      _buildTransferDetails(sendAmount),

                      SizedBox(height: 32),

                      // Continue Button
                      PrimaryButton(
                        text: 'Confirm Payment',
                        onPressed:
                            _selectedReason.isNotEmpty
                                ? _proceedToPayment
                                : null,
                        isLoading: _isLoading,
                        height: 48.00000,
                        backgroundColor:
                            _selectedReason.isNotEmpty
                                ? AppColors.purple500
                                : AppColors.purple500.withOpacity(0.12),
                        textColor:
                            _selectedReason.isNotEmpty
                                ? AppColors.neutral0
                                : AppColors.neutral0.withOpacity(.20),
                        fontFamily: 'Chirp',
                        letterSpacing: -.70,
                        fontSize: 18,
                        width: double.infinity,
                        fullWidth: true,
                        borderRadius: 40,
                      ),

                      SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildReasonSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: 'Reason for transfer',
          hintText: 'Select reason for transfer',
          controller: _reasonController,
          onTap: _showReasonBottomSheet,
          shouldReadOnly: true,
          suffixIcon: Icon(
            Icons.keyboard_arrow_down,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildTransferDetails(double sendAmount) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transfer Details',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontFamily: 'Chirp',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 20),

          _buildDetailRow('Transfer Amount', '₦${_formatNumber(sendAmount)}'),
          _buildDetailRow('Recipient', '@${widget.dayfiId}'),
          _buildDetailRow('Delivery Method', 'Dayfi Tag Transfer'),
          Divider(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            height: 24,
          ),
          _buildDetailRow(
            'Total',
            '₦${_formatNumber(sendAmount)}',
            isTotal: true,
          ),
          _buildDetailRow('Transfer Time', 'Instant', bottomPadding: 0),
        ],
      ),
    );
  }

  Widget _getDetailIcon(String label) {
    switch (label.toLowerCase()) {
      case 'transfer amount':
        return Transform.rotate(
          angle: -pi / 2,
          child: SvgPicture.asset('assets/icons/svgs/fee.svg', height: 24),
        );
      case 'recipient':
        return Padding(
          padding: EdgeInsetsGeometry.all(1),
          child: Image.asset("assets/icons/pngs/account_4.png", height: 22),
        );
      case 'delivery method':
        return SvgPicture.asset('assets/icons/svgs/delivery.svg', height: 24);
      case 'transfer time':
        return SvgPicture.asset('assets/icons/svgs/time.svg', height: 24);
      default:
        return SvgPicture.asset('assets/icons/svgs/fee.svg', height: 24);
    }
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isTotal = false,
    double bottomPadding = 12,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _getDetailIcon(label),
              SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontFamily: 'Chirp',
                  letterSpacing: -.25,
                  fontSize: 14,
                  fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontFamily: 'Chirp',
                fontSize: isTotal ? 16 : 13,
                fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Information (Optional)',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontFamily: 'Chirp',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),

        SizedBox(height: 16),

        CustomTextField(
          controller: _descriptionController,
          label: 'Description',
          hintText: 'Add any additional info about this transfer...',
          minLines: 2,
        ),
      ],
    );
  }

  void _showReasonBottomSheet() {
    showModalBottomSheet(
      barrierColor: Colors.black.withOpacity(0.85),
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.92,

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
                        'Transfer reason',
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
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    itemCount: _reasons.length,
                    itemBuilder: (context, index) {
                      final reason = _reasons[index];
                      final isSelected = _selectedReason == reason['name'];
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(vertical: 4),
                        leading: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.neutral0,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            reason['emoji']!,
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                        title: Text(
                          reason['name']!,
                          style: AppTypography.bodyLarge.copyWith(
                            fontFamily: 'Chirp',
                            fontSize: 16,
                            letterSpacing: -.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing:
                            isSelected
                                ? SvgPicture.asset(
                                  'assets/icons/svgs/circle-check.svg',
                                  color: AppColors.purple500ForTheme(context),
                                )
                                : null,
                        onTap: () {
                          setState(() {
                            _selectedReason = reason['name']!;
                            _reasonController.text = reason['name']!;
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }
}

// Transaction PIN Bottom Sheet Widget
// Transaction PIN Bottom Sheet Widget
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
  void initState() {
    super.initState();
    // Reset PIN when bottom sheet opens (clean slate)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transactionPinProvider.notifier).resetForm();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pinState = ref.watch(transactionPinProvider);
    final pinNotifier = ref.read(transactionPinProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 600;
        return Align(
          alignment: isWide ? Alignment.center : Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isWide ? 500 : double.infinity,
            ),
            child: Container(
              height:
                  isWide
                      ? MediaQuery.of(context).size.height * 0.50
                      : MediaQuery.of(context).size.height * 0.74,

              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius:
                    isWide
                        ? BorderRadius.circular(20)
                        : BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  SizedBox(height: 18),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: isWide ? 24 : 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(height: 24, width: 22),
                        Text(
                          'Enter Transaction PIN',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
                            fontFamily: 'Chirp',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            pinNotifier.resetForm();
                            Navigator.pop(context);
                          },
                          child: Image.asset(
                            "assets/icons/pngs/cancelicon.png",
                            height: 24,
                            width: 24,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height:
                        isWide ? 60 : MediaQuery.of(context).size.width * 0.15,
                  ),

                  // PIN dots
                  Stack(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          4,
                          (index) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                            ),
                            child: Text(
                              index < pinState.pin.length ? '*' : '*',
                              style: TextStyle(
                                fontSize: 60,
                                letterSpacing: -25,
                                fontFamily: 'FunnelDisplay',
                                fontWeight: FontWeight.w700,
                                color:
                                    index < pinState.pin.length
                                        ? AppColors.purple500ForTheme(context)
                                        : AppColors.neutral300,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // SizedBox(height: MediaQuery.of(context).size.width * 0.075),

                      // Loading indicator section
                      if (widget.isProcessing)
                        Positioned(
                          top: 50,
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Center(
                            child:
                                LoadingAnimationWidget.horizontalRotatingDots(
                                  color: AppColors.purple100,
                                  size: 32.0,
                                ),
                          ),
                        ),
                    ],
                  ),

                  // Number pad - disabled when processing
                  Expanded(
                    child: Stack(
                      children: [
                        GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          childAspectRatio: 1.5,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          padding: EdgeInsets.symmetric(
                            horizontal: isWide ? 24 : 18,
                          ),
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            ...List.generate(9, (index) {
                              final number = (index + 1).toString();
                              return _buildNumberButton(number, () {
                                if (pinState.pin.length < 4 &&
                                    !widget.isProcessing) {
                                  final newPin = pinState.pin + number;
                                  pinNotifier.updatePin(newPin);
                                  if (newPin.length == 4) {
                                    Future.delayed(
                                      Duration(milliseconds: 300),
                                      () {
                                        widget.onPinEntered(newPin);
                                      },
                                    );
                                  }
                                }
                              });
                            }),
                            const SizedBox.shrink(),
                            _buildNumberButton('0', () {
                              if (pinState.pin.length < 4 &&
                                  !widget.isProcessing) {
                                final newPin = '${pinState.pin}0';
                                pinNotifier.updatePin(newPin);
                                if (newPin.length == 4) {
                                  Future.delayed(
                                    Duration(milliseconds: 300),
                                    () {
                                      widget.onPinEntered(newPin);
                                    },
                                  );
                                }
                              }
                            }),
                            _buildIconButton(
                              icon: Icons.arrow_back_ios,

                              onTap: () {
                                if (pinState.pin.isNotEmpty &&
                                    !widget.isProcessing) {
                                  pinNotifier.updatePin(
                                    pinState.pin.substring(
                                      0,
                                      pinState.pin.length - 1,
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        // Overlay when processing
                        if (widget.isProcessing)
                          Container(
                            color: Theme.of(
                              context,
                            ).scaffoldBackgroundColor.withOpacity(0.7),
                          ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNumberButton(String number, VoidCallback onTap) {
    return Builder(
      builder:
          (context) => InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            borderRadius: BorderRadius.circular(100),
            onTap:
                widget.isProcessing
                    ? null
                    : () {
                      HapticHelper.lightImpact();
                      onTap();
                    },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Center(
                child: Text(
                  number,
                  style: TextStyle(
                    fontSize: 24,
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
      onTap:
          widget.isProcessing
              ? null
              : () {
                HapticHelper.lightImpact();
                onTap();
              },
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: Center(
          child: Icon(
            icon,
            color: AppColors.purple500ForTheme(context),
            size: 20,
          ),
        ),
      ),
    );
  }
}
