import 'package:dayfi/features/dayx/widgets/dayx_inline_success.dart';

/// Outcome of running a DayX flow `execute` payload (bank send, swap, etc.).
class DayxFlowExecuteResult {
  const DayxFlowExecuteResult._({
    required this.success,
    this.message,
    this.invalidPin = false,
    this.receipt,
  });

  final bool success;
  final String? message;

  /// True when the backend rejected the transaction PIN (retry allowed).
  final bool invalidPin;

  /// Inline chat receipt when the transaction succeeds.
  final DayxInlineSuccess? receipt;

  static DayxFlowExecuteResult ok({DayxInlineSuccess? receipt}) =>
      DayxFlowExecuteResult._(success: true, receipt: receipt);

  static DayxFlowExecuteResult failure(
    String message, {
    bool invalidPin = false,
  }) =>
      DayxFlowExecuteResult._(
        success: false,
        message: message,
        invalidPin: invalidPin,
      );
}
