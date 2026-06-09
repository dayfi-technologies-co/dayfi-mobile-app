import 'package:dayfi/features/dayflow/models/dayflow_models.dart';

/// In-memory DayBudget dashboard cache for instant navigation from Home.
class DayflowDashboardCache {
  DayflowDashboardCache._();

  static final DayflowDashboardCache instance = DayflowDashboardCache._();

  DayFlowDashboardSnapshot? _snapshot;
  DateTime? _fetchedAt;

  static const _maxAge = Duration(minutes: 5);

  DayFlowDashboardSnapshot? peek() {
    if (_snapshot == null || _fetchedAt == null) return null;
    if (DateTime.now().difference(_fetchedAt!) > _maxAge) return null;
    return _snapshot;
  }

  void put(DayFlowDashboardSnapshot snapshot) {
    _snapshot = snapshot;
    _fetchedAt = DateTime.now();
  }

  void invalidate() {
    _snapshot = null;
    _fetchedAt = null;
  }

  bool? get hasActivePlan {
    final snap = peek();
    if (snap == null) return null;
    if (snap.hasActivePlan) return true;
    return snap.flows.any((f) => f.isActive);
  }
}
