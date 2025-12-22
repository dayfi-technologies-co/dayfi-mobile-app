import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:intercom_flutter/intercom_flutter.dart';

class FaqView extends StatefulWidget {
  const FaqView({super.key});

  @override
  State<FaqView> createState() => _FaqViewState();
}

class _FaqViewState extends State<FaqView> {
  final List<FaqItem> _faqItems = [
    // Getting Started
    FaqItem(
      question: "What is DayFi?",
      answer:
          "DayFi is a fintech platform on a mission to make payments accessible for Africa. We enable fast, secure, and affordable cross-border transfers using stablecoin technology (USDC), making it easier for Africans to send and receive money globally.",
    ),
    FaqItem(
      question: "How do I create a DayFi account?",
      answer:
          "Simply download the app, enter your email address, verify it with the OTP sent to your inbox, create a secure password and passcode, then complete your profile with basic information. It takes less than 5 minutes!",
    ),
    FaqItem(
      question: "Is DayFi available in my country?",
      answer:
          "DayFi is currently available in Nigeria and expanding across Africa. We're working hard to bring our services to more African countries soon. Stay tuned for updates!",
    ),
    FaqItem(
      question: "What documents do I need to verify my account?",
      answer:
          "You'll need a valid government-issued ID (National ID, International Passport, or Driver's License). Our identity verification is powered by Smile ID, ensuring your data is secure and the process is seamless.",
    ),

    // About USDC & Transfers
    FaqItem(
      question: "What is USDC and why does DayFi use it?",
      answer:
          "USDC (USD Coin) is a stablecoin pegged 1:1 to the US Dollar. We use USDC because it enables instant, low-cost transfers without the volatility of traditional cryptocurrencies. Your money maintains its value throughout the transfer process.",
    ),
    FaqItem(
      question: "How fast are DayFi transfers?",
      answer:
          "Most transfers are completed within minutes! Because we leverage blockchain technology and USDC, we can process transfers much faster than traditional banking systems.",
    ),
    FaqItem(
      question: "What are the transfer fees?",
      answer:
          "DayFi offers competitive rates with transparent pricing. You'll always see the exact fees before confirming any transfer. No hidden charges, ever.",
    ),
    FaqItem(
      question: "What's the minimum and maximum transfer amount?",
      answer:
          "Transfer limits depend on your verification level. Basic verified users can send up to a certain limit, while fully verified users enjoy higher limits. Check your profile for your specific limits.",
    ),

    // Security
    FaqItem(
      question: "How secure is DayFi?",
      answer:
          "Security is our top priority. We use bank-grade encryption, secure passcodes, biometric authentication (Face ID/Fingerprint), and partner with Smile ID for identity verification. Your funds and data are always protected.",
    ),
    FaqItem(
      question: "What is a transaction PIN?",
      answer:
          "Your transaction PIN is a 4-digit code required to authorize all wallet transfers. It adds an extra layer of security to ensure only you can move your funds.",
    ),
    FaqItem(
      question: "What should I do if I forget my passcode?",
      answer:
          "If you forget your passcode, you can reset it by logging out and using the 'Forgot Password' option. You'll verify your identity via email, then create a new passcode.",
    ),
    FaqItem(
      question: "Can I enable biometric login?",
      answer:
          "Yes! DayFi supports Face ID and Fingerprint authentication for quick and secure access. You can enable this in your profile settings after setting up your passcode.",
    ),

    // Partners & Technology
    FaqItem(
      question: "Who is Yellow Card?",
      answer:
          "Yellow Card is our trusted partner for crypto-to-fiat conversions. They're Africa's largest cryptocurrency exchange, enabling us to provide seamless cash-out options across multiple African countries.",
    ),
    FaqItem(
      question: "Who is Smile ID?",
      answer:
          "Smile ID is Africa's leading identity verification provider. They power our KYC (Know Your Customer) process, ensuring secure and reliable identity verification while keeping your personal data safe.",
    ),
    FaqItem(
      question: "Is my personal information safe with DayFi?",
      answer:
          "Absolutely. We follow strict data protection protocols and only collect information necessary to provide our services. Your data is encrypted and never shared with unauthorized third parties.",
    ),

    // Troubleshooting
    FaqItem(
      question: "My transfer is taking longer than expected. What should I do?",
      answer:
          "While most transfers complete in minutes, occasionally there may be delays due to network congestion or additional verification. If your transfer hasn't completed within 24 hours, please contact our support team.",
    ),
    FaqItem(
      question: "I sent money to the wrong recipient. Can I reverse it?",
      answer:
          "Unfortunately, once a transfer is confirmed, it cannot be reversed due to the nature of blockchain transactions. Always double-check recipient details before confirming. Contact support if you need assistance.",
    ),
    FaqItem(
      question: "Why was my transaction declined?",
      answer:
          "Transactions may be declined due to insufficient balance, exceeded limits, or security flags. Check your balance and verification status. If issues persist, contact support for assistance.",
    ),
    FaqItem(
      question: "How do I contact DayFi support?",
      answer:
          "You can reach our support team through the in-app chat, email us at support@dayfi.co, or visit our Help Center. We're here to help 24/7!",
    ),
    FaqItem(
      question: "What makes DayFi different from other money transfer apps?",
      answer:
          "DayFi combines the speed and low cost of blockchain technology with the simplicity of traditional apps. We're built specifically for Africa, understanding local needs, and backed by trusted partners like Yellow Card and Smile ID to deliver a seamless experience.",
    ),
  ];

  int? _expandedIndex;

  void _navigateToContactUs() async {
    try {
      await Intercom.instance.displayMessenger();
    } catch (e) {
      // Fallback in case Intercom fails
      if (mounted) {
        TopSnackbar.show(
          context,
          message: 'Unable to open support chat. Please try again later.',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          scrolledUnderElevation: .5,
          foregroundColor: Theme.of(context).scaffoldBackgroundColor,
          shadowColor: Theme.of(context).scaffoldBackgroundColor,
          surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leadingWidth: 72,
          centerTitle: true,
          leading: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              Navigator.pop(context);
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset(
                  "assets/icons/svgs/notificationn.svg",
                  height: 40,
                  color: Theme.of(context).colorScheme.surface,
                ),
                SizedBox(
                  height: 40,
                  width: 40,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Icon(
                        Icons.arrow_back_ios,
                        size: 20,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth > 600;
            return SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isWide ? 32 : 18,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            "Frequently Asked\nQuestions",
                            textAlign: TextAlign.center,
                            style: Theme.of(
                              context,
                            ).textTheme.displayLarge?.copyWith(
                              color:
                                  Theme.of(
                                    context,
                                  ).textTheme.headlineLarge?.color,
                              fontSize: isWide ? 32 : 28,
                              letterSpacing: -.250,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'FunnelDisplay',
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Find answers to common questions about Dayfi",
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Chirp',
                              letterSpacing: -.25,
                              height: 1.2,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          // FAQ List
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _faqItems.length,
                            separatorBuilder:
                                (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = _faqItems[index];
                              final isExpanded = _expandedIndex == index;

                              return _buildFaqCard(
                                context,
                                item: item,
                                isExpanded: isExpanded,
                                onTap: () {
                                  setState(() {
                                    _expandedIndex = isExpanded ? null : index;
                                  });
                                },
                              );
                            },
                          ),

                          const SizedBox(height: 32),

                          // Contact Support Section
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.purple500ForTheme(
                                context,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Stack(
                                  alignment: AlignmentGeometry.center,
                                  children: [
                                    SvgPicture.asset(
                                      "assets/icons/svgs/notificationn.svg",
                                      height: 40,
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                    ),
                                    Center(
                                      child: SvgPicture.asset(
                                        "assets/icons/svgs/support.svg",
                                        height: 28,
                                        color: AppColors.purple400,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Still have questions?",
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(
                                    fontFamily: 'FunnelDisplay',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                    letterSpacing: -.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Our support team is available 24/7 to help you with any questions or concerns.",
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(
                                    fontFamily: 'Chirp',
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withOpacity(0.7),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                InkWell(
                                  onTap: _navigateToContactUs,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.purple500ForTheme(
                                        context,
                                      ),
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Text(
                                      "Contact Support",
                                      style: TextStyle(
                                        fontFamily: 'Chirp',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.neutral0,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFaqCard(
    BuildContext context, {
    required FaqItem item,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isExpanded
                  ? AppColors.purple500ForTheme(context).withOpacity(0.3)
                  : Theme.of(context).dividerColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: Colors.transparent,
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.question,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontFamily: 'Chirp',
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          letterSpacing: -0.3,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.purple500ForTheme(context),
                        size: 24,
                      ),
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                          item.answer,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            fontFamily: 'Chirp',
                            fontSize: 14,
                            letterSpacing: -0.2,
                            height: 1.5,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color?.withOpacity(0.8),
                          ),
                        )
                        .animate()
                        .fadeIn(
                          delay: 100.ms,
                          duration: 300.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .slideY(
                          begin: 0.2,
                          end: 0,
                          delay: 100.ms,
                          duration: 300.ms,
                          curve: Curves.easeOutCubic,
                        ),
                  ),
                  crossFadeState:
                      isExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FaqItem {
  final String question;
  final String answer;

  FaqItem({required this.question, required this.answer});
}
