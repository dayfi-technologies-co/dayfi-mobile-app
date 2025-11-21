import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/models/payment_response.dart';
import 'package:flutter_svg/svg.dart';

class DeliveryMethodSelectionBottomSheet extends StatelessWidget {
  final List<Channel> deliveryMethods;
  final String selectedDeliveryMethodId;
  final Function(String) onDeliveryMethodSelected;

  const DeliveryMethodSelectionBottomSheet({
    super.key,
    required this.deliveryMethods,
    required this.selectedDeliveryMethodId,
    required this.onDeliveryMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F6F0), // Light beige background
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.neutral400,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 24.h, 16.w, 20.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Select Delivery Method',
                    textAlign: TextAlign.center,
                    style: AppTypography.titleLarge.copyWith(
                      fontFamily: 'CabinetGrotesk',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: AppColors.neutral600,
                    size: 24.sp,
                  ),
                ),
              ],
            ),
          ),
          
          // Delivery methods list
          Expanded(
            child: deliveryMethods.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 56.sp,
                          color: AppColors.neutral400,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No delivery methods available',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.neutral600,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Please select a different country',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.neutral400,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    itemCount: deliveryMethods.length,
                    itemBuilder: (context, index) {
                      final method = deliveryMethods[index];
                      final isSelected = method.id == selectedDeliveryMethodId;
                      
                      return Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              onDeliveryMethodSelected(method.id ?? '');
                              Navigator.pop(context);
                            },
                            borderRadius: BorderRadius.circular(12.r),
                            child: Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? Theme.of(context).colorScheme.primaryContainer 
                                    : AppColors.neutral0,
                                borderRadius: BorderRadius.circular(12.r),
                                border: isSelected 
                                    ? Border.all(color: AppColors.primary500, width: 1.5)
                                    : Border.all(color: AppColors.neutral200),
                                boxShadow: isSelected ? [
                                  BoxShadow(
                                    color: AppColors.primary500.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ] : [
                                  BoxShadow(
                                    color: AppColors.neutral500.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      // Channel type icon
                                      Container(
                                        padding: EdgeInsets.all(8.w),
                                        decoration: BoxDecoration(
                                          color: isSelected 
                                              ? AppColors.primary100 
                                              : AppColors.neutral100,
                                          borderRadius: BorderRadius.circular(8.r),
                                        ),
                                        child: Icon(
                                          _getChannelTypeIcon(method.channelType),
                                          color: isSelected 
                                              ? AppColors.primary600 
                                              : AppColors.neutral600,
                                          size: 20.sp,
                                        ),
                                      ),
                                      
                                      SizedBox(width: 12.w),
                                      
                                      // Channel type and status
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _getChannelTypeName(method.channelType),
                                              style: AppTypography.bodyMedium.copyWith(
                                                fontFamily: 'Karla',
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w600,
                                                color: isSelected 
                                                    ? AppColors.primary700 
                                                    : Theme.of(context).colorScheme.onSurface,
                                              ),
                                            ),
                                            SizedBox(height: 2.h),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 6.w,
                                                    vertical: 2.h,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: method.status == 'active' 
                                                        ? AppColors.success100 
                                                        : AppColors.error100,
                                                    borderRadius: BorderRadius.circular(4.r),
                                                  ),
                                                  child: Text(
                                                    method.status?.toUpperCase() ?? 'UNKNOWN',
                                                    style: AppTypography.bodySmall.copyWith(
                                                      fontFamily: 'Karla',
                                                      fontSize: 10.sp,
                                                      fontWeight: FontWeight.w600,
                                                      color: method.status == 'active' 
                                                          ? AppColors.success700 
                                                          : AppColors.error700,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 8.w),
                                                Text(
                                                  '•',
                                                  style: TextStyle(
                                                    color: AppColors.neutral400,
                                                    fontSize: 12.sp,
                                                  ),
                                                ),
                                                SizedBox(width: 8.w),
                                                Text(
                                                  method.rampType?.toUpperCase() ?? '',
                                                  style: AppTypography.bodySmall.copyWith(
                                                    fontFamily: 'Karla',
                                                    fontSize: 10.sp,
                                                    color: AppColors.neutral600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // Selection indicator
                                      if (isSelected)

                                      SvgPicture.asset(
                'assets/icons/svgs/circle-check.svg',
                color: AppColors.purple500ForTheme(context),
                height: 24.sp,
                width: 24.sp,
              ),
                                        
                                    ],
                                  ),
                                  
                                  SizedBox(height: 12.h),
                                  
                                  // Additional details
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildDetailItem(
                                          'Min Amount',
                                          '${method.currency} ${method.min?.toStringAsFixed(2) ?? '0.00'}',
                                          isSelected,
                                        ),
                                      ),
                                      SizedBox(width: 16.w),
                                      Expanded(
                                        child: _buildDetailItem(
                                          'Max Amount',
                                          '${method.currency} ${method.max?.toStringAsFixed(2) ?? '∞'}',
                                          isSelected,
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  if (method.feeLocal != null && method.feeLocal! > 0) ...[
                                    SizedBox(height: 8.h),
                                    _buildDetailItem(
                                      'Fee',
                                      '${method.currency} ${method.feeLocal!.toStringAsFixed(2)}',
                                      isSelected,
                                    ),
                                  ],
                                  
                                  if (method.estimatedSettlementTime != null) ...[
                                    SizedBox(height: 8.h),
                                    _buildDetailItem(
                                      'Settlement Time',
                                      '${method.estimatedSettlementTime} minutes',
                                      isSelected,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, bool isSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            fontFamily: 'Karla',
            fontSize: 10.sp,
            color: isSelected 
                ? AppColors.primary600 
                : AppColors.neutral400,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: AppTypography.bodySmall.copyWith(
            fontFamily: 'Karla',
            fontSize: 12.sp,
            color: isSelected 
                ? AppColors.primary700 
                : AppColors.neutral700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  IconData _getChannelTypeIcon(String? channelType) {
    switch (channelType?.toLowerCase()) {
      case 'momo':
        return Icons.phone_android;
      case 'bank':
        return Icons.account_balance;
      case 'p2p':
        return Icons.people;
      case 'eft':
        return Icons.account_balance_wallet;
      case 'spenn':
        return Icons.payment;
      case 'yellowcardpin':
        return Icons.credit_card;
      default:
        return Icons.payment;
    }
  }

  String _getChannelTypeName(String? channelType) {
    switch (channelType?.toLowerCase()) {
      case 'momo':
        return 'Mobile Money';
      case 'bank':
        return 'Bank Account';
      case 'p2p':
        return 'Peer-to-Peer';
      case 'eft':
        return 'Electronic Funds Transfer';
      case 'spenn':
        return 'Spenn';
      case 'yellowcardpin':
        return 'Dayfi PIN';
      default:
        return channelType?.toUpperCase() ?? 'Unknown';
    }
  }
}
