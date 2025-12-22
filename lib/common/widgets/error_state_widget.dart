import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';

/// A reusable widget for displaying error states with retry functionality
/// 
/// Usage:
/// ```dart
/// ErrorStateWidget(
///   message: 'Failed to load data',
///   onRetry: () => loadData(),
/// )
/// ```
class ErrorStateWidget extends StatelessWidget {
  /// The error message to display
  final String message;
  
  /// Optional detailed error message
  final String? details;
  
  /// Callback when retry button is pressed
  final VoidCallback onRetry;
  
  /// Optional custom icon
  final Widget? icon;
  
  /// Whether to show the retry button
  final bool showRetryButton;
  
  /// Custom retry button text
  final String retryButtonText;

  const ErrorStateWidget({
    super.key,
    required this.message,
    required this.onRetry,
    this.details,
    this.icon,
    this.showRetryButton = true,
    this.retryButtonText = 'Try Again',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Error icon
            icon ?? Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            SizedBox(height: 24),
            
            // Error message
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
             fontFamily: 'FunnelDisplay',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Details if provided
            if (details != null) ...[
              SizedBox(height: 12),
              Text(
                details!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Chirp',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            // Retry button
            if (showRetryButton) ...[
              SizedBox(height: 32),
              PrimaryButton.dayfi(
                text: retryButtonText,
                onPressed: onRetry,
                width: 200,
                height: 44,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A compact version of error state for inline use (e.g., in lists)
class CompactErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final String retryButtonText;

  const CompactErrorStateWidget({
    super.key,
    required this.message,
    required this.onRetry,
    this.retryButtonText = 'Retry',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: 24,
            color: Theme.of(context).colorScheme.error,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontFamily: 'Chirp',
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          // SizedBox(width: 12),
          // TextButton(
          //   onPressed: onRetry,
          //   child: Text(
          //     retryButtonText,
          //     style: TextStyle(
          //    fontFamily: 'FunnelDisplay',
          //       fontSize: 14,
          //       fontWeight: FontWeight.w600,
          //       color: AppColors.purple500ForTheme(context),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
