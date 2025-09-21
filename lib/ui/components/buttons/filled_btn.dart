import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';

class FilledBtn extends StatelessWidget {
  final String text;
  final Color? textColor;
  final Color? backgroundColor;
  final bool isEnabled;
  final bool isLoading;
  final Function()? onPressed;
  final String? semanticLabel;

  const FilledBtn({
    super.key,
    required this.text,
    this.textColor,
    this.backgroundColor,
    this.isEnabled = true,
    this.isLoading = false,
    this.onPressed,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = !isEnabled || isLoading || onPressed == null;
    final theme = Theme.of(context);

    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: !isDisabled,
      child: SizedBox(
        height: 48.h,
        width: double.infinity,
        child: TextButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(
              isDisabled
                  ? const Color(0xffCAC5FC)
                  : backgroundColor ?? Color(0xff5645F5),
            ),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            foregroundColor: WidgetStateProperty.all(Colors.transparent),
          ),
          onPressed: isDisabled
              ? null
              : () {
                  dismissKeyboard();
                  onPressed!();
                },
          child: isLoading
              ? SizedBox(
                  height: 20.h,
                  width: 20.h,
                  child: CupertinoActivityIndicator(
                    color: Colors.white,
                    // radius: 4.w,
                    // semanticsLabel: 'Loading',
                  ),
                )
              : Text(
                  text.toUpperCase(),
                  style: theme.textTheme.labelLarge!.copyWith(
                   
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.00,
                    height: 1.450,
                    fontFamily: "Karla", fontSize: 16.sp,
                    color:
                        isDisabled ? Colors.white : textColor ?? Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
