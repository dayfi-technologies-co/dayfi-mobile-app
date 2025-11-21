import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_theme_extensions.dart';

/// Theme Utilities
///
/// Utility functions and helper classes for working with the app's theme system
/// Provides convenient access to colors, typography, spacing, and other theme properties
class ThemeUtils {
  // Private constructor to prevent instantiation
  ThemeUtils._();

  // ============================================================================
  // COLOR UTILITIES
  // ============================================================================

  /// Get the primary color from context
  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  /// Get the secondary color from context
  static Color getSecondaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.secondary;
  }

  /// Get the tertiary color from context
  static Color getTertiaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.tertiary;
  }

  /// Get the surface color from context
  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  /// Get the background color from context
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  /// Get the error color from context
  static Color getErrorColor(BuildContext context) {
    return Theme.of(context).colorScheme.error;
  }

  /// Get the success color from context
  static Color getSuccessColor(BuildContext context) {
    return AppColors.success500;
  }

  /// Get the warning color from context
  static Color getWarningColor(BuildContext context) {
    return AppColors.warning500;
  }

  /// Get the info color from context
  static Color getInfoColor(BuildContext context) {
    return AppColors.info500;
  }

  /// Get the text color from context
  static Color getTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  /// Get the hint text color from context
  static Color getHintTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  /// Get the disabled text color from context
  static Color getDisabledTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface.withOpacity(0.38);
  }

  /// Get the divider color from context
  static Color getDividerColor(BuildContext context) {
    return Theme.of(context).colorScheme.outline;
  }

  /// Get the border color from context
  static Color getBorderColor(BuildContext context) {
    return Theme.of(context).colorScheme.outline;
  }

  /// Get the shadow color from context
  static Color getShadowColor(BuildContext context) {
    return Theme.of(context).colorScheme.shadow;
  }

  /// Get the scrim color from context
  static Color getScrimColor(BuildContext context) {
    return Theme.of(context).colorScheme.scrim;
  }

  // ============================================================================
  // TYPOGRAPHY UTILITIES
  // ============================================================================

  /// Get display large text style
  static TextStyle getDisplayLarge(BuildContext context) {
    return Theme.of(context).textTheme.displayLarge!;
  }

  /// Get display medium text style
  static TextStyle getDisplayMedium(BuildContext context) {
    return Theme.of(context).textTheme.displayMedium!;
  }

  /// Get display small text style
  static TextStyle getDisplaySmall(BuildContext context) {
    return Theme.of(context).textTheme.displaySmall!;
  }

  /// Get headline large text style
  static TextStyle getHeadlineLarge(BuildContext context) {
    return Theme.of(context).textTheme.headlineLarge!;
  }

  /// Get headline medium text style
  static TextStyle getHeadlineMedium(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium!;
  }

  /// Get headline small text style
  static TextStyle getHeadlineSmall(BuildContext context) {
    return Theme.of(context).textTheme.headlineSmall!;
  }

  /// Get title large text style
  static TextStyle getTitleLarge(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge!;
  }

  /// Get title medium text style
  static TextStyle getTitleMedium(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium!;
  }

  /// Get title small text style
  static TextStyle getTitleSmall(BuildContext context) {
    return Theme.of(context).textTheme.titleSmall!;
  }

  /// Get body large text style
  static TextStyle getBodyLarge(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge!;
  }

  /// Get body medium text style
  static TextStyle getBodyMedium(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!;
  }

  /// Get body small text style
  static TextStyle getBodySmall(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall!;
  }

  /// Get label large text style
  static TextStyle getLabelLarge(BuildContext context) {
    return Theme.of(context).textTheme.labelLarge!;
  }

  /// Get label medium text style
  static TextStyle getLabelMedium(BuildContext context) {
    return Theme.of(context).textTheme.labelMedium!;
  }

  /// Get label small text style
  static TextStyle getLabelSmall(BuildContext context) {
    return Theme.of(context).textTheme.labelSmall!;
  }

  // ============================================================================
  // NEW TYPOGRAPHY STYLES
  // ============================================================================

  /// Get title regular text style
  static TextStyle getTitleRegular(BuildContext context) {
    return AppTypography.titleRegular.copyWith(color: getTextColor(context));
  }

  /// Get body regular text style
  static TextStyle getBodyRegular(BuildContext context) {
    return AppTypography.bodyRegular.copyWith(color: getTextColor(context));
  }

  /// Get headline H4 text style
  static TextStyle getHeadlineH4(BuildContext context) {
    return AppTypography.headlineH4.copyWith(color: getTextColor(context));
  }

  /// Get label regular text style
  static TextStyle getLabelRegular(BuildContext context) {
    return AppTypography.labelRegular.copyWith(color: getTextColor(context));
  }

  /// Get label tiny text style
  static TextStyle getLabelTiny(BuildContext context) {
    return AppTypography.labelTiny.copyWith(color: getTextColor(context));
  }

  /// Get micro large text style
  static TextStyle getMicroLarge(BuildContext context) {
    return AppTypography.microLarge.copyWith(color: getTextColor(context));
  }

  /// Get micro medium text style
  static TextStyle getMicroMedium(BuildContext context) {
    return AppTypography.microMedium.copyWith(color: getTextColor(context));
  }

  // ============================================================================
  // SPACING UTILITIES
  // ============================================================================

  /// Get spacing extension from context
  static AppSpacingExtension getSpacing(BuildContext context) {
    return Theme.of(context).extension<AppSpacingExtension>()!;
  }

  /// Get extra small spacing
  static double getSpacingXS(BuildContext context) {
    return getSpacing(context).xs;
  }

  /// Get small spacing
  static double getSpacingSM(BuildContext context) {
    return getSpacing(context).sm;
  }

  /// Get medium spacing
  static double getSpacingMD(BuildContext context) {
    return getSpacing(context).md;
  }

  /// Get large spacing
  static double getSpacingLG(BuildContext context) {
    return getSpacing(context).lg;
  }

  /// Get extra large spacing
  static double getSpacingXL(BuildContext context) {
    return getSpacing(context).xl;
  }

  /// Get extra extra large spacing
  static double getSpacingXXL(BuildContext context) {
    return getSpacing(context).xxl;
  }

  /// Get extra extra extra large spacing
  static double getSpacingXXXL(BuildContext context) {
    return getSpacing(context).xxxl;
  }

  // ============================================================================
  // BORDER RADIUS UTILITIES
  // ============================================================================

  /// Get border radius extension from context
  static AppBorderRadiusExtension getBorderRadius(BuildContext context) {
    return Theme.of(context).extension<AppBorderRadiusExtension>()!;
  }

  /// Get extra small border radius
  static double getBorderRadiusXS(BuildContext context) {
    return getBorderRadius(context).xs;
  }

  /// Get small border radius
  static double getBorderRadiusSM(BuildContext context) {
    return getBorderRadius(context).sm;
  }

  /// Get medium border radius
  static double getBorderRadiusMD(BuildContext context) {
    return getBorderRadius(context).md;
  }

  /// Get large border radius
  static double getBorderRadiusLG(BuildContext context) {
    return getBorderRadius(context).lg;
  }

  /// Get extra large border radius
  static double getBorderRadiusXL(BuildContext context) {
    return getBorderRadius(context).xl;
  }

  /// Get extra extra large border radius
  static double getBorderRadiusXXL(BuildContext context) {
    return getBorderRadius(context).xxl;
  }

  /// Get circular border radius
  static double getBorderRadiusCircular(BuildContext context) {
    return getBorderRadius(context).circular;
  }

  // ============================================================================
  // ELEVATION UTILITIES
  // ============================================================================

  /// Get elevation extension from context
  static AppElevationExtension getElevation(BuildContext context) {
    return Theme.of(context).extension<AppElevationExtension>()!;
  }

  /// Get no elevation
  static double getElevationNone(BuildContext context) {
    return getElevation(context).none;
  }

  /// Get extra small elevation
  static double getElevationXS(BuildContext context) {
    return getElevation(context).xs;
  }

  /// Get small elevation
  static double getElevationSM(BuildContext context) {
    return getElevation(context).sm;
  }

  /// Get medium elevation
  static double getElevationMD(BuildContext context) {
    return getElevation(context).md;
  }

  /// Get large elevation
  static double getElevationLG(BuildContext context) {
    return getElevation(context).lg;
  }

  /// Get extra large elevation
  static double getElevationXL(BuildContext context) {
    return getElevation(context).xl;
  }

  /// Get extra extra large elevation
  static double getElevationXXL(BuildContext context) {
    return getElevation(context).xxl;
  }

  // ============================================================================
  // SHADOW UTILITIES
  // ============================================================================

  /// Get shadow extension from context
  static AppShadowExtension getShadow(BuildContext context) {
    return Theme.of(context).extension<AppShadowExtension>()!;
  }

  /// Get no shadow
  static List<BoxShadow> getShadowNone(BuildContext context) {
    return getShadow(context).none;
  }

  /// Get extra small shadow
  static List<BoxShadow> getShadowXS(BuildContext context) {
    return getShadow(context).xs;
  }

  /// Get small shadow
  static List<BoxShadow> getShadowSM(BuildContext context) {
    return getShadow(context).sm;
  }

  /// Get medium shadow
  static List<BoxShadow> getShadowMD(BuildContext context) {
    return getShadow(context).md;
  }

  /// Get large shadow
  static List<BoxShadow> getShadowLG(BuildContext context) {
    return getShadow(context).lg;
  }

  /// Get extra large shadow
  static List<BoxShadow> getShadowXL(BuildContext context) {
    return getShadow(context).xl;
  }

  /// Get extra extra large shadow
  static List<BoxShadow> getShadowXXL(BuildContext context) {
    return getShadow(context).xxl;
  }

  // ============================================================================
  // ANIMATION UTILITIES
  // ============================================================================

  /// Get animation extension from context
  static AppAnimationExtension getAnimation(BuildContext context) {
    return Theme.of(context).extension<AppAnimationExtension>()!;
  }

  /// Get fast animation duration
  static Duration getAnimationFast(BuildContext context) {
    return getAnimation(context).fast;
  }

  /// Get normal animation duration
  static Duration getAnimationNormal(BuildContext context) {
    return getAnimation(context).normal;
  }

  /// Get slow animation duration
  static Duration getAnimationSlow(BuildContext context) {
    return getAnimation(context).slow;
  }

  /// Get very slow animation duration
  static Duration getAnimationVerySlow(BuildContext context) {
    return getAnimation(context).verySlow;
  }

  /// Get default animation curve
  static Curve getAnimationCurve(BuildContext context) {
    return getAnimation(context).curve;
  }

  /// Get fast animation curve
  static Curve getAnimationCurveFast(BuildContext context) {
    return getAnimation(context).curveFast;
  }

  /// Get slow animation curve
  static Curve getAnimationCurveSlow(BuildContext context) {
    return getAnimation(context).curveSlow;
  }

  // ============================================================================
  // THEME DETECTION UTILITIES
  // ============================================================================

  /// Check if the current theme is dark
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Check if the current theme is light
  static bool isLight(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light;
  }

  /// Get the current brightness
  static Brightness getBrightness(BuildContext context) {
    return Theme.of(context).brightness;
  }

  // ============================================================================
  // CUSTOM TEXT STYLE UTILITIES
  // ============================================================================

  /// Get app title text style
  static TextStyle getAppTitle(BuildContext context) {
    return AppTypography.appTitle.copyWith(color: getTextColor(context));
  }

  /// Get card title text style
  static TextStyle getCardTitle(BuildContext context) {
    return AppTypography.cardTitle.copyWith(color: getTextColor(context));
  }

  /// Get button text style
  static TextStyle getButtonText(BuildContext context) {
    return AppTypography.buttonText.copyWith(color: getTextColor(context));
  }

  /// Get caption text style
  static TextStyle getCaption(BuildContext context) {
    return AppTypography.caption.copyWith(color: getHintTextColor(context));
  }

  /// Get overline text style
  static TextStyle getOverline(BuildContext context) {
    return AppTypography.overline.copyWith(color: getHintTextColor(context));
  }

  /// Get number display text style
  static TextStyle getNumberDisplay(BuildContext context) {
    return AppTypography.numberDisplay.copyWith(color: getTextColor(context));
  }

  /// Get number large text style
  static TextStyle getNumberLarge(BuildContext context) {
    return AppTypography.numberLarge.copyWith(color: getTextColor(context));
  }

  /// Get number medium text style
  static TextStyle getNumberMedium(BuildContext context) {
    return AppTypography.numberMedium.copyWith(color: getTextColor(context));
  }

  /// Get number small text style
  static TextStyle getNumberSmall(BuildContext context) {
    return AppTypography.numberSmall.copyWith(color: getTextColor(context));
  }

  // ============================================================================
  // HELPER METHODS
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

  /// Get a color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  /// Get a color with alpha
  static Color withAlpha(Color color, int alpha) {
    return color.withAlpha(alpha);
  }

  /// Get a color with brightness adjustment
  static Color withBrightness(Color color, double brightness) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + brightness).clamp(0.0, 1.0))
        .toColor();
  }

  /// Get a color with saturation adjustment
  static Color withSaturation(Color color, double saturation) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withSaturation((hsl.saturation + saturation).clamp(0.0, 1.0))
        .toColor();
  }
}
