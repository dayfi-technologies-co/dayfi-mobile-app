import 'dart:convert';

import 'package:dayfi/app_locator.dart';
import 'package:dayfi/features/dayflow/models/dayflow_models.dart';
import 'package:dayfi/features/dayflow/services/dayflow_api_service.dart';
import 'package:dayfi/features/dayflow/services/dayflow_dashboard_cache.dart';
import 'package:dayfi/features/dayflow/services/dayflow_user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local cache for DayBudget — server is source of truth when online.
class DayFlowLocalStore {
  DayFlowLocalStore._();

  static final DayFlowLocalStore instance = DayFlowLocalStore._();

  Future<void> _cachePlan(DayFlowPlan plan, String key) async {
    await locator<SharedPreferences>().setString(
      key,
      json.encode({
        ...plan.toJson(),
        '_cachedUserId': await DayFlowUserStorage.currentUserId(),
      }),
    );
  }

  Future<void> _cacheTemplate(DayFlowPlanDraft draft, String key) async {
    await locator<SharedPreferences>().setString(
      key,
      json.encode({
        ...draft.toJson(),
        '_cachedUserId': await DayFlowUserStorage.currentUserId(),
      }),
    );
  }

  Future<DayFlowPlan?> _readCachedPlan(String key) async {
    final raw = locator<SharedPreferences>().getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = Map<String, dynamic>.from(json.decode(raw) as Map);
      final cachedUser = map.remove('_cachedUserId')?.toString();
      final currentUser = await DayFlowUserStorage.currentUserId();
      if (cachedUser != null &&
          currentUser != null &&
          cachedUser != currentUser) {
        await locator<SharedPreferences>().remove(key);
        return null;
      }
      return DayFlowPlan.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<DayFlowPlanDraft?> _readCachedTemplate(String key) async {
    final raw = locator<SharedPreferences>().getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = Map<String, dynamic>.from(json.decode(raw) as Map);
      final cachedUser = map.remove('_cachedUserId')?.toString();
      final currentUser = await DayFlowUserStorage.currentUserId();
      if (cachedUser != null &&
          currentUser != null &&
          cachedUser != currentUser) {
        await locator<SharedPreferences>().remove(key);
        return null;
      }
      return DayFlowPlanDraft.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  /// Cached plan only — no network (fast path for dashboard UI).
  Future<DayFlowPlan?> loadCachedPlan() async {
    await DayFlowUserStorage.ensureUserScope();
    final key = await DayFlowUserStorage.scopedKeyForCurrentUser(
      DayFlowUserStorage.planKeyBase,
    );
    if (key == null) return null;
    return _readCachedPlan(key);
  }

  Future<DayFlowPlan?> loadPlan() async {
    await DayFlowUserStorage.ensureUserScope();
    final key = await DayFlowUserStorage.scopedKeyForCurrentUser(
      DayFlowUserStorage.planKeyBase,
    );
    if (key == null) return null;

    final result = await dayFlowApiService.fetchPlanResult();
    if (result.fromServer) {
      if (result.plan != null) {
        await _cachePlan(result.plan!, key);
        return result.plan;
      }
      await locator<SharedPreferences>().remove(key);
      return null;
    }

    return _readCachedPlan(key);
  }

  Future<void> savePlan(DayFlowPlan plan) async {
    await DayFlowUserStorage.ensureUserScope();
    final key = await DayFlowUserStorage.scopedKeyForCurrentUser(
      DayFlowUserStorage.planKeyBase,
    );
    if (key == null) return;
    final synced = await dayFlowApiService.syncPlan(plan);
    await _cachePlan(synced ?? plan, key);
  }

  Future<void> clearPlan() async {
    await DayFlowUserStorage.ensureUserScope();
    final key = await DayFlowUserStorage.scopedKeyForCurrentUser(
      DayFlowUserStorage.planKeyBase,
    );
    if (key == null) return;
    await locator<SharedPreferences>().remove(key);
  }

  Future<void> saveTemplate(DayFlowPlanDraft draft) async {
    await DayFlowUserStorage.ensureUserScope();
    final key = await DayFlowUserStorage.scopedKeyForCurrentUser(
      DayFlowUserStorage.templateKeyBase,
    );
    if (key == null) return;
    final synced = await dayFlowApiService.saveTemplate(draft);
    await _cacheTemplate(synced, key);
  }

  Future<void> clearTemplate() async {
    await DayFlowUserStorage.ensureUserScope();
    final key = await DayFlowUserStorage.scopedKeyForCurrentUser(
      DayFlowUserStorage.templateKeyBase,
    );
    if (key == null) return;
    await locator<SharedPreferences>().remove(key);
  }

  Future<DayFlowPlanDraft?> loadTemplate() async {
    await DayFlowUserStorage.ensureUserScope();
    final key = await DayFlowUserStorage.scopedKeyForCurrentUser(
      DayFlowUserStorage.templateKeyBase,
    );
    if (key == null) return null;

    try {
      final remote = await dayFlowApiService.fetchTemplate();
      if (remote != null) {
        await _cacheTemplate(remote, key);
        return remote;
      }
      await locator<SharedPreferences>().remove(key);
    } catch (_) {}

    return _readCachedTemplate(key);
  }
}

/// Whether the user has an active DayBudget on the server.
abstract final class DayFlowActivity {
  /// Fast local signal — no network (used before opening DayFlow from Home).
  static Future<bool> hasLocalSetup() async {
    await DayFlowUserStorage.ensureUserScope();
    final plan = await DayFlowLocalStore.instance.loadCachedPlan();
    if (plan == null) return false;
    return plan.upcoming.isNotEmpty ||
        plan.categories.any((c) => c.allocated > 0) ||
        plan.totalBudget > 0;
  }

  static Future<bool> hasPlan() async {
    await DayFlowUserStorage.ensureUserScope();
    final cached = DayflowDashboardCache.instance.hasActivePlan;
    if (cached != null) return cached;
    if (await hasLocalSetup()) return true;
    return dayFlowApiService.hasActiveBudgetOnServer();
  }
}
