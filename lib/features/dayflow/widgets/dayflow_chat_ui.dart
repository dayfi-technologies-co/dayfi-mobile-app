import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/buttons/secondary_button.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Shared typography and controls for DayFlow in-chat cards (aligned with DayX).
abstract final class DayFlowChatUi {
  static const bubbleRadius = 14.0;
  static const chipRadius = 12.0;
  static const buttonRadius = 38.0;
  static const insetPanelRadius = 12.0;

  static TextStyle cardTitle(BuildContext context) => TextStyle(
        fontFamily: 'Chirp',
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
      );

  static TextStyle cardHint(BuildContext context) => TextStyle(
        fontFamily: 'Chirp',
        fontSize: 12,
        height: 1.35,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
      );

  static TextStyle body(BuildContext context) => const TextStyle(
        fontFamily: 'Chirp',
        fontSize: 15,
        height: 1.35,
      );

  static TextStyle sectionHeader(BuildContext context) => TextStyle(
        fontFamily: 'Chirp',
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
      );

  static TextStyle rowLabel(BuildContext context) => TextStyle(
        fontFamily: 'Chirp',
        fontSize: 13,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
      );

  static TextStyle rowValue(BuildContext context) => const TextStyle(
        fontFamily: 'Chirp',
        fontSize: 14,
        fontWeight: FontWeight.w600,
      );

  static TextStyle emphasis(BuildContext context) => const TextStyle(
        fontFamily: 'Chirp',
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
      );

  static Widget primaryButton(
    BuildContext context, {
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return PrimaryButton(
      borderRadius: buttonRadius,
      text: text,
      onPressed: onPressed,
      enabled: onPressed != null && !isLoading,
      isLoading: isLoading,
      backgroundColor: AppColors.teal500,
      height: 48,
      textColor: AppColors.neutral0,
      fontFamily: 'Chirp',
      letterSpacing: -.70,
      fontSize: 18,
      fontWeight: FontWeight.w700,
      fullWidth: true,
    );
  }

  static Widget secondaryButton(
    BuildContext context, {
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SecondaryButton(
      borderRadius: buttonRadius,
      text: text,
      onPressed: onPressed,
      enabled: onPressed != null && !isLoading,
      isLoading: isLoading,
      fullWidth: true,
      height: 48,
      borderColor: AppColors.teal500.withValues(alpha: 0.45),
      textColor: AppColors.teal500,
      backgroundColor: Colors.transparent,
      fontFamily: 'Chirp',
      letterSpacing: -.70,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    );
  }

  static Widget cancelTextButton(
    BuildContext context, {
    required String label,
    VoidCallback? onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontFamily: AppTypography.secondaryFontFamily,
          fontWeight: AppTypography.bold,
          height: 1,
          letterSpacing: -.4,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
    );
  }
}
