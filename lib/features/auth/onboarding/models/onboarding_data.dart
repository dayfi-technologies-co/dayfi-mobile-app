import 'onboarding_page.dart';

class OnboardingData {
  static const List<OnboardingPage> pages = [
    OnboardingPage(
      title: 'Send money\nto anyone',
      subtitle:
          'Send salaries, gig payouts, and remittances that update every second.',
      description:
          'Experience real-time financial flows powered by Stellar USDC and our instant streaming engine.',
      illustrationPath: 'assets/icons/svgs/recipients.svg',
      decorativeElements: ['purple_starburst', 'green_starburst'],
    ),
    OnboardingPage(
      title: 'Cross-border\nin real time',
      subtitle:
          'Send USD globally and settle instantly into NGN, ZAR, GHS, and more.',
      description:
          'Your recipients get live-updating balances in their local currency—no delays, no friction.',
      illustrationPath: 'assets/icons/svgs/transactions.svg',
      decorativeElements: ['purple_starburst', 'green_starburst'],
    ),
    OnboardingPage(
      title: 'Secure and\nprogrammable',
      subtitle:
          'Built with end-to-end encryption, KYC/KYB, and automated compliance rules.',
      description:
          'Our programmable ledger gives you full transparency, audit trails, and enterprise-grade safety.',
      illustrationPath: 'assets/icons/pngs/account_4.png',
      decorativeElements: [
        'padlock',
        'green_star',
        'teal_circle',
        'purple_circle',
      ],
    ),
    OnboardingPage(
      title: 'Instant cash-out\nwhen needed',
      subtitle:
          'Recipients withdraw in seconds to bank accounts and mobile wallets.',
      description:
          'We stream continuously, and settle instantly—so funds are available whenever they’re needed.',
      illustrationPath: 'assets/icons/svgs/swap.svg',
      decorativeElements: ['hand_stopwatch'],
    ),
  ];
}
