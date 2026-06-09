import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Branded filled circle check — use instead of [Icons.check_circle] / [Icons.check].
class DayfiCircleCheckIcon extends StatelessWidget {
  const DayfiCircleCheckIcon({
    super.key,
    this.size = 24,
    this.color,
  });

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/svgs/circle-check.svg',
      width: size,
      height: size,
      color: color ?? Theme.of(context).colorScheme.primary,
    );
  }
}
