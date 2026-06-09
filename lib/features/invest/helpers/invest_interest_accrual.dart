import 'package:dayfi/services/remote/investment_service.dart';

/// Prorated interest earned so far on active locks (linear daily accrual).
class InvestInterestAccrual {
  InvestInterestAccrual._();

  static double maturityInterest(InvestmentPosition position) {
    if (position.interestEarned > 0) return position.interestEarned;
    if (position.lockDays <= 0) return 0;
    return position.principal *
        (position.apyPercent / 100) *
        (position.lockDays / 365);
  }

  static double accruedInterest(
    InvestmentPosition position, [
    DateTime? now,
  ]) {
    now ??= DateTime.now();
    if (position.status == 'claimed') return 0;

    final full = maturityInterest(position);
    if (position.canClaim || position.status == 'matured') return full;

    final start = position.startedAt;
    final end = position.maturesAt;
    if (start == null || end == null) return position.accruedInterest;

    final nowUtc = now.toUtc();
    final startUtc = start.toUtc();
    final endUtc = end.toUtc();
    if (!nowUtc.isBefore(endUtc)) return full;
    if (nowUtc.isBefore(startUtc)) return 0;

    final totalMs = endUtc.difference(startUtc).inMilliseconds;
    if (totalMs <= 0) return full;

    final elapsedMs = nowUtc.difference(startUtc).inMilliseconds;
    final fraction = (elapsedMs / totalMs).clamp(0.0, 1.0);
    return full * fraction;
  }

  static double totalAccrued(
    Iterable<InvestmentPosition> positions, [
    DateTime? now,
  ]) {
    return positions
        .where((p) => p.status != 'claimed')
        .fold(0.0, (sum, p) => sum + accruedInterest(p, now));
  }

  /// Pocket balance already includes locked principal; only add accruing interest.
  static double totalDisplayBalance(
    InvestmentSummary summary,
    Iterable<InvestmentPosition> positions, [
    DateTime? now,
  ]) {
    return summary.balance + totalAccrued(positions, now);
  }

  static String formatAmount(double amount) {
    if (amount >= 1) return '\$${amount.toStringAsFixed(2)}';
    if (amount >= 0.01) return '\$${amount.toStringAsFixed(2)}';
    if (amount > 0) return '\$${amount.toStringAsFixed(4)}';
    return '\$0.00';
  }
}
