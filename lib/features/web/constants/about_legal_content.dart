import 'package:dayfi/features/web/models/legal_document.dart';

const aboutLegalDocument = LegalDocument(
  id: LegalDocumentId.about,
  pageTitle: 'About DayFi',
  subtitle:
      'We build an AI-powered personal finance app — DayX guides you in plain language to send, pay bills, automate with DayFlow, and save with DayEarn, on regulated rails where available.',
  effectiveDate: 'Last updated: 11 May 2026',
  sections: [
    LegalSection(
      number: '01',
      title: 'Who we are',
      paragraphs: [
        'DayFi Technologies Inc. (DayFi) is a financial technology company building a personal wallet and money-movement app for individuals who send money across Africa, pay everyday bills, and manage their finances in one place.',
        'We were founded on the belief that people in Nigeria—and in cross-border contexts where Africa plays a central role—deserve infrastructure that is honest about how money moves, clear about fees and timing, and built on regulated rails rather than workarounds. We are not a bank. We are a technology layer that connects you to licensed infrastructure that is.',
        'Our team has experience across payments, fintech product design, and regulated financial services. We build with compliance as a constraint from day one, not as an afterthought applied at the end.',
      ],
    ),
    LegalSection(
      number: '02',
      title: 'What DayFi does',
      paragraphs: [
        'DayFi is an AI-powered personal finance app for individuals—not a business-only POS or merchant gateway. It is designed around how everyday people send, receive, spend, and save money.',
        'At its core, DayFi gives you:',
        '• DayX — your AI guide to send, pay bills, check balances, and open savings or budgets in plain language.',
        '• DayFlow — automate repeat sends and bill payments on a schedule, powered by DayX.',
        '• A multi-currency wallet to hold USD, NGN, and other supported balances in one account.',
        '• Send money to family, friends, and recipients across Africa via bank transfer, mobile money, DayFi ID, or supported digital rails.',
        '• Add money by bank transfer, stablecoin deposit, or other supported funding methods.',
        '• Pay bills such as airtime, mobile data, cable TV, internet, and utilities from your global balance.',
        '• Personal budgets to cap spending, schedule repeat transfers, and get reminders before bills or sends are due.',
        '• DayEarn savings pots that accrue daily interest, with flexible withdrawals.',
        '• A clear transaction history and real-time notifications so you always know when money moves.',
        'Payment paths available or in development include NGN bank transfer to a dedicated Flutterwave virtual account, outbound NGN bank withdrawals, stablecoin settlement (including Stellar USDC and supported EVM-network paths), bill payments, and tap-to-pay on compatible devices. Not every path is available in every market, at every verification level, or on every device. We label features clearly as live, limited access, or coming soon so you can plan accordingly.',
      ],
    ),
    LegalSection(
      number: '03',
      title: 'Our infrastructure partners',
      paragraphs: [
        'DayFi does not hold a banking license. We build on top of regulated partners who do.',
        'Flutterwave is our primary partner for NGN payment infrastructure. When you enable virtual-account features, Flutterwave issues and operates the dedicated NGN virtual account associated with your DayFi profile. Inbound bank transfers are received by Flutterwave and notified to DayFi via webhook; outbound NGN bank payouts you initiate from DayFi are routed through Flutterwave\'s payout infrastructure. Flutterwave is a licensed financial institution regulated by the Central Bank of Nigeria (CBN) and holds licenses in multiple additional jurisdictions.',
        'For stablecoin settlement paths, we use public blockchain networks—including the Stellar network for USDC flows and supported EVM networks. On-chain transactions are public and irreversible once confirmed. We monitor for on-chain confirmations and credit your DayFi wallet accordingly.',
        'We work with additional technology and infrastructure partners for hosting, notifications, identity verification, and other services. See our Privacy Notice for categories of sub-processors and the data they may touch.',
        'Our partnership model is built around transparency: we aim to describe, in product copy and legal documents, which partner is responsible for which part of any given flow, so you know where to look if something needs resolution.',
      ],
    ),
    LegalSection(
      number: '04',
      title: 'Our approach to trust and compliance',
      paragraphs: [
        'Financial products earn trust by being clear, not by being clever. Our product copy and legal documents are written to tell you what actually happens with your money—not to create impressions that do not hold up under scrutiny.',
        'We conduct know-your-customer (KYC) and anti-money-laundering (AML) checks appropriate to the products you use and the jurisdiction you are in. For NGN virtual account features, this includes collecting and transmitting your BVN to Flutterwave as part of the onboarding process they require. We do not collect more than we need, and we handle what we do collect in line with our Privacy Notice.',
        'We are not subject to every regulation in every jurisdiction. Where we operate in a regulated space, we aim to meet applicable requirements and to work with partners who are themselves regulated. Where the regulatory framework is unclear or evolving—for example in relation to stablecoin settlement—we take a conservative posture and describe that uncertainty to you rather than asserting certainty we do not have.',
        'We reserve the right to decline onboarding, restrict features, or close accounts where we are required to by law or partner obligations, or where we have reasonable compliance or risk concerns. We will always try to communicate clearly about what is happening and why, within the limits the law allows.',
      ],
    ),
    LegalSection(
      number: '05',
      title: 'Transparency about what is live',
      paragraphs: [
        'DayFi is an active product under development. Some features described in our documentation, on our website, or in this page are in staged rollout, available only to specific account types, or marked coming soon. We label these as precisely as we can in the product interface itself.',
        'We do not believe in vaporware. Every feature we describe as coming soon is something we are actively building or integrating. But until a feature is labeled live for your account, do not depend on it for production transactions.',
        'If you are unsure whether a specific payment path, limit, or feature is active for your account, the most reliable source is the DayFi app itself, followed by our support team at support@dayfi.co.',
      ],
    ),
    LegalSection(
      number: '06',
      title: 'Geographic scope',
      paragraphs: [
        'DayFi\'s primary market is Nigeria. Our NGN virtual account infrastructure, outbound bank transfer paths, and regulatory relationships are designed with Nigerian users in mind.',
        'We also support individuals in cross-border contexts—for example, people who receive funds from abroad, send money to family across Africa, or want to hold and convert between NGN, USD, and stablecoins. These use cases are supported where our payment paths and partner capabilities allow, but they are subject to additional verification requirements and may be limited by applicable law in your or your recipient\'s jurisdiction.',
        'DayFi Technologies Inc. is incorporated in the United States (Delaware). Our operations and primary user base are in Nigeria. Our Terms of Use provide jurisdiction-specific governing law provisions for Nigerian and non-Nigerian users.',
      ],
    ),
    LegalSection(
      number: '07',
      title: 'Contact us',
      paragraphs: [
        'We are a small, focused team. The best way to reach us is:',
        'General support and account issues: support@dayfi.co',
        'Privacy and data rights inquiries: privacy@dayfi.co',
        'We do not currently have a public press kit or a formal partnership inquiry process. If you have a partnership proposal or press inquiry, email support@dayfi.co with a brief description and we will route it appropriately.',
      ],
    ),
  ],
);
