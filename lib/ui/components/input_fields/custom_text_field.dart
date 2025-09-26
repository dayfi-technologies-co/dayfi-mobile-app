import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
                  fontWeight: FontWeight.w600,
                  letterSpacing: -.1,
                  height: 1.450,
                  color: label == "hidden"
                      ? Colors.transparent
                      : Color(0xff2A0079),
                ),
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
              )
            : const SizedBox(),
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
          cursorColor: const Color(0xff5645F5), // innit
          textInputAction: textInputAction,
          keyboardType: keyboardType,
          readOnly: shouldReadOnly,
          obscureText: obscureText,
          onChanged: onChanged,
          validator: validator,
          inputFormatters: [
            formatter ?? FilteringTextInputFormatter.singleLineFormatter,
          ],
          style: const TextStyle(
            fontFamily: 'Karla',
            fontSize: 16,
            letterSpacing: -.1,
            fontWeight: FontWeight.w600,
            height: 1.450,
            color: Color(0xff2A0079),
          ),
          decoration: InputDecoration(
            counterText: "",
            errorText: errorText,
            hintText: hintText,
            hintStyle: TextStyle(
              fontFamily: 'Karla',
              fontSize: 16,
              letterSpacing: -.1,
              fontWeight: FontWeight.w500,
              height: 1.450,
              color: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .color!
                  // ignore: deprecated_member_use
                  .withOpacity(.65),
            ),
            filled: true,
            fillColor: errorText.toString() != "null"
                ? isDayfiId
                    ? Colors.greenAccent.withOpacity(.08)
                    : const Color.fromARGB(255, 255, 217, 214)
                : Colors.white,
            contentPadding: EdgeInsets.symmetric(
              vertical: 14.h,
              horizontal: 10.w,
            ),
            errorStyle: TextStyle(
              fontFamily: 'Karla',
              fontSize: errorFontSize,
              color: Colors.red.shade800,
              letterSpacing: -.3,
            ),
            prefixIcon: prefixIcon,
            prefix: prefix,
            suffixIcon: suffixIcon,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                // color: Color( 0xff5645F5), // innit
                color: const Color(0xff5645F5), // innit
                width: 1.w,
              ),
              borderRadius: BorderRadius.all(Radius.circular(4.r)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: const Color(0xff5645F5).withOpacity(.2),
                width: 1.w,
              ),
              borderRadius: BorderRadius.all(Radius.circular(4.r)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: isDayfiId
                    ? Colors.green.shade800.withOpacity(.85)
                    : Colors.red.shade800.withOpacity(.85),
                width: 1.w,
              ),
              borderRadius: BorderRadius.all(Radius.circular(4.r)),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: isDayfiId
                    ? Colors.green.shade800.withOpacity(.85)
                    : Colors.red.shade800.withOpacity(.85),
                width: 1.w,
              ),
              borderRadius: BorderRadius.all(Radius.circular(4.r)),
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
            fontWeight: FontWeight.w600,
            letterSpacing: -.1,
            height: 1.450,
            color: Color(0xFF302D53),
          ),
          textAlign: TextAlign.start,
          overflow: TextOverflow.ellipsis,
        ),
        verticalSpace(4),
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
          cursorColor: const Color(0xff5645F5), // innit
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
            fontWeight: FontWeight.w600,
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
              color: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .color!
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
                color: const Color(0xff5645F5), // innit
                width: 1.w,
              ),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4.r),
                  topRight: Radius.circular(4.r)),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: const Color(0xff5645F5).withOpacity(.2),
                width: 1.w,
              ),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4.r),
                  topRight: Radius.circular(4.r)),
            ),
            focusedErrorBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.red.shade800.withOpacity(.85),
                width: 1.w,
              ),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4.r),
                  topRight: Radius.circular(4.r)),
            ),
            errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.red.shade800.withOpacity(.85),
                width: 1.w,
              ),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4.r),
                  topRight: Radius.circular(4.r)),
            ),
          ),
        ),
      ],
    );
  }
}
