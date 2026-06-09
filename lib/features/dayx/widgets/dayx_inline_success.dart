import 'package:dayfi/common/widgets/transaction_success_view.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Compact success receipt shown inside a DayX chat bubble.
class DayxInlineSuccess {
  final String headline;
  final String title;
  final String? amountText;
  final String? subtitle;
  final List<TransactionSuccessDetail> details;

  const DayxInlineSuccess({
    required this.headline,
    required this.title,
    this.amountText,
    this.subtitle,
    this.details = const [],
  });
}

class DayxChatSuccessReceipt extends StatelessWidget {
  final DayxInlineSuccess receipt;

  const DayxChatSuccessReceipt({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.purple900,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SvgPicture.asset(
            'assets/icons/svgs/circle-check.svg',
            height: 44,
            colorFilter: const ColorFilter.mode(
              AppColors.success500,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            receipt.headline,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'FunnelDisplay',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            receipt.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Chirp',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
          if (receipt.amountText != null && receipt.amountText!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              receipt.amountText!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'FunnelDisplay',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
          if (receipt.subtitle != null && receipt.subtitle!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              receipt.subtitle!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Chirp',
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.72),
              ),
            ),
          ],
          if (receipt.details.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...receipt.details.map(
              (d) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        d.label,
                        style: TextStyle(
                          fontFamily: 'Chirp',
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.65),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        d.value,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontFamily: 'Chirp',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
