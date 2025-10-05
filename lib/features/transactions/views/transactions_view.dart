import 'package:dayfi/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/features/transactions/vm/transactions_viewmodel.dart';
import 'package:dayfi/models/wallet_transaction.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class TransactionsView extends ConsumerStatefulWidget {
  const TransactionsView({super.key});

  @override
  ConsumerState<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends ConsumerState<TransactionsView> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transactionsProvider.notifier).loadTransactions();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh transactions when app comes back to foreground
      _refreshTransactions();
    }
  }

  void _refreshTransactions() {
    ref.read(transactionsProvider.notifier).loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final transactionsState = ref.watch(transactionsProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: const SizedBox.shrink(),
          leadingWidth: 0,
          title: Text(
            "Transactions",
            style: AppTypography.titleLarge.copyWith(
              fontFamily: 'CabinetGrotesk',
              fontSize: 28.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          centerTitle: true,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            _refreshTransactions();
          },
          child: Column(
            children: [
            // Search Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              child: CustomTextField(
                controller: _searchController,
                label: '',
                hintText: 'Search transactions',
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                  size: 20.sp,
                ),
                onChanged: (value) {
                  ref
                      .read(transactionsProvider.notifier)
                      .searchTransactions(value);
                },
              ),
            ),

            // Transactions List
            Expanded(
              child: Padding(
                padding: EdgeInsetsGeometry.only(bottom: 0.h),
                child:
                    transactionsState.isLoading
                        ? Center(
                          child: LoadingAnimationWidget.horizontalRotatingDots(
                            color: AppColors.purple500,
                            size: 20,
                          ),
                        )
                        : transactionsState.errorMessage != null
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Icon(
                              //   Icons.error_outline,
                              //   size: 48.sp,
                              //   color: Theme.of(
                              //     context,
                              //   ).colorScheme.onSurface.withOpacity(0.6),
                              // ),
                              // SizedBox(height: 16.h),
                              Text(
                                'Failed to load transactions',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.copyWith(
                                  fontFamily: 'CabinetGrotesk',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18.sp,
                                  height: 1.4,
                                  letterSpacing: -.4,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.8),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                transactionsState.errorMessage!,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.copyWith(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Karla',
                                  letterSpacing: -.6,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                        : transactionsState.groupedTransactions.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Icon(
                              //   Icons.receipt_long_outlined,
                              //   size: 48.sp,
                              //   color: Theme.of(
                              //     context,
                              //   ).colorScheme.onSurface.withOpacity(0.6),
                              // ),
                              // SizedBox(height: 16.h),
                              Text(
                                'No transactions found',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.copyWith(
                                  fontFamily: 'CabinetGrotesk',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18.sp,
                                  height: 1.4,
                                  letterSpacing: -.4,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.8),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          itemCount:
                              transactionsState.groupedTransactions.length,
                          itemBuilder: (context, index) {
                            final group =
                                transactionsState.groupedTransactions[index];
                            return _buildTransactionGroup(group);
                          },
                        ),
              ),
            ),
        ],
      ),
          ),
        ),
    );
  }

  Widget _buildTransactionGroup(TransactionGroup group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Header
        Padding(
          padding: EdgeInsets.only(bottom: 12.h, top: 8.h),
          child: Text(
            group.date,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontFamily: 'Karla',
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),

        // Transactions for this date
        ...group.transactions.map(
          (transaction) => _buildTransactionCard(transaction),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(WalletTransaction transaction) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          // Status Icon
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: _getStatusColor(transaction.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              _getStatusIcon(transaction.status),
              color: _getStatusColor(transaction.status),
              size: 20.sp,
            ),
          ),
          SizedBox(width: 16.w),

          // Transaction Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.beneficiary.name,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontFamily: 'Karla',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _getStatusText(transaction.status),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Karla',
                    fontSize: 14.sp,
                    color: _getStatusColor(transaction.status),
                  ),
                ),
                if (transaction.reason != null && transaction.reason!.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    transaction.reason!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'Karla',
                      fontSize: 12.sp,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Amount
          Text(
            _getTransactionAmount(transaction),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontFamily: 'Karla',
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success-collection':
        return AppColors.success500;
      case 'pending':
        return AppColors.warning500;
      case 'failed':
        return AppColors.error500;
      default:
        return AppColors.neutral500;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'success-collection':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'failed':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'success-collection':
        return 'Completed';
      case 'pending':
        return 'Pending';
      case 'failed':
        return 'Failed';
      default:
        return 'Unknown';
    }
  }

  String _getTransactionAmount(WalletTransaction transaction) {
    // Use actual amounts from the transaction data
    if (transaction.sendAmount != null && transaction.sendAmount! > 0) {
      return 'NGN ${transaction.sendAmount!.toStringAsFixed(2)}';
    } else if (transaction.receiveAmount != null && transaction.receiveAmount! > 0) {
      return 'NGN ${transaction.receiveAmount!.toStringAsFixed(2)}';
    } else {
      return 'N/A';
    }
  }
}
