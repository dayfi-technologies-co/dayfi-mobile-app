import 'package:dayfi/features/recipients/helpers/recipient_history_helper.dart';
import 'package:dayfi/features/recipients/helpers/recipients_list_cache.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/models/beneficiary_with_source.dart';
import 'package:dayfi/services/remote/wallet_service.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/utils/app_logger.dart';

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
      filteredBeneficiaries:
          filteredBeneficiaries ?? this.filteredBeneficiaries,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class RecipientsNotifier extends StateNotifier<RecipientsState> {
  final WalletService _walletService;

  RecipientsNotifier(this._walletService) : super(RecipientsState());

  static bool _isLocalOnlySave(BeneficiaryWithSource entry) {
    final id = entry.beneficiary.id;
    return id.startsWith('saved-') && !id.startsWith('ben-saved-');
  }

  List<BeneficiaryWithSource> _localOnlySavesFromStateOrCache() {
    final fromState = state.beneficiaries.where(_isLocalOnlySave).toList();
    if (fromState.isNotEmpty) return fromState;

    final cached = RecipientsListCache.read();
    if (cached == null) return const [];
    return cached.where(_isLocalOnlySave).toList();
  }

  Future<void> loadBeneficiaries({bool isInitialLoad = false}) async {
    if (state.beneficiaries.isEmpty) {
      final cached = RecipientsListCache.read();
      if (cached != null) {
        final bens =
            cached.where(RecipientHistoryHelper.isSendRecipient).toList();
        if (bens.isNotEmpty) {
          state = state.copyWith(
            beneficiaries: bens,
            filteredBeneficiaries: bens,
            isLoading: false,
          );
        }
      }
    }

    final localOnlySaves = _localOnlySavesFromStateOrCache();
    final shouldShowLoading = state.beneficiaries.isEmpty;
    state = state.copyWith(isLoading: shouldShowLoading, errorMessage: null);

    try {
      final results = await Future.wait([
        _walletService.getUniqueBeneficiariesWithSource(),
        _walletService.fetchSavedBeneficiaries(),
      ]);
      final fromHistory = results[0];
      final fromSavedApi = results[1];

      var merged = RecipientHistoryHelper.mergeRecipients(
        fromHistory,
        fromSavedApi,
      );
      if (localOnlySaves.isNotEmpty) {
        merged = RecipientHistoryHelper.mergeRecipients(merged, localOnlySaves);
      }

      await RecipientsListCache.write(merged);
      state = state.copyWith(
        beneficiaries: merged,
        filteredBeneficiaries: merged,
        isLoading: false,
      );
      if (state.searchQuery.isNotEmpty) {
        searchBeneficiaries(state.searchQuery);
      }
    } catch (e) {
      AppLogger.error('Failed to load recipients: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: null,
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

    final filtered =
        state.beneficiaries.where((beneficiaryWithSource) {
          final beneficiary = beneficiaryWithSource.beneficiary;
          return beneficiary.name.toLowerCase().contains(query.toLowerCase()) ||
              beneficiary.phone.contains(query) ||
              beneficiary.email.toLowerCase().contains(query.toLowerCase()) ||
              (beneficiaryWithSource.source.accountNumber ?? '')
                  .toLowerCase()
                  .contains(query.toLowerCase());
        }).toList();

    state = state.copyWith(searchQuery: query, filteredBeneficiaries: filtered);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  bool validateNoDuplicates() {
    final beneficiaries = state.beneficiaries;
    final seen = <String>{};

    for (final beneficiaryWithSource in beneficiaries) {
      final key = RecipientHistoryHelper.peopleListDedupKey(beneficiaryWithSource);
      if (seen.contains(key)) {
        return false;
      }
      seen.add(key);
    }

    return true;
  }

  RecipientsState addBeneficiaryOptimistically(
    BeneficiaryWithSource newBeneficiary,
  ) {
    final previousState = state;
    final updatedBeneficiaries = [...state.beneficiaries, newBeneficiary];

    state = state.copyWith(
      beneficiaries: updatedBeneficiaries,
      filteredBeneficiaries:
          state.searchQuery.isEmpty
              ? updatedBeneficiaries
              : state.filteredBeneficiaries,
    );

    return previousState;
  }

  void rollbackToState(RecipientsState previousState) {
    state = previousState;
  }

  Future<void> saveRecipient(BeneficiaryWithSource entry) async {
    if (!RecipientHistoryHelper.isSendRecipient(entry)) return;

    final byKey = <String, BeneficiaryWithSource>{};
    for (final existing in state.beneficiaries) {
      if (!RecipientHistoryHelper.isSendRecipient(existing)) continue;
      byKey[RecipientHistoryHelper.peopleListDedupKey(existing)] = existing;
    }
    final key = RecipientHistoryHelper.peopleListDedupKey(entry);
    final prior = byKey[key];
    if (prior == null ||
        RecipientHistoryHelper.shouldReplaceRecipient(entry, prior)) {
      byKey[key] = entry;
    }

    final updated =
        byKey.values.toList()
          ..sort((a, b) => a.beneficiary.name.compareTo(b.beneficiary.name));

    state = state.copyWith(
      beneficiaries: updated,
      filteredBeneficiaries:
          state.searchQuery.isEmpty
              ? updated
              : updated.where((b) {
                final q = state.searchQuery.toLowerCase();
                return b.beneficiary.name.toLowerCase().contains(q) ||
                    (b.source.accountNumber ?? '').toLowerCase().contains(q);
              }).toList(),
    );

    await RecipientsListCache.write(updated);
  }
}

final recipientsProvider =
    StateNotifierProvider<RecipientsNotifier, RecipientsState>((ref) {
      return RecipientsNotifier(locator<WalletService>());
    });
