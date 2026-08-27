import 'package:dayfi/features/dayflow/helpers/dayflow_draft_schedules.dart';
import 'package:dayfi/features/dayflow/models/dayflow_models.dart';

/// Prefill + identifiers when editing an existing DayFlow autopay schedule.
class DayFlowAutomationEditContext {
  final String flowId;
  final String scheduleId;
  final double amount;
  final String frequency;
  final DateTime startAt;
  final DateTime? endAt;
  final String paymentType;
  final String? recipientId;
  final String? recipientHint;
  final String? billCustomerId;
  final String? billProviderName;

  const DayFlowAutomationEditContext({
    required this.flowId,
    required this.scheduleId,
    required this.amount,
    required this.frequency,
    required this.startAt,
    required this.paymentType,
    this.endAt,
    this.recipientId,
    this.recipientHint,
    this.billCustomerId,
    this.billProviderName,
  });

  bool get isBill => paymentType == 'bill';

  String get recipientDisplayName {
    final parsed = parseRecipientHint(recipientHint);
    if (parsed.label.isNotEmpty) return parsed.label;
    return '';
  }

  String? get recipientChannelLabel {
    final parsed = parseRecipientHint(recipientHint);
    return parsed.channel;
  }

  String screenTitleForKind({required bool isSend}) {
    if (isSend) {
      final name = recipientDisplayName;
      if (name.isNotEmpty) return 'Send to $name';
      return 'Send to someone';
    }
    return 'Pay a bill';
  }

  static ({String label, String? channel}) parseRecipientHint(String? hint) {
    if (hint == null || hint.trim().isEmpty) {
      return (label: '', channel: null);
    }
    final parts = hint.split('·').map((s) => s.trim()).where((s) => s.isNotEmpty);
    final list = parts.toList();
    if (list.length >= 2) {
      return (label: list.first, channel: list.sublist(1).join(' · '));
    }
    return (label: hint.trim(), channel: null);
  }

  static DayFlowAutomationEditContext? fromScheduleInstance({
    required DayBudgetScheduleInstance item,
    DayFlowEnvelopeSchedule? schedule,
    DayFlowEnvelope? flow,
  }) {
    final resolved = schedule;
    final startRaw = resolved?.nextRunAt;
    final parsedStart = startRaw != null ? DateTime.tryParse(startRaw) : null;
    final localStart = (parsedStart ?? item.dueAt).toLocal();

    final freq = () {
      final explicit = resolved?.frequency.trim().toLowerCase();
      if (explicit != null &&
          explicit.isNotEmpty &&
          explicit != 'monthly') {
        return explicit;
      }
      return dayflowFrequencyFromLabel(
        resolved?.dueLabel ?? item.dueLabel ?? flow?.periodLabel,
      );
    }();

    final hint = item.recipientHint ?? resolved?.recipientHint;
    final billParts = parseRecipientHint(hint);

    return DayFlowAutomationEditContext(
      flowId: item.flowId,
      scheduleId: item.scheduleId,
      amount: item.amount > 0 ? item.amount : (resolved?.amount ?? 0),
      frequency: freq,
      startAt: localStart,
      paymentType: item.paymentType,
      recipientId: item.recipientId ?? resolved?.recipientId,
      recipientHint: hint,
      billProviderName: item.paymentType == 'bill' ? billParts.label : null,
      billCustomerId:
          item.paymentType == 'bill' && billParts.channel != null
              ? billParts.channel
              : null,
    );
  }
}
