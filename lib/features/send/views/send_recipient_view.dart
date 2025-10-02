import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/services/remote/payment_service.dart';
import 'package:dayfi/app_locator.dart';

class SendRecipientView extends ConsumerStatefulWidget {
  final Map<String, dynamic> selectedData;

  const SendRecipientView({Key? key, required this.selectedData})
    : super(key: key);

  @override
  ConsumerState<SendRecipientView> createState() => _SendRecipientViewState();
}

class _SendRecipientViewState extends ConsumerState<SendRecipientView> {
  final TextEditingController _accountNumberController =
      TextEditingController();
  bool _isResolving = false;
  String? _resolvedAccountName;
  String? _resolveError;

  @override
  void initState() {
    super.initState();
    _loadSelectedData();
  }

  void _loadSelectedData() {
    print('📋 Selected Data: ${widget.selectedData}');
  }

  Future<void> _resolveAccount() async {
    if (_accountNumberController.text.trim().isEmpty) {
      setState(() {
        _resolveError = 'Please enter an account number';
        _resolvedAccountName = null;
      });
      return;
    }

    setState(() {
      _isResolving = true;
      _resolveError = null;
      _resolvedAccountName = null;
    });

    try {
      final paymentService = locator<PaymentService>();
      final response = await paymentService.resolveBank(
        accountNumber: _accountNumberController.text.trim(),
        networkId: widget.selectedData['networkId'] ?? '',
      );

      if (response.statusCode == 200 && !response.error) {
        // TODO: Extract account name from response data
        setState(() {
          _resolvedAccountName = 'Account Resolved Successfully';
          _resolveError = null;
        });
      } else {
        setState(() {
          _resolveError = response.message;
          _resolvedAccountName = null;
        });
      }
    } catch (e) {
      setState(() {
        _resolveError = 'Error resolving account: $e';
        _resolvedAccountName = null;
      });
    } finally {
      setState(() {
        _isResolving = false;
      });
    }
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.neutral0,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.neutral900,
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Recipient Details',
          style: AppTypography.titleLarge.copyWith(
            fontFamily: 'CabinetGrotesk',
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral900,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transaction Summary
            _buildTransactionSummary(),

            SizedBox(height: 32.h),

            // Account Resolution
            _buildAccountResolutionSection(),

            SizedBox(height: 32.h),

            // Continue Button
            _buildContinueButton(),

            SizedBox(height: 100.h),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionSummary() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.neutral0,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral500.withOpacity(0.1),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaction Summary',
            style: AppTypography.titleMedium.copyWith(
              fontFamily: 'CabinetGrotesk',
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral900,
            ),
          ),

          SizedBox(height: 16.h),

          // Send Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'You send',
                style: AppTypography.bodyLarge.copyWith(
                  fontFamily: 'Karla',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutral600,
                ),
              ),
              Text(
                '${widget.selectedData['sendAmount']} ${widget.selectedData['sendCurrency']}',
                style: AppTypography.bodyLarge.copyWith(
                  fontFamily: 'Karla',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral900,
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Receive Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recipient gets',
                style: AppTypography.bodyLarge.copyWith(
                  fontFamily: 'Karla',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutral600,
                ),
              ),
              Text(
                '${widget.selectedData['receiveAmount']} ${widget.selectedData['receiveCurrency']}',
                style: AppTypography.bodyLarge.copyWith(
                  fontFamily: 'Karla',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral900,
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Delivery Method
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Delivery method',
                style: AppTypography.bodyLarge.copyWith(
                  fontFamily: 'Karla',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutral600,
                ),
              ),
              Text(
                widget.selectedData['recipientDeliveryMethod'] ??
                    'Not selected',
                style: AppTypography.bodyLarge.copyWith(
                  fontFamily: 'Karla',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral900,
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Network
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Network ID',
                style: AppTypography.bodyLarge.copyWith(
                  fontFamily: 'Karla',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutral600,
                ),
              ),
              SizedBox(width: 72.h),
              Expanded(
                child: Text(
                  widget.selectedData['networkId'] ?? 'Not selected',
                  style: AppTypography.bodyLarge.copyWith(
                    fontFamily: 'Karla',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral900,
                    // overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountResolutionSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.neutral0,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral500.withOpacity(0.1),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Resolution',
            style: AppTypography.titleMedium.copyWith(
              fontFamily: 'CabinetGrotesk',
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral900,
            ),
          ),

          SizedBox(height: 20.h),

          // Account Number Input
          _buildTextField(
            controller: _accountNumberController,
            label: widget.selectedData['accountNumberType'] == 'phone'
                ? 'Phone Number'
                : 'Account Number',
            hint: widget.selectedData['accountNumberType'] == 'phone'
                ? 'Enter phone number'
                : 'Enter account number',
            isRequired: true,
            keyboardType: widget.selectedData['accountNumberType'] == 'phone'
                ? TextInputType.phone
                : TextInputType.text,
          ),

          SizedBox(height: 16.h),

          // Resolve Button
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: _isResolving ? null : _resolveAccount,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary600,
                foregroundColor: AppColors.neutral0,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: _isResolving
                  ? SizedBox(
                      height: 20.h,
                      width: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.neutral0,
                        ),
                      ),
                    )
                  : Text(
                      'Resolve Account',
                      style: AppTypography.bodyLarge.copyWith(
                        fontFamily: 'Karla',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral0,
                      ),
                    ),
            ),
          ),

          // Resolution Result
          if (_resolvedAccountName != null || _resolveError != null) ...[
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: _resolveError != null 
                    ? AppColors.error50 
                    : AppColors.success50,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: _resolveError != null 
                      ? AppColors.error200 
                      : AppColors.success200,
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _resolveError != null 
                        ? Icons.error_outline 
                        : Icons.check_circle_outline,
                    color: _resolveError != null 
                        ? AppColors.error600 
                        : AppColors.success600,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      _resolveError ?? _resolvedAccountName!,
                      style: AppTypography.bodyMedium.copyWith(
                        fontFamily: 'Karla',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: _resolveError != null 
                            ? AppColors.error700 
                            : AppColors.success700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isRequired,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: AppTypography.bodyMedium.copyWith(
              fontFamily: 'Karla',
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.neutral700,
            ),
            children: [
              if (isRequired)
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: AppColors.error500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),

        SizedBox(height: 8.h),

        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppTypography.bodyLarge.copyWith(
            fontFamily: 'Karla',
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.neutral900,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyLarge.copyWith(
              fontFamily: 'Karla',
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.neutral400,
            ),
            filled: true,
            fillColor: AppColors.neutral50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.neutral200, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.neutral200, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.primary600, width: 2.0),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    final canContinue = _resolvedAccountName != null && _resolveError == null;
    
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: canContinue ? () {
          // TODO: Proceed to next step with resolved account
          print('🚀 Proceeding with resolved account: ${_accountNumberController.text}');
        } : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canContinue 
              ? AppColors.primary600 
              : AppColors.neutral300,
          foregroundColor: canContinue 
              ? AppColors.neutral0 
              : AppColors.neutral500,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          'Continue',
          style: AppTypography.titleMedium.copyWith(
            fontFamily: 'CabinetGrotesk',
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: canContinue 
                ? AppColors.neutral0 
                : AppColors.neutral500,
          ),
        ),
      ),
    );
  }
}
