import 'package:flutter/material.dart';

/// Selectable marketing text for the public web landing experience.
///
/// Uses [SelectableText] so visitors can highlight and copy content on web.
class LandingCopyableText extends StatelessWidget {
  const LandingCopyableText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
  });

  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return SelectableText(
      data,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }
}

/// Selectable rich text for styled landing headlines and inline emphasis.
class LandingCopyableRichText extends StatelessWidget {
  const LandingCopyableRichText(
    this.textSpan, {
    super.key,
    this.textAlign,
    this.maxLines,
  });

  final TextSpan textSpan;
  final TextAlign? textAlign;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return SelectableText.rich(
      textSpan,
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }
}
