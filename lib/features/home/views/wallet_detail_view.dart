// wallet_detail_view.dart
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/helpers/wallet_transaction_display.dart';
import 'package:dayfi/common/utils/haptic_helper.dart';
import 'package:dayfi/common/widgets/empty_state_widget.dart';
import 'package:dayfi/common/widgets/shimmer_widgets.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/send/send_flow.dart';
import 'package:dayfi/features/transactions/vm/transactions_viewmodel.dart';
import 'package:dayfi/features/transactions/widgets/wallet_transaction_list_tile.dart';
import 'package:dayfi/features/wallet/views/wallet_receive_view.dart';
import 'package:dayfi/models/wallet_transaction.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WalletDetailView extends ConsumerStatefulWidget {
  final String name;
  final String currency;
  final String symbol;
  final String flagPath;
  final double balance;

  const WalletDetailView({
    super.key,
    required this.name,
    required this.currency,
    required this.symbol,
    required this.flagPath,
    required this.balance,
  });

  @override
  ConsumerState<WalletDetailView> createState() => _WalletDetailViewState();
}

class _WalletDetailViewState extends ConsumerState<WalletDetailView> {
  bool _isBalanceVisible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final txs = ref.read(transactionsProvider).transactions;
      if (txs.isEmpty) {
        ref
            .read(transactionsProvider.notifier)
            .loadTransactions(isInitialLoad: true);
      }
    });
  }

  // ─── Formatters ─────────────────────────────────────────────────────────────

  String _formatNumber(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final dec = parts.length > 1 ? parts[1] : '00';
    final buf = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(',');
      buf.write(intPart[i]);
    }
    return '$buf.$dec';
  }

  // ─── Pending totals ──────────────────────────────────────────────────────────

  /// Sum of pending inflows for this wallet's currency.
  double _pendingIn(List<WalletTransaction> txs) => txs
      .where(
        (t) =>
            WalletTransactionDisplay.belongsToWallet(t, widget.currency) &&
            t.status.toLowerCase().contains('pending') &&
            t.status.toLowerCase().contains('collection'),
      )
      .fold(0.0, (sum, t) => sum + (t.receiveAmount ?? t.sendAmount ?? 0));

  /// Sum of pending outflows for this wallet's currency.
  double _pendingOut(List<WalletTransaction> txs) => txs
      .where(
        (t) =>
            WalletTransactionDisplay.belongsToWallet(t, widget.currency) &&
            t.status.toLowerCase().contains('pending') &&
            t.status.toLowerCase().contains('payment'),
      )
      .fold(0.0, (sum, t) => sum + (t.sendAmount ?? 0));

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final transactionsState = ref.watch(transactionsProvider);
    final isLoading = transactionsState.isLoading;

    final txList =
        List<WalletTransaction>.from(transactionsState.transactions)
            .where(
              (tx) =>
                  WalletTransactionDisplay.belongsToWallet(tx, widget.currency),
            )
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final grouped = WalletTransactionDisplay.groupByDateLabel(txList);
    final dateKeys = grouped.keys.toList();

    final pendingIn = _pendingIn(transactionsState.transactions);
    final pendingOut = _pendingOut(transactionsState.transactions);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ── Pull to refresh ─────────────────────────────────────────────────
          CupertinoSliverRefreshControl(
            onRefresh: () async {
              HapticHelper.lightImpact();
              await ref.read(transactionsProvider.notifier).loadTransactions();
            },
          ),

          // ── Header block ─────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildBalanceCard(pendingIn, pendingOut),
                  const SizedBox(height: 24),
                  _buildActionRow(),
                  const SizedBox(height: 18),
                  _buildTransactionHeader(txList.length),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),

          // ── Transaction list ─────────────────────────────────────────────────
          if (isLoading && txList.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: ShimmerWidgets.transactionListShimmer(
                  context,
                  itemCount: 6,
                ),
              ),
            )
          else if (txList.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 80),
                child: EmptyStateWidget(
                  icon: Icons.receipt_long_outlined,
                  title: 'No transactions yet',
                  message:
                      'Your ${widget.currency} wallet activity will appear here',
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, sectionIndex) {
                  final label = dateKeys[sectionIndex];
                  return WalletTransactionGroupSection(
                    dateLabel: label,
                    transactions: grouped[label]!,
                  );
                },
                childCount: dateKeys.length,
              ),
            ),

          // Bottom padding so last item isn't behind nav bar.
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // ─── App bar ─────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onPressed: () => appRouter.pop(),
        icon: Icon(
          Icons.arrow_back_ios,
          size: 20,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ClipOval(
          //   child: SvgPicture.asset(
          //     widget.flagPath,
          //     width: 28,
          //     height: 28,
          //     fit: BoxFit.cover,
          //   ),
          // ),
          // const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.name,
                style: AppTypography.titleMedium.copyWith(
                  fontFamily: 'Chirp',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -.2,
                  height: 1.3,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                widget.currency,
                style: AppTypography.titleMedium.copyWith(
                  fontFamily: 'Chirp',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
      centerTitle: true,
    );
  }

  // ─── Balance card ─────────────────────────────────────────────────────────────

  Widget _buildBalanceCard(double pendingIn, double pendingOut) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Visibility toggle row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Balance   '.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Chirp',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -.04,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.55),
                ),
              ),
              GestureDetector(
                onTap: () => setState(
                  () => _isBalanceVisible = !_isBalanceVisible,
                ),
                child: SvgPicture.asset(
                  _isBalanceVisible
                      ? 'assets/icons/svgs/eye.svg'
                      : 'assets/icons/svgs/eye-closed.svg',
                  height: 20,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Amount
          _isBalanceVisible
              ? RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: widget.symbol,
                      style: _balanceStyle(context, 30),
                    ),
                    TextSpan(
                      text: _formatNumber(widget.balance).split('.')[0],
                      style: _balanceStyle(context, 40),
                    ),
                    TextSpan(
                      text:
                          '.${_formatNumber(widget.balance).split('.').length > 1 ? _formatNumber(widget.balance).split('.')[1] : '00'}',
                      style: _balanceStyle(context, 40),
                    ),
                  ],
                ),
              )
              : Text(
                '*****',
                style: TextStyle(
                  fontSize: 40,
                  height: 1,
                  fontFamily: 'Chirp',
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: -1.2,
                ),
              ),

          const SizedBox(height: 14),

          // Pending chips — only show if there's something pending
          if (pendingIn > 0 || pendingOut > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (pendingIn > 0)
                  _pendingChip(
                    label: 'Pending in',
                    value:
                        _isBalanceVisible
                            ? '${widget.symbol}${_formatNumber(pendingIn)}'
                            : '***',
                    color: AppColors.success600,
                    bgColor: AppColors.success600.withOpacity(0.08),
                  ),
                if (pendingIn > 0 && pendingOut > 0) const SizedBox(width: 12),
                if (pendingOut > 0)
                  _pendingChip(
                    label: 'Pending out',
                    value:
                        _isBalanceVisible
                            ? '${widget.symbol}${_formatNumber(pendingOut)}'
                            : '***',
                    color: AppColors.warning600,
                    bgColor: AppColors.warning600.withOpacity(0.08),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  TextStyle _balanceStyle(BuildContext context, double size) => TextStyle(
    fontSize: size,
    height: 1,
    fontFamily: 'Chirp',
    fontWeight: FontWeight.w600,
    color: Theme.of(context).colorScheme.onSurface,
    letterSpacing: -1,
  );

  Widget _pendingChip({
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule_rounded, size: 13, color: color),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Chirp',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Chirp',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Action row ───────────────────────────────────────────────────────────────
  // Mirrors home_view action buttons exactly: orange icon, surface container,
  // 'Chirp' label. No custom sheet needed — reuses openSendFromWallet.

  Widget _buildActionRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Expanded(
            child: _actionButton(
              label: 'Send',
              icon: 'assets/icons/svgs/brand-telegram.svg',
              onTap: () => openSendFromWallet(context, widget.currency),
            ),
          ),
          Expanded(
            child: _actionButton(
              label: 'Add',
              icon: 'assets/icons/svgs/add_c.svg',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WalletReceiveView(
                    currency: widget.currency,
                    symbol: widget.symbol,
                    name: widget.name,
                    flagPath: widget.flagPath,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required String icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(icon,height: 28, color: AppColors.orange500),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                height: 1.3,
                fontFamily: 'Chirp',
                fontSize: 12.5,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Transaction header ───────────────────────────────────────────────────────

  Widget _buildTransactionHeader(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Transactions',
            style: TextStyle(
              fontFamily: 'Chirp',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
              height: 1.45,
              color: Theme.of(
                context,
              ).textTheme.bodyLarge!.color!.withOpacity(0.85),
            ),
          ),
          if (count > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontFamily: 'Chirp',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}