import 'package:dayfi/common/constants/product_features.dart';
import 'package:dayfi/common/utils/haptic_helper.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/dayearn/helpers/dayearn_format.dart';
import 'package:dayfi/features/dayflow/constants/dayflow_copy.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_format.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_schedule_list_helper.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_wallet_balance.dart';
import 'package:dayfi/features/dayflow/models/dayflow_models.dart';
// import 'package:dayfi/features/home/widgets/workspace_section_header.dart';
import 'package:dayfi/services/remote/dayearn_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Contextual DayFlow + DayEarn on Home. Marketing copy only when there is
/// no live data — never as a fake metric.
class HomeInsightTiles extends StatelessWidget {
  final DayFlowDashboardSnapshot? dayFlow;
  final DayEarnSummary? dayEarn;
  final VoidCallback onDayFlow;
  final VoidCallback onDayEarn;

  const HomeInsightTiles({
    super.key,
    required this.dayFlow,
    required this.dayEarn,
    required this.onDayFlow,
    required this.onDayEarn,
  });

  DayBudgetScheduleInstance? get _nextFlow {
    final upcoming = [...?dayFlow?.scheduleInstances.upcoming];
    if (upcoming.isEmpty) return null;
    upcoming.sort((a, b) => a.dueAt.compareTo(b.dueAt));
    return upcoming.first;
  }

  bool get _hasDayEarnPots => (dayEarn?.pots.length ?? 0) > 0;

  @override
  Widget build(BuildContext context) {
    final next = _nextFlow;
    final showDayFlowLive = next != null;
    final showDayFlowEmpty =
        ProductFeatures.dayFlowAutopay && !showDayFlowLive;
    final showDayEarnLive = ProductFeatures.dayEarnHomePromo && _hasDayEarnPots;
    final showDayEarnEmpty =
        ProductFeatures.dayEarnHomePromo && !_hasDayEarnPots;

    if (!showDayFlowLive &&
        !showDayFlowEmpty &&
        !showDayEarnLive &&
        !showDayEarnEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // const WorkspaceSectionHeader(title: 'UP NEXT'),
        const SizedBox(height: 10),
        if (showDayFlowLive)
          _InsightRow(
            eyebrow: DayFlowCopy.featureName.toUpperCase(),
            title: next!.title.trim().isEmpty ? 'Scheduled payment' : next.title,
            subtitle:
                '${formatScheduleDateHeader(next.dueAt)} · ${formatDayFlowAmount(next.amount, kDayFlowWalletCurrency)}',
            icon: 'assets/icons/svgs/automation.svg',
            accent: AppColors.teal600,
            onTap: onDayFlow,
          )
        else if (showDayFlowEmpty)
          _InsightRow(
            eyebrow: 'AUTOMATE A PAYMENT',
            title: 'Never forget rent or subscriptions',
            subtitle: 'Set up a scheduled payment',
            icon: 'assets/icons/svgs/automation.svg',
            accent: AppColors.teal600,
            onTap: onDayFlow,
          ),
        if (showDayFlowLive || showDayFlowEmpty) const SizedBox(height: 8),
        if (showDayEarnLive)
          _InsightRow(
            eyebrow: 'DAYEARN',
            title: formatDayEarnAmount(
              dayEarn!.totalBalance,
              kDayEarnCurrency,
            ),
            subtitle: _dayEarnSubtitle(dayEarn!),
            icon: 'assets/icons/svgs/clock-dollar.svg',
            accent: AppColors.purple600,
            onTap: onDayEarn,
          )
        else if (showDayEarnEmpty)
          _InsightRow(
            eyebrow: 'START SAVING',
            title: 'Put your money to work',
            subtitle: 'Create your first DayEarn pot',
            icon: 'assets/icons/svgs/clock-dollar.svg',
            accent: AppColors.purple600,
            onTap: onDayEarn,
          ),
      ],
    );
  }

  String _dayEarnSubtitle(DayEarnSummary summary) {
    final pots = summary.pots.length;
    final potLabel = pots == 1 ? '1 pot' : '$pots pots';
    final awaiting = summary.pots.every(dayEarnPotAwaitingFirstCredit);
    if (awaiting || summary.todaysInterest <= 0) {
      return '$potLabel · interest pending';
    }
    return '$potLabel · +${formatDayEarnInterestAmount(summary.todaysInterest, kDayEarnCurrency)} today';
  }
}

class _InsightRow extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  final String icon;
  final Color accent;
  final VoidCallback onTap;

  const _InsightRow({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticHelper.lightImpact();
          onTap();
        },
        splashColor: Colors.transparent,
        highlightColor: accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/svgs/recipients.svg',
                      width: 40,
                      height: 40,
                      colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
                    ),
                    SvgPicture.asset(
                      icon,
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eyebrow,
                      style: TextStyle(
                        fontFamily: 'Chirp',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                        color: accent,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleMedium.copyWith(
                        fontFamily: 'Chirp',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                        color: onSurface,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Chirp',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: onSurface.withValues(alpha: 0.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
