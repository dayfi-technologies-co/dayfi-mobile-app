import 'package:dayfi/common/constants/username_copy.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/dayfi_screen_description.dart';
import 'package:dayfi/common/widgets/dayfi_readonly_copy_field.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/services/local/intercom_support_service.dart';
import 'package:flutter/material.dart';

/// Username share UI — same content as [_SendPaymentMethodViewState._showDayfiTagBottomSheet].
class DayfiUsernameShareContent extends StatefulWidget {
  const DayfiUsernameShareContent({
    super.key,
    required this.dayfiId,
    this.onClose,
    this.showCloseButton = true,
    this.showTitle = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 18),
  });

  final String dayfiId;
  final VoidCallback? onClose;
  final bool showCloseButton;
  final bool showTitle;
  final EdgeInsetsGeometry padding;

  @override
  State<DayfiUsernameShareContent> createState() =>
      _DayfiUsernameShareContentState();
}

class _DayfiUsernameShareContentState extends State<DayfiUsernameShareContent> {
  String get _displayTag =>
      widget.dayfiId.startsWith('@') ? widget.dayfiId : '@${widget.dayfiId}';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.showTitle) ...[
            const SizedBox(height: 8),
            Text(
              UsernameCopy.myUsername,
              textAlign: TextAlign.center,
              style: AppTypography.titleLarge.copyWith(
                fontFamily: 'FunnelDisplay',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 18),
          ] else
            const SizedBox(height: 8),
          DayfiScreenDescription(
            text: UsernameCopy.shareInstant,
            bottomSpacing: 32,
          ),
          DayfiReadonlyCopyField(
            label: UsernameCopy.label,
            value: _displayTag,
            shareText: UsernameCopy.shareInvite(_displayTag),
            shareSubject: UsernameCopy.myUsername,
            copiedMessage: UsernameCopy.copiedToClipboard,
            maxLines: 2,
          ),
          const SizedBox(height: 32),
          if (widget.showCloseButton)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: PrimaryButton(
                text: 'Close',
                onPressed: widget.onClose ?? () => Navigator.pop(context),
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
          if (widget.showCloseButton) const SizedBox(height: 20),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
    );
  }
}
