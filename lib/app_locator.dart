import 'package:get_it/get_it.dart';
import 'package:dayfi/common/utils/app_strings.dart';
import 'package:dayfi/common/widgets/loading_bottom_sheet_controller.dart';
import 'package:dayfi/core/navigation/navigation.dart';
import 'package:dayfi/flavors.dart';
import 'package:dayfi/services/remote/auth_service.dart';
import 'package:dayfi/services/remote/network/network_service.dart';

import 'package:dayfi/services/local/secure_storage.dart';
import 'package:dayfi/services/local/local_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';

GetIt locator = GetIt.instance;

Future<void> setupLocator() async {
  //ensure stored user data is cleared
  // clearLoggedInUserCache();

  locator.registerFactory<NetworkService>(
    () => NetworkService(baseUrl: F.baseUrl),
  );
  locator.registerLazySingleton<AuthService>(
    () => AuthService(networkService: locator()),
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
}

//get singleton classes
final appRouter = locator<AppRouter>();
final secureStorage = locator<SecureStorageService>();
final localCache = locator<LocalCache>();
final appStrings = locator<AppStrings>();
final sharedPreferences = locator<SharedPreferences>();
final networkService = locator<NetworkService>();
final authService = locator<AuthService>();
final loadingModalController = locator<LoadingModalController>();
