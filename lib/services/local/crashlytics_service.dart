import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/models/user_model.dart';

/// General error reporter used for logging errors to [FirebaseCrashlytics]
FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

class CrashlyticsService {
  FirebaseCrashlytics get crashlytics => _crashlytics;

  Future<void> reportError(error, stackTrace) async {
    try {
      User user = User.fromJson(await localCache.getUser());
      crashlytics.setUserIdentifier(user.userId);
      crashlytics.setCustomKey("Name", '${user.lastName} ${user.firstName}');
      crashlytics.setCustomKey("Email", user.email);
      crashlytics.setCustomKey("Mobile", user.phoneNumber ?? '');
      crashlytics.recordError(error, stackTrace);
    } catch (error) {
      AppLogger.error(error);
    }
  }
}
