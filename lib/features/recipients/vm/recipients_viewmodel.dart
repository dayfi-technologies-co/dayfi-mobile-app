import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/features/recipients/models/recipient_model.dart';

class RecipientsState {
  final List<Recipient> recipients;
  final List<Recipient> filteredRecipients;
  final bool isLoading;
  final String searchQuery;

  const RecipientsState({
    this.recipients = const [],
    this.filteredRecipients = const [],
    this.isLoading = false,
    this.searchQuery = '',
  });

  RecipientsState copyWith({
    List<Recipient>? recipients,
    List<Recipient>? filteredRecipients,
    bool? isLoading,
    String? searchQuery,
  }) {
    return RecipientsState(
      recipients: recipients ?? this.recipients,
      filteredRecipients: filteredRecipients ?? this.filteredRecipients,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class RecipientsViewModel extends StateNotifier<RecipientsState> {
  RecipientsViewModel() : super(const RecipientsState());

  Future<void> loadRecipients() async {
    state = state.copyWith(isLoading: true);
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock data - in real app, this would come from API
    final mockRecipients = [
      Recipient(
        id: '1',
        name: 'IFEOLUWA DORCAS OLUWAFEMI',
        bankName: 'Opay',
        accountNumber: '7042441564',
        email: 'ifeoluwad@email.com',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Recipient(
        id: '2',
        name: 'KOLAWOLE PAUL OLUWAFEMI',
        bankName: 'Opay',
        accountNumber: '8131208415',
        email: 'kolawolep@email.com',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Recipient(
        id: '3',
        name: 'ADEBAYO JOHNSON',
        bankName: 'GTBank',
        accountNumber: '0123456789',
        email: 'adebayoj@email.com',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Recipient(
        id: '4',
        name: 'FATIMA IBRAHIM',
        bankName: 'Access Bank',
        accountNumber: '1234567890',
        email: 'fatimai@email.com',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      Recipient(
        id: '5',
        name: 'CHIDI OKAFOR',
        bankName: 'First Bank',
        accountNumber: '2345678901',
        email: 'chidio@email.com',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
    
    state = state.copyWith(
      recipients: mockRecipients,
      filteredRecipients: mockRecipients,
      isLoading: false,
    );
  }

  void searchRecipients(String query) {
    if (query.isEmpty) {
      state = state.copyWith(
        searchQuery: query,
        filteredRecipients: state.recipients,
      );
      return;
    }

    final filtered = state.recipients.where((recipient) {
      return recipient.name.toLowerCase().contains(query.toLowerCase()) ||
             recipient.bankName.toLowerCase().contains(query.toLowerCase()) ||
             recipient.accountNumber.contains(query) ||
             (recipient.email?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();

    state = state.copyWith(
      searchQuery: query,
      filteredRecipients: filtered,
    );
  }

  void addRecipient(Recipient recipient) {
    final updatedRecipients = [...state.recipients, recipient];
    state = state.copyWith(
      recipients: updatedRecipients,
      filteredRecipients: _filterRecipients(updatedRecipients, state.searchQuery),
    );
  }

  void updateRecipient(Recipient recipient) {
    final updatedRecipients = state.recipients.map((r) {
      return r.id == recipient.id ? recipient : r;
    }).toList();
    
    state = state.copyWith(
      recipients: updatedRecipients,
      filteredRecipients: _filterRecipients(updatedRecipients, state.searchQuery),
    );
  }

  void deleteRecipient(String recipientId) {
    final updatedRecipients = state.recipients
        .where((r) => r.id != recipientId)
        .toList();
    
    state = state.copyWith(
      recipients: updatedRecipients,
      filteredRecipients: _filterRecipients(updatedRecipients, state.searchQuery),
    );
  }

  List<Recipient> _filterRecipients(List<Recipient> recipients, String query) {
    if (query.isEmpty) return recipients;
    
    return recipients.where((recipient) {
      return recipient.name.toLowerCase().contains(query.toLowerCase()) ||
             recipient.bankName.toLowerCase().contains(query.toLowerCase()) ||
             recipient.accountNumber.contains(query) ||
             (recipient.email?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();
  }

  void refreshRecipients() {
    loadRecipients();
  }
}

final recipientsViewModelProvider = StateNotifierProvider<RecipientsViewModel, RecipientsState>((ref) {
  return RecipientsViewModel();
});
