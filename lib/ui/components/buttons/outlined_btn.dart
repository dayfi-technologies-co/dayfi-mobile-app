import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OutlineBtn extends StatelessWidget {
  final String text;
  final Function()? onPressed;
  final Color? textColor;
  final Color? borderColor;
  final Color? backgroundColor;
  final bool hasIcon;
  final Widget? icon;
  final double? width;
  final double? height;

  const OutlineBtn({
    super.key,
    required this.text,
    this.onPressed,
    this.textColor,
    this.borderColor,
    this.backgroundColor,
    this.hasIcon = false,
    this.icon,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        boxShadow:
            hasIcon
                ? [
                  BoxShadow(
                    // color: Colors.OrangeAccent.shade200,
                    blurRadius: 0,
                    spreadRadius: 0,
                    offset: Offset(
                      text == "Send"
                          ? -1.2
                          :
                          // text == 'Swap' ||
                          text == "Next - Enter amount"
                          ? 0
                          : 1.5,
                      3,
                    ),
                  ),
                ]
                : null,
        borderRadius: BorderRadius.circular(4.r),
      ),
      height: height ?? 48,
      width: MediaQuery.of(context).size.width,
      child: TextButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
            backgroundColor ?? theme.inputDecorationTheme.fillColor,
          ),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
          ),
          side: WidgetStateProperty.all(
            BorderSide(
              width: width ?? 1,
              color: borderColor ?? theme.textTheme.bodyLarge!.color!,
            ),
          ),
        ),
        onPressed: onPressed,
        child:
            hasIcon
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    icon!,
                    const SizedBox(width: 8),
                    Text(
                      text.toUpperCase(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -.04,
                        height: 1.450,
                        color: textColor ?? theme.textTheme.bodyLarge!.color,
                      ),
                    ),
                  ],
                )
                : Text(
                  text.toUpperCase(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.00,
                    height: 1.450,
                    fontFamily: "Karla",
                    color: textColor ?? theme.textTheme.bodyLarge!.color,
                  ),
                ),
      ),
    );
  }
}
