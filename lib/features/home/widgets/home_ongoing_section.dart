import 'package:dayfi/app_locator.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/budget/models/budget_models.dart';
import 'package:dayfi/features/budget/services/budget_list_cache.dart';
import 'package:dayfi/features/budget/views/budget_detail_view.dart';
import 'package:dayfi/features/budget/views/budgets_view.dart';
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
  InvestmentSummary? _investment;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        budgetService.fetchBudgets(),
        investmentService.fetchSummary(),
      ]);
      if (!mounted) return;
      final allBudgets = results[0] as List<Budget>;
      BudgetListCache.instance.put(allBudgets);
      setState(() {
        _budgets = allBudgets
            .where((b) => b.isActive || b.isPaused)
            .take(3)
            .toList();
        _investment = results[1] as InvestmentSummary;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox.shrink();

    final positions = _investment?.positions
            .where((p) => p.status == 'active' || p.status == 'matured')
            .take(3)
            .toList() ??
        [];

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
            ..._budgets.map(
              (b) => _budgetTile(context, b),
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

  Widget _budgetTile(BuildContext context, Budget b) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => BudgetDetailView(
                  budgetId: b.id,
                  initialBudget: b,
                ),
          ),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.name,
                      style: const TextStyle(
                        fontFamily: 'Chirp',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      b.isPaused ? 'Paused' : b.typeLabel,
                      style: TextStyle(
                        fontFamily: 'Chirp',
                        fontSize: 13,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${b.progressPercent}%',
                style: const TextStyle(
                  fontFamily: 'Chirp',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
