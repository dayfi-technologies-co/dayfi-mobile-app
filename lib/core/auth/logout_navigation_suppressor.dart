/// While [begin] / [end] wraps logout, global 401 handlers must not navigate —
/// manual logout owns a single [AppRouter.pushCheckEmailAndClearStack] transition.
class LogoutNavigationSuppressor {
  LogoutNavigationSuppressor._();

  static bool _active = false;

  static bool get isActive => _active;

  static void begin() {
    _active = true;
  }

  static void end() {
    _active = false;
  }
}
