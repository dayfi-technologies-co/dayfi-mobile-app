import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/utils/haptic_helper.dart';
import 'package:dayfi/common/widgets/dayfi_empty_state.dart';
import 'package:dayfi/common/widgets/dayfi_web_dialog.dart';
import 'package:dayfi/common/widgets/shimmer_widgets.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/dayflow/constants/dayflow_copy.dart';
import 'package:dayfi/features/dayflow/daybudget_flow.dart';
import 'package:dayfi/features/dayflow/dayflow_flow.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_analytics.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_schedule_actions.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_schedule_instances.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_schedule_list_helper.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_wallet_balance.dart';
import 'package:dayfi/features/dayflow/models/dayflow_models.dart';
import 'package:dayfi/features/dayflow/services/dayflow_api_service.dart';
import 'package:dayfi/features/dayflow/services/dayflow_dashboard_cache.dart';
import 'package:dayfi/features/dayflow/services/dayflow_local_store.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/features/dayflow/services/dayflow_reset_service.dart';
import 'package:dayfi/features/dayflow/services/dayflow_user_storage.dart';
import 'package:dayfi/features/dayflow/widgets/dayflow_schedule_list_tile.dart';
import 'package:dayfi/models/wallet_hub.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DayFlowMainView extends StatefulWidget {
  final VoidCallback? onDataChanged;

  const DayFlowMainView({super.key, this.onDataChanged});

  @override
  State<DayFlowMainView> createState() => _DayFlowMainViewState();
}

class _DayFlowMainViewState extends State<DayFlowMainView> {
  DayFlowDashboardSnapshot? _dashboard;
  bool _loading = true;
  String? _loadError;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final cached = DayflowDashboardCache.instance.peek();
    if (cached != null) {
      _dashboard = cached;
      _loading = false;
    }
    _load(showLoader: _dashboard == null);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  DayFlowPlan? _fallbackPlanFromFlows(List<DayFlowEnvelope> flows) {
    if (flows.isEmpty) return null;
    final categoryMap = <String, DayFlowCategory>{};
    for (final flow in flows) {
      for (final c in flow.categories) {
        final existing = categoryMap[c.name];
        if (existing == null) {
          categoryMap[c.name] = DayFlowCategory(
            name: c.name,
            allocated: c.allocated,
            spent: c.spent,
            locked: c.locked,
          );
        } else {
          categoryMap[c.name] = DayFlowCategory(
            name: c.name,
            allocated: existing.allocated + c.allocated,
            spent: existing.spent + c.spent,
            locked: existing.locked || c.locked,
          );
        }
      }
    }

    final upcoming = <DayFlowUpcomingPayment>[];
    for (final flow in flows) {
      for (final s in flow.schedules) {
        upcoming.add(
          DayFlowUpcomingPayment(
            title: s.title,
            amount: s.amount,
            currency: flow.currency,
            dueLabel: s.dueLabel ?? 'Scheduled',
            recipientHint: s.recipientHint,
            recipientId: s.recipientId,
            autoSend: s.autoPay,
          ),
        );
      }
    }

    final totalBudget = flows.fold<double>(0, (sum, f) => sum + f.totalAmount);
    final spent = flows.fold<double>(0, (sum, f) => sum + f.spentAmount);
    final remaining = flows.fold<double>(
      0,
      (sum, f) => sum + f.remainingAmount,
    );
    final categories =
        categoryMap.values.toList()
          ..sort((a, b) => b.allocated.compareTo(a.allocated));

    return DayFlowPlan(
      id: 'flows-summary',
      title: flows.length == 1 ? 'Flow Summary' : 'Active Flows Summary',
      periodLabel: 'This Month',
      budgetType: 'monthly',
      totalBudget: totalBudget,
      spent: spent,
      currency: kDayFlowWalletCurrency,
      summaryLine:
          flows.length == 1
              ? DayFlowCopy.onTrackSummary
              : '${flows.length} active flows running',
      categories: categories,
      upcoming: upcoming,
      goals: const [],
      lockedCategories:
          categories.where((c) => c.locked).map((c) => c.name).toList(),
      leftover: remaining,
    );
  }

  Future<void> _load({bool showLoader = true}) async {
    if (showLoader) {
      setState(() {
        _loading = true;
        _loadError = null;
      });
    }

    await DayFlowUserStorage.ensureUserScope();
    final localPlan = await DayFlowLocalStore.instance.loadCachedPlan();
    WalletHubSnapshot? hub;
    try {
      hub = await walletService.fetchWalletHub();
    } catch (_) {}

    try {
      final dash = await dayFlowApiService.fetchDashboard(
        localPlan: localPlan,
        localHub: hub,
      );

      if (mounted) {
        setState(() {
          _dashboard =
              dash ??
              (localPlan != null && hub != null
                  ? DayFlowAnalytics.buildLocalDashboard(
                    plan: localPlan,
                    hub: hub,
                    flows: const [],
                  )
                  : null);
          _loadError = null;
          if (showLoader) _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadError =
              'Could not load automations. Check your connection and try again.';
          if (showLoader) _loading = false;
        });
      }
    }
  }

  DayBudgetScheduleInstances _resolveInstances(
    DayFlowDashboardSnapshot? dash,
    List<DayFlowEnvelope> flows,
    DayFlowPlan? plan,
  ) {
    // Prefer server-computed instances so pull-to-refresh stays in sync with api.dayfi.co.
    if (dash != null) {
      return dash.scheduleInstances;
    }
    return collectLocalScheduleInstances(flows: flows, plan: plan);
  }

  Future<void> _onInstanceTap(DayBudgetScheduleInstance item) async {
    await DayFlowScheduleActions.handleTap(
      context,
      item,
      onUpdated: () {
        _load(showLoader: false);
        widget.onDataChanged?.call();
      },
    );
    if (mounted) {
      _load(showLoader: false);
      widget.onDataChanged?.call();
    }
  }

  Future<void> _addNewItem() async {
    HapticHelper.lightImpact();
    final created = await DayBudgetFlow.openAddAutomation(
      context,
      onActivated: () {
        _load(showLoader: false);
        widget.onDataChanged?.call();
      },
    );
    if (created && mounted) {
      await _load(showLoader: false);
      widget.onDataChanged?.call();
    }
  }

  Future<void> _startOver() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => DayfiWebAlertDialog(
            title: Text(DayFlowCopy.startOver),
            content: Text(DayFlowCopy.startOverConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(DayFlowCopy.startOver),
              ),
            ],
          ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await DayFlowResetService.startOver();
      if (!mounted) return;
      setState(() {
        _dashboard = null;
        _searchQuery = '';
        _searchController.clear();
      });
      await _load(showLoader: false);
      widget.onDataChanged?.call();
      if (mounted) {
        TopSnackbar.showSafe(
          context,
          message: DayFlowCopy.startOverDone,
          isError: false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      TopSnackbar.showSafe(
        context,
        message: e.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    }
  }

  Future<void> _openCreateAutomation() async {
    final created = await DayBudgetFlow.openCreateAutomation(
      context,
      onActivated: () {
        _load(showLoader: false);
        widget.onDataChanged?.call();
      },
    );
    if (created && mounted) {
      await _load(showLoader: false);
      widget.onDataChanged?.call();
    }
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title, {
    required double horizontal,
    double top = 8,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontal, top, horizontal, 4),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'FunnelDisplay',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.75),
        ),
      ),
    );
  }

  Widget _buildScheduleList(DayFlowScheduleListData listData, bool isWide) {
    if (listData.isEmpty && _searchQuery.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            SvgPicture.asset(
              'assets/icons/svgs/search-normal.svg',
              height: 64,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.45),
            ),
            const SizedBox(height: 16),
            Text(
              'No scheduled payments found',
              style: AppTypography.bodyMedium.copyWith(
                fontFamily: 'FunnelDisplay',
                fontSize: 16,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    final horizontal = isWide ? 24.0 : 18.0;
    final hasUpcoming = listData.upcomingGroups.isNotEmpty;
    final hasPast = listData.pastGroups.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasUpcoming) ...[
          _buildSectionTitle(
            context,
            DayFlowCopy.upcomingSection,
            horizontal: horizontal,
          ),
          for (final group in listData.upcomingGroups)
            DayFlowScheduleDateGroupSection(
              dateLabel: group.dateLabel,
              items: group.items,
              horizontalPadding: horizontal,
              onItemTap: _onInstanceTap,
            ),
        ],
        if (hasPast) ...[
          _buildSectionTitle(
            context,
            DayFlowCopy.pastSection,
            horizontal: horizontal,
            top: hasUpcoming ? 20 : 8,
          ),
          for (final group in listData.pastGroups)
            DayFlowScheduleDateGroupSection(
              dateLabel: group.dateLabel,
              items: group.items,
              horizontalPadding: horizontal,
              muted: true,
              onItemTap: _onInstanceTap,
            ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dash = _dashboard;
    final plan = dash?.plan;
    final flows = dash?.flows.where((f) => f.isActive).toList() ?? [];
    final effectivePlan = plan ?? _fallbackPlanFromFlows(flows);
    final instances = _resolveInstances(dash, flows, effectivePlan);
    final listData = buildScheduleListData(
      instances,
      searchQuery: _searchQuery,
    );
    final hasSetup =
        flows.isNotEmpty ||
        effectivePlan != null ||
        instances.upcoming.isNotEmpty ||
        instances.past.isNotEmpty;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          leadingWidth: 72,
          scrolledUnderElevation: .5,
          foregroundColor: Theme.of(context).scaffoldBackgroundColor,
          shadowColor: Theme.of(context).scaffoldBackgroundColor,
          surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          leading: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () => DayFlowFlow.popToMain(context),
            child: Stack(
              alignment: AlignmentGeometry.center,
              children: [
                SvgPicture.asset(
                  "assets/icons/svgs/notificationn.svg",
                  height: 40,
                  color: Theme.of(context).colorScheme.surface,
                ),
                SizedBox(
                  height: 40,
                  width: 40,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Icon(
                        Icons.arrow_back_ios,
                        size: 20,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                        // size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          title: Text(
            DayFlowCopy.featureName,
            style: AppTypography.titleLarge.copyWith(
              fontFamily: 'FunnelDisplay',
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          centerTitle: true,
          actions: [
            if (hasSetup) ...[
              // PopupMenuButton<String>(
              //   icon: Icon(
              //     Icons.more_horiz,
              //     color: Theme.of(context).colorScheme.onSurface,
              //   ),
              //   onSelected: (value) {
              //     if (value == 'start_over') _startOver();
              //   },
              //   itemBuilder:
              //       (ctx) => [
              //         PopupMenuItem(
              //           value: 'start_over',
              //           child: Text(
              //             DayFlowCopy.clearAllUpcoming,
              //             style: TextStyle(
              //               fontFamily: 'Chirp',
              //               color: Theme.of(ctx).colorScheme.error,
              //               fontWeight: FontWeight.w600,
              //             ),
              //           ),
              //         ),
              //       ],
              // ),
             
              Padding(
                padding: const EdgeInsets.only(right: 18),
                child: InkWell(
                  onTap: _addNewItem,
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
              ),
            ],
          ],
        ),
        body:
            _loading
                ? ShimmerWidgets.dayBudgetMainShimmer(context)
                : LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 600;
                    final horizontal = isWide ? 24.0 : 18.0;

                    return CustomScrollView(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      slivers: [
                        CupertinoSliverRefreshControl(
                          onRefresh: () => _load(showLoader: false),
                        ),
                        SliverToBoxAdapter(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: isWide ? 500 : double.infinity,
                              ),
                              child:
                                  _loadError != null && _dashboard == null
                                      ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 48,
                                          horizontal: 18,
                                        ),
                                        child: DayfiEmptyState(
                                          title: 'Could not load',
                                          message: _loadError!,
                                          actionText: 'Try again',
                                          onAction: () => _load(showLoader: true),
                                        ),
                                      )
                                      : !hasSetup
                                      ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 48,
                                          horizontal: 18,
                                        ),
                                        child: DayfiEmptyState(
                                          title: DayFlowCopy.emptyTitle,
                                          message: DayFlowCopy.emptyMessage,
                                          actionText: DayFlowCopy.automatePayment,
                                          onAction: _openCreateAutomation,
                                        ),
                                      )
                                      : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(
                                              horizontal,
                                              8,
                                              horizontal,
                                              8,
                                            ),
                                            child: CustomTextField(
                                              isSearch: true,
                                              controller: _searchController,
                                              label: '',
                                              hintText:
                                                  'Search scheduled payments',
                                              borderRadius: 40,
                                              prefixIcon: Container(
                                                width: 40,
                                                alignment:
                                                    Alignment.centerRight,
                                                constraints:
                                                    const BoxConstraints.tightForFinite(),
                                                child: Center(
                                                  child: SvgPicture.asset(
                                                    'assets/icons/svgs/search-normal.svg',
                                                    height: 22,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface
                                                        .withValues(alpha: 0.6),
                                                  ),
                                                ),
                                              ),
                                              suffixIcon:
                                                  _searchQuery.isNotEmpty
                                                      ? GestureDetector(
                                                        onTap: () {
                                                          HapticHelper.lightImpact();
                                                          _searchController
                                                              .clear();
                                                          setState(
                                                            () =>
                                                                _searchQuery =
                                                                    '',
                                                          );
                                                        },
                                                        child: Container(
                                                          width: 40,
                                                          alignment:
                                                              Alignment
                                                                  .centerLeft,
                                                          constraints:
                                                              const BoxConstraints.tightForFinite(),
                                                          child: Center(
                                                            child: SvgPicture.asset(
                                                              'assets/icons/svgs/close-circle.svg',
                                                              height: 20,
                                                              color: Theme.of(
                                                                    context,
                                                                  )
                                                                  .colorScheme
                                                                  .onSurface
                                                                  .withValues(
                                                                    alpha: 0.6,
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                      : null,
                                              onChanged: (value) {
                                                setState(
                                                  () => _searchQuery = value,
                                                );
                                              },
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 0,
                                            ),
                                            child: _buildScheduleList(
                                              listData,
                                              isWide,
                                            ),
                                          ),
                                          const SizedBox(height: 32),
                                        ],
                                      ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
      ),
    );
  }
}
