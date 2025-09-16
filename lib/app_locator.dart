import 'package:get_it/get_it.dart';
import 'package:onebank/core/navigation/navigation.dart';


GetIt locator = GetIt.instance;

Future<void> setupLocator() async {
  //ensure stored user data is cleared
  // clearLoggedInUserCache();

  locator.registerLazySingleton(
    () => AppRouter(),
  );

}

//get singleton classes
final appRouter = locator<AppRouter>();

