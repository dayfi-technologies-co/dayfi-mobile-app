import 'package:dayfi/core/network/network.service.dart';
import 'package:get_it/get_it.dart';
import 'package:dayfi/core/navigation/navigation.dart';
import 'package:dayfi/flavor.dart';
import 'package:dayfi/services/remote/auth_service.dart';

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

  locator.registerLazySingleton(() => SecureStorage());

  locator.registerLazySingleton(
    () => LocalCache(
      storage: locator<SecureStorage>(),
      sharedPreferences: locator<SharedPreferences>(),
    ),
  );
}

//get singleton classes
final appRouter = locator<AppRouter>();
final secureStorage = locator<SecureStorage>();
final localCache = locator<LocalCache>();
final sharedPreferences = locator<SharedPreferences>();
final networkService = locator<NetworkService>();
final authService = locator<AuthService>();
