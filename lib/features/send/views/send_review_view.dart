import 'dart:math';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/common/utils/haptic_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/features/send/vm/send_viewmodel.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/services/remote/payment_service.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';
import 'package:dayfi/features/send/vm/transaction_pin_viewmodel.dart';
import 'package:dayfi/models/payment_response.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SendReviewView extends ConsumerStatefulWidget {
  final Map<String, dynamic> selectedData;
  final Map<String, dynamic> recipientData;
  final Map<String, dynamic> senderData;

  const SendReviewView({
    super.key,
    required this.selectedData,
    required this.recipientData,
    required this.senderData,
  });

  @override
  ConsumerState<SendReviewView> createState() => _SendReviewViewState();
}

class _SendReviewViewState extends ConsumerState<SendReviewView>
    with WidgetsBindingObserver {
  final _descriptionController = TextEditingController();
  final _reasonController = TextEditingController();
  String _selectedReason = '';
  final bool _isLoading = false;
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

    // Update viewModel with selected data and ensure networks are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateViewModelWithSelectedData();
      _ensureNetworksLoaded();
      // Refresh profile to get latest PIN status
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

  // Ensure networks are loaded for proper network name resolution
  void _ensureNetworksLoaded() {
    final sendState = ref.read(sendViewModelProvider);
    if (sendState.networks.isEmpty) {
      // print('🔄 Networks not loaded, initializing send view model...');
      ref.read(sendViewModelProvider.notifier).initialize();
    }
  }

  void _updateViewModelWithSelectedData() {
    final sendState = ref.read(sendViewModelProvider.notifier);

    AppLogger.info(
      '🔄 Updating SendViewModel with selectedData from send_review_view',
    );
    AppLogger.info(
      '   Receive Country: ${widget.selectedData['receiveCountry']}',
    );
    AppLogger.info(
      '   Receive Currency: ${widget.selectedData['receiveCurrency']}',
    );
    AppLogger.info(
      '   Recipient Delivery Method: ${widget.selectedData['recipientDeliveryMethod']}',
    );

    // Update send amount if available
    if (widget.selectedData['sendAmount'] != null) {
      sendState.updateSendAmount(widget.selectedData['sendAmount'].toString());
    }

    // Update receive country and currency
    if (widget.selectedData['receiveCountry'] != null &&
        widget.selectedData['receiveCurrency'] != null) {
      sendState.updateReceiveCountry(
        widget.selectedData['receiveCountry'].toString(),
        widget.selectedData['receiveCurrency'].toString(),
      );
    }

    // Update send country and currency
    if (widget.selectedData['sendCountry'] != null &&
        widget.selectedData['sendCurrency'] != null) {
      sendState.updateSendCountry(
        widget.selectedData['sendCountry'].toString(),
        widget.selectedData['sendCurrency'].toString(),
      );
    }

    // Update delivery method - CRITICAL for channel matching
    if (widget.selectedData['recipientDeliveryMethod'] != null) {
      sendState.updateDeliveryMethod(
        widget.selectedData['recipientDeliveryMethod'].toString(),
      );
    }

    // Update sender delivery method if available
    if (widget.selectedData['senderDeliveryMethod'] != null) {
      sendState.updateSenderDeliveryMethod(
        widget.selectedData['senderDeliveryMethod'].toString(),
      );
    }

    AppLogger.info('✅ SendViewModel updated successfully');
  }

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

  // Helper method to get currency symbol from currency code
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
      case 'RWF':
        return 'RWF ';
      case 'GHS':
        return 'GH₵';
      case 'KES':
        return 'KSh ';
      case 'UGX':
        return 'USh ';
      case 'TZS':
        return 'TSh ';
      case 'ZAR':
        return 'R';
      case 'BWP':
        return 'BWP ';
      case 'XOF':
        return 'CFA';
      case 'XAF':
        return 'FCFA';
      default:
        return '$currencyCode ';
    }
  }

  // Helper method to get network name from networkId
  String _getNetworkName(String? networkId) {
    if (networkId == null || networkId.isEmpty) return 'Unknown Network';

    final sendState = ref.watch(sendViewModelProvider);

    // Debug logging
    // print('🔍 Looking for network ID: $networkId');
    // print('📊 Available networks count: ${sendState.networks.length}');
    print(
      '📋 Available network IDs: ${sendState.networks.map((n) => n.id).join(", ")}',
    );

    // If networks are empty, try to trigger a refresh
    if (sendState.networks.isEmpty) {
      // print('⚠️ No networks loaded, triggering refresh...');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(sendViewModelProvider.notifier).initialize();
      });
      return 'Loading...';
    }

    final network = sendState.networks.firstWhere(
      (n) => n.id == networkId,
      orElse: () => Network(id: null, name: null),
    );

    if (network.id == null) {
      // print('❌ Network not found for ID: $networkId');
      return 'Unknown Network';
    }

    // print('✅ Found network: ${network.name} for ID: $networkId');
    return network.name ?? 'Unknown Network';
  }

  // Helper method to get display name for delivery method (convert P2P to Bank Transfer)
  String _getDeliveryMethodDisplay(String? method) {
    if (method == null || method.isEmpty) {
      return 'Bank Transfer';
    }

    final methodLower = method.toLowerCase();

    // Convert P2P to Bank Transfer for display
    if (methodLower == 'p2p' ||
        methodLower == 'peer_to_peer' ||
        methodLower == 'peer-to-peer') {
      return 'Bank Transfer';
    }

    return method;
  }

  // Convert country name to ISO alpha-2 code (best-effort)
  String _countryToCode(String? country) {
    if (country == null) return '';
    final c = country.trim();
    if (c.length == 2) return c.toUpperCase();
    final map = {
      'nigeria': 'NG',
      'south africa': 'ZA',
      'ghana': 'GH',
      'kenya': 'KE',
      'rwanda': 'RW',
      'uganda': 'UG',
      'tanzania': 'TZ',
      'zambia': 'ZM',
    };
    return map[c.toLowerCase()] ?? c;
  }

  // Format phone numbers; for Nigeria add +234 and strip leading zero
  String _formatPhone(String? phone, String countryCode) {
    if (phone == null) return '';
    var p = phone.trim();
    if (p.isEmpty) return '';
    if (p.startsWith('+')) return p;
    if (countryCode.toUpperCase() == 'NG' ||
        countryCode.toLowerCase() == 'nigeria') {
      if (p.startsWith('0')) p = p.substring(1);
      return '+234$p';
    }
    return p;
  }

  // Ensure date is in YYYY-MM-DD format if possible
  String _formatDob(String? dob) {
    if (dob == null) return '';
    try {
      final dt = DateTime.parse(dob);
      return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return dob;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sendState = ref.watch(sendViewModelProvider);

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
                  height: 40.sp,
                  color: Theme.of(context).colorScheme.surface,
                ),
                SizedBox(
                  height: 40.sp,
                  width: 40.sp,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Icon(
                        Icons.arrow_back_ios,
                        size: 20.sp,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                        // size: 20.sp,
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
              fontSize: 24.sp, // height: 1.6,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: Text(
                  "Confirm the details of your transfer before sending",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Karla',
                    letterSpacing: -.6,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 32.h),

              // Reason Selection
              _buildReasonSelection(),

              SizedBox(height: 24.h),

              // Transfer Details
              _buildTransferDetails(sendState),

              // SizedBox(height: 32.h),

              // // Description
              // _buildDescriptionSection(),
              SizedBox(height: 40.h),

              // Continue Button
              PrimaryButton(
                text: 'Confirm Payment',
                onPressed:
                    _selectedReason.isNotEmpty ? _proceedToPayment : null,
                isLoading: _isLoading,
                height: 48.00000.h,
                backgroundColor:
                    _selectedReason.isNotEmpty
                        ? AppColors.purple500
                        : AppColors.purple500.withOpacity(0.12),
                textColor:
                    _selectedReason.isNotEmpty
                        ? AppColors.neutral0
                        : AppColors.neutral0.withOpacity(.35),
                fontFamily: 'Karla',
                letterSpacing: -.70,
                fontSize: 18,
                width: double.infinity,
                fullWidth: true,
                borderRadius: 40.r,
              ),

              SizedBox(height: 36.h),
            ],
          ),
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

  Widget _buildTransferDetails(SendState sendState) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
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
              fontFamily: 'Karla',
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 20.h),

          _buildDetailRow(
            'Transfer Amount',
            '₦${_formatNumber(double.tryParse(widget.selectedData['sendAmount']?.toString() ?? '0') ?? 0)}',
          ),
          _buildDetailRow(
            'Total to Beneficiary ',
            '${_getCurrencySymbol(widget.selectedData['receiveCurrency']?.toString() ?? 'NGN')}${_formatNumber(double.tryParse(widget.selectedData['receiveAmount']?.toString() ?? '0') ?? 0)}',
          ),
          _buildDetailRow('Exchange Rate', sendState.exchangeRate),
          _buildDetailRow(
            'Transfer Fee',
            sendState.receiverCountry.toUpperCase() == 'NG'
                ? '₦${_formatNumber(double.tryParse(sendState.fee.toString()) ?? 0)}'
                : '${_formatNumber(double.tryParse(sendState.fee.toString()) ?? 0)}',
          ),

          // _buildDetailRow('Transfer Taxes', '₦0.00'),
          Divider(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            height: 24.h,
          ),
          SizedBox(height: 12.h),

          _buildDetailRow(
            'Total',
            '₦${_formatNumber(double.tryParse(sendState.totalToPay.toString()) ?? 0)}',
            isTotal: true,
          ),

          _buildDetailRow('Beneficiary ', widget.recipientData['name']),
          SizedBox(height: 6.h),

          // Bank Name for Manual Input
          if (widget.recipientData['bankName'] != null && widget.recipientData['bankName'].toString().isNotEmpty)
            _buildDetailRow('Bank Name', widget.recipientData['bankName']),

          // Account Name for Manual Input
          if (widget.recipientData['accountName'] != null && widget.recipientData['accountName'].toString().isNotEmpty)
            _buildDetailRow('Account Name', widget.recipientData['accountName']),

          // Account Number - show for both bank and mobile money
          _buildDetailRow(
            widget.selectedData['recipientDeliveryMethod'] == 'bank' || widget.selectedData['recipientDeliveryMethod'] == 'eft' ||
                    widget.selectedData['recipientDeliveryMethod'] == 'p2p'
                ? 'Account Number'
                : 'Mobile Money Number',
            widget.recipientData['accountNumber'] ?? 'N/A',
          ),

          // Network/Provider - change title based on delivery method
          _buildDetailRow(
            widget.selectedData['recipientDeliveryMethod'] == 'bank' || widget.selectedData['recipientDeliveryMethod'] == 'eft' ||
                    widget.selectedData['recipientDeliveryMethod'] == 'p2p'
                ? 'Bank'
                : 'Mobile Money Provider',
            _getNetworkName(widget.recipientData['networkId']),
          ),
          _buildDetailRow(
            'Delivery Method',
            _getDeliveryMethodDisplay(
              widget.selectedData['recipientDeliveryMethod']?.toString(),
            ).toUpperCase(),
          ),
          _buildDetailRow(
            'Transfer Time',
            _getTransferTime(
              widget.selectedData['recipientDeliveryMethod']?.toString(),
            ),
            bottomPadding: 0,
          ),
        ],
      ),
    );
  }

  String _getTransferTime(String? deliveryMethod) {
    if (deliveryMethod == null || deliveryMethod.isEmpty) {
      return 'Within 5 minutes';
    }

    final methodLower = deliveryMethod.toLowerCase();

    // Immediate transfer methods
    if (methodLower == 'bank_transfer' ||
        methodLower == 'bank' ||
        methodLower == 'p2p' ||
        methodLower == 'peer_to_peer' ||
        methodLower == 'peer-to-peer' ||
        methodLower == 'eft' ||
        methodLower == 'electronic_funds_transfer') {
      return 'Within 5 minutes';
    }

    // Default for other methods
    return 'Within 5 minutes';
  }

  Widget _getDetailIcon(String label) {
    // Map labels to appropriate SVG icons from send_view.dart
    switch (label.toLowerCase()) {
      case 'transfer amount':
      case 'fee':
        return Transform.rotate(
          angle: -pi / 2,
          child: SvgPicture.asset('assets/icons/svgs/fee.svg', height: 24),
        );
      case 'transfer fee':
        return SvgPicture.asset('assets/icons/svgs/fee.svg', height: 24);
      case 'total':
      case 'total to beneficiary':
        return SvgPicture.asset('assets/icons/svgs/total.svg', height: 24);
      case 'exchange rate':
      case 'rate':
        return SvgPicture.asset('assets/icons/svgs/rate.svg', height: 24);
      case 'network':
      case 'bank network':
      case 'bank':
      case 'mobile money provider':
        return SvgPicture.asset('assets/icons/svgs/bank.svg', height: 0);
      case 'account number':
      case 'mobile money number':
        return SvgPicture.asset('assets/icons/svgs/user1.svg', height: 0);
      case 'beneficiary':
        return SvgPicture.asset('assets/icons/svgs/user1.svg', height: 24);
      case 'delivery method':
        return SvgPicture.asset('assets/icons/svgs/delivery.svg', height: 24);
      case 'transfer time':
        return SvgPicture.asset('assets/icons/svgs/time.svg', height: 24);
      case 'transfer taxes':
        return SvgPicture.asset('assets/icons/svgs/tax.svg', height: 24);
      default:
        // Default icon for other items
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
      padding: EdgeInsets.only(bottom: bottomPadding.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _getDetailIcon(label),
              SizedBox(width: 8.w),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontFamily: 'Karla',
                  letterSpacing: -.6,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontFamily: 'Karla',
                fontSize: 14.sp,
                 letterSpacing: -.6,
                fontWeight: FontWeight.w600,
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
            fontFamily: 'Karla',
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),

        SizedBox(height: 16.h),

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
                      SizedBox(height: 40.h, width: 40.w),
                      Text(
                        'Transfer reason',
                        style: AppTypography.titleLarge.copyWith(
                          fontFamily: 'FunnelDisplay',
                          fontSize: 20.sp,
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
                              height: 40.sp,
                              color: Theme.of(context).colorScheme.surface,
                            ),
                            SizedBox(
                              height: 40.sp,
                              width: 40.sp,
                              child: Center(
                                child: Image.asset(
                                  "assets/icons/pngs/cancelicon.png",
                                  height: 20.h,
                                  width: 20.w,
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
                SizedBox(height: 16.h),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    itemCount: _reasons.length,
                    itemBuilder: (context, index) {
                      final reason = _reasons[index];
                      final isSelected = _selectedReason == reason['name'];
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(vertical: 4.h),
                        leading: Container(
                          padding: EdgeInsets.all(6.r),
                          decoration: BoxDecoration(
                            color: AppColors.neutral0,
                            // borderRadius: BorderRadius.circular(12.r),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            reason['emoji']!,
                            style: TextStyle(fontSize: 24.sp),
                          ),
                        ),
                        title: Text(
                          reason['name']!,
                          style: AppTypography.bodyLarge.copyWith(
                            fontFamily: 'Karla',
                            fontSize: 16.sp,
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
      ...widget.recipientData,
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
              'returnRoute': AppRoute.sendReviewView,
              'returnArguments': {
                'selectedData': widget.selectedData,
                'recipientData': widget.recipientData,
                'senderData': widget.senderData,
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
      final encryptedPin = pin;

      final sendState = ref.read(sendViewModelProvider);
      final paymentService = locator<PaymentService>();

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
      final requestData = await _buildPaymentRequest(
        sendState: sendState,
        selectedChannel: selectedChannel,
        collectionSequenceId: "7e490488-92e4-4de6-a55f-ea0fe17a07150",
        pin: encryptedPin,
      );

      // Call createPaymentRequest API
      final response = await paymentService.createPayment(requestData);

      if (response.error == false && response.data != null) {
        AppLogger.info('Payment request created successfully');

        // Store the payment data
        final paymentData = response.data!;

        // Get transaction ID from response
        final transactionId = paymentData.id ?? paymentData.sequenceId;

        // Close bottom sheet
        Navigator.pop(context);

        // Navigate to success screen
        appRouter.pushNamedAndRemoveUntil(
          AppRoute.sendPaymentSuccessView,
          (Route route) => false, // Remove all previous routes
          arguments: {
            'recipientData': widget.recipientData,
            'selectedData': widget.selectedData,
            'paymentData': _paymentData ?? {},
            'collectionData': paymentData,
            'transactionId': transactionId,
          },
        );
      } else {
        // Check if error is PIN-related or balance-related
        final errorMessage =
            response.message.isNotEmpty
                ? response.message
                : 'Failed to create payment request';

        // Clear PIN if error is PIN-related
        if (errorMessage.toLowerCase().contains('pin') ||
            errorMessage.toLowerCase().contains('incorrect') ||
            errorMessage.toLowerCase().contains('invalid')) {
          ref.read(transactionPinProvider.notifier).resetForm();
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      AppLogger.error('Error creating payment request: $e');

      // Clear PIN on error
      ref.read(transactionPinProvider.notifier).resetForm();

      // Determine error message based on error type
      String userFriendlyMessage;
      final errorString = e.toString().toLowerCase();

      if (errorString.contains('pin') || errorString.contains('incorrect')) {
        userFriendlyMessage = 'Incorrect PIN. Please try again.';
      } else if (errorString.contains('insufficient') ||
          errorString.contains('balance')) {
        userFriendlyMessage =
            'Insufficient wallet balance. Please fund your wallet and try again.';
      } else {
        userFriendlyMessage = 'Failed to initiate transfer. Please try again.';
      }

      // Don't close bottom sheet - let user retry
      // Show error message using TopSnackbar
      TopSnackbar.show(context, message: userFriendlyMessage, isError: true);
    } finally {
      // Reset processing state (this will trigger modal rebuild via ValueNotifier)
      _isProcessingPin = false;
      _isProcessingPinNotifier.value = false;
    }
  }

  /// Find the selected channel based on send state
  dynamic _findSelectedChannel(SendState sendState) {
    AppLogger.info('🔍 Finding selected channel...');
    AppLogger.info('   Receiver Country: ${sendState.receiverCountry}');
    AppLogger.info('   Receiver Currency: ${sendState.receiverCurrency}');
    AppLogger.info(
      '   Selected Delivery Method: ${sendState.selectedDeliveryMethod}',
    );
    AppLogger.info('   Total Channels Available: ${sendState.channels.length}');

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

    AppLogger.info(
      '   Matching Recipient Channels: ${recipientChannels.length}',
    );

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

    AppLogger.info(
      '   Valid Channels (with correct rampType): ${validChannels.length}',
    );

    final selectedChannel =
        validChannels.isNotEmpty
            ? validChannels.first
            : (recipientChannels.isNotEmpty ? recipientChannels.first : null);

    if (selectedChannel != null) {
      AppLogger.info('✅ Selected Channel: ${selectedChannel.id}');
    } else {
      AppLogger.error('❌ No valid channel found!');
    }

    return selectedChannel;
  }

  /// Build payment request
  Future<Map<String, dynamic>> _buildPaymentRequest({
    required SendState sendState,
    required dynamic selectedChannel,
    required String collectionSequenceId,
    required String pin,
  }) async {
    // Determine account type based on recipient data
    final accountType = widget.recipientData['accountType'] ?? 'bank';
    final isCrypto =
        widget.selectedData['cryptoCurrency'] != null ||
        widget.selectedData['cryptoNetwork'] != null;
    final finalAccountType = isCrypto ? 'crypto' : accountType;

    // Get account number (could be bank account or wallet address)
    final accountNumber =
        widget.recipientData['accountNumber'] ??
        widget.recipientData['walletAddress'] ??
        '';

    // Get account name
    final accountName = widget.recipientData['name'] ?? 'Recipient';

    // Get network ID
    final networkId =
        widget.recipientData['networkId'] ??
        widget.selectedData['cryptoNetwork'] ??
        '';

    // Get network country (use receiver country)
    final networkCountry = sendState.receiverCountry;

    // Get country
    final country = sendState.receiverCountry;

    // Get reason
    final reason = _paymentData?['reason'] ?? 'other';

    // Get amount (convert to integer if needed)
    final amount =
        double.tryParse(
          sendState.sendAmount.replaceAll(RegExp(r'[^\d.]'), ''),
        )?.toInt() ??
        0;

    // Get currency
    final currency = sendState.sendCurrency;

    // Get channel ID
    final channelId =
        widget.selectedData['recipientChannelId'] ?? selectedChannel.id ?? '';

    // Build metadata
    final metadata = {
      "orderId": "ORD-${DateTime.now().millisecondsSinceEpoch}",
      "description": _paymentData?['description'] ?? 'Money Transfer',
    };
    // Retrieve stored user data for recipient details
    // final localCache = locator<LocalCache>();
    // final storedUser = await localCache.getUser();

    // final firstName = (storedUser['first_name'] ?? '').toString();
    // final lastName = (storedUser['last_name'] ?? '').toString();
    // final fullName = (('$firstName $lastName').trim());
    // final rawCountry = storedUser['country']?.toString() ?? '';
    // final countryCode = _countryToCode(rawCountry);
    // final phone = _formatPhone(
    //   storedUser['phone_number']?.toString(),
    //   countryCode,
    // );
    // final dob = _formatDob(storedUser['date_of_birth']?.toString());
    // final email =
    //     (storedUser['email'] ?? storedUser['verification_email'] ?? '')
    //         .toString();
    // final idNumber = storedUser['id_number']?.toString() ?? '';
    // final rawIdType = storedUser['id_type']?.toString() ?? '';
    // final idTypeUpper =
    //     rawIdType.isNotEmpty
    //         ? rawIdType.toUpperCase()
    //         : (idNumber.isNotEmpty ? 'NIN' : '');
    // final idTypeForApi = idTypeUpper == 'NIN' ? 'NIN_V2' : idTypeUpper;

    // final recipient = {
    //   'name': fullName,
    //   'country': countryCode,
    //   'phone': phone,
    //   'address': storedUser['address'] ?? '',
    //   'dob': dob,
    //   'email': email,
    //   // include both styles for compatibility
    //   'idNumber': idNumber,
    //   'idType': idTypeUpper,
    //   'id_type': idTypeForApi,
    //   'id_number': idNumber,
    // };

    // final source = {
    //   'accountType': widget.recipientData['accountType'] ?? finalAccountType,
    //   'accountNumber': accountNumber,
    //   'networkId': networkId,
    // };

    // Build payment request payload (including recipient and source)
    final requestData = <String, dynamic>{
      "amount": amount,
      // "collectionSequenceId": collectionSequenceId,
      "currency": currency,
      "channelId": channelId,
      "accountType": finalAccountType,
      "networkCountry": networkCountry,
      "country": country,
      "reason": reason.toString().toLowerCase(),
      "pin": pin,
      "fees": sendState.fee,
      "accountNumber": accountNumber,
      "networkId": networkId,
      "accountName": accountName.toString().replaceAll(',', ""),
      "metadata": metadata,
      // Add bankName and accountName for Manual Input
      if (widget.recipientData['bankName'] != null) "accountBank": widget.recipientData['bankName'],
      if (widget.recipientData['accountName'] != null) "accountName": widget.recipientData['accountName'],
      // "recipient": recipient,
      // "source": source,
    };

    return requestData;
  }
}

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
                SizedBox(height: 40.h, width: 40.w),
                Text(
                  'Enter Transaction PIN',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontFamily: 'FunnelDisplay',
                    fontSize: 20.sp,
                    // height: 1.6,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),

                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    pinNotifier.resetForm();
                    Navigator.pop(context);
                  },
                  child: Stack(
                    alignment: AlignmentGeometry.center,
                    children: [
                      SvgPicture.asset(
                        "assets/icons/svgs/notificationn.svg",
                        height: 40.sp,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      SizedBox(
                        height: 40.sp,
                        width: 40.sp,
                        child: Center(
                          child: Image.asset(
                            "assets/icons/pngs/cancelicon.png",
                            height: 20.h,
                            width: 20.w,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.width * 0.15),

          // PIN dots
          Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      index < pinState.pin.length ? '*' : '*',
                      style: TextStyle(
                        fontSize: 88.sp,
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
                    child: LoadingAnimationWidget.horizontalRotatingDots(
                      color: AppColors.purple100,
                      size: 32.0.w,
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
            size: 20.sp,
          ),
        ),
      ),
    );
  }
}
