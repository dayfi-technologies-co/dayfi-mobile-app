import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/dayfi_screen_app_bar.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/invest/constants/invest_copy.dart';
import 'package:flutter/material.dart';

class InvestLockStepScaffold extends StatelessWidget {
  final int step;
  final int totalSteps;
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget bottomBar;
  final bool showBackButton;

  const InvestLockStepScaffold({
    super.key,
    required this.step,
    required this.totalSteps,
    required this.title,
    this.subtitle,
    required this.child,
    required this.bottomBar,
    this.showBackButton = true,
  });

  /// Full-width lock-step CTA — white label, 24px horizontal inset via scaffold.
  static Widget primaryButton(
    BuildContext context, {
    required String text,
    required VoidCallback? onPressed,
    bool enabled = true,
    bool isLoading = false,
  }) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 24),
      child: PrimaryButton(
        text: text,
        onPressed: onPressed,
        enabled: enabled,
        isLoading: isLoading,
        fullWidth: true,
        height: 48,
        borderRadius: 38,
        backgroundColor: AppColors.purple500ForTheme(context),
        textColor: AppColors.neutral0,
        fontFamily: 'Chirp',
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -.7,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (step + 1) / totalSteps;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: DayfiScreenAppBar(
        title: InvestCopy.createTitle,
        showBackButton: showBackButton,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step ${step + 1} of $totalSteps',
                  style: TextStyle(
                    fontFamily: 'Chirp',
                    fontSize: 13,
                    color: onSurface.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: onSurface.withValues(alpha: 0.08),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'FunnelDisplay',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontFamily: 'Chirp',
                      fontSize: 14,
                      height: 1.35,
                      color: onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
              child: child,
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
              child: bottomBar,
            ),
          ),
        ],
      ),
    );
  }
}
