/// DayX user-facing copy and suggestion prompts.
abstract final class DayxCopy {
  DayxCopy._();

  static const featureName = 'DayX';

  /// Long intro bubble — always the second message; starts with I'm DayX.
  static const chatWelcomeIntroLead =
      "I'm DayX — your guide inside DayFi. I can help you send money, "
      'pay bills, check your balance, open DayEarn savings, or build a '
      'budget with DayFlow.';

  static const trySayingHeading = 'Try saying:';

  static const actionHeading = 'What would you like to do?';

  static const voiceTryPhrases = [
    'Send ₦5,000 to mom',
    'Pay airtime',
    'Help me budget this month',
    'What is DayFi?',
  ];

  @Deprecated('Use greetingLine + chatWelcomeIntroLead as two messages')
  static const chatWelcome = chatWelcomeIntroLead;

  static const offTopicFallback =
      'I\'m best at DayFi tasks — sends, bills, balance, DayEarn, and DayFlow budgets. What would you like to do?';

  /// Shown on screen only — never spoken at voice session start.
  static const voiceListeningHint = 'I\'m listening. Say what you need.';

  /// Legacy long intro (chat / transcript only).
  static const voiceGreeting =
      'Hi, I\'m DayX. Ask me to send money, pay bills, add money, check balance, or open DayEarn and DayFlow.';

  static const starterSuggestions = [
    'What is DayFi?',
    'Check balance',
    'Send money',
    'Pay bills',
    'Add money',
    'Open DayEarn',
    'Open DayFlow',
    'View transactions',
  ];

  static const voiceGreetingShort =
      'Hi — what can I help you with? I\'m listening.';

  static const voiceReadyLine = 'I\'m listening.';

  static const followUpSuggestions = [
    'What is DayFi?',
    'Check balance',
    'Send money',
    'Pay bills',
    'Add money',
    'Open DayEarn',
    'Open DayFlow',
    'Contact support',
  ];
}
