import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/services/local/local_cache.dart';
import 'package:dayfi/services/local/secure_storage.dart';
import 'package:dayfi/common/constants/storage_keys.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';
import 'package:dayfi/features/send/vm/send_viewmodel.dart';
import 'package:dayfi/features/recipients/vm/recipients_viewmodel.dart';
import 'package:dayfi/features/transactions/vm/transactions_viewmodel.dart';
import 'package:dayfi/features/auth/passcode/vm/passcode_viewmodel.dart';
import 'package:dayfi/features/profile/edit_profile/vm/edit_profile_viewmodel.dart';
import 'package:dayfi/features/auth/complete_personal_information/vm/complete_personal_information_viewmodel.dart';
import 'package:dayfi/features/auth/login/vm/login_viewmodel.dart';
import 'package:dayfi/features/auth/signup/vm/signup_viewmodel.dart';
import 'package:dayfi/features/auth/reset_password/vm/reset_password_viewmodel.dart';
import 'package:dayfi/features/auth/forgot_password/vm/forgot_password_viewmodel.dart';
import 'package:dayfi/features/auth/create_passcode/vm/create_passcode_viewmodel.dart';
import 'package:dayfi/features/auth/success_signup/vm/success_signup_viewmodel.dart';
import 'package:dayfi/features/auth/onboarding/vm/onboarding_viewmodel.dart';
import 'package:dayfi/features/auth/biometric_setup/vm/biometric_setup_viewmodel.dart';
import 'package:dayfi/features/auth/verify_email/vm/verify_email_viewmodel.dart';
import 'package:dayfi/features/auth/upload_documents/vm/upload_documents_viewmodel.dart';

/// Service responsible for clearing all user data from the device
/// This includes data from storage, Riverpod providers, and any cached data
class DataClearingService {
  final LocalCache _localCache = locator<LocalCache>();

  /// Clears all user data from the device
  /// This method should be called when:
  /// 1. User manually logs out
  /// 2. Token expires and user is redirected to login
  /// 3. Account is deleted
  Future<void> clearAllUserData(WidgetRef ref) async {
    try {
      AppLogger.info('Starting comprehensive data clearing...');
      
      // 1. Clear all storage data (secure storage + shared preferences)
      await _clearStorageData();
      
      // 2. Reset all Riverpod providers to their initial state
      await _resetAllProviders(ref);
      
      // 3. Clear any additional cached data
      await _clearCachedData();
      
      AppLogger.info('All user data cleared successfully');
    } catch (e) {
      AppLogger.error('Error during comprehensive data clearing: $e');
      rethrow;
    }
  }

  /// Clears all user data using a ProviderContainer (for use in interceptors)
  Future<void> clearAllUserDataWithContainer(ProviderContainer container) async {
    try {
      AppLogger.info('Starting comprehensive data clearing with container...');
      
      // 1. Clear all storage data (secure storage + shared preferences)
      await _clearStorageData();
      
      // 2. Reset all Riverpod providers to their initial state using container
      await _resetAllProvidersWithContainer(container);
      
      // 3. Clear any additional cached data
      await _clearCachedData();
      
      AppLogger.info('All user data cleared successfully');
    } catch (e) {
      AppLogger.error('Error during comprehensive data clearing: $e');
      rethrow;
    }
  }

  /// Clear all data from storage (secure storage + shared preferences)
  Future<void> _clearStorageData() async {
    try {
      AppLogger.info('Clearing storage data...');
      await _localCache.clearAllUserData();
      
      // Also clear secure storage data directly
      final secureStorage = locator<SecureStorageService>();
      await secureStorage.delete(StorageKeys.token);
      await secureStorage.delete(StorageKeys.user);
      await secureStorage.delete(StorageKeys.email);
      await secureStorage.delete(StorageKeys.password);
      await secureStorage.delete(StorageKeys.passcode);
      await secureStorage.delete(StorageKeys.isFirstTime);
      await secureStorage.delete(StorageKeys.hasSeenWelcome);
      
      AppLogger.info('Storage data cleared successfully');
    } catch (e) {
      AppLogger.error('Error clearing storage data: $e');
      rethrow;
    }
  }

  /// Reset all Riverpod providers to their initial state
  Future<void> _resetAllProviders(WidgetRef ref) async {
    try {
      AppLogger.info('Resetting all providers...');
      
      // Reset all viewmodel providers to their initial state
      ref.invalidate(profileViewModelProvider);
      ref.invalidate(sendViewModelProvider);
      ref.invalidate(recipientsProvider);
      ref.invalidate(transactionsProvider);
      ref.invalidate(passcodeProvider);
      ref.invalidate(editProfileProvider);
      ref.invalidate(completePersonalInfoProvider);
      ref.invalidate(loginProvider);
      ref.invalidate(signupProvider);
      ref.invalidate(resetPasswordProvider);
      ref.invalidate(forgotPasswordProvider);
      ref.invalidate(createPasscodeProvider);
      ref.invalidate(successSignupProvider);
      ref.invalidate(onboardingViewModelProvider);
      ref.invalidate(biometricSetupProvider);
      ref.invalidate(verifyEmailProvider);
      ref.invalidate(uploadDocumentsProvider);
      
      AppLogger.info('All providers reset successfully');
    } catch (e) {
      AppLogger.error('Error resetting providers: $e');
      rethrow;
    }
  }

  /// Reset all Riverpod providers using a ProviderContainer
  Future<void> _resetAllProvidersWithContainer(ProviderContainer container) async {
    try {
      AppLogger.info('Resetting all providers with container...');
      
      // Reset all viewmodel providers to their initial state
      container.invalidate(profileViewModelProvider);
      container.invalidate(sendViewModelProvider);
      container.invalidate(recipientsProvider);
      container.invalidate(transactionsProvider);
      container.invalidate(passcodeProvider);
      container.invalidate(editProfileProvider);
      container.invalidate(completePersonalInfoProvider);
      container.invalidate(loginProvider);
      container.invalidate(signupProvider);
      container.invalidate(resetPasswordProvider);
      container.invalidate(forgotPasswordProvider);
      container.invalidate(createPasscodeProvider);
      container.invalidate(successSignupProvider);
      container.invalidate(onboardingViewModelProvider);
      container.invalidate(biometricSetupProvider);
      container.invalidate(verifyEmailProvider);
      container.invalidate(uploadDocumentsProvider);
      
      AppLogger.info('All providers reset successfully');
    } catch (e) {
      AppLogger.error('Error resetting providers: $e');
      rethrow;
    }
  }

  /// Clear any additional cached data that might not be covered by storage or providers
  Future<void> _clearCachedData() async {
    try {
      AppLogger.info('Clearing cached data...');
      
      // Clear any image cache
      // Note: Flutter automatically manages image cache, but we can force clear it
      // if needed in the future
      
      // Clear any other cached data here
      // For example: API response cache, temporary files, etc.
      
      AppLogger.info('Cached data cleared successfully');
    } catch (e) {
      AppLogger.error('Error clearing cached data: $e');
      rethrow;
    }
  }

  /// Clear only sensitive data (for partial clearing scenarios)
  Future<void> clearSensitiveData(WidgetRef ref) async {
    try {
      AppLogger.info('Clearing sensitive data only...');
      
      // Clear sensitive storage data
      await _localCache.deleteToken();
      await _localCache.removeFromLocalCache('userTokenId');
      await _localCache.removeFromLocalCache('user_email');
      await _localCache.removeFromLocalCache('user_password');
      await _localCache.removeFromLocalCache('user_passcode');
      
      // Reset sensitive providers
      ref.invalidate(profileViewModelProvider);
      ref.invalidate(passcodeProvider);
      
      AppLogger.info('Sensitive data cleared successfully');
    } catch (e) {
      AppLogger.error('Error clearing sensitive data: $e');
      rethrow;
    }
  }
}

/// Provider for the DataClearingService
final dataClearingServiceProvider = Provider<DataClearingService>((ref) {
  return DataClearingService();
});
