import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/transactions/vm/transactions_viewmodel.dart';
import 'package:dayfi/features/transactions/models/transaction_model.dart';

class TransactionsView extends ConsumerStatefulWidget {
  const TransactionsView({super.key});

  @override
  ConsumerState<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends ConsumerState<TransactionsView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transactionsViewModelProvider.notifier).loadTransactions();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionsState = ref.watch(transactionsViewModelProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: const SizedBox.shrink(),
        leadingWidth: 0,
        title: Text(
          "Transactions",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontFamily: 'CabinetGrotesk',
            fontSize: 28.00,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          // Container(
          //   color: const Color(0xffFEF9F3),
          //   padding: EdgeInsets.all(16.w),
          //   child: Container(
          //     height: 48.h,
          //     decoration: BoxDecoration(
          //       color: AppColors.neutral100,
          //       borderRadius: BorderRadius.circular(12.r),
          //     ),
          //     child: TextField(
          //       controller: _searchController,
          //       decoration: InputDecoration(
          //         hintText: 'Search transactions',
          //         hintStyle: AppTypography.bodyMedium.copyWith(
          //           color: AppColors.neutral400,
          //         ),
          //         prefixIcon: Icon(
          //           Icons.search,
          //           color: AppColors.neutral400,
          //           size: 20.sp,
          //         ),
          //         border: InputBorder.none,
          //         contentPadding: EdgeInsets.symmetric(
          //           horizontal: 16.w,
          //           vertical: 12.h,
          //         ),
          //       ),
          //       onChanged: (value) {
          //         ref.read(transactionsViewModelProvider.notifier).searchTransactions(value);
          //       },
          //     ),
          //   ),
          // ),

          // // Transactions List
          // Expanded(
          //   child: transactionsState.isLoading
          //       ? _buildLoadingState()
          //       : transactionsState.filteredTransactions.isEmpty
          //           ? _buildEmptyState()
          //           : _buildTransactionsList(transactionsState),
          // ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary500),
          SizedBox(height: 16.h),
          Text(
            'Loading transactions...',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.neutral600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              color: AppColors.neutral400,
              size: 32.sp,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'No transactions yet',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.neutral700,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Your transaction history will appear here',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.neutral500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(TransactionsState state) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: state.filteredTransactions.length,
      itemBuilder: (context, index) {
        final transaction = state.filteredTransactions[index];
        final isFirstInGroup =
            index == 0 ||
            _getDateString(transaction.date) !=
                _getDateString(state.filteredTransactions[index - 1].date);

        return Column(
          children: [
            if (isFirstInGroup) ...[
              SizedBox(height: index == 0 ? 16.h : 24.h),
              _buildDateHeader(transaction.date),
              SizedBox(height: 12.h),
            ],
            _buildTransactionCard(transaction),
            if (index == state.filteredTransactions.length - 1)
              SizedBox(height: 16.h),
          ],
        );
      },
    );
  }

  Widget _buildDateHeader(DateTime date) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        _getDateString(date),
        style: AppTypography.labelMedium.copyWith(
          color: AppColors.neutral600,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: _getStatusColor(transaction.status).withOpacity(0.2),
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
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(transaction.status),
              color: _getStatusColor(transaction.status),
              size: 20.sp,
            ),
          ),

          SizedBox(width: 12.w),

          // Transaction Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.recipientName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  _getStatusText(transaction.status),
                  style: AppTypography.bodySmall.copyWith(
                    color: _getStatusColor(transaction.status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Amount
          Text(
            '₦${transaction.amount.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return AppColors.warning500;
      case TransactionStatus.completed:
        return AppColors.success500;
      case TransactionStatus.failed:
        return AppColors.error500;
      case TransactionStatus.requiresAction:
        return AppColors.primary500;
    }
  }

  IconData _getStatusIcon(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return Icons.schedule;
      case TransactionStatus.completed:
        return Icons.check_circle;
      case TransactionStatus.failed:
        return Icons.error;
      case TransactionStatus.requiresAction:
        return Icons.warning;
    }
  }

  String _getStatusText(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return 'Processing';
      case TransactionStatus.completed:
        return 'Completed';
      case TransactionStatus.failed:
        return 'Failed';
      case TransactionStatus.requiresAction:
        return 'Requires action';
    }
  }

  String _getDateString(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Today';
    } else if (transactionDate == yesterday) {
      return 'Yesterday';
    } else {
      final months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      return '${date.day}th ${months[date.month - 1]} ${date.year}';
    }
  }
}
