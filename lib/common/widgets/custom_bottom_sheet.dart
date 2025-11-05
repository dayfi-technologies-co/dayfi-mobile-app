import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/gen/assets.gen.dart';
import 'package:dayfi/common/widgets/buttons/buttons.dart';

/// A dynamic bottom sheet widget that adapts to different use cases.
///
/// This widget provides a flexible bottom sheet implementation with:
/// - Optional handle for drag indication
/// - Configurable close icon positioning (left/right)
/// - Dynamic sizing (auto-fit or fixed height)
/// - Built-in continue button with customization
/// - Support for all bottom sheet variants through configuration
class CustomBottomSheet extends StatelessWidget {
  /// The main content of the bottom sheet
  final Widget child;

  /// Whether to show the drag handle at the top
  final bool showHandle;

  /// Whether to show the close icon
  final bool showCloseIcon;

  /// Position of the close icon (left or right)
  final CloseIconPosition closeIconPosition;

  /// Fixed height for the bottom sheet (null for auto-fit)
  final double? fixedHeight;

  /// Maximum height for the bottom sheet
  final double? maxHeight;

  /// Minimum height for the bottom sheet
  final double? minHeight;

  /// Whether to show the default continue button
  final bool showContinueButton;

  /// Text for the continue button
  final String? continueButtonText;

  /// Callback for continue button press
  final VoidCallback? onContinue;

  /// Custom continue button widget (overrides default if provided)
  final Widget? customContinueButton;

  /// Whether the continue button is enabled
  final bool continueButtonEnabled;

  /// Whether the continue button is in loading state
  final bool continueButtonLoading;

  /// Background color of the bottom sheet
  final Color? backgroundColor;

  /// Border radius of the bottom sheet
  final double? borderRadius;

  /// Padding around the content
  final EdgeInsets? contentPadding;

  /// Padding for the continue button area
  final EdgeInsets? continueButtonPadding;

  /// Whether the bottom sheet is dismissible by tapping outside
  final bool isDismissible;

  /// Whether the bottom sheet can be dismissed by dragging down
  final bool enableDrag;

  /// Callback when the bottom sheet is dismissed
  final VoidCallback? onDismissed;

  /// Custom header widget (overrides default header if provided)
  final Widget? customHeader;

  /// Title for the bottom sheet
  final String? title;

  /// Subtitle for the bottom sheet
  final String? subtitle;

  /// Whether to show the title and subtitle
  final bool showTitle;

  /// Custom close icon widget
  final Widget? customCloseIcon;

  /// Custom handle widget
  final Widget? customHandle;

  /// Whether to use safe area for the content
  final bool useSafeArea;

  /// Elevation of the bottom sheet
  final double? elevation;

  /// Shadow color of the bottom sheet
  final Color? shadowColor;

  const CustomBottomSheet({
    super.key,
    required this.child,
    this.showHandle = true,
    this.showCloseIcon = true,
    this.closeIconPosition = CloseIconPosition.right,
    this.fixedHeight,
    this.maxHeight,
    this.minHeight,
    this.showContinueButton = true,
    this.continueButtonText,
    this.onContinue,
    this.customContinueButton,
    this.continueButtonEnabled = true,
    this.continueButtonLoading = false,
    this.backgroundColor,
    this.borderRadius,
    this.contentPadding,
    this.continueButtonPadding,
    this.isDismissible = true,
    this.enableDrag = true,
    this.onDismissed,
    this.customHeader,
    this.title,
    this.subtitle,
    this.showTitle = false,
    this.customCloseIcon,
    this.customHandle,
    this.useSafeArea = true,
    this.elevation,
    this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight ?? MediaQuery.of(context).size.height * 0.9,
        minHeight: minHeight ?? 200.h,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadius ?? 24.r),
          topRight: Radius.circular(borderRadius ?? 24.r),
        ),
        boxShadow:
            elevation != null && elevation! > 0
                ? [
                  BoxShadow(
                    color: shadowColor ?? Colors.black.withOpacity(0.1),
                    blurRadius: elevation! * 2,
                    offset: Offset(0, -elevation!),
                  ),
                ]
                : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with handle and close icon
          _buildHeader(context),

          // Title and subtitle
          if (showTitle && (title != null || subtitle != null))
            _buildTitleSection(context),

          // Main content
          Flexible(
            child: Container(
              width: double.infinity,
              height: fixedHeight,
              padding: contentPadding ?? EdgeInsets.all(24.w),
              child: useSafeArea ? SafeArea(child: child) : child,
            ),
          ),

          // Continue button
          if (showContinueButton) _buildContinueButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side
          if (showCloseIcon && closeIconPosition == CloseIconPosition.left)
            _buildCloseIcon(context)
          else
            const SizedBox.shrink(),

          // Center - always show handle if enabled
          if (showHandle) _buildHandle(context) else const SizedBox.shrink(),

          // Right side
          if (showCloseIcon && closeIconPosition == CloseIconPosition.right)
            _buildCloseIcon(context)
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildHandle(BuildContext context) {
    if (customHandle != null) return customHandle!;

    return Container(
      width: 40.w,
      height: 4.h,
      decoration: BoxDecoration(
        color: AppColors.neutral300,
        borderRadius: BorderRadius.circular(2.r),
      ),
    );
  }

  Widget _buildCloseIcon(BuildContext context) {
    if (customCloseIcon != null) return customCloseIcon!;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        onDismissed?.call();
      },
      child: Center(
        child: Assets.icons.pngs.closeiconblack.image(
          width: 18.w,
          height: 18.h,
        ),
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Text(
              title!,
              style: AppTypography.headlineH4.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (subtitle != null) ...[
            SizedBox(height: 8.h),
            Text(
              subtitle!,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.neutral600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    if (customContinueButton != null) {
      return Container(
        padding:
            continueButtonPadding ??
            EdgeInsets.only(left: 24.w, right: 24.w, bottom: 50.h),
        child: customContinueButton!,
      );
    }

    return Container(
      padding:
          continueButtonPadding ??
          EdgeInsets.only(left: 24.w, right: 24.w, bottom: 50.h),
      child: PrimaryButton.dayfi(
        text: continueButtonText ?? 'CONTINUE',
        onPressed: continueButtonEnabled ? onContinue : null,
        enabled: continueButtonEnabled,
        isLoading: continueButtonLoading,
        fullWidth: true,
      ),
    );
  }

  /// Shows the bottom sheet with proper configuration
  static Future<T?> show<T>({
    required BuildContext context,
    required CustomBottomSheet bottomSheet,
    bool isScrollControlled = true,
    bool useRootNavigator = false,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? barrierColor,
    String? barrierLabel,
    bool useSafeArea = true,
    RouteSettings? routeSettings,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      builder: (context) => bottomSheet,
      isScrollControlled: isScrollControlled,
      useRootNavigator: useRootNavigator,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      barrierColor: barrierColor ?? AppColors.neutral900.withOpacity(0.85),
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      routeSettings: routeSettings,
    );
  }
}

/// Enum for close icon position
enum CloseIconPosition { left, right }

/// Extension methods for CustomBottomSheet
extension CustomBottomSheetExtensions on CustomBottomSheet {
  /// Creates a copy of this bottom sheet with updated properties
  CustomBottomSheet copyWith({
    Widget? child,
    bool? showHandle,
    bool? showCloseIcon,
    CloseIconPosition? closeIconPosition,
    double? fixedHeight,
    double? maxHeight,
    double? minHeight,
    bool? showContinueButton,
    String? continueButtonText,
    VoidCallback? onContinue,
    Widget? customContinueButton,
    bool? continueButtonEnabled,
    bool? continueButtonLoading,
    Color? backgroundColor,
    double? borderRadius,
    EdgeInsets? contentPadding,
    EdgeInsets? continueButtonPadding,
    bool? isDismissible,
    bool? enableDrag,
    VoidCallback? onDismissed,
    Widget? customHeader,
    String? title,
    String? subtitle,
    bool? showTitle,
    Widget? customCloseIcon,
    Widget? customHandle,
    bool? useSafeArea,
    double? elevation,
    Color? shadowColor,
  }) {
    return CustomBottomSheet(
      key: key,
      child: child ?? this.child,
      showHandle: showHandle ?? this.showHandle,
      showCloseIcon: showCloseIcon ?? this.showCloseIcon,
      closeIconPosition: closeIconPosition ?? this.closeIconPosition,
      fixedHeight: fixedHeight ?? this.fixedHeight,
      maxHeight: maxHeight ?? this.maxHeight,
      minHeight: minHeight ?? this.minHeight,
      showContinueButton: showContinueButton ?? this.showContinueButton,
      continueButtonText: continueButtonText ?? this.continueButtonText,
      onContinue: onContinue ?? this.onContinue,
      customContinueButton: customContinueButton ?? this.customContinueButton,
      continueButtonEnabled:
          continueButtonEnabled ?? this.continueButtonEnabled,
      continueButtonLoading:
          continueButtonLoading ?? this.continueButtonLoading,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      contentPadding: contentPadding ?? this.contentPadding,
      continueButtonPadding:
          continueButtonPadding ?? this.continueButtonPadding,
      isDismissible: isDismissible ?? this.isDismissible,
      enableDrag: enableDrag ?? this.enableDrag,
      onDismissed: onDismissed ?? this.onDismissed,
      customHeader: customHeader ?? this.customHeader,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      showTitle: showTitle ?? this.showTitle,
      customCloseIcon: customCloseIcon ?? this.customCloseIcon,
      customHandle: customHandle ?? this.customHandle,
      useSafeArea: useSafeArea ?? this.useSafeArea,
      elevation: elevation ?? this.elevation,
      shadowColor: shadowColor ?? this.shadowColor,
    );
  }
}
