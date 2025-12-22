import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';

/// UI Helper functions for consistent spacing and layout
class UIHelpers {
  // Private constructor to prevent instantiation
  UIHelpers._();

  /// Default barrier color for dialogs and bottom sheets
  static Color get defaultBarrierColor => AppColors.neutral900.withOpacity(0.85);
}

/// Creates vertical spacing with consistent sizing
Widget verticalSpace(double height) {
  return SizedBox(height: height);
}

/// Creates horizontal spacing with consistent sizing
Widget horizontalSpace(double width) {
  return SizedBox(width: width);
}

/// Creates small vertical spacing (4)
Widget verticalSpaceSmall() {
  return SizedBox(height: 4);
}

/// Creates medium vertical spacing (8)
Widget verticalSpaceMedium() {
  return SizedBox(height: 8);
}

/// Creates large vertical spacing (16)
Widget verticalSpaceLarge() {
  return SizedBox(height: 16);
}

/// Creates extra large vertical spacing (24)
Widget verticalSpaceXLarge() {
  return SizedBox(height: 24);
}

/// Creates small horizontal spacing (4)
Widget horizontalSpaceSmall() {
  return SizedBox(width: 4);
}

/// Creates medium horizontal spacing (8)
Widget horizontalSpaceMedium() {
  return SizedBox(width: 8);
}

/// Creates large horizontal spacing (16)
Widget horizontalSpaceLarge() {
  return SizedBox(width: 16);
}

/// Creates extra large horizontal spacing (24)
Widget horizontalSpaceXLarge() {
  return SizedBox(width: 24);
}

/// Shows a dialog with consistent dark barrier color
/// 
/// This is a wrapper around [showDialog] that applies a consistent
/// dark barrier color (AppColors.neutral900.withOpacity(0.85))
/// for all dialogs in the app.
Future<T?> showAppDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor,
  String? barrierLabel,
  bool useSafeArea = true,
  bool useRootNavigator = false,
  RouteSettings? routeSettings,
  Offset? anchorPoint,
}) {
  return showDialog<T>(
    context: context,
    builder: builder,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor ?? UIHelpers.defaultBarrierColor,
    barrierLabel: barrierLabel,
    useSafeArea: useSafeArea,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    anchorPoint: anchorPoint,
  );
}

/// Shows a modal bottom sheet with consistent dark barrier color
/// 
/// This is a wrapper around [    showModalBottomSheet] that applies a consistent
/// dark barrier color (AppColors.neutral900.withOpacity(0.85))
/// for all bottom sheets in the app.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  bool useRootNavigator = false,
  bool isDismissible = true,
  bool enableDrag = true,
  Color? backgroundColor,
  Color? barrierColor,
  String? barrierLabel,
  double? elevation,
  ShapeBorder? shape,
  Clip? clipBehavior,
  BoxConstraints? constraints,
  bool useSafeArea = true,
  RouteSettings? routeSettings,
  AnimationController? transitionAnimationController,
  Offset? anchorPoint,
}) {
  return     showModalBottomSheet<T>(
    context: context,
    builder: builder,
    isScrollControlled: isScrollControlled,
    useRootNavigator: useRootNavigator,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: backgroundColor,
    barrierColor: barrierColor ?? UIHelpers.defaultBarrierColor,
    barrierLabel: barrierLabel,
    elevation: elevation,
    shape: shape,
    clipBehavior: clipBehavior,
    constraints: constraints,
    useSafeArea: useSafeArea,
    routeSettings: routeSettings,
    transitionAnimationController: transitionAnimationController,
    anchorPoint: anchorPoint,
  );
}
