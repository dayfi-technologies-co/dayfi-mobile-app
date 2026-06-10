import 'package:dayfi/features/budget/services/budget_list_cache.dart';
import 'package:dayfi/features/dayflow/services/dayflow_dashboard_cache.dart';

/// Keeps budget list and DayFlow dashboard caches aligned after mutations.
abstract final class DayFlowCacheSync {
  DayFlowCacheSync._();

  static void invalidateAll() {
    BudgetListCache.instance.invalidate();
    DayflowDashboardCache.instance.invalidate();
  }
}
