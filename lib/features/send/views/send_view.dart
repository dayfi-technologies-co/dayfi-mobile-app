import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/send/vm/send_viewmodel.dart';

class SendView extends ConsumerStatefulWidget {
  const SendView({super.key});

  @override
  ConsumerState<SendView> createState() => _SendViewState();
}

class _SendViewState extends ConsumerState<SendView> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sendViewModelProvider.notifier).initialize();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sendState = ref.watch(sendViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.neutral0,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Send Money',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.neutral900,
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement notifications
            },
            icon: Icon(
              Icons.notifications_outlined,
              color: AppColors.primary500,
              size: 24.sp,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transfer Limit Card
            if (sendState.showUpgradePrompt)
              _buildUpgradeCard(),
            
            SizedBox(height: 16.h),
            
            // You Send Section
            _buildSendSection(sendState),
            
            SizedBox(height: 24.h),
            
            // Transaction Details
            _buildTransactionDetails(sendState),
            
            SizedBox(height: 24.h),
            
            // Receiver Gets Section
            _buildReceiverSection(sendState),
            
            SizedBox(height: 24.h),
            
            // Delivery Method
            _buildDeliveryMethod(sendState),
            
            SizedBox(height: 32.h),
            
            // Continue Button
            _buildContinueButton(sendState),
            
            SizedBox(height: 24.h),
            
            // Partnership Info
            _buildPartnershipInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.neutral0,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.warning200),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppColors.warning100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline,
              color: AppColors.warning600,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Increase transfer limit',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.neutral900,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 4.h),
                RichText(
                  text: TextSpan(
                    text: 'You\'re currently on Tier 1. Submit required documents to access Tier 2 and send higher amounts. ',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.neutral600,
                    ),
                    children: [
                      TextSpan(
                        text: 'Upgrade now.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary500,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendSection(SendState sendState) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.neutral0,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You Send',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.neutral700,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  sendState.sendAmount.isEmpty ? '₦0.00' : '₦${sendState.sendAmount}',
                  style: AppTypography.displaySmall.copyWith(
                    color: sendState.sendAmount.isEmpty ? AppColors.neutral400 : AppColors.neutral900,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              _buildCurrencySelector(
                currency: sendState.sendCurrency,
                onTap: () => _showCurrencyPicker(true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetails(SendState sendState) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        children: [
          _buildTransactionDetailItem(
            icon: Icons.trending_down,
            iconColor: AppColors.success500,
            label: 'Fee',
            value: '₦${sendState.fee}',
          ),
          SizedBox(height: 16.h),
          _buildTransactionDetailItem(
            icon: Icons.account_balance_wallet_outlined,
            iconColor: AppColors.orange500,
            label: 'Total to pay',
            value: '₦${sendState.totalToPay}',
          ),
          SizedBox(height: 16.h),
          _buildTransactionDetailItem(
            icon: Icons.currency_exchange,
            iconColor: AppColors.neutral700,
            label: 'Rate',
            value: sendState.exchangeRate,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetailItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 16.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.neutral700,
            ),
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.neutral900,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildReceiverSection(SendState sendState) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.neutral0,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Receiver Gets',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.neutral700,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  sendState.receiverAmount.isEmpty ? '₦0.00' : '₦${sendState.receiverAmount}',
                  style: AppTypography.displaySmall.copyWith(
                    color: sendState.receiverAmount.isEmpty ? AppColors.neutral400 : AppColors.neutral900,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              _buildCurrencySelector(
                currency: sendState.receiverCurrency,
                onTap: () => _showCurrencyPicker(false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencySelector({
    required String currency,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.neutral100,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.neutral200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currency,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.neutral900,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.neutral600,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryMethod(SendState sendState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DELIVERY METHOD',
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.neutral700,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.neutral0,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.neutral200),
          ),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.success100,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.account_balance,
                  color: AppColors.success600,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bank Account',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.neutral900,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Transfers within minutes',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.neutral400,
                size: 20.sp,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton(SendState sendState) {
    final isEnabled = sendState.sendAmount.isNotEmpty && 
                     double.tryParse(sendState.sendAmount) != null &&
                     double.parse(sendState.sendAmount) > 0;

    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: ElevatedButton(
        onPressed: isEnabled ? () {
          // TODO: Implement continue action
        } : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? AppColors.primary500 : AppColors.neutral300,
          foregroundColor: AppColors.neutral0,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          'Continue',
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.neutral0,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildPartnershipInfo() {
    return Column(
      children: [
        Center(
          child: Text(
            'Swap is powered by Flutterwave in partnership with Kadavra BDC and Wema Bank.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.neutral500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 4.h),
        Center(
          child: Text(
            'Flutterwave Technology Solutions Limited Licensed by the Central Bank of Nigeria.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.neutral500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  void _showCurrencyPicker(bool isSendCurrency) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.neutral0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.neutral300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Select Currency',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.neutral900,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 16.h),
            ...['NGN', 'USD', 'GBP', 'EUR'].map((currency) => 
              ListTile(
                title: Text(
                  currency,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.neutral900,
                  ),
                ),
                onTap: () {
                  ref.read(sendViewModelProvider.notifier).updateCurrency(
                    currency, 
                    isSendCurrency,
                  );
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
