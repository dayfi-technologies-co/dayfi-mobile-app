import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TermsOfUseView extends StatelessWidget {
  const TermsOfUseView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: Text(
          "Terms of Use",
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontFamily: 'CabinetGrotesk',
            fontSize: 28.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.8,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // _buildSectionTitle("📄 DayFi Terms of Use"),
            // SizedBox(height: 8.h),
            _buildEffectiveDate(context, "Effective Date: December 19, 2024"),
            SizedBox(height: 24.h),

            _buildSection(context, "1. Introduction", [
              "Welcome to DayFi Technologies Inc. (\"DayFi,\" \"we,\" \"our,\" or \"us\"). These Terms of Use (\"Terms\") govern your access to and use of our products and services, including the DayFi website, mobile application, APIs, and related tools (collectively, the \"Services\").",
              "By creating an account, accessing, or using our Services, you agree to be bound by these Terms. If you do not agree, please do not use the Services."
            ]),

            _buildSection(context, "2. Eligibility", [
              "To use our Services, you must:",
              "• Be at least 18 years old (or the legal age of majority in your jurisdiction).",
              "• Have the legal capacity to enter into a binding contract.",
              "• Not be located in, or a resident of, any country subject to comprehensive sanctions.",
              "• Pass all required identity verification checks."
            ]),

            _buildSection(context, "3. Account Registration and Verification", [
              "To access the Services, you must create an account and provide accurate, current, and complete information.",
              "We use Smile ID for identity verification and Twilio for phone number authentication.",
              "You agree to promptly update your information if it changes.",
              "We may suspend or terminate your account if you provide false or incomplete information."
            ]),

            _buildSection(context, "4. Services Overview", [
              "DayFi provides a secure, regulated platform for cross-border payments and related financial services.",
              "Key services include:",
              "• Sending and receiving payments across supported countries.",
              "• Currency exchange between supported fiat and digital assets.",
              "• Secure wallet services.",
              "All payments are processed through Yellow Card, our licensed payment infrastructure partner."
            ]),

            _buildSection(context, "5. Prohibited Uses", [
              "You agree not to use the Services for:",
              "• Money laundering, terrorist financing, or other unlawful activities.",
              "• Transactions involving sanctioned individuals, entities, or countries.",
              "• Fraud, scams, or misrepresentation.",
              "• Interference with the security or integrity of our systems.",
              "We may suspend or terminate your account and report activity to regulators if prohibited use is detected."
            ]),

            _buildSection(context, "6. Fees and Charges", [
              "DayFi may charge transaction fees, exchange rate spreads, or other service-related fees.",
              "Fees will be disclosed before you confirm a transaction.",
              "By confirming a transaction, you agree to pay all applicable fees."
            ]),

            _buildSection(context, "7. Transaction Limits", [
              "DayFi may set transaction limits based on factors such as:",
              "• Your verification level.",
              "• Applicable laws and regulations.",
              "• Risk assessment.",
              "We may adjust limits at our discretion without prior notice."
            ]),

            _buildSection(context, "8. Risk Disclosure", [
              "• Transactions are irreversible once processed.",
              "• Exchange rates may fluctuate and affect the value of your funds.",
              "• Use of digital assets carries additional risks, including volatility and regulatory changes.",
              "• You acknowledge and accept these risks."
            ]),

            _buildSection(context, "9. Privacy", [
              "Your use of our Services is also governed by our Privacy Notice, which explains how we collect, use, and protect your personal data."
            ]),

            _buildSection(context, "10. Intellectual Property", [
              "All content, trademarks, and technology used in the Services are owned by DayFi or our licensors. You are granted a limited, non-exclusive license to use the Services for lawful purposes."
            ]),

            _buildSection(context, "11. Termination", [
              "We may suspend or terminate your access to the Services at any time if:",
              "• You violate these Terms or applicable laws.",
              "• Required by regulatory authorities.",
              "• For risk or security reasons."
            ]),

            _buildSection(context, "12. Limitation of Liability", [
              "To the maximum extent permitted by law:",
              "• DayFi is not liable for indirect, incidental, or consequential damages.",
              "• Our liability is limited to the fees you paid to us in the 3 months before the event giving rise to the claim."
            ]),

            _buildSection(context, "13. Governing Law and Dispute Resolution", [
              "These Terms are governed by the laws of:",
              "• Delaware, United States, for users outside Nigeria.",
              "• Federal Republic of Nigeria, for users in Nigeria.",
              "Any disputes will be resolved through arbitration or competent courts in the applicable jurisdiction."
            ]),

            _buildSection(context, "14. Changes to Terms", [
              "We may update these Terms from time to time. Material changes will be notified through our app, website, or email. Continued use of the Services after updates constitutes acceptance."
            ]),

            _buildSection(context, "15. Contact Us", [
              "For questions about these Terms, contact us at:",
              "📧 support@dayfi.com"
            ]),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }


  Widget _buildEffectiveDate(BuildContext context, String date) {
    return Text(
      date,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontFamily: 'Karla',
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
        letterSpacing: -0.8,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<String> content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontFamily: 'CabinetGrotesk',
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.8,
          ),
        ),
        SizedBox(height: 12.h),
        ...content.map((paragraph) => Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Text(
            paragraph,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontFamily: 'Karla',
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              height: 1.5,
              letterSpacing: -0.8,
            ),
          ),
        )),
        SizedBox(height: 20.h),
      ],
    );
  }
}
