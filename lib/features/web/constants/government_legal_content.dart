import 'package:dayfi/features/web/models/legal_document.dart';

const governmentLegalDocument = LegalDocument(
  id: LegalDocumentId.government,
  pageTitle: 'Government & law enforcement',
  subtitle:
      'How DayFi handles lawful requests, regulatory obligations, and user notification—covering personal account data, NGN payments processed with Flutterwave, stablecoin activity, and records we hold.',
  effectiveDate: 'Effective date: 11 May 2026',
  sections: [
    LegalSection(
      number: '01',
      title: 'Purpose of this page',
      paragraphs: [
        'This page explains how DayFi Technologies Inc. handles requests from government agencies, regulators, courts, and law enforcement. It also describes how we think about transparency for our users when their data is the subject of such requests.',
        'This page is informational. It does not create legal rights or obligations beyond what applicable law already establishes, and it does not override any valid legal process served on DayFi or our partners. We update it as our Services, legal obligations, and practices evolve.',
      ],
    ),
    LegalSection(
      number: '02',
      title: 'Our general approach to legal process',
      paragraphs: [
        'DayFi is a financial technology company operating on regulated infrastructure. We take our legal obligations seriously, including obligations to respond to valid legal process and to cooperate with regulators and law enforcement where the law requires it.',
        'At the same time, we believe that government access to user data should be lawful, necessary, and proportionate. We do not provide bulk access to user records, and we do not voluntarily disclose user data to governments beyond what applicable law requires.',
        'When we receive a request for user data or account information, we evaluate it carefully. We consider whether the requesting authority has jurisdiction over DayFi or the relevant data, whether the request is legally valid and procedurally correct, whether the scope of the request is proportionate to its stated purpose, and whether compliance would violate applicable law—including the laws of any other jurisdiction that may apply.',
        'We may challenge requests we believe are overbroad, improperly scoped, or legally deficient, and we will seek to narrow the scope of any request before complying where that is possible.',
      ],
    ),
    LegalSection(
      number: '03',
      title: 'Types of requests we receive',
      paragraphs: [
        'Government and regulatory requests we may receive include subpoenas or court orders requiring us to produce records; warrants authorizing search or seizure of data we hold; regulatory examinations, audits, or information requests from financial regulators (including the Central Bank of Nigeria or equivalent bodies in other jurisdictions); requests from financial intelligence units related to anti-money-laundering (AML) or counter-terrorism financing (CTF) obligations; and informal inquiries or preservation requests that may precede formal legal process.',
        'We treat each category differently depending on the authority of the requesting body, the legal basis for the request, and the jurisdiction in which it arises.',
      ],
    ),
    LegalSection(
      number: '04',
      title: 'What data we can produce',
      paragraphs: [
        'DayFi holds account information (name, contact details, verification records), transaction history (payment intents, amounts, counterparties, timestamps, and statuses), wallet and ledger data, device and session metadata, and—where enabled—encrypted verification data such as BVN-linked records processed with Flutterwave.',
        'We do not hold the full underlying banking records for NGN transfers; those are held by Flutterwave in its capacity as a licensed financial institution. Where a request concerns Flutterwave-held data, we will indicate that the requesting authority should direct the relevant process to Flutterwave directly, and our ability to produce that data may be limited to what Flutterwave makes available to us.',
        'For stablecoin settlement paths, on-chain transaction data is publicly visible on the relevant blockchain network and does not require a request to DayFi to access. We hold records of your payment intent, confirmation status, and wallet addresses associated with specific events in our system, but we do not control on-chain data.',
      ],
    ),
    LegalSection(
      number: '05',
      title: 'Notifying users',
      paragraphs: [
        'Unless we are legally prohibited from doing so—for example by a non-disclosure requirement in a court order, a gag order, or applicable law—we will generally attempt to notify the affected user before or promptly after we comply with a request for their data. This gives the user an opportunity to seek legal advice or challenge the request if they believe it is unlawful or overbroad.',
        'We will not notify a user if we reasonably believe that doing so would create a risk of harm to a third party, would interfere with an ongoing investigation involving credible threats to safety, or would violate a specific legal prohibition on notification that we are subject to.',
        'Notification does not mean we will delay compliance while the user pursues a challenge; the timing of any notification relative to our compliance will depend on what the law permits in the specific circumstances.',
      ],
    ),
    LegalSection(
      number: '06',
      title: 'Regulatory relationships and compliance obligations',
      paragraphs: [
        'DayFi builds on Flutterwave\'s licensed infrastructure for NGN payment services. Flutterwave is regulated by the Central Bank of Nigeria (CBN) and maintains its own AML, KYC, and reporting obligations. Our integration with Flutterwave is designed to operate within those regulated frameworks, not around them.',
        'DayFi Technologies Inc. is incorporated in Delaware, United States. We are therefore also subject to applicable US law, including federal financial crime statutes, sanctions administered by the Office of Foreign Assets Control (OFAC), and export control regulations. We screen transactions and users against applicable sanctions lists.',
        'Where applicable law requires us to file reports—for example Suspicious Activity Reports (SARs) or equivalent reports in relevant jurisdictions—we do so. The existence of a filed report is typically subject to tipping-off prohibitions, meaning we cannot confirm or deny whether a specific report has been made about a specific transaction or user.',
        'We do not provide financial, tax, or regulatory advice. You are responsible for your own compliance obligations under applicable tax law, consumer protection law, and any sector-specific regulations that apply to you.',
      ],
    ),
    LegalSection(
      number: '07',
      title: 'International requests',
      paragraphs: [
        'DayFi\'s primary market is Nigeria, and the majority of payment data we hold relates to NGN transactions conducted in or connected to Nigeria. We also handle data related to cross-border stablecoin flows and, in some cases, user accounts operating outside Nigeria.',
        'We respond to requests from foreign governments where we have a clear legal obligation to do so and where the request is consistent with applicable law in the jurisdictions involved. We are not obligated to comply with foreign legal process simply because it is served; we evaluate jurisdiction, applicable treaties, and our legal obligations carefully.',
        'Where a request from a foreign authority conflicts with Nigerian law or with our obligations to our users, we will seek to resolve that conflict transparently and with appropriate legal advice before complying.',
      ],
    ),
    LegalSection(
      number: '08',
      title: 'Data preservation',
      paragraphs: [
        'If we receive a valid preservation request from a law enforcement or government agency, we may preserve relevant data for a defined period pending formal legal process. Preservation does not mean disclosure; we will only produce preserved data in response to valid legal process that we are obligated to comply with.',
        'We retain payment and account data for periods specified in our Privacy Notice and as required by applicable law. If you are a government agency and your preservation request concerns data we no longer hold, we will inform you of that fact.',
      ],
    ),
    LegalSection(
      number: '09',
      title: 'Transparency reporting',
      paragraphs: [
        'As our operations and legal programs mature, we intend to publish aggregate transparency statistics—for example, ranges indicating the number of legal requests we received and how we responded—where applicable law permits us to do so. We do not currently publish a formal transparency report, but we are committed to doing so as our scale and obligations warrant it.',
        'We believe that transparency about government access to financial data is important for the trust that users place in financial infrastructure. We will not misrepresent the volume or nature of requests we receive.',
      ],
    ),
    LegalSection(
      number: '10',
      title: 'How to submit a valid request',
      paragraphs: [
        'Official legal process and regulatory requests should be submitted on agency letterhead or equivalent secure and verifiable channel. Requests must include:',
        '• The name and jurisdiction of the requesting authority.',
        '• The legal basis for the request (statute, court order, warrant, or regulatory instrument).',
        '• A specific and proportionate description of the data or records requested.',
        '• The time period covered by the request.',
        '• A return contact at the requesting agency.',
        'Informal or unverifiable requests cannot be acted on. We reserve the right to seek authentication of any request before complying, and to reject requests that do not meet applicable legal standards.',
        'Submit requests to: support@dayfi.co — mark the subject line clearly as a legal or regulatory request. We will acknowledge receipt and inform you of next steps.',
      ],
    ),
  ],
);
