import 'package:dayfi/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/common/widgets/shimmer_widgets.dart';
import 'package:dayfi/common/widgets/error_state_widget.dart';
import 'package:dayfi/common/widgets/empty_state_widget.dart';
import 'package:dayfi/common/utils/haptic_helper.dart';
import 'package:dayfi/common/utils/debouncer.dart';
import 'package:dayfi/features/transactions/vm/transactions_viewmodel.dart';
import 'package:dayfi/features/transactions/widgets/transaction_filter_bottom_sheet.dart';
import 'package:dayfi/models/wallet_transaction.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';

class TransactionsView extends ConsumerStatefulWidget {
  const TransactionsView({super.key});

  @override
  ConsumerState<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends ConsumerState<TransactionsView>
    with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  final _searchDebouncer = SearchDebouncer(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(transactionsProvider.notifier)
          .loadTransactions(isInitialLoad: true);
      analyticsService.trackScreenView(screenName: 'TransactionsView');
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _searchDebouncer.dispose();
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
    HapticHelper.lightImpact();
    ref.read(transactionsProvider.notifier).loadTransactions();
  }

  void _showFilterBottomSheet(TransactionsState transactionsState) {
    HapticHelper.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => TransactionFilterBottomSheet(
            currentFilters: transactionsState.filters,
            onApply: (filters) {
              ref.read(transactionsProvider.notifier).applyFilters(filters);
            },
          ),
    );
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
          leading: IconButton(
            onPressed: () => appRouter.pop(),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).colorScheme.onSurface,
              // size: 20.sp,
            ),
          ),
          title: Text(
            "Transactions",
            style: AppTypography.titleLarge.copyWith(
              fontFamily: 'CabinetGrotesk',
              fontSize: 28.00,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          centerTitle: true,
          // actions: [
          //   Stack(
          //     children: [
          //       IconButton(
          //         onPressed: () => _showFilterBottomSheet(transactionsState),
          //         icon: Icon(
          //           Icons.filter_list,
          //           color: Theme.of(context).colorScheme.onSurface,
          //           size: 24.sp,
          //         ),
          //       ),
          //       if (transactionsState.filters.hasActiveFilters)
          //         Positioned(
          //           right: 8.w,
          //           top: 8.h,
          //           child: Container(
          //             width: 18.w,
          //             height: 18.w,
          //             decoration: BoxDecoration(
          //               color: AppColors.purple500,
          //               shape: BoxShape.circle,
          //             ),
          //             child: Center(
          //               child: Text(
          //                 '${transactionsState.filters.activeFilterCount}',
          //                 style: TextStyle(
          //                   color: Colors.white,
          //                   fontSize: 10.sp,
          //                   fontWeight: FontWeight.w600,
          //                 ),
          //               ),
          //             ),
          //           ),
          //         ),
          //     ],
          //   ),
          //   SizedBox(width: 8.w),
          // ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            _refreshTransactions();
          },
          child: Column(
            children: [
              // Active Filters Indicator
              if (transactionsState.filters.hasActiveFilters)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 8.h,
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.purple500ForTheme(
                        context,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppColors.purple500ForTheme(
                          context,
                        ).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.filter_alt,
                          size: 18.sp,
                          color: AppColors.purple500ForTheme(context),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            _getFilterSummary(transactionsState.filters),
                            style: AppTypography.bodySmall.copyWith(
                              fontFamily: 'Karla',
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.purple500ForTheme(context),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            HapticHelper.lightImpact();
                            ref
                                .read(transactionsProvider.notifier)
                                .applyFilters(TransactionFilterOptions());
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Clear',
                            style: AppTypography.bodySmall.copyWith(
                              fontFamily: 'Karla',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.purple500ForTheme(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Transactions List
              Expanded(
                child: Padding(
                  padding: EdgeInsetsGeometry.only(bottom: 0.h),
                  child:
                      transactionsState.isLoading &&
                              transactionsState.groupedTransactions.isEmpty
                          ? Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 16.h,
                            ),
                            child: ShimmerWidgets.transactionListShimmer(
                              context,
                              itemCount: 8,
                            ),
                          )
                          : transactionsState.errorMessage != null &&
                              transactionsState.groupedTransactions.isEmpty
                          ? ErrorStateWidget(
                            message: 'Failed to load transactions',
                            details: transactionsState.errorMessage,
                            onRetry: _refreshTransactions,
                          )
                          : transactionsState.groupedTransactions.isEmpty
                          ? EmptyStateWidget(
                            icon: Icons.receipt_long_outlined,
                            title: 'No transactions yet',
                            message:
                                'Your transaction history will appear here',
                            actionText: 'Send Money',
                            onAction: () {
                              Navigator.pushNamed(context, '/send');
                            },
                          )
                          : ListView(
                            children: [
                              // Search Bar
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 18.w,
                                  vertical: 8.h,
                                ),
                                child: CustomTextField(
                                  controller: _searchController,
                                  label: '',
                                  hintText: 'Search transactions',
                                  borderRadius: 40,
                                  prefixIcon: Container(
                                    width: 40.w,
                                    alignment: Alignment.centerRight,
                                    constraints:
                                        BoxConstraints.tightForFinite(),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        'assets/icons/svgs/search-normal.svg',
                                        height: 22.sp,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.6),
                                      ),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    _searchDebouncer.run(() {
                                      ref
                                          .read(transactionsProvider.notifier)
                                          .searchTransactions(value);
                                    });
                                  },
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.only(
                                  left: 24.w,
                                  right: 24.w,
                                  bottom: 124.h,
                                ),
                                itemCount:
                                    transactionsState
                                        .groupedTransactions
                                        .length,
                                itemBuilder: (context, index) {
                                  final group =
                                      transactionsState
                                          .groupedTransactions[index];
                                  return _buildTransactionGroup(group);
                                },
                              ),
                            ],
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
          padding: EdgeInsets.only(bottom: 8.h, top: 16.h),
          child: Text(
            group.date,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontFamily: 'Karla',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              letterSpacing: -.3,
              height: 1.450,
              color: Theme.of(
                context,
              ).textTheme.bodyLarge!.color!.withOpacity(.75),
            ),
          ),
        ),

        // Transactions for this date
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: [
              for (int i = 0; i < group.transactions.length; i++)
                _buildTransactionCard(
                  group.transactions[i],
                  bottomMargin: i == group.transactions.length - 1 ? 8 : 24,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(
    WalletTransaction transaction, {
    double bottomMargin = 24,
  }) {
    final beneficiaryName = _getBeneficiaryDisplayName(transaction);
    final statusText = _getStatusText(transaction.status);
    final amount =
        '${transaction.sendNetwork ?? transaction.receiveNetwork ?? 'USD'} ${(transaction.sendAmount ?? transaction.receiveAmount ?? 0.0).toStringAsFixed(2)}';

    return Semantics(
      button: true,
      label: 'Transaction to $beneficiaryName for $amount, $statusText',
      hint: 'Double tap to view transaction details',
      child: InkWell(
        onTap: () {
          appRouter.pushNamed(
            AppRoute.transactionDetailsView,
            arguments: transaction,
          );
        },
        child: Container(
          margin: EdgeInsets.only(bottom: bottomMargin.h, top: 8.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Transaction Type Icon (Inflow/Outflow)
              SizedBox(
                width: 36.w,
                height: 36.w,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background circle
                    SvgPicture.asset(
                      'assets/icons/svgs/transactions.svg',
                      height: 36.sp,
                      color: _getTransactionTypeColorForTransaction(
                        transaction,
                      ).withOpacity(0.35),
                    ),
                    // Foreground icon
                    Center(
                      child: SvgPicture.asset(
                        _getTransactionTypeIconForTransaction(transaction),
                        height: 20.sp,
                        color: _getTransactionTypeColorForTransaction(
                          transaction,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),

              // Transaction Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // _getAccountIcon(transaction.source, transaction.beneficiary),
                        // SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            _getBeneficiaryDisplayName(transaction),
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(
                              fontFamily: 'Karla',
                              fontSize: 18.sp,
                              letterSpacing: -.3,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            // maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),

                    if (transaction.reason != null &&
                        transaction.reason!.isNotEmpty) ...[
                      // SizedBox(height: 2.h),
                      Text(
                        _capitalizeWords(transaction.reason!),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'karla',
                          fontWeight: FontWeight.w400,
                          letterSpacing: -.1,
                          height: 1.5,
                          fontSize: 12.sp,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(.45),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    Text(
                      _formatTransactionTime(transaction.timestamp),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Karla',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -.2,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              // Amount and Time
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _getTransactionAmount(transaction),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontFamily: 'Karla',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 2.h),

                  Text(
                    _getStatusText(transaction.status).toUpperCase(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Karla',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -.5,
                      height: 1.450,
                      color: _getStatusColor(transaction.status),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getTransactionType(String status, String sendChannel) {
    final lowerStatus = status.toLowerCase();
    final lowerSendChannel = sendChannel.toLowerCase();

    // Check for dayfi-to-dayfi transfers first
    if (lowerSendChannel == 'dayfi' ||
        lowerSendChannel.contains('dayfi_to_dayfi')) {
      return 'Dayfi Transfer';
    }

    // Check for collection (money coming into Dayfi) - works with success-collection, pending-collection, etc.
    if (lowerStatus.contains('collection')) {
      return 'Wallet Funding (Money coming into Dayfi)';
    }

    // Check for payment going out (and not dayfi-to-dayfi) - works with success-payment, pending-payment, etc.
    if (lowerStatus.contains('payment')) {
      return 'Sending money out of Dayfi';
    }

    return 'Unknown transaction type';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success-collection':
      case 'success-payment':
        return AppColors.success500;
      case 'pending-collection':
      case 'pending-payment':
        return AppColors.warning500;
      case 'failed-collection':
      case 'failed-payment':
        return AppColors.error500;
      default:
        return AppColors.neutral500;
    }
  }

  String _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'success-collection':
      case 'success-payment':
        return 'assets/icons/svgs/circle-check.svg';
      case 'pending-collection':
      case 'pending-payment':
        return "assets/icons/svgs/exclamation-circle.svg";
      case 'failed-collection':
      case 'failed-payment':
        return "assets/icons/svgs/circle-x.svg";
      default:
        return "assets/icons/svgs/info-circle.svg";
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'success-collection':
      case 'success-payment':
        return 'Completed';
      case 'pending-collection':
      case 'pending-payment':
        return 'Pending';
      case 'failed-collection':
      case 'failed-payment':
        return 'Failed';
      default:
        return 'Unknown';
    }
  }

  String _getTransactionAmount(WalletTransaction transaction) {
    // Use actual amounts from the transaction data
    if (transaction.sendAmount != null && transaction.sendAmount! > 0) {
      return '₦${_formatNumber(transaction.sendAmount!)}';
    } else if (transaction.receiveAmount != null &&
        transaction.receiveAmount! > 0) {
      return '₦${_formatNumber(transaction.receiveAmount!)}';
    } else {
      return 'N/A';
    }
  }

  String _getBeneficiaryDisplayName(WalletTransaction transaction) {
    final isCollection = transaction.status.toLowerCase().contains('collection');
    final isPayment = transaction.status.toLowerCase().contains('payment');
    
    // Check if this is a DayFi tag transfer
    final isDayfiTransfer = transaction.source.accountType?.toLowerCase() == 'dayfi' ||
        transaction.beneficiary.accountType?.toLowerCase() == 'dayfi';
    
    // For collection (incoming money)
    if (isCollection) {
      if (isDayfiTransfer && transaction.beneficiary.accountNumber != null &&
          transaction.beneficiary.accountNumber!.isNotEmpty) {
        final tag = transaction.beneficiary.accountNumber!;
        final displayTag = tag.startsWith('@') ? tag : '@$tag';
        return 'Money received from $displayTag';
      }
      return 'Money added to your wallet';
    }
    
    // For payment (outgoing money)
    if (isPayment) {
      // Check if it's a wallet top-up (sending to yourself)
      final profileState = ref.read(profileViewModelProvider);
      final user = profileState.user;
      
      if (user != null) {
        final userFullName = '${user.firstName} ${user.lastName}'.trim().toUpperCase();
        final beneficiaryName = transaction.beneficiary.name.trim().toUpperCase();
        
        if (beneficiaryName == userFullName ||
            beneficiaryName == 'SELF FUNDING' ||
            (beneficiaryName.contains('SELF') && beneficiaryName.contains('FUNDING'))) {
          return 'Topped up your wallet';
        }
      }
      
      // Regular payment to another person
      if (isDayfiTransfer && transaction.beneficiary.accountNumber != null &&
          transaction.beneficiary.accountNumber!.isNotEmpty) {
        final tag = transaction.beneficiary.accountNumber!;
        final displayTag = tag.startsWith('@') ? tag : '@$tag';
        return 'Sent money to $displayTag';
      }
      
      // Payment to beneficiary name
      return 'Sent to ${transaction.beneficiary.name}';
    }
    
    // Fallback to beneficiary name
    return transaction.beneficiary.name.toUpperCase();
  }

  String _formatNumber(double amount) {
    // Format number with thousands separators
    String formatted = amount.toStringAsFixed(2);
    List<String> parts = formatted.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : '00';

    // Add commas for thousands separators
    String formattedInteger = '';
    for (int i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        formattedInteger += ',';
      }
      formattedInteger += integerPart[i];
    }

    return '$formattedInteger.$decimalPart';
  }

  String _formatTransactionTime(String timestamp) {
    try {
      // Add 1 hour to the timestamp
      final date = DateTime.parse(timestamp).add(const Duration(hours: 1));

      // Format time as HH:MM AM/PM
      final hour =
          date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
      final minute = date.minute.toString().padLeft(2, '0');
      final period = date.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    } catch (e) {
      return '';
    }
  }

  String _capitalizeWords(String text) {
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  // Get transaction type icon (inflow/outflow)
  String _getTransactionTypeIcon(String status) {
    // Collection = money coming in (inflow)
    if (status.toLowerCase().contains('collection')) {
      return 'assets/icons/svgs/arrow-narrow-down.svg'; // Down arrow for inflow
    }
    // Payment = money going out (outflow)
    else if (status.toLowerCase().contains('payment')) {
      return 'assets/icons/svgs/arrow-narrow-up.svg'; // Up arrow for outflow
    }
    return 'assets/icons/svgs/info-circle.svg';
  }

  // Get transaction type icon with beneficiary check (for individual transactions)
  String _getTransactionTypeIconForTransaction(WalletTransaction transaction) {
    final beneficiaryName = _getBeneficiaryDisplayName(transaction);

    // If wallet funded, always show pay-in icon (down arrow)
    if (beneficiaryName == 'Wallet Top Up') {
      return 'assets/icons/svgs/arrow-narrow-down.svg';
    }

    // Otherwise use status-based logic
    return _getTransactionTypeIcon(transaction.status);
  }

  // Get transaction type color (inflow/outflow)
  Color _getTransactionTypeColor(String status) {
    // Collection = money coming in (green)
    if (status.toLowerCase().contains('collection')) {
      return AppColors.success500;
    }
    // Payment = money going out (orange/warning)
    else if (status.toLowerCase().contains('payment')) {
      return AppColors.warning500;
    }
    return AppColors.neutral500;
  }

  // Get transaction type color with beneficiary check (for individual transactions)
  Color _getTransactionTypeColorForTransaction(WalletTransaction transaction) {
    final beneficiaryName = _getBeneficiaryDisplayName(transaction);

    // If wallet funded, always show green (pay-in color)
    if (beneficiaryName == 'Wallet Top Up') {
      return AppColors.success500;
    }

    // Otherwise use status-based logic
    return _getTransactionTypeColor(transaction.status);
  }

  String _getFilterSummary(TransactionFilterOptions filters) {
    List<String> parts = [];

    if (filters.sortBy != TransactionSortBy.newest) {
      switch (filters.sortBy) {
        case TransactionSortBy.oldest:
          parts.add('Oldest first');
          break;
        case TransactionSortBy.amountHighest:
          parts.add('Highest amount');
          break;
        case TransactionSortBy.amountLowest:
          parts.add('Lowest amount');
          break;
        default:
          break;
      }
    }

    if (filters.status != TransactionStatus.all) {
      parts.add('${filters.status.name.capitalize()} only');
    }

    if (filters.startDate != null || filters.endDate != null) {
      if (filters.startDate != null && filters.endDate != null) {
        parts.add(
          '${_formatShortDate(filters.startDate!)} - ${_formatShortDate(filters.endDate!)}',
        );
      } else if (filters.startDate != null) {
        parts.add('From ${_formatShortDate(filters.startDate!)}');
      } else {
        parts.add('Until ${_formatShortDate(filters.endDate!)}');
      }
    }

    return parts.isEmpty ? 'Filters active' : parts.join(' • ');
  }

  String _formatShortDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _getAccountIcon(Source source, Beneficiary beneficiary) {
    final accountType = source.accountType?.toLowerCase() ?? '';
    String overlayIcon;
    switch (accountType) {
      case 'dayfi':
        overlayIcon = 'assets/icons/svgs/at.svg';
        break;
      case 'bank':
        overlayIcon = 'assets/icons/svgs/building-bank.svg';
        break;
      case 'phone':
      case 'mobile':
      case 'mobile_money':
      case 'momo':
        overlayIcon = 'assets/icons/svgs/device-mobile.svg';
        break;
      case 'crypto':
        overlayIcon = 'assets/icons/svgs/currency-dollar.svg';
        break;
      case 'card':
        overlayIcon = 'assets/icons/svgs/carddd.svg';
        break;
      default:
        overlayIcon = 'assets/icons/svgs/paymentt.svg';
    }

    return Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24.r)),
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          SvgPicture.asset(
            'assets/icons/svgs/swap.svg',
            height: 22,
            color: AppColors.neutral700.withOpacity(.35),
          ),
          SvgPicture.asset(
            overlayIcon,
            height: 16,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(.65),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
