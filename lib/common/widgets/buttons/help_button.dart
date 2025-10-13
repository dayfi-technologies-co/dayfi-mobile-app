import 'package:dayfi/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';

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
      child: Container(
        height: 32.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: ShapeDecoration(
          color: AppColors.primary100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12.r),
            onTap: onTap,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  svgIcon ?? Assets.icons.svgs.spark.svg(),
                  SizedBox(width: text?.toUpperCase() == "READ ALL" ? 0 : 4.w),
                  Text(
                    text?.toUpperCase() ?? "HELP",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: AppTypography.semibold,
                      fontFamily: AppTypography.secondaryFontFamily,
                      letterSpacing: -0.3,
                      height: 1.5,
                      color: AppColors.neutral950,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
