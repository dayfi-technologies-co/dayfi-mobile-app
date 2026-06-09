/// Shared breakpoints and content width for Flutter web marketing pages.
abstract final class WebLayout {
  WebLayout._();

  /// Below this width: single column, hamburger nav.
  static const double mobileBreakpoint = 768;

  /// Below this width: two-column grids where applicable.
  static const double tabletBreakpoint = 1024;

  /// Max readable content width on large screens.
  static const double maxContentWidth = 1280;

  static bool isMobile(double width) => width < mobileBreakpoint;

  static bool isTablet(double width) =>
      width >= mobileBreakpoint && width < tabletBreakpoint;

  static bool isDesktop(double width) => width >= tabletBreakpoint;

  /// Horizontal gutter outside the content column.
  static double pagePadding(double viewportWidth) {
    if (isMobile(viewportWidth)) return 20;
    if (isTablet(viewportWidth)) return 32;
    return 48;
  }

  /// Width of the centered content column (never capped below viewport).
  static double contentMaxWidth(double viewportWidth) {
    if (isMobile(viewportWidth)) return viewportWidth;
    final padded = viewportWidth - pagePadding(viewportWidth) * 2;
    return padded.clamp(0, maxContentWidth).toDouble();
  }

  /// Readable width inside [contentMaxWidth] after horizontal page padding.
  static double contentInnerWidth(double viewportWidth) {
    return contentMaxWidth(viewportWidth) - pagePadding(viewportWidth) * 2;
  }

  // --- Landing page responsive tokens (based on content column width) ---

  /// Editorial right inset for section headlines and body copy.
  static double sectionRightInset(double contentWidth, {double fraction = 0.2}) {
    if (isMobile(contentWidth)) return 18;
    if (isTablet(contentWidth)) {
      return (contentWidth * fraction * 0.65).clamp(40, 140);
    }
    return (contentWidth * fraction).clamp(100, 420);
  }

  /// Larger staggered inset (highlight cards, how-it-works).
  static double sectionLargeRightInset(double contentWidth) {
    if (isMobile(contentWidth)) return 18;
    if (isTablet(contentWidth)) {
      return (contentWidth * 0.15).clamp(40, 130);
    }
    return (contentWidth * 0.32).clamp(140, 400);
  }

  /// Extra inset for delivery-method copy blocks.
  static double sectionExtraRightInset(double contentWidth) {
    if (isMobile(contentWidth)) return 40;
    if (isTablet(contentWidth)) {
      return (contentWidth * 0.22).clamp(64, 180);
    }
    return (contentWidth * 0.45).clamp(180, 520);
  }

  /// Bottom margin between stacked editorial blocks.
  static double sectionBottomSpacing(double contentWidth, {double fraction = 0.06}) {
    if (isMobile(contentWidth)) return 40;
    return (contentWidth * fraction).clamp(48, 120);
  }

  /// Standard vertical gap between subsections.
  static double sectionVerticalGap(double contentWidth) {
    if (isMobile(contentWidth)) return 48;
    if (isTablet(contentWidth)) return 56;
    return 72;
  }
}
