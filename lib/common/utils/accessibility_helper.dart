import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Helper class for accessibility features
/// 
/// Provides utilities for screen readers, semantic labels, and accessibility hints
class AccessibilityHelper {
  /// Wraps a widget with semantic label for screen readers
  static Widget label({
    required Widget child,
    required String label,
    String? hint,
    bool? button,
    bool? header,
    bool? link,
    bool? enabled,
    bool? checked,
    bool? selected,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: button,
      header: header,
      link: link,
      enabled: enabled,
      checked: checked,
      selected: selected,
      onTap: onTap,
      onLongPress: onLongPress,
      child: child,
    );
  }

  /// Wraps a button with proper semantics
  static Widget button({
    required Widget child,
    required String label,
    String? hint,
    bool enabled = true,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: true,
      enabled: enabled,
      onTap: onTap,
      child: child,
    );
  }

  /// Wraps a text field with proper semantics
  static Widget textField({
    required Widget child,
    required String label,
    String? hint,
    String? value,
    bool obscured = false,
    bool multiline = false,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      textField: true,
      obscured: obscured,
      multiline: multiline,
      child: child,
    );
  }

  /// Wraps an image with alt text
  static Widget image({
    required Widget child,
    required String label,
    String? hint,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      image: true,
      child: child,
    );
  }

  /// Wraps a header/title with proper semantics
  static Widget header({
    required Widget child,
    required String label,
    int level = 1,
  }) {
    return Semantics(
      label: label,
      header: true,
      child: child,
    );
  }

  /// Excludes a widget from semantics tree (decorative elements)
  static Widget exclude({
    required Widget child,
    bool excluding = true,
  }) {
    return ExcludeSemantics(
      excluding: excluding,
      child: child,
    );
  }

  /// Announces a message to screen readers
  static void announce(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Checks if screen reader is enabled
  static bool isScreenReaderEnabled(BuildContext context) {
    return MediaQuery.of(context).accessibleNavigation;
  }

  /// Gets the text scale factor for dynamic text sizing
  static double getTextScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaleFactor;
  }

  /// Checks if reduce motion is enabled
  static bool shouldReduceMotion(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  /// Checks color contrast ratio (WCAG AA requires 4.5:1 for normal text, 3:1 for large text)
  static double calculateContrastRatio(Color foreground, Color background) {
    final fgLuminance = foreground.computeLuminance();
    final bgLuminance = background.computeLuminance();
    
    final lighter = fgLuminance > bgLuminance ? fgLuminance : bgLuminance;
    final darker = fgLuminance > bgLuminance ? bgLuminance : fgLuminance;
    
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Checks if color combination meets WCAG AA standard
  static bool meetsWCAGAA(Color foreground, Color background, {bool largeText = false}) {
    final ratio = calculateContrastRatio(foreground, background);
    return largeText ? ratio >= 3.0 : ratio >= 4.5;
  }

  /// Checks if color combination meets WCAG AAA standard
  static bool meetsWCAGAAA(Color foreground, Color background, {bool largeText = false}) {
    final ratio = calculateContrastRatio(foreground, background);
    return largeText ? ratio >= 4.5 : ratio >= 7.0;
  }

  /// Formats currency for screen readers (e.g., "$100.50" -> "100 dollars and 50 cents")
  static String formatCurrencyForScreenReader(String amount, String currency) {
    // Remove currency symbols and parse
    final numericAmount = amount.replaceAll(RegExp(r'[^0-9.]'), '');
    final parts = numericAmount.split('.');
    
    if (parts.isEmpty) return amount;
    
    final dollars = parts[0];
    final cents = parts.length > 1 ? parts[1] : '00';
    
    if (cents == '00') {
      return '$dollars $currency';
    }
    
    return '$dollars $currency and $cents cents';
  }

  /// Formats account numbers for screen readers (breaks into groups)
  static String formatAccountNumberForScreenReader(String accountNumber) {
    // Break into groups of 4 digits for easier listening
    final cleaned = accountNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final groups = <String>[];
    
    for (int i = 0; i < cleaned.length; i += 4) {
      final end = (i + 4 < cleaned.length) ? i + 4 : cleaned.length;
      groups.add(cleaned.substring(i, end));
    }
    
    return groups.join(' ');
  }

  /// Creates a live region for dynamic content updates
  static Widget liveRegion({
    required Widget child,
    required String label,
    bool polite = true,
  }) {
    return Semantics(
      label: label,
      liveRegion: true,
      child: child,
    );
  }
}
