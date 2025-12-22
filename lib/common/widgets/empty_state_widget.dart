// import 'package:dayfi/common/widgets/buttons/primary_button.dart';
// import 'package:dayfi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dayfi/core/theme/app_typography.dart';
// import 'package:dayfi/common/widgets/buttons/primary_button.dart';

/// A reusable widget for displaying empty states with optional CTAs
///
/// Usage:
/// ```dart
/// EmptyStateWidget(
///   title: 'No transactions yet',
///   message: 'your transactions will appear here',
///   actionText: 'Send Money',
///   onAction: () => navigateToSend(),
/// )
/// ```
class EmptyStateWidget extends StatelessWidget {
  /// The main title for the empty state
  final String title;

  /// Optional message providing more context
  final String? message;

  /// Optional icon to display
  final IconData? icon;

  /// Optional custom icon widget (SVG, image, etc.)
  final Widget? customIcon;

  /// Optional action button text
  final String? actionText;

  /// Callback when action button is pressed
  final VoidCallback? onAction;

  /// Optional secondary action button text
  final String? secondaryActionText;

  /// Callback when secondary action button is pressed
  final VoidCallback? onSecondaryAction;

  final double? paddingAll;

  /// Optional custom button widget (e.g., for recipients "Send Money" button)
  final Widget? customButton;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.customIcon,
    this.actionText,
    this.onAction,
    this.secondaryActionText,
    this.onSecondaryAction,
    this.paddingAll,
    this.customButton,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon
            // if (customIcon != null)
            //   customIcon!
            // else if (icon != null)
            //   Icon(
            //     icon,
            //     size: 80,
            //     color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            //   ),
            // SizedBox(height: 24),
            SvgPicture.asset(
              'assets/icons/svgs/search-normal.svg',
              height: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            SizedBox(height: 16),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontFamily: 'FunnelDisplay',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Message
            if (message != null) ...[
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  message!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Chirp',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],

            // Custom button (e.g., for recipients "Send Money" button)
            // if (customButton != null) ...[
            //   SizedBox(height: 24),
            //   customButton!,
            // ],
            SizedBox(height: 96),
          ],
        ),
      ),
    );
  }
}

/// A compact version of empty state for inline use (e.g., in cards or sections)
class CompactEmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData? icon;
  final Widget? customIcon;

  const CompactEmptyStateWidget({
    super.key,
    required this.message,
    this.icon,
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (customIcon != null)
            customIcon!
          else if (icon != null)
            Icon(
              icon,
              size: 40,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
          if (icon != null || customIcon != null) SizedBox(height: 12),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontFamily: 'Chirp',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
