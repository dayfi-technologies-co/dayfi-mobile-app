import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer loading widgets for different components
class ShimmerWidgets {
  // Base shimmer wrapper with theme-aware colors
  static Widget shimmerEffect({
    required Widget child,
    required BuildContext context,
    Color? baseColor,
    Color? highlightColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor:
          baseColor ??
          (isDark
              ? Colors.grey[800]!.withOpacity(.35)
              : Colors.grey[300]!.withOpacity(.35)),
      highlightColor:
          highlightColor ??
          (isDark ? Colors.grey[700]! : Colors.grey[100]!.withOpacity(.35)),
      child: child,
    );
  }

  // Wallet balance shimmer
  static Widget walletBalanceShimmer(BuildContext context) {
    final shimmerColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    return shimmerEffect(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 200.w,
            height: 28.h,
            decoration: BoxDecoration(
              color: shimmerColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ],
      ),
    );
  }

  // Transaction list item shimmer
  static Widget transactionItemShimmer(BuildContext context) {
    final shimmerColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    return shimmerEffect(
      context: context,
      child: Container(
        margin: EdgeInsets.only(bottom: 24.h, top: 12.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Transaction Type Icon placeholder (with circle background)
            SizedBox(
              width: 40.w,
              height: 40.w,
              child: Container(
                decoration: BoxDecoration(
                  color: shimmerColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            // Transaction Info placeholders
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Beneficiary name placeholder
                  Container(
                    width: double.infinity,
                    height: 18.h,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  // Reason placeholder (optional)
                  Container(
                    width: 150.w,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  // Time placeholder
                  Container(
                    width: 80.w,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            // Amount and Status placeholders
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Amount placeholder
                Container(
                  width: 80.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 2.h),
                // Status placeholder
                Container(
                  width: 60.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Transaction list shimmer
  static Widget transactionListShimmer(
    BuildContext context, {
    int itemCount = 5,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: List.generate(
            itemCount,
            (index) => transactionItemShimmer(context),
          ),
        ),
      ),
    );
  }

  // Recipient/Beneficiary item shimmer
  static Widget recipientItemShimmer(BuildContext context) {
    final shimmerColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    return shimmerEffect(
      context: context,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h, top: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            // Avatar with flag placeholder (Stack)
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  margin: EdgeInsets.only(bottom: 4.w, right: 4.w),
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    shape: BoxShape.circle,
                  ),
                ),
                // Flag placeholder
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 8.w),
            // Text placeholders
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name placeholder
                  Container(
                    width: double.infinity,
                    height: 18.h,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  // Account info placeholder (icon + text)
                  Row(
                    children: [
                      // Icon placeholder
                      Container(
                        width: 32.w,
                        height: 32.w,
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      // Text placeholder
                      Expanded(
                        child: Container(
                          height: 12.h,
                          decoration: BoxDecoration(
                            color: shimmerColor,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            // Send button placeholder
            Container(
              width: 68.w,
              height: 32.h,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Recipients list shimmer
  static Widget recipientListShimmer(
    BuildContext context, {
    int itemCount = 5,
    EdgeInsetsGeometry? padding,
  }) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: padding ?? EdgeInsets.only(left: 18.w, right: 18.w, bottom: 112.h),
      itemCount: itemCount,
      itemBuilder: (context, index) => recipientItemShimmer(context),
    );
  }

  // Profile card shimmer
  static Widget profileCardShimmer(BuildContext context) {
    final shimmerColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    return shimmerEffect(
      context: context,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 22.h),
        decoration: BoxDecoration(
          color: shimmerColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: shimmerColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(height: 16.h),
            // Name
            Container(
              width: 150.w,
              height: 20.h,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 8.h),
            // Email
            Container(
              width: 200.w,
              height: 14.h,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Generic card shimmer
  static Widget cardShimmer(
    BuildContext context, {
    double? width,
    double? height,
    double? borderRadius,
  }) {
    final shimmerColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    return shimmerEffect(
      context: context,
      child: Container(
        width: width ?? double.infinity,
        height: height ?? 100.h,
        decoration: BoxDecoration(
          color: shimmerColor,
          borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
        ),
      ),
    );
  }

  // Text shimmer
  static Widget textShimmer(
    BuildContext context, {
    double? width,
    double? height,
    double? borderRadius,
  }) {
    final shimmerColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    return shimmerEffect(
      context: context,
      child: Container(
        width: width ?? 100.w,
        height: height ?? 14.h,
        decoration: BoxDecoration(
          color: shimmerColor,
          borderRadius: BorderRadius.circular(borderRadius ?? 4.r),
        ),
      ),
    );
  }

  // Grid shimmer (for wallet cards, etc.)
  static Widget gridShimmer(
    BuildContext context, {
    int itemCount = 4,
    int crossAxisCount = 2,
    double childAspectRatio = 1.5,
  }) {
    final shimmerColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    return shimmerEffect(
      context: context,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: shimmerColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
          );
        },
      ),
    );
  }

  // Country/Currency selection item shimmer
  static Widget countryItemShimmer(BuildContext context) {
    final shimmerColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    return shimmerEffect(
      context: context,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 13.h),
        child: Row(
          children: [
            // Flag placeholder
            Container(
              width: 38.h,
              height: 38.h,
              decoration: BoxDecoration(
                color: shimmerColor,
                // borderRadius: BorderRadius.circular(4.r),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 12.w),
            // Country name placeholder
            Expanded(
              child: Container(
                height: 38.h,
                decoration: BoxDecoration(
                  color: shimmerColor,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
            SizedBox(width: 18.w),
            // Currency placeholder
            Container(
              width: 48.w,
              height: 38.h,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Country list shimmer
  static Widget countryListShimmer(BuildContext context, {int itemCount = 10}) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: itemCount,
      itemBuilder: (context, index) => countryItemShimmer(context),
    );
  }
}
