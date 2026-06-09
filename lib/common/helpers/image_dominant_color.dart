import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Samples an asset image and returns its most common non-background color.
Future<Color?> dominantColorFromAsset(String assetPath) async {
  try {
    final data = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: 32,
      targetHeight: 32,
    );
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    image.dispose();
    if (byteData == null) return null;

    final buckets = <int, int>{};
    final bytes = byteData.buffer.asUint8List();

    for (var i = 0; i < bytes.length; i += 4) {
      final alpha = bytes[i + 3];
      if (alpha < 128) continue;

      final red = bytes[i];
      final green = bytes[i + 1];
      final blue = bytes[i + 2];
      final luminance = 0.299 * red + 0.587 * green + 0.114 * blue;
      if (luminance > 240 || luminance < 15) continue;

      final key = ((red >> 4) << 16) | ((green >> 4) << 8) | (blue >> 4);
      buckets[key] = (buckets[key] ?? 0) + 1;
    }

    if (buckets.isEmpty) return null;

    final dominantKey = buckets.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    return Color.fromARGB(
      255,
      ((dominantKey >> 16) & 0xF) * 17,
      ((dominantKey >> 8) & 0xF) * 17,
      (dominantKey & 0xF) * 17,
    );
  } catch (_) {
    return null;
  }
}
