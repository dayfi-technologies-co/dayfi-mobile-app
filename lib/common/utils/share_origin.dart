import 'package:flutter/material.dart';

/// Anchor rect for [Share.share] / [Share.shareXFiles] on iPad and iOS.
Rect sharePositionOrigin(BuildContext context) {
  final box = context.findRenderObject();
  if (box is RenderBox && box.hasSize) {
    final origin = box.localToGlobal(Offset.zero) & box.size;
    if (origin.width > 0 && origin.height > 0) return origin;
  }
  final size = MediaQuery.sizeOf(context);
  return Rect.fromLTWH(size.width * 0.5, size.height * 0.5, 1, 1);
}
