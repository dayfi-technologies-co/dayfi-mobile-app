import 'package:flutter/material.dart';

/// Centered screen helper copy — matches Add via Username / Add money detail screens.
class DayfiScreenDescription extends StatelessWidget {
  const DayfiScreenDescription({
    super.key,
    required this.text,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
    this.bottomSpacing = 16,
  });

  final String text;
  final EdgeInsetsGeometry padding;
  final double bottomSpacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomSpacing),
      child: Padding(
        padding: padding,
        child: Opacity(
          opacity: 0.85,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'Chirp',
              letterSpacing: -.25,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
