import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EyeIcon extends StatelessWidget {
  final bool isVisible;
  final Color? color;
  final double size;

  const EyeIcon({
    super.key,
    required this.isVisible,
    this.color,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      isVisible 
        ? 'assets/icons/svgs/eye.svg'
        : 'assets/icons/svgs/eye-closed.svg',
      width: size,
      height: size,
      colorFilter: color != null 
        ? ColorFilter.mode(color!, BlendMode.srcIn)
        : null,
    );
  }
}



