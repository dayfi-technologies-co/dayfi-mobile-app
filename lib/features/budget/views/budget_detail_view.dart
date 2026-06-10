import 'dart:async';

import 'package:dayfi/common/utils/request_timeout.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/buttons/secondary_button.dart';
import 'package:dayfi/common/widgets/dayfi_loading_indicator.dart';
import 'package:dayfi/common/widgets/dayfi_screen_app_bar.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/budget/constants/budget_copy.dart';
import 'package:dayfi/features/budget/helpers/budget_amount_format.dart';
import 'package:dayfi/features/budget/models/budget_models.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_schedule_from_budget.dart';
import 'package:dayfi/services/remote/budget_service.dart';
import 'package:flutter/material.dart';

class BudgetDetailView extends StatefulWidget {
  final String budgetId;
  final Budget? initialBudget;

  const BudgetDetailView({
    super.key,
    required this.budgetId,
    this.initialBudget,
  });

  @override
  State<BudgetDetailView> createState() => _BudgetDetailViewState();
}

class _BudgetDetailViewState extends State<BudgetDetailView> {
  Budget? _budget;
  bool _loading = false;
  bool _busy = false;
  String? _loadError;

  bool get _showFullLoader => _loading && _budget == null;

  @override
  void initState() {
    super.initState();
    _budget = widget.initialBudget;
    _loading = _budget == null;
    _load(showFullLoader: _budget == null);
  }

  Future<void> _load({bool showFullLoader = true}) async {
    if (showFullLoader && _budget == null) {
      setState(() {
        _loading = true;
        _loadError = null;
      });
    }
    try {
      final b = await withScreenFetchTimeout(
        budgetService.fetchBudget(widget.budgetId),
      );
      if (mounted) {
        setState(() {
          _budget = b;
          _loadError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        final message =
            e is TimeoutException
                ? 'Could not load budget. Check your connection and try again.'
                : '$e';
        setState(() => _loadError = message);
        TopSnackbar.show(context, message: message, isError: true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _togglePause() async {
    final b = _budget;
    if (b == null) return;
    setState(() => _busy = true);
    try {
      final updated =
          b.isPaused
              ? await budgetService.resume(b.id)
              : await budgetService.pause(b.id);
      if (mounted) {
        setState(() => _budget = updated);
        TopSnackbar.show(
          context,
          message: updated.isPaused ? 'Budget paused' : 'Budget resumed',
        );
      }
    } catch (e) {
      if (mounted) TopSnackbar.show(context, message: '$e', isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancel() async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text(
              'Delete budget?',
              style: TextStyle(fontFamily: 'Chirp'),
            ),
            content: const Text(
              'This budget will be removed. You can create a new one anytime.',
              style: TextStyle(fontFamily: 'Chirp'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Keep'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    if (ok != true) return;

    setState(() => _busy = true);
    try {
      await budgetService.cancel(widget.budgetId);
      if (mounted) {
        TopSnackbar.show(context, message: 'Budget deleted');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) TopSnackbar.show(context, message: '$e', isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = _budget;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: DayfiScreenAppBar(title: b?.name ?? 'Budget'),
      body:
          _showFullLoader
              ? const DayfiLoadingCenter()
              : b == null
              ? _LoadErrorState(
                message: _loadError ?? 'Budget not found',
                onRetry: () => _load(),
              )
              : Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => _load(showFullLoader: false),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                        children: [
                          if (b.isManagedByDayFlow) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.teal500.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                BudgetCopy.managedInDayFlow,
                                style: TextStyle(
                                  fontFamily: 'Chirp',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.teal500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          _SummaryCard(budget: b),
                          const SizedBox(height: 12),
                          _DetailsCard(budget: b),
                        ],
                      ),
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                      child: Column(
                        children: [
                          if (b.isManagedByDayFlow)
                            PrimaryButton(
                              text: BudgetCopy.viewScheduledPayment,
                              onPressed:
                                  _busy
                                      ? null
                                      : () async {
                                        await DayFlowScheduleFromBudget.open(
                                          context,
                                          budget: b,
                                          onUpdated: () => _load(showFullLoader: false),
                                        );
                                      },
                              fullWidth: true,
                              borderRadius: 38,
                              height: 48,
                              backgroundColor: AppColors.purple500ForTheme(
                                context,
                              ),
                              textColor: AppColors.neutral0,
                              fontFamily: 'Chirp',
                              fontSize: 18,
                            )
                          else ...[
                            PrimaryButton(
                              text: b.isPaused ? 'Resume' : 'Pause',
                              onPressed: _busy ? null : _togglePause,
                              isLoading: _busy,
                              fullWidth: true,
                              borderRadius: 38,
                              height: 48,
                              backgroundColor: AppColors.purple500ForTheme(
                                context,
                              ),
                              textColor: AppColors.neutral0,
                              fontFamily: 'Chirp',
                              fontSize: 18,
                            ),
                            const SizedBox(height: 12),
                            SecondaryButton(
                              borderColor: Colors.transparent,
                              text: 'Delete budget',
                              onPressed: _busy ? null : _cancel,
                              fullWidth: true,
                              height: 52,
                              borderRadius: 12,
                              fontSize: 14,
                              textColor:
                                  Theme.of(context).colorScheme.onSurface,
                              fontFamily: 'Chirp',
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}

class _LoadErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _LoadErrorState({required this.message, required this.onRetry});

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
                style: TextStyle(fontFamily: 'Chirp', fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final Budget budget;

  const _SummaryCard({required this.budget});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            budget.typeLabel,
            style: TextStyle(
              fontFamily: 'Chirp',
              fontSize: 13,
              color: onSurface.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            budget.amountLabel,
            style: TextStyle(
              fontFamily: 'Chirp',
              fontSize: 12.5,
              color: onSurface.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formatBudgetAmount(budget.amount, budget.currency),
            style: const TextStyle(
              fontFamily: 'FunnelDisplay',
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            budget.frequencyLabel,
            style: const TextStyle(
              fontFamily: 'Chirp',
              fontWeight: FontWeight.w500,
            ),
          ),
          if (budget.nextRunLabel != null) ...[
            const SizedBox(height: 12),
            Text(
              budget.nextRunLabel!,
              style: TextStyle(
                fontFamily: 'Chirp',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary400,
              ),
            ),
          ],
          if (budget.spentAmount > 0) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: budget.progressPercent / 100,
                minHeight: 6,
                color: AppColors.primary400,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${formatBudgetAmount(budget.spentAmount, budget.currency)} spent · '
              '${formatBudgetAmount(budget.remainingAmount, budget.currency)} left',
              style: TextStyle(
                fontFamily: 'Chirp',
                fontSize: 13,
                color: onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ],
      ),
    );
  }

}

class _DetailsCard extends StatelessWidget {
  final Budget budget;

  const _DetailsCard({required this.budget});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final rows = budget.detailRows;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Budget details',
            style: AppTypography.bodySmall.copyWith(
              fontFamily: 'Chirp',
              fontSize: 12.5,
              letterSpacing: -.25,
              height: 1.2,
              fontWeight: FontWeight.w600,
              color: onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),
          for (final row in rows) _DetailRow(label: row.key, value: row.value),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final isNote = label == 'Note';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                fontFamily: 'Chirp',
                fontSize: 14,
                letterSpacing: -.4,
                fontWeight: FontWeight.w500,
                color: onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: AppTypography.bodyMedium.copyWith(
                  fontFamily: 'Chirp',
                  fontSize: isNote ? 13 : 14,
                  letterSpacing: -.4,
                  fontWeight: FontWeight.w600,
                  color:
                      isNote
                          ? onSurface.withValues(alpha: 0.55)
                          : onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
