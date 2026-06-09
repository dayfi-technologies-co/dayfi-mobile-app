/// Deterministic Send / Swap / Pay / Add-money wizard driven by POST /dayx/flow/turn.
class DayxFlowId {
  static const send = 'send';
  static const swap = 'swap';
  static const pay = 'pay';
  static const addMoney = 'add_money';
}

class DayxFlowWalletBalance {
  final String currency;
  final double balance;

  const DayxFlowWalletBalance({required this.currency, required this.balance});

  Map<String, dynamic> toJson() => {
        'currency': currency,
        'balance': balance,
      };
}

class DayxFlowSession {
  final String flow;
  final String step;
  final Map<String, dynamic> data;

  const DayxFlowSession({
    required this.flow,
    required this.step,
    this.data = const {},
  });

  factory DayxFlowSession.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    return DayxFlowSession(
      flow: json['flow']?.toString() ?? DayxFlowId.send,
      step: json['step']?.toString() ?? 'idle',
      data: raw is Map<String, dynamic>
          ? Map<String, dynamic>.from(raw)
          : raw is Map
              ? Map<String, dynamic>.from(raw)
              : const {},
    );
  }

  Map<String, dynamic> toJson() => {
        'flow': flow,
        'step': step,
        'data': data,
      };
}

class DayxFlowOption {
  final String id;
  final String label;
  final String? subtitle;

  const DayxFlowOption({
    required this.id,
    required this.label,
    this.subtitle,
  });

  factory DayxFlowOption.fromJson(Map<String, dynamic> json) {
    return DayxFlowOption(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      subtitle: json['subtitle']?.toString(),
    );
  }
}

class DayxFlowInput {
  final String type;
  final String field;
  final String label;
  final String? placeholder;
  final String? keyboard;

  const DayxFlowInput({
    required this.type,
    required this.field,
    required this.label,
    this.placeholder,
    this.keyboard,
  });

  factory DayxFlowInput.fromJson(Map<String, dynamic> json) {
    return DayxFlowInput(
      type: json['type']?.toString() ?? 'text',
      field: json['field']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      placeholder: json['placeholder']?.toString(),
      keyboard: json['keyboard']?.toString(),
    );
  }

  bool get isAmount => type == 'amount';
  bool get isMultiline => type == 'multiline';
  bool get isPin => type == 'pin';
}

class DayxFlowReviewLine {
  final String label;
  final String value;

  const DayxFlowReviewLine({required this.label, required this.value});

  factory DayxFlowReviewLine.fromJson(Map<String, dynamic> json) {
    return DayxFlowReviewLine(
      label: json['label']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
    );
  }
}

class DayxFlowDepositData {
  final String currency;
  final List<String> tabs;
  final String? dayfiId;
  final String? coinLabel;

  const DayxFlowDepositData({
    required this.currency,
    required this.tabs,
    this.dayfiId,
    this.coinLabel,
  });

  factory DayxFlowDepositData.fromJson(Map<String, dynamic> json) {
    final tabsRaw = json['tabs'];
    return DayxFlowDepositData(
      currency: json['currency']?.toString() ?? 'USD',
      tabs: tabsRaw is List
          ? tabsRaw.map((e) => e.toString()).toList()
          : const ['username', 'bank'],
      dayfiId: json['dayfiId']?.toString(),
      coinLabel: json['cryptoDetails'] is Map
          ? (json['cryptoDetails'] as Map)['coinLabel']?.toString()
          : null,
    );
  }
}

class DayxFlowUi {
  final String step;
  final String? title;
  final List<DayxFlowOption> options;
  final DayxFlowInput? input;
  final List<DayxFlowReviewLine> review;
  final bool showBack;
  final String? panel;
  final DayxFlowDepositData? deposit;
  final String? rateLine;
  final String? hint;

  const DayxFlowUi({
    required this.step,
    this.title,
    this.options = const [],
    this.input,
    this.review = const [],
    this.showBack = false,
    this.panel,
    this.deposit,
    this.rateLine,
    this.hint,
  });

  factory DayxFlowUi.fromJson(Map<String, dynamic> json) {
    final opts = json['options'];
    final rev = json['review'];
    return DayxFlowUi(
      step: json['step']?.toString() ?? '',
      title: json['title']?.toString(),
      options: opts is List
          ? opts
              .whereType<Map>()
              .map((e) => DayxFlowOption.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      input: json['input'] is Map<String, dynamic>
          ? DayxFlowInput.fromJson(json['input'] as Map<String, dynamic>)
          : json['input'] is Map
              ? DayxFlowInput.fromJson(
                  Map<String, dynamic>.from(json['input'] as Map),
                )
              : null,
      review: rev is List
          ? rev
              .whereType<Map>()
              .map(
                (e) => DayxFlowReviewLine.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList()
          : const [],
      showBack: json['showBack'] == true,
      panel: json['panel']?.toString(),
      deposit: json['deposit'] is Map<String, dynamic>
          ? DayxFlowDepositData.fromJson(json['deposit'] as Map<String, dynamic>)
          : json['deposit'] is Map
              ? DayxFlowDepositData.fromJson(
                  Map<String, dynamic>.from(json['deposit'] as Map),
                )
              : null,
      rateLine: json['rateLine']?.toString(),
      hint: json['hint']?.toString(),
    );
  }
}

class DayxFlowTurnResult {
  final String reply;
  final DayxFlowSession? session;
  final DayxFlowUi? ui;
  final bool awaitingPin;
  final Map<String, dynamic>? execute;
  final bool completed;
  final String? navigateTarget;

  const DayxFlowTurnResult({
    required this.reply,
    this.session,
    this.ui,
    this.awaitingPin = false,
    this.execute,
    this.completed = false,
    this.navigateTarget,
  });

  factory DayxFlowTurnResult.fromJson(Map<String, dynamic> json) {
    return DayxFlowTurnResult(
      reply: json['reply']?.toString() ?? '',
      session: json['session'] is Map<String, dynamic>
          ? DayxFlowSession.fromJson(json['session'] as Map<String, dynamic>)
          : json['session'] is Map
              ? DayxFlowSession.fromJson(
                  Map<String, dynamic>.from(json['session'] as Map),
                )
              : null,
      ui: json['ui'] is Map<String, dynamic>
          ? DayxFlowUi.fromJson(json['ui'] as Map<String, dynamic>)
          : json['ui'] is Map
              ? DayxFlowUi.fromJson(Map<String, dynamic>.from(json['ui'] as Map))
              : null,
      awaitingPin: json['awaitingPin'] == true,
      execute: json['execute'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['execute'] as Map<String, dynamic>)
          : json['execute'] is Map
              ? Map<String, dynamic>.from(json['execute'] as Map)
              : null,
      completed: json['completed'] == true,
      navigateTarget: json['navigateTarget']?.toString(),
    );
  }
}
