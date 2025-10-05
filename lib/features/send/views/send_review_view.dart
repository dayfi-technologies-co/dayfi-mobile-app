import 'package:dayfi/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/features/send/views/send_payment_method_view.dart';
import 'package:dayfi/features/send/vm/send_viewmodel.dart';

class SendReviewView extends ConsumerStatefulWidget {
  final Map<String, dynamic> selectedData;
  final Map<String, dynamic> recipientData;

  const SendReviewView({
    super.key,
    required this.selectedData,
    required this.recipientData,
  });

  @override
  ConsumerState<SendReviewView> createState() => _SendReviewViewState();
}

class _SendReviewViewState extends ConsumerState<SendReviewView> {
  final _descriptionController = TextEditingController();
  final _reasonController = TextEditingController();
  String _selectedReason = '';
  bool _isLoading = false;

  final List<String> _reasons = [
    'Family Support',
    'Education',
    'Medical Expenses',
    'Business Investment',
    'Emergency',
    'Travel',
    'Gift',
    'Rent/Mortgage',
    'Utilities',
    'Food & Groceries',
    'Transportation',
    'Entertainment',
    'Savings',
    'Debt Payment',
    'Insurance',
    'Charity/Donation',
    'Wedding',
    'Funeral',
    'Birthday Celebration',
    'Holiday Expenses',
    'Home Improvement',
    'Technology Purchase',
    'Clothing',
    'Healthcare',
    'Legal Fees',
    'Tax Payment',
    'Investment',
    'Loan Repayment',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(() {
      setState(() {});
    });
    
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
    
    // Update other data if available
    if (widget.selectedData['sendCurrency'] != null) {
      // You might need to add a method to update currency in the viewModel
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sendState = ref.watch(sendViewModelProvider);
    
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
            'Review',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
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
              // Reason Selection
              _buildReasonSelection(),

              SizedBox(height: 32.h),

              // Transfer Details
              _buildTransferDetails(sendState),

              SizedBox(height: 32.h),

              // Description
              _buildDescriptionSection(),

              SizedBox(height: 48.h),

              // Continue Button
              PrimaryButton(
                text: 'Continue',
                onPressed:
                    _selectedReason.isNotEmpty ? _proceedToPayment : null,
                isLoading: _isLoading,
                height: 60.h,
                backgroundColor:
                    _selectedReason.isNotEmpty
                        ? AppColors.purple500
                        : Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.12),
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
              fontFamily: 'CabinetGrotesk',
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 20.h),

          _buildDetailRow(
            'Transfer Amount',
            '${widget.selectedData['sendAmount']} ${widget.selectedData['sendCurrency']}',
          ),
          _buildDetailRow(
            'Total to Recipient',
            '${widget.selectedData['receiveAmount']} ${widget.selectedData['receiveCurrency']}',
          ),
          _buildDetailRow(
            'Exchange Rate',
            sendState.exchangeRate,
          ),
          _buildDetailRow('Transfer Fee', '${sendState.sendCurrency} ${sendState.fee}'),
          _buildDetailRow('Transfer Taxes', '${sendState.sendCurrency} 0.00'),

          Divider(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            height: 24.h,
          ),

          _buildDetailRow(
            'Total',
            '${sendState.sendCurrency} ${sendState.totalToPay}',
            isTotal: true,
          ),

          SizedBox(height: 16.h),

          _buildDetailRow('Recipient', widget.recipientData['name']),
          _buildDetailRow(
            'Delivery Method',
            widget.selectedData['recipientDeliveryMethod'] ?? 'Bank Transfer',
          ),
          _buildDetailRow('Transfer Time', 'Within 24 hours', bottomPadding: 0),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false, double bottomPadding = 8}) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontFamily: 'Karla',
                      letterSpacing: -.3,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontFamily: 'CabinetGrotesk',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
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
            fontFamily: 'CabinetGrotesk',
            fontSize: 18.sp,
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
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.6,
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
                        'Transfer reason',
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
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    itemCount: _reasons.length,
                    itemBuilder: (context, index) {
                      final reason = _reasons[index];
                      final isSelected = _selectedReason == reason;
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(vertical: 4.h),
                        title: Text(
                          reason,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            fontFamily: 'Karla',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        trailing:
                            isSelected
                                ? Icon(
                                  Icons.circle,
                                  color: AppColors.primary600,
                                  size: 10,
                                )
                                : null,
                        onTap: () {
                          setState(() {
                            _selectedReason = reason;
                            _reasonController.text = reason;
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
    setState(() {
      _isLoading = true;
    });

    // Simulate loading
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        final paymentData = {
          ...widget.selectedData,
          ...widget.recipientData,
          'reason': _selectedReason,
          'description': _descriptionController.text.trim(),
        };

        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => SendPaymentMethodView(
                  selectedData: widget.selectedData,
                  recipientData: widget.recipientData,
                  paymentData: paymentData,
                ),
          ),
        );
      }
    });
  }
}
