import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/dayfi_empty_state.dart';
import 'package:dayfi/common/widgets/dayfi_balance_header.dart';
import 'package:dayfi/common/widgets/shimmer_widgets.dart';
import 'package:dayfi/common/widgets/dayfi_refresh_scroll_view.dart';
import 'package:dayfi/common/widgets/dayfi_screen_app_bar.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/dayearn/constants/dayearn_copy.dart';
import 'package:dayfi/core/navigation/dayfi_page_transitions.dart';
import 'package:dayfi/features/dayearn/dayearn_flow.dart';
import 'package:dayfi/features/dayearn/helpers/dayearn_format.dart';
import 'package:dayfi/features/dayearn/views/dayearn_pot_detail_view.dart';
import 'package:dayfi/features/dayearn/services/dayearn_summary_cache.dart';
import 'package:dayfi/services/remote/dayearn_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DayEarnMainView extends StatefulWidget {
  final bool showAsTab;
  final VoidCallback? onDataChanged;

  const DayEarnMainView({
    super.key,
    this.showAsTab = false,
    this.onDataChanged,
  });

  @override
  State<DayEarnMainView> createState() => _DayEarnMainViewState();
}

class _DayEarnMainViewState extends State<DayEarnMainView> {
  DayEarnSummary? _summary;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final cached = DayEarnSummaryCache.instance.peek();
    if (cached != null) {
      _summary = cached;
      _loading = false;
    }
    _load(showLoader: _summary == null);
  }

  Future<void> _load({bool showLoader = true}) async {
    if (showLoader) setState(() => _loading = true);
    try {
      final summary = await dayEarnService.fetchSummary(
        forceRefresh: !showLoader,
      );
      if (mounted) setState(() => _summary = summary);
    } catch (e) {
      if (mounted) {
        TopSnackbar.show(
          context,
          message: 'Could not load DayEarn',
          isError: true,
        );
      }
    } finally {
      if (mounted && showLoader) setState(() => _loading = false);
    }
  }

  Future<void> _create() async {
    await DayEarnFlow.openCreate(context);
    if (mounted) {
      await _load();
      widget.onDataChanged?.call();
    }
  }

  Future<void> _openPot(DayEarnPot pot) async {
    final changed = await Navigator.push<bool>(
      context,
      DayfiPageRoute<bool>(
        builder:
            (_) => DayEarnPotDetailView(
              potId: pot.id,
              initialPot: pot,
            ),
      ),
    );
    if (changed == true && mounted) {
      await _load(showLoader: false);
      widget.onDataChanged?.call();
    }
  }

  double? _headerAmount(DayEarnSummary? s) {
    if (s == null || s.pots.isEmpty) return 0;
    final currencies = s.pots.map((p) => p.currency.toUpperCase()).toSet();
    if (currencies.length != 1) return null;
    return s.pots.fold<double>(0, (sum, p) => sum + p.balance);
  }

  String? _headerAltText(DayEarnSummary? s) {
    if (s == null || s.pots.isEmpty) return null;
    if (s.pots.map((p) => p.currency.toUpperCase()).toSet().length > 1) {
      return '${s.pots.length} pots';
    }
    return null;
  }

  String _headerCurrency(DayEarnSummary? s) {
    if (s == null || s.pots.isEmpty) return kDayEarnCurrency;
    return dayEarnEffectiveCurrency(s.pots.first.currency);
  }

  String _headerInterest(DayEarnSummary? s) {
    if (s == null || s.pots.isEmpty) {
      return "Today's Interest ${formatDayEarnAmount(0, kDayEarnCurrency)}";
    }
    final allAwaiting = s.pots.every(dayEarnPotAwaitingFirstCredit);
    if (allAwaiting || s.todaysInterest <= 0) {
      return "Today's Interest ${formatDayEarnAmount(0, kDayEarnCurrency)}";
    }
    if (s.pots.length == 1) {
      final p = s.pots.first;
      return "Today's Interest +${formatDayEarnInterestAmount(p.todaysInterest, kDayEarnCurrency)}";
    }
    return "Today's Interest ${formatDayEarnCombinedTodaysInterest(s.pots)} (combined)";
  }

  String? _headerFirstCreditHint(DayEarnSummary? s) {
    if (s == null || s.pots.isEmpty) return null;
    if (!s.pots.every(dayEarnPotAwaitingFirstCredit)) return null;
    if (s.pots.length == 1) {
      return formatDayEarnFirstCreditLabel(s.pots.first);
    }
    return 'First interest pending on ${s.pots.length} pots';
  }

  @override
  Widget build(BuildContext context) {
    final s = _summary;
    final pots = s?.pots ?? [];
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: DayfiScreenAppBar(
        title: DayEarnCopy.featureName,
        showBackButton: !widget.showAsTab,
        onBack: widget.showAsTab ? null : () => DayEarnFlow.popToMain(context),
      ),
      body:
          _loading
              ? ShimmerWidgets.dayEarnMainShimmer(context)
              : DayfiRefreshScrollView(
                onRefresh: () => _load(showLoader: false),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        DayfiBalanceHeaderCard(
                          label: DayEarnCopy.totalBalanceLabel,
                          amount: _headerAmount(s),
                          currency: _headerCurrency(s),
                          currencySymbolFor: dayEarnCurrencySymbol,
                          altVisibleText: _headerAltText(s),
                          footer: [
                            const SizedBox(height: 12),
                            Text(
                              _headerInterest(s),
                              style: TextStyle(
                                fontFamily: 'Chirp',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color:
                                    (s?.todaysInterest ?? 0) > 0 &&
                                            !(s?.pots.every(
                                                  dayEarnPotAwaitingFirstCredit,
                                                ) ??
                                                true)
                                        ? AppColors.success600
                                        : onSurface.withValues(alpha: 0.55),
                              ),
                            ),
                            if (_headerFirstCreditHint(s) != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                _headerFirstCreditHint(s)!,
                                style: TextStyle(
                                  fontFamily: 'Chirp',
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: onSurface.withValues(alpha: 0.45),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),
                     Padding(padding: const EdgeInsets.symmetric(horizontal: 18), child:   PrimaryButton(
                          text: DayEarnCopy.createCta,
                          onPressed: _create,
                          fullWidth: true,
                          height: 48,
                          borderRadius: 38,
                          backgroundColor: AppColors.purple500ForTheme(
                            context,
                          ),
                          textColor: AppColors.neutral0,
                          fontFamily: 'Chirp',
                          fontSize: 17,
                        ),),
                        const SizedBox(height: 20),
                        if (pots.isEmpty)
                          DayfiEmptyState(
                            title: DayEarnCopy.emptyTitle,
                            message: DayEarnCopy.emptyMessage,
                          )
                        else
                          ...pots.map(
                            (pot) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _PotTile(
                                pot: pot,
                                onTap: () => _openPot(pot),
                              ),
                            ),
                          ),
                      ]),
                    ),
                  ),
                ],
              ),
    );
  }
}

class _PotTile extends StatelessWidget {
  final DayEarnPot pot;
  final VoidCallback onTap;

  const _PotTile({required this.pot, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              SvgPicture.asset(
                dayEarnFlagAsset(),
                width: 28,
                height: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pot.name,
                      style: TextStyle(
                        fontFamily: 'Chirp',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatDayEarnAmount(pot.balance, kDayEarnCurrency),
                      style: TextStyle(
                        fontFamily: 'Chirp',
                        fontSize: 13,
                        color: onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatDayEarnTodaysInterestLabel(pot),
                    style: TextStyle(
                      fontFamily: 'Chirp',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: onSurface.withValues(alpha: 0.45),
                    ),
                  ),
                  if (dayEarnPotAwaitingFirstCredit(pot)) ...[
                    const SizedBox(height: 2),
                    Text(
                      formatDayEarnFirstCreditLabel(
                        pot,
                      ).replaceFirst('First interest ', ''),
                      style: TextStyle(
                        fontFamily: 'Chirp',
                        fontSize: 10.5,
                        color: onSurface.withValues(alpha: 0.38),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
