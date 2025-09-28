import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PrivacyNoticeView extends StatelessWidget {
  const PrivacyNoticeView({super.key});

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
          "Privacy Notice",
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
            // _buildSectionTitle("📄 DayFi Privacy Notice")
            _buildEffectiveDate(context, "Effective Date: December 19, 2024"),
            SizedBox(height: 24.h),

            _buildSection(context, "1. Introduction", [
              "DayFi Technologies Inc. (\"DayFi,\" \"we,\" \"our,\" or \"us\") is committed to protecting your privacy. This Privacy Notice explains how we collect, use, share, and safeguard your personal data when you use our Services."
            ]),

            _buildSection(context, "2. Information We Collect", [
              "We may collect the following categories of personal data:",
              "• Identity Information: Name, date of birth, government-issued ID.",
              "• Contact Information: Phone number, email address, residential address.",
              "• Financial Information: Bank account details, wallet addresses, transaction history.",
              "• Device Information: IP address, browser type, mobile device identifiers.",
              "• Verification Data: Biometric or facial data processed by Smile ID for KYC."
            ]),

            _buildSection(context, "3. How We Collect Information", [
              "• Directly from you when you register or transact.",
              "• Automatically when you use our app or website.",
              "• From third parties such as verification providers (Smile ID) or payment partners (Yellow Card)."
            ]),

            _buildSection(context, "4. How We Use Information", [
              "We use your personal data to:",
              "• Provide and operate our Services.",
              "• Verify your identity and comply with KYC/AML obligations.",
              "• Process payments via Yellow Card.",
              "• Communicate with you via Twilio SMS or email.",
              "• Detect, prevent, and report fraud and financial crime.",
              "• Improve our services and user experience."
            ]),

            _buildSection(context, "5. How We Share Information", [
              "We may share your data with:",
              "• Smile ID for identity verification.",
              "• Twilio for SMS/communication.",
              "• Yellow Card for payment processing.",
              "• Regulatory authorities, law enforcement, or courts when legally required.",
              "• Service providers who support our operations (e.g., cloud hosting).",
              "We never sell your personal data."
            ]),

            _buildSection(context, "6. Data Retention", [
              "We retain personal data for at least 5 years after account closure or as required by law/regulations."
            ]),

            _buildSection(context, "7. Your Rights", [
              "Depending on your jurisdiction, you may have rights to:",
              "• Access the personal data we hold about you.",
              "• Correct inaccurate or incomplete data.",
              "• Request deletion of your data (subject to legal obligations).",
              "• Restrict or object to processing.",
              "• Data portability (receive your data in a structured format).",
              "To exercise your rights, email us at privacy@dayfi.com"
            ]),

            _buildSection(context, "8. Security Measures", [
              "We use strong technical and organizational safeguards to protect your data, including:",
              "• Encryption of data in transit and at rest.",
              "• Multi-factor authentication.",
              "• Regular audits and monitoring."
            ]),

            _buildSection(context, "9. International Data Transfers", [
              "Your data may be transferred to and processed in countries outside your residence, including Nigeria, the United States, and other jurisdictions where DayFi operates. We ensure safeguards are in place for such transfers."
            ]),

            _buildSection(context, "10. Children's Privacy", [
              "Our Services are not intended for children under 18. We do not knowingly collect data from minors."
            ]),

            _buildSection(context, "11. Updates to this Notice", [
              "We may update this Privacy Notice to reflect changes in law or business practices. We will notify you of material updates via our app, website, or email."
            ]),

            _buildSection(context, "12. Contact Us", [
              "For privacy-related questions or concerns, contact us at:",
              "📧 privacy@dayfi.com",
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
          child:             Text(
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