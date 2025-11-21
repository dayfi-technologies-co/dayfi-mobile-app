import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/common/utils/haptic_helper.dart';
import 'package:dayfi/core/navigation/navigator_key.dart';

class DayfiTagSuccessDialog extends StatelessWidget {
  final String dayfiId;
  final VoidCallback onClose;
  final BuildContext? parentContext;

  const DayfiTagSuccessDialog({
    super.key,
    required this.dayfiId,
    required this.onClose,
    this.parentContext,
  });

  void _copyDayfiId(BuildContext context) {
    HapticHelper.lightImpact();
    Clipboard.setData(ClipboardData(text: dayfiId));

    // Pop the dialog first
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    Navigator.of(context).pop();

    // Then handle parent navigation and show snackbar after navigation completes
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // Show snackbar in the parent context or navigator key context
      final snackbarContext =
          parentContext ?? NavigatorKey.appNavigatorKey.currentContext;
      if (snackbarContext != null) {
        TopSnackbar.show(
          snackbarContext,
          message: 'Dayfi ID copied to clipboard',
          isError: false,
        );
      }

      // Call onClose to pop parent views with result
      Future.delayed(const Duration(milliseconds: 100), () {
        onClose();
      });
    });
  }

  void _handleClose(BuildContext context) {
    // Pop the dialog, then handle parent navigation
    Navigator.of(context).pop();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      // Small delay before popping parent to avoid navigator conflicts
      Future.delayed(const Duration(milliseconds: 100), () {
        onClose();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28.r),
          topRight: Radius.circular(28.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 88.w,
              height: 3.5.h,
              margin: EdgeInsets.only(top: 8.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.r),
                color: Theme.of(
                  context,
                ).textTheme.bodyLarge!.color!.withOpacity(0.25),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),

          // Close button
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () => _handleClose(context),
              child: Image.asset(
                "assets/icons/pngs/cancelicon.png",
                height: 24.h,
                width: 24.w,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),

          // Content
          Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success icon
                SvgPicture.asset(
                  "assets/icons/svgs/successs.svg",
                  height: 88.h,
                  width: 88.w,
                ),
                SizedBox(height: 24.h),

                // Title
                Text(
                  "Your Dayfi ID is all set",
                  style: AppTypography.titleLarge.copyWith(
                 fontFamily: 'CabinetGrotesk',
                     fontSize: 20.sp, // height: 1.6,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),

                // Subtitle
                Text(
                  "$dayfiId is your Dayfi id. It can be found on your profile page, and copied.",
                  style: AppTypography.bodyMedium.copyWith(
                    fontFamily: 'Karla',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                    height: 1.4,
                    letterSpacing: -.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.12),

                // Copy button
                PrimaryButton(
                  text: 'Dayfi ID copied',
                  onPressed: () => _copyDayfiId(context),
                  backgroundColor: AppColors.purple500,
                  textColor: AppColors.neutral0,
                  borderRadius: 38.r,
                  height: 48.000.h,
                  width: double.infinity,
                  fullWidth: true,
                  fontFamily: 'Karla',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.8,
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
