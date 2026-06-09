import 'package:dayfi/app_locator.dart';
import 'package:dayfi/features/dayx/models/dayx_intent.dart';
import 'package:dayfi/flavors.dart';
import 'package:dayfi/services/remote/network/network_service.dart';

class DayxStatus {
  final bool enabled;
  final String mode;
  final String provider;
  final String? model;

  const DayxStatus({
    required this.enabled,
    required this.mode,
    required this.provider,
    this.model,
  });

  factory DayxStatus.fromJson(Map<String, dynamic> json) {
    return DayxStatus(
      enabled: json['enabled'] == true,
      mode: json['mode']?.toString() ?? 'local',
      provider: json['provider']?.toString() ?? 'rules',
      model: json['model']?.toString(),
    );
  }

  bool get isFullMode => mode == 'full';

  String get displayLabel {
    if (!isFullMode) return 'Offline';
    if (provider == 'groq') return 'AI';
    if (provider == 'openai') return 'AI';
    return 'AI';
  }
}

/// Calls backend DayX (Groq via server). No local mock fallback.
class DayxChatService {
  DayxChatService({NetworkService? network})
      : _network = network ?? locator<NetworkService>();

  final NetworkService _network;
  DayxStatus? _cachedStatus;

  Future<DayxStatus> fetchStatus({bool forceRefresh = false}) async {
    if (_cachedStatus != null && !forceRefresh) return _cachedStatus!;
    try {
      final response = await _network.call(
        '${F.baseUrl}/dayx/status',
        RequestMethod.get,
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final inner = data['data'] is Map<String, dynamic>
            ? data['data'] as Map<String, dynamic>
            : data;
        _cachedStatus = DayxStatus.fromJson(inner);
        return _cachedStatus!;
      }
    } catch (_) {
      /* offline or unauthenticated */
    }
    _cachedStatus = const DayxStatus(
      enabled: false,
      mode: 'local',
      provider: 'rules',
    );
    return _cachedStatus!;
  }

  Future<DayxResponse> chat({
    required String message,
    List<DayxHistoryMessage> history = const [],
  }) async {
    final response = await _network.call(
      '${F.baseUrl}/dayx/chat',
      RequestMethod.post,
      data: {
        'message': message,
        'history': history
            .map((h) => {'role': h.role, 'content': h.content})
            .toList(),
      },
    );
    final root = response.data;
    if (root is! Map<String, dynamic>) {
      throw const DayxChatException('Invalid DayX response');
    }
    final data = root['data'] is Map<String, dynamic>
        ? root['data'] as Map<String, dynamic>
        : root;
    return DayxResponse.fromJson(data);
  }
}

class DayxChatException implements Exception {
  final String message;
  const DayxChatException(this.message);

  @override
  String toString() => message;
}

class DayxHistoryMessage {
  final String role;
  final String content;

  const DayxHistoryMessage({required this.role, required this.content});
}
