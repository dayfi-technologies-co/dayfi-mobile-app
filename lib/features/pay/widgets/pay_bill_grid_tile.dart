import 'package:dayfi/features/pay/constants/bill_display_labels.dart';
import 'package:dayfi/features/pay/widgets/pay_bill_icon_badge.dart';
import 'package:dayfi/features/pay/widgets/pay_biller_brand_icon.dart';
import 'package:flutter/material.dart';

/// Grid cell for bill categories and billers — scope-style icon, no accent colors.
class PayBillGridTile extends StatelessWidget {
  const PayBillGridTile({
    super.key,
    required this.title,
    required this.innerIconAsset,
    required this.onTap,
    this.brandImageAsset,
    this.subtitle,
    this.plainBillerBrandIcon = false,
  });

  final String title;
  final String? subtitle;
  final String innerIconAsset;
  final String? brandImageAsset;
  final bool plainBillerBrandIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final surface = Theme.of(context).colorScheme.surface;
    final showSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: onSurface.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (plainBillerBrandIcon)
                PayBillerBrandIcon(
                  brandImageAsset: brandImageAsset,
                  fallbackInnerIconAsset: innerIconAsset,
                )
              else
                PayBillIconBadge(
                  innerIconAsset: innerIconAsset,
                  brandImageAsset: brandImageAsset,
                ),
              const Spacer(),
              Text(
                formatBillBillerLabel(title),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Chirp',
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  letterSpacing: -0.25,
                  height: 1.25,
                  color: onSurface,
                ),
              ),
              if (showSubtitle) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Chirp',
                    fontSize: 12.5,
                    height: 1.3,
                    color: onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
