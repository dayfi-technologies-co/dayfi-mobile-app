import 'dart:async';

import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/dayfi_empty_state.dart';
import 'package:dayfi/common/widgets/dayfi_refresh_scroll_view.dart';
import 'package:dayfi/common/widgets/dayfi_screen_app_bar.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/invest/constants/invest_copy.dart';
import 'package:dayfi/features/invest/helpers/invest_interest_accrual.dart';
import 'package:dayfi/features/invest/helpers/invest_position_display.dart';
import 'package:dayfi/features/invest/invest_deposit_flow.dart';
import 'package:dayfi/features/invest/views/investment_position_detail_view.dart';
import 'package:dayfi/features/invest/widgets/invest_position_list_tile.dart';
import 'package:dayfi/services/remote/investment_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class InvestView extends ConsumerStatefulWidget {
  /// When true, embedded without a back button (legacy tab layout).
  final bool showAsTab;
  final VoidCallback? onDataChanged;

  const InvestView({super.key, this.showAsTab = false, this.onDataChanged});

  @override
  ConsumerState<InvestView> createState() => _InvestViewState();
}

class _InvestViewState extends ConsumerState<InvestView> {
  InvestmentSummary? _summary;
  bool _loading = true;
  Timer? _accrualTimer;

  @override
  void initState() {
    super.initState();
    _load();
    _accrualTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted || _summary == null) return;
      final hasAccruingLocks = _visiblePositions(_summary!)
          .any((p) => p.status != 'claimed' && !p.canClaim);
      if (hasAccruingLocks) setState(() {});
    });
  }

  @override
  void dispose() {
    _accrualTimer?.cancel();
    super.dispose();
  }

  Future<void> _load({bool showFullLoader = true}) async {
    if (showFullLoader) setState(() => _loading = true);
    try {
      final s = await investmentService.fetchSummary();
      if (mounted) setState(() => _summary = s);
    } catch (e) {
      if (mounted) {
        TopSnackbar.show(
          context,
          message: 'Could not load locks',
          isError: true,
        );
      }
      rethrow;
    } finally {
      if (mounted && showFullLoader) setState(() => _loading = false);
    }
  }

  Future<void> _refresh() => _load(showFullLoader: false);

  Future<void> _deposit() => InvestDepositFlow.start(
    context: context,
    ref: ref,
    summary: _summary,
    showBackButton: true,
    onSuccess: () {
      _load();
      widget.onDataChanged?.call();
    },
  );

  Future<void> _openPositionDetail(InvestmentPosition position) async {
    final refreshed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => InvestmentPositionDetailView(position: position),
      ),
    );
    if (refreshed == true) _load();
  }

  List<InvestmentPosition> _visiblePositions(InvestmentSummary s) {
    return s.positions.where((p) => p.status != 'claimed').toList()
      ..sort((a, b) {
        if (a.canClaim != b.canClaim) return a.canClaim ? -1 : 1;
        return (b.maturesAt ?? DateTime.now()).compareTo(
          a.maturesAt ?? DateTime.now(),
        );
      });
  }

  String _balanceSubtitle(
    InvestmentSummary? s,
    List<InvestmentPosition> positions,
  ) {
    final apy = s?.apyDisplayPercent.toStringAsFixed(0) ?? '20';
    final apyLine = 'Earn up to $apy% APY · paid at maturity';
    if (s != null && s.lockedPrincipal > 0) {
      final accrued = InvestInterestAccrual.totalAccrued(positions);
      final interestPart = accrued > 0
          ? '${InvestInterestAccrual.formatAmount(accrued)} interest · '
          : '';
      return 'Saved \$${s.lockedPrincipal.toStringAsFixed(2)} · '
          '$interestPart$apyLine';
    }
    return 'Earn up to $apy% APY from your USD balance';
  }

  @override
  Widget build(BuildContext context) {
    final s = _summary;
    final positions = s != null ? _visiblePositions(s) : <InvestmentPosition>[];
    final headerBalance = s != null
        ? InvestInterestAccrual.totalDisplayBalance(s, positions)
        : 0.0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: DayfiScreenAppBar(
        title: InvestCopy.featureName,
        showBackButton: !widget.showAsTab,
      ),
      body:
          _loading
              ? Center(
                child: LoadingAnimationWidget.horizontalRotatingDots(
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              )
              : DayfiRefreshScrollView(
                onRefresh: _refresh,
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                InvestPositionDisplay.iconAsset,
                                height: 18,
                                color: InvestPositionDisplay.iconColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                InvestCopy.pocketLabel.toUpperCase(),
                                style: TextStyle(
                                  fontFamily: 'Chirp',
                                  fontSize: 12.5,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge!.color!.withOpacity(.85),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -.04,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '\$${headerBalance.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 38.0,
                              height: 1,
                              fontFamily: 'Chirp',
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            _balanceSubtitle(s, positions),
                            style: TextStyle(
                              fontFamily: 'Chirp',
                              fontSize: 12.5,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge!.color!.withOpacity(.55),
                              fontWeight: FontWeight.w600,
                              letterSpacing: -.04,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: PrimaryButton(
                        text: InvestCopy.createCta,
                        onPressed: _deposit,
                        fullWidth: true,
                        height: 48,
                        borderRadius: 38,
                        backgroundColor: AppColors.purple500ForTheme(context),
                        textColor: AppColors.neutral0,
                        fontFamily: 'Chirp',
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -.7,
                      ),
                    ),
                    if (s != null && !s.riskAccepted)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          'First deposit accepts risk disclosure automatically.',
                          style: TextStyle(
                            fontFamily: 'Chirp',
                            fontSize: 12.5,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Text(
                          InvestCopy.listTitle,
                          style: TextStyle(
                            fontFamily: 'Chirp',
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.color?.withOpacity(0.85),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (positions.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${positions.length}',
                              style: const TextStyle(
                                fontFamily: 'Chirp',
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (positions.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: DayfiEmptyState(
                          title: InvestCopy.emptyTitle,
                          message: InvestCopy.emptyMessage,
                          actionText: InvestCopy.createCta,
                          onAction: _deposit,
                        ),
                      )
                    else
                      InvestPositionGroupSection(
                        positions: positions,
                        onPositionTap: _openPositionDetail,
                      ),
                    const SizedBox(height: 112),
                      ]),
                    ),
                  ),
                ],
              ),
    );
  }
}
