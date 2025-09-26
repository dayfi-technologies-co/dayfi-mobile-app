import 'package:flutter/material.dart';

/// App Typography System
///
/// This class defines the comprehensive typography system for Dayfi
/// following Material Design 3 principles and industry standards.
///
/// Typography is organized into semantic categories:
/// - Display: Large headings for hero sections
/// - Headline: Section headings and important titles
/// - Title: Card titles and subsection headings
/// - Body: Main content text
/// - Label: UI labels, buttons, and small text
/// - Custom: App-specific text styles
class AppTypography {
  // Private constructor to prevent instantiation
  AppTypography._();

  // ============================================================================
  // FONT FAMILIES
  // ============================================================================

  /// Primary font family - Readex Pro (for titles, body, micro)
  static const String primaryFontFamily = 'Readex Pro';

  /// Secondary font family - Youth (for display, headings, labels)
  static const String secondaryFontFamily = 'Karla';

  /// Monospace font family - For code and numbers
  static const String monospaceFontFamily = 'SF Mono';

  // ============================================================================
  // FONT WEIGHTS
  // ============================================================================

  /// Thin font weight - 100 (Youth only)
  static const FontWeight thin = FontWeight.w100;

  /// Extra Light font weight - 200 (Readex Pro only)
  static const FontWeight extraLight = FontWeight.w200;

  /// Light font weight - 300
  static const FontWeight light = FontWeight.w300;

  /// Regular font weight - 400
  static const FontWeight regular = FontWeight.w400;

  /// Medium font weight - 500
  static const FontWeight medium = FontWeight.w500;

  /// Semibold font weight - 600 (Readex Pro only)
  static const FontWeight semibold = FontWeight.w600;

  /// Bold font weight - 700
  static const FontWeight bold = FontWeight.w700;

  /// Black font weight - 900 (Youth only)
  static const FontWeight black = FontWeight.w900;

  // ============================================================================
  // DISPLAY STYLES (Large headings for hero sections)
  // ============================================================================

  /// Display Large - 48px, 56px line height, -0.8em letter spacing
  static const TextStyle displayLarge = TextStyle(
    fontSize: 48,
    height: 1.167, // 56px line height
    letterSpacing: -0.8,
    fontWeight: FontWeight.w600, // Bold for maximum impact
    fontFamily: secondaryFontFamily, // Youth
  );

  /// Display Medium - 40px, 48px line height, -0.64em letter spacing
  static const TextStyle displayMedium = TextStyle(
    fontSize: 40,
    height: 1.2, // 48px line height
    letterSpacing: -0.64,
    fontWeight: FontWeight.w500, // Medium weight
    fontFamily: secondaryFontFamily, // Youth
  );

  /// Display Small - 32px, 36px line height, -0.6em letter spacing
  static const TextStyle displaySmall = TextStyle(
    fontSize: 32,
    height: 1.125, // 36px line height
    letterSpacing: -0.6,
    fontWeight: FontWeight.w400, // Regular weight
    fontFamily: secondaryFontFamily, // Youth
  );

  // ============================================================================
  // HEADLINE STYLES (Section headings and important titles)
  // ============================================================================

  /// Headings H1 - 28px, 36px line height, 0em letter spacing
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 28,
    height: 1.286, // 36px line height
    letterSpacing: 0,
    fontWeight: FontWeight.w600, // Bold for H1
    fontFamily: secondaryFontFamily, // Youth
  );

  /// Headings H2 - 24px, 32px line height, 0em letter spacing
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24,
    height: 1.333, // 32px line height
    letterSpacing: 0,
    fontWeight: FontWeight.w500, // Medium for H2
    fontFamily: secondaryFontFamily, // Youth
  );

  /// Headings H3 - 20px, 26px line height, 0em letter spacing
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 20,
    height: 1.3, // 26px line height
    letterSpacing: 0,
    fontWeight: FontWeight.w500, // Medium for H3
    fontFamily: secondaryFontFamily, // Youth
  );

  /// Headings H4 - 18px, 24px line height, 0em letter spacing
  static const TextStyle headlineH4 = TextStyle(
    fontSize: 18,
    height: 1.333, // 24px line height
    letterSpacing: 0,
    fontWeight: FontWeight.w400, // Regular for H4
    fontFamily: secondaryFontFamily, // Youth
  );

  // ============================================================================
  // TITLE STYLES (Card titles and subsection headings)
  // ============================================================================

  /// Title Large - 24px, 28px line height, 0em letter spacing
  static const TextStyle titleLarge = TextStyle(
    fontSize: 24,
    height: 1.167, // 28px line height
    letterSpacing: 0,
    fontWeight: FontWeight.w400, // Semibold for large titles
    fontFamily: primaryFontFamily, // Readex Pro
  );

  /// Title Medium - 20px, 24px line height, 0em letter spacing
  static const TextStyle titleMedium = TextStyle(
    fontSize: 20,
    height: 1.2, // 24px line height
    letterSpacing: 0,
    fontWeight: FontWeight.w500, // Medium for medium titles
    fontFamily: primaryFontFamily, // Readex Pro
  );

  /// Title Regular - 16px, 20px line height, 0em letter spacing
  static const TextStyle titleRegular = TextStyle(
    fontSize: 16,
    height: 1.25, // 20px line height
    letterSpacing: 0,
    fontWeight: FontWeight.w500, // Medium for regular titles
    fontFamily: primaryFontFamily, // Readex Pro
  );

  /// Title Small - 14px, 20px line height, 0em letter spacing
  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    height: 1.429, // 20px line height
    letterSpacing: 0,
    fontWeight: FontWeight.w400, // Regular weight (matches spec)
    fontFamily: primaryFontFamily, // Readex Pro
  );

  // ============================================================================
  // BODY STYLES (Main content text)
  // ============================================================================

  /// Body Large - 16px, 20px line height, 0em letter spacing
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    height: 1.25, // 20px line height
    letterSpacing: 0,
    fontWeight: FontWeight.w400,
    fontFamily: primaryFontFamily, // Readex Pro
  );

  /// Body Medium - 14px, 20px line height, 0em letter spacing
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    height: 1.429, // 20px line height
    letterSpacing: 0,
    fontWeight: FontWeight.w400,
    fontFamily: primaryFontFamily, // Readex Pro
  );

  /// Body Regular - 11px, 16px line height, 0em letter spacing
  static const TextStyle bodyRegular = TextStyle(
    fontSize: 11,
    height: 1.455, // 16px line height
    letterSpacing: 0,
    fontWeight: FontWeight.w400, // Regular weight (matches spec)
    fontFamily: primaryFontFamily, // Readex Pro
  );

  /// Body Small - 9px, 12px line height, 0em letter spacing
  static const TextStyle bodySmall = TextStyle(
    fontSize: 9,
    height: 1.333, // 12px line height
    letterSpacing: 0,
    fontWeight: FontWeight.w400,
    fontFamily: primaryFontFamily, // Readex Pro
  );

  // ============================================================================
  // LABEL STYLES (UI labels, buttons, and small text)
  // ============================================================================

  /// Label Large - 16px, 20px line height, 0em letter spacing
  static const TextStyle labelLarge = TextStyle(
    fontSize: 16,
    height: 1.25, // 20px line height
    letterSpacing: 0,
    fontWeight: FontWeight.w500, // Medium for large labels
    fontFamily: secondaryFontFamily, // Youth
  );

  /// Label Medium - 14px, 18px line height, 0em letter spacing
  static const TextStyle labelMedium = TextStyle(
    fontSize: 14,
    height: 1.286, // 18px line height
    letterSpacing: 0,
    fontWeight: FontWeight.w500, // Medium for medium labels
    fontFamily: secondaryFontFamily, // Youth
  );

  /// Label Regular - 12px, 16px line height, 0.6em letter spacing
  static const TextStyle labelRegular = TextStyle(
    fontSize: 12,
    height: 1.333, // 16px line height
    letterSpacing: 0.6,
    fontWeight: FontWeight.w400, // Regular weight (matches spec)
    fontFamily: secondaryFontFamily, // Youth
  );

  /// Label Small - 10px, 14px line height, 0em letter spacing
  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    height: 1.4, // 14px line height
    letterSpacing: 0,
    fontWeight: FontWeight.w400, // Regular weight (matches spec)
    fontFamily: secondaryFontFamily, // Youth
  );

  /// Label Tiny - 8px, 12px line height, 0em letter spacing
  static const TextStyle labelTiny = TextStyle(
    fontSize: 8,
    height: 1.5, // 12px line height
    letterSpacing: 0,
    fontWeight: FontWeight.w400, // Regular weight (matches spec)
    fontFamily: secondaryFontFamily, // Youth
  );

  // ============================================================================
  // MICRO STYLES (Very small text)
  // ============================================================================

  /// Micro Large - 10px, 12px line height, 0em letter spacing
  static const TextStyle microLarge = TextStyle(
    fontSize: 10,
    height: 1.2, // 12px line height
    letterSpacing: 0,
    fontWeight: FontWeight.w400,
    fontFamily: primaryFontFamily, // Readex Pro
  );

  /// Micro Medium - 9px, 10px line height, 0em letter spacing
  static const TextStyle microMedium = TextStyle(
    fontSize: 9,
    height: 1.111, // 10px line height
    letterSpacing: 0,
    fontWeight: FontWeight.w400,
    fontFamily: primaryFontFamily, // Readex Pro
  );

  // ============================================================================
  // CUSTOM APP-SPECIFIC STYLES
  // ============================================================================

  /// App Title - Large, bold title for app branding
  static const TextStyle appTitle = TextStyle(
    fontSize: 28,
    height: 1.286, // 36px line height
    letterSpacing: 0,
    fontWeight: FontWeight.w600, // Bold for app branding
    fontFamily: secondaryFontFamily, // Youth
  );

  /// Card Title - Medium weight for card headers
  static const TextStyle cardTitle = TextStyle(
    fontSize: 20,
    height: 1.2, // 24px line height
    letterSpacing: 0,
    fontWeight: FontWeight.w400, // Semibold for card titles
    fontFamily: primaryFontFamily, // Readex Pro
  );

  /// Button Text - Medium weight for button labels
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    height: 1.25, // 20px line height
    letterSpacing: 0,
    fontWeight: FontWeight.w400, // Semibold for buttons
    fontFamily: primaryFontFamily, // Readex Pro
  );

  /// Caption - Small text for captions and metadata
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    height: 1.333, // 16px line height
    letterSpacing: 0.6,
    fontWeight: FontWeight.w400, // Regular for captions
    fontFamily: secondaryFontFamily, // Youth
  );

  /// Overline - Very small text for overlines
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    height: 1.2, // 12px line height
    letterSpacing: 0,
    fontWeight: FontWeight.w500, // Medium for overlines
    fontFamily: primaryFontFamily, // Readex Pro
  );

  /// Number Display - For displaying large numbers (balances, amounts)
  static const TextStyle numberDisplay = TextStyle(
    fontSize: 32,
    height: 1.125, // 36px line height
    letterSpacing: -0.6,
    fontWeight: FontWeight.w600,
    fontFamily: monospaceFontFamily,
  );

  /// Number Large - For displaying medium numbers
  static const TextStyle numberLarge = TextStyle(
    fontSize: 24,
    height: 1.167, // 28px line height
    letterSpacing: -0.8,
    fontWeight: FontWeight.w400,
    fontFamily: monospaceFontFamily,
  );

  /// Number Medium - For displaying small numbers
  static const TextStyle numberMedium = TextStyle(
    fontSize: 18,
    height: 1.333, // 24px line height
    letterSpacing: 0,
    fontWeight: FontWeight.w400,
    fontFamily: monospaceFontFamily,
  );

  /// Number Small - For displaying very small numbers
  static const TextStyle numberSmall = TextStyle(
    fontSize: 14,
    height: 1.429, // 20px line height
    letterSpacing: 0,
    fontWeight: FontWeight.w500,
    fontFamily: monospaceFontFamily,
  );

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Create a text style with custom color
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Create a text style with custom weight
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Create a text style with custom size
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }

  /// Create a text style with custom height
  static TextStyle withHeight(TextStyle style, double height) {
    return style.copyWith(height: height);
  }

  /// Create a text style with custom letter spacing
  static TextStyle withLetterSpacing(TextStyle style, double spacing) {
    return style.copyWith(letterSpacing: spacing);
  }

  /// Create a text style with custom decoration
  static TextStyle withDecoration(TextStyle style, TextDecoration decoration) {
    return style.copyWith(decoration: decoration);
  }

  /// Create a text style with custom shadows
  static TextStyle withShadows(TextStyle style, List<Shadow> shadows) {
    return style.copyWith(shadows: shadows);
  }

  /// Create a text style with custom font family
  static TextStyle withFontFamily(TextStyle style, String fontFamily) {
    return style.copyWith(fontFamily: fontFamily);
  }

  /// Create a text style with custom font style
  static TextStyle withFontStyle(TextStyle style, FontStyle fontStyle) {
    return style.copyWith(fontStyle: fontStyle);
  }

  /// Create a text style with custom overflow
  static TextStyle withOverflow(TextStyle style, TextOverflow overflow) {
    return style.copyWith(overflow: overflow);
  }

  /// Create a text style with custom max lines
  static TextStyle withMaxLines(TextStyle style, int maxLines) {
    return style.copyWith(overflow: TextOverflow.ellipsis);
  }

  /// Create a text style with custom text baseline
  static TextStyle withTextBaseline(TextStyle style, TextBaseline baseline) {
    return style.copyWith(textBaseline: baseline);
  }

  /// Create a text style with custom locale
  static TextStyle withLocale(TextStyle style, Locale locale) {
    return style.copyWith(locale: locale);
  }

  /// Create a text style with custom background
  static TextStyle withBackground(TextStyle style, Paint background) {
    return style.copyWith(background: background);
  }

  /// Create a text style with custom foreground
  static TextStyle withForeground(TextStyle style, Paint foreground) {
    return style.copyWith(foreground: foreground);
  }

  /// Create a text style with custom decoration color
  static TextStyle withDecorationColor(TextStyle style, Color color) {
    return style.copyWith(decorationColor: color);
  }

  /// Create a text style with custom decoration style
  static TextStyle withDecorationStyle(
    TextStyle style,
    TextDecorationStyle decorationStyle,
  ) {
    return style.copyWith(decorationStyle: decorationStyle);
  }

  /// Create a text style with custom decoration thickness
  static TextStyle withDecorationThickness(TextStyle style, double thickness) {
    return style.copyWith(decorationThickness: thickness);
  }

  /// Create a text style with custom word spacing
  static TextStyle withWordSpacing(TextStyle style, double spacing) {
    return style.copyWith(wordSpacing: spacing);
  }

  /// Create a text style with custom font features
  static TextStyle withFontFeatures(
    TextStyle style,
    List<FontFeature> features,
  ) {
    return style.copyWith(fontFeatures: features);
  }

  /// Create a text style with custom font variations
  static TextStyle withFontVariations(
    TextStyle style,
    List<FontVariation> variations,
  ) {
    return style.copyWith(fontVariations: variations);
  }

  /// Create a text style with custom leading distribution
  static TextStyle withLeadingDistribution(
    TextStyle style,
    TextLeadingDistribution distribution,
  ) {
    return style.copyWith(leadingDistribution: distribution);
  }
}
