import 'package:flutter/material.dart';
import 'dart:ui';
import 'app_colors.dart';

/// App Theme Extensions
///
/// This file contains custom theme extensions for app-specific styling
/// that extends beyond the standard Material Design 3 theme system.
///
/// Extensions include:
/// - Custom color schemes for specific use cases
/// - App-specific component styles
/// - Custom spacing and sizing
/// - Special effects and animations
/// - Brand-specific styling

/// App Color Scheme Extension
///
/// Extends the standard ColorScheme with app-specific colors
@immutable
class AppColorSchemeExtension extends ThemeExtension<AppColorSchemeExtension> {
  const AppColorSchemeExtension({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.info,
    required this.onInfo,
    required this.infoContainer,
    required this.onInfoContainer,
    required this.surfaceContainer,
    required this.onSurfaceContainer,
    required this.surfaceContainerHigh,
    required this.onSurfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.onSurfaceContainerHighest,
    required this.surfaceVariant,
    required this.onSurfaceVariant,
    required this.surfaceDim,
    required this.surfaceBright,
    required this.outlineHigh,
    required this.outlineMedium,
    required this.outlineLow,
  });

  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;
  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color onWarningContainer;
  final Color info;
  final Color onInfo;
  final Color infoContainer;
  final Color onInfoContainer;
  final Color surfaceContainer;
  final Color onSurfaceContainer;
  final Color surfaceContainerHigh;
  final Color onSurfaceContainerHigh;
  final Color surfaceContainerHighest;
  final Color onSurfaceContainerHighest;
  final Color surfaceVariant;
  final Color onSurfaceVariant;
  final Color surfaceDim;
  final Color surfaceBright;
  final Color outlineHigh;
  final Color outlineMedium;
  final Color outlineLow;

  @override
  AppColorSchemeExtension copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? info,
    Color? onInfo,
    Color? infoContainer,
    Color? onInfoContainer,
    Color? surfaceContainer,
    Color? onSurfaceContainer,
    Color? surfaceContainerHigh,
    Color? onSurfaceContainerHigh,
    Color? surfaceContainerHighest,
    Color? onSurfaceContainerHighest,
    Color? surfaceVariant,
    Color? onSurfaceVariant,
    Color? surfaceDim,
    Color? surfaceBright,
    Color? outlineHigh,
    Color? outlineMedium,
    Color? outlineLow,
  }) {
    return AppColorSchemeExtension(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      infoContainer: infoContainer ?? this.infoContainer,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      onSurfaceContainer: onSurfaceContainer ?? this.onSurfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh ?? this.surfaceContainerHigh,
      onSurfaceContainerHigh:
          onSurfaceContainerHigh ?? this.onSurfaceContainerHigh,
      surfaceContainerHighest:
          surfaceContainerHighest ?? this.surfaceContainerHighest,
      onSurfaceContainerHighest:
          onSurfaceContainerHighest ?? this.onSurfaceContainerHighest,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      surfaceDim: surfaceDim ?? this.surfaceDim,
      surfaceBright: surfaceBright ?? this.surfaceBright,
      outlineHigh: outlineHigh ?? this.outlineHigh,
      outlineMedium: outlineMedium ?? this.outlineMedium,
      outlineLow: outlineLow ?? this.outlineLow,
    );
  }

  @override
  AppColorSchemeExtension lerp(
    ThemeExtension<AppColorSchemeExtension>? other,
    double t,
  ) {
    if (other is! AppColorSchemeExtension) {
      return this;
    }

    return AppColorSchemeExtension(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer:
          Color.lerp(successContainer, other.successContainer, t)!,
      onSuccessContainer:
          Color.lerp(onSuccessContainer, other.onSuccessContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningContainer:
          Color.lerp(warningContainer, other.warningContainer, t)!,
      onWarningContainer:
          Color.lerp(onWarningContainer, other.onWarningContainer, t)!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      onInfoContainer: Color.lerp(onInfoContainer, other.onInfoContainer, t)!,
      surfaceContainer:
          Color.lerp(surfaceContainer, other.surfaceContainer, t)!,
      onSurfaceContainer:
          Color.lerp(onSurfaceContainer, other.onSurfaceContainer, t)!,
      surfaceContainerHigh:
          Color.lerp(surfaceContainerHigh, other.surfaceContainerHigh, t)!,
      onSurfaceContainerHigh:
          Color.lerp(onSurfaceContainerHigh, other.onSurfaceContainerHigh, t)!,
      surfaceContainerHighest:
          Color.lerp(
            surfaceContainerHighest,
            other.surfaceContainerHighest,
            t,
          )!,
      onSurfaceContainerHighest:
          Color.lerp(
            onSurfaceContainerHighest,
            other.onSurfaceContainerHighest,
            t,
          )!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      onSurfaceVariant:
          Color.lerp(onSurfaceVariant, other.onSurfaceVariant, t)!,
      surfaceDim: Color.lerp(surfaceDim, other.surfaceDim, t)!,
      surfaceBright: Color.lerp(surfaceBright, other.surfaceBright, t)!,
      outlineHigh: Color.lerp(outlineHigh, other.outlineHigh, t)!,
      outlineMedium: Color.lerp(outlineMedium, other.outlineMedium, t)!,
      outlineLow: Color.lerp(outlineLow, other.outlineLow, t)!,
    );
  }
}

/// App Spacing Extension
///
/// Defines consistent spacing values throughout the app
@immutable
class AppSpacingExtension extends ThemeExtension<AppSpacingExtension> {
  const AppSpacingExtension({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
    required this.xxxl,
  });

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
  final double xxxl;

  @override
  AppSpacingExtension copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
    double? xxxl,
  }) {
    return AppSpacingExtension(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
      xxxl: xxxl ?? this.xxxl,
    );
  }

  @override
  AppSpacingExtension lerp(
    ThemeExtension<AppSpacingExtension>? other,
    double t,
  ) {
    if (other is! AppSpacingExtension) {
      return this;
    }

    return AppSpacingExtension(
      xs: lerpDouble(xs, other.xs, t)!,
      sm: lerpDouble(sm, other.sm, t)!,
      md: lerpDouble(md, other.md, t)!,
      lg: lerpDouble(lg, other.lg, t)!,
      xl: lerpDouble(xl, other.xl, t)!,
      xxl: lerpDouble(xxl, other.xxl, t)!,
      xxxl: lerpDouble(xxxl, other.xxxl, t)!,
    );
  }
}

/// App Border Radius Extension
///
/// Defines consistent border radius values throughout the app
@immutable
class AppBorderRadiusExtension
    extends ThemeExtension<AppBorderRadiusExtension> {
  const AppBorderRadiusExtension({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
    required this.circular,
  });

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
  final double circular;

  @override
  AppBorderRadiusExtension copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
    double? circular,
  }) {
    return AppBorderRadiusExtension(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
      circular: circular ?? this.circular,
    );
  }

  @override
  AppBorderRadiusExtension lerp(
    ThemeExtension<AppBorderRadiusExtension>? other,
    double t,
  ) {
    if (other is! AppBorderRadiusExtension) {
      return this;
    }

    return AppBorderRadiusExtension(
      xs: lerpDouble(xs, other.xs, t)!,
      sm: lerpDouble(sm, other.sm, t)!,
      md: lerpDouble(md, other.md, t)!,
      lg: lerpDouble(lg, other.lg, t)!,
      xl: lerpDouble(xl, other.xl, t)!,
      xxl: lerpDouble(xxl, other.xxl, t)!,
      circular: lerpDouble(circular, other.circular, t)!,
    );
  }
}

/// App Elevation Extension
///
/// Defines consistent elevation values throughout the app
@immutable
class AppElevationExtension extends ThemeExtension<AppElevationExtension> {
  const AppElevationExtension({
    required this.none,
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
  });

  final double none;
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;

  @override
  AppElevationExtension copyWith({
    double? none,
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
  }) {
    return AppElevationExtension(
      none: none ?? this.none,
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
    );
  }

  @override
  AppElevationExtension lerp(
    ThemeExtension<AppElevationExtension>? other,
    double t,
  ) {
    if (other is! AppElevationExtension) {
      return this;
    }

    return AppElevationExtension(
      none: lerpDouble(none, other.none, t)!,
      xs: lerpDouble(xs, other.xs, t)!,
      sm: lerpDouble(sm, other.sm, t)!,
      md: lerpDouble(md, other.md, t)!,
      lg: lerpDouble(lg, other.lg, t)!,
      xl: lerpDouble(xl, other.xl, t)!,
      xxl: lerpDouble(xxl, other.xxl, t)!,
    );
  }
}

/// App Shadow Extension
///
/// Defines consistent shadow values throughout the app
@immutable
class AppShadowExtension extends ThemeExtension<AppShadowExtension> {
  const AppShadowExtension({
    required this.none,
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
  });

  final List<BoxShadow> none;
  final List<BoxShadow> xs;
  final List<BoxShadow> sm;
  final List<BoxShadow> md;
  final List<BoxShadow> lg;
  final List<BoxShadow> xl;
  final List<BoxShadow> xxl;

  @override
  AppShadowExtension copyWith({
    List<BoxShadow>? none,
    List<BoxShadow>? xs,
    List<BoxShadow>? sm,
    List<BoxShadow>? md,
    List<BoxShadow>? lg,
    List<BoxShadow>? xl,
    List<BoxShadow>? xxl,
  }) {
    return AppShadowExtension(
      none: none ?? this.none,
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
    );
  }

  @override
  AppShadowExtension lerp(ThemeExtension<AppShadowExtension>? other, double t) {
    if (other is! AppShadowExtension) {
      return this;
    }

    return AppShadowExtension(
      none: _lerpBoxShadowList(none, other.none, t),
      xs: _lerpBoxShadowList(xs, other.xs, t),
      sm: _lerpBoxShadowList(sm, other.sm, t),
      md: _lerpBoxShadowList(md, other.md, t),
      lg: _lerpBoxShadowList(lg, other.lg, t),
      xl: _lerpBoxShadowList(xl, other.xl, t),
      xxl: _lerpBoxShadowList(xxl, other.xxl, t),
    );
  }

  List<BoxShadow> _lerpBoxShadowList(
    List<BoxShadow> a,
    List<BoxShadow> b,
    double t,
  ) {
    if (a.length != b.length) {
      return t < 0.5 ? a : b;
    }

    return List.generate(a.length, (index) {
      final shadowA = a[index];
      final shadowB = b[index];

      return BoxShadow(
        color: Color.lerp(shadowA.color, shadowB.color, t)!,
        offset: Offset.lerp(shadowA.offset, shadowB.offset, t)!,
        blurRadius: lerpDouble(shadowA.blurRadius, shadowB.blurRadius, t)!,
        spreadRadius:
            lerpDouble(shadowA.spreadRadius, shadowB.spreadRadius, t)!,
      );
    });
  }
}

/// App Animation Extension
///
/// Defines consistent animation durations and curves throughout the app
@immutable
class AppAnimationExtension extends ThemeExtension<AppAnimationExtension> {
  const AppAnimationExtension({
    required this.fast,
    required this.normal,
    required this.slow,
    required this.verySlow,
    required this.curve,
    required this.curveFast,
    required this.curveSlow,
  });

  final Duration fast;
  final Duration normal;
  final Duration slow;
  final Duration verySlow;
  final Curve curve;
  final Curve curveFast;
  final Curve curveSlow;

  @override
  AppAnimationExtension copyWith({
    Duration? fast,
    Duration? normal,
    Duration? slow,
    Duration? verySlow,
    Curve? curve,
    Curve? curveFast,
    Curve? curveSlow,
  }) {
    return AppAnimationExtension(
      fast: fast ?? this.fast,
      normal: normal ?? this.normal,
      slow: slow ?? this.slow,
      verySlow: verySlow ?? this.verySlow,
      curve: curve ?? this.curve,
      curveFast: curveFast ?? this.curveFast,
      curveSlow: curveSlow ?? this.curveSlow,
    );
  }

  @override
  AppAnimationExtension lerp(
    ThemeExtension<AppAnimationExtension>? other,
    double t,
  ) {
    if (other is! AppAnimationExtension) {
      return this;
    }

    return AppAnimationExtension(
      fast: Duration(
        milliseconds:
            (fast.inMilliseconds +
                    (other.fast.inMilliseconds - fast.inMilliseconds) * t)
                .round(),
      ),
      normal: Duration(
        milliseconds:
            (normal.inMilliseconds +
                    (other.normal.inMilliseconds - normal.inMilliseconds) * t)
                .round(),
      ),
      slow: Duration(
        milliseconds:
            (slow.inMilliseconds +
                    (other.slow.inMilliseconds - slow.inMilliseconds) * t)
                .round(),
      ),
      verySlow: Duration(
        milliseconds:
            (verySlow.inMilliseconds +
                    (other.verySlow.inMilliseconds - verySlow.inMilliseconds) *
                        t)
                .round(),
      ),
      curve: t < 0.5 ? curve : other.curve,
      curveFast: t < 0.5 ? curveFast : other.curveFast,
      curveSlow: t < 0.5 ? curveSlow : other.curveSlow,
    );
  }
}

/// App Theme Extensions Factory
///
/// Factory class to create theme extensions for light and dark themes
class AppThemeExtensionsFactory {
  /// Create light theme extensions
  static Map<Type, ThemeExtension> createLightExtensions() {
    return {
      AppColorSchemeExtension: const AppColorSchemeExtension(
        success: AppColors.success500,
        onSuccess: AppColors.neutral0,
        successContainer: AppColors.success100,
        onSuccessContainer: AppColors.success900,
        warning: AppColors.warning500,
        onWarning: AppColors.neutral0,
        warningContainer: AppColors.warning100,
        onWarningContainer: AppColors.warning900,
        info: AppColors.info500,
        onInfo: AppColors.neutral0,
        infoContainer: AppColors.info100,
        onInfoContainer: AppColors.info900,
        surfaceContainer: AppColors.neutral50,
        onSurfaceContainer: AppColors.neutral900,
        surfaceContainerHigh: AppColors.neutral100,
        onSurfaceContainerHigh: AppColors.neutral900,
        surfaceContainerHighest: AppColors.neutral200,
        onSurfaceContainerHighest: AppColors.neutral900,
        surfaceVariant: AppColors.neutral100,
        onSurfaceVariant: AppColors.neutral700,
        surfaceDim: AppColors.neutral100,
        surfaceBright: AppColors.neutral0,
        outlineHigh: AppColors.neutral400,
        outlineMedium: AppColors.neutral400,
        outlineLow: AppColors.neutral200,
      ),
      AppSpacingExtension: const AppSpacingExtension(
        xs: 4.0,
        sm: 8.0,
        md: 16.0,
        lg: 24.0,
        xl: 32.0,
        xxl: 56.0,
        xxxl: 64.0,
      ),
      AppBorderRadiusExtension: const AppBorderRadiusExtension(
        xs: 4.0,
        sm: 8.0,
        md: 12.0,
        lg: 16.0,
        xl: 20.0,
        xxl: 24.0,
        circular: 50.0,
      ),
      AppElevationExtension: const AppElevationExtension(
        none: 0.0,
        xs: 1.0,
        sm: 2.0,
        md: 4.0,
        lg: 8.0,
        xl: 12.0,
        xxl: 16.0,
      ),
      AppShadowExtension: AppShadowExtension(
        none: [],
        xs: [
          BoxShadow(
            color: AppColors.neutral950.withOpacity(0.05),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
        sm: [
          BoxShadow(
            color: AppColors.neutral950.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
        md: [
          BoxShadow(
            color: AppColors.neutral950.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        lg: [
          BoxShadow(
            color: AppColors.neutral950.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        xl: [
          BoxShadow(
            color: AppColors.neutral950.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        xxl: [
          BoxShadow(
            color: AppColors.neutral950.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      AppAnimationExtension: const AppAnimationExtension(
        fast: Duration(milliseconds: 150),
        normal: Duration(milliseconds: 300),
        slow: Duration(milliseconds: 500),
        verySlow: Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
        curveFast: Curves.easeOut,
        curveSlow: Curves.easeIn,
      ),
    };
  }

  /// Create dark theme extensions
  static Map<Type, ThemeExtension> createDarkExtensions() {
    return {
      AppColorSchemeExtension: const AppColorSchemeExtension(
        success: AppColors.success400,
        onSuccess: AppColors.success900,
        successContainer: AppColors.success800,
        onSuccessContainer: AppColors.success100,
        warning: AppColors.warning400,
        onWarning: AppColors.warning900,
        warningContainer: AppColors.warning800,
        onWarningContainer: AppColors.warning100,
        info: AppColors.info400,
        onInfo: AppColors.info900,
        infoContainer: AppColors.info800,
        onInfoContainer: AppColors.info100,
        surfaceContainer: AppColors.neutral800,
        onSurfaceContainer: AppColors.neutral100,
        surfaceContainerHigh: AppColors.neutral700,
        onSurfaceContainerHigh: AppColors.neutral100,
        surfaceContainerHighest: AppColors.neutral600,
        onSurfaceContainerHighest: AppColors.neutral100,
        surfaceVariant: AppColors.neutral800,
        onSurfaceVariant: AppColors.neutral400,
        surfaceDim: AppColors.neutral950,
        surfaceBright: AppColors.neutral800,
        outlineHigh: AppColors.neutral400,
        outlineMedium: AppColors.neutral600,
        outlineLow: AppColors.neutral700,
      ),
      AppSpacingExtension: const AppSpacingExtension(
        xs: 4.0,
        sm: 8.0,
        md: 16.0,
        lg: 24.0,
        xl: 32.0,
        xxl: 56.0,
        xxxl: 64.0,
      ),
      AppBorderRadiusExtension: const AppBorderRadiusExtension(
        xs: 4.0,
        sm: 8.0,
        md: 12.0,
        lg: 16.0,
        xl: 20.0,
        xxl: 24.0,
        circular: 50.0,
      ),
      AppElevationExtension: const AppElevationExtension(
        none: 0.0,
        xs: 1.0,
        sm: 2.0,
        md: 4.0,
        lg: 8.0,
        xl: 12.0,
        xxl: 16.0,
      ),
      AppShadowExtension: AppShadowExtension(
        none: [],
        xs: [
          BoxShadow(
            color: AppColors.neutral0.withOpacity(0.05),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
        sm: [
          BoxShadow(
            color: AppColors.neutral0.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
        md: [
          BoxShadow(
            color: AppColors.neutral0.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        lg: [
          BoxShadow(
            color: AppColors.neutral0.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        xl: [
          BoxShadow(
            color: AppColors.neutral0.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        xxl: [
          BoxShadow(
            color: AppColors.neutral0.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      AppAnimationExtension: const AppAnimationExtension(
        fast: Duration(milliseconds: 150),
        normal: Duration(milliseconds: 300),
        slow: Duration(milliseconds: 500),
        verySlow: Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
        curveFast: Curves.easeOut,
        curveSlow: Curves.easeIn,
      ),
    };
  }
}
