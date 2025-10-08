import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/models/wallet_transaction.dart';
import 'package:dayfi/services/remote/wallet_service.dart';
import 'package:dayfi/app_locator.dart';

class RecipientsState {
  final List<Beneficiary> beneficiaries;
  final List<Beneficiary> filteredBeneficiaries;
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
    List<Beneficiary>? beneficiaries,
    List<Beneficiary>? filteredBeneficiaries,
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

  Future<void> loadBeneficiaries() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final beneficiaries = await _walletService.getUniqueBeneficiaries();
      state = state.copyWith(
        beneficiaries: beneficiaries,
        filteredBeneficiaries: beneficiaries,
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

    final filtered = state.beneficiaries.where((beneficiary) {
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
}

final recipientsProvider = StateNotifierProvider<RecipientsNotifier, RecipientsState>((ref) {
  return RecipientsNotifier(locator<WalletService>());
});