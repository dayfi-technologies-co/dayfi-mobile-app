// import 'package:epass/ui/common/app_colors.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class PinTextField extends StatelessWidget {
  final Function(String)? onTextChanged;
  final Function()? onCancel;
  final Function(String)? onCompleted;
  final TextEditingController? controller;
  final bool isEnabled;
  final double? height;
  final double? width;
  final int length;
  final bool obscureText;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;

  const PinTextField({
    super.key,
    this.onTextChanged,
    this.controller,
    this.focusNode,
    this.obscureText = false,
    this.isEnabled = true,
    this.height,
    this.width,
    this.length = 4,
    this.onCancel,
    this.onCompleted,
    this.validator,
    this.textInputAction = TextInputAction.done,
  });

  @override
  Widget build(BuildContext context) {
    return PinCodeTextField(
      keyboardType: TextInputType.number,
      focusNode: focusNode,
      enablePinAutofill: true,
      controller: controller,
      autoDisposeControllers: false,
      blinkDuration: const Duration(milliseconds: 10),
      enabled: isEnabled,
      validator: validator,
      textInputAction: textInputAction,
      cursorWidth: 1,
      enableActiveFill: true,
      obscureText: obscureText,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
        fontSize: 20.sp,
       fontWeight: FontWeight.w500,
        fontFamily: 'Karla',
        letterSpacing: 0,
      ),
      pinTheme: PinTheme(
        errorBorderWidth: 1.w,
        activeBorderWidth: 1.w,
        disabledBorderWidth: 1.w,
        inactiveBorderWidth: 1.w,
        selectedBorderWidth: 1.w,
        borderWidth: 1.w,
        fieldHeight: height ?? 60.0.w,
        fieldWidth: width ?? 48.0.w,
        borderRadius: BorderRadius.circular(12.r),
        shape: PinCodeFieldShape.box,
        inactiveFillColor: Theme.of(context).colorScheme.surface,
        activeFillColor: Theme.of(context).colorScheme.surface,
        selectedFillColor: Theme.of(context).colorScheme.surface,
        inactiveColor: AppColors.purple500ForTheme(context).withOpacity(.2),
        activeColor: AppColors.purple500ForTheme(context).withOpacity(.2),
        selectedColor: AppColors.purple500ForTheme(context),
      ),

      appContext: context,
      length: length,
      onCompleted: onCompleted,
      onChanged: onTextChanged!,
      animationType: AnimationType.fade,
      animationDuration: const Duration(milliseconds: 150),
      cursorColor: AppColors.purple500ForTheme(context),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    );
  }
}
