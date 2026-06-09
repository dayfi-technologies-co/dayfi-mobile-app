import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/empty_state_widget.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Recipients-style empty state: icon, title, message, orange CTA.
class DayfiEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;

  const DayfiEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
  });

  /// Standard Dayfi primary CTA used on Recipients, Transactions, Budgets, etc.
  static Widget actionButton({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
  }) {
    final accent = AppColors.purple500ForTheme(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: PrimaryButton(
        text: text,
        onPressed: onPressed,
        backgroundColor: accent,
        borderColor: accent,
        height: 48,
        textColor: AppColors.neutral0,
        fontFamily: 'Chirp',
        letterSpacing: -0.7,
        fontSize: 18,
        borderRadius: 50,
        fullWidth: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: title,
      message: message,
      customButton:
          actionText != null && onAction != null
              ? actionButton(
                context: context,
                text: actionText!,
                onPressed: onAction!,
              )
              : null,
    );
  }
}

/// Full-height scrollable empty body (pull-to-refresh friendly).
class DayfiEmptyStateBody extends StatelessWidget {
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;

  const DayfiEmptyStateBody({
    super.key,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final minHeight = constraints.maxHeight > 0
            ? constraints.maxHeight
            : MediaQuery.sizeOf(context).height * 0.65;
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: DayfiEmptyState(
              title: title,
              message: message,
              actionText: actionText,
              onAction: onAction,
            ),
          ),
        );
      },
    );
  }
}
