import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/features/transactions/models/transaction_model.dart';

class TransactionsState {
  final List<Transaction> transactions;
  final List<Transaction> filteredTransactions;
  final bool isLoading;
  final String searchQuery;

  const TransactionsState({
    this.transactions = const [],
    this.filteredTransactions = const [],
    this.isLoading = false,
    this.searchQuery = '',
  });

  TransactionsState copyWith({
    List<Transaction>? transactions,
    List<Transaction>? filteredTransactions,
    bool? isLoading,
    String? searchQuery,
  }) {
    return TransactionsState(
      transactions: transactions ?? this.transactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class TransactionsViewModel extends StateNotifier<TransactionsState> {
  TransactionsViewModel() : super(const TransactionsState());

  Future<void> loadTransactions() async {
    state = state.copyWith(isLoading: true);
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock data - in real app, this would come from API
    final mockTransactions = [
      Transaction(
        id: '1',
        recipientName: 'IFEOLUWA DORCAS OLUWAFEMI',
        amount: 20001,
        date: DateTime(2025, 9, 26),
        status: TransactionStatus.requiresAction,
        reference: 'TXN001',
        description: 'School fees payment',
      ),
      Transaction(
        id: '2',
        recipientName: 'KOLAWOLE PAUL OLUWAFEMI',
        amount: 20001,
        date: DateTime(2025, 9, 24),
        status: TransactionStatus.requiresAction,
        reference: 'TXN002',
        description: 'Living expenses',
      ),
      Transaction(
        id: '3',
        recipientName: 'ADEBAYO JOHNSON',
        amount: 15000,
        date: DateTime(2025, 9, 20),
        status: TransactionStatus.completed,
        reference: 'TXN003',
        description: 'Book purchase',
      ),
      Transaction(
        id: '4',
        recipientName: 'FATIMA IBRAHIM',
        amount: 25000,
        date: DateTime(2025, 9, 18),
        status: TransactionStatus.completed,
        reference: 'TXN004',
        description: 'Tuition fees',
      ),
      Transaction(
        id: '5',
        recipientName: 'CHIDI OKAFOR',
        amount: 12000,
        date: DateTime(2025, 9, 15),
        status: TransactionStatus.failed,
        reference: 'TXN005',
        description: 'Accommodation',
      ),
      Transaction(
        id: '6',
        recipientName: 'AMINA YUSUF',
        amount: 18000,
        date: DateTime(2025, 9, 12),
        status: TransactionStatus.pending,
        reference: 'TXN006',
        description: 'Medical expenses',
      ),
    ];
    
    state = state.copyWith(
      transactions: mockTransactions,
      filteredTransactions: mockTransactions,
      isLoading: false,
    );
  }

  void searchTransactions(String query) {
    if (query.isEmpty) {
      state = state.copyWith(
        searchQuery: query,
        filteredTransactions: state.transactions,
      );
      return;
    }

    final filtered = state.transactions.where((transaction) {
      return transaction.recipientName.toLowerCase().contains(query.toLowerCase()) ||
             transaction.reference?.toLowerCase().contains(query.toLowerCase()) == true ||
             transaction.description?.toLowerCase().contains(query.toLowerCase()) == true;
    }).toList();

    state = state.copyWith(
      searchQuery: query,
      filteredTransactions: filtered,
    );
  }

  void refreshTransactions() {
    loadTransactions();
  }

  void retryTransaction(String transactionId) {
    // TODO: Implement retry logic
    print('Retrying transaction: $transactionId');
  }

  void cancelTransaction(String transactionId) {
    // TODO: Implement cancel logic
    print('Cancelling transaction: $transactionId');
  }
}

final transactionsViewModelProvider = StateNotifierProvider<TransactionsViewModel, TransactionsState>((ref) {
  return TransactionsViewModel();
});
