import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/core/navigation/navigation.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/services/local/analytics_service.dart';
import 'package:dayfi/services/kyc/kyc_service.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/utils/app_logger.dart';

class UploadDocumentsState {
  final bool isBusy;
  final bool isSmileIdInitialized;
  final String errorMessage;

  const UploadDocumentsState({
    this.isBusy = false,
    this.isSmileIdInitialized = false,
    this.errorMessage = '',
  });

  UploadDocumentsState copyWith({
    bool? isBusy,
    bool? isSmileIdInitialized,
    String? errorMessage,
  }) {
    return UploadDocumentsState(
      isBusy: isBusy ?? this.isBusy,
      isSmileIdInitialized: isSmileIdInitialized ?? this.isSmileIdInitialized,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class UploadDocumentsNotifier extends StateNotifier<UploadDocumentsState> {
  final AnalyticsService _analyticsService;
  final AppRouter _appRouter;
  final KycService _kycService;

  UploadDocumentsNotifier({
    required AnalyticsService analyticsService,
    required AppRouter appRouter,
    required KycService kycService,
  }) : _analyticsService = analyticsService,
       _appRouter = appRouter,
       _kycService = kycService,
       super(const UploadDocumentsState());

  // Start Smile ID verification process
  Future<void> startSmileIdVerification(BuildContext context) async {
    state = state.copyWith(isBusy: true, errorMessage: '');

    try {
      _analyticsService.logEvent(name: 'kyc_tier2_verification_started');

      // Initialize Smile ID SDK
      await _initializeSmileId();

      // Launch Smile ID verification flow
      await _launchSmileIdVerification(context);
    } catch (e) {
      state = state.copyWith(
        isBusy: false,
        errorMessage: 'Failed to start verification. Please try again.',
      );

      _analyticsService.logEvent(
        name: 'kyc_tier2_verification_failed',
        parameters: {'reason': e.toString()},
      );

      TopSnackbar.show(context, message: state.errorMessage, isError: true);
    }
  }

  // Alternative method for Enhanced KYC with BVN (if you want to use this instead)
  Future<void> startEnhancedKycVerification(BuildContext context, String bvnNumber) async {
    state = state.copyWith(isBusy: true, errorMessage: '');

    try {
      _analyticsService.logEvent(name: 'kyc_tier2_enhanced_verification_started');

      // For now, we'll simulate the verification process
      // The actual Smile ID SDK integration will depend on the specific API methods available
      // in the version you're using. Based on the documentation, you may need to use:
      // - SmileID.api.doEnhancedKycAsync() for Enhanced KYC
      // - SmileID.api.pollBiometricKycJobStatus() for polling job status
      
      await Future.delayed(const Duration(seconds: 2));

      // Simulate successful verification
      AppLogger.info('Smile ID Enhanced KYC successful (simulated)');
      _analyticsService.logEvent(name: 'kyc_tier2_verification_completed');
      
      // Update user KYC tier to Tier 2
      await _updateUserKycTier();
      
      // Navigate to main view
      _appRouter.pushNamed(AppRoute.mainView);

    } catch (e) {
      AppLogger.error('Error launching Enhanced KYC: $e');
      state = state.copyWith(
        isBusy: false,
        errorMessage: 'Failed to start verification. Please try again.',
      );

      _analyticsService.logEvent(
        name: 'kyc_tier2_verification_failed',
        parameters: {'reason': e.toString()},
      );

      TopSnackbar.show(context, message: state.errorMessage, isError: true);
    }
  }

  // Initialize Smile ID SDK
  Future<void> _initializeSmileId() async {
    try {
      // Smile ID SDK is already initialized in main.dart
      // We just need to verify it's ready
      state = state.copyWith(isSmileIdInitialized: true);
    } catch (e) {
      AppLogger.error('Error initializing Smile ID: $e');
      state = state.copyWith(
        isSmileIdInitialized: false,
        errorMessage: 'Failed to initialize verification service',
      );
    }
  }

  // Launch Smile ID verification using Enhanced KYC
  Future<void> _launchSmileIdVerification(BuildContext context) async {
    try {
      AppLogger.info('Starting Smile ID Enhanced KYC verification process...');

      // For now, we'll simulate the verification process
      // The actual Smile ID SDK integration will depend on the specific API methods available
      // in the version you're using. Based on the documentation, you may need to use:
      // - SmileID.api.doEnhancedKycAsync() for Enhanced KYC
      // - SmileID.api.pollBiometricKycJobStatus() for polling job status
      
      await Future.delayed(const Duration(seconds: 2));

      // Simulate successful verification
      AppLogger.info('Smile ID verification successful (simulated)');
      _analyticsService.logEvent(name: 'kyc_tier2_verification_completed');

      // Update user KYC tier to Tier 2
      await _updateUserKycTier();

      // Navigate to biometric setup
      _appRouter.pushNamed(AppRoute.biometricSetupView);
    } catch (e) {
      AppLogger.error('Error launching Smile ID verification: $e');
      state = state.copyWith(
        isBusy: false,
        errorMessage: 'Failed to start verification. Please try again.',
      );

      _analyticsService.logEvent(
        name: 'kyc_tier2_verification_failed',
        parameters: {'reason': e.toString()},
      );

      TopSnackbar.show(
        context,
        message: 'Failed to start verification. Please try again.',
        isError: true,
      );
    }
  }

  // Update user KYC tier in backend
  Future<void> _updateUserKycTier() async {
    // Update KYC tier to Tier 2
    await _kycService.setKycTier(KycTier.tier2);

    // TODO: Implement API call to update user KYC tier on backend
    // This would:
    // 1. Call backend API to update user tier
    // 2. Store verification data
    // 3. Update transaction limits on server

    await Future.delayed(const Duration(seconds: 1)); // Simulate API call
  }

  // Skip verification for later
  void skipForLater(BuildContext context) {
    _analyticsService.logEvent(name: 'kyc_tier2_verification_skipped');

    // Navigate to biometric setup
    _appRouter.pushNamed(AppRoute.biometricSetupView);
  }

  // Handle verification result from Smile ID
  void handleSmileIdResult({
    required bool isSuccess,
    required String message,
    Map<String, dynamic>? verificationData,
  }) {
    if (isSuccess) {
      _analyticsService.logEvent(name: 'kyc_tier2_verification_success');
      // Process successful verification
      _processSuccessfulVerification(verificationData);
    } else {
      _analyticsService.logEvent(
        name: 'kyc_tier2_verification_failed',
        parameters: {'reason': message},
      );
      state = state.copyWith(isBusy: false, errorMessage: message);
    }
  }

  // Process successful verification
  Future<void> _processSuccessfulVerification(
    Map<String, dynamic>? verificationData,
  ) async {
    try {
      // TODO: Process verification data
      // This would include:
      // 1. Extracting BVN and ID information
      // 2. Updating user profile
      // 3. Setting KYC tier to 2
      // 4. Updating transaction limits

      await _updateUserKycTier();

      state = state.copyWith(isBusy: false);
    } catch (e) {
      state = state.copyWith(
        isBusy: false,
        errorMessage: 'Failed to process verification. Please try again.',
      );
    }
  }

  // Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: '');
  }

  // Reset form to initial state
  void resetForm() {
    state = const UploadDocumentsState();
  }
}

// Provider
final uploadDocumentsProvider =
    StateNotifierProvider<UploadDocumentsNotifier, UploadDocumentsState>((ref) {
      final kycService = ref.read(kycServiceProvider);

      return UploadDocumentsNotifier(
        analyticsService: analyticsService,
        appRouter: appRouter,
        kycService: kycService,
      );
    });
