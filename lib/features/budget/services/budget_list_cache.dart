import 'package:dayfi/features/budget/models/budget_models.dart';

/// In-memory budget list cache for instant Budgets screen navigation.
class BudgetListCache {
  BudgetListCache._();

  static final BudgetListCache instance = BudgetListCache._();

  List<Budget>? _budgets;
  DateTime? _fetchedAt;

  static const _maxAge = Duration(minutes: 5);

  List<Budget>? peek() {
    if (_budgets == null || _fetchedAt == null) return null;
    if (DateTime.now().difference(_fetchedAt!) > _maxAge) return null;
    return List<Budget>.from(_budgets!);
  }

  /// Returns cached budgets even when stale — for instant screen paint.
  List<Budget>? peekAny() {
    if (_budgets == null) return null;
    return List<Budget>.from(_budgets!);
  }

  void put(List<Budget> budgets) {
    _budgets = List<Budget>.from(budgets);
    _fetchedAt = DateTime.now();
  }

  void invalidate() {
    _budgets = null;
    _fetchedAt = null;
  }
}
