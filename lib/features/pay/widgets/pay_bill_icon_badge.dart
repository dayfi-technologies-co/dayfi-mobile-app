import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Branded biller logo or category glyph with scope-style outer ring.
class PayBillIconBadge extends StatelessWidget {
  const PayBillIconBadge({
    super.key,
    required this.innerIconAsset,
    this.brandImageAsset,
    this.innerIconColor,
    this.size = 40,
    this.innerSize = 28,
  });

  final String innerIconAsset;
  final String? brandImageAsset;
  final Color? innerIconColor;
  final double size;
  final double innerSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ringColor = theme.scaffoldBackgroundColor;
    final resolvedInnerIconColor =
        innerIconColor ??
        theme.textTheme.bodyLarge?.color ??
        theme.colorScheme.onSurface;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/svgs/swap.svg',
            width: size,
            height: size,
            colorFilter: ColorFilter.mode(ringColor, BlendMode.srcIn),
          ),
          if (brandImageAsset != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(innerSize / 2),
              child: Image.asset(
                brandImageAsset!,
                width: innerSize,
                height: innerSize,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) =>
                        _innerSvg(context, resolvedInnerIconColor),
              ),
            )
          else
            _innerSvg(context, resolvedInnerIconColor),
        ],
      ),
    );
  }

  Widget _innerSvg(BuildContext context, Color innerIconColor) {
    return SvgPicture.asset(
      innerIconAsset,
      width: innerSize,
      height: innerSize,
      colorFilter: ColorFilter.mode(innerIconColor, BlendMode.srcIn),
    );
  }
}
