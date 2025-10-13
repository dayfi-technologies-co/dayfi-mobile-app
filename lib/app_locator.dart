import 'package:get_it/get_it.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/common/utils/app_strings.dart';
import 'package:dayfi/common/widgets/loading_bottom_sheet_controller.dart';
import 'package:dayfi/core/navigation/navigation.dart';
import 'package:dayfi/flavors.dart';
import 'package:dayfi/services/remote/auth_service.dart';
import 'package:dayfi/services/remote/payment_service.dart';
import 'package:dayfi/services/remote/wallet_service.dart';
import 'package:dayfi/services/remote/network/network_service.dart';

import 'package:dayfi/services/local/secure_storage.dart';
import 'package:dayfi/services/local/local_cache.dart';
import 'package:dayfi/services/local/connectivity_service.dart';
import 'package:dayfi/services/local/analytics_service.dart';
import 'package:dayfi/services/kyc/kyc_service.dart';
import 'package:dayfi/services/version_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

GetIt locator = GetIt.instance;

// Global provider container reference for resetting providers
ProviderContainer? _globalProviderContainer;

Future<void> setupLocator() async {
  //ensure stored user data is cleared
  // clearLoggedInUserCache();

  locator.registerFactory<NetworkService>(
    () => NetworkService(baseUrl: F.baseUrl),
  );
  locator.registerLazySingleton<AuthService>(
    () => AuthService(networkService: locator()),
  );
  locator.registerLazySingleton<PaymentService>(
    () => PaymentService(networkService: locator()),
  );
  locator.registerLazySingleton<WalletService>(
    () => WalletService(networkService: locator()),
  );

  final sharedPreferences = await SharedPreferences.getInstance();
  locator.registerSingleton(sharedPreferences);

  locator.registerLazySingleton(() => AppRouter());

  locator.registerLazySingleton(() => SecureStorageService());

  locator.registerLazySingleton(
    () => LocalCache(
      storage: locator<SecureStorageService>(),
      sharedPreferences: locator<SharedPreferences>(),
    ),
  );

  locator.registerLazySingleton(() => AppStrings());

  locator.registerLazySingleton(() => LoadingModalController.instance);
  
  // Initialize analytics service
  locator.registerLazySingleton(() => AnalyticsService());
  
  // Initialize KYC service
  locator.registerLazySingleton(() => KycService(secureStorage: locator<SecureStorageService>()));
  
  // Initialize version service
  locator.registerLazySingleton(() => VersionService(sharedPreferences));
  
  // Initialize connectivity service
  await ConnectivityService.initialize();
}

//get singleton classes
final appRouter = locator<AppRouter>();
final secureStorage = locator<SecureStorageService>();
final localCache = locator<LocalCache>();
final appStrings = locator<AppStrings>();
final sharedPreferences = locator<SharedPreferences>();
final networkService = locator<NetworkService>();
final authService = locator<AuthService>();
final paymentService = locator<PaymentService>();
final walletService = locator<WalletService>();
final loadingModalController = locator<LoadingModalController>();
final analyticsService = locator<AnalyticsService>();
final kycService = locator<KycService>();
final versionService = locator<VersionService>();

// Provider container management
void setGlobalProviderContainer(ProviderContainer container) {
  _globalProviderContainer = container;
}

ProviderContainer? getGlobalProviderContainer() {
  return _globalProviderContainer;
}
