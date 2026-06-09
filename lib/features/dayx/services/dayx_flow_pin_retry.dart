import 'package:dayfi/features/dayx/models/dayx_flow.dart';

/// Inline DayX flow PIN attempts after review (initial try + 3 retries).
class DayxFlowPinRetry {
  DayxFlowPinRetry._();

  static const int maxAttempts = 4;

  static String? messageAfterFailure(int failures) {
    if (failures >= maxAttempts) {
      return 'Too many wrong PINs. Please start again.';
    }
    final left = maxAttempts - failures;
    return 'Wrong PIN. $left ${left == 1 ? 'try' : 'tries'} left.';
  }

  static bool shouldRunExecute(DayxFlowTurnResult result) {
    final exec = result.execute;
    if (exec == null) return false;
    final pin = exec['pin']?.toString() ?? '';
    return pin.length >= 4;
  }

  /// Backend returns `Invalid PIN` (400) for a wrong transaction PIN only.
  static bool isInvalidPinError(String? message) {
    if (message == null || message.trim().isEmpty) return false;
    final m = message.toLowerCase();
    if (m.contains('whitelist')) return false;
    return m.contains('invalid pin') ||
        m.contains('incorrect pin') ||
        m.contains('wrong pin') ||
        m.contains('pin does not match') ||
        m.contains('pin is incorrect');
  }
}
