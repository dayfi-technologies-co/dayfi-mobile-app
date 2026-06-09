import 'dart:convert';

import 'package:dayfi/app_locator.dart';
import 'package:dayfi/features/dayx/models/dayx_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DayxStoredMessage {
  final String text;
  final bool isUser;
  final String? responseJson;

  const DayxStoredMessage({
    required this.text,
    required this.isUser,
    this.responseJson,
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'isUser': isUser,
    if (responseJson != null) 'responseJson': responseJson,
  };

  factory DayxStoredMessage.fromJson(Map<String, dynamic> json) {
    return DayxStoredMessage(
      text: json['text']?.toString() ?? '',
      isUser: json['isUser'] == true,
      responseJson: json['responseJson']?.toString(),
    );
  }
}

class DayxConversationStore {
  DayxConversationStore._();

  static final DayxConversationStore instance = DayxConversationStore._();
  static const _key = 'dayx_conversation_v1';

  Future<List<DayxStoredMessage>> load() async {
    final raw = locator<SharedPreferences>().getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = json.decode(raw) as List<dynamic>;
      return list
          .whereType<Map>()
          .map((m) => DayxStoredMessage.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<DayxChatMessage> messages) async {
    final stored = messages
        .map(
          (m) => DayxStoredMessage(
            text: m.text,
            isUser: m.isUser,
            responseJson: m.response != null ? _encodeResponse(m.response!) : null,
          ),
        )
        .toList();
    await locator<SharedPreferences>().setString(
      _key,
      json.encode(stored.map((s) => s.toJson()).toList()),
    );
  }

  Future<void> clear() async {
    await locator<SharedPreferences>().remove(_key);
  }

  String _encodeResponse(DayxResponse r) {
    return json.encode({
      'reply': r.reply,
      if (r.voiceReply != null) 'voiceReply': r.voiceReply,
      if (r.suggestions != null) 'suggestions': r.suggestions,
      if (r.spendingInsights != null)
        'spendingInsights':
            r.spendingInsights!.map((i) => i.toJson()).toList(),
      if (r.transferProposal != null)
        'transferProposal': r.transferProposal!.toJson(),
      if (r.intent != null)
        'intent': {
          'action': r.intent!.action,
          'confidence': r.intent!.confidence,
          'params': r.intent!.params,
        },
      if (r.ui != null)
        'ui': {'type': r.ui!.type, 'title': r.ui!.title},
      'meta': {'provider': r.meta.provider, 'mode': r.meta.mode},
    });
  }

  DayxResponse? decodeResponse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      return DayxResponse.fromJson(
        Map<String, dynamic>.from(json.decode(raw) as Map),
      );
    } catch (_) {
      return null;
    }
  }
}
