

import 'package:flutter/material.dart';
import 'package:dayfi/common/widgets/toggle_animation.dart';

extension GestureExtension on Widget {
  Widget onTap({required VoidCallback? onTap, required String tooltip}) {
    return ToggleAnimation(
      onTap: onTap,
      child: Tooltip(message: tooltip, child: this),
    );
  }

  Widget onTapWithoutAnimation(
      {required VoidCallback? onTap, required String tooltip}) {
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(message: tooltip, child: this),
    );
  }
}
