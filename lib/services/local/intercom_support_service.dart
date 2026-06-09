import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/models/user_model.dart';
import 'package:dayfi/services/local/local_cache.dart';
import 'package:intercom_flutter/intercom_flutter.dart';

/// Opens Intercom with an identified user so customers can start new conversations.
class IntercomSupportService {
  static Future<User?> _resolveUser(User? user) async {
    if (user != null) return user;
    try {
      final data = await locator<LocalCache>().getUser();
      if (data.isEmpty) return null;
      return User.fromJson(data);
    } catch (e) {
      AppLogger.warning('Intercom: could not load user from cache: $e');
      return null;
    }
  }

  static Future<void> syncUser(User? user) async {
    final resolved = await _resolveUser(user);
    if (resolved == null) return;
    try {
      final userId = resolved.userId.trim();
      if (userId.isEmpty) return;

      await Intercom.instance.loginIdentifiedUser(userId: userId);

      final name = '${resolved.firstName} ${resolved.lastName}'.trim();
      await Intercom.instance.updateUser(
        email: resolved.email.isNotEmpty ? resolved.email : null,
        name: name.isNotEmpty ? name : null,
        phone:
            (resolved.phoneNumber?.isNotEmpty ?? false)
                ? resolved.phoneNumber
                : null,
      );
    } catch (e) {
      AppLogger.warning('Intercom user sync failed: $e');
    }
  }

  /// Opens the Intercom messenger so customers can start or continue support chats.
  static Future<void> openContactSupport({User? user}) async {
    await syncUser(user);
    await Intercom.instance.setLauncherVisibility(IntercomVisibility.gone);

    try {
      await Intercom.instance.displayMessenger();
      return;
    } catch (e) {
      AppLogger.warning('Intercom messenger failed: $e');
    }

    try {
      await Intercom.instance.displayMessageComposer('');
      return;
    } catch (e) {
      AppLogger.warning('Intercom composer failed: $e');
    }

    await Intercom.instance.displayMessages();
  }
}
