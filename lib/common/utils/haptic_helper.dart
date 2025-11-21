import 'package:flutter/services.dart';

/// Utility class for providing haptic feedback throughout the app
/// 
/// Usage:
/// ```dart
/// HapticHelper.lightImpact(); // For subtle feedback
/// HapticHelper.mediumImpact(); // For standard interactions
/// HapticHelper.heavyImpact(); // For important actions
/// HapticHelper.selection(); // For picker/selector changes
/// HapticHelper.success(); // For successful operations
/// HapticHelper.warning(); // For warning states
/// HapticHelper.error(); // For error states
/// ```
class HapticHelper {
  /// Light impact haptic - for subtle interactions
  /// Use for: Hovering, selection changes, minor UI updates
  static Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium impact haptic - for standard interactions
  /// Use for: Button taps, switches, checkbox toggles
  static Future<void> mediumImpact() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy impact haptic - for important actions
  /// Use for: Confirmation dialogs, delete actions, significant changes
  static Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }

  /// Selection haptic - for changing selections in pickers
  /// Use for: Scrolling through picker values, tabs, segmented controls
  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }

  /// Success feedback - indicates successful operation
  /// Use for: Transaction success, form submission success
  static Future<void> success() async {
    // Double light impact for success feel
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.lightImpact();
  }

  /// Warning feedback - indicates warning or caution
  /// Use for: Warning dialogs, important confirmations
  static Future<void> warning() async {
    await HapticFeedback.mediumImpact();
  }

  /// Error feedback - indicates an error occurred
  /// Use for: Failed operations, validation errors
  static Future<void> error() async {
    // Triple light impact for error feel
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.lightImpact();
  }

  /// Vibrate - standard device vibration
  /// Use sparingly for very important notifications
  static Future<void> vibrate() async {
    await HapticFeedback.vibrate();
  }
}
