import 'dart:async';

import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/utils/request_timeout.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/dayfi_balance_header.dart';
import 'package:dayfi/common/widgets/dayfi_loading_indicator.dart';
import 'package:dayfi/common/widgets/dayfi_screen_app_bar.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/dayearn/constants/dayearn_copy.dart';
import 'package:dayfi/features/dayearn/helpers/dayearn_format.dart';
import 'package:dayfi/features/dayearn/views/dayearn_add_view.dart';
import 'package:dayfi/features/dayearn/views/dayearn_withdraw_view.dart';
import 'package:dayfi/services/remote/dayearn_service.dart';
import 'package:flutter/material.dart';
import 'package:dayfi/features/dayearn/widgets/dayearn_activity_list_tile.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DayEarnPotDetailView extends StatefulWidget {
  final String potId;
  final DayEarnPot? initialPot;

  const DayEarnPotDetailView({
    super.key,
    required this.potId,
    this.initialPot,
  });

  @override
  State<DayEarnPotDetailView> createState() => _DayEarnPotDetailViewState();
}

class _DayEarnPotDetailViewState extends State<DayEarnPotDetailView> {
  DayEarnPotDetail? _detail;
  bool _loading = false;

  bool get _showFullLoader => _loading && _detail == null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialPot;
    if (initial != null) {
      _detail = DayEarnPotDetail(pot: initial, activity: const []);
    } else {
      _loading = true;
    }
    _load(showFullLoader: initial == null);
  }

  Future<void> _load({bool showFullLoader = true}) async {
    if (showFullLoader && _detail == null) {
      setState(() => _loading = true);
    }
    try {
      final detail = await withScreenFetchTimeout(
        dayEarnService.fetchPot(widget.potId),
      );
      if (mounted) setState(() => _detail = detail);
    } catch (e) {
      if (mounted) {
        final message =
            e is TimeoutException
                ? 'Could not load pot. Check your connection and try again.'
                : 'Could not load pot';
        TopSnackbar.show(context, message: message, isError: true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _withdraw() async {
    final pot = _detail?.pot;
    if (pot == null) return;
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => DayEarnWithdrawView(potId: pot.id, pot: pot),
      ),
    );
    if (changed == true && mounted) {
      await _load(showFullLoader: false);
      if (!mounted) return;
      if (_detail == null) {
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _addMore() async {
    final pot = _detail?.pot;
    if (pot == null) return;
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => DayEarnAddView(potId: pot.id, pot: pot),
      ),
    );
    if (changed == true && mounted) _load(showFullLoader: false);
  }

  @override
  Widget build(BuildContext context) {
    final pot = _detail?.pot;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: DayfiScreenAppBar(
        title: pot?.name ?? DayEarnCopy.featureName,
        showBackButton: true,
      ),
      body:
          _showFullLoader
              ? const DayfiLoadingCenter()
              : pot == null
              ? const Center(child: Text('Pot not found'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DayfiBalanceHeaderCard(
                      label: '${pot.name} balance',
                      amount: pot.balance,
                      currency: kDayEarnCurrency,
                      currencySymbolFor: dayEarnCurrencySymbol,
                      leading: Row(
                        children: [
                          SvgPicture.asset(
                            dayEarnFlagAsset(),
                            width: 28,
                            height: 28,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            kDayEarnCurrency,
                            style: TextStyle(
                              fontFamily: 'Chirp',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: onSurface.withValues(alpha: 0.55),
                            ),
                          ),
                        ],
                      ),
                      footer: [
                        const SizedBox(height: 12),
                        Text(
                          formatDayEarnPotDetailInterestSummary(pot),
                          style: TextStyle(
                            fontFamily: 'Chirp',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.45,
                            color: onSurface.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            text: DayEarnCopy.withdrawCta,
                            onPressed: _withdraw,
                            fullWidth: true,
                            applyFeatureInset: false,
                            height: 48,
                            borderRadius: 38,
                            backgroundColor: Theme.of(context).colorScheme.surface,
                            textColor: onSurface,
                            fontFamily: 'Chirp',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: PrimaryButton(
                            text: DayEarnCopy.addMoreCta,
                            onPressed: _addMore,
                            fullWidth: true,
                            applyFeatureInset: false,
                            height: 48,
                            borderRadius: 38,
                            backgroundColor: AppColors.purple500ForTheme(context),
                            textColor: AppColors.neutral0,
                            fontFamily: 'Chirp',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontFamily: 'Chirp',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_detail!.activity.isEmpty)
                      Text(
                        'No activity yet',
                        style: TextStyle(
                          fontFamily: 'Chirp',
                          fontSize: 14,
                          color: onSurface.withValues(alpha: 0.5),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        child: Column(
                          children: [
                            for (int i = 0; i < _detail!.activity.length; i++)
                              DayEarnActivityListTile(
                                activity: _detail!.activity[i],
                                bottomMargin:
                                    i == _detail!.activity.length - 1 ? 8 : 24,
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
    );
  }
}
