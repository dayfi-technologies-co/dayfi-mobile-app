import 'dart:async';

import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/helpers/transaction_completion_flow.dart';
import 'package:dayfi/common/helpers/transaction_pin_flow.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/dayfi_screen_app_bar.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/invest/constants/invest_copy.dart';
import 'package:dayfi/features/invest/helpers/invest_interest_accrual.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/services/remote/investment_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class InvestmentPositionDetailView extends ConsumerStatefulWidget {
  final InvestmentPosition position;

  const InvestmentPositionDetailView({
    super.key,
    required this.position,
  });

  @override
  ConsumerState<InvestmentPositionDetailView> createState() =>
      _InvestmentPositionDetailViewState();
}

class _InvestmentPositionDetailViewState
    extends ConsumerState<InvestmentPositionDetailView> {
  late InvestmentPosition _position;
  bool _claiming = false;
  Timer? _accrualTimer;

  @override
  void initState() {
    super.initState();
    _position = widget.position;
    _accrualTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted || _position.status == 'claimed') return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _accrualTimer?.cancel();
    super.dispose();
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '—';
    return DateFormat('d MMM yyyy').format(d.toLocal());
  }

  String _headerSubtitle(InvestmentPosition p) {
    if (p.status == 'claimed') {
      if (p.claimedAt != null) {
        return 'Claimed ${_formatDate(p.claimedAt)}';
      }
      return 'Claimed';
    }
    if (p.canClaim) {
      final matures = _formatDate(p.maturesAt);
      return matures == '—' ? 'Ready to claim' : 'Ready to claim · Matured $matures';
    }
    final matures = _formatDate(p.maturesAt);
    if (p.daysRemaining > 0 && matures != '—') {
      return 'Matures $matures · ${p.daysRemaining} days left';
    }
    if (matures != '—') return 'Matures $matures';
    return '';
  }

  String _statusLabel() {
    if (_position.status == 'claimed') return 'Claimed';
    if (_position.canClaim) return 'Ready to claim';
    if (_position.daysRemaining <= 0) return 'Matured';
    return 'Active';
  }

  Color _statusColor(BuildContext context) {
    if (_position.canClaim) return AppColors.success500;
    if (_position.status == 'claimed') {
      return Theme.of(context).colorScheme.onSurface.withOpacity(0.45);
    }
    return AppColors.primary400;
  }

  double _lockProgress() {
    final start = _position.startedAt;
    final end = _position.maturesAt;
    if (start == null || end == null) return 0;
    final total = end.difference(start).inMilliseconds;
    if (total <= 0) return 1;
    final elapsed = DateTime.now().difference(start).inMilliseconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  String _statusHeadline() {
    final amount = '\$${_position.principal.toStringAsFixed(2)}';
    if (_position.status == 'claimed') {
      return 'You claimed $amount to your USD wallet';
    }
    if (_position.canClaim) {
      return 'Your $amount lock is ready to claim';
    }
    if (_position.daysRemaining <= 0) {
      return 'Your $amount lock has matured';
    }
    if (_position.daysRemaining > 0) {
      return 'Your $amount lock is active and will mature in '
          '${_position.daysRemaining} days';
    }
    return 'Your $amount lock is active';
  }

  Future<void> _claim() async {
    setState(() => _claiming = true);
    final amount = _position.principal;
    final ok = await TransactionPinFlow.requestPinAndRun<bool>(
      context: context,
      ref: ref,
      returnRoute: AppRoute.investView,
      task: (pin) async {
        await investmentService.claimPosition(
          positionId: _position.id,
          pin: pin,
        );
        return true;
      },
    );
    if (!mounted) return;
    setState(() => _claiming = false);
    if (ok != true) return;

    await TransactionCompletionFlow.pushSuccess(
      context,
      screen: TransactionCompletionFlow.investClaimSuccess(amount: amount),
    );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final p = _position;
    final periodPct = p.periodReturnPercent;
    final headerSubtitle = _headerSubtitle(p);
    final accrued = InvestInterestAccrual.accruedInterest(p);
    final showLiveAccrual = p.status != 'claimed' && !p.canClaim;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: DayfiScreenAppBar(title: InvestCopy.detailTitle),
      body: Align(
        alignment: Alignment.topCenter,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isWide ? 500 : double.infinity,
              ),
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 24 : 18,
                  vertical: 16,
                ),
                children: [
                  _buildLockHeader(p, headerSubtitle),
                  if (p.status != 'claimed' && p.maturesAt != null) ...[
                    const SizedBox(height: 16),
                    _buildLockProgress(p),
                  ],
                  const SizedBox(height: 24),
                  _buildStatusCard(),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    context,
                    title: 'Returns',
                    children: [
                      if (showLiveAccrual)
                        _buildDetailRow(
                          context,
                          'Earned so far',
                          InvestInterestAccrual.formatAmount(accrued),
                          valueColor: Colors.green.shade400,
                        ),
                      _buildDetailRow(
                        context,
                        showLiveAccrual
                            ? 'Interest at maturity'
                            : 'Estimated interest',
                        '\$${p.interestEarned.toStringAsFixed(2)}',
                        valueColor: showLiveAccrual
                            ? null
                            : Colors.green.shade400,
                      ),
                      _buildDetailRow(
                        context,
                        'Total at maturity',
                        '\$${p.totalPayout.toStringAsFixed(2)}',
                      ),
                      _buildDetailRow(
                        context,
                        'Period return',
                        '~${periodPct.toStringAsFixed(2)}% for this lock',
                      ),
                      _buildDetailRow(
                        context,
                        'APY (yearly)',
                        '${p.apyPercent.toStringAsFixed(2)}%',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    context,
                    title: 'Timeline',
                    children: [
                      _buildDetailRow(
                        context,
                        'Started',
                        _formatDate(p.startedAt),
                      ),
                      _buildDetailRow(
                        context,
                        'Matures',
                        _formatDate(p.maturesAt),
                      ),
                      if (p.claimedAt != null)
                        _buildDetailRow(
                          context,
                          'Claimed',
                          _formatDate(p.claimedAt),
                        ),
                      _buildDetailRow(
                        context,
                        'Lock duration',
                        '${p.lockDays} days',
                      ),
                      _buildDetailRow(
                        context,
                        'Status',
                        _statusLabel(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    context,
                    title: 'Reference',
                    children: [
                      _buildDetailRow(
                        context,
                        'Position ID',
                        p.id.length > 12 ? '${p.id.substring(0, 8)}…' : p.id,
                      ),
                      _buildDetailRow(context, 'Currency', 'USD'),
                    ],
                  ),
                  if (p.canClaim) ...[
                    const SizedBox(height: 24),
                    PrimaryButton(
                      text: 'Claim to USD wallet',
                      onPressed: _claiming ? null : _claim,
                      isLoading: _claiming,
                      fullWidth: true,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      borderRadius: 38,
                      height: 48,
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Hero — amount + icon row, no container (matches [TransactionDetailsView]).
  Widget _buildLockHeader(InvestmentPosition p, String headerSubtitle) {
    final amountText = '\$${p.principal.toStringAsFixed(2)}';
    final amountMain = amountText.split('.').first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          amountMain,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontFamily: 'FunnelDisplay',
                fontSize: 24,
                letterSpacing: -.25,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/svgs/account.svg',
                    height: 40,
                    color: AppColors.primary400,
                  ),
                  Center(
                    child: SvgPicture.asset(
                      'assets/icons/svgs/clock-dollar.svg',
                      height: 22,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          p.name.isNotEmpty ? p.name : 'Investment lock',
                          style: AppTypography.bodyLarge.copyWith(
                            fontFamily: 'Chirp',
                            fontSize: 16,
                            letterSpacing: -.25,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(context).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _statusLabel(),
                          style: TextStyle(
                            fontFamily: 'Chirp',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _statusColor(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${p.lockDays}-day lock · ${p.apyPercent.toStringAsFixed(1)}% APY',
                    style: AppTypography.bodyMedium.copyWith(
                      fontFamily: 'Chirp',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -.4,
                      height: 1.45,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                  ),
                  if (headerSubtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      headerSubtitle,
                      style: AppTypography.bodyMedium.copyWith(
                        fontFamily: 'Chirp',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -.4,
                        height: 1.45,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLockProgress(InvestmentPosition p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _lockProgress(),
            minHeight: 6,
            backgroundColor: Theme.of(context)
                .colorScheme
                .onSurface
                .withOpacity(0.08),
            color: AppColors.primary400,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          p.canClaim
              ? 'Lock period complete'
              : '${p.daysRemaining} days until maturity',
          style: TextStyle(
            fontFamily: 'Chirp',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    final isComplete = _position.canClaim || _position.status == 'claimed';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: isComplete ? AppColors.success500 : AppColors.primary400,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isComplete
                  ? SvgPicture.asset(
                      'assets/icons/svgs/circle-check.svg',
                      width: 10,
                      height: 10,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    )
                  : Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _statusHeadline(),
                  style: AppTypography.bodyMedium.copyWith(
                    fontFamily: 'Chirp',
                    fontSize: 14,
                    letterSpacing: -0.2,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              fontFamily: 'Chirp',
              fontSize: 12.5,
              letterSpacing: -.25,
              height: 1.2,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                value,
                style: AppTypography.bodyMedium.copyWith(
                  fontFamily: 'Chirp',
                  fontSize: 16,
                  letterSpacing: -.4,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
