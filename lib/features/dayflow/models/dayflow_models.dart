import 'package:dayfi/features/dayflow/constants/dayflow_copy.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_draft_schedules.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_wallet_balance.dart';

class DayFlowCategory {
  final String name;
  final double allocated;
  final double spent;
  final bool locked;

  const DayFlowCategory({
    required this.name,
    required this.allocated,
    this.spent = 0,
    this.locked = false,
  });

  double get remaining => (allocated - spent).clamp(0, double.infinity);

  double get progress =>
      allocated > 0 ? (spent / allocated).clamp(0.0, 1.2) : 0;

  Map<String, dynamic> toJson() => {
    'name': name,
    'allocated': allocated,
    'spent': spent,
    'locked': locked,
  };

  factory DayFlowCategory.fromJson(Map<String, dynamic> json) {
    return DayFlowCategory(
      name: json['name']?.toString() ?? '',
      allocated: (json['allocated'] as num?)?.toDouble() ?? 0,
      spent: (json['spent'] as num?)?.toDouble() ?? 0,
      locked: json['locked'] == true,
    );
  }

  DayFlowCategory copyWith({double? spent, bool? locked}) {
    return DayFlowCategory(
      name: name,
      allocated: allocated,
      spent: spent ?? this.spent,
      locked: locked ?? this.locked,
    );
  }
}

class DayFlowUpcomingPayment {
  final String title;
  final double amount;
  final String currency;
  final String dueLabel;
  final String? recipientHint;
  final String? recipientId;
  final bool autoSend;

  const DayFlowUpcomingPayment({
    required this.title,
    required this.amount,
    required this.currency,
    required this.dueLabel,
    this.recipientHint,
    this.recipientId,
    this.autoSend = false,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'amount': amount,
    'currency': currency,
    'dueLabel': dueLabel,
    if (recipientHint != null) 'recipientHint': recipientHint,
    if (recipientId != null) 'recipientId': recipientId,
    'autoSend': autoSend,
  };

  factory DayFlowUpcomingPayment.fromJson(Map<String, dynamic> json) {
    return DayFlowUpcomingPayment(
      title: json['title']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency']?.toString() ?? kDayFlowWalletCurrency,
      dueLabel: json['dueLabel']?.toString() ?? '',
      recipientHint: json['recipientHint']?.toString(),
      recipientId: json['recipientId']?.toString(),
      autoSend: json['autoSend'] == true,
    );
  }

  DayFlowUpcomingPayment copyWith({
    String? recipientHint,
    String? recipientId,
    bool? autoSend,
  }) {
    return DayFlowUpcomingPayment(
      title: title,
      amount: amount,
      currency: currency,
      dueLabel: dueLabel,
      recipientHint: recipientHint ?? this.recipientHint,
      recipientId: recipientId ?? this.recipientId,
      autoSend: autoSend ?? this.autoSend,
    );
  }
}

class DayFlowGoal {
  final String id;
  final String title;
  final double targetAmount;
  final double savedAmount;
  final String? targetDateLabel;

  const DayFlowGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    this.savedAmount = 0,
    this.targetDateLabel,
  });

  double get progress =>
      targetAmount > 0 ? (savedAmount / targetAmount).clamp(0.0, 1.0) : 0;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'targetAmount': targetAmount,
    'savedAmount': savedAmount,
    if (targetDateLabel != null) 'targetDateLabel': targetDateLabel,
  };

  factory DayFlowGoal.fromJson(Map<String, dynamic> json) {
    return DayFlowGoal(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0,
      savedAmount: (json['savedAmount'] as num?)?.toDouble() ?? 0,
      targetDateLabel: json['targetDateLabel']?.toString(),
    );
  }
}

class DayFlowPlan {
  final String id;
  final String title;
  final String periodLabel;
  final String budgetType;
  final double totalBudget;
  final double spent;
  final String currency;
  final String summaryLine;
  final List<DayFlowCategory> categories;
  final List<DayFlowUpcomingPayment> upcoming;
  final List<DayFlowGoal> goals;
  final List<String> lockedCategories;
  final double leftover;
  final bool sweepToDayEarn;

  const DayFlowPlan({
    required this.id,
    required this.title,
    required this.periodLabel,
    this.budgetType = 'monthly',
    required this.totalBudget,
    required this.spent,
    required this.currency,
    required this.summaryLine,
    required this.categories,
    required this.upcoming,
    this.goals = const [],
    this.lockedCategories = const [],
    this.leftover = 0,
    this.sweepToDayEarn = false,
  });

  double get remaining => (totalBudget - spent).clamp(0, double.infinity);

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'periodLabel': periodLabel,
    'budgetType': budgetType,
    'totalBudget': totalBudget,
    'spent': spent,
    'currency': currency,
    'summaryLine': summaryLine,
    'categories': categories.map((c) => c.toJson()).toList(),
    'upcoming': upcoming.map((u) => u.toJson()).toList(),
    'goals': goals.map((g) => g.toJson()).toList(),
    'lockedCategories': lockedCategories,
    'leftover': leftover,
    'sweepToDayEarn': sweepToDayEarn,
  };

  factory DayFlowPlan.fromJson(Map<String, dynamic> json) {
    final categories = <DayFlowCategory>[];
    for (final c in json['categories'] as List<dynamic>? ?? []) {
      if (c is Map) {
        categories.add(DayFlowCategory.fromJson(Map<String, dynamic>.from(c)));
      }
    }
    final upcoming = <DayFlowUpcomingPayment>[];
    for (final u in json['upcoming'] as List<dynamic>? ?? []) {
      if (u is Map) {
        upcoming.add(
          DayFlowUpcomingPayment.fromJson(Map<String, dynamic>.from(u)),
        );
      }
    }
    final goals = <DayFlowGoal>[];
    for (final g in json['goals'] as List<dynamic>? ?? []) {
      if (g is Map) {
        goals.add(DayFlowGoal.fromJson(Map<String, dynamic>.from(g)));
      }
    }
    final locked = <String>[];
    for (final l in json['lockedCategories'] as List<dynamic>? ?? []) {
      locked.add(l.toString());
    }
    return DayFlowPlan(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? "This Month's Plan",
      periodLabel: json['periodLabel']?.toString() ?? 'This Month',
      budgetType: json['budgetType']?.toString() ?? 'monthly',
      totalBudget: (json['totalBudget'] as num?)?.toDouble() ?? 0,
      spent: (json['spent'] as num?)?.toDouble() ?? 0,
      currency: json['currency']?.toString() ?? kDayFlowWalletCurrency,
      summaryLine:
          json['summaryLine']?.toString() ?? DayFlowCopy.onTrackSummary,
      categories: categories,
      upcoming: upcoming,
      goals: goals,
      lockedCategories: locked,
      leftover: (json['leftover'] as num?)?.toDouble() ?? 0,
      sweepToDayEarn: json['sweepToDayEarn'] == true,
    );
  }

  static bool _shouldLockCategory(String name) {
    final n = name.toLowerCase();
    return n.contains('rent') ||
        n.contains('school') ||
        n.contains('emergency') ||
        n.contains('saving');
  }

  /// Build a saved plan from an AI plan draft.
  static DayFlowPlan fromDraft(DayFlowPlanDraft draft) {
    final lockedNames = <String>[];
    final categories =
        draft.categories.map((c) {
          final locked = _shouldLockCategory(c.name);
          if (locked) lockedNames.add(c.name);
          return DayFlowCategory(
            name: c.name,
            allocated: c.allocated,
            locked: locked,
          );
        }).toList();

    return DayFlowPlan(
      id: 'plan-${DateTime.now().millisecondsSinceEpoch}',
      title: draft.title,
      periodLabel: draft.periodLabel,
      budgetType: draft.budgetType,
      totalBudget: draft.totalBudget,
      spent: 0,
      currency: draft.currency,
      summaryLine: DayFlowCopy.onTrackSummary,
      leftover: draft.leftover,
      sweepToDayEarn: draft.sweepToDayEarn,
      lockedCategories: lockedNames,
      goals:
          draft.goals
              .map(
                (g) => DayFlowGoal(
                  id: 'goal-${g.title.hashCode}',
                  title: g.title,
                  targetAmount: g.targetAmount,
                  savedAmount: g.savedAmount,
                  targetDateLabel: g.targetDateLabel,
                ),
              )
              .toList(),
      categories: categories,
      upcoming: dayflowUpcomingFromDraft(draft),
    );
  }

  /// Seed the chat overlay when editing an existing saved plan.
  DayFlowPlanDraft toDraft() {
    return DayFlowPlanDraft(
      title: title,
      periodLabel: periodLabel,
      budgetType: budgetType,
      totalBudget: totalBudget,
      categories:
          categories
              .map(
                (c) => DayFlowCategoryDraft(
                  name: c.name,
                  allocated: c.allocated,
                ),
              )
              .toList(),
      payments:
          upcoming
              .map(
                (u) => DayFlowPaymentDraft(
                  title: u.title,
                  amount: u.amount,
                  dueLabel: u.dueLabel,
                  recipientHint: u.recipientHint,
                  autoSend: u.autoSend,
                ),
              )
              .toList(),
      goals:
          goals
              .map(
                (g) => DayFlowGoalDraft(
                  title: g.title,
                  targetAmount: g.targetAmount,
                  savedAmount: g.savedAmount,
                  targetDateLabel: g.targetDateLabel,
                ),
              )
              .toList(),
      leftover: leftover,
      sweepToDayEarn: sweepToDayEarn,
      readyToApprove: false,
    );
  }

  /// Demo plan from a natural-language prompt until the AI backend ships.
  static DayFlowPlan demoFromPrompt(String prompt) {
    final lower = prompt.toLowerCase();
    final currency =
        lower.contains('usd') || lower.contains('\$') ? 'USD' : 'NGN';
    const budget = 500000.0;
    return DayFlowPlan(
      id: 'plan-${DateTime.now().millisecondsSinceEpoch}',
      title: "This Month's Plan",
      periodLabel: 'This Month',
      totalBudget: budget,
      spent: 142800,
      currency: currency,
      summaryLine: "You're ₦8,450 under budget this week 👍",
      leftover: 87000,
      sweepToDayEarn: lower.contains('dayearn') || lower.contains('save'),
      categories: const [
        DayFlowCategory(name: 'Rent', allocated: 150000, spent: 0),
        DayFlowCategory(name: 'Food & Dining', allocated: 60000, spent: 12000),
        DayFlowCategory(name: 'Transport', allocated: 25000, spent: 8200),
        DayFlowCategory(name: 'Airtime & Data', allocated: 8000, spent: 3500),
      ],
      upcoming: const [
        DayFlowUpcomingPayment(
          title: 'Rent to Landlord',
          amount: 150000,
          currency: 'NGN',
          dueLabel: 'Due 25th',
        ),
        DayFlowUpcomingPayment(
          title: 'Send to @freddy001',
          amount: 20000,
          currency: 'NGN',
          dueLabel: 'This Saturday',
        ),
      ],
    );
  }
}

class DayFlowCategoryDraft {
  final String name;
  final double allocated;
  final double? sourceAmount;

  const DayFlowCategoryDraft({
    required this.name,
    required this.allocated,
    this.sourceAmount,
  });

  factory DayFlowCategoryDraft.fromJson(Map<String, dynamic> json) {
    return DayFlowCategoryDraft(
      name: json['name']?.toString() ?? '',
      allocated: (json['allocated'] as num?)?.toDouble() ?? 0,
      sourceAmount: (json['sourceAmount'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'allocated': allocated,
    if (sourceAmount != null) 'sourceAmount': sourceAmount,
  };
}

class DayFlowPaymentDraft {
  final String title;
  final double amount;
  final double? sourceAmount;
  final String? dueLabel;
  final String? nextRunAt;
  final String? toCurrency;
  final String? recipientHint;
  final bool autoSend;

  const DayFlowPaymentDraft({
    required this.title,
    required this.amount,
    this.sourceAmount,
    this.dueLabel,
    this.nextRunAt,
    this.toCurrency,
    this.recipientHint,
    this.autoSend = false,
  });

  factory DayFlowPaymentDraft.fromJson(Map<String, dynamic> json) {
    return DayFlowPaymentDraft(
      title: json['title']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      sourceAmount: (json['sourceAmount'] as num?)?.toDouble(),
      dueLabel: json['dueLabel']?.toString(),
      nextRunAt: json['nextRunAt']?.toString(),
      toCurrency: json['toCurrency']?.toString(),
      recipientHint: json['recipientHint']?.toString(),
      autoSend: json['autoSend'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'amount': amount,
    if (sourceAmount != null) 'sourceAmount': sourceAmount,
    if (dueLabel != null) 'dueLabel': dueLabel,
    if (nextRunAt != null) 'nextRunAt': nextRunAt,
    if (toCurrency != null) 'toCurrency': toCurrency,
    if (recipientHint != null) 'recipientHint': recipientHint,
    'autoSend': autoSend,
  };

  DayFlowPaymentDraft copyWith({
    String? recipientHint,
    bool? autoSend,
    double? sourceAmount,
    String? nextRunAt,
    String? toCurrency,
  }) {
    return DayFlowPaymentDraft(
      title: title,
      amount: amount,
      sourceAmount: sourceAmount ?? this.sourceAmount,
      dueLabel: dueLabel,
      nextRunAt: nextRunAt ?? this.nextRunAt,
      toCurrency: toCurrency ?? this.toCurrency,
      recipientHint: recipientHint ?? this.recipientHint,
      autoSend: autoSend ?? this.autoSend,
    );
  }
}

class DayFlowPlanDraft {
  final String title;
  final String periodLabel;
  final String budgetType;
  final double totalBudget;
  final String currency;
  final String? inputCurrency;
  final double? fxNgnPerUsd;
  final List<DayFlowCategoryDraft> categories;
  final List<DayFlowPaymentDraft> payments;
  final List<DayFlowGoalDraft> goals;
  final double leftover;
  final bool sweepToDayEarn;
  final bool readyToApprove;

  const DayFlowPlanDraft({
    required this.title,
    required this.periodLabel,
    this.budgetType = 'monthly',
    required this.totalBudget,
    this.currency = kDayFlowWalletCurrency,
    this.inputCurrency,
    this.fxNgnPerUsd,
    required this.categories,
    required this.payments,
    this.goals = const [],
    this.leftover = 0,
    this.sweepToDayEarn = false,
    this.readyToApprove = false,
  });

  factory DayFlowPlanDraft.fromJson(Map<String, dynamic> json) {
    final categories = <DayFlowCategoryDraft>[];
    for (final c in json['categories'] as List<dynamic>? ?? []) {
      if (c is Map) {
        categories.add(
          DayFlowCategoryDraft.fromJson(Map<String, dynamic>.from(c)),
        );
      }
    }
    final payments = <DayFlowPaymentDraft>[];
    for (final p in json['payments'] as List<dynamic>? ?? []) {
      if (p is Map) {
        payments.add(
          DayFlowPaymentDraft.fromJson(Map<String, dynamic>.from(p)),
        );
      }
    }
    final goals = <DayFlowGoalDraft>[];
    for (final g in json['goals'] as List<dynamic>? ?? []) {
      if (g is Map) {
        goals.add(DayFlowGoalDraft.fromJson(Map<String, dynamic>.from(g)));
      }
    }
    return DayFlowPlanDraft(
      title: json['title']?.toString() ?? "This Month's Plan",
      periodLabel: json['periodLabel']?.toString() ?? 'This Month',
      budgetType: json['budgetType']?.toString() ?? 'monthly',
      totalBudget: (json['totalBudget'] as num?)?.toDouble() ?? 0,
      currency: json['currency']?.toString() ?? kDayFlowWalletCurrency,
      inputCurrency: json['inputCurrency']?.toString(),
      fxNgnPerUsd: (json['fxNgnPerUsd'] as num?)?.toDouble(),
      categories: categories,
      payments: payments,
      goals: goals,
      leftover: (json['leftover'] as num?)?.toDouble() ?? 0,
      sweepToDayEarn: json['sweepToDayEarn'] == true,
      readyToApprove: json['readyToApprove'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'periodLabel': periodLabel,
    'budgetType': budgetType,
    'totalBudget': totalBudget,
    'currency': currency,
    if (inputCurrency != null) 'inputCurrency': inputCurrency,
    if (fxNgnPerUsd != null) 'fxNgnPerUsd': fxNgnPerUsd,
    'categories': categories.map((c) => c.toJson()).toList(),
    'payments': payments.map((p) => p.toJson()).toList(),
    'leftover': leftover,
    'sweepToDayEarn': sweepToDayEarn,
    'readyToApprove': readyToApprove,
  };

  DayFlowPlanDraft copyWith({
    List<DayFlowPaymentDraft>? payments,
    bool? sweepToDayEarn,
    bool? readyToApprove,
  }) {
    return DayFlowPlanDraft(
      title: title,
      periodLabel: periodLabel,
      budgetType: budgetType,
      totalBudget: totalBudget,
      categories: categories,
      payments: payments ?? this.payments,
      goals: goals,
      leftover: leftover,
      sweepToDayEarn: sweepToDayEarn ?? this.sweepToDayEarn,
      readyToApprove: readyToApprove ?? this.readyToApprove,
    );
  }
}

class DayFlowGoalDraft {
  final String title;
  final double targetAmount;
  final double savedAmount;
  final String? targetDateLabel;

  const DayFlowGoalDraft({
    required this.title,
    required this.targetAmount,
    this.savedAmount = 0,
    this.targetDateLabel,
  });

  factory DayFlowGoalDraft.fromJson(Map<String, dynamic> json) {
    return DayFlowGoalDraft(
      title: json['title']?.toString() ?? '',
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0,
      savedAmount: (json['savedAmount'] as num?)?.toDouble() ?? 0,
      targetDateLabel: json['targetDateLabel']?.toString(),
    );
  }
}

/// A funded budget envelope (money held from global wallet for a purpose).
class DayFlowEnvelope {
  final String id;
  final String title;
  final String flowType;
  final String status;
  final double totalAmount;
  final double heldAmount;
  final double spentAmount;
  final double remainingAmount;
  final String currency;
  final List<DayFlowCategory> categories;
  final List<DayFlowEnvelopeSchedule> schedules;
  final String? periodLabel;
  final String? budgetType;
  final String? nextRunAt;
  final String? summaryLine;

  const DayFlowEnvelope({
    required this.id,
    required this.title,
    required this.flowType,
    required this.status,
    required this.totalAmount,
    required this.heldAmount,
    required this.spentAmount,
    required this.remainingAmount,
    required this.currency,
    this.categories = const [],
    this.schedules = const [],
    this.periodLabel,
    this.budgetType,
    this.nextRunAt,
    this.summaryLine,
  });

  bool get isActive => status == 'active';

  factory DayFlowEnvelope.fromJson(Map<String, dynamic> json) {
    final categories = <DayFlowCategory>[];
    for (final c in json['categories'] as List<dynamic>? ?? []) {
      if (c is Map) {
        categories.add(DayFlowCategory.fromJson(Map<String, dynamic>.from(c)));
      }
    }
    final schedules = <DayFlowEnvelopeSchedule>[];
    for (final s in json['schedules'] as List<dynamic>? ?? []) {
      if (s is Map) {
        schedules.add(
          DayFlowEnvelopeSchedule.fromJson(Map<String, dynamic>.from(s)),
        );
      }
    }
    return DayFlowEnvelope(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Flow',
      flowType: json['flowType']?.toString() ?? 'mixed',
      status: json['status']?.toString() ?? 'active',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      heldAmount: (json['heldAmount'] as num?)?.toDouble() ?? 0,
      spentAmount: (json['spentAmount'] as num?)?.toDouble() ?? 0,
      remainingAmount: (json['remainingAmount'] as num?)?.toDouble() ?? 0,
      currency: json['currency']?.toString() ?? kDayFlowWalletCurrency,
      categories: categories,
      schedules: schedules,
      periodLabel: json['periodLabel']?.toString(),
      budgetType: json['budgetType']?.toString(),
      nextRunAt: json['nextRunAt']?.toString(),
      summaryLine: json['summaryLine']?.toString(),
    );
  }
}

class DayFlowEnvelopeSchedule {
  final String id;
  final String title;
  final double amount;
  final String? dueLabel;
  final String? recipientHint;
  final String? recipientId;
  final String paymentType;
  final String frequency;
  final bool autoPay;
  final String? budgetId;
  final String? nextRunAt;
  final String? lastRunAt;
  final String? lastStatus;

  const DayFlowEnvelopeSchedule({
    required this.id,
    required this.title,
    required this.amount,
    this.dueLabel,
    this.recipientHint,
    this.recipientId,
    this.paymentType = 'send',
    this.frequency = 'monthly',
    this.autoPay = false,
    this.budgetId,
    this.nextRunAt,
    this.lastRunAt,
    this.lastStatus,
  });

  factory DayFlowEnvelopeSchedule.fromJson(Map<String, dynamic> json) {
    return DayFlowEnvelopeSchedule(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      dueLabel: json['dueLabel']?.toString(),
      recipientHint: json['recipientHint']?.toString(),
      recipientId: json['recipientId']?.toString(),
      paymentType: json['paymentType']?.toString() ?? 'send',
      frequency: json['frequency']?.toString() ?? 'monthly',
      autoPay: json['autoPay'] == true,
      budgetId: json['budgetId']?.toString(),
      nextRunAt: json['nextRunAt']?.toString(),
      lastRunAt: json['lastRunAt']?.toString(),
      lastStatus: json['lastStatus']?.toString(),
    );
  }
}

enum DayBudgetInstanceStatus { upcoming, paid, failed, overdue }

DateTime _parseScheduleDueAt(dynamic raw) {
  final parsed = DateTime.tryParse(raw?.toString() ?? '');
  if (parsed == null) return DateTime.now();
  return parsed.isUtc ? parsed.toLocal() : parsed;
}

class DayBudgetScheduleInstance {
  final String id;
  final String flowId;
  final String scheduleId;
  final String title;
  final double amount;
  final DateTime dueAt;
  final DayBudgetInstanceStatus status;
  final bool autoPay;
  final String paymentType;
  final String? recipientHint;
  final String? recipientId;
  final bool needsSetup;
  final String? flowTitle;
  final String? dueLabel;

  const DayBudgetScheduleInstance({
    required this.id,
    required this.flowId,
    required this.scheduleId,
    required this.title,
    required this.amount,
    required this.dueAt,
    required this.status,
    this.autoPay = true,
    this.paymentType = 'send',
    this.recipientHint,
    this.recipientId,
    this.needsSetup = false,
    this.flowTitle,
    this.dueLabel,
  });

  factory DayBudgetScheduleInstance.fromJson(Map<String, dynamic> json) {
    DayBudgetInstanceStatus parseStatus(String? raw) {
      switch (raw) {
        case 'paid':
          return DayBudgetInstanceStatus.paid;
        case 'failed':
          return DayBudgetInstanceStatus.failed;
        case 'overdue':
          return DayBudgetInstanceStatus.overdue;
        default:
          return DayBudgetInstanceStatus.upcoming;
      }
    }

    return DayBudgetScheduleInstance(
      id: json['id']?.toString() ?? '',
      flowId: json['flowId']?.toString() ?? '',
      scheduleId: json['scheduleId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      dueAt: _parseScheduleDueAt(json['dueAt']),
      status: parseStatus(json['status']?.toString()),
      autoPay: json['autoPay'] != false,
      paymentType: json['paymentType']?.toString() ?? 'send',
      recipientHint: json['recipientHint']?.toString(),
      recipientId: json['recipientId']?.toString(),
      needsSetup: json['needsSetup'] == true,
      flowTitle: json['flowTitle']?.toString(),
      dueLabel: json['dueLabel']?.toString(),
    );
  }
}

class DayBudgetScheduleInstances {
  final List<DayBudgetScheduleInstance> upcoming;
  final List<DayBudgetScheduleInstance> past;
  final double committedThisPeriod;
  final String periodLabel;

  const DayBudgetScheduleInstances({
    this.upcoming = const [],
    this.past = const [],
    this.committedThisPeriod = 0,
    this.periodLabel = '',
  });

  factory DayBudgetScheduleInstances.fromApi(
    Map<String, dynamic>? raw, {
    double? committed,
    String? periodLabel,
  }) {
    if (raw == null) {
      return DayBudgetScheduleInstances(
        committedThisPeriod: committed ?? 0,
        periodLabel: periodLabel ?? '',
      );
    }
    final up = <DayBudgetScheduleInstance>[];
    final past = <DayBudgetScheduleInstance>[];
    for (final item in raw['upcoming'] as List<dynamic>? ?? []) {
      if (item is Map) {
        up.add(DayBudgetScheduleInstance.fromJson(Map<String, dynamic>.from(item)));
      }
    }
    for (final item in raw['past'] as List<dynamic>? ?? []) {
      if (item is Map) {
        past.add(DayBudgetScheduleInstance.fromJson(Map<String, dynamic>.from(item)));
      }
    }
    return DayBudgetScheduleInstances(
      upcoming: up,
      past: past,
      committedThisPeriod: committed ?? 0,
      periodLabel: periodLabel ?? '',
    );
  }
}

class DayFlowDashboardSnapshot {
  final double walletBalance;
  final String walletCurrency;
  final double safeToSpend;
  final double freeToSpend;
  final double committedThisPeriod;
  final String budgetPeriodLabel;
  final DayBudgetScheduleInstances scheduleInstances;
  final int healthScore;
  final String forecastMessage;
  final List<String> insights;
  final DayFlowPlan? plan;
  final List<DayFlowEnvelope> flows;
  final double totalFlowHeld;
  final bool hasActivePlan;

  const DayFlowDashboardSnapshot({
    required this.walletBalance,
    this.walletCurrency = kDayFlowWalletCurrency,
    required this.safeToSpend,
    this.freeToSpend = 0,
    this.committedThisPeriod = 0,
    this.budgetPeriodLabel = '',
    this.scheduleInstances = const DayBudgetScheduleInstances(),
    required this.healthScore,
    required this.forecastMessage,
    this.insights = const [],
    this.plan,
    this.flows = const [],
    this.totalFlowHeld = 0,
    this.hasActivePlan = false,
  });

  bool get hasFlows => flows.any((f) => f.isActive);

  factory DayFlowDashboardSnapshot.fromApi(Map<String, dynamic> data) {
    DayFlowPlan? plan;
    final rawPlan = data['plan'];
    if (rawPlan is Map<String, dynamic>) {
      plan = DayFlowPlan.fromJson({
        'id': rawPlan['id'],
        'title': rawPlan['title'],
        'periodLabel': rawPlan['periodLabel'],
        'budgetType': rawPlan['budgetType'],
        'totalBudget': rawPlan['totalBudget'],
        'spent': rawPlan['spent'],
        'currency': rawPlan['currency'] ?? kDayFlowWalletCurrency,
        'summaryLine': rawPlan['summaryLine'],
        'categories': rawPlan['categories'],
        'upcoming': rawPlan['upcoming'],
        'goals': rawPlan['goals'],
        'lockedCategories': rawPlan['lockedCategories'],
        'leftover': rawPlan['leftover'],
        'sweepToDayEarn': rawPlan['sweepToDayEarn'],
      });
    }
    final forecast = data['forecast'];
    final flows = <DayFlowEnvelope>[];
    for (final f in data['flows'] as List<dynamic>? ?? []) {
      if (f is Map) {
        flows.add(DayFlowEnvelope.fromJson(Map<String, dynamic>.from(f)));
      }
    }
    return DayFlowDashboardSnapshot(
      walletBalance:
          (data['walletBalance'] as num?)?.toDouble() ??
          (data['ngnBalance'] as num?)?.toDouble() ??
          0,
      walletCurrency:
          data['walletCurrency']?.toString() ?? kDayFlowWalletCurrency,
      safeToSpend: (data['safeToSpend'] as num?)?.toDouble() ?? 0,
      freeToSpend:
          (data['freeToSpend'] as num?)?.toDouble() ??
          (data['safeToSpend'] as num?)?.toDouble() ??
          0,
      committedThisPeriod: (data['committedThisPeriod'] as num?)?.toDouble() ?? 0,
      budgetPeriodLabel: data['budgetPeriodLabel']?.toString() ?? '',
      scheduleInstances: DayBudgetScheduleInstances.fromApi(
        data['scheduleInstances'] is Map
            ? Map<String, dynamic>.from(data['scheduleInstances'] as Map)
            : null,
        committed: (data['committedThisPeriod'] as num?)?.toDouble(),
        periodLabel: data['budgetPeriodLabel']?.toString(),
      ),
      healthScore: (data['healthScore'] as num?)?.toInt() ?? 62,
      forecastMessage:
          forecast is Map ? forecast['message']?.toString() ?? '' : '',
      insights:
          (data['insights'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList(),
      plan: plan,
      flows: flows,
      totalFlowHeld: (data['totalFlowHeld'] as num?)?.toDouble() ?? 0,
      hasActivePlan: data['hasActivePlan'] == true || plan != null || flows.isNotEmpty,
    );
  }
}

class DayFlowIncomeEvent {
  final String transactionId;
  final double amount;
  final String currency;
  final String? channel;
  final String? reason;
  final DateTime? timestamp;
  final String label;

  const DayFlowIncomeEvent({
    required this.transactionId,
    required this.amount,
    required this.currency,
    this.channel,
    this.reason,
    this.timestamp,
    required this.label,
  });

  bool get isNgn => currency.toUpperCase() == 'NGN';

  factory DayFlowIncomeEvent.fromJson(Map<String, dynamic> json) {
    DateTime? ts;
    final rawTs = json['timestamp'];
    if (rawTs != null) {
      ts = DateTime.tryParse(rawTs.toString());
    }
    return DayFlowIncomeEvent(
      transactionId:
          json['transactionId']?.toString() ??
          json['transaction_id']?.toString() ??
          '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency']?.toString() ?? kDayFlowWalletCurrency,
      channel: json['channel']?.toString(),
      reason: json['reason']?.toString(),
      timestamp: ts,
      label: json['label']?.toString() ?? 'Wallet top-up',
    );
  }
}

extension DayFlowAllocationDraft on DayFlowPlanDraft {
  static DayFlowPlanDraft fromIncomeAllocation({
    required DayFlowIncomeEvent income,
    required Map<String, double> allocations,
    DayFlowPlan? existingPlan,
  }) {
    final categories =
        allocations.entries
            .where((e) => e.value > 0)
            .map((e) => DayFlowCategoryDraft(name: e.key, allocated: e.value))
            .toList();
    final allocatedSum = categories.fold<double>(0, (s, c) => s + c.allocated);
    final total = income.isNgn ? income.amount : allocatedSum;
    return DayFlowPlanDraft(
      title: existingPlan?.title ?? "This Month's Plan",
      periodLabel: existingPlan?.periodLabel ?? 'This Month',
      budgetType: existingPlan?.budgetType ?? 'monthly',
      totalBudget: total,
      categories: categories,
      payments: const [],
      leftover: (total - allocatedSum).clamp(0, double.infinity),
      sweepToDayEarn: existingPlan?.sweepToDayEarn ?? false,
      readyToApprove: true,
    );
  }
}
