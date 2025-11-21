import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:flutter_svg/svg.dart';

/// A static Help button that always routes to the Help/FAQ page.
class HelpButton extends StatelessWidget {
  /// The route to navigate to (defaults to "/help")
  final String routeName;
  final VoidCallback? onTap;
  final String? text;
  final Widget? svgIcon;

  const HelpButton({
    super.key,
    this.routeName = "/help",
    this.onTap,
    this.text,
    this.svgIcon,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Padding(
        padding: EdgeInsets.only(right: 0.w),
        child: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: onTap,
          child: Stack(
            alignment: AlignmentGeometry.center,
            children: [
              SvgPicture.asset(
                "assets/icons/svgs/notificationn.svg",
                height: 40.sp,
                color: AppColors.neutral700.withOpacity(.35),
              ),
              Center(
                child: SvgPicture.asset(
                  "assets/icons/svgs/support.svg",
                  height: 28,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(.65),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
