import 'package:dayfi/app_locator.dart';
import 'package:dayfi/features/invest/views/invest_lock_duration_view.dart';
import 'package:dayfi/services/remote/investment_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shared Lock & Earn deposit flow — used from Home quick actions and Invest tab.
class InvestDepositFlow {
  InvestDepositFlow._();

  static final List<InvestmentPlan> fallbackPlans = [
    InvestmentPlan(
      lockDays: 30,
      label: '30 days',
      apyPercent: 1.5,
      maxApyPercent: 4,
      periodReturnPercent: InvestmentPlan.computePeriodReturn(1.5, 30),
    ),
    InvestmentPlan(
      lockDays: 90,
      label: '90 days',
      apyPercent: 3.5,
      maxApyPercent: 6,
      periodReturnPercent: InvestmentPlan.computePeriodReturn(3.5, 90),
    ),
    InvestmentPlan(
      lockDays: 180,
      label: '180 days',
      apyPercent: 5.5,
      maxApyPercent: 8,
      periodReturnPercent: InvestmentPlan.computePeriodReturn(5.5, 180),
    ),
    InvestmentPlan(
      lockDays: 365,
      label: '365 days',
      apyPercent: 8,
      maxApyPercent: 10,
      periodReturnPercent: InvestmentPlan.computePeriodReturn(8, 365),
    ),
  ];

  /// Opens the lock wizard immediately; network prep runs on the first step.
  static Future<void> start({
    required BuildContext context,
    required WidgetRef ref,
    InvestmentSummary? summary,
    List<InvestmentPlan>? plans,
    VoidCallback? onSuccess,
    bool showBackButton = true,
  }) async {
    final initialPlans =
        (plans != null && plans.isNotEmpty) ? plans : fallbackPlans;

    if (!context.mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InvestLockDurationView(
          plans: initialPlans,
          summary: summary,
          refreshPlansOnLoad: plans == null || plans.isEmpty,
          refreshSummaryOnLoad: summary == null,
          onSuccess: onSuccess,
          showBackButton: showBackButton,
        ),
      ),
    );
  }

  /// Risk disclosure + plan refresh — runs on the duration step, not before navigation.
  static Future<void> bootstrapLockFlow({
    InvestmentSummary? summary,
    bool refreshSummary = false,
    bool refreshPlans = false,
    void Function(List<InvestmentPlan> plans)? onPlansUpdated,
    void Function(InvestmentSummary summary)? onSummaryUpdated,
  }) async {
    if (refreshSummary || summary == null) {
      try {
        final fetched = await investmentService.fetchSummary();
        onSummaryUpdated?.call(fetched);
        summary = fetched;
      } catch (_) {}
    }

    if (summary != null && !summary.riskAccepted) {
      try {
        await investmentService.acceptRisk();
      } catch (e) {
        // Non-blocking; deposit step will surface errors if still required.
      }
    }

    if (!refreshPlans) return;

    try {
      final fetched = await investmentService.fetchPlans();
      fetched.sort((a, b) => a.lockDays.compareTo(b.lockDays));
      if (fetched.isNotEmpty) {
        onPlansUpdated?.call(fetched);
      }
    } catch (_) {}
  }
}
