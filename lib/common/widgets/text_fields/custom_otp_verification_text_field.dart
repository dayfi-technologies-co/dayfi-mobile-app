import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';

import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';

class OtpVerificationTextField extends StatelessWidget {
  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  const OtpVerificationTextField({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.controller,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final defaultDecoration = BoxDecoration(
      // color: AppColors.transparent,
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: Colors.transparent, width: 1.5),
    );

    final focusedDecoration = defaultDecoration.copyWith(
      color: Colors.transparent,
      border: Border.all(color: Theme.of(context).colorScheme.onSurface, width: 1.5),
    );

    final submittedDecoration = defaultDecoration.copyWith(
      color: Colors.transparent,
      border: Border.all(color: AppColors.neutral400, width: 1.5),
    );

    return Pinput(
      errorPinTheme: PinTheme(
        width: 64.w,
        height: 72.h,
        textStyle: AppTypography.displaySmall,
        decoration: submittedDecoration,
      ),
      errorTextStyle: const TextStyle(
        color: Colors.red,
        fontSize: 13,
        fontFamily: 'Karla',
        letterSpacing: -.6,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      length: length,
      controller: controller,
      focusNode: focusNode,
      // androidSmsAutofillMethod: AndroidSmsAutofillMethod.none,
      keyboardType: TextInputType.number,
      mainAxisAlignment: MainAxisAlignment.start,
      defaultPinTheme: PinTheme(
        width: 64.w,
        height: 72.h,
        textStyle: AppTypography.displaySmall,
        decoration: defaultDecoration,
      ),
      focusedPinTheme: PinTheme(
        width: 64.w,
        height: 72.h,
        textStyle: AppTypography.displaySmall,
        decoration: focusedDecoration,
      ),
      submittedPinTheme: PinTheme(
        width: 64.w,
        height: 72.h,
        textStyle: AppTypography.displaySmall,
        decoration: submittedDecoration,
      ),
      separatorBuilder: (index) => SizedBox(width: 8.w),
      onChanged: onChanged,
      onCompleted: onCompleted,
    );
  }
}
