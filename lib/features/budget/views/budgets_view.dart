import 'dart:async';

import 'package:dayfi/common/utils/request_timeout.dart';
import 'package:dayfi/common/widgets/dayfi_empty_state.dart';
import 'package:dayfi/common/widgets/dayfi_screen_app_bar.dart';
import 'package:dayfi/common/widgets/shimmer_widgets.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/features/budget/helpers/budget_navigation.dart';
import 'package:dayfi/features/budget/models/budget_models.dart';
import 'package:dayfi/features/budget/services/budget_list_cache.dart';
import 'package:dayfi/features/budget/views/create_budget_type_view.dart';
import 'package:dayfi/features/budget/widgets/budget_list_tile.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_schedule_from_budget.dart';
import 'package:dayfi/features/dayflow/models/dayflow_models.dart';
import 'package:dayfi/features/dayflow/services/dayflow_api_service.dart';
import 'package:dayfi/features/dayflow/services/dayflow_dashboard_cache.dart';
import 'package:dayfi/services/remote/budget_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BudgetsView extends StatefulWidget {
  const BudgetsView({super.key});

  @override
  State<BudgetsView> createState() => _BudgetsViewState();
}

class _BudgetsViewState extends State<BudgetsView> {
  List<Budget> _budgets = [];
  DayFlowDashboardSnapshot? _dayflowDash;
  bool _loading = false;
  String? _loadError;

  bool get _showShimmer => _loading && _budgets.isEmpty;

  DayBudgetScheduleInstance? _dayflowInstanceFor(Budget budget) {
    if (!budget.isManagedByDayFlow) return null;
    return DayFlowScheduleFromBudget.resolveInstance(
      budget,
      _dayflowDash?.scheduleInstances,
    );
  }

  List<Budget> _sortedBudgets(List<Budget> rows) {
    final sorted = List<Budget>.from(rows);
    sorted.sort((a, b) {
      return DayFlowScheduleFromBudget.compareByNextRun(
        a,
        b,
        _dayflowInstanceFor(a),
        _dayflowInstanceFor(b),
      );
    });
    return sorted;
  }

  @override
  void initState() {
    super.initState();
    final cached = BudgetListCache.instance.peekAny();
    if (cached != null) {
      _budgets = cached;
    }
    _dayflowDash = DayflowDashboardCache.instance.peek();
    _load(showFullLoader: _budgets.isEmpty);
  }

  Future<void> _openCreateBudget() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CreateBudgetTypeView()),
    );
    if (created == true) {
      BudgetListCache.instance.invalidate();
      await _load(showFullLoader: _budgets.isEmpty);
    }
  }

  Future<void> _onBudgetTap(Budget budget) async {
    await BudgetNavigation.openDetail(
      context,
      budget: budget,
      onUpdated: () => _load(showFullLoader: false),
    );
    if (mounted) await _load(showFullLoader: false);
  }

  Future<void> _load({bool showFullLoader = true}) async {
    if (showFullLoader && _budgets.isEmpty) {
      setState(() {
        _loading = true;
        _loadError = null;
      });
    }
    try {
      final rows = await withScreenFetchTimeout(budgetService.fetchBudgets());
      final hasDayFlowBudgets = rows.any((b) => b.isManagedByDayFlow);
      DayFlowDashboardSnapshot? dash =
          _dayflowDash ?? DayflowDashboardCache.instance.peek();
      if (hasDayFlowBudgets) {
        try {
          dash = await withScreenFetchTimeout(
            dayFlowApiService.fetchDashboard(),
          );
        } catch (_) {
          dash ??= DayflowDashboardCache.instance.peek();
        }
      }
      BudgetListCache.instance.put(rows);
      if (mounted) {
        setState(() {
          _dayflowDash = dash;
          _budgets = _sortedBudgets(rows);
          _loadError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        final message =
            e is TimeoutException
                ? 'Could not load budgets. Check your connection and try again.'
                : '$e';
        setState(() => _loadError = message);
        if (_budgets.isEmpty) {
          TopSnackbar.show(context, message: message, isError: true);
        }
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildAddBudgetAction(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 18),
      child: InkWell(
        onTap: _openCreateBudget,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/svgs/notificationn.svg',
              height: 40,
              color: Theme.of(context).colorScheme.surface,
            ),
            SizedBox(
              height: 40,
              width: 40,
              child: Center(
                child: Icon(
                  Icons.add,
                  size: 28,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DayfiFeatureScaffold(
      title: 'Budgets',
      actions: [_buildAddBudgetAction(context)],
      body:
          _showShimmer
              ? ShimmerWidgets.recipientListShimmer(
                context,
                itemCount: 4,
                padding: EdgeInsets.symmetric(horizontal: 18),
              )
              : RefreshIndicator(
                onRefresh: () => _load(showFullLoader: false),
                child:
                    _budgets.isEmpty
                        ? CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          slivers: [
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: Center(
                                child:
                                    _loadError != null
                                        ? _BudgetsErrorState(
                                          message: _loadError!,
                                          onRetry: () => _load(),
                                        )
                                        : DayfiEmptyState(
                                          title: 'No budgets yet',
                                          message:
                                              'Schedule sends, bills, spending caps, DayEarn deposits, or one-time reminders.',
                                          actionText: 'Create budget',
                                          onAction: _openCreateBudget,
                                        ),
                              ),
                            ),
                          ],
                        )
                        : CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          slivers: [
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
                              sliver: SliverToBoxAdapter(
                                child: Text(
                                  'Your budgets',
                                  style: TextStyle(
                                    fontFamily: 'Chirp',
                                    fontSize: 14,
                                    height: 1.4,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.55),
                                  ),
                                ),
                              ),
                            ),
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                              sliver: SliverToBoxAdapter(
                                child: BudgetListGroupSection(
                                  budgets: _budgets,
                                  dayflowInstanceFor: _dayflowInstanceFor,
                                  onBudgetTap: _onBudgetTap,
                                ),
                              ),
                            ),
                          ],
                        ),
              ),
    );
  }
}

class _BudgetsErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _BudgetsErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Chirp', fontSize: 15),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: const Text(
                'Try again',
                style: TextStyle(
                  fontFamily: 'Chirp',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
