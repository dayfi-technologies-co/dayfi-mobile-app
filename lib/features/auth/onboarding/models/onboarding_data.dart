import 'onboarding_page.dart';

class OnboardingData {
  static const List<OnboardingPage> pages = [
    OnboardingPage(
      title: 'Send money',
      subtitle: 'Pay salaries, support family, and send remittances with ease.',
      description:
          'Move money across African countries.',
      illustrationPath: 'assets/icons/svgs/recipients.svg',
      decorativeElements: ['purple_starburst', 'green_starburst'],
    ),
    OnboardingPage(
      title: 'Fast payments',
      subtitle: 'Send instantly in NGN, GHS, ZAR, and more.',
      description:
          'No delays. Recipients receive money in their local currency.',
      illustrationPath: 'assets/icons/svgs/transactions.svg',
      decorativeElements: ['purple_starburst', 'green_starburst'],
    ),
    OnboardingPage(
      title: 'Safe & reliable',
      subtitle: 'Protected with strong security and verified accounts.',
      description:
          'Every transaction is encrypted and transparent.',
      illustrationPath: 'assets/icons/pngs/account_4.png',
      decorativeElements: [
        'padlock',
        'green_star',
        'teal_circle',
        'purple_circle',
      ],
    ),
    OnboardingPage(
      title: 'Cash out',
      subtitle: 'Withdraw instantly to banks and mobile wallets.',
      description: 'Your money is always available when you need it.',
      illustrationPath: 'assets/icons/svgs/swap.svg',
      decorativeElements: ['hand_stopwatch'],
    ),
  ];
}
