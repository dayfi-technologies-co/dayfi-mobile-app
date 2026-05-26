/// De-duplicates the “session expired → go to Login” redirect.
///
/// Multiple in-flight requests can each receive a 401 at the same time. Both
/// [AppInterceptor.onResponse] and [NetworkService] Dio error handlers call
/// `pushNamedAndRemoveAllBehind('/loginView', …)`, which without a guard ends
/// up pushing the login screen more than once.
///
/// Usage:
/// ```dart
/// if (!UnauthorizedNavigationGuard.tryBegin()) return;
/// try {
///   // … clear data & navigate exactly once …
/// } finally {
///   UnauthorizedNavigationGuard.scheduleEnd();
/// }
/// ```
class UnauthorizedNavigationGuard {
  UnauthorizedNavigationGuard._();

  static bool _navigating = false;

  static bool get isActive => _navigating;

  /// Returns `true` if the caller is allowed to navigate now. Subsequent
  /// callers (until [scheduleEnd] / [end] runs) get `false` and should bail.
  static bool tryBegin() {
    if (_navigating) return false;
    _navigating = true;
    return true;
  }

  /// Resets the guard immediately. Prefer [scheduleEnd] in async paths.
  static void end() {
    _navigating = false;
  }

  /// Resets the guard after [delay] so any quickly-following 401s in the
  /// same burst are still suppressed, but a later session can re-trigger.
  static void scheduleEnd({
    Duration delay = const Duration(seconds: 2),
  }) {
    Future<void>.delayed(delay, () {
      _navigating = false;
    });
  }
}
