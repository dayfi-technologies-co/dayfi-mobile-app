import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/dayflow/constants/dayflow_copy.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_format.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_instance_display.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_wallet_balance.dart';
import 'package:dayfi/features/dayflow/models/dayflow_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class DayFlowScheduleSections extends StatelessWidget {
  final DayBudgetScheduleInstances instances;
  final void Function(DayBudgetScheduleInstance item)? onTap;

  const DayFlowScheduleSections({
    super.key,
    required this.instances,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    if (instances.upcoming.isEmpty && instances.past.isEmpty) {
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (instances.upcoming.isNotEmpty) ...[
          _SectionHeader(title: DayFlowCopy.upcomingSection),
          const SizedBox(height: 8),
          ...instances.upcoming.map(
            (item) => _InstanceTile(
              item: item,
              onTap: onTap != null ? () => onTap!(item) : null,
            ),
          ),
          const SizedBox(height: 20),
        ],
        if (instances.past.isNotEmpty) ...[
          _SectionHeader(title: DayFlowCopy.pastSection),
          const SizedBox(height: 8),
          ...instances.past.map(
            (item) => _InstanceTile(
              item: item,
              muted: true,
              onTap: onTap != null ? () => onTap!(item) : null,
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'FunnelDisplay',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
      ),
    );
  }
}

class _InstanceTile extends StatelessWidget {
  final DayBudgetScheduleInstance item;
  final bool muted;
  final VoidCallback? onTap;

  const _InstanceTile({
    required this.item,
    this.muted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final alpha = muted ? 0.45 : 1.0;
    final amount = formatDayFlowAmount(item.amount, kDayFlowWalletCurrency);
    final subtitle = formatInstanceSubtitle(item);
    final showSetupWarning = item.needsSetup;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: onSurface.withValues(alpha: 0.08)),
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
                          color: onSurface.withValues(alpha: alpha),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontFamily: 'Chirp',
                          fontSize: 13,
                          color: showSetupWarning
                              ? AppColors.orange500
                              : onSurface.withValues(alpha: muted ? 0.4 : 0.5),
                          fontWeight:
                              showSetupWarning
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (item.status == DayBudgetInstanceStatus.paid) ...[
                  const SizedBox(width: 8),
                  SvgPicture.asset(
                    'assets/icons/svgs/circle-check.svg',
                    color: AppColors.success500,
                    height: 20,
                    width: 20,
                  ),
                ] else if (showSetupWarning) ...[
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
                    color: AppColors.teal500.withValues(alpha: muted ? 0.35 : 0.7),
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
  }
}
