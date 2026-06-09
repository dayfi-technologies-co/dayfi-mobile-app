import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

/// Standard Dayfi loading animation (horizontal rotating dots).
class DayfiLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const DayfiLoadingIndicator({
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingAnimationWidget.horizontalRotatingDots(
      color: color ?? Theme.of(context).colorScheme.primary,
      size: size,
    );
  }
}

/// Centered [DayfiLoadingIndicator] for full-screen or section loading.
class DayfiLoadingCenter extends StatelessWidget {
  final double size;
  final Color? color;

  const DayfiLoadingCenter({
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DayfiLoadingIndicator(size: size, color: color),
    );
  }
}
