import 'package:dayfi/app_locator.dart';
import 'package:dayfi/features/dayflow/services/dayflow_dashboard_cache.dart';
import 'package:dayfi/services/local/local_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Per-user keys for DayBudget local cache — prevents cross-account leakage.
abstract final class DayFlowUserStorage {
  static const lastUserIdKey = 'dayflow_last_user_id_v1';

  static const legacyPlanKey = 'dayflow_active_plan_v1';
  static const legacyTemplateKey = 'daybudget_template_v1';
  static const legacyConversationKey = 'dayflow_conversation_v1';
  static const legacyDismissedIncomeKey = 'dayflow_dismissed_income_v1';

  static const planKeyBase = 'dayflow_active_plan_v2';
  static const templateKeyBase = 'daybudget_template_v2';
  static const conversationKeyBase = 'dayflow_conversation_v2';
  static const dismissedIncomeKeyBase = 'dayflow_dismissed_income_v2';

  static Future<String?> currentUserId() async {
    final user = await locator<LocalCache>().getUser();
    for (final key in ['user_id', 'userId', '_id', 'id']) {
      final value = user[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  static String scopedKey(String base, String userId) => '${base}_$userId';

  static Future<String?> scopedKeyForCurrentUser(String base) async {
    final userId = await currentUserId();
    if (userId == null || userId.isEmpty) return null;
    return scopedKey(base, userId);
  }

  /// Call before reading/writing DayBudget cache. Clears stale data on account switch.
  static Future<void> ensureUserScope() async {
    final userId = await currentUserId();
    if (userId == null || userId.isEmpty) return;

    final prefs = locator<SharedPreferences>();
    final previous = prefs.getString(lastUserIdKey);
    if (previous != null && previous != userId) {
      DayflowDashboardCache.instance.invalidate();
    }
    await _removeLegacyGlobalKeys(prefs);
    await prefs.setString(lastUserIdKey, userId);
  }

  static Future<void> clearAllForLogout() async {
    final prefs = locator<SharedPreferences>();
    final userId = prefs.getString(lastUserIdKey) ?? await currentUserId();
    if (userId != null && userId.isNotEmpty) {
      await prefs.remove(scopedKey(planKeyBase, userId));
      await prefs.remove(scopedKey(templateKeyBase, userId));
      await prefs.remove(scopedKey(conversationKeyBase, userId));
      await prefs.remove(scopedKey(dismissedIncomeKeyBase, userId));
    }
    await _removeLegacyGlobalKeys(prefs);
    await prefs.remove(lastUserIdKey);
    DayflowDashboardCache.instance.invalidate();
  }

  static Future<void> _removeLegacyGlobalKeys(SharedPreferences prefs) async {
    for (final key in [
      legacyPlanKey,
      legacyTemplateKey,
      legacyConversationKey,
      legacyDismissedIncomeKey,
    ]) {
      await prefs.remove(key);
    }
  }
}
