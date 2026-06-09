import 'package:dayfi/services/remote/dayearn_service.dart';

/// In-memory DayEarn summary cache for instant navigation from Home.
class DayEarnSummaryCache {
  DayEarnSummaryCache._();

  static final DayEarnSummaryCache instance = DayEarnSummaryCache._();

  DayEarnSummary? _summary;
  DateTime? _fetchedAt;

  static const _maxAge = Duration(minutes: 5);

  DayEarnSummary? peek() {
    if (_summary == null || _fetchedAt == null) return null;
    if (DateTime.now().difference(_fetchedAt!) > _maxAge) return null;
    return _summary;
  }

  void put(DayEarnSummary summary) {
    _summary = summary;
    _fetchedAt = DateTime.now();
  }

  void invalidate() {
    _summary = null;
    _fetchedAt = null;
  }
}
