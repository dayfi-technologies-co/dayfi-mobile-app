import 'package:dayfi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// DayFlow automation row icon — teal octagon + white gear (like send/bill badges).
class DayFlowAutomationIconBadge extends StatelessWidget {
  const DayFlowAutomationIconBadge({
    super.key,
    this.size = 40,
    this.innerSize = 26,
    this.muted = false,
  });

  final double size;
  final double innerSize;
  final bool muted;

  static const Color badgeColor = AppColors.teal500;

  @override
  Widget build(BuildContext context) {
    final ringAlpha = muted ? 0.5 : 1.0;
    final innerAlpha = muted ? 0.7 : 1.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/svgs/account.svg',
            height: size,
            colorFilter: ColorFilter.mode(
              badgeColor.withValues(alpha: ringAlpha),
              BlendMode.srcIn,
            ),
          ),
          SvgPicture.asset(
            'assets/icons/svgs/automation.svg',
            height: innerSize,
            colorFilter: ColorFilter.mode(
              Colors.white.withValues(alpha: innerAlpha),
              BlendMode.srcIn,
            ),
          ),
        ],
      ),
    );
  }
}
