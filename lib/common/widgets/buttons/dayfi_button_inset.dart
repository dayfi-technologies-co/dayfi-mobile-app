import 'package:dayfi/common/app_constants.dart';
import 'package:flutter/material.dart';

Widget wrapDayfiFeatureButtonInset({
  required bool fullWidth,
  required bool applyFeatureInset,
  required Widget child,
}) {
  if (!fullWidth || !applyFeatureInset) return child;
  return Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: AppConstants.buttonExtraHorizontalPadding,
    ),
    child: child,
  );
}
