import 'package:dayfi/app_locator.dart';
import 'package:dayfi/features/dayx/models/dayx_intent.dart';
import 'package:dayfi/features/dayx/services/dayx_chat_service.dart';
import 'package:dayfi/features/dayx_v2/services/dayx_v2_prefs.dart';
import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';
import 'package:dayfi/flavors.dart';
import 'package:dayfi/services/remote/network/network_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Voice-first DayX v2 — uses `/dayx/v2/chat` with persona + language rules.
class DayxV2ChatService {
  DayxV2ChatService({NetworkService? network})
      : _network = network ?? locator<NetworkService>();

  final NetworkService _network;

  Future<DayxResponse> chat({
    required String message,
    List<DayxHistoryMessage> history = const [],
    WidgetRef? ref,
  }) async {
    String? firstName;
    if (ref != null) {
      final user = ref.read(profileViewModelProvider).user;
      firstName = user?.firstName?.trim();
      if (firstName != null && firstName.isEmpty) firstName = null;
    }

    final response = await _network.call(
      '${F.baseUrl}/dayx/v2/chat',
      RequestMethod.post,
      data: {
        'message': message,
        'history': history
            .map((h) => {'role': h.role, 'content': h.content})
            .toList(),
        'voiceName': DayxV2Prefs.selectedVoiceId ?? 'Idera',
        if (firstName != null && firstName.isNotEmpty) 'firstName': firstName,
        'isFirstSession': DayxV2Prefs.shouldShowIntro,
      },
    );

    final root = response.data;
    if (root is! Map<String, dynamic>) {
      throw const DayxChatException('Invalid DayX v2 response');
    }
    final data = root['data'] is Map<String, dynamic>
        ? root['data'] as Map<String, dynamic>
        : root;
    return DayxResponse.fromJson(data);
  }
}
