import 'package:dayfi/common/utils/ui_helpers.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CapitalizeFirstLetterFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    
    // Capitalize the first letter
    String capitalizedText = newValue.text;
    if (capitalizedText.isNotEmpty) {
      capitalizedText = capitalizedText[0].toUpperCase() + 
          (capitalizedText.length > 1 ? capitalizedText.substring(1) : '');
    }
    
    return TextEditingValue(
      text: capitalizedText,
      selection: newValue.selection,
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String? label;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? hintText;
  final TextInputFormatter? formatter;
  final Function(String)? onChanged;
  final Function()? onTap;
  final int? maxLength;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final Color? borderColor;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool shouldReadOnly;
  final bool enabled;
  final TextCapitalization? textCapitalization;
  final int? minLines;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final bool enableInteractiveSelection;
  final Widget? prefix;
  final String? errorText;
  final double? errorFontSize;
  final bool isDayfiId;
  final bool capitalizeFirstLetter;

  const CustomTextField({
    super.key,
    this.label,
    this.keyboardType,
    this.obscureText = false,
    this.hintText,
    this.formatter,
    this.onChanged,
    this.onTap,
    this.maxLength,
    this.suffixIcon,
    this.prefixIcon,
    this.borderColor,
    this.controller,
    this.validator,
    this.shouldReadOnly = false,
    this.enabled = true,
    this.minLines,
    this.textCapitalization,
    this.textInputAction,
    this.autofocus = true,
    this.enableInteractiveSelection = true,
    this.prefix,
    this.errorText,
    this.errorFontSize,
    this.isDayfiId = false,
    this.capitalizeFirstLetter = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label != ""
            ? Text(
              label!,
              style: TextStyle(
                fontFamily: 'Karla',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: -.6,
                height: 1.450,
                color:
                    label == "hidden"
                        ? Colors.transparent
                        : Theme.of(
                          context,
                        ).textTheme.bodyLarge!.color!.withOpacity(.75),
              ),
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
            )
            : const SizedBox(),
        SizedBox(height: label == "" ? 0 : 4),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0.r),
            boxShadow: [
              BoxShadow(
                color:
                    errorText.toString() != "null"
                        ? isDayfiId
                            ? Colors.green.withOpacity(0.3)
                            : Colors.red.withOpacity(0.3)
                        : const Color.fromARGB(
                          255,
                          123,
                          36,
                          211,
                        ).withOpacity(0.05),
                blurRadius: 1.0,
                offset: const Offset(0, 2),
                spreadRadius: 0.25,
              ),
            ],
          ),
          child: TextFormField(
            // autofocus: autofocus,
            maxLines: obscureText ? 1 : minLines,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            onTap: onTap,
            enableInteractiveSelection: enableInteractiveSelection,
            textCapitalization:
                textCapitalization ?? TextCapitalization.sentences,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            maxLength: obscureText ? null : maxLength,
            controller: controller,
            cursorColor: AppColors.purple500, // innit
            
            textInputAction: textInputAction,
            keyboardType: keyboardType,
            readOnly: shouldReadOnly,
            obscureText: obscureText,
            onChanged: onChanged,
            validator: validator,
            inputFormatters: [
              formatter ?? FilteringTextInputFormatter.singleLineFormatter,
            ],
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontFamily: 'Karla',
              fontSize: 16,
              letterSpacing: -.6,
              fontWeight: FontWeight.w500,
              height: 1.450,
            ),
            decoration: InputDecoration(
              counterText: "",
              errorText: errorText,
              hintText: hintText,
              hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontFamily: 'Karla',
                fontSize: 16,
                letterSpacing: -.6,
                fontWeight: FontWeight.w500,
                height: 1.450,
                overflow: TextOverflow.ellipsis,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(.25),
              ),
              filled: true,
              fillColor:
                  errorText.toString() != "null"
                      ? isDayfiId
                          ? Colors.greenAccent.withOpacity(.08)
                          : const Color.fromARGB(255, 255, 217, 214)
                      : Theme.of(context).colorScheme.surface,
              contentPadding: EdgeInsets.symmetric(
                vertical: 14.h,
                horizontal: 10.w,
              ),
              errorStyle: TextStyle(
                fontFamily: 'Karla',
                fontSize: errorFontSize ?? 13.sp,
                color: Colors.red.shade800,
                letterSpacing: -.6,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
              prefixIcon: prefixIcon,
              prefix: prefix,
              suffixIcon: suffixIcon,
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(12.0.r)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(12.0.r)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(12.0.r)),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(12.0.r)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ReadOnlyCustomTextField extends StatelessWidget {
  final String? label;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? hintText;
  final TextInputFormatter? formatter;
  final Function(String)? onChanged;
  final Function()? onTap;
  final int? maxLength;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final Color? borderColor;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool shouldReadOnly;
  final bool enabled;
  final TextCapitalization? textCapitalization;
  final int? minLines;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final bool enableInteractiveSelection;
  final Widget? prefix;
  final String? errorText;

  const ReadOnlyCustomTextField({
    super.key,
    this.label,
    this.keyboardType,
    this.obscureText = false,
    this.hintText,
    this.formatter,
    this.onChanged,
    this.onTap,
    this.maxLength,
    this.suffixIcon,
    this.prefixIcon,
    this.borderColor,
    this.controller,
    this.validator,
    this.shouldReadOnly = false,
    this.enabled = true,
    this.minLines,
    this.textCapitalization,
    this.textInputAction,
    this.autofocus = true,
    this.enableInteractiveSelection = true,
    this.prefix,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label!,
          style: const TextStyle(
            fontFamily: 'Karla',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: -.1,
            height: 1.450,
            color: Color(0xFF302D53),
          ),
          textAlign: TextAlign.start,
          overflow: TextOverflow.ellipsis,
        ),
        verticalSpace(label == "" ? 0 : 4),
        TextFormField(
          // autofocus: autofocus,
          maxLines: obscureText ? 1 : minLines,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          onTap: onTap,
          enableInteractiveSelection: enableInteractiveSelection,
          textCapitalization:
              textCapitalization ?? TextCapitalization.sentences,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          maxLength: obscureText ? null : maxLength,
          controller: controller,
          cursorColor: AppColors.purple500, // innit
          textInputAction: textInputAction,
          keyboardType: keyboardType,
          readOnly: true,
          obscureText: obscureText,
          onChanged: onChanged,
          validator: validator,
          inputFormatters: [
            formatter ?? FilteringTextInputFormatter.singleLineFormatter,
          ],
          style: const TextStyle(
            fontFamily: 'Karla',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.450,
            color: Color(0xFF302D53),
          ),
          decoration: InputDecoration(
            counterText: "",
            errorText: errorText,
            hintText: hintText,
            hintStyle: TextStyle(
              fontFamily: 'Karla',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.450,
              color: Theme.of(context).textTheme.bodyLarge!.color!
              // ignore: deprecated_member_use
              .withOpacity(.5),
            ),
            filled: true,
            fillColor: const Color.fromARGB(255, 0, 0, 0).withOpacity(.075),
            contentPadding: EdgeInsets.symmetric(
              vertical: 14.h,
              horizontal: 14.w,
            ),
            errorStyle: TextStyle(
              fontFamily: 'Karla',
              fontSize: 12,
              color: Colors.red.shade800,
              letterSpacing: -.3,
            ),
            prefixIcon: prefixIcon,
            prefix: prefix,
            suffixIcon: suffixIcon,
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                // color: Color( 0xff5645F5), // innit
                color: AppColors.purple500, // innit
                width: 1.w,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.0.r),
                topRight: Radius.circular(8.0.r),
              ),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.purple500.withOpacity(.2),
                width: 1.w,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.0.r),
                topRight: Radius.circular(8.0.r),
              ),
            ),
            focusedErrorBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.red.shade800.withOpacity(.85),
                width: 1.w,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.0.r),
                topRight: Radius.circular(8.0.r),
              ),
            ),
            errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.red.shade800.withOpacity(.85),
                width: 1.w,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.0.r),
                topRight: Radius.circular(8.0.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
