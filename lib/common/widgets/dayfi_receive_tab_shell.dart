import 'package:dayfi/common/widgets/dayfi_screen_description.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/services/local/intercom_support_service.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:flutter/material.dart';

/// Centered title + description layout used by Add-money tabs (matches [DayfiUsernameShareContent]).
class DayfiReceiveTabShell extends StatelessWidget {
  const DayfiReceiveTabShell({
    super.key,
    this.title = '',
    required this.description,
    this.showTitle = true,
    this.children = const [],
    this.primaryButtonText,
    this.onPrimaryPressed,
    this.showCloseButton = false,
    this.onClose,
    this.padding = const EdgeInsets.symmetric(horizontal: 18),
  });

  final String title;
  final String description;
  final bool showTitle;
  final List<Widget> children;
  final String? primaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final bool showCloseButton;
  final VoidCallback? onClose;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.only(top: 16, bottom: 32),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showTitle && title.isNotEmpty) ...[
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTypography.titleLarge.copyWith(
                  fontFamily: 'FunnelDisplay',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 18),
            ],
            DayfiScreenDescription(
              text: description,
              bottomSpacing: 32,
            ),
            ...children,
            if (primaryButtonText != null && onPrimaryPressed != null) ...[
              PrimaryButton(
                text: primaryButtonText!,
                onPressed: onPrimaryPressed,
                backgroundColor: AppColors.purple500,
                height: 48,
                textColor: AppColors.neutral0,
                fontFamily: 'Chirp',
                letterSpacing: -.70,
                fontSize: 18,
                width: double.infinity,
                fullWidth: true,
                borderRadius: 40,
              ),
              const SizedBox(height: 20),
            ],
            if (showCloseButton)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                child: PrimaryButton(
                  text: 'Close',
                  onPressed: onClose ?? () => Navigator.pop(context),
                  backgroundColor: AppColors.purple500,
                  height: 48,
                  textColor: AppColors.neutral0,
                  fontFamily: 'Chirp',
                  letterSpacing: -.70,
                  fontSize: 18,
                  width: double.infinity,
                  fullWidth: true,
                  borderRadius: 40,
                ),
              ),

            if (showCloseButton) const SizedBox(height: 20),
            InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              onTap: () async {
                try {
                  await IntercomSupportService.openContactSupport();
                } catch (e) {
                  if (context.mounted) {
                    TopSnackbar.show(
                      context,
                      message:
                          'Unable to open support chat. Please try again later.',
                      isError: true,
                    );
                  }
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Text(
                  'Do you need help?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Chirp',
                    color: AppColors.purple500ForTheme(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -.25,
                    height: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
