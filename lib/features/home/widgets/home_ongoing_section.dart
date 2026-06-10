import 'package:dayfi/common/constants/product_features.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/budget/helpers/budget_navigation.dart';
import 'package:dayfi/features/budget/models/budget_models.dart';
import 'package:dayfi/features/budget/services/budget_list_cache.dart';
import 'package:dayfi/features/budget/views/budgets_view.dart';
import 'package:dayfi/features/budget/widgets/budget_list_tile.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_schedule_from_budget.dart';
import 'package:dayfi/features/dayflow/models/dayflow_models.dart';
import 'package:dayfi/features/dayflow/services/dayflow_api_service.dart';
import 'package:dayfi/features/dayflow/services/dayflow_dashboard_cache.dart';
import 'package:dayfi/features/invest/constants/invest_copy.dart';
import 'package:dayfi/features/invest/views/investment_position_detail_view.dart';
import 'package:dayfi/features/invest/widgets/invest_position_list_tile.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/services/remote/budget_service.dart';
import 'package:dayfi/services/remote/investment_service.dart';
import 'package:flutter/material.dart';

/// Active locks and budgets below Assets on Home.
class HomeOngoingSection extends StatefulWidget {
  const HomeOngoingSection({super.key});

  @override
  State<HomeOngoingSection> createState() => _HomeOngoingSectionState();
}

class _HomeOngoingSectionState extends State<HomeOngoingSection> {
  List<Budget> _budgets = [];
  DayFlowDashboardSnapshot? _dayflowDash;
  InvestmentSummary? _investment;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  DayBudgetScheduleInstance? _dayflowInstanceFor(Budget budget) {
    if (!budget.isManagedByDayFlow) return null;
    return DayFlowScheduleFromBudget.resolveInstance(
      budget,
      _dayflowDash?.scheduleInstances,
    );
  }

  List<Budget> _sortedPreview(List<Budget> rows) {
    final active = rows.where((b) => b.isActive || b.isPaused).toList();
    active.sort((a, b) {
      return DayFlowScheduleFromBudget.compareByNextRun(
        a,
        b,
        _dayflowInstanceFor(a),
        _dayflowInstanceFor(b),
      );
    });
    return active.take(3).toList();
  }

  Future<void> _load() async {
    try {
      final allBudgets = await budgetService.fetchBudgets();
      InvestmentSummary? investment;
      if (ProductFeatures.investHomeOngoing) {
        investment = await investmentService.fetchSummary();
      }
      if (!mounted) return;
      BudgetListCache.instance.put(allBudgets);

      DayFlowDashboardSnapshot? dash = DayflowDashboardCache.instance.peek();
      try {
        dash ??= await dayFlowApiService.fetchDashboard();
      } catch (_) {}

      setState(() {
        _dayflowDash = dash;
        _budgets = _sortedPreview(allBudgets);
        _investment = investment;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openBudget(Budget budget) async {
    await BudgetNavigation.openDetail(
      context,
      budget: budget,
      onUpdated: _load,
    );
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox.shrink();

    final positions =
        ProductFeatures.investHomeOngoing
            ? (_investment?.positions
                    .where((p) => p.status == 'active' || p.status == 'matured')
                    .take(3)
                    .toList() ??
                [])
            : <InvestmentPosition>[];

    if (positions.isEmpty && _budgets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (positions.isNotEmpty) ...[
            _sectionHeader(
              context,
              title: InvestCopy.homeSectionTitle,
              onSeeAll: () =>
                  Navigator.pushNamed(context, AppRoute.investView),
            ),
            const SizedBox(height: 8),
            InvestPositionGroupSection(
              positions: positions,
              onPositionTap: (p) async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InvestmentPositionDetailView(position: p),
                  ),
                );
                _load();
              },
            ),
            const SizedBox(height: 20),
          ],
          if (_budgets.isNotEmpty) ...[
            _sectionHeader(
              context,
              title: 'Ongoing budgets',
              onSeeAll: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BudgetsView()),
              ),
            ),
            const SizedBox(height: 8),
            BudgetListGroupSection(
              budgets: _budgets,
              dayflowInstanceFor: _dayflowInstanceFor,
              showSpendProgress: false,
              onBudgetTap: _openBudget,
            ),
          ],
        ],
      ),
    );
  }

  Widget _sectionHeader(
    BuildContext context, {
    required String title,
    required VoidCallback onSeeAll,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Chirp',
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: onSeeAll,
          child: Text(
            'See all',
            style: AppTypography.bodyMedium.copyWith(
              fontFamily: 'Chirp',
              fontWeight: FontWeight.w600,
              color: AppColors.primary500,
            ),
          ),
        ),
      ],
    );
  }
}
