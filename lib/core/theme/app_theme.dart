import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// App Theme System
///
/// This class defines the comprehensive theme system for Dayfi
/// following Material Design 3 principles and industry standards.
///
/// Features:
/// - Light and Dark mode support
/// - Material Design 3 color scheme
/// - Custom typography system
/// - Consistent component styling
/// - Accessibility support
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // ============================================================================
  // LIGHT THEME
  // ============================================================================

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Scaffold Background
      scaffoldBackgroundColor: const Color(0xffFEF9F3),

      // Color Scheme
      colorScheme: _lightColorScheme,

      // Typography
      textTheme: _lightTextTheme,

      // App Bar Theme
      appBarTheme: _lightAppBarTheme,

      // Card Theme
      cardTheme: _lightCardTheme,

      // Elevated Button Theme
      elevatedButtonTheme: _lightElevatedButtonTheme,

      // Outlined Button Theme
      outlinedButtonTheme: _lightOutlinedButtonTheme,

      // Text Button Theme
      textButtonTheme: _lightTextButtonTheme,

      // Input Decoration Theme
      inputDecorationTheme: _lightInputDecorationTheme,

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: _lightBottomNavigationBarTheme,

      // Floating Action Button Theme
      floatingActionButtonTheme: _lightFloatingActionButtonTheme,

      // Dialog Theme
      dialogTheme: _lightDialogTheme,

      // Bottom Sheet Theme
      bottomSheetTheme: _lightBottomSheetTheme,

      // Snack Bar Theme
      snackBarTheme: _lightSnackBarTheme,

      // Divider Theme
      dividerTheme: _lightDividerTheme,

      // Icon Theme
      iconTheme: _lightIconTheme,

      // Primary Icon Theme
      primaryIconTheme: _lightPrimaryIconTheme,

      // Switch Theme
      switchTheme: _lightSwitchTheme,

      // Checkbox Theme
      checkboxTheme: _lightCheckboxTheme,

      // Radio Theme
      radioTheme: _lightRadioTheme,

      // Slider Theme
      sliderTheme: _lightSliderTheme,

      // Tab Bar Theme
      tabBarTheme: _lightTabBarTheme,

      // Chip Theme
      chipTheme: _lightChipTheme,

      // Progress Indicator Theme
      progressIndicatorTheme: _lightProgressIndicatorTheme,

      // Tooltip Theme
      tooltipTheme: _lightTooltipTheme,

      // Popup Menu Theme
      popupMenuTheme: _lightPopupMenuTheme,

      // List Tile Theme
      listTileTheme: _lightListTileTheme,

      // Drawer Theme
      drawerTheme: _lightDrawerTheme,

      // Navigation Bar Theme
      navigationBarTheme: _lightNavigationBarTheme,

      // Navigation Rail Theme
      navigationRailTheme: _lightNavigationRailTheme,

      // Badge Theme
      badgeTheme: _lightBadgeTheme,

      // Segmented Button Theme
      segmentedButtonTheme: _lightSegmentedButtonTheme,

      // Date Picker Theme
      datePickerTheme: _lightDatePickerTheme,

      // Time Picker Theme
      timePickerTheme: _lightTimePickerTheme,

      // Expansion Tile Theme
      expansionTileTheme: _lightExpansionTileTheme,

      // Data Table Theme
      dataTableTheme: _lightDataTableTheme,

      // Menu Bar Theme
      menuBarTheme: _lightMenuBarTheme,

      // Menu Button Theme
      menuButtonTheme: _lightMenuButtonTheme,

      // Menu Theme
      menuTheme: _lightMenuTheme,

      // Search Bar Theme
      searchBarTheme: _lightSearchBarTheme,

      // Search View Theme
      searchViewTheme: _lightSearchViewTheme,

      // Action Icon Theme
      actionIconTheme: _lightActionIconTheme,

      // Filled Button Theme
      filledButtonTheme: _lightFilledButtonTheme,

      // Icon Button Theme
      iconButtonTheme: _lightIconButtonTheme,

      // Toggle Buttons Theme
      toggleButtonsTheme: _lightToggleButtonsTheme,

      // Text Selection Theme
      textSelectionTheme: _lightTextSelectionTheme,

      // Scrollbar Theme
      scrollbarTheme: _lightScrollbarTheme,

      // Page Transitions Theme
      pageTransitionsTheme: _lightPageTransitionsTheme,

      // Visual Density
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // Material Tap Target Size
      materialTapTargetSize: MaterialTapTargetSize.padded,

      // Splash Factory
      splashFactory: InkRipple.splashFactory,

      // Platform
      platform: TargetPlatform.iOS,
    );
  }

  // ============================================================================
  // DARK THEME
  // ============================================================================

  /// Dark theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Scaffold Background
      scaffoldBackgroundColor: AppColors.neutral950,

      // Color Scheme
      colorScheme: _darkColorScheme,

      // Typography
      textTheme: _darkTextTheme,

      // App Bar Theme
      appBarTheme: _darkAppBarTheme,

      // Card Theme
      cardTheme: _darkCardTheme,

      // Elevated Button Theme
      elevatedButtonTheme: _darkElevatedButtonTheme,

      // Outlined Button Theme
      outlinedButtonTheme: _darkOutlinedButtonTheme,

      // Text Button Theme
      textButtonTheme: _darkTextButtonTheme,

      // Input Decoration Theme
      inputDecorationTheme: _darkInputDecorationTheme,

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: _darkBottomNavigationBarTheme,

      // Floating Action Button Theme
      floatingActionButtonTheme: _darkFloatingActionButtonTheme,

      // Dialog Theme
      dialogTheme: _darkDialogTheme,

      // Bottom Sheet Theme
      bottomSheetTheme: _darkBottomSheetTheme,

      // Snack Bar Theme
      snackBarTheme: _darkSnackBarTheme,

      // Divider Theme
      dividerTheme: _darkDividerTheme,

      // Icon Theme
      iconTheme: _darkIconTheme,

      // Primary Icon Theme
      primaryIconTheme: _darkPrimaryIconTheme,

      // Switch Theme
      switchTheme: _darkSwitchTheme,

      // Checkbox Theme
      checkboxTheme: _darkCheckboxTheme,

      // Radio Theme
      radioTheme: _darkRadioTheme,

      // Slider Theme
      sliderTheme: _darkSliderTheme,

      // Tab Bar Theme
      tabBarTheme: _darkTabBarTheme,

      // Chip Theme
      chipTheme: _darkChipTheme,

      // Progress Indicator Theme
      progressIndicatorTheme: _darkProgressIndicatorTheme,

      // Tooltip Theme
      tooltipTheme: _darkTooltipTheme,

      // Popup Menu Theme
      popupMenuTheme: _darkPopupMenuTheme,

      // List Tile Theme
      listTileTheme: _darkListTileTheme,

      // Drawer Theme
      drawerTheme: _darkDrawerTheme,

      // Navigation Bar Theme
      navigationBarTheme: _darkNavigationBarTheme,

      // Navigation Rail Theme
      navigationRailTheme: _darkNavigationRailTheme,

      // Badge Theme
      badgeTheme: _darkBadgeTheme,

      // Segmented Button Theme
      segmentedButtonTheme: _darkSegmentedButtonTheme,

      // Date Picker Theme
      datePickerTheme: _darkDatePickerTheme,

      // Time Picker Theme
      timePickerTheme: _darkTimePickerTheme,

      // Expansion Tile Theme
      expansionTileTheme: _darkExpansionTileTheme,

      // Data Table Theme
      dataTableTheme: _darkDataTableTheme,

      // Menu Bar Theme
      menuBarTheme: _darkMenuBarTheme,

      // Menu Button Theme
      menuButtonTheme: _darkMenuButtonTheme,

      // Menu Theme
      menuTheme: _darkMenuTheme,

      // Search Bar Theme
      searchBarTheme: _darkSearchBarTheme,

      // Search View Theme
      searchViewTheme: _darkSearchViewTheme,

      // Action Icon Theme
      actionIconTheme: _darkActionIconTheme,

      // Filled Button Theme
      filledButtonTheme: _darkFilledButtonTheme,

      // Icon Button Theme
      iconButtonTheme: _darkIconButtonTheme,

      // Toggle Buttons Theme
      toggleButtonsTheme: _darkToggleButtonsTheme,

      // Text Selection Theme
      textSelectionTheme: _darkTextSelectionTheme,

      // Scrollbar Theme
      scrollbarTheme: _darkScrollbarTheme,

      // Page Transitions Theme
      pageTransitionsTheme: _darkPageTransitionsTheme,

      // Visual Density
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // Material Tap Target Size
      materialTapTargetSize: MaterialTapTargetSize.padded,

      // Splash Factory
      splashFactory: InkRipple.splashFactory,

      // Platform
      platform: TargetPlatform.iOS,
    );
  }

  // ============================================================================
  // COLOR SCHEMES
  // ============================================================================

  /// Light color scheme
  static ColorScheme get _lightColorScheme {
    return const ColorScheme.light(
      // Primary colors (Dayfi Blue)
      primary: AppColors.primary500,
      onPrimary: AppColors.neutral0,
      primaryContainer: AppColors.primary100,
      onPrimaryContainer: AppColors.primary900,

      onSecondary: AppColors.neutral0,

      // Tertiary colors (using teal as accent)
      tertiary: AppColors.teal500,
      onTertiary: AppColors.neutral0,
      tertiaryContainer: AppColors.teal100,
      onTertiaryContainer: AppColors.teal900,

      // Error colors
      error: AppColors.error500,
      onError: AppColors.neutral0,
      errorContainer: AppColors.error100,
      onErrorContainer: AppColors.error900,

      // Surface colors
      surface: AppColors.surfaceLight,
      onSurface: AppColors.neutral900,
      surfaceContainerHighest: AppColors.surfaceContainerHighestLight,
      onSurfaceVariant: AppColors.neutral700,
      surfaceVariant: AppColors.surfaceVariantLight,

      // Outline colors
      outline: AppColors.outlineLight,
      outlineVariant: AppColors.outlineVariantLight,

      // Background colors
      background: AppColors.neutral0,
      onBackground: AppColors.neutral900,

      // Shadow
      shadow: AppColors.neutral950,
      scrim: AppColors.neutral950,

      // Inverse colors
      inverseSurface: AppColors.neutral100,
      onInverseSurface: AppColors.neutral800,
      inversePrimary: AppColors.primary200,
    );
  }

  /// Dark color scheme
  static ColorScheme get _darkColorScheme {
    return const ColorScheme.dark(
      // Primary colors (Dayfi Blue)
      primary: AppColors.primary400,
      onPrimary: AppColors.primary900,
      primaryContainer: AppColors.primary800,
      onPrimaryContainer: AppColors.primary100,

      // Tertiary colors (using teal as accent)
      tertiary: AppColors.teal400,
      onTertiary: AppColors.teal900,
      tertiaryContainer: AppColors.teal800,
      onTertiaryContainer: AppColors.teal100,

      // Error colors
      error: AppColors.error400,
      onError: AppColors.error900,
      errorContainer: AppColors.error800,
      onErrorContainer: AppColors.error100,

      // Surface colors
      surface: AppColors.surfaceDark,
      onSurface: AppColors.neutral100,
      surfaceContainerHighest: AppColors.surfaceContainerHighestDark,
      onSurfaceVariant: AppColors.neutral300,
      surfaceVariant: AppColors.surfaceVariantDark,

      // Outline colors
      outline: AppColors.outlineDark,
      outlineVariant: AppColors.outlineVariantDark,

      // Background colors
      background: AppColors.neutral950,
      onBackground: AppColors.neutral100,

      // Shadow
      shadow: AppColors.neutral0,
      scrim: AppColors.neutral0,

      // Inverse colors
      inverseSurface: AppColors.neutral800,
      onInverseSurface: AppColors.neutral200,
      inversePrimary: AppColors.primary600,
    );
  }

  // ============================================================================
  // TEXT THEMES
  // ============================================================================

  /// Light text theme
  static TextTheme get _lightTextTheme {
    return TextTheme(
      // Display styles
      displayLarge: AppTypography.displayLarge.copyWith(
        color: AppColors.neutral900,
      ),
      displayMedium: AppTypography.displayMedium.copyWith(
        color: AppColors.neutral900,
      ),
      displaySmall: AppTypography.displaySmall.copyWith(
        color: AppColors.neutral900,
      ),

      // Headline styles
      headlineLarge: AppTypography.headlineLarge.copyWith(
        color: AppColors.neutral900,
      ),
      headlineMedium: AppTypography.headlineMedium.copyWith(
        color: AppColors.neutral900,
      ),
      headlineSmall: AppTypography.headlineSmall.copyWith(
        color: AppColors.neutral900,
      ),

      // Title styles
      titleLarge: AppTypography.titleLarge.copyWith(
        color: AppColors.neutral900,
      ),
      titleMedium: AppTypography.titleMedium.copyWith(
        color: AppColors.neutral900,
      ),
      titleSmall: AppTypography.titleSmall.copyWith(
        color: AppColors.neutral800,
      ),

      // Body styles
      bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.neutral800),
      bodyMedium: AppTypography.bodyMedium.copyWith(
        color: AppColors.neutral800,
      ),
      bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.neutral700),

      // Label styles
      labelLarge: AppTypography.labelLarge.copyWith(
        color: AppColors.neutral800,
      ),
      labelMedium: AppTypography.labelMedium.copyWith(
        color: AppColors.neutral700,
      ),
      labelSmall: AppTypography.labelSmall.copyWith(
        color: AppColors.neutral600,
      ),
    );
  }

  /// Dark text theme
  static TextTheme get _darkTextTheme {
    return TextTheme(
      // Display styles
      displayLarge: AppTypography.displayLarge.copyWith(
        color: AppColors.neutral100,
      ),
      displayMedium: AppTypography.displayMedium.copyWith(
        color: AppColors.neutral100,
      ),
      displaySmall: AppTypography.displaySmall.copyWith(
        color: AppColors.neutral100,
      ),

      // Headline styles
      headlineLarge: AppTypography.headlineLarge.copyWith(
        color: AppColors.neutral100,
      ),
      headlineMedium: AppTypography.headlineMedium.copyWith(
        color: AppColors.neutral100,
      ),
      headlineSmall: AppTypography.headlineSmall.copyWith(
        color: AppColors.neutral100,
      ),

      // Title styles
      titleLarge: AppTypography.titleLarge.copyWith(
        color: AppColors.neutral100,
      ),
      titleMedium: AppTypography.titleMedium.copyWith(
        color: AppColors.neutral100,
      ),
      titleSmall: AppTypography.titleSmall.copyWith(
        color: AppColors.neutral200,
      ),

      // Body styles
      bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.neutral200),
      bodyMedium: AppTypography.bodyMedium.copyWith(
        color: AppColors.neutral200,
      ),
      bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.neutral300),

      // Label styles
      labelLarge: AppTypography.labelLarge.copyWith(
        color: AppColors.neutral200,
      ),
      labelMedium: AppTypography.labelMedium.copyWith(
        color: AppColors.neutral300,
      ),
      labelSmall: AppTypography.labelSmall.copyWith(
        color: AppColors.neutral400,
      ),
    );
  }

  // ============================================================================
  // COMPONENT THEMES - LIGHT
  // ============================================================================

  static AppBarTheme get _lightAppBarTheme {
    return const AppBarTheme(
      backgroundColor: Color(0xffFEF9F3),
      foregroundColor: AppColors.neutral900,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: AppColors.neutral900,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    );
  }

  static CardThemeData get _lightCardTheme {
    return CardThemeData(
      color: AppColors.surfaceLight,
      shadowColor: AppColors.neutral950.withOpacity(0.1),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(8),
    );
  }

  static ElevatedButtonThemeData get _lightElevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary500,
        foregroundColor: AppColors.neutral0,
        elevation: 2,
        shadowColor: AppColors.primary500.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: AppTypography.buttonText,
      ),
    );
  }

  static OutlinedButtonThemeData get _lightOutlinedButtonTheme {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary500,
        side: const BorderSide(color: AppColors.primary500, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: AppTypography.buttonText,
      ),
    );
  }

  static TextButtonThemeData get _lightTextButtonTheme {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary500,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: AppTypography.buttonText,
      ),
    );
  }

  static InputDecorationTheme get _lightInputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.neutral50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.outlineLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.outlineLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary500, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error500),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error500, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      labelStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.neutral600,
      ),
      hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.neutral500),
      errorStyle: AppTypography.bodySmall.copyWith(color: AppColors.error500),
    );
  }

  // ============================================================================
  // COMPONENT THEMES - DARK
  // ============================================================================

  static AppBarTheme get _darkAppBarTheme {
    return const AppBarTheme(
      backgroundColor: AppColors.neutral950,
      foregroundColor: AppColors.neutral100,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: AppColors.neutral100,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    );
  }

  static CardThemeData get _darkCardTheme {
    return CardThemeData(
      color: AppColors.surfaceDark,
      shadowColor: AppColors.neutral0.withOpacity(0.1),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(8),
    );
  }

  static ElevatedButtonThemeData get _darkElevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary400,
        foregroundColor: AppColors.primary900,
        elevation: 2,
        shadowColor: AppColors.primary400.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: AppTypography.buttonText,
      ),
    );
  }

  static OutlinedButtonThemeData get _darkOutlinedButtonTheme {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary400,
        side: const BorderSide(color: AppColors.primary400, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: AppTypography.buttonText,
      ),
    );
  }

  static TextButtonThemeData get _darkTextButtonTheme {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary400,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: AppTypography.buttonText,
      ),
    );
  }

  static InputDecorationTheme get _darkInputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.neutral800,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.outlineDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.outlineDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary400, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error400),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error400, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      labelStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.neutral400,
      ),
      hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.neutral500),
      errorStyle: AppTypography.bodySmall.copyWith(color: AppColors.error400),
    );
  }

  // ============================================================================
  // ADDITIONAL COMPONENT THEMES (Simplified for brevity)
  // ============================================================================

  // Light theme components
  static BottomNavigationBarThemeData get _lightBottomNavigationBarTheme =>
      const BottomNavigationBarThemeData();
  static FloatingActionButtonThemeData get _lightFloatingActionButtonTheme =>
      const FloatingActionButtonThemeData();
  static DialogThemeData get _lightDialogTheme => DialogThemeData(
        backgroundColor: AppColors.neutral0,
      );
  static BottomSheetThemeData get _lightBottomSheetTheme =>
      BottomSheetThemeData(
        backgroundColor: AppColors.neutral0,
      );
  static SnackBarThemeData get _lightSnackBarTheme => const SnackBarThemeData();
  static DividerThemeData get _lightDividerTheme => const DividerThemeData();
  static IconThemeData get _lightIconTheme => const IconThemeData();
  static IconThemeData get _lightPrimaryIconTheme => const IconThemeData();
  static SwitchThemeData get _lightSwitchTheme => const SwitchThemeData();
  static CheckboxThemeData get _lightCheckboxTheme => const CheckboxThemeData();
  static RadioThemeData get _lightRadioTheme => const RadioThemeData();
  static SliderThemeData get _lightSliderTheme => const SliderThemeData();
  static TabBarThemeData get _lightTabBarTheme => const TabBarThemeData();
  static ChipThemeData get _lightChipTheme => const ChipThemeData();
  static ProgressIndicatorThemeData get _lightProgressIndicatorTheme =>
      const ProgressIndicatorThemeData();
  static TooltipThemeData get _lightTooltipTheme => const TooltipThemeData();
  static PopupMenuThemeData get _lightPopupMenuTheme =>
      const PopupMenuThemeData();
  static ListTileThemeData get _lightListTileTheme => const ListTileThemeData();
  static DrawerThemeData get _lightDrawerTheme => const DrawerThemeData();
  static NavigationBarThemeData get _lightNavigationBarTheme =>
      const NavigationBarThemeData();
  static NavigationRailThemeData get _lightNavigationRailTheme =>
      const NavigationRailThemeData();
  static BadgeThemeData get _lightBadgeTheme => const BadgeThemeData();
  static SegmentedButtonThemeData get _lightSegmentedButtonTheme =>
      const SegmentedButtonThemeData();
  static DatePickerThemeData get _lightDatePickerTheme =>
      const DatePickerThemeData();
  static TimePickerThemeData get _lightTimePickerTheme =>
      const TimePickerThemeData();
  static ExpansionTileThemeData get _lightExpansionTileTheme =>
      const ExpansionTileThemeData();
  static DataTableThemeData get _lightDataTableTheme =>
      const DataTableThemeData();
  static MenuBarThemeData get _lightMenuBarTheme => const MenuBarThemeData();
  static MenuButtonThemeData get _lightMenuButtonTheme =>
      const MenuButtonThemeData();
  static MenuThemeData get _lightMenuTheme => const MenuThemeData();
  static SearchBarThemeData get _lightSearchBarTheme =>
      const SearchBarThemeData();
  static SearchViewThemeData get _lightSearchViewTheme =>
      const SearchViewThemeData();
  static ActionIconThemeData get _lightActionIconTheme =>
      const ActionIconThemeData();
  static FilledButtonThemeData get _lightFilledButtonTheme =>
      const FilledButtonThemeData();
  static IconButtonThemeData get _lightIconButtonTheme =>
      const IconButtonThemeData();
  static ToggleButtonsThemeData get _lightToggleButtonsTheme =>
      const ToggleButtonsThemeData();
  static TextSelectionThemeData get _lightTextSelectionTheme =>
      const TextSelectionThemeData();
  static ScrollbarThemeData get _lightScrollbarTheme =>
      const ScrollbarThemeData();
  static PageTransitionsTheme get _lightPageTransitionsTheme =>
      const PageTransitionsTheme();

  // Dark theme components
  static BottomNavigationBarThemeData get _darkBottomNavigationBarTheme =>
      const BottomNavigationBarThemeData();
  static FloatingActionButtonThemeData get _darkFloatingActionButtonTheme =>
      const FloatingActionButtonThemeData();
  static DialogThemeData get _darkDialogTheme => DialogThemeData(
        backgroundColor: AppColors.surfaceDark,
      );
  static BottomSheetThemeData get _darkBottomSheetTheme =>
      BottomSheetThemeData(
        backgroundColor: AppColors.surfaceDark,
      );
  static SnackBarThemeData get _darkSnackBarTheme => const SnackBarThemeData();
  static DividerThemeData get _darkDividerTheme => const DividerThemeData();
  static IconThemeData get _darkIconTheme => const IconThemeData();
  static IconThemeData get _darkPrimaryIconTheme => const IconThemeData();
  static SwitchThemeData get _darkSwitchTheme => const SwitchThemeData();
  static CheckboxThemeData get _darkCheckboxTheme => const CheckboxThemeData();
  static RadioThemeData get _darkRadioTheme => const RadioThemeData();
  static SliderThemeData get _darkSliderTheme => const SliderThemeData();
  static TabBarThemeData get _darkTabBarTheme => const TabBarThemeData();
  static ChipThemeData get _darkChipTheme => const ChipThemeData();
  static ProgressIndicatorThemeData get _darkProgressIndicatorTheme =>
      const ProgressIndicatorThemeData();
  static TooltipThemeData get _darkTooltipTheme => const TooltipThemeData();
  static PopupMenuThemeData get _darkPopupMenuTheme =>
      const PopupMenuThemeData();
  static ListTileThemeData get _darkListTileTheme => const ListTileThemeData();
  static DrawerThemeData get _darkDrawerTheme => const DrawerThemeData();
  static NavigationBarThemeData get _darkNavigationBarTheme =>
      const NavigationBarThemeData();
  static NavigationRailThemeData get _darkNavigationRailTheme =>
      const NavigationRailThemeData();
  static BadgeThemeData get _darkBadgeTheme => const BadgeThemeData();
  static SegmentedButtonThemeData get _darkSegmentedButtonTheme =>
      const SegmentedButtonThemeData();
  static DatePickerThemeData get _darkDatePickerTheme =>
      const DatePickerThemeData();
  static TimePickerThemeData get _darkTimePickerTheme =>
      const TimePickerThemeData();
  static ExpansionTileThemeData get _darkExpansionTileTheme =>
      const ExpansionTileThemeData();
  static DataTableThemeData get _darkDataTableTheme =>
      const DataTableThemeData();
  static MenuBarThemeData get _darkMenuBarTheme => const MenuBarThemeData();
  static MenuButtonThemeData get _darkMenuButtonTheme =>
      const MenuButtonThemeData();
  static MenuThemeData get _darkMenuTheme => const MenuThemeData();
  static SearchBarThemeData get _darkSearchBarTheme =>
      const SearchBarThemeData();
  static SearchViewThemeData get _darkSearchViewTheme =>
      const SearchViewThemeData();
  static ActionIconThemeData get _darkActionIconTheme =>
      const ActionIconThemeData();
  static FilledButtonThemeData get _darkFilledButtonTheme =>
      const FilledButtonThemeData();
  static IconButtonThemeData get _darkIconButtonTheme =>
      const IconButtonThemeData();
  static ToggleButtonsThemeData get _darkToggleButtonsTheme =>
      const ToggleButtonsThemeData();
  static TextSelectionThemeData get _darkTextSelectionTheme =>
      const TextSelectionThemeData();
  static ScrollbarThemeData get _darkScrollbarTheme =>
      const ScrollbarThemeData();
  static PageTransitionsTheme get _darkPageTransitionsTheme =>
      const PageTransitionsTheme();
}
