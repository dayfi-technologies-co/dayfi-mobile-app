import 'package:dayfi/routes/route.dart';
import 'package:flutter/material.dart';

/// Marketing copy for the public web landing page (individual users).
abstract final class LandingCopy {
  LandingCopy._();

  // Announcement
  static const announcementText =
      'We\'ve secured our microfinance banking license in Nigeria — our home market 🎉.';
  static const announcementCta = 'See what this means for you →';

  // Nav
  static const navContact = 'Contact us';
  static const navFaqs = 'FAQs';
  static const navLogin = 'Login';
  static const navSignUp = 'Sign up';

  static const brandName = 'DayFi';

  // Hero
  static const heroLine1 = 'Your global wallet';
  static const heroLine2 = 'for';
  static const heroLine3 = 'Africa';
  static const heroSubtitle =
      'Send money worldwide, pay airtime and bills, hold USD and NGN, set personal budgets, and grow savings with Daily Earn — all in one app built for everyday people.';
  static const heroSubtitleShort =
      'Make international transfers to local bank accounts, mobile money and crypto wallets — pay airtime and bills, earn on savings, and smartly budget and automate your spending — all from one multi-currency wallet.';

  static const qrTitle = 'Get the DayFi app';
  static const qrSubtitle =
      'Scan to download. Available on the App Store and Google Play.';
  static const heroQrScanText =
      'Scan to download app.\nAvailable on App Store and Google Play.';
  static const qrUrl = 'https://dayfi.co';

  // Transfer preview (illustrative cross-border send)
  static const previewYouSendLabel = 'You send';
  static const previewReceiverGetsLabel = 'They receive';
  static const previewFeeLabel = 'Fee';
  static const previewTotalLabel = 'Total';
  static const previewRateLabel = 'Rate';
  static const previewDeliveryMethodLabel = 'Delivery';
  static const previewYouSendSymbol = '\$';
  static const previewReceiverSymbol = '₦';
  static const previewYouSend = '100.00';
  static const previewYouSendCurrency = 'USD';
  static const previewFee = 'FREE';
  static const previewSendCta = 'Send money';
  static const previewTotal = '100.00 USD';
  static const previewRate = '1 USD = 1,580.00 NGN';
  static const previewReceiverGets = '158,000.00';
  static const previewReceiverCurrency = 'NGN';
  static const previewDeliveryMethod = 'Bank account';

  // Value highlights
  static const deliveryHighlights = <LandingHighlightBlock>[
    LandingHighlightBlock(
      title: 'More than a transfer app',
      body:
          'DayFi is the single place where your money lives. Hold multiple currencies, move funds to any bank or mobile money account, pay your bills, and get full visibility into every transaction in real time.',
      icon: 'assets/icons/svgs/swap.svg',
    ),
    LandingHighlightBlock(
      title: 'Candor, every transfer',
      body:
          'See the exact fee, live exchange rate, and estimated arrival time before you confirm anything. No fine print, no last minute surprises. What you review is what happens, every single time.',
      icon: 'assets/icons/svgs/transactions.svg',
    ),
  ];

  // Core capabilities
  static const deliveryMethodsTitle =
      'One wallet for how you actually use money.';
  static const deliveryMethods = <LandingDeliveryMethod>[
    LandingDeliveryMethod(
      title: 'Send worldwide',
      description:
          'Transfer to local bank accounts and mobile money across Africa and beyond. Save recipients and repeat sends in seconds.',
      iconName: 'bank',
    ),
    LandingDeliveryMethod(
      title: 'Pay via username',
      description:
          'Send instantly to another DayFi user with their @username. No account numbers needed. Share yours to get paid the same way.',
      iconName: 'id',
    ),
    LandingDeliveryMethod(
      title: 'Pay bills',
      description:
          'Top up airtime and data, pay cable TV, internet, and utilities from your global balance without switching apps.',
      iconName: 'bills',
    ),
  ];

  // Security
  static const securityTitle = 'Built on regulated rails';
  static const securitySubtitle =
      'DayFi connects you to licensed infrastructure — including Flutterwave for NGN payments and Smile ID for identity verification — so your money moves on systems built for scale and compliance.';
  static const securityBadges = <LandingSecurityBadge>[
    LandingSecurityBadge(
      title: 'Licensed NGN infrastructure',
      description:
          'All NGN deposits and withdrawals are handled by Flutterwave, a CBN regulated payment infrastructure that businesses across Africa rely on every day.',
    ),
    LandingSecurityBadge(
      title: 'Identity you can trust',
      description:
          'Smile ID powers your identity verification. On top of that, your passcode, transaction PIN, and optional biometrics all have to clear before any money moves.',
    ),
  ];

  // How it works (4 steps)
  static const howItWorksTitle = 'Get started in minutes';
  static const howItWorksSubtitle =
      'Create your DayFi account on web or mobile, verify once, then send, pay bills, budget, and save from the same wallet.';
  static const howItWorksSteps = <LandingStep>[
    LandingStep(number: '1', title: 'Sign up with your email', body: ''),
    LandingStep(number: '2', title: 'Verify your identity', body: ''),
    LandingStep(
      number: '3',
      title: 'Fund your wallet and move money',
      body: '',
    ),
    LandingStep(
      number: '4',
      title: 'Track sends, bills, and savings live',
      body: '',
    ),
  ];

  // Testimonials
  static const testimonialsTitle = 'What our users are saying';
  static const testimonials = <LandingTestimonial>[
    LandingTestimonial(
      quote:
          'USD and NGN in one app, DSTV paid in seconds. The rate is always clear before I confirm.',
      name: 'Amara O.',
      location: 'London, UK',
    ),
    LandingTestimonial(
      quote:
          'Friends pay me via @username and I cash out instantly. Bills and airtime take seconds.',
      name: 'David K.',
      location: 'Lagos, Nigeria',
    ),
    LandingTestimonial(
      quote:
          'Daily Earn keeps me saving and DayFlow tracks my spending. One money app, not five.',
      name: 'Zainab M.',
      location: 'Abuja, Nigeria',
    ),
  ];

  // FAQ
  static const faqTitle = 'Frequently asked questions';
  static const faqSupportCta =
      'Visit our full FAQ or contact support if you have more questions.';
  static const faqs = <LandingFaq>[
    LandingFaq(
      question: 'What is DayFi?',
      answer:
          'DayFi is a personal finance app for individuals — not businesses. You get a multi-currency wallet to send money across borders, pay bills, set budgets, automate spending with DayFlow, and save with Daily Earn. Everything is designed around how everyday people move, spend, and grow money.',
    ),
    LandingFaq(
      question: 'Who is DayFi for?',
      answer:
          'DayFi is built for people in Nigeria and Africans in cross-border contexts — anyone who sends to family abroad, receives funds from overseas, pays local bills, or wants USD, NGN, and stablecoin balances in one honest wallet.',
    ),
    LandingFaq(
      question: 'How do I add money to DayFi?',
      answer:
          'Fund your wallet by bank transfer to your dedicated NGN virtual account (where available), stablecoin deposit on supported networks including Stellar USDC, or other methods shown in the app. Available paths depend on your verification level and market.',
    ),
    LandingFaq(
      question: 'What is Daily Earn?',
      answer:
          'Daily Earn lets you create named savings pots that accrue interest daily. Add from your USD wallet, watch it grow, and withdraw back to your balance anytime — no lock-in penalty.',
    ),
    LandingFaq(
      question: 'Is DayFi safe?',
      answer:
          'Security is core to how we build. NGN payment rails run through licensed partner Flutterwave. Identity checks use Smile ID. You control access with a passcode, transaction PIN, and optional Face ID or fingerprint. We never promise what our partners and regulators have not approved.',
    ),
    LandingFaq(
      question: 'How fast are DayFi transfers?',
      answer:
          'Most transfers complete within minutes. Depending on your corridor and delivery method, funds can reach bank accounts, mobile money wallets, or another DayFi user quickly — you can track status in real time from the app.',
    ),
    LandingFaq(
      question: 'What are the transfer fees?',
      answer:
          'DayFi shows exact fees and rates before you confirm any send. Pricing is transparent — no hidden charges. Fees depend on corridor, amount, and payment method shown in the app.',
    ),
    LandingFaq(
      question: 'What is USDC and why does DayFi use it?',
      answer:
          'USDC is a stablecoin pegged 1:1 to the US dollar. DayFi uses it on supported rails to move value quickly and keep your balance stable while transfers are in flight.',
    ),
    LandingFaq(
      question: 'Which countries can I send money to?',
      answer:
          'DayFi supports sends to Nigeria, Kenya, Ghana, South Africa, and expanding corridors across Africa, the UK, US, and Europe. Open the Send flow in the app to see live destinations for your account.',
    ),
    LandingFaq(
      question: 'How do I contact DayFi support?',
      answer:
          'Reach us via in-app chat, email at support@dayfi.co, or the Contact us link on this site. We are here to help with account, transfer, and verification questions.',
    ),
  ];

  // Final CTA
  static const finalCtaTitle = 'Open your global wallet';
  static const finalCtaButton = 'Create your free account';

  // Footer
  static const footerCompanyTitle = 'Company';
  static const footerSupportTitle = 'Support';
  static const footerLegalTitle = 'Legal';
  static const footerSendTitle = 'Send money';
  static const footerQrScanText =
      'Scan to download app.\nAvailable on App Store and Google Play.';
  static String footerCopyright(int year) => '© DayFi $year';

  static const footerSocialPills = <LandingFooterSocialPill>[
    LandingFooterSocialPill(
      label: 'INSTAGRAM',
      url: 'https://instagram.com/dayfi',
      backgroundColor: Color(0xFFE84362),
      foregroundColor: Colors.white,
      rotationDegrees: 16,
    ),
    LandingFooterSocialPill(
      label: 'FACEBOOK',
      url: 'https://facebook.com/dayfi',
      backgroundColor: Color(0xFF3B6FE8),
      foregroundColor: Colors.white,
      rotationDegrees: -8,
    ),
    LandingFooterSocialPill(
      label: 'TIKTOK',
      url: 'https://tiktok.com/@dayfi',
      backgroundColor: Color(0xFF4CD964),
      foregroundColor: Color(0xFF0A0A0A),
      rotationDegrees: 24,
    ),
    LandingFooterSocialPill(
      label: 'TWITTER',
      url: 'https://x.com/dayfi',
      backgroundColor: Color(0xFFF5F0E8),
      foregroundColor: Color(0xFF0A0A0A),
      rotationDegrees: -14,
    ),
  ];

  static const footerCompanyLinks = <LandingFooterLink>[
    LandingFooterLink('About DayFi', AppRoute.webAboutPath),
    LandingFooterLink('Security', AppRoute.webSecurityPath),
    LandingFooterLink('Government', AppRoute.webGovernmentPath),
  ];

  static const footerSupportLinks = <LandingFooterLink>[
    LandingFooterLink('Contact us', '_contact'),
    LandingFooterLink('FAQs', AppRoute.webFaqPath),
  ];

  static const footerLegalLinks = <LandingFooterLink>[
    LandingFooterLink('Terms of use', AppRoute.webTermsPath),
    LandingFooterLink('Privacy Notice', AppRoute.webPrivacyPath),
    LandingFooterLink('Cookie Notice', AppRoute.webPrivacyPath),
    LandingFooterLink('Cookie settings', '_cookie_settings'),
  ];

  static const footerSendLinks = <LandingFooterLink>[
    LandingFooterLink('Send from UK 🇬🇧 to Nigeria 🇳🇬', AppRoute.signupPath),
    LandingFooterLink('Send from US 🇺🇸 to Nigeria 🇳🇬', AppRoute.signupPath),
  ];

  static const footerPagePills = <LandingFooterPagePill>[
    LandingFooterPagePill(
      label: 'ABOUT',
      route: AppRoute.webAboutPath,
      backgroundColor: Color(0xFFE84362),
      foregroundColor: Colors.white,
      rotationDegrees: -14,
    ),
    LandingFooterPagePill(
      label: 'SECURITY',
      route: AppRoute.webSecurityPath,
      backgroundColor: Color(0xFF3B6FE8),
      foregroundColor: Colors.white,
      rotationDegrees: 10,
    ),
    LandingFooterPagePill(
      label: 'FAQs',
      route: AppRoute.webFaqPath,
      backgroundColor: Color(0xFF4CD964),
      foregroundColor: Color(0xFF0A0A0A),
      rotationDegrees: 18,
    ),
    LandingFooterPagePill(
      label: 'SIGN UP',
      route: AppRoute.signupPath,
      backgroundColor: Color(0xFFF5F0E8),
      foregroundColor: Color(0xFF0A0A0A),
      rotationDegrees: -10,
    ),
    LandingFooterPagePill(
      label: 'TERMS',
      route: AppRoute.webTermsPath,
      backgroundColor: Color(0xFFFF6B2C),
      foregroundColor: Colors.white,
      rotationDegrees: 8,
    ),
    LandingFooterPagePill(
      label: 'PRIVACY',
      route: AppRoute.webPrivacyPath,
      backgroundColor: Color(0xFF7A30E9),
      foregroundColor: Colors.white,
      rotationDegrees: -16,
    ),
  ];

  static const footerLegalFinePrint = <String>[
    'DayFi Technologies Inc. is a financial technology company. We are not a bank. DayFi is incorporated in the United States (Delaware). Our primary market is Nigeria.',
    'NGN virtual account collection and outbound bank payouts are coordinated with Flutterwave, a payment infrastructure licensed by the Central Bank of Nigeria (CBN). Flutterwave processes inbound bank transfers and outbound NGN payouts you initiate from DayFi.',
    'Stablecoin settlement paths may use public blockchain networks, including Stellar USDC and supported EVM flows. On-chain transactions are public and irreversible once confirmed.',
    'DayFi conducts know-your-customer and anti-money-laundering checks appropriate to the products you use. Not every feature is available in every market or at every verification level.',
    'General support: support@dayfi.co · Privacy enquiries: privacy@dayfi.co',
  ];

  // Cookies
  static const cookieMessage =
      'We use cookies to improve your experience on dayfi.co. You can accept all cookies or reject non-essential ones.';
  static const cookieAccept = 'Accept all';
  static const cookieReject = 'Reject all';
}

class LandingHighlightBlock {
  const LandingHighlightBlock({
    required this.title,
    required this.body,
    required this.icon,
  });
  final String title;
  final String body;
  final String icon;
}

class LandingDeliveryMethod {
  const LandingDeliveryMethod({
    required this.title,
    required this.description,
    required this.iconName,
  });
  final String title;
  final String description;
  final String iconName;
}

class LandingSecurityBadge {
  const LandingSecurityBadge({required this.title, required this.description});
  final String title;
  final String description;
}

class LandingStep {
  const LandingStep({
    required this.number,
    required this.title,
    required this.body,
  });
  final String number;
  final String title;
  final String body;
}

class LandingTestimonial {
  const LandingTestimonial({
    required this.quote,
    required this.name,
    required this.location,
  });
  final String quote;
  final String name;
  final String location;
}

class LandingFaq {
  const LandingFaq({required this.question, required this.answer});
  final String question;
  final String answer;
}

class LandingFooterLink {
  const LandingFooterLink(this.label, this.route);
  final String label;
  final String route;
}

class LandingFooterPagePill {
  const LandingFooterPagePill({
    required this.label,
    required this.route,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.rotationDegrees,
  });

  final String label;
  final String route;
  final Color backgroundColor;
  final Color foregroundColor;
  final double rotationDegrees;
}

class LandingFooterSocialPill {
  const LandingFooterSocialPill({
    required this.label,
    required this.url,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.rotationDegrees,
  });

  final String label;
  final String url;
  final Color backgroundColor;
  final Color foregroundColor;
  final double rotationDegrees;
}
