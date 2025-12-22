// import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AmountCustomTextField extends StatelessWidget {
  final String? label;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? hintText;
  final String? labelText;
  final List<TextInputFormatter>? formatter;
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
  final AutovalidateMode? autovalidateMode;

  const AmountCustomTextField({
    super.key,
    this.label,
    this.keyboardType,
    this.obscureText = false,
    this.hintText,
    this.labelText,
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
    this.autovalidateMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label!,
          style: theme.textTheme.bodySmall?.copyWith(
            fontFamily: 'Chirp',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -.1,
            height: 1.450,
          ),
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 4),
        TextFormField(
          maxLines: minLines,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          onTap: onTap,
          enableInteractiveSelection: enableInteractiveSelection,
          textCapitalization:
              textCapitalization ?? TextCapitalization.sentences,
          autovalidateMode:
              autovalidateMode ?? AutovalidateMode.onUserInteraction,
          maxLength: obscureText ? null : maxLength,
          controller: controller,
          cursorColor: const Color(0xff5645F5), // innit
          textInputAction: textInputAction,
          keyboardType: keyboardType,
          readOnly: shouldReadOnly,
          obscureText: obscureText,
          onChanged: onChanged,
          validator: validator,
          inputFormatters:
              formatter ?? [FilteringTextInputFormatter.singleLineFormatter],
          style: TextStyle(
            fontFamily: 'Chirp', //
            fontSize: 15,
            fontWeight: FontWeight.w600,
            height: 1.450,
            letterSpacing: -.1,
            color: theme.textTheme.bodyLarge!.color,
          ),
          decoration: InputDecoration(
            counterText: "",
            hintText: hintText,
            hintStyle: TextStyle(
              fontFamily: 'Chirp', //
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.450,
              letterSpacing: -.1,
              color: theme.textTheme.bodyLarge!.color!.withOpacity(0.5),
            ),
            filled: true,
            labelText: labelText,
            labelStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: -.01,
              fontFamily: "Chirp",
              height: 1.450,
              color: theme.textTheme.bodyLarge!.color!.withOpacity(0.75),
            ),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            fillColor: theme.colorScheme.surface,
            contentPadding: EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 14,
            ),
            errorStyle: TextStyle(
              fontFamily: "Chirp",
              fontSize: 12,
              color: Colors.red.shade800,
              letterSpacing: -.25,
            ),
            prefixIcon: prefixIcon,
            prefix: prefix,
            suffixIcon: suffixIcon,
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                // color: Color( 0xff5645F5), // innit
                color: const Color(0xff5645F5), // innit
                width: 2,
              ),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4)),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: const Color(0xff5645F5).withOpacity(.2),
                width: 2,
              ),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4)),
            ),
            focusedErrorBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.red.shade800.withOpacity(.85),
                width: 2,
              ),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4)),
            ),
            errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.red.shade800.withOpacity(.85),
                width: 2,
              ),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4)),
            ),
          ),
        ),
      ],
    );
  }
}
