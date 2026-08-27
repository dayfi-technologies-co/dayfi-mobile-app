class BudgetCategory {
  final String name;
  final double limit;

  const BudgetCategory({required this.name, required this.limit});

  factory BudgetCategory.fromJson(Map<String, dynamic> json) {
    return BudgetCategory(
      name: json['name']?.toString() ?? '',
      limit: _num(json['limit']),
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'limit': limit};
}

class Budget {
  final String id;
  final String name;
  final String type;
  final double amount;
  final String currency;
  final String frequency;
  final String status;
  final List<BudgetCategory> categories;
  final String? recipientId;
  final Map<String, dynamic> metadata;
  final double spentAmount;
  final double remainingAmount;
  final int progressPercent;
  final DateTime? nextRunAt;

  const Budget({
    required this.id,
    required this.name,
    required this.type,
    required this.amount,
    required this.currency,
    required this.frequency,
    required this.status,
    required this.categories,
    this.recipientId,
    this.metadata = const {},
    required this.spentAmount,
    required this.remainingAmount,
    required this.progressPercent,
    this.nextRunAt,
  });

  bool get isActive => status == 'active';
  bool get isPaused => status == 'paused';

  /// Linked autopay created via DayFlow (`metadata.dayflowFlowId` on the server).
  String? get dayflowFlowId => _metaVal('dayflowFlowId');

  String? get dayflowScheduleId => _metaVal('scheduleId');

  String? get dayflowPaymentType => _metaVal('paymentType');

  bool get isManagedByDayFlow =>
      dayflowFlowId != null && dayflowFlowId!.isNotEmpty;

  factory Budget.fromJson(Map<String, dynamic> json) {
    final cats = <BudgetCategory>[];
    final raw = json['categories'];
    if (raw is List) {
      for (final c in raw) {
        if (c is Map<String, dynamic>) {
          cats.add(BudgetCategory.fromJson(c));
        }
      }
    }
    DateTime? next;
    final n = json['nextRunAt']?.toString();
    if (n != null && n.isNotEmpty) next = DateTime.tryParse(n);

    final metaRaw = json['metadata'];
    final metadata =
        metaRaw is Map
            ? Map<String, dynamic>.from(metaRaw)
            : <String, dynamic>{};

    return Budget(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? 'category_spend',
      amount: _num(json['amount']),
      currency: json['currency']?.toString() ?? 'USD',
      frequency: json['frequency']?.toString() ?? 'monthly',
      status: json['status']?.toString() ?? 'active',
      categories: cats,
      recipientId: json['recipientId']?.toString(),
      metadata: metadata,
      spentAmount: _num(json['spentAmount']),
      remainingAmount: _num(json['remainingAmount']),
      progressPercent: json['progressPercent'] as int? ?? 0,
      nextRunAt: next,
    );
  }

  String get typeLabel {
    switch (type) {
      case 'recurring_send':
        return frequency == 'once' ? 'One-time send' : 'Recurring send';
      case 'bill_reminder':
        return frequency == 'once' ? 'Bill reminder' : 'Bills';
      case 'invest_allocation':
        return 'DayEarn';
      case 'category_spend':
        return 'Spending cap';
      default:
        return 'Spending cap';
    }
  }

  String get amountLabel {
    switch (type) {
      case 'category_spend':
        return 'Monthly limit';
      case 'invest_allocation':
        return 'Per deposit';
      default:
        return frequency == 'once' ? 'Reminder amount' : 'Amount';
    }
  }

  String get frequencyLabel {
    if (frequency == 'once') return 'One-time';
    return switch (frequency) {
      'weekly' => 'Weekly',
      'biweekly' => 'Every two weeks',
      'monthly' => 'Monthly',
      _ => frequency,
    };
  }

  String get statusLabel =>
      isPaused ? 'Paused' : isActive ? 'Active' : status;

  bool get isReminder =>
      frequency == 'once' || metadata['reminder'] == true;

  String? _metaVal(String key) {
    final raw = metadata[key];
    if (raw == null) return null;
    final s = raw.toString().trim();
    return s.isEmpty ? null : s;
  }

  /// Key-value rows for the detail screen (label → value).
  List<MapEntry<String, String>> get detailRows {
    final rows = <MapEntry<String, String>>[];

    rows.add(MapEntry('Status', statusLabel));
    rows.add(MapEntry('Schedule', frequencyLabel));

    switch (type) {
      case 'bill_reminder':
        final billType = _metaVal('billCategoryName');
        final provider = _metaVal('billerName');
        final account = _metaVal('customerReference');
        if (billType != null) rows.add(MapEntry('Bill type', billType));
        if (provider != null) rows.add(MapEntry('Provider', provider));
        if (account != null) rows.add(MapEntry('Phone / account', account));
        if (isReminder) {
          rows.add(MapEntry(
            'Note',
            'Reminder only — pay manually from Pay bills.',
          ));
        } else {
          rows.add(MapEntry(
            'Note',
            'Scheduled bill — payment runs when automation is live.',
          ));
        }
      case 'recurring_send':
        final recipient = _metaVal('recipientName');
        if (recipient != null) {
          rows.add(MapEntry('Recipient', recipient));
        } else if (recipientId != null && recipientId!.isNotEmpty) {
          rows.add(MapEntry('Recipient ID', recipientId!));
        }
        if (isReminder) {
          rows.add(MapEntry(
            'Note',
            'Reminder only — complete the send yourself.',
          ));
        }
      case 'category_spend':
        final category =
            categories.isNotEmpty
                ? categories.first.name
                : _metaVal('categoryName');
        if (category != null) rows.add(MapEntry('Category', category));
        rows.add(MapEntry(
          'Remaining',
          '\$${remainingAmount.toStringAsFixed(2)}',
        ));
        rows.add(MapEntry(
          'Note',
          'Tracking only — spending is not blocked automatically.',
        ));
      case 'invest_allocation':
        final pot = _metaVal('potName');
        if (pot != null) rows.add(MapEntry('DayEarn pot', pot));
        rows.add(MapEntry(
          'Note',
          'Scheduled deposit — runs when automation is live.',
        ));
    }

    final endsAt = _metaVal('endsAt');
    if (endsAt != null) rows.add(MapEntry('Ends on', endsAt));

    return rows;
  }

  String? get nextRunLabel {
    if (nextRunAt == null || !isActive) return null;
    final d = nextRunAt!.toLocal();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final date = '${d.day} ${months[d.month - 1]}';
    if (frequency == 'once') return 'Reminder: $date';
    return 'Next: $date';
  }
}

double _num(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}
