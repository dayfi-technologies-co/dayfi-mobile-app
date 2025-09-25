import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_spacing.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:pinput/pinput.dart';

class PinTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String? value)? validation;
  final int fieldCount;
  final bool isTransactionPin;
  final bool obscureText;
  final double? boxSize;
  final void Function(String value)? onChange;
  final bool autoDisposeControllers;

  PinTextField(
      {super.key,
      this.controller,
      required this.validation,
      this.fieldCount = 4,
      this.isTransactionPin = false,
      this.obscureText = true,
      this.onChange,
      this.boxSize = 52,
      this.autoDisposeControllers = true});

  final FocusNode pinPutFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Pinput(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      length: fieldCount,
      focusNode: AlwaysDisabledFocusNode(), // Use custom focus node
      controller: controller,
      validator: validation,
      enabled: true,
      readOnly: false, // Needed for paste to work
      toolbarEnabled: true, // Enables paste option
      autofillHints: const [AutofillHints.oneTimeCode],
      showCursor: false,
      keyboardType: TextInputType.none, // Optional
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        PasteOnlyInputFormatter(), // See below
      ],
      onTap: () {
        // You can trigger paste manually if needed
      },
      onChanged: (value) {
        if (controller != null && controller!.text != value) {
          controller!.text = value;
        }

        if (onChange != null && value.length == fieldCount) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onChange!(value);
          });
        }
      },
      errorPinTheme: PinTheme(
        // shape: PinCodeFieldShape.underline,
        height: boxSize ?? 64.h,
        width: boxSize ?? 64.w,
        decoration: BoxDecoration(
            borderRadius:BorderRadius.circular(50),
            border: Border.all(width: 2, color: AppColors.error500)
            ),
      ),
      defaultPinTheme: PinTheme(
        // shape: PinCodeFieldShape.underline,
        textStyle: AppTypography.bodyMedium.copyWith(
          fontSize: AppSpacings.k20,
        ),
        height: boxSize ?? 64.h,
        width: boxSize ?? 64.w,
        decoration: BoxDecoration(
            borderRadius:BorderRadius.circular(50),
            border: Border.all(width: 2, color: AppColors.blackAlpha24)
            ),
      ),

      errorTextStyle: TextStyle(
          color: AppColors.error500,
          fontSize: AppTypography.labelMedium.fontSize,
          fontWeight: FontWeight.w500),
      obscureText: obscureText,
      animationDuration: const Duration(milliseconds: 300),
    );
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => true;
}

class PasteOnlyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final isPaste = (newValue.text.length - oldValue.text.length) > 1 ||
        (oldValue.text.isEmpty && newValue.text.isNotEmpty);

    return isPaste ? newValue : oldValue;
  }
}
