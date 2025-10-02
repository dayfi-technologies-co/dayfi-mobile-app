import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/send/vm/send_viewmodel.dart';

class CountrySelectionBottomSheet extends StatelessWidget {
  final List<CountryOption> countries;
  final String selectedCountryCode;
  final Function(String) onCountrySelected;
  final String title;

  const CountrySelectionBottomSheet({
    super.key,
    required this.countries,
    required this.selectedCountryCode,
    required this.onCountrySelected,
    required this.title,
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
              color: AppColors.neutral300,
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
                    title,
                    textAlign: TextAlign.center,
                    style: AppTypography.titleLarge.copyWith(
                      fontFamily: 'CabinetGrotesk',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral800,
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
          
          // Search bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.neutral200),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search currency here...',
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: AppColors.neutral500,
                    fontSize: 14.sp,
                    fontFamily: 'Karla',
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.neutral500,
                    size: 20.sp,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                ),
              ),
            ),
          ),
          
          SizedBox(height: 20.h),
          
          // Countries list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              itemCount: countries.length,
              itemBuilder: (context, index) {
                final country = countries[index];
                
                return Container(
                  margin: EdgeInsets.only(bottom: 4.h),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        onCountrySelected(country.code);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(8.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 16.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            // Flag - circular container
                            Container(
                              width: 32.w,
                              height: 32.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.neutral200,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  country.flag,
                                  style: TextStyle(fontSize: 18.sp),
                                ),
                              ),
                            ),
                            
                            SizedBox(width: 16.w),
                            
                            // Country name
                            Expanded(
                              child: Text(
                                country.name,
                                style: AppTypography.bodyMedium.copyWith(
                                  fontFamily: 'Karla',
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.neutral800,
                                ),
                              ),
                            ),
                            
                            // Currency code
                            Text(
                              country.currency,
                              style: AppTypography.bodyMedium.copyWith(
                                fontFamily: 'Karla',
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.neutral800,
                              ),
                            ),
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
}
