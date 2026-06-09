import 'dart:convert';

import 'package:dayfi/app_locator.dart';
import 'package:dayfi/features/dayflow/models/dayflow_models.dart';
import 'package:dayfi/features/dayflow/services/dayflow_user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DayFlowStoredMessage {
  final String text;
  final bool isUser;
  final DayFlowPlanDraft? planDraft;
  final bool suggestSwap;

  const DayFlowStoredMessage({
    required this.text,
    required this.isUser,
    this.planDraft,
    this.suggestSwap = false,
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'isUser': isUser,
    if (planDraft != null) 'planDraft': planDraft!.toJson(),
    'suggestSwap': suggestSwap,
  };

  factory DayFlowStoredMessage.fromJson(Map<String, dynamic> json) {
    DayFlowPlanDraft? draft;
    final raw = json['planDraft'];
    if (raw is Map) {
      draft = DayFlowPlanDraft.fromJson(Map<String, dynamic>.from(raw));
    }
    return DayFlowStoredMessage(
      text: json['text']?.toString() ?? '',
      isUser: json['isUser'] == true,
      planDraft: draft,
      suggestSwap: json['suggestSwap'] == true,
    );
  }
}

class DayFlowConversationSnapshot {
  final List<DayFlowStoredMessage> messages;
  final DayFlowPlanDraft? activeDraft;

  const DayFlowConversationSnapshot({
    this.messages = const [],
    this.activeDraft,
  });
}

/// Persists DayFlow chat history locally between sessions (per user).
class DayFlowConversationStore {
  DayFlowConversationStore._();

  static final DayFlowConversationStore instance = DayFlowConversationStore._();

  Future<String?> _storageKey() async {
    await DayFlowUserStorage.ensureUserScope();
    return DayFlowUserStorage.scopedKeyForCurrentUser(
      DayFlowUserStorage.conversationKeyBase,
    );
  }

  Future<DayFlowConversationSnapshot> load() async {
    final key = await _storageKey();
    if (key == null) return const DayFlowConversationSnapshot();

    final raw = locator<SharedPreferences>().getString(key);
    if (raw == null || raw.isEmpty) {
      return const DayFlowConversationSnapshot();
    }
    try {
      final map = Map<String, dynamic>.from(json.decode(raw) as Map);
      final cachedUser = map['userId']?.toString();
      final currentUser = await DayFlowUserStorage.currentUserId();
      if (cachedUser != null &&
          currentUser != null &&
          cachedUser != currentUser) {
        await locator<SharedPreferences>().remove(key);
        return const DayFlowConversationSnapshot();
      }

      final messages = <DayFlowStoredMessage>[];
      for (final m in map['messages'] as List<dynamic>? ?? []) {
        if (m is Map) {
          messages.add(
            DayFlowStoredMessage.fromJson(Map<String, dynamic>.from(m)),
          );
        }
      }
      DayFlowPlanDraft? draft;
      final rawDraft = map['activeDraft'];
      if (rawDraft is Map) {
        draft = DayFlowPlanDraft.fromJson(Map<String, dynamic>.from(rawDraft));
      }
      return DayFlowConversationSnapshot(
        messages: messages,
        activeDraft: draft,
      );
    } catch (_) {
      return const DayFlowConversationSnapshot();
    }
  }

  Future<void> save({
    required List<DayFlowStoredMessage> messages,
    DayFlowPlanDraft? activeDraft,
  }) async {
    final key = await _storageKey();
    if (key == null) return;
    final userId = await DayFlowUserStorage.currentUserId();
    await locator<SharedPreferences>().setString(
      key,
      json.encode({
        if (userId != null) 'userId': userId,
        'messages': messages.map((m) => m.toJson()).toList(),
        if (activeDraft != null) 'activeDraft': activeDraft.toJson(),
      }),
    );
  }

  Future<void> clear() async {
    final key = await _storageKey();
    if (key == null) return;
    await locator<SharedPreferences>().remove(key);
  }
}
