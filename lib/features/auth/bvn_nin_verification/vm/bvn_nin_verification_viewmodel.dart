import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';
import 'package:dayfi/features/wallet/providers/wallet_hub_provider.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/services/remote/kyc_service.dart';

class BvnNinVerificationState {
  final String bvn;
  final String nin;
  final bool isBusy;
  final String bvnError;
  final String ninError;
  final String submitError;

  const BvnNinVerificationState({
    this.bvn = '',
    this.nin = '',
    this.isBusy = false,
    this.bvnError = '',
    this.ninError = '',
    this.submitError = '',
  });

  bool get isFormValid =>
      bvn.isNotEmpty && nin.isNotEmpty && bvnError.isEmpty && ninError.isEmpty;

  BvnNinVerificationState copyWith({
    String? bvn,
    String? nin,
    bool? isBusy,
    String? bvnError,
    String? ninError,
    String? submitError,
  }) {
    return BvnNinVerificationState(
      bvn: bvn ?? this.bvn,
      nin: nin ?? this.nin,
      isBusy: isBusy ?? this.isBusy,
      bvnError: bvnError ?? this.bvnError,
      ninError: ninError ?? this.ninError,
      submitError: submitError ?? this.submitError,
    );
  }
}

class BvnNinVerificationNotifier
    extends StateNotifier<BvnNinVerificationState> {
  final KycApiService _kycApi = KycApiService(networkService);

  BvnNinVerificationNotifier() : super(const BvnNinVerificationState());

  void setBvn(String value) {
    final error = _validateBvn(value);
    state = state.copyWith(bvn: value, bvnError: error, submitError: '');
  }

  void setNin(String value) {
    final error = _validateNin(value);
    state = state.copyWith(nin: value, ninError: error, submitError: '');
  }

  String _validateBvn(String value) {
    if (value.isEmpty) return 'Please enter your BVN';
    if (value.length != 11) return 'BVN must be exactly 11 digits';
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'BVN must contain only numbers';
    }
    return '';
  }

  String _validateNin(String value) {
    if (value.isEmpty) return 'Please enter your NIN';
    if (value.length != 11) return 'NIN must be exactly 11 digits';
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'NIN must contain only numbers';
    }
    return '';
  }

  Future<void> submitVerification(
    BuildContext context,
    WidgetRef ref, {
    required bool showBackButton,
    required bool fromSignup,
  }) async {
    if (!state.isFormValid) return;

    state = state.copyWith(isBusy: true, submitError: '');

    try {
      AppLogger.info('Starting BVN/NIN verification...');

      final outcome = await _kycApi.verifyIdentity(
        bvn: state.bvn,
        nin: state.nin,
      );

      await ref
          .read(profileViewModelProvider.notifier)
          .applyKycProfileSnapshot(outcome);
      await ref.read(walletHubProvider.notifier).refresh();

      if (!context.mounted) return;

      final account = outcome['ngnAccount'] as Map<String, dynamic>?;
      final acct = account?['accountNumber']?.toString();
      TopSnackbar.show(
        context,
        message: acct != null && acct.isNotEmpty
            ? 'Your NGN bank account is ready.'
            : 'Verification complete.',
      );

      if (fromSignup && !showBackButton) {
        appRouter.pushNamed(AppRoute.createPasscodeView);
      } else if (showBackButton) {
        Navigator.of(context).pop(true);
      } else {
        appRouter.pushNamed(AppRoute.createPasscodeView);
      }
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '').trim();
      AppLogger.error('Error verifying BVN/NIN: $message');
      state = state.copyWith(submitError: message);
      if (context.mounted) {
        TopSnackbar.show(context, message: message, isError: true);
      }
    } finally {
      state = state.copyWith(isBusy: false);
    }
  }

  void resetForm() {
    state = const BvnNinVerificationState();
  }
}

final bvnNinVerificationProvider =
    StateNotifierProvider<BvnNinVerificationNotifier, BvnNinVerificationState>(
      (ref) => BvnNinVerificationNotifier(),
    );
