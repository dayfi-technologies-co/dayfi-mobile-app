import 'package:dayfi/common/helpers/image_dominant_color.dart';
import 'package:dayfi/features/pay/widgets/pay_bill_icon_badge.dart';
import 'package:flutter/material.dart';

/// Plain biller logo (no stack ring) — MTN, Airtel, Glo, etc.
class PayBillerBrandIcon extends StatefulWidget {
  const PayBillerBrandIcon({
    super.key,
    required this.brandImageAsset,
    required this.fallbackInnerIconAsset,
    this.size = 36,
  });

  final String? brandImageAsset;
  final String fallbackInnerIconAsset;
  final double size;

  @override
  State<PayBillerBrandIcon> createState() => _PayBillerBrandIconState();
}

class _PayBillerBrandIconState extends State<PayBillerBrandIcon> {
  Color? _borderColor;

  @override
  void initState() {
    super.initState();
    _loadBorderColor();
  }

  @override
  void didUpdateWidget(PayBillerBrandIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.brandImageAsset != widget.brandImageAsset) {
      _loadBorderColor();
    }
  }

  Future<void> _loadBorderColor() async {
    final asset = widget.brandImageAsset;
    if (asset == null) return;

    final color = await dominantColorFromAsset(asset);
    if (!mounted || color == null) return;
    setState(() => _borderColor = color);
  }

  @override
  Widget build(BuildContext context) {
    final asset = widget.brandImageAsset;
    if (asset != null) {
      final borderColor = _borderColor ?? Theme.of(context).colorScheme.outline;
      final imageSize = widget.size - 8;

      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor.withOpacity(0.35), width: 6),
          borderRadius: BorderRadius.circular(32),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Image.asset(
            asset,
            width: imageSize,
            height: imageSize,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _fallbackBadge(context),
          ),
        ),
      );
    }

    return _fallbackBadge(context);
  }

  Widget _fallbackBadge(BuildContext context) {
    return PayBillIconBadge(
      innerIconAsset: widget.fallbackInnerIconAsset,
      size: widget.size,
      innerSize: widget.size * 0.65,
    );
  }
}
