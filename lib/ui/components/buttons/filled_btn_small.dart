import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';

class FilledBtnSmall extends StatelessWidget {
  final String text;
  final Color? textColor;
  final Color? backgroundColor;
  final bool? isEnabled;
  final Function()? onPressed;
  final Color? borderColor;
  final double borderWidth;
  final bool isModelBusy;

  const FilledBtnSmall({
    super.key,
    required this.text,
    this.textColor,
    this.onPressed,
    this.backgroundColor,
    this.isEnabled = true,
    this.borderColor,
    this.borderWidth = 2.0,
    this.isModelBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    return SizedBox(
      height: 34,
      child: TextButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
            backgroundColor ?? const Color(0xff5645F5),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40.r),
            ),
          ),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          foregroundColor: WidgetStateProperty.all(Colors.transparent),
        ),
        onPressed: isEnabled == false
            ? null
            : () {
                dismissKeyboard();
                onPressed!();
              },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: isModelBusy
              ? const Center(
                  child: SizedBox(
                    height: 22,
                    width: 20,
                    child: CupertinoActivityIndicator(
                      color: Color(0xff5645F5), // innit
                    ),
                  ),
                )
              : Text(
                  text,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                    fontFamily: "Karla",
                    height: 0,
                    color: textColor ?? Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}

class FilledBtnSmall2 extends StatelessWidget {
  final String text;
  final Color? textColor;
  final Color? backgroundColor;
  final bool? isEnabled;
  final Function()? onPressed;
  final Color? borderColor;
  final double borderWidth;
  final bool isModelBusy;

  const FilledBtnSmall2({
    super.key,
    required this.text,
    this.textColor,
    this.onPressed,
    this.backgroundColor,
    this.isEnabled = true,
    this.borderColor,
    this.borderWidth = 2.0,
    this.isModelBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 34,
      child: TextButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
            backgroundColor ??
                (isEnabled == false
                    ? theme.primaryColor.withOpacity(0.5)
                    : theme.primaryColor),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          foregroundColor: WidgetStateProperty.all(Colors.transparent),
        ),
        onPressed: isEnabled == false ? () {} : onPressed,
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * .01),
          child: isModelBusy
              ? const Center(
                  child: SizedBox(
                    height: 22,
                    width: 20,
                    child: CupertinoActivityIndicator(
                      color: Color(0xff5645F5), // innit
                    ),
                  ),
                )
              : Text(
                  text,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                    height: 0,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
