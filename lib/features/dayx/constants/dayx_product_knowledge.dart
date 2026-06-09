/// Product facts DayX uses for “what is DayFi?” and help replies (client-side).
abstract final class DayxProductKnowledge {
  DayxProductKnowledge._();

  static const appOverview =
      'Happy to explain! DayFi is your global wallet — one place for money across Africa and beyond.\n\n'
      'You can:\n'
      '• Add money — bank transfer, username, or crypto (including Stellar USDC)\n'
      '• Send worldwide — bank, mobile money, @username, or crypto\n'
      '• Pay bills — airtime, data, TV, utilities, and more\n'
      '• DayEarn — savings pots with daily interest\n'
      '• DayFlow — chat to budget, automate allowance, split rent, and schedule sends & bills\n\n'
      'Just tell me what you need — e.g. “send ₦5,000 to mom”, “pay airtime”, or “help me budget”.';

  static const capabilitiesHelp =
      'Here is what I can do for you:\n'
      '• Check your balance and recent transactions\n'
      '• Send money (bank, mobile money, @username, crypto)\n'
      '• Add money to your wallet\n'
      '• Pay Nigerian bills\n'
      '• Open DayEarn savings or DayFlow budgeting\n'
      '• Connect you with support\n\n'
      'Try: “Send money”, “Pay bills”, “Check balance”, or “Open DayFlow”.';

  static bool matches(String message) {
    final q = message
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (q.isEmpty) return false;

    const needles = [
      'what is dayfi',
      'whats dayfi',
      'what is day fi',
      'what is this app',
      'whats this app',
      'what s this app',
      'what is the app',
      'tell me about dayfi',
      'about dayfi',
      'about the app',
      'about this app',
      'all about',
      'what can dayfi do',
      'what does dayfi do',
      'how does dayfi work',
      'how does this app work',
      'what is dayx',
      'global wallet',
      'what do you do',
      'what can you do',
      'what are you',
      'who are you',
      'help me understand',
      'explain dayfi',
      'explain the app',
    ];

    if (needles.any(q.contains)) return true;

    if (q.contains('app') &&
        (q.contains('about') ||
            q.contains('what') ||
            q.contains('explain') ||
            q.contains('all about'))) {
      return true;
    }

    return false;
  }
}
