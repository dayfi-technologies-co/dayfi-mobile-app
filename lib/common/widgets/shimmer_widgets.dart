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
            width: 200,
            height: 28,
            decoration: BoxDecoration(
              color: shimmerColor,
              borderRadius: BorderRadius.circular(12),
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
        margin: EdgeInsets.only(bottom: 24, top: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Transaction Type Icon placeholder (with circle background)
            SizedBox(
              width: 40,
              height: 40,
              child: Container(
                decoration: BoxDecoration(
                  color: shimmerColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SizedBox(width: 8),
            // Transaction Info placeholders
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Beneficiary name placeholder
                  Container(
                    width: double.infinity,
                    height: 18,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: 4),
                  // Reason placeholder (optional)
                  Container(
                    width: 150,
                    height: 12,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: 4),
                  // Time placeholder
                  Container(
                    width: 80,
                    height: 12,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),
            // Amount and Status placeholders
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Amount placeholder
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 2),
                // Status placeholder
                Container(
                  width: 60,
                  height: 12,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(4),
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
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
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
        margin: EdgeInsets.only(bottom: 8, top: 8),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Avatar with flag placeholder (Stack)
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  margin: EdgeInsets.only(bottom: 4, right: 4),
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    shape: BoxShape.circle,
                  ),
                ),
                // Flag placeholder
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 8),
            // Text placeholders
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name placeholder
                  Container(
                    width: double.infinity,
                    height: 18,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: 4),
                  // Account info placeholder (icon + text)
                  Row(
                    children: [
                      // Icon placeholder
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      SizedBox(width: 2),
                      // Text placeholder
                      Expanded(
                        child: Container(
                          height: 12,
                          decoration: BoxDecoration(
                            color: shimmerColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),
            // Send button placeholder
            Container(
              width: 68,
              height: 32,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(20),
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
      padding: padding ?? EdgeInsets.only(left: 18, right: 18, bottom: 112),
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
        padding: EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          color: shimmerColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: shimmerColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(height: 16),
            // Name
            Container(
              width: 150,
              height: 20,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: 8),
            // Email
            Container(
              width: 200,
              height: 14,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(4),
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
        height: height ?? 100,
        decoration: BoxDecoration(
          color: shimmerColor,
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
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
        width: width ?? 100,
        height: height ?? 14,
        decoration: BoxDecoration(
          color: shimmerColor,
          borderRadius: BorderRadius.circular(borderRadius ?? 4),
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
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: shimmerColor,
              borderRadius: BorderRadius.circular(12),
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
        padding: EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            // Flag placeholder
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: shimmerColor,
                // borderRadius: BorderRadius.circular(4),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 12),
            // Country name placeholder
            Expanded(
              child: Container(
                height: 38,
                decoration: BoxDecoration(
                  color: shimmerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            SizedBox(width: 18),
            // Currency placeholder
            Container(
              width: 48,
              height: 38,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(4),
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
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: itemCount,
      itemBuilder: (context, index) => countryItemShimmer(context),
    );
  }

  // Quick Send chip shimmer (horizontal scrollable list)
  static Widget quickSendChipShimmer(BuildContext context) {
    final shimmerColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    return shimmerEffect(
      context: context,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Container(
          height: 48,
          width: 140,
          decoration: BoxDecoration(
            color: shimmerColor,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // Quick Send list shimmer (horizontal)
  static Widget quickSendListShimmer(BuildContext context, {int itemCount = 5}) {
    return SizedBox(
      height: 72,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12),
        itemCount: itemCount,
        itemBuilder: (context, index) => quickSendChipShimmer(context),
      ),
    );
  }

  // Delivery method card shimmer
  static Widget deliveryMethodCardShimmer(BuildContext context) {
    final shimmerColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    return shimmerEffect(
      context: context,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Icon placeholder
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            SizedBox(width: 12),
            // Text placeholders
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title placeholder
                  Container(
                    width: 150,
                    height: 16,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: 8),
                  // Subtitle placeholder
                  Container(
                    width: 100,
                    height: 12,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            // Arrow placeholder
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Delivery method list shimmer
  static Widget deliveryMethodListShimmer(
    BuildContext context, {
    int itemCount = 4,
    EdgeInsetsGeometry? padding,
  }) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: padding ?? EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      itemCount: itemCount,
      separatorBuilder: (context, index) => SizedBox(height: 12),
      itemBuilder: (context, index) => deliveryMethodCardShimmer(context),
    );
  }
}
