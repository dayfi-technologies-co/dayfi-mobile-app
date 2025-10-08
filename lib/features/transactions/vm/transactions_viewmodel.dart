import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/models/wallet_transaction.dart';
import 'package:dayfi/services/remote/wallet_service.dart';
import 'package:dayfi/app_locator.dart';

class TransactionsState {
  final List<WalletTransaction> transactions;
  final List<TransactionGroup> groupedTransactions;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;

  TransactionsState({
    this.transactions = const [],
    this.groupedTransactions = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
  });

  TransactionsState copyWith({
    List<WalletTransaction>? transactions,
    List<TransactionGroup>? groupedTransactions,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
  }) {
    return TransactionsState(
      transactions: transactions ?? this.transactions,
      groupedTransactions: groupedTransactions ?? this.groupedTransactions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
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

  Future<void> loadTransactions() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final response = await _walletService.getWalletTransactions();
      
      final groupedTransactions = _groupTransactionsByDate(response.data.transactions);
      
      state = state.copyWith(
        transactions: response.data.transactions,
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
    if (query.isEmpty) {
      final groupedTransactions = _groupTransactionsByDate(state.transactions);
      state = state.copyWith(
        searchQuery: query,
        groupedTransactions: groupedTransactions,
      );
      return;
    }

    final filtered = state.transactions.where((transaction) {
      return transaction.beneficiary.name.toLowerCase().contains(query.toLowerCase()) ||
             transaction.beneficiary.phone.contains(query) ||
             transaction.beneficiary.email.toLowerCase().contains(query.toLowerCase()) ||
             transaction.status.toLowerCase().contains(query.toLowerCase());
    }).toList();

    final groupedTransactions = _groupTransactionsByDate(filtered);

    state = state.copyWith(
      searchQuery: query,
      groupedTransactions: groupedTransactions,
    );
  }

  List<TransactionGroup> _groupTransactionsByDate(List<WalletTransaction> transactions) {
    final Map<String, List<WalletTransaction>> grouped = {};
    
    for (final transaction in transactions) {
      final date = _formatDate(transaction.timestamp);
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(transaction);
    }

    return grouped.entries
        .map((entry) => TransactionGroup(
              date: entry.key,
              transactions: entry.value,
            ))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending
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