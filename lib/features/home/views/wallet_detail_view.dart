// wallet_detail_view.dart
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/utils/haptic_helper.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/transactions/vm/transactions_viewmodel.dart';
import 'package:dayfi/models/wallet_transaction.dart';
import 'package:dayfi/features/wallet/views/wallet_receive_view.dart';
import 'package:dayfi/features/wallet/views/wallet_convert_view.dart';
import 'package:dayfi/features/send/send_flow.dart';
import 'package:dayfi/routes/route.dart';
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

  String _formatNumber(double amount) {
    String formatted = amount.toStringAsFixed(2);
    List<String> parts = formatted.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : '00';
    String formattedInteger = '';
    for (int i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        formattedInteger += ',';
      }
      formattedInteger += integerPart[i];
    }
    return '$formattedInteger.$decimalPart';
  }

  String _formatDate(String timestamp) {
    try {
      final date = DateTime.parse(timestamp).add(const Duration(hours: 1));
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final hour =
          date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
      final minute = date.minute.toString().padLeft(2, '0');
      final period = date.hour >= 12 ? 'PM' : 'AM';
      return '${months[date.month - 1]} ${date.day}  •  $hour:$minute $period';
    } catch (_) {
      return '';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success-collection' || 'success-payment':
        return AppColors.success500;
      case 'pending-collection' || 'pending-payment':
        return AppColors.warning500;
      case 'failed-collection' || 'failed-payment':
        return AppColors.error500;
      default:
        return AppColors.neutral500;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'success-collection' || 'success-payment':
        return 'Completed';
      case 'pending-collection' || 'pending-payment':
        return 'Pending';
      case 'failed-collection' || 'failed-payment':
        return 'Failed';
      default:
        return 'Unknown';
    }
  }

  bool _isIncoming(WalletTransaction tx) =>
      tx.status.toLowerCase().contains('collection');

  void _showSendOptionsSheet() {
    HapticHelper.lightImpact();
    showModalBottomSheet(
      context: context,
      // ignore: deprecated_member_use
      barrierColor: Colors.black.withOpacity(0.85),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => _SendOptionsSheet(
            currency: widget.currency,
            symbol: widget.symbol,
            parentContext: context,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionsState = ref.watch(transactionsProvider);

    // Filter transactions roughly by currency — show all for now
    final txList = List<WalletTransaction>.from(transactionsState.transactions)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
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
        title: Text(
          widget.currency,
          style: AppTypography.titleMedium.copyWith(
            fontFamily: 'FunnelDisplay',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Balance card ──────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'AVAILABLE BALANCE',
                              style: TextStyle(
                                fontFamily: 'Chirp',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.45),
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap:
                                  () => setState(
                                    () =>
                                        _isBalanceVisible = !_isBalanceVisible,
                                  ),
                              child: SvgPicture.asset(
                                _isBalanceVisible
                                    ? "assets/icons/svgs/eye.svg"
                                    : "assets/icons/svgs/eye-closed.svg",
                                height: 20,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge!.color!.withOpacity(0.45),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _isBalanceVisible
                            ? RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: widget.symbol,
                                    style: TextStyle(
                                      fontSize: 40,
                                      height: 1,
                                      fontFamily: 'Chirp',
                                      fontWeight: FontWeight.w500,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                      letterSpacing: -1,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        _formatNumber(
                                          widget.balance,
                                        ).split('.')[0],
                                    style: TextStyle(
                                      fontSize: 44,
                                      height: 1,
                                      fontFamily: 'Chirp',
                                      fontWeight: FontWeight.w500,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                      letterSpacing: -2,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        '.${_formatNumber(widget.balance).split('.').length > 1 ? _formatNumber(widget.balance).split('.')[1] : '00'}',
                                    style: TextStyle(
                                      fontSize: 44,
                                      height: 1,
                                      fontFamily: 'Chirp',
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.45),
                                      letterSpacing: -2,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : Text(
                              '*****',
                              style: TextStyle(
                                fontSize: 44,
                                height: 1,
                                fontFamily: 'Chirp',
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onSurface,
                                letterSpacing: -1.2,
                              ),
                            ),

                        const SizedBox(height: 16),

                        // Pending in / out row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _pendingChip(
                              label: 'Pending in',
                              value: '${widget.symbol}0.00',
                              color: AppColors.success500,
                            ),
                            const SizedBox(width: 12),
                            _pendingChip(
                              label: 'Pending out',
                              value: '${widget.symbol}0.00',
                              color: AppColors.warning500,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Action buttons ────────────────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.1,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _actionButton(
                            label: 'Add',
                            icon: Icons.add_rounded,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => WalletReceiveView(
                                    currency: widget.currency,
                                    symbol: widget.symbol,
                                    name: widget.name,
                                    flagPath: widget.flagPath,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),

                        Expanded(
                          child: _actionButton(
                            label: 'Send',
                            icon: Icons.arrow_upward_rounded,
                            onTap: () =>
                                openSendFromWallet(context, widget.currency),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _actionButton(
                            label: 'Convert',
                            icon: Icons.swap_horiz_rounded,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const WalletConvertView(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // const SizedBox(height: 32),

                  // // ── Transactions header ───────────────────────────
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text(
                  //       'Recent transactions'.toUpperCase(),
                  //       style: AppTypography.labelLarge.copyWith(
                  //         color: Theme.of(
                  //           context,
                  //         ).textTheme.bodyLarge!.color!.withOpacity(0.85),
                  //         fontSize: 11,
                  //         fontWeight: FontWeight.w500,
                  //         fontFamily: 'Chirp',
                  //         letterSpacing: -0.20,
                  //         height: 1.2,
                  //       ),
                  //     ),
                  //     if (txList.isNotEmpty)
                  //       GestureDetector(
                  //         onTap:
                  //             () => Navigator.pushNamed(
                  //               context,
                  //               AppRoute.transactionsView,
                  //             ),
                  //         child: Text(
                  //           'See all',
                  //           style: TextStyle(
                  //             fontFamily: 'Chirp',
                  //             fontSize: 13,
                  //             fontWeight: FontWeight.w500,
                  //             color: Theme.of(context).colorScheme.primary,
                  //           ),
                  //         ),
                  //       ),
                  //   ],
                  // ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ── Transaction list ──────────────────────────────────────
          // if (txList.isEmpty)
          //   SliverFillRemaining(
          //     hasScrollBody: false,
          //     child: Center(
          //       child: Padding(
          //         padding: const EdgeInsets.only(top: 48),
          //         child: Column(
          //           mainAxisSize: MainAxisSize.min,
          //           children: [
          //             Icon(
          //               Icons.receipt_long_outlined,
          //               size: 40,
          //               color: Theme.of(
          //                 context,
          //               ).colorScheme.onSurface.withOpacity(0.2),
          //             ),
          //             const SizedBox(height: 12),
          //             Text(
          //               'Nothing to show',
          //               style: TextStyle(
          //                 fontFamily: 'Chirp',
          //                 fontSize: 14,
          //                 fontWeight: FontWeight.w500,
          //                 color: Theme.of(
          //                   context,
          //                 ).colorScheme.onSurface.withOpacity(0.4),
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   )
          // else
          //   SliverPadding(
          //     padding: const EdgeInsets.fromLTRB(18, 0, 18, 112),
          //     sliver: SliverList(
          //       delegate: SliverChildBuilderDelegate((context, index) {
          //         final tx = txList[index];
          //         final incoming = _isIncoming(tx);
          //         return _txRow(tx, incoming);
          //       }, childCount: txList.length),
          //     ),
          //   ),
        ],
      ),
    );
  }

  Widget _pendingChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Chirp',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Chirp',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              size: 24,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              height: 1.3,
              fontFamily: 'Chirp',
              letterSpacing: -0.20,
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _txRow(WalletTransaction tx, bool incoming) {
    final amount =
        tx.sendAmount != null && tx.sendAmount! > 0
            ? tx.sendAmount!
            : (tx.receiveAmount ?? 0.0);

    return InkWell(
      onTap:
          () => appRouter.pushNamed(
            AppRoute.transactionDetailsView,
            arguments: tx,
          ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (incoming ? AppColors.success500 : AppColors.warning500)
                    .withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                incoming
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                size: 18,
                color: incoming ? AppColors.success500 : AppColors.warning500,
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    incoming
                        ? 'Money received'
                        : 'Sent to ${tx.beneficiary.name}',
                    style: TextStyle(
                      fontFamily: 'Chirp',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.20,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(tx.timestamp),
                    style: TextStyle(
                      fontFamily: 'Chirp',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.45),
                    ),
                  ),
                ],
              ),
            ),

            // Amount + status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${incoming ? '+' : '-'}${widget.symbol}${_formatNumber(amount)}',
                  style: TextStyle(
                    fontFamily: 'Chirp',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                    color:
                        incoming
                            ? AppColors.success500
                            : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getStatusText(tx.status),
                  style: TextStyle(
                    fontFamily: 'Chirp',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _getStatusColor(tx.status),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Send Options Bottom Sheet ────────────────────────────────────────────────

class _SendOptionsSheet extends StatelessWidget {
  final String currency;
  final String symbol;
  final BuildContext parentContext;

  const _SendOptionsSheet({
    required this.currency,
    required this.symbol,
    required this.parentContext,
  });

  void _afterPop(VoidCallback action) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!parentContext.mounted) return;
      action();
    });
  }

  @override
  Widget build(BuildContext context) {
    final options = [
      (
        icon: Icons.account_balance_rounded,
        title: 'Send to a bank account',
        subtitle: 'Send to a new or previous bank recipient',
        onTap: () {
          Navigator.pop(context);
          _afterPop(
            () => appRouter.pushNamed(AppRoute.selectDestinationCountryView),
          );
        },
        enabled: true,
      ),
      (
        icon: Icons.phone_android_rounded,
        title: 'Send using mobile money',
        subtitle: 'Send instantly to mobile money wallets',
        onTap: () {
          Navigator.pop(context);
          _afterPop(
            () => appRouter.pushNamed(AppRoute.selectDestinationCountryView),
          );
        },
        enabled: true,
      ),
      (
        icon: Icons.currency_bitcoin_rounded,
        title: 'Send via crypto',
        subtitle: 'Send USDC through different networks',
        onTap: () {
          Navigator.pop(context);
          _afterPop(
            () => appRouter.pushNamed(AppRoute.sendFetchCryptoChannelsView),
          );
        },
        enabled: true,
      ),
      (
        icon: Icons.alternate_email_rounded,
        title: 'Send via Dayfi Tag',
        subtitle: 'Send instantly using a @dayfi tag',
        onTap: () {
          Navigator.pop(context);
          _afterPop(
            () => appRouter.pushNamed(
              AppRoute.sendDayfiIdView,
              arguments: <String, dynamic>{},
            ),
          );
        },
        enabled: true,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          // Drag handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Send money',
                  style: TextStyle(
                    fontFamily: 'FunnelDisplay',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              'Choose how you\'d like to send $currency.',
              style: TextStyle(
                fontFamily: 'Chirp',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.2,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.55),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Options list
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: List.generate(options.length, (i) {
                final opt = options[i];
                return Column(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.vertical(
                        top: i == 0 ? const Radius.circular(14) : Radius.zero,
                        bottom:
                            i == options.length - 1
                                ? const Radius.circular(14)
                                : Radius.zero,
                      ),
                      onTap: opt.enabled ? opt.onTap : null,
                      child: Opacity(
                        opacity: opt.enabled ? 1.0 : 0.4,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  opt.icon,
                                  size: 20,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      opt.title,
                                      style: TextStyle(
                                        fontFamily: 'Chirp',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: -0.20,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      opt.subtitle,
                                      style: TextStyle(
                                        fontFamily: 'Chirp',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: -0.1,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 18,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.3),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (i < options.length - 1)
                      Divider(
                        height: 1,
                        indent: 68,
                        color: Theme.of(context).dividerColor.withOpacity(0.06),
                      ),
                  ],
                );
              }),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
