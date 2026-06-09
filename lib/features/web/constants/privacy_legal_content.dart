import 'package:dayfi/features/web/models/legal_document.dart';

const privacyLegalDocument = LegalDocument(
  id: LegalDocumentId.privacy,
  pageTitle: 'Privacy Notice',
  subtitle:
      'How we collect, use, and protect your personal data when you use DayFi to send money, pay bills, and manage your wallet.',
  effectiveDate: 'Effective date: 11 May 2026',
  sections: [
    LegalSection(
      number: '01',
      title: 'Introduction and scope',
      paragraphs: [
        'DayFi Technologies Inc. ("DayFi," "we," "our," or "us") is committed to protecting your privacy. This Privacy Notice explains how we collect, use, disclose, retain, and protect personal data when you access or use our website, mobile applications, wallet and payment tools, APIs, and any related services (collectively, the "Services").',
        'DayFi is designed to help individuals send money, pay bills, budget, and save through a personal multi-currency wallet. That includes NGN bank collection and payouts through our banking partner Flutterwave, optional stablecoin settlement (for example Stellar USDC and supported EVM flows), and device-based experiences such as tap-to-pay on compatible hardware where available. Some features may be in limited availability or marked coming soon as we expand coverage.',
        'This Notice applies to all individuals who use DayFi\'s Services, whether as account holders or visitors to our website. If you use DayFi on behalf of a business, the same principles apply to the personal data we process for that account. It does not apply to third-party services, websites, or partners—such as Flutterwave—whose own privacy policies govern the data they hold. We encourage you to review those policies separately.',
        'By creating an account or using the Services, you acknowledge that you have read and understood this Privacy Notice. If you have questions, contact us at privacy@dayfi.co.',
      ],
    ),
    LegalSection(
      number: '02',
      title: 'Information we collect',
      paragraphs: [
        'The personal data we collect depends on how you use the Services. We aim to collect only what is necessary for us to provide and improve DayFi.',
        'Identity details: Your legal name, date of birth where required, and profile information such as your DayFi ID or username. Where you choose virtual account (VA) onboarding, we collect information required to issue a dedicated NGN VA through Flutterwave, which may include your Bank Verification Number (BVN). BVN is a sensitive identifier and is handled with particular care—it is transmitted securely to Flutterwave for VA issuance and may be stored in encrypted form in our systems only where our operating environment is explicitly configured to allow it.',
        'Contact information: Email address, phone number, and any business or mailing address you provide during registration or account management.',
        'Financial and payment data: NGN virtual account numbers and bank metadata issued by or coordinated with Flutterwave; your payout bank account details when you request withdrawals; recipient details you save for sends; stablecoin wallet addresses and on-chain transaction references (for example Stellar USDC deposits or EVM-compatible flows); bill-payment metadata; wallet balances; budget and Daily Earn records; and your transaction and ledger history within the platform.',
        'Device and technical data: Device model, operating system, app version, IP address, and session diagnostics. Where you use tap-to-pay, NFC, or similar device-based payment technology, we also process signals necessary to complete or secure the transaction on supported hardware. We may collect crash and error data to diagnose and improve the app.',
        'Usage and analytics data: How you navigate the app, features you use, settings you configure, and aggregate behavioral patterns that help us understand how the product performs. This data is typically collected using first-party instrumentation and may in future involve trusted analytics partners under data processing agreements.',
        'Communications: Messages and files you submit via in-app support, email correspondence, and authentication or delivery logs when we send you service communications.',
      ],
    ),
    LegalSection(
      number: '03',
      title: 'How we collect information',
      paragraphs: [
        'Directly from you: When you register for an account, complete identity verification, send money, pay bills, set budgets, fund your wallet, or contact our support team. You are always in control of what you provide.',
        'Automatically: When you use our app or visit our website, we may collect technical data through logs, cookies, and similar technologies. This includes information about your device, session timing, and payment status updates. We use this data primarily for security, reliability, and diagnosing issues—not for cross-site advertising.',
        'From Flutterwave: When we create or manage your NGN virtual account, reconcile inbound bank transfers, or execute outbound NGN payouts you initiate, Flutterwave provides us with transaction identifiers, status messages, and other data required to operate those payment flows accurately.',
        'From blockchain networks and indexers: Where you choose stablecoin settlement rails, we may receive confirmation data from public blockchain networks or trusted indexers to verify that a payment was received on-chain and to credit your wallet or sale record accordingly. Note that transaction data on public blockchains is visible to anyone with network access—this is a fundamental property of those networks, not a choice we make.',
        'From verification or identity services: We may work with third-party services to help validate account information or detect fraud, consistent with applicable law. Any such service is bound by a data processing agreement with us.',
      ],
    ),
    LegalSection(
      number: '04',
      title: 'How we use your information',
      paragraphs: [
        'We use your personal data for the following purposes, always based on a valid legal ground:',
        'Providing and operating the Services: This includes processing sends and top-ups, paying bills, maintaining your ledger and wallet, running budget and Daily Earn features, sending transactional notifications, and managing your account settings. This is necessary to perform our contract with you.',
        'NGN banking operations: Operating virtual account collection and outbound bank payouts through Flutterwave in accordance with their requirements and applicable Nigerian financial law. We cannot provide NGN bank rails without processing the identity and account data Flutterwave requires.',
        'Stablecoin settlement: Orchestrating optional on-chain payment flows so that you receive timely, transparent payment status. This includes communicating with blockchain networks and monitoring for confirmed inbound transactions.',
        'Device-based payment experiences: Enabling tap-to-pay, NFC, gift-card, and other checkout paths on supported hardware and software versions. These flows depend on device and OS data; we only collect what is necessary to complete or secure the transaction.',
        'Product improvement and development: Analyzing how the Services are used in aggregate to fix bugs, improve performance, and build new features. We aim to use anonymized or aggregated data for this purpose where possible.',
        'Security, fraud prevention, and compliance: Detecting and investigating suspicious activity, protecting our platform and users from unauthorized access or fraudulent transactions, and meeting our legal and regulatory obligations—including anti-money-laundering (AML) and know-your-customer (KYC) requirements in Nigeria and any other jurisdiction where we operate.',
        'Communications: Sending you service messages (for example transaction confirmations, security alerts, and policy updates), responding to your support requests, and providing guidance on using the platform. We do not send marketing messages without your consent.',
      ],
    ),
    LegalSection(
      number: '05',
      title: 'How we share your information',
      paragraphs: [
        'We do not sell your personal data as a list product. We share data only in the ways described below:',
        'Flutterwave and its banking partners: We share identity, account, and transaction data with Flutterwave strictly as required to issue and operate your NGN virtual account, match inbound transfers to the correct account, and execute outbound NGN payouts you request. Flutterwave processes this data under their own privacy policy and applicable Nigerian banking regulations.',
        'Infrastructure, hosting, and operations vendors: We use third-party providers for cloud hosting, database management, monitoring, security tooling, email delivery, and customer support software. Each provider processes data on our behalf under a data processing agreement and is not permitted to use your data for their own purposes.',
        'Analytics and diagnostics: We may share limited technical data with trusted analytics providers to understand app performance and usage patterns. We configure these integrations to minimize personal data transmission and do not use them for targeted advertising.',
        'Blockchain networks: Where you use stablecoin rails, the transaction details required to complete a payment (such as a wallet address and amount) are broadcast to public blockchain networks. This data is visible to anyone and is irreversible once confirmed—that is a structural property of blockchain technology.',
        'Regulators, courts, and law enforcement: We may disclose personal data when we believe in good faith that such disclosure is required or permitted by law, a valid court order, or a regulatory requirement applicable to DayFi or our partners. We review such requests for legal validity and will challenge overbroad requests where permitted.',
        'Business transfers: If DayFi is involved in a merger, acquisition, or sale of all or substantially all of its assets, personal data held by us may be transferred as part of that transaction. We will provide notice to affected users as required by law.',
        'Aggregated or de-identified data: We may share information that has been aggregated or de-identified in a way that cannot reasonably identify you, for purposes such as industry research, product announcements, or partnerships.',
      ],
    ),
    LegalSection(
      number: '06',
      title: 'Cookies and similar technologies',
      paragraphs: [
        'We use cookies and similar tracking technologies on our website and within the app to maintain your session, remember your preferences, ensure security, and collect aggregated usage data.',
        'Strictly necessary cookies are required for the Services to function—for example, to keep you logged in or to maintain your cart during a checkout session. You cannot opt out of these without effectively opting out of the Services themselves.',
        'Analytics and performance cookies help us understand how the product is used and where improvements can be made. These are used in aggregate and are not linked to individually identifiable profiles for advertising purposes.',
        'We do not use advertising or third-party tracking cookies. If our practices change in this area, we will update this Notice and seek your consent where required.',
        'Browser-level cookie controls are available in all modern browsers. Mobile app data is managed through operating system permissions and your in-app settings where applicable.',
      ],
    ),
    LegalSection(
      number: '07',
      title: 'Data retention',
      paragraphs: [
        'We retain personal data for as long as your account is active, and for a reasonable period afterward to address any outstanding matters, disputes, or regulatory requirements.',
        'Financial and payment records—including transaction histories, ledger entries, virtual account data, and KYC-related information—are subject to longer retention periods required by law. In Nigeria, applicable financial crime prevention, Central Bank of Nigeria (CBN) guidance, and tax regulations may require us to retain such records for five years or more after the relationship ends.',
        'Communications and support records are typically retained for a shorter period consistent with their operational purpose, unless they are part of a dispute or legal matter.',
        'When retention periods have passed, we delete or irreversibly anonymize data where technically feasible. In some cases, residual copies may persist for a short time in backup or archive systems before being permanently removed.',
      ],
    ),
    LegalSection(
      number: '08',
      title: 'Your rights and choices',
      paragraphs: [
        'Depending on your location, you may have rights under applicable data protection law. In Nigeria, the Nigeria Data Protection Act (NDPA) and regulations issued by the Nigeria Data Protection Commission (NDPC) provide data subjects with the following rights:',
        '• Right of access: You may request a copy of the personal data we hold about you.',
        '• Right to rectification: You may request that we correct inaccurate or incomplete information.',
        '• Right to erasure: You may request that we delete your personal data, subject to legal retention obligations and legitimate business needs that override erasure.',
        '• Right to restriction: You may ask us to restrict processing of your data in certain circumstances—for example, while a dispute about accuracy is pending.',
        '• Right to data portability: Where technically feasible and legally required, you may request a copy of your data in a commonly used, machine-readable format.',
        '• Right to object: You may object to processing based on our legitimate interests where your rights override those interests.',
        '• Right to lodge a complaint: You have the right to lodge a complaint with the NDPC or the relevant supervisory authority in your country.',
        'To exercise any of these rights, email privacy@dayfi.co from the address associated with your account and describe your request clearly. We may need to verify your identity before we can respond, and we will aim to respond within the timeframe required by applicable law.',
      ],
    ),
    LegalSection(
      number: '09',
      title: 'Security',
      paragraphs: [
        'We take the security of your data seriously and implement administrative, technical, and physical safeguards appropriate to a financial and payments product.',
        'In transit: All connections between DayFi apps, our APIs, and our servers are encrypted using TLS. We enforce secure connections and reject unencrypted requests.',
        'At rest: Sensitive values—including certain credentials, secret keys, and encrypted BVN data where applicable—are stored using industry-standard encryption. Database access is controlled by strict identity and access management policies.',
        'Operational controls: We apply the principle of least privilege to staff access, conduct security reviews of significant product changes, and monitor our systems for indicators of unauthorized access or anomalous activity.',
        'Third-party security: Our vendors and partners are required to maintain security standards consistent with their role in processing data on our behalf. Flutterwave, as a licensed financial institution, maintains their own extensive security and compliance program.',
        'No system is perfectly secure. You play an important role in security too: protect your account password, enable device-level security (PIN, biometrics), and notify us immediately if you suspect unauthorized access to your account.',
      ],
    ),
    LegalSection(
      number: '10',
      title: 'International transfers',
      paragraphs: [
        'DayFi may process or store data in countries where we, our infrastructure providers, or our partners operate. These may include the United States, European Economic Area member states, and other jurisdictions with varying data protection frameworks.',
        'Where we transfer personal data across borders, we take steps to ensure that appropriate safeguards are in place—such as standard contractual clauses, binding corporate rules, or other mechanisms recognized under applicable law—and that the transfer is necessary for the purpose described in this Notice.',
        'We assess the risks to your rights and freedoms before conducting international transfers and will update our practices if legal requirements change.',
      ],
    ),
    LegalSection(
      number: '11',
      title: 'Children\'s privacy',
      paragraphs: [
        'The Services are intended solely for adults and businesses. We do not knowingly collect, use, or disclose personal data from individuals under the age of 18.',
        'If we learn that we have inadvertently collected personal data from a minor, we will take prompt steps to delete that data. If you believe a minor\'s data has been provided to us, contact us at privacy@dayfi.co.',
      ],
    ),
    LegalSection(
      number: '12',
      title: 'Updates to this Notice',
      paragraphs: [
        'We may update this Privacy Notice from time to time as our Services, partners, technical practices, or applicable laws change. When we make material changes, we will post the revised Notice on our website and app and provide additional notice—such as an in-app notification or email—where this is practicable and required.',
        'The effective date at the top of this Notice indicates when the current version was last reviewed. We encourage you to review this Notice periodically.',
      ],
    ),
    LegalSection(
      number: '13',
      title: 'Contact us',
      paragraphs: [
        'For privacy-related questions, data subject rights requests, or concerns about how your data is handled, please contact us:',
        'Privacy enquiries: privacy@dayfi.co',
        'General support: support@dayfi.co',
        'We aim to respond to all privacy enquiries within the timeframe required by applicable law and no later than 30 days from receipt.',
      ],
    ),
  ],
);
