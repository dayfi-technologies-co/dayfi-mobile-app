import 'package:dayfi/app_locator.dart';
import 'package:dayfi/features/dayflow/models/dayflow_models.dart';
import 'package:dayfi/flavors.dart';
import 'package:dayfi/services/remote/network/network_service.dart';

class DayFlowStatus {
  final bool enabled;
  final String mode;
  final String provider;
  final String? model;

  const DayFlowStatus({
    required this.enabled,
    required this.mode,
    required this.provider,
    this.model,
  });

  factory DayFlowStatus.fromJson(Map<String, dynamic> json) {
    return DayFlowStatus(
      enabled: json['enabled'] == true,
      mode: json['mode']?.toString() ?? 'local',
      provider: json['provider']?.toString() ?? 'rules',
      model: json['model']?.toString(),
    );
  }

  bool get isFullMode => mode == 'full';
}

class DayFlowChatService {
  DayFlowChatService({NetworkService? network})
      : _network = network ?? locator<NetworkService>();

  final NetworkService _network;
  DayFlowStatus? _cachedStatus;

  Future<DayFlowStatus> fetchStatus({bool forceRefresh = false}) async {
    if (_cachedStatus != null && !forceRefresh) return _cachedStatus!;
    try {
      final response = await _network.call(
        '${F.baseUrl}/dayflow/status',
        RequestMethod.get,
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final inner = data['data'] is Map<String, dynamic>
            ? data['data'] as Map<String, dynamic>
            : data;
        _cachedStatus = DayFlowStatus.fromJson(inner);
        return _cachedStatus!;
      }
    } catch (_) {
      /* offline */
    }
    _cachedStatus = const DayFlowStatus(
      enabled: false,
      mode: 'local',
      provider: 'rules',
    );
    return _cachedStatus!;
  }

  Future<DayFlowChatResponse> chat({
    required String message,
    List<DayFlowHistoryMessage> history = const [],
    String? mode,
  }) async {
    final response = await _network.call(
      '${F.baseUrl}/dayflow/chat',
      RequestMethod.post,
      data: {
        'message': message,
        'history': history
            .map((h) => {'role': h.role, 'content': h.content})
            .toList(),
        if (mode != null && mode.isNotEmpty) 'mode': mode,
      },
    );
    final root = response.data;
    if (root is! Map<String, dynamic>) {
      throw const DayFlowChatException('Invalid DayFlow response');
    }
    final data = root['data'] is Map<String, dynamic>
        ? root['data'] as Map<String, dynamic>
        : root;
    return DayFlowChatResponse.fromJson(data);
  }
}

class DayFlowChatException implements Exception {
  final String message;
  const DayFlowChatException(this.message);

  @override
  String toString() => message;
}

class DayFlowHistoryMessage {
  final String role;
  final String content;

  const DayFlowHistoryMessage({required this.role, required this.content});
}

class DayFlowChatResponse {
  final String reply;
  final DayFlowPlanDraft? planDraft;
  final bool suggestSwap;
  final DayFlowResponseMeta meta;

  const DayFlowChatResponse({
    required this.reply,
    this.planDraft,
    this.suggestSwap = false,
    required this.meta,
  });

  factory DayFlowChatResponse.fromJson(Map<String, dynamic> json) {
    DayFlowPlanDraft? draft;
    final rawDraft = json['planDraft'];
    if (rawDraft is Map<String, dynamic>) {
      draft = DayFlowPlanDraft.fromJson(rawDraft);
    }
    return DayFlowChatResponse(
      reply: json['reply']?.toString() ?? '',
      planDraft: draft,
      suggestSwap: json['suggestSwap'] == true,
      meta: DayFlowResponseMeta.fromJson(
        json['meta'] is Map<String, dynamic>
            ? json['meta'] as Map<String, dynamic>
            : const {},
      ),
    );
  }
}

class DayFlowResponseMeta {
  final String provider;
  final String mode;

  const DayFlowResponseMeta({required this.provider, required this.mode});

  factory DayFlowResponseMeta.fromJson(Map<String, dynamic> json) {
    return DayFlowResponseMeta(
      provider: json['provider']?.toString() ?? 'rules',
      mode: json['mode']?.toString() ?? 'local',
    );
  }
}
