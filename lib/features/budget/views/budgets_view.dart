import 'dart:async';

import 'package:dayfi/common/utils/request_timeout.dart';
import 'package:dayfi/common/widgets/dayfi_empty_state.dart';
import 'package:dayfi/common/widgets/dayfi_screen_app_bar.dart';
import 'package:dayfi/common/widgets/shimmer_widgets.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/budget/helpers/budget_amount_format.dart';
import 'package:dayfi/features/budget/models/budget_models.dart';
import 'package:dayfi/features/budget/services/budget_list_cache.dart';
import 'package:dayfi/features/budget/views/budget_detail_view.dart';
import 'package:dayfi/features/budget/views/create_budget_type_view.dart';
import 'package:dayfi/services/remote/budget_service.dart';
import 'package:flutter/material.dart';

class BudgetsView extends StatefulWidget {
  const BudgetsView({super.key});

  @override
  State<BudgetsView> createState() => _BudgetsViewState();
}

class _BudgetsViewState extends State<BudgetsView> {
  List<Budget> _budgets = [];
  bool _loading = false;
  String? _loadError;

  bool get _showFullLoader => _loading && _budgets.isEmpty;

  @override
  void initState() {
    super.initState();
    final cached = BudgetListCache.instance.peekAny();
    if (cached != null) {
      _budgets = cached;
    }
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

  Future<void> _load({bool showFullLoader = true}) async {
    if (showFullLoader && _budgets.isEmpty) {
      setState(() {
        _loading = true;
        _loadError = null;
      });
    }
    try {
      final rows = await withScreenFetchTimeout(budgetService.fetchBudgets());
      BudgetListCache.instance.put(rows);
      if (mounted) {
        setState(() {
          _budgets = rows;
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
        TopSnackbar.show(context, message: message, isError: true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DayfiFeatureScaffold(
      title: 'Budgets',
      body:
          _showFullLoader
              ? ShimmerWidgets.recipientListShimmer(
                context,
                itemCount: 4,
                padding: EdgeInsets.symmetric(horizontal: 18),
              )
              : RefreshIndicator(
                onRefresh: () => _load(showFullLoader: false),
                child:
                    _budgets.isEmpty
                        ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.45,
                              child: _loadError != null
                                  ? _BudgetsErrorState(
                                    message: _loadError!,
                                    onRetry: () => _load(),
                                  )
                                  : DayfiEmptyStateBody(
                                    title: 'No budgets yet',
                                    message:
                                        'Schedule sends, bills, spending caps, Daily Earn deposits, or one-time reminders.',
                                    actionText: 'Create budget',
                                    onAction: _openCreateBudget,
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
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate((
                                  context,
                                  i,
                                ) {
                                  final b = _budgets[i];
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom: i < _budgets.length - 1 ? 10 : 0,
                                    ),
                                    child: _BudgetCard(
                                      budget: b,
                                      onTap: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => BudgetDetailView(
                                                  budgetId: b.id,
                                                  initialBudget: b,
                                                ),
                                          ),
                                        );
                                        if (mounted) {
                                          _load(showFullLoader: false);
                                        }
                                      },
                                    ),
                                  );
                                }, childCount: _budgets.length),
                              ),
                            ),
                          ],
                        ),
              ),
      bottomNavigationBar:
          _budgets.isEmpty
              ? null
              : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(56, 0, 64, 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _openCreateBudget,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.purple500ForTheme(context),
                        foregroundColor: AppColors.neutral0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(38),
                        ),
                      ),
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: const Text(
                        'New budget',
                        style: TextStyle(
                          fontFamily: 'Chirp',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                  ),
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

class _BudgetCard extends StatelessWidget {
  final Budget budget;
  final VoidCallback onTap;

  const _BudgetCard({required this.budget, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      budget.name,
                      style: const TextStyle(
                        fontFamily: 'Chirp',
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.25,
                      ),
                    ),
                  ),
                  _StatusChip(
                    label: budget.isPaused ? 'Paused' : budget.frequency,
                    isPaused: budget.isPaused,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                budget.typeLabel,
                style: TextStyle(
                  fontFamily: 'Chirp',
                  fontSize: 13,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    formatBudgetAmount(budget.amount, budget.currency),
                    style: const TextStyle(
                      fontFamily: 'FunnelDisplay',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  if (budget.nextRunLabel != null)
                    Text(
                      budget.nextRunLabel!,
                      style: TextStyle(
                        fontFamily: 'Chirp',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary400,
                      ),
                    ),
                ],
              ),
              if (budget.spentAmount > 0) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: budget.progressPercent / 100,
                    minHeight: 5,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.08),
                    color: AppColors.primary400,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${formatBudgetAmount(budget.spentAmount, budget.currency)} spent',
                  style: TextStyle(
                    fontFamily: 'Chirp',
                    fontSize: 12.5,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.45),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool isPaused;

  const _StatusChip({required this.label, required this.isPaused});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            isPaused
                ? AppColors.warning500.withOpacity(0.12)
                : AppColors.success500.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Chirp',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isPaused ? AppColors.warning600 : AppColors.success600,
        ),
      ),
    );
  }
}
