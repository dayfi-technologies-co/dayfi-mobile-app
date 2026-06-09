import 'package:dayfi/common/utils/dayfi_platform.dart';
import 'package:flutter/material.dart';

/// Caps dialog width on web so mobile-first layouts do not stretch edge-to-edge.
class DayfiWebDialog extends StatelessWidget {
  const DayfiWebDialog({
    super.key,
    required this.child,
    this.maxWidth = 400,
    this.backgroundColor,
    this.shape,
    this.insetPadding,
  });

  final Widget child;
  final double maxWidth;
  final Color? backgroundColor;
  final ShapeBorder? shape;
  final EdgeInsets? insetPadding;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
      shape: shape,
      insetPadding:
          insetPadding ??
          EdgeInsets.symmetric(
            horizontal: isDayfiWeb ? 24 : 40,
            vertical: 24,
          ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isDayfiWeb ? maxWidth : 560,
        ),
        child: child,
      ),
    );
  }
}
