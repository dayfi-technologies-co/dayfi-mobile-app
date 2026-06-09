import 'package:dayfi/features/web/models/legal_document.dart';

const termsLegalDocument = LegalDocument(
  id: LegalDocumentId.terms,
  pageTitle: 'Terms of Use',
  subtitle:
      'The rules and guidelines for using DayFi as an individual — including sending money, paying bills, multi-currency wallets, stablecoins, and other features where available.',
  effectiveDate: 'Effective date: 11 May 2026',
  sections: [
    LegalSection(
      number: '01',
      title: 'Introduction',
      paragraphs: [
        'Welcome to DayFi Technologies Inc. ("DayFi," "we," "our," or "us"). These Terms of Use ("Terms") govern your access to and use of our products and services, including the DayFi website, mobile application, APIs, webhooks, and all related tools (collectively, the "Services").',
        'DayFi is a personal finance application for individuals. We help you send money across Africa, hold multi-currency balances, pay everyday bills, set personal budgets, and save with products such as Daily Earn. Our platform may integrate NGN virtual accounts and bank payouts through Flutterwave, optional stablecoin settlement (for example Stellar USDC and supported EVM paths), tap-to-pay on compatible devices, and additional payment experiences as we expand. Some capabilities are limited to certain regions, verification levels, or device types, and may be marked coming soon or beta until we announce general availability.',
        'By creating an account, accessing, or using the Services in any way, you agree to be bound by these Terms and our Privacy Notice, which is incorporated by reference. If you do not agree to these Terms, do not create an account or use the Services. If you are using the Services on behalf of a business or legal entity, you represent that you have the authority to bind that entity to these Terms.',
      ],
    ),
    LegalSection(
      number: '02',
      title: 'Eligibility',
      paragraphs: [
        'To use the Services you must:',
        '• Be at least 18 years old, or the age of legal majority in your jurisdiction, whichever is higher.',
        '• Have the full legal capacity to enter into a binding contract.',
        '• Not be prohibited from receiving the Services under the laws of your country or any other applicable jurisdiction, including under sanctions, export control, or anti-money-laundering (AML) laws applicable to you or to DayFi.',
        '• Complete any identity verification, know-your-customer (KYC), or onboarding steps that we require for your region, product tier, or specific payment feature—including Flutterwave-led checks required to issue and operate a dedicated NGN virtual account.',
        'We reserve the right to decline or revoke access for any person or entity that does not meet these criteria, or that we believe poses a risk to the platform, other users, or compliance with applicable law.',
      ],
    ),
    LegalSection(
      number: '03',
      title: 'Accounts, onboarding, and verification',
      paragraphs: [
        'You must provide accurate, current, and complete information during registration and account management, and keep it updated. Providing false or misleading information is grounds for immediate suspension or termination.',
        'When you enable NGN virtual-account features, we collect the details required for Flutterwave to issue and maintain your VA. This may include your legal name and Bank Verification Number (BVN). BVN is transmitted to Flutterwave securely for VA issuance; retention of raw BVN in DayFi systems may occur only when explicitly enabled in our operating environment and is handled in encrypted form as described in our Privacy Notice.',
        'We may verify the identity of account holders directly or through trusted third parties, apply transaction or feature limits based on your verification level, and request additional documentation at any time if we have compliance or risk concerns.',
        'You are responsible for maintaining the confidentiality of your account credentials and for all activity that occurs under your account. Notify us immediately at support@dayfi.co if you believe your account has been compromised.',
        'We may suspend or restrict your account if information is false, incomplete, or inconsistent with our risk or compliance requirements; if we suspect fraudulent, abusive, or prohibited activity; or if required by law, regulation, or a partner\'s rules.',
      ],
    ),
    LegalSection(
      number: '04',
      title: 'Services overview',
      paragraphs: [
        'DayFi provides personal financial services for individual users. The Services may include, depending on your region and verification tier:',
        '• Multi-currency wallet: Holding and viewing balances in supported currencies such as USD, NGN, GBP, and EUR.',
        '• Send money: Transferring funds to bank accounts, mobile money, DayFi IDs, or supported digital rails across African and other corridors.',
        '• Add money: Funding your wallet by bank transfer, stablecoin deposit, or other supported top-up methods.',
        '• Pay bills: Paying airtime, mobile data, TV, internet, utilities, and other bill categories where available.',
        '• Budgets: Setting personal spending limits, scheduling repeat transfers, and receiving bill or budget reminders.',
        '• Daily Earn: Named savings pots that accrue daily interest, subject to product terms shown in the app.',
        '• Transaction history and notifications: Reviewing past activity and receiving alerts for payments, security events, and product updates.',
        'Payment experiences may include, where available and supported: NGN bank transfer to a Flutterwave-issued virtual account; outbound NGN bank withdrawals routed through Flutterwave; stablecoin settlement paths (including Stellar USDC and EVM-network flows we support); bill payments; and tap-to-pay or NFC-based checkout on compatible devices.',
        'Not every payment path is available in every market, on every device, or at every verification level. Labels such as coming soon, limited access, or beta may apply until we announce general availability.',
      ],
    ),
    LegalSection(
      number: '05',
      title: 'Prohibited uses',
      paragraphs: [
        'You may not use the Services for any purpose that is unlawful, deceptive, harmful, or inconsistent with these Terms. Prohibited activities include but are not limited to:',
        '• Money laundering, terrorist financing, proliferation financing, or any transaction that violates sanctions administered by OFAC, the UN Security Council, or any other applicable authority.',
        '• Fraud, identity theft, phishing, or any scheme to deceive other users, customers, or DayFi itself.',
        '• Processing payments for illegal goods or services, or for any activity prohibited by applicable law in your jurisdiction.',
        '• Circumventing, disabling, or interfering with security features, rate limits, or access controls of the Services.',
        '• Using the Services to transmit malware, unauthorized scripts, or data scrapers.',
        '• Impersonating DayFi, Flutterwave, or any other person or entity.',
        '• Structuring transactions to avoid reporting obligations or transaction limits.',
        'We may suspend or terminate access without prior notice if we detect or reasonably suspect prohibited use, and we reserve the right to cooperate with law enforcement, regulators, and financial institutions as required or permitted by applicable law.',
      ],
    ),
    LegalSection(
      number: '06',
      title: 'Fees and charges',
      paragraphs: [
        'DayFi and its partners may charge fees in connection with the Services. These may include transaction fees on sales processed through the platform, foreign exchange spreads or conversion fees where applicable, withdrawal or payout fees for NGN bank transfers or stablecoin movements, and subscription or access fees for premium features.',
        'Where a fee applies to a specific action, we aim to display the fee or a clear estimate before you confirm that action—for example, before you confirm a payout request or select a checkout rail.',
        'Third parties—including banks, card networks, blockchain validators, or gas networks—may impose separate fees or minimums beyond our control. These are not our fees and we may not be able to predict or display them in advance.',
        'All fees are non-refundable except where required by law or as otherwise stated in writing by DayFi. We may update our fee schedule from time to time and will provide reasonable notice of material changes.',
      ],
    ),
    LegalSection(
      number: '07',
      title: 'Transaction limits and holds',
      paragraphs: [
        'We may impose limits on transaction size, daily or monthly volume, withdrawal amounts, or stablecoin flows based on your verification level, risk profile, partner rules, or applicable law. These limits may be adjusted at any time to protect the integrity of the platform or to comply with regulatory requirements.',
        'We may place holds on funds pending settlement, dispute resolution, verification, fraud investigation, or compliance review. During a hold, you may not be able to access or withdraw the affected funds. We will notify you of holds where permitted and resolve them as promptly as practicable.',
        'If you believe a limit or hold has been applied in error, contact support@dayfi.co with your account details and a description of the issue.',
      ],
    ),
    LegalSection(
      number: '08',
      title: 'Risk disclosure',
      paragraphs: [
        'Using the Services involves certain risks that you should understand:',
        '• NGN payment rails: Inbound bank transfers and Flutterwave-mediated payouts depend on the availability and accuracy of third-party banking infrastructure. Timing, settlement windows, and success of specific transfers may vary and are not fully within our control.',
        '• Stablecoin and on-chain settlement: Blockchain transactions are irreversible once confirmed. Stablecoin values, while designed to be stable, may deviate from their peg in extreme market conditions. On-chain data is publicly visible and permanent. Regulatory treatment of digital assets varies by jurisdiction and may change.',
        '• Device-based checkout (tap-to-pay, NFC): These flows depend on device hardware, operating system version, permissions granted by the user, and third-party certifications. Availability does not imply certification for every use case or compliance with every local standard.',
        '• Security: While we implement strong security controls, no system is perfectly secure. Unauthorized access to your account, device compromise, or social engineering attacks could result in loss of funds or data. You are responsible for securing the devices and credentials used with DayFi.',
        '• Regulatory and legal risk: The regulatory environment for payments, stablecoins, and digital financial services is evolving. Changes in law or regulation could affect the availability of specific features or the terms on which we can offer the Services.',
      ],
    ),
    LegalSection(
      number: '09',
      title: 'Privacy and data handling',
      paragraphs: [
        'Your use of the Services is also governed by our Privacy Notice, which is incorporated into these Terms by reference. The Privacy Notice explains in detail how we collect, use, share, and protect your personal data—including data processed with Flutterwave for NGN banking, data observable on public blockchain networks when you use stablecoin rails, and device data used for tap-to-pay and related experiences.',
        'By using the Services, you consent to our data practices as described in the Privacy Notice. If you have questions about your data or wish to exercise your data rights, contact privacy@dayfi.co.',
      ],
    ),
    LegalSection(
      number: '10',
      title: 'Intellectual property',
      paragraphs: [
        'The Services, including our software, website, app, APIs, branding, trademarks, and all content we create, are owned by DayFi Technologies Inc. or our licensors and are protected by applicable intellectual property laws.',
        'We grant you a limited, non-exclusive, non-transferable, revocable license to use the Services solely for your internal business purposes and in accordance with these Terms. You may not copy, modify, distribute, sell, sublicense, reverse engineer, or create derivative works based on the Services or any part of them without our prior written consent.',
        'Any feedback, suggestions, or ideas you share with us about the Services may be used by us without restriction or compensation to you. You retain ownership of the content you upload (such as saved recipients or profile information), and you grant us a limited license to process and display that content as necessary to provide the Services.',
      ],
    ),
    LegalSection(
      number: '11',
      title: 'Suspension and termination',
      paragraphs: [
        'We may suspend or terminate your access to the Services at any time, with or without prior notice, if you breach these Terms, if required by law or a partner\'s compliance requirements, or for risk, fraud, or security reasons.',
        'You may stop using the Services at any time. To close your account, contact support@dayfi.co. Closure of your account does not relieve you of obligations that arose prior to termination, including any fees owed, chargebacks, or indemnification obligations.',
        'Certain provisions of these Terms survive termination, including Sections 5, 8, 10, 12, 13, and 14, as well as any provisions that by their nature should survive.',
      ],
    ),
    LegalSection(
      number: '12',
      title: 'Disclaimer and limitation of liability',
      paragraphs: [
        'The Services are provided on an \'as-is\' and \'as-available\' basis without warranties of any kind. To the maximum extent permitted by applicable law, DayFi expressly disclaims all implied warranties, including warranties of merchantability, fitness for a particular purpose, non-infringement, and accuracy.',
        'We do not warrant that the Services will be uninterrupted, error-free, or free from harmful components; that defects will be corrected; or that third-party services (including Flutterwave\'s banking infrastructure or blockchain networks) will meet your expectations.',
        'To the maximum extent permitted by law, DayFi, its directors, officers, employees, and agents are not liable for any indirect, incidental, special, consequential, or punitive damages, or for lost profits, lost revenue, lost data, or business interruption, arising out of or related to your use of or inability to use the Services—even if we have been advised of the possibility of such damages.',
        'Where liability cannot be fully excluded, our aggregate liability arising out of or related to these Terms or the Services is limited to the greater of: (a) the total fees you paid DayFi for the Services in the three (3) calendar months immediately preceding the event giving rise to the claim, or (b) one hundred US dollars (US\$100). This limitation applies to all causes of action in aggregate, not per incident.',
        'Nothing in these Terms limits liability that cannot be excluded or limited under applicable law—including liability for death or personal injury caused by negligence, or for fraud or fraudulent misrepresentation.',
      ],
    ),
    LegalSection(
      number: '13',
      title: 'Indemnification',
      paragraphs: [
        'You agree to indemnify, defend, and hold harmless DayFi Technologies Inc. and its officers, directors, employees, contractors, affiliates, and licensors from and against any claims, liabilities, damages, losses, and expenses (including reasonable legal fees) arising from: (a) your use of the Services in violation of these Terms; (b) your violation of any applicable law or third-party rights; (c) the content or data you submit to the Services; or (d) any dispute between you and your customers or business partners.',
        'We reserve the right to assume exclusive control of any matter subject to indemnification, in which case you agree to cooperate with us in asserting available defenses.',
      ],
    ),
    LegalSection(
      number: '14',
      title: 'Governing law and disputes',
      paragraphs: [
        'For users located in Nigeria: These Terms are governed by the laws of the Federal Republic of Nigeria, without regard to conflict-of-law rules. Disputes shall first be referred to good-faith negotiation; if unresolved within 30 days, either party may refer the dispute to the appropriate court or tribunal with jurisdiction in Nigeria.',
        'For users located outside Nigeria: These Terms are governed by the laws of the State of Delaware, United States, excluding its conflict-of-law rules. Subject to applicable law, you agree to submit to the exclusive jurisdiction of state or federal courts located in Delaware for any dispute not subject to binding arbitration or another mandatory dispute resolution forum.',
        'Nothing in this section limits rights you cannot waive under mandatory consumer protection laws applicable in your country of residence.',
      ],
    ),
    LegalSection(
      number: '15',
      title: 'Changes to these Terms',
      paragraphs: [
        'We may update these Terms as our Services, partners, or legal obligations change. We will post the updated Terms on our website and within the app, updating the effective date at the top.',
        'Where changes are material, we will provide additional notice—such as an in-app notification or email—when practicable. Your continued use of the Services after the effective date of updated Terms constitutes your acceptance of the changes, except where your separate, explicit consent is required by law.',
        'If you do not agree to updated Terms, you must stop using the Services and contact us to close your account.',
      ],
    ),
    LegalSection(
      number: '16',
      title: 'Contact us',
      paragraphs: [
        'Questions or concerns about these Terms or the Services:',
        'General support and account issues: support@dayfi.co',
        'Privacy and data rights: privacy@dayfi.co',
      ],
    ),
  ],
);
