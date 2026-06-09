import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/constants/storage_keys.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/services/local/secure_storage.dart';

/// Routes after a successful auth token is saved (email, Google, or Apple).
///
/// Kuda-style behaviour:
/// - Profile incomplete → finish signup
/// - Local passcode exists → enter passcode to unlock
/// - No local passcode → set passcode once on this device
Future<void> navigateAfterAuthenticatedSession({
  required bool profileComplete,
}) async {
  if (!profileComplete) {
    await appRouter.pushNamed(AppRoute.successSignupView);
    return;
  }

  final passcode =
      await locator<SecureStorageService>().read(StorageKeys.passcode);
  if (passcode.trim().isNotEmpty) {
    await appRouter.pushNamed(AppRoute.passcodeView);
    return;
  }

  await appRouter.pushNamed(AppRoute.createPasscodeView, arguments: false);
}
