import 'package:dayfi/features/dayx/models/dayx_intent.dart';
import 'package:dayfi/features/dayx/constants/dayx_product_knowledge.dart';

/// Rules-based DayX responses for v1 — no LLM required.
class DayxMockIntentService {
  DayxMockIntentService._();

  static Future<DayxResponse> resolve(String message) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final q = message.trim().toLowerCase();
    if (q.isEmpty) {
      return _clarify('Say something like “What’s my balance?” or “Open transactions”.');
    }

    if (_matchesAny(q, [
      'balance',
      'how much',
      'how much do i have',
      'my money',
      'wallet balance',
      'what do i have',
      "what's my balance",
      'whats my balance',
    ])) {
      return const DayxResponse(
        reply: 'Here are your wallet balances.',
        intent: DayxIntent(
          action: DayxIntentActions.showBalance,
          confidence: 0.95,
        ),
        ui: DayxUi(
          type: DayxUiTypes.balanceCard,
          title: 'Your balances',
        ),
      );
    }

    if (_matchesAny(q, [
      'customer support',
      'contact support',
      'reach out to support',
      'talk to support',
      'live chat',
      'support team',
      'need support',
      'speak to someone',
    ])) {
      return const DayxResponse(
        reply: 'Opening customer support — you can chat with our team there.',
        intent: DayxIntent(
          action: DayxIntentActions.openSupport,
          confidence: 0.95,
        ),
        ui: DayxUi(type: DayxUiTypes.textOnly),
      );
    }

    final route = _matchNavigate(q);
    if (route != null) {
      return DayxResponse(
        reply: route.reply,
        intent: DayxIntent(
          action: DayxIntentActions.navigate,
          confidence: 0.9,
          params: {'target': route.target},
        ),
        ui: const DayxUi(type: DayxUiTypes.textOnly),
      );
    }

    if (_matchesAny(q, ['help', 'what can you do', 'commands', 'what can dayfi do'])) {
      return const DayxResponse(
        reply: DayxProductKnowledge.capabilitiesHelp,
        ui: DayxUi(type: DayxUiTypes.textOnly),
      );
    }

    if (DayxProductKnowledge.matches(q)) {
      return const DayxResponse(
        reply: DayxProductKnowledge.appOverview,
        ui: DayxUi(type: DayxUiTypes.textOnly),
      );
    }

    return DayxResponse(
      reply:
          'I didn’t catch that yet. Try “What’s my balance?” or “Open transactions”.',
      intent: const DayxIntent(
        action: DayxIntentActions.clarify,
        confidence: 0.4,
      ),
      ui: const DayxUi(type: DayxUiTypes.textOnly),
    );
  }

  static bool _matchesAny(String q, List<String> needles) {
    return needles.any((n) => q.contains(n));
  }

  static _RouteMatch? _matchNavigate(String q) {
    const routes = <_RouteMatch>[
      _RouteMatch(
        target: DayxNavigateTargets.home,
        needles: ['home', 'go home', 'open home'],
        reply: 'Opening Home.',
      ),
      _RouteMatch(
        target: DayxNavigateTargets.transactions,
        needles: [
          'transaction',
          'transactions',
          'history',
          'activity',
          'spending history',
        ],
        reply: 'Opening Transactions.',
      ),
      _RouteMatch(
        target: DayxNavigateTargets.recipients,
        needles: ['recipient', 'recipients', 'contacts'],
        reply: 'Opening Recipients.',
      ),
      _RouteMatch(
        target: DayxNavigateTargets.profile,
        needles: ['profile', 'account', 'settings', 'more tab'],
        reply: 'Opening More.',
      ),
      _RouteMatch(
        target: DayxNavigateTargets.invest,
        needles: [
          'invest',
          'earn',
          'lock',
          'lock & earn',
          'lock and earn',
          'earn interest',
          'safelock',
          'open earn',
        ],
        reply: 'Opening Lock & Earn.',
      ),
      _RouteMatch(
        target: DayxNavigateTargets.pay,
        needles: [
          'pay a bill',
          'pay bill',
          'pay bills',
          'airtime',
          'data',
          'cable',
          'utilities',
        ],
        reply: 'Opening Pay bills.',
      ),
      _RouteMatch(
        target: DayxNavigateTargets.send,
        needles: [
          'how do i send',
          'how to send',
          'send money',
          'transfer money',
          'send',
          'transfer',
        ],
        reply: 'Opening send — pick your destination.',
      ),
      _RouteMatch(
        target: DayxNavigateTargets.budgets,
        needles: ['budget', 'budgets'],
        reply: 'Opening Budgets.',
      ),
      _RouteMatch(
        target: DayxNavigateTargets.addMoney,
        needles: ['add money', 'top up', 'deposit', 'receive'],
        reply: 'Opening Add money.',
      ),
    ];

    for (final route in routes) {
      if (route.needleMatches(q)) return route;
    }
    return null;
  }

  static DayxResponse _clarify(String text) {
    return DayxResponse(
      reply: text,
      intent: const DayxIntent(
        action: DayxIntentActions.clarify,
        confidence: 0.5,
      ),
      ui: const DayxUi(type: DayxUiTypes.textOnly),
    );
  }
}

class _RouteMatch {
  final String target;
  final List<String> needles;
  final String reply;

  const _RouteMatch({
    required this.target,
    required this.needles,
    required this.reply,
  });

  bool needleMatches(String q) {
    return needles.any((n) => q.contains(n));
  }
}
