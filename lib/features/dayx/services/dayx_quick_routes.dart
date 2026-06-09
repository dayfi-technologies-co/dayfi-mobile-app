import 'package:dayfi/features/dayx/constants/dayx_product_knowledge.dart';
import 'package:dayfi/features/dayx/models/dayx_intent.dart';

/// Instant DayX routing for common phrases (chips + typed shortcuts).
class DayxQuickRoutes {
  DayxQuickRoutes._();

  /// Starts an in-overlay wizard instead of jumping to a legacy screen.
  static String? productKnowledgeReplyFor(String message) {
    if (DayxProductKnowledge.matches(message)) {
      return DayxProductKnowledge.appOverview;
    }
    return null;
  }

  static String? flowIdFor(String message) {
    final q = message.trim().toLowerCase();
    if (q.isEmpty) return null;

    if (_matchesAny(q, const [
      'how do i send money',
      'how to send money',
      'send money',
      'start send',
      'transfer money',
      'transfer to bank',
      'make a transfer',
    ])) {
      return 'send';
    }

    if (_matchesAny(q, const [
      'pay a bill',
      'pay bills',
      'pay bill',
      'buy airtime',
      'pay utilities',
    ])) {
      return 'pay';
    }

    if (_matchesAny(q, const [
      'add money',
      'top up',
      'deposit',
      'fund wallet',
      'receive money',
      'get paid',
      'how do i receive',
    ]) &&
        !q.contains('withdraw')) {
      return 'add_money';
    }

    return null;
  }

  static String? navigateTargetFor(String message) {
    final q = message.trim().toLowerCase();
    if (q.isEmpty) return null;

    if (_matchesAny(q, const [
      'customer support',
      'contact support',
      'reach out to support',
      'talk to support',
      'live chat',
      'chat with support',
      'support team',
      'need support',
      'get support',
      'open support',
      'talk to someone',
      'contact dayfi',
      'help center',
    ])) {
      return DayxNavigateTargets.support;
    }

    if (_matchesAny(q, const [
      'check balance',
      "what's my balance",
      'whats my balance',
      'my balance',
      'how much do i have',
      'account balance',
    ])) {
      return '__balance__';
    }

    if (_matchesAny(q, const ['open send'])) {
      return DayxNavigateTargets.send;
    }

    if (_matchesAny(q, const ['open bills', 'open pay'])) {
      return DayxNavigateTargets.pay;
    }

    if (_matchesAny(q, const [
      'open dayearn',
      'open earn',
      'dayearn',
      'lock & earn',
      'lock and earn',
      'earn interest',
      'savings',
    ])) {
      return DayxNavigateTargets.invest;
    }

    if (_matchesAny(q, const [
      'open dayflow',
      'dayflow',
      'budget',
      'plan my money',
      'track expenses',
    ])) {
      return DayxNavigateTargets.dayflow;
    }

    if (_matchesAny(q, const [
      'withdraw',
      'withdraw funds',
    ])) {
      return DayxNavigateTargets.withdraw;
    }

    if (_matchesAny(q, const ['open add money'])) {
      return DayxNavigateTargets.addMoney;
    }

    if (_matchesAny(q, const [
      'transaction history',
      'recent transactions',
      'view transactions',
      'spending history',
      'history',
      'transactions',
    ])) {
      return DayxNavigateTargets.transactions;
    }

    if (_matchesAny(q, const [
      'recipients',
      'saved recipients',
      'my contacts',
    ])) {
      return DayxNavigateTargets.recipients;
    }

    return null;
  }

  static String replyForTarget(String target) {
    switch (target) {
      case '__balance__':
        return 'Here are your wallet balances.';
      case DayxNavigateTargets.send:
        return 'Opening send — pick where you\'re sending to.';
      case DayxNavigateTargets.pay:
        return 'Opening Pay bills.';
      case DayxNavigateTargets.invest:
        return 'Opening DayEarn.';
      case DayxNavigateTargets.dayflow:
        return 'Opening DayFlow — smartly budget and automate your payments.';
      case DayxNavigateTargets.addMoney:
        return 'Opening Add money.';
      case DayxNavigateTargets.withdraw:
        return 'Opening send to move funds out.';
      case DayxNavigateTargets.transactions:
        return 'Opening your transaction history.';
      case DayxNavigateTargets.recipients:
        return 'Opening Recipients.';
      case DayxNavigateTargets.support:
        return 'Opening customer support.';
      default:
        return 'Opening that for you.';
    }
  }

  static bool _matchesAny(String q, List<String> needles) {
    return needles.any((n) => q == n || q.contains(n));
  }
}
