import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/common/utils/haptic_helper.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

/// A reusable secondary button widget that follows the Dayfi design system.
///
/// This button provides a consistent secondary action button with customizable
/// colors, text, and styling while maintaining the design system standards.
class SecondaryButton extends StatelessWidget {
  /// The text to display on the button
  final String text;

  /// Callback function when the button is pressed
  final VoidCallback? onPressed;

  /// Whether the button is enabled or disabled
  final bool enabled;

  /// Whether the button is in loading state
  final bool isLoading;

  /// The background color of the button
  final Color? backgroundColor;

  /// The text color of the button
  final Color? textColor;

  /// The border color of the button
  final Color? borderColor;

  /// The width of the button
  final double? width;

  /// The height of the button
  final double? height;

  /// The horizontal padding of the button
  final double? horizontalPadding;

  /// The vertical padding of the button
  final double? verticalPadding;

  /// The border radius of the button
  final double? borderRadius;

  /// The border width of the button
  final double? borderWidth;

  /// The font size of the text
  final double? fontSize;

  /// The font weight of the text
  final FontWeight? fontWeight;

  /// The letter spacing of the text
  final double? letterSpacing;

  /// The line height of the text
  final double? lineHeight;

  /// The font family of the text
  final String? fontFamily;

  /// Whether to show a loading indicator
  final bool showLoadingIndicator;

  /// The color of the loading indicator
  final Color? loadingIndicatorColor;

  /// The size of the loading indicator
  final double? loadingIndicatorSize;

  /// Custom child widget (overrides text if provided)
  final Widget? child;

  /// Whether to use the full width available
  final bool fullWidth;

  /// The elevation of the button
  final double? elevation;

  /// The shadow color of the button
  final Color? shadowColor;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.enabled = true,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.width,
    this.height,
    this.horizontalPadding,
    this.verticalPadding,
    this.borderRadius,
    this.borderWidth,
    this.fontSize,
    this.fontWeight,
    this.letterSpacing,
    this.lineHeight,
    this.fontFamily,
    this.showLoadingIndicator = true,
    this.loadingIndicatorColor,
    this.loadingIndicatorSize,
    this.child,
    this.fullWidth = false,
    this.elevation,
    this.shadowColor,
  });

  /// Creates a secondary button with default Dayfi styling
  factory SecondaryButton.dayfi({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool enabled = true,
    bool isLoading = false,
    Color? backgroundColor,
    Color? textColor,
    Color? borderColor,
    double? width,
    double? height,
    bool fullWidth = false,
    Widget? child,
  }) {
    return SecondaryButton(
      key: key,
      text: text,
      onPressed: onPressed,
      enabled: enabled,
      isLoading: isLoading,
      backgroundColor: backgroundColor ?? Colors.transparent,
      textColor: textColor ?? AppColors.primary400,
      borderColor: borderColor ?? AppColors.primary400,
      width: width ?? 343.w,
      height: height ?? 56.h,
      horizontalPadding: 10.w,
      verticalPadding: 8.h,
      borderRadius: 10.r,
      borderWidth: 1,
      fontSize: 18.sp,
      fontWeight: AppTypography.bold,
      letterSpacing: 0.18,
      lineHeight: 1.78,
      fontFamily: AppTypography.secondaryFontFamily,
      fullWidth: fullWidth,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = !enabled || isLoading;
    final effectiveBackgroundColor =
        isDisabled
            ? (backgroundColor ?? Colors.transparent).withOpacity(0.5)
            : backgroundColor ?? Colors.transparent;

    final effectiveTextColor =
        isDisabled
            ? (textColor ?? AppColors.primary400).withOpacity(0.7)
            : textColor ?? AppColors.primary400;

    final effectiveBorderColor =
        isDisabled
            ? (borderColor ?? AppColors.primary400).withOpacity(0.5)
            : borderColor ?? AppColors.primary400;

    return Container(
      width: fullWidth ? double.infinity : width,
      height: height,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding ?? 10.w,
        vertical: verticalPadding ?? 8.h,
      ),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: effectiveBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 10.r),
          side: BorderSide(
            color: effectiveBorderColor,
            width: borderWidth ?? 1.5,
          ),
        ),
        shadows:
            elevation != null && elevation! > 0
                ? [
                  BoxShadow(
                    color: shadowColor ?? effectiveBorderColor.withOpacity(0.3),
                    blurRadius: elevation! * 2,
                    offset: Offset(0, elevation!),
                  ),
                ]
                : null,
      ),
      child: Semantics(
        button: true,
        enabled: !isDisabled,
        label: text,
        hint: isLoading ? 'Loading' : null,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap:
                isDisabled
                    ? null
                    : () {
                      HapticHelper.mediumImpact();
                      onPressed?.call();
                    },
            borderRadius: BorderRadius.circular(borderRadius ?? 10.r),
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (isLoading && showLoadingIndicator) ...[
                    SizedBox(
                      width: loadingIndicatorSize ?? 20.w,
                      height: loadingIndicatorSize ?? 20.w,
                      child: LoadingAnimationWidget.horizontalRotatingDots(
                        color: loadingIndicatorColor ?? effectiveTextColor,
                        size: loadingIndicatorSize ?? 20,
                      ),
                    ),
                    SizedBox(width: 8.w),
                  ],
                  if (child != null)
                    child!
                  else
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Text(
                        text,
                        style: TextStyle(
                          color: effectiveTextColor,
                          fontSize: fontSize ?? 18,
                          fontFamily:
                              fontFamily ?? AppTypography.secondaryFontFamily,
                          fontWeight: fontWeight ?? AppTypography.medium,
                          height: lineHeight ?? 1.78,
                          letterSpacing: -.8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Extension methods for SecondaryButton to provide additional functionality
extension SecondaryButtonExtensions on SecondaryButton {
  /// Creates a copy of this button with updated properties
  SecondaryButton copyWith({
    String? text,
    VoidCallback? onPressed,
    bool? enabled,
    bool? isLoading,
    Color? backgroundColor,
    Color? textColor,
    Color? borderColor,
    double? width,
    double? height,
    double? horizontalPadding,
    double? verticalPadding,
    double? borderRadius,
    double? borderWidth,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? lineHeight,
    String? fontFamily,
    bool? showLoadingIndicator,
    Color? loadingIndicatorColor,
    double? loadingIndicatorSize,
    Widget? child,
    bool? fullWidth,
    double? elevation,
    Color? shadowColor,
  }) {
    return SecondaryButton(
      key: key,
      text: text ?? this.text,
      onPressed: onPressed ?? this.onPressed,
      enabled: enabled ?? this.enabled,
      isLoading: isLoading ?? this.isLoading,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      borderColor: borderColor ?? this.borderColor,
      width: width ?? this.width,
      height: height ?? this.height,
      horizontalPadding: horizontalPadding ?? this.horizontalPadding,
      verticalPadding: verticalPadding ?? this.verticalPadding,
      borderRadius: borderRadius ?? this.borderRadius,
      borderWidth: borderWidth ?? this.borderWidth,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      lineHeight: lineHeight ?? this.lineHeight,
      fontFamily: fontFamily ?? this.fontFamily,
      showLoadingIndicator: showLoadingIndicator ?? this.showLoadingIndicator,
      loadingIndicatorColor:
          loadingIndicatorColor ?? this.loadingIndicatorColor,
      loadingIndicatorSize: loadingIndicatorSize ?? this.loadingIndicatorSize,
      fullWidth: fullWidth ?? this.fullWidth,
      elevation: elevation ?? this.elevation,
      shadowColor: shadowColor ?? this.shadowColor,
      child: child ?? this.child,
    );
  }
}
