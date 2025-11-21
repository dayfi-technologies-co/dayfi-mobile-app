import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:dayfi/common/utils/haptic_helper.dart';

class TopSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Haptic feedback based on message type
    if (isError) {
      HapticHelper.error();
    } else {
      HapticHelper.success();
    }
    
    final primaryColor =
        isError ? const Color(0xFFDC2626) : const Color(0xFF059669);
    final backgroundColor =
        isError ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4);
    final borderColor =
        isError ? const Color(0xFFFECACA) : const Color(0xFFBBF7D0);
    final textColor =
        isError ? const Color(0xFF991B1B) : const Color(0xFF065F46);

    Flushbar(
      messageText: Row(
        children: [
          // Enhanced icon with animation
          Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SvgPicture.asset(
                  isError
                      ? 'assets/icons/svgs/circle-x.svg'
                      : 'assets/icons/svgs/circle-check.svg',
                  color: primaryColor,
                  height: 24.sp,
                  width: 24.sp,
                ),
              )
              .animate()
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.0, 1.0),
                duration: const Duration(milliseconds: 200),
                curve: Curves.elasticOut,
              )
              .fadeIn(duration: const Duration(milliseconds: 150)),
          const SizedBox(width: 12),
          // Enhanced text with better typography
          Expanded(
            child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 16.sp,
                 fontFamily: 'CabinetGrotesk',
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.2,
                    height: 1.4,
                    color: textColor,
                  ),
                )
                .animate()
                .slideX(
                  begin: -0.2,
                  end: 0.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                )
                .fadeIn(duration: const Duration(milliseconds: 200)),
          ),
        ],
      ),
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      borderRadius: BorderRadius.circular(12),
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      borderWidth: 1.5,
      duration: duration,
      flushbarPosition: FlushbarPosition.TOP,
      animationDuration: const Duration(milliseconds: 300),
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      // Add subtle shadow
      boxShadows: [
        BoxShadow(
          color: primaryColor.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
      // Enhanced animation
      showProgressIndicator: false,
      isDismissible: true,
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
    ).show(context);
  }
}
