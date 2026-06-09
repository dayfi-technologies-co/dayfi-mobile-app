import 'package:dayfi/common/utils/haptic_helper.dart';
import 'package:dayfi/common/utils/share_origin.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart';

/// Borderless read-only value with copy / share — used on wallet receive (IBAN, address, username).
class DayfiReadonlyCopyField extends StatelessWidget {
  const DayfiReadonlyCopyField({
    super.key,
    required this.label,
    required this.value,
    required this.shareText,
    this.shareSubject,
    this.copiedMessage = 'Copied to clipboard',
    this.minLines = 1,
    this.maxLines = 4,
  });

  final String label;
  final String value;
  final String shareText;
  final String? shareSubject;
  final String copiedMessage;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final surface = Theme.of(context).colorScheme.surface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Chirp',
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              height: 1.45,
              color: onSurface.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 4),
        ],
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SelectableText(
                  value,
                  minLines: minLines,
                  maxLines: maxLines,
                  style: TextStyle(
                    fontFamily: 'Chirp',
                    fontSize: 15,
                    letterSpacing: -0.25,
                    height: 1.45,
                    fontWeight: FontWeight.w400,
                    color: onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _DayfiCopyShareActions(
                copyText: value,
                shareText: shareText,
                shareSubject: shareSubject,
                copiedMessage: copiedMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DayfiCopyShareActions extends StatelessWidget {
  const _DayfiCopyShareActions({
    required this.copyText,
    required this.shareText,
    this.shareSubject,
    required this.copiedMessage,
  });

  final String copyText;
  final String shareText;
  final String? shareSubject;
  final String copiedMessage;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final canCopy = copyText.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DayfiCopyShareButton(
            label: 'copy',
            iconAsset: 'assets/icons/svgs/copy.svg',
            color: primary,
            onTap:
                canCopy
                    ? () {
                      HapticHelper.lightImpact();
                      Clipboard.setData(ClipboardData(text: copyText));
                      TopSnackbar.show(
                        context,
                        message: copiedMessage,
                        isError: false,
                      );
                    }
                    : null,
          ),
          const SizedBox(width: 16),
          Builder(
            builder: (shareContext) {
              return _DayfiCopyShareButton(
                label: 'share',
                iconAsset: 'assets/icons/svgs/share.svg',
                color: primary,
                onTap:
                    shareText.trim().isNotEmpty
                        ? () async {
                          HapticHelper.lightImpact();
                          try {
                            await Share.share(
                              shareText,
                              subject: shareSubject,
                              sharePositionOrigin: sharePositionOrigin(shareContext),
                            );
                          } catch (e) {
                            if (shareContext.mounted) {
                              TopSnackbar.show(
                                shareContext,
                                message:
                                    'Unable to share. Please try again.',
                                isError: true,
                              );
                            }
                          }
                        }
                        : null,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DayfiCopyShareButton extends StatelessWidget {
  const _DayfiCopyShareButton({
    required this.label,
    required this.iconAsset,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String iconAsset;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Chirp',
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
              letterSpacing: 0,
              height: 1.45,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          SvgPicture.asset(iconAsset, color: color, height: 16),
        ],
      ),
    );
  }
}
