import 'package:dayfi/features/dayflow/helpers/dayflow_format.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_schedule_instances.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_wallet_balance.dart';
import 'package:dayfi/features/dayflow/models/dayflow_models.dart';
import 'package:dayfi/models/wallet_hub.dart';

abstract final class DayFlowAnalytics {
  static DayFlowDashboardSnapshot buildLocalDashboard({
    required DayFlowPlan plan,
    WalletHubSnapshot? hub,
    List<DayFlowEnvelope> flows = const [],
  }) {
    final instances = collectLocalScheduleInstances(flows: flows, plan: plan);
    final committed = instances.committedThisPeriod;
    final availableInPlanCurrency = dayFlowWalletForBudget(hub, plan.currency);
    final freeToSpend =
        (availableInPlanCurrency - committed).clamp(0.0, double.infinity).toDouble();
    final safeToSpend = freeToSpend;
    final healthScore = _computeHealthScore(plan);
    final forecast = _computeForecast(availableInPlanCurrency, plan);
    final insights = _buildInsights(plan);

    return DayFlowDashboardSnapshot(
      walletBalance: dayFlowWalletBalance(hub),
      walletCurrency: kDayFlowWalletCurrency,
      safeToSpend: safeToSpend,
      freeToSpend: freeToSpend,
      committedThisPeriod: committed,
      budgetPeriodLabel: instances.periodLabel,
      scheduleInstances: instances,
      healthScore: healthScore,
      forecastMessage: forecast,
      insights: insights,
      plan: plan,
      flows: flows,
      hasActivePlan: true,
    );
  }

  static int _computeHealthScore(DayFlowPlan plan) {
    var score = 72;
    final progress =
        plan.totalBudget > 0 ? plan.spent / plan.totalBudget : 0;
    if (progress <= 0.5) {
      score += 12;
    } else if (progress <= 0.75) {
      score += 8;
    } else if (progress <= 0.9) {
      score += 3;
    } else if (progress > 1) {
      score -= 18;
    } else {
      score -= 6;
    }

    final overspent = plan.categories
        .where((c) => c.spent > c.allocated && c.allocated > 0)
        .length;
    score -= overspent * 8;

    if (plan.categories.any((c) =>
        RegExp(r'saving|emergency|invest', caseSensitive: false)
            .hasMatch(c.name))) {
      score += 6;
    }
    if (plan.goals.isNotEmpty) score += 4;

    return score.clamp(35, 98);
  }

  static String _computeForecast(double availableBalance, DayFlowPlan plan) {
    final now = DateTime.now();
    final daysElapsed = now.day.clamp(1, 31);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final dailyBurn = plan.spent / daysElapsed;
    if (dailyBurn <= 0) {
      return 'At your current pace, you could save ${formatDayFlowAmount(plan.remaining, plan.currency)} this period.';
    }
    final daysUntilLow = (availableBalance / dailyBurn).floor();
    if (daysUntilLow < (daysInMonth - now.day)) {
      return 'At your current pace, your balance may run low in about $daysUntilLow days.';
    }
    return 'At your current pace, you could save ${formatDayFlowAmount(plan.remaining, plan.currency)} this period.';
  }

  static List<String> _buildInsights(DayFlowPlan plan) {
    final insights = <String>[];
    for (final c in plan.categories) {
      if (c.allocated <= 0) continue;
      final pct = ((c.spent / c.allocated) * 100).round();
      if (pct >= 80 && pct < 100) {
        insights.add("You're nearing your ${c.name} budget ($pct% used).");
      }
      if (pct >= 100) {
        insights.add('${c.name} is over budget — consider adjusting.');
      }
    }
    if (plan.leftover > 0 && plan.sweepToDayEarn) {
      insights.add(
        'You have ${formatDayFlowAmount(plan.leftover, plan.currency)} that could move to DayEarn for yield.',
      );
    }
    if (insights.isEmpty) {
      insights.add(plan.summaryLine);
    }
    return insights.take(5).toList();
  }
}
