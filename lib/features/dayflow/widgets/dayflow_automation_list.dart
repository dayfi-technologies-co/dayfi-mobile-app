import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/dayflow/constants/dayflow_copy.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_format.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_schedule_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class DayFlowAutomationList extends StatelessWidget {
  final List<DayBudgetAutomationItem> items;
  final void Function(DayBudgetAutomationItem item)? onTap;

  const DayFlowAutomationList({super.key, required this.items, this.onTap});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          DayFlowCopy.noAutomationsYet,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Chirp',
            fontSize: 14,
            height: 1.4,
            color: onSurface.withValues(alpha: 0.55),
          ),
        ),
      );
    }

    return Column(
      children:
          items.map((item) {
            final hint = item.recipientHint?.trim();
            final amount = formatDayFlowAmount(item.amount, 'NGN');
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: onTap != null ? () => onTap!(item) : null,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: onSurface.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${item.title} · $amount',
                                style: TextStyle(
                                  fontFamily: 'Chirp',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  height: 1.35,
                                  color: onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                hint != null && hint.isNotEmpty
                                    ? '$hint · ${item.scheduleText}'
                                    : item.needsSetup
                                    ? '${item.scheduleText} · ${DayFlowCopy.tapToAddDetails}'
                                    : item.scheduleText,
                                style: TextStyle(
                                  fontFamily: 'Chirp',
                                  fontSize: 13,
                                  color:
                                      item.needsSetup
                                          ? AppColors.orange500
                                          : onSurface.withValues(alpha: 0.5),
                                  fontWeight:
                                      item.needsSetup
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (item.needsSetup) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 20,
                            color: AppColors.orange500,
                          ),
                        ] else if (item.autoPay) ...[
                          const SizedBox(width: 8),
                          SvgPicture.asset(
                            'assets/icons/svgs/circle-check.svg',
                            colorFilter: const ColorFilter.mode(
                              AppColors.success500,
                              BlendMode.srcIn,
                            ),
                            height: 20,
                            width: 20,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}
