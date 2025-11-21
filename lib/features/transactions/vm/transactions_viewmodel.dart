import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/models/wallet_transaction.dart';
import 'package:dayfi/services/remote/wallet_service.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/features/transactions/widgets/transaction_filter_bottom_sheet.dart';

class TransactionsState {
  final List<WalletTransaction> transactions;
  final List<TransactionGroup> groupedTransactions;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final TransactionFilterOptions filters;

  const TransactionsState({
    this.transactions = const [],
    this.groupedTransactions = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
    this.filters = const TransactionFilterOptions(),
  });

  TransactionsState copyWith({
    List<WalletTransaction>? transactions,
    List<TransactionGroup>? groupedTransactions,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
    TransactionFilterOptions? filters,
  }) {
    return TransactionsState(
      transactions: transactions ?? this.transactions,
      groupedTransactions: groupedTransactions ?? this.groupedTransactions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      filters: filters ?? this.filters,
    );
  }
}

class TransactionGroup {
  final String date;
  final List<WalletTransaction> transactions;

  TransactionGroup({
    required this.date,
    required this.transactions,
  });
}

class TransactionsNotifier extends StateNotifier<TransactionsState> {
  final WalletService _walletService;

  TransactionsNotifier(this._walletService) : super(TransactionsState());

  Future<void> loadTransactions({bool isInitialLoad = false}) async {
    // Only show loading state if there's no existing data (initial load)
    final shouldShowLoading = isInitialLoad || state.transactions.isEmpty;
    state = state.copyWith(
      isLoading: shouldShowLoading,
      errorMessage: null,
    );
    
    try {
      // Fetch first page to get total pages count
      final firstResponse = await _walletService.getWalletTransactions(
        limit: 100, // Use a larger limit per page
      );
      
      List<WalletTransaction> allTransactions = List.from(firstResponse.data.transactions);
      
      // Fetch remaining pages if there are more
      final totalPages = firstResponse.data.totalPages;
      if (totalPages > 1) {
        final remainingPages = List.generate(
          totalPages - 1,
          (index) => index + 2, // Pages 2, 3, 4, etc.
        );
        
        // Fetch all remaining pages
        final remainingResponses = await Future.wait(
          remainingPages.map((page) => _walletService.getWalletTransactions(
            page: page,
            limit: 100,
          )),
        );
        
        // Combine all transactions
        for (final response in remainingResponses) {
          allTransactions.addAll(response.data.transactions);
        }
      }
      
      final groupedTransactions = _groupTransactionsByDate(allTransactions);
      
      state = state.copyWith(
        transactions: allTransactions,
        groupedTransactions: groupedTransactions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load transactions. Please try again.',
      );
    }
  }

  void searchTransactions(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFiltersAndSort();
  }

  void applyFilters(TransactionFilterOptions filters) {
    state = state.copyWith(filters: filters);
    _applyFiltersAndSort();
  }

  void _applyFiltersAndSort() {
    var filtered = state.transactions;

    // Apply search query
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered = filtered.where((transaction) {
        return transaction.beneficiary.name.toLowerCase().contains(query) ||
               transaction.beneficiary.phone.contains(query) ||
               transaction.beneficiary.email.toLowerCase().contains(query) ||
               transaction.status.toLowerCase().contains(query);
      }).toList();
    }

    // Apply status filter
    if (state.filters.status != TransactionStatus.all) {
      final statusString = _getStatusString(state.filters.status);
      filtered = filtered.where((transaction) {
        return transaction.status.toLowerCase().contains(statusString);
      }).toList();
    }

    // Apply date range filter
    if (state.filters.startDate != null || state.filters.endDate != null) {
      filtered = filtered.where((transaction) {
        try {
          final transactionDate = DateTime.parse(transaction.timestamp);
          final transactionDateOnly = DateTime(
            transactionDate.year,
            transactionDate.month,
            transactionDate.day,
          );

          if (state.filters.startDate != null) {
            final startDateOnly = DateTime(
              state.filters.startDate!.year,
              state.filters.startDate!.month,
              state.filters.startDate!.day,
            );
            if (transactionDateOnly.isBefore(startDateOnly)) return false;
          }

          if (state.filters.endDate != null) {
            final endDateOnly = DateTime(
              state.filters.endDate!.year,
              state.filters.endDate!.month,
              state.filters.endDate!.day,
            );
            if (transactionDateOnly.isAfter(endDateOnly)) return false;
          }

          return true;
        } catch (e) {
          return false;
        }
      }).toList();
    }

    // Apply sorting
    filtered = _sortTransactions(filtered);

    // Group by date
    final groupedTransactions = _groupTransactionsByDate(filtered);

    state = state.copyWith(groupedTransactions: groupedTransactions);
  }

  String _getStatusString(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.success:
        return 'success';
      case TransactionStatus.pending:
        return 'pending';
      case TransactionStatus.failed:
        return 'failed';
      case TransactionStatus.cancelled:
        return 'cancelled';
      case TransactionStatus.all:
        return '';
    }
  }

  List<WalletTransaction> _sortTransactions(List<WalletTransaction> transactions) {
    final sorted = List<WalletTransaction>.from(transactions);

    switch (state.filters.sortBy) {
      case TransactionSortBy.newest:
        sorted.sort((a, b) {
          try {
            return DateTime.parse(b.timestamp).compareTo(DateTime.parse(a.timestamp));
          } catch (e) {
            return 0;
          }
        });
        break;
      case TransactionSortBy.oldest:
        sorted.sort((a, b) {
          try {
            return DateTime.parse(a.timestamp).compareTo(DateTime.parse(b.timestamp));
          } catch (e) {
            return 0;
          }
        });
        break;
      case TransactionSortBy.amountHighest:
        sorted.sort((a, b) {
          final amountA = a.sendAmount ?? a.receiveAmount ?? 0.0;
          final amountB = b.sendAmount ?? b.receiveAmount ?? 0.0;
          return amountB.compareTo(amountA);
        });
        break;
      case TransactionSortBy.amountLowest:
        sorted.sort((a, b) {
          final amountA = a.sendAmount ?? a.receiveAmount ?? 0.0;
          final amountB = b.sendAmount ?? b.receiveAmount ?? 0.0;
          return amountA.compareTo(amountB);
        });
        break;
    }

    return sorted;
  }

  List<TransactionGroup> _groupTransactionsByDate(List<WalletTransaction> transactions) {
    final Map<String, List<WalletTransaction>> grouped = {};
    final Map<String, DateTime> dateMap = {}; // Store actual DateTime for sorting
    
    for (final transaction in transactions) {
      final date = _formatDate(transaction.timestamp);
      final actualDate = _parseTransactionDate(transaction.timestamp);
      
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
        dateMap[date] = actualDate;
      }
      grouped[date]!.add(transaction);
    }

    return grouped.entries
        .map((entry) => TransactionGroup(
              date: entry.key,
              transactions: entry.value,
            ))
        .toList()
      ..sort((a, b) => dateMap[b.date]!.compareTo(dateMap[a.date]!)); // Sort by actual DateTime descending
  }

  DateTime _parseTransactionDate(String timestamp) {
    try {
      return DateTime.parse(timestamp);
    } catch (e) {
      return DateTime.now(); // Fallback to current date if parsing fails
    }
  }

  String _formatDate(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
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
          'January', 'February', 'March', 'April', 'May', 'June',
          'July', 'August', 'September', 'October', 'November', 'December'
        ];
        final day = date.day;
        final month = months[date.month - 1];
        final year = date.year;
        return '$day${_getOrdinalSuffix(day)} $month $year';
      }
    } catch (e) {
      return 'Unknown Date';
    }
  }

  String _getOrdinalSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final transactionsProvider = StateNotifierProvider<TransactionsNotifier, TransactionsState>((ref) {
  return TransactionsNotifier(locator<WalletService>());
});