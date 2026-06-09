import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/buttons/secondary_button.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

/// Side-by-side Copy + Share actions (Add money tabs).
class CopyShareRow extends StatelessWidget {
  final String copyValue;
  final String? shareValue;
  final String copyLabel;

  const CopyShareRow({
    super.key,
    required String value,
    this.shareValue,
    this.copyLabel = 'Copy',
  }) : copyValue = value;

  const CopyShareRow.split({
    super.key,
    required this.copyValue,
    required this.shareValue,
    this.copyLabel = 'Copy',
  });

  String get _sharePayload => shareValue ?? copyValue;

  @override
  Widget build(BuildContext context) {
    final copyEnabled = copyValue.isNotEmpty;
    final shareEnabled = _sharePayload.isNotEmpty;

    return Row(
      children: [
        Expanded(
          child: PrimaryButton(
            text: copyLabel,
            onPressed: copyEnabled
                ? () {
                    Clipboard.setData(ClipboardData(text: copyValue));
                    TopSnackbar.show(context, message: 'Copied to clipboard');
                  }
                : null,
            enabled: copyEnabled,
            fullWidth: true,
            height: 52,
            borderRadius: 38,
            backgroundColor: AppColors.purple500ForTheme(context),
            textColor: AppColors.neutral0,
            fontFamily: 'Chirp',
            fontSize: 16,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SecondaryButton(
            text: 'Share',
            onPressed: shareEnabled ? () => Share.share(_sharePayload) : null,
            enabled: shareEnabled,
            fullWidth: true,
            height: 52,
            borderRadius: 38,
            fontFamily: 'Chirp',
            fontSize: 16,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
