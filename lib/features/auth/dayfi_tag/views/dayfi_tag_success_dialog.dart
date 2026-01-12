import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';

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
          message: 'Dayfi Tag copied to clipboard',
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
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
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
              width: 88,
              height: 3.5,
              margin: EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
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
                height: 24,
                width: 24,
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
                  height: 88,
                  width: 88,
                ),
                SizedBox(height: 24),

                // Title
                Text(
                  "Your Dayfi Tag is all set",
                  style: AppTypography.titleLarge.copyWith(
                 fontFamily: 'FunnelDisplay',
                     fontSize: 24, // height: 1.6,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),

                // Subtitle
                Text(
                  "$dayfiId is your Dayfi Tag. It can be found on your profile page, and copied.",
                  style: AppTypography.bodyMedium.copyWith(
                    fontFamily: 'Chirp',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                    height: 1.2,
                    letterSpacing: -.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.12),

                // Copy button
                PrimaryButton(
                  text: 'Dayfi Tag copied',
                  onPressed: () => _copyDayfiId(context),
                  backgroundColor: AppColors.purple500,
                  textColor: AppColors.neutral0,
                  borderRadius: 38,
                  height: 48.00000,
                  width: double.infinity,
                  fullWidth: true,
                  fontFamily: 'Chirp',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.3,
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
