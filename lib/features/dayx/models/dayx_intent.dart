// DayX intent contract — shared shape for rules and LLM responses.

import 'package:dayfi/features/dayx/models/dayx_flow.dart';
import 'package:dayfi/features/dayx/widgets/dayx_inline_success.dart';

class DayxIntentActions {
  DayxIntentActions._();

  static const showBalance = 'show_balance';
  static const navigate = 'navigate';
  static const openSupport = 'open_support';
  static const proposeTransfer = 'propose_transfer';
  static const spendingInsight = 'spending_insight';
  static const clarify = 'clarify';
  static const smallTalk = 'small_talk';
  static const offTopic = 'off_topic';
}

class DayxNavigateTargets {
  DayxNavigateTargets._();

  static const home = 'home';
  static const transactions = 'transactions';
  static const recipients = 'recipients';
  static const profile = 'profile';
  static const invest = 'invest';
  static const earn = 'earn';
  static const dayflow = 'dayflow';
  static const pay = 'pay';
  static const send = 'send';
  static const budgets = 'budgets';
  static const addMoney = 'add_money';
  static const swap = 'swap';
  static const support = 'support';
  static const withdraw = 'withdraw';
}

class DayxUiTypes {
  DayxUiTypes._();

  static const textOnly = 'text_only';
  static const balanceCard = 'balance_card';
  static const transferConfirm = 'transfer_confirm';
  static const spendingInsight = 'spending_insight';
}

class DayxMeta {
  final String provider;
  final String mode;

  const DayxMeta({
    this.provider = 'rules',
    this.mode = 'local',
  });

  bool get isFullMode => mode == 'full';
}

class DayxIntent {
  final String action;
  final double confidence;
  final Map<String, dynamic> params;
  final List<String> missing;

  const DayxIntent({
    required this.action,
    required this.confidence,
    this.params = const {},
    this.missing = const [],
  });
}

class DayxUi {
  final String type;
  final String? title;

  const DayxUi({
    required this.type,
    this.title,
  });
}

class DayxTransferCandidate {
  final String beneficiaryId;
  final String name;
  final String? accountMask;
  final String? country;

  const DayxTransferCandidate({
    required this.beneficiaryId,
    required this.name,
    this.accountMask,
    this.country,
  });

  factory DayxTransferCandidate.fromJson(Map<String, dynamic> json) {
    return DayxTransferCandidate(
      beneficiaryId:
          json['beneficiaryId']?.toString() ??
          json['beneficiary_id']?.toString() ??
          '',
      name: json['name']?.toString() ?? '',
      accountMask:
          json['accountMask']?.toString() ?? json['account_mask']?.toString(),
      country: json['country']?.toString(),
    );
  }
}

class DayxTransferProposal {
  final String status;
  final double? amount;
  final String? currency;
  final String? recipientName;
  final String? beneficiaryId;
  final String? accountMask;
  final List<DayxTransferCandidate> candidates;

  const DayxTransferProposal({
    required this.status,
    this.amount,
    this.currency,
    this.recipientName,
    this.beneficiaryId,
    this.accountMask,
    this.candidates = const [],
  });

  bool get needsConfirmation => status == 'needs_confirmation';
  bool get isAmbiguous => status == 'ambiguous';

  factory DayxTransferProposal.fromJson(Map<String, dynamic> json) {
    final candidates = <DayxTransferCandidate>[];
    for (final c in json['candidates'] as List<dynamic>? ?? []) {
      if (c is Map) {
        candidates.add(
          DayxTransferCandidate.fromJson(Map<String, dynamic>.from(c)),
        );
      }
    }
    return DayxTransferProposal(
      status: json['status']?.toString() ?? 'info_only',
      amount: (json['amount'] as num?)?.toDouble(),
      currency: json['currency']?.toString(),
      recipientName:
          json['recipientName']?.toString() ??
          json['recipient_name']?.toString(),
      beneficiaryId:
          json['beneficiaryId']?.toString() ??
          json['beneficiary_id']?.toString(),
      accountMask:
          json['accountMask']?.toString() ?? json['account_mask']?.toString(),
      candidates: candidates,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    if (amount != null) 'amount': amount,
    if (currency != null) 'currency': currency,
    if (recipientName != null) 'recipientName': recipientName,
    if (beneficiaryId != null) 'beneficiaryId': beneficiaryId,
    if (accountMask != null) 'accountMask': accountMask,
    'candidates': candidates
        .map(
          (c) => {
            'beneficiaryId': c.beneficiaryId,
            'name': c.name,
            if (c.accountMask != null) 'accountMask': c.accountMask,
            if (c.country != null) 'country': c.country,
          },
        )
        .toList(),
  };
}

class DayxSpendingInsight {
  final String title;
  final String message;
  final String? metric;
  final String tone;

  const DayxSpendingInsight({
    required this.title,
    required this.message,
    this.metric,
    this.tone = 'neutral',
  });

  factory DayxSpendingInsight.fromJson(Map<String, dynamic> json) {
    return DayxSpendingInsight(
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      metric: json['metric']?.toString(),
      tone: json['tone']?.toString() ?? 'neutral',
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'message': message,
    if (metric != null) 'metric': metric,
    'tone': tone,
  };
}

class DayxResponse {
  final String reply;
  final String? voiceReply;
  final String? startFlow;
  final Map<String, dynamic>? flowSlots;
  final List<String>? suggestions;
  final List<DayxSpendingInsight>? spendingInsights;
  final DayxTransferProposal? transferProposal;
  final DayxIntent? intent;
  final DayxUi? ui;
  final DayxMeta meta;

  const DayxResponse({
    required this.reply,
    this.voiceReply,
    this.startFlow,
    this.flowSlots,
    this.suggestions,
    this.spendingInsights,
    this.transferProposal,
    this.intent,
    this.ui,
    this.meta = const DayxMeta(),
  });

  factory DayxResponse.fromJson(Map<String, dynamic> json) {
    DayxIntent? intent;
    final intentRaw = json['intent'];
    if (intentRaw is Map<String, dynamic>) {
      intent = DayxIntent(
        action: intentRaw['action']?.toString() ?? DayxIntentActions.clarify,
        confidence: (intentRaw['confidence'] as num?)?.toDouble() ?? 0.8,
        params: intentRaw['params'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(intentRaw['params'] as Map)
            : const {},
      );
    }

    DayxUi? ui;
    final uiRaw = json['ui'];
    if (uiRaw is Map<String, dynamic>) {
      ui = DayxUi(
        type: uiRaw['type']?.toString() ?? DayxUiTypes.textOnly,
        title: uiRaw['title']?.toString(),
      );
    }

    DayxTransferProposal? transferProposal;
    final tpRaw = json['transferProposal'];
    if (tpRaw is Map<String, dynamic>) {
      transferProposal = DayxTransferProposal.fromJson(tpRaw);
    }

    List<String>? suggestions;
    final sugRaw = json['suggestions'];
    if (sugRaw is List) {
      suggestions = sugRaw.map((s) => s.toString()).toList();
    }

    List<DayxSpendingInsight>? spendingInsights;
    final insightsRaw = json['spendingInsights'];
    if (insightsRaw is List) {
      spendingInsights = insightsRaw
          .whereType<Map>()
          .map((m) => DayxSpendingInsight.fromJson(Map<String, dynamic>.from(m)))
          .where((i) => i.title.isNotEmpty && i.message.isNotEmpty)
          .toList();
      if (spendingInsights.isEmpty) spendingInsights = null;
    }

    DayxMeta meta = const DayxMeta();
    final metaRaw = json['meta'];
    if (metaRaw is Map<String, dynamic>) {
      meta = DayxMeta(
        provider: metaRaw['provider']?.toString() ?? 'groq',
        mode: metaRaw['mode']?.toString() ?? 'full',
      );
    }

    Map<String, dynamic>? flowSlots;
    final slotsRaw = json['slots'] ?? json['flowSlots'];
    if (slotsRaw is Map) {
      flowSlots = Map<String, dynamic>.from(slotsRaw);
    }

    return DayxResponse(
      reply: json['reply']?.toString() ?? '',
      voiceReply: json['voiceReply']?.toString(),
      startFlow: json['startFlow']?.toString(),
      flowSlots: flowSlots,
      suggestions: suggestions,
      spendingInsights: spendingInsights,
      transferProposal: transferProposal,
      intent: intent,
      ui: ui,
      meta: meta,
    );
  }
}

class DayxChatMessage {
  final bool isUser;
  final String text;
  final DayxResponse? response;
  /// Active flow step UI (only the latest message should set [flowInteractive]).
  final DayxFlowUi? flowUi;
  final DayxFlowSession? flowSession;
  final bool flowInteractive;
  final DayxInlineSuccess? successReceipt;

  const DayxChatMessage({
    required this.isUser,
    required this.text,
    this.response,
    this.flowUi,
    this.flowSession,
    this.flowInteractive = false,
    this.successReceipt,
  });
}
