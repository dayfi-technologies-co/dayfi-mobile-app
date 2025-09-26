import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// UI Helper functions for consistent spacing and layout
class UIHelpers {
  // Private constructor to prevent instantiation
  UIHelpers._();
}

/// Creates vertical spacing with consistent sizing
Widget verticalSpace(double height) {
  return SizedBox(height: height.h);
}

/// Creates horizontal spacing with consistent sizing
Widget horizontalSpace(double width) {
  return SizedBox(width: width.w);
}

/// Creates small vertical spacing (4.h)
Widget verticalSpaceSmall() {
  return SizedBox(height: 4.h);
}

/// Creates medium vertical spacing (8.h)
Widget verticalSpaceMedium() {
  return SizedBox(height: 8.h);
}

/// Creates large vertical spacing (16.h)
Widget verticalSpaceLarge() {
  return SizedBox(height: 16.h);
}

/// Creates extra large vertical spacing (24.h)
Widget verticalSpaceXLarge() {
  return SizedBox(height: 24.h);
}

/// Creates small horizontal spacing (4.w)
Widget horizontalSpaceSmall() {
  return SizedBox(width: 4.w);
}

/// Creates medium horizontal spacing (8.w)
Widget horizontalSpaceMedium() {
  return SizedBox(width: 8.w);
}

/// Creates large horizontal spacing (16.w)
Widget horizontalSpaceLarge() {
  return SizedBox(width: 16.w);
}

/// Creates extra large horizontal spacing (24.w)
Widget horizontalSpaceXLarge() {
  return SizedBox(width: 24.w);
}


