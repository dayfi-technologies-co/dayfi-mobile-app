import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/models/beneficiary_with_source.dart';
import 'package:dayfi/services/remote/wallet_service.dart';
import 'package:dayfi/app_locator.dart';

class RecipientsState {
  final List<BeneficiaryWithSource> beneficiaries;
  final List<BeneficiaryWithSource> filteredBeneficiaries;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;

  RecipientsState({
    this.beneficiaries = const [],
    this.filteredBeneficiaries = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
  });

  RecipientsState copyWith({
    List<BeneficiaryWithSource>? beneficiaries,
    List<BeneficiaryWithSource>? filteredBeneficiaries,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
  }) {
    return RecipientsState(
      beneficiaries: beneficiaries ?? this.beneficiaries,
      filteredBeneficiaries: filteredBeneficiaries ?? this.filteredBeneficiaries,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class RecipientsNotifier extends StateNotifier<RecipientsState> {
  final WalletService _walletService;

  RecipientsNotifier(this._walletService) : super(RecipientsState());

  Future<void> loadBeneficiaries({bool isInitialLoad = false}) async {
    // Only show loading state if there's no existing data (initial load)
    final shouldShowLoading = isInitialLoad || state.beneficiaries.isEmpty;
    state = state.copyWith(
      isLoading: shouldShowLoading,
      errorMessage: null,
    );
    
    try {
      final beneficiaries = await _walletService.getUniqueBeneficiariesWithSource();
      
      // Additional client-side deduplication using Set to ensure no duplicates
      final uniqueBeneficiaries = beneficiaries.toSet().toList();
      
      state = state.copyWith(
        beneficiaries: uniqueBeneficiaries,
        filteredBeneficiaries: uniqueBeneficiaries,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load recipients. Please try again.',
      );
    }
  }

  void searchBeneficiaries(String query) {
    if (query.isEmpty) {
      state = state.copyWith(
        searchQuery: query,
        filteredBeneficiaries: state.beneficiaries,
      );
      return;
    }

    final filtered = state.beneficiaries.where((beneficiaryWithSource) {
      final beneficiary = beneficiaryWithSource.beneficiary;
      return beneficiary.name.toLowerCase().contains(query.toLowerCase()) ||
             beneficiary.phone.contains(query) ||
             beneficiary.email.toLowerCase().contains(query.toLowerCase());
    }).toList();

    state = state.copyWith(
      searchQuery: query,
      filteredBeneficiaries: filtered,
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Validates that there are no duplicate account details in the current beneficiaries list
  /// Checks for duplicates based on name + account number + network ID (same as display string logic)
  bool validateNoDuplicates() {
    final beneficiaries = state.beneficiaries;
    final seen = <String>{};
    
    for (final beneficiaryWithSource in beneficiaries) {
      final key = '${beneficiaryWithSource.beneficiary.name}_${beneficiaryWithSource.source.accountNumber}_${beneficiaryWithSource.source.networkId}';
      if (seen.contains(key)) {
        return false; // Duplicate found
      }
      seen.add(key);
    }
    
    return true; // No duplicates found
  }

  /// Optimistically add a beneficiary to the list
  /// Returns the previous state for rollback if needed
  RecipientsState addBeneficiaryOptimistically(BeneficiaryWithSource newBeneficiary) {
    final previousState = state;
    final updatedBeneficiaries = [...state.beneficiaries, newBeneficiary];
    
    state = state.copyWith(
      beneficiaries: updatedBeneficiaries,
      filteredBeneficiaries: state.searchQuery.isEmpty 
          ? updatedBeneficiaries 
          : state.filteredBeneficiaries,
    );
    
    return previousState;
  }

  /// Rollback to a previous state (used when optimistic update fails)
  void rollbackToState(RecipientsState previousState) {
    state = previousState;
  }
}

final recipientsProvider = StateNotifierProvider<RecipientsNotifier, RecipientsState>((ref) {
  return RecipientsNotifier(locator<WalletService>());
});