import 'package:dayfi/features/dayflow/services/dayflow_api_service.dart';
import 'package:dayfi/features/dayflow/services/dayflow_conversation_store.dart';
import 'package:dayfi/features/dayflow/services/dayflow_cache_sync.dart';
import 'package:dayfi/features/dayflow/services/dayflow_dashboard_cache.dart';
import 'package:dayfi/features/dayflow/services/dayflow_local_store.dart';
import 'package:dayfi/features/dayflow/services/dayflow_user_storage.dart';

/// Wipes active DayFlow automations and local draft state so the user can start fresh.
abstract final class DayFlowResetService {
  static Future<void> startOver() async {
    await DayFlowUserStorage.ensureUserScope();

    try {
      final flows = await dayFlowApiService.fetchFlows();
      for (final flow in flows.where((f) => f.isActive)) {
        try {
          await dayFlowApiService.cancelFlow(flow.id);
        } catch (_) {}
      }
    } catch (_) {}

    await DayFlowLocalStore.instance.clearPlan();
    await DayFlowLocalStore.instance.clearTemplate();
    await DayFlowConversationStore.instance.clear();
    DayFlowCacheSync.invalidateAll();
  }
}
