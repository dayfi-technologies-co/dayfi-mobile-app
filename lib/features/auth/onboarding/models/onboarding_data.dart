import 'onboarding_page.dart';

class OnboardingData {
  static const List<OnboardingPage> pages = [
    OnboardingPage(
      title: 'Send money to those who matter',
      subtitle:
          'Make international transfers to local bank accounts and mobile money wallets.',
      description:
          'Empower your relationships with seamless financial connections worldwide.',
      illustrationPath: 'assets/icons/svgs/Box.svg',
      decorativeElements: ['purple_starburst', 'green_starburst'],
    ),
    OnboardingPage(
      title: '20+\ncountries, 15 currencies',
      subtitle: 'Send money to your recipients in their local currency.',
      description:
          'Experience global connectivity with local banking convenience.',
      illustrationPath: 'assets/icons/svgs/Card.svg',
      decorativeElements: ['purple_starburst', 'green_starburst'],
    ),
    OnboardingPage(
      title: 'Safe and secure transfers',
      subtitle:
          'Your transactions and personal data are securely protected.',
      description:
          'Your financial data stays private with enterprise-level security measures.',
      illustrationPath: 'assets/icons/svgs/Others.svg',
      decorativeElements: [
        'padlock',
        'green_star',
        'teal_circle',
        'purple_circle',
      ],
    ),
    OnboardingPage(
      title: 'Send\nmoney in minutes',
      subtitle: 'Recipients typically receive funds almost instantly.',
      description: 'Experience the speed of modern financial technology.',
      illustrationPath: 'assets/icons/svgs/Transfer.svg',
      decorativeElements: ['hand_stopwatch'],
    ),
  ];
}
