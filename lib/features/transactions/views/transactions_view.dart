import 'package:dayfi/core/theme/app_typography.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/common/widgets/shimmer_widgets.dart';
import 'package:dayfi/common/widgets/error_state_widget.dart';
import 'package:dayfi/common/widgets/empty_state_widget.dart';
import 'package:dayfi/common/utils/haptic_helper.dart';
import 'package:dayfi/features/transactions/vm/transactions_viewmodel.dart';
import 'package:dayfi/features/transactions/widgets/transaction_filter_bottom_sheet.dart';
import 'package:dayfi/models/wallet_transaction.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';
import 'package:dayfi/common/utils/available_balance_calculator.dart';

class TransactionsView extends ConsumerStatefulWidget {
  const TransactionsView({super.key});

  @override
  ConsumerState<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends ConsumerState<TransactionsView>
    with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();

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
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
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
      barrierColor: Colors.black.withOpacity(0.85),
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionFilterBottomSheet(
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

    // Sync search controller with state
    if (_searchController.text != transactionsState.searchQuery) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted &&
            _searchController.text != transactionsState.searchQuery) {
          _searchController.text = transactionsState.searchQuery;
          _searchController.selection = TextSelection.fromPosition(
            TextPosition(offset: _searchController.text.length),
          );
        }
      });
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          scrolledUnderElevation: .5,
          foregroundColor: Theme.of(context).scaffoldBackgroundColor,
          shadowColor: Theme.of(context).scaffoldBackgroundColor,
          surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          // leading: const SizedBox.shrink(),
          automaticallyImplyLeading: false,
          leadingWidth: 0,
          title: Text(
            "Transactions",
            style: AppTypography.titleLarge.copyWith(
              fontFamily: 'FunnelDisplay',
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          centerTitle: true,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth > 600;
            return CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                CupertinoSliverRefreshControl(
                  onRefresh: () async {
                    _refreshTransactions();
                  },
                ),
                SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isWide ? 500 : double.infinity,
                      ),
                      child: Column(
                        children: [
                          // Active Filters Indicator
                          if (transactionsState.filters.hasActiveFilters)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isWide ? 24 : 18,
                                vertical: 8,
                              ),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.purple500ForTheme(context)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.purple500ForTheme(context)
                                        .withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.filter_alt,
                                      size: 18,
                                      color:
                                          AppColors.purple500ForTheme(context),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _getFilterSummary(
                                          transactionsState.filters,
                                        ),
                                        style:
                                            AppTypography.bodySmall.copyWith(
                                              fontFamily: 'Karla',
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors
                                                  .purple500ForTheme(context),
                                            ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        HapticHelper.lightImpact();
                                        ref
                                            .read(
                                              transactionsProvider.notifier,
                                            )
                                            .applyFilters(
                                              TransactionFilterOptions(),
                                            );
                                      },
                                      style: TextButton.styleFrom(
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 8),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        'Clear',
                                        style:
                                            AppTypography.bodySmall.copyWith(
                                              fontFamily: 'Karla',
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors
                                                  .purple500ForTheme(context),
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          // Main Content
                          Padding(
                            padding: EdgeInsets.only(bottom: 0),
                            child: _buildMainContent(
                              transactionsState,
                              isWide,
                            ),
                          ),
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

  Widget _buildMainContent(
    TransactionsState transactionsState,
    bool isWide,
  ) {
    if (transactionsState.transactions.isEmpty) {
      if (transactionsState.isLoading) {
        return ShimmerWidgets.recipientListShimmer(context, itemCount: 8);
      } else if (transactionsState.errorMessage != null) {
        return ErrorStateWidget(
          message: 'Failed to load transactions',
          details: transactionsState.errorMessage,
          onRetry: _refreshTransactions,
        );
      } else {
        return EmptyStateWidget(
          icon: Icons.receipt_long_outlined,
          title: 'No transactions yet',
          message: 'Your transaction history will appear here',
          actionText: 'Send Money',
          onAction: () {
            Navigator.pushNamed(context, '/send');
          },
        );
      }
    }

    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        // Search Bar
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 24 : 18,
            vertical: 8,
          ),
          child: CustomTextField(
            isSearch: true,
            controller: _searchController,
            label: '',
            hintText: 'Search transactions',
            borderRadius: 40,
            prefixIcon: Container(
              width: 40,
              alignment: Alignment.centerRight,
              constraints: BoxConstraints.tightForFinite(),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/svgs/search-normal.svg',
                  height: 22,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.6),
                ),
              ),
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      HapticHelper.lightImpact();
                      _searchController.clear();
                      ref
                          .read(transactionsProvider.notifier)
                          .searchTransactions('');
                    },
                    child: Container(
                      width: 40,
                      alignment: Alignment.centerLeft,
                      constraints: BoxConstraints.tightForFinite(),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/icons/svgs/close-circle.svg',
                          height: 20,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                      ),
                    ),
                  )
                : null,
            onChanged: (value) {
              ref.read(transactionsProvider.notifier).searchTransactions(value);
            },
          ),
        ),

        // No Search Results
        if (transactionsState.groupedTransactions.isEmpty &&
            transactionsState.searchQuery.isNotEmpty)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 16),
                SvgPicture.asset(
                  'assets/icons/svgs/search-normal.svg',
                  height: 64,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.6),
                ),
                SizedBox(height: 16),
                Text(
                  'No transactions found',
                  style: TextStyle(
                    fontFamily: 'FunnelDisplay',
                    fontSize: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Try searching with different keywords',
                  style: AppTypography.bodyMedium.copyWith(
                    fontFamily: 'Karla',
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.4),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          // Transactions List
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.only(
              left: isWide ? 24 : 18,
              right: isWide ? 24 : 18,
              bottom: 20,
            ),
            itemCount: transactionsState.groupedTransactions.length,
            itemBuilder: (context, index) {
              final group = transactionsState.groupedTransactions[index];
              return _buildTransactionGroup(group, isWide);
            },
          ),
      ],
    );
  }

  Widget _buildTransactionGroup(TransactionGroup group, bool isWide) {
    return Column(
      key: ValueKey(group.date),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Header
        Padding(
          padding: EdgeInsets.only(bottom: 8, top: 16),
          child: Text(
            group.date,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Karla',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -.6,
                  height: 1.450,
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .color!
                      .withOpacity(.75),
                ),
          ),
        ),

        // Transactions for this date
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
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
    final statusText = _getStatusText(_getEffectiveStatus(transaction));
    final amount = _getTransactionAmount(transaction);

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
          key: ValueKey(transaction.id),
          margin: EdgeInsets.only(
            bottom: bottomMargin,
            top: 8,
            left: 8,
            right: 8,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Transaction Type Icon
              SizedBox(
                width: 40,
                height: 40,
                child: Stack(
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
                            color: _getTransactionTypeColorForTransaction(
                              transaction,
                            ),
                          ),
                          Center(
                            child: SvgPicture.asset(
                              _getTransactionTypeIconForTransaction(
                                transaction,
                              ),
                              height: 28,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),

              // Transaction Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _getBeneficiaryDisplayName(transaction),
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontFamily: 'Karla',
                                      fontSize: 16,
                                      letterSpacing: -.7,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    if (transaction.reason != null &&
                        transaction.reason!.isNotEmpty) ...[
                      Text(
                        _capitalizeWords(transaction.reason!),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontFamily: 'karla',
                              fontWeight: FontWeight.w500,
                              letterSpacing: -.1,
                              height: 1.5,
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(.65),
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    Text(
                      _formatTransactionTime(transaction.timestamp),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: 'Karla',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -.2,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),

              // Amount and Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _getTransactionAmount(transaction),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontFamily: 'Karla',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    _getStatusText(_getEffectiveStatus(transaction)),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: 'Karla',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -.6,
                          height: 1.450,
                          color: _getStatusColor(
                            _getEffectiveStatus(transaction),
                          ),
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

  // Helper methods remain the same...
  String getTransactionType(String status, String sendChannel) {
    final lowerStatus = status.toLowerCase();
    final lowerSendChannel = sendChannel.toLowerCase();

    if (lowerSendChannel == 'dayfi' ||
        lowerSendChannel.contains('dayfi_to_dayfi')) {
      return 'Dayfi Transfer';
    }

    if (lowerStatus.contains('collection')) {
      return 'Wallet Funding (Money coming into Dayfi)';
    }

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
      case 'expired-payment':
        return AppColors.error500;
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
      case 'expired-payment':
        return "assets/icons/svgs/circle-x.svg";
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
      case 'expired-payment':
        return 'Expired';
      case 'failed-collection':
      case 'failed-payment':
        return 'Failed';
      default:
        return 'Unknown';
    }
  }

  String _getEffectiveStatus(WalletTransaction transaction) {
    return AvailableBalanceCalculator.getEffectiveStatus(transaction);
  }

  String _getTransactionAmount(WalletTransaction transaction) {
    if (transaction.receiveAmount != null && transaction.receiveAmount! > 0) {
      final currencyCode = _getCurrencyCodeFromCountry(
        transaction.beneficiary.country,
      );
      final currencySymbol = _getCurrencySymbolFromCode(currencyCode);
      return '$currencySymbol${_formatNumber(transaction.receiveAmount!)}';
    } else if (transaction.sendAmount != null && transaction.sendAmount! > 0) {
      return '₦${_formatNumber(transaction.sendAmount!)}';
    } else {
      return 'N/A';
    }
  }

  String _getBeneficiaryDisplayName(WalletTransaction transaction) {
    final effectiveStatus = _getEffectiveStatus(transaction);
    final isCollection = effectiveStatus.toLowerCase().contains('collection');
    final isPayment = effectiveStatus.toLowerCase().contains('payment');

    final isDayfiTransfer =
        transaction.source.accountType?.toLowerCase() == 'dayfi' ||
            transaction.beneficiary.accountType?.toLowerCase() == 'dayfi';

    if (isCollection) {
      if (isDayfiTransfer &&
          transaction.beneficiary.accountNumber != null &&
          transaction.beneficiary.accountNumber!.isNotEmpty) {
        final tag = transaction.beneficiary.accountNumber!;
        final displayTag = tag.startsWith('@') ? tag.substring(1) : tag;
        return 'FROM ${displayTag.toUpperCase()}';
      }
      return 'WALLET CREDIT';
    }

    if (isPayment) {
      if (isDayfiTransfer &&
          transaction.beneficiary.accountNumber != null &&
          transaction.beneficiary.accountNumber!.isNotEmpty) {
        final tag = transaction.beneficiary.accountNumber!;
        final displayTag = tag.startsWith('@') ? tag.substring(1) : tag;
        return 'TO ${displayTag.toUpperCase()}';
      }

      return 'TO ${transaction.beneficiary.name.toUpperCase()}';
    }

    return transaction.beneficiary.name.toUpperCase();
  }

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

  String _formatTransactionTime(String timestamp) {
    try {
      final date = DateTime.parse(timestamp).add(const Duration(hours: 1));
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

  String _getTransactionTypeIcon(String status) {
    if (status.toLowerCase().contains('collection')) {
      return 'assets/icons/svgs/arrow-narrow-down.svg';
    } else if (status.toLowerCase().contains('payment')) {
      return 'assets/icons/svgs/arrow-narrow-up.svg';
    }
    return 'assets/icons/svgs/info-circle.svg';
  }

  String _getTransactionTypeIconForTransaction(WalletTransaction transaction) {
    final beneficiaryName = _getBeneficiaryDisplayName(transaction);

    if (beneficiaryName == 'Wallet Top Up') {
      return 'assets/icons/svgs/arrow-narrow-down.svg';
    }

    return _getTransactionTypeIcon(transaction.status);
  }

  Color _getTransactionTypeColor(String status) {
    if (status.toLowerCase().contains('collection')) {
      return AppColors.success500;
    } else if (status.toLowerCase().contains('payment')) {
      return AppColors.warning500;
    }
    return AppColors.neutral500;
  }

  Color _getTransactionTypeColorForTransaction(WalletTransaction transaction) {
    final beneficiaryName = _getBeneficiaryDisplayName(transaction);

    if (beneficiaryName == 'Wallet Top Up') {
      return AppColors.success500;
    }

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

  String _getCurrencyCodeFromCountry(String country) {
    final upperCountry = country.toUpperCase();
    switch (upperCountry) {
      case 'NG':
      case 'NIGERIA':
        return 'NGN';
      case 'RW':
      case 'RWANDA':
        return 'RWF';
      case 'GH':
      case 'GHANA':
        return 'GHS';
      case 'KE':
      case 'KENYA':
        return 'KES';
      case 'UG':
      case 'UGANDA':
        return 'UGX';
      case 'TZ':
      case 'TANZANIA':
        return 'TZS';
      case 'ZA':
      case 'SOUTH AFRICA':
      case 'SA':
        return 'ZAR';
      case 'BW':
      case 'BOTSWANA':
        return 'BWP';
      case 'SN':
      case 'SENEGAL':
      case 'CI':
      case 'COTE D\'IVOIRE':
      case 'IVORY COAST':
      case 'BF':
      case 'BURKINA FASO':
      case 'ML':
      case 'MALI':
      case 'NE':
      case 'NIGER':
      case 'TD':
      case 'CHAD':
      case 'CF':
      case 'CENTRAL AFRICAN REPUBLIC':
        return 'XOF';
      case 'CM':
      case 'CAMEROON':
      case 'GQ':
      case 'EQUATORIAL GUINEA':
      case 'GA':
      case 'GABON':
      case 'CG':
      case 'CONGO':
      case 'CD':
      case 'DEMOCRATIC REPUBLIC OF CONGO':
      case 'AO':
      case 'ANGOLA':
        return 'XAF';
      case 'US':
      case 'USA':
      case 'UNITED STATES':
        return 'USD';
      case 'GB':
      case 'UK':
      case 'UNITED KINGDOM':
      case 'ENGLAND':
        return 'GBP';
      case 'EU':
      case 'EUROPE':
        return 'EUR';
      default:
        return 'NGN'; // Default to Naira
    }
  }

  String _getCurrencySymbolFromCode(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'NGN':
        return '₦';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'RWF':
        return 'RWF ';
      case 'GHS':
        return 'GH₵';
      case 'KES':
        return 'KSh ';
      case 'UGX':
        return 'UGX ';
      case 'TZS':
        return 'TSh ';
      case 'ZAR':
        return 'R ';
      case 'BWP':
        return 'P ';
      case 'XOF':
        return 'CFA ';
      case 'XAF':
        return 'FCFA ';
      default:
        return '₦';
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
