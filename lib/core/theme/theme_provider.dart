import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'app_theme.dart';

/// Theme Mode Enum
///
/// Defines the available theme modes for the app
enum AppThemeMode { light, dark, system }

/// Theme Provider
///
/// Manages the app's theme state and persistence
/// Provides methods to switch between light, dark, and system themes
class ThemeNotifier extends StateNotifier<AppThemeMode> {
  static const String _themeKey = 'app_theme_mode';

  ThemeNotifier(this._prefs) : super(AppThemeMode.system) {
    _loadTheme();
  }

  final SharedPreferences _prefs;

  /// Load the saved theme from SharedPreferences
  Future<void> _loadTheme() async {
    final themeIndex = _prefs.getInt(_themeKey);
    if (themeIndex != null && themeIndex < AppThemeMode.values.length) {
      state = AppThemeMode.values[themeIndex];
    }
  }

  /// Save the current theme to SharedPreferences
  Future<void> _saveTheme(AppThemeMode theme) async {
    await _prefs.setInt(_themeKey, theme.index);
  }

  /// Set the theme mode
  Future<void> setThemeMode(AppThemeMode theme) async {
    state = theme;
    await _saveTheme(theme);
  }

  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    final newTheme =
        state == AppThemeMode.light ? AppThemeMode.dark : AppThemeMode.light;
    await setThemeMode(newTheme);
  }

  /// Get the current theme mode
  AppThemeMode get currentTheme => state;

  /// Check if the current theme is light
  bool get isLight => state == AppThemeMode.light;

  /// Check if the current theme is dark
  bool get isDark => state == AppThemeMode.dark;

  /// Check if the current theme follows system
  bool get isSystem => state == AppThemeMode.system;
}

/// Theme Provider
///
/// Riverpod provider for the theme notifier
final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) {
  throw UnimplementedError('ThemeProvider must be overridden');
});

/// Theme Provider Override
///
/// This should be used to provide the ThemeNotifier with SharedPreferences
final themeProviderOverride = Provider<ThemeNotifier>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeNotifier(prefs);
});

/// Shared Preferences Provider
///
/// Provides SharedPreferences instance
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferencesProvider must be overridden');
});

/// Theme Data Provider
///
/// Provides the current theme data based on the theme mode
final themeDataProvider = Provider<ThemeData>((ref) {
  final themeMode = ref.watch(themeProvider);
  final brightness = _getBrightness(themeMode);

  return brightness == Brightness.light
      ? AppTheme.lightTheme
      : AppTheme.darkTheme;
});

/// Theme Mode Provider
///
/// Provides the current theme mode as a Flutter ThemeMode
final flutterThemeModeProvider = Provider<ThemeMode>((ref) {
  final appThemeMode = ref.watch(themeProvider);

  switch (appThemeMode) {
    case AppThemeMode.light:
      return ThemeMode.light;
    case AppThemeMode.dark:
      return ThemeMode.dark;
    case AppThemeMode.system:
      return ThemeMode.system;
  }
});

/// Brightness Provider
///
/// Provides the current brightness based on the theme mode
final brightnessProvider = Provider<Brightness>((ref) {
  final themeMode = ref.watch(themeProvider);
  return _getBrightness(themeMode);
});

/// Color Scheme Provider
///
/// Provides the current color scheme based on the theme mode
final colorSchemeProvider = Provider<ColorScheme>((ref) {
  final themeData = ref.watch(themeDataProvider);
  return themeData.colorScheme;
});

/// Text Theme Provider
///
/// Provides the current text theme based on the theme mode
final textThemeProvider = Provider<TextTheme>((ref) {
  final themeData = ref.watch(themeDataProvider);
  return themeData.textTheme;
});

/// Helper function to get brightness from theme mode
Brightness _getBrightness(AppThemeMode themeMode) {
  switch (themeMode) {
    case AppThemeMode.light:
      return Brightness.light;
    case AppThemeMode.dark:
      return Brightness.dark;
    case AppThemeMode.system:
      // In a real app, you would get this from the system
      // For now, we'll default to light
      return Brightness.light;
  }
}

/// Theme Extensions
///
/// Custom theme extensions for app-specific styling
@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    required this.primaryGradient,
    required this.secondaryGradient,
    required this.cardElevation,
    required this.borderRadius,
    required this.spacing,
    required this.shadowColor,
    required this.overlayColor,
  });

  final LinearGradient primaryGradient;
  final LinearGradient secondaryGradient;
  final double cardElevation;
  final double borderRadius;
  final double spacing;
  final Color shadowColor;
  final Color overlayColor;

  @override
  AppThemeExtension copyWith({
    LinearGradient? primaryGradient,
    LinearGradient? secondaryGradient,
    double? cardElevation,
    double? borderRadius,
    double? spacing,
    Color? shadowColor,
    Color? overlayColor,
  }) {
    return AppThemeExtension(
      primaryGradient: primaryGradient ?? this.primaryGradient,
      secondaryGradient: secondaryGradient ?? this.secondaryGradient,
      cardElevation: cardElevation ?? this.cardElevation,
      borderRadius: borderRadius ?? this.borderRadius,
      spacing: spacing ?? this.spacing,
      shadowColor: shadowColor ?? this.shadowColor,
      overlayColor: overlayColor ?? this.overlayColor,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) {
      return this;
    }

    return AppThemeExtension(
      primaryGradient:
          LinearGradient.lerp(primaryGradient, other.primaryGradient, t)!,
      secondaryGradient:
          LinearGradient.lerp(secondaryGradient, other.secondaryGradient, t)!,
      cardElevation: lerpDouble(cardElevation, other.cardElevation, t)!,
      borderRadius: lerpDouble(borderRadius, other.borderRadius, t)!,
      spacing: lerpDouble(spacing, other.spacing, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
      overlayColor: Color.lerp(overlayColor, other.overlayColor, t)!,
    );
  }
}

/// App Theme Extension Provider
///
/// Provides the current app theme extension
final appThemeExtensionProvider = Provider<AppThemeExtension>((ref) {
  final brightness = ref.watch(brightnessProvider);

  if (brightness == Brightness.light) {
    return const AppThemeExtension(
      primaryGradient: LinearGradient(
        colors: [Color(0xFF2D99B6), Color(0xFF01CBEA)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      secondaryGradient: LinearGradient(
        colors: [Color(0xFFFA7319), Color(0xFFE16614)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      cardElevation: 2.0,
      borderRadius: 12.0,
      spacing: 16.0,
      shadowColor: Color(0x1A000000),
      overlayColor: Color(0x1A000000),
    );
  } else {
    return const AppThemeExtension(
      primaryGradient: LinearGradient(
        colors: [Color(0xFF01CBEA), Color(0xFF2D99B6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      secondaryGradient: LinearGradient(
        colors: [Color(0xFFFFA468), Color(0xFFFA7319)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      cardElevation: 4.0,
      borderRadius: 12.0,
      spacing: 16.0,
      shadowColor: Color(0x1AFFFFFF),
      overlayColor: Color(0x1AFFFFFF),
    );
  }
});

/// Theme Utilities
///
/// Utility functions for working with themes
class ThemeUtils {
  /// Get the current theme mode from context
  static AppThemeMode getThemeMode(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.light
        ? AppThemeMode.light
        : AppThemeMode.dark;
  }

  /// Check if the current theme is dark
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Check if the current theme is light
  static bool isLight(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light;
  }

  /// Get the app theme extension from context
  static AppThemeExtension getAppTheme(BuildContext context) {
    return Theme.of(context).extension<AppThemeExtension>()!;
  }

  /// Get the primary color from context
  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  /// Get the secondary color from context
  static Color getSecondaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.secondary;
  }

  /// Get the surface color from context
  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  /// Get the background color from context
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.background;
  }

  /// Get the error color from context
  static Color getErrorColor(BuildContext context) {
    return Theme.of(context).colorScheme.error;
  }

  /// Get the success color from context
  static Color getSuccessColor(BuildContext context) {
    return Theme.of(context).colorScheme.tertiary;
  }

  /// Get the warning color from context
  static Color getWarningColor(BuildContext context) {
    return Theme.of(context).colorScheme.tertiary;
  }

  /// Get the info color from context
  static Color getInfoColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
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
}
