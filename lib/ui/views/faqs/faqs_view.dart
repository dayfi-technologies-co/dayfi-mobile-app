import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stacked/stacked.dart';
import 'faqs_viewmodel.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:dayfi/ui/components/buttons/filled_btn.dart' show FilledBtn;

class FaqsView extends StackedView<FaqsViewModel> {
  const FaqsView({super.key});

  @override
  Widget builder(
    BuildContext context,
    FaqsViewModel viewModel,
    Widget? child,
  ) {
    return AppScaffold(
      backgroundColor: const Color(0xffF6F5FE),
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xffF6F5FE),
        leading: IconButton(
          onPressed: () => viewModel.navigationService.back(),
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xff5645F5),
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        constraints: const BoxConstraints.expand(),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              verticalSpace(10),
              
              // Title with smooth entrance
              Text(
                "FAQs",
                style: TextStyle(
                  fontFamily: 'Boldonse',
                  fontSize: 27.5,
                  height: 1.2,
                  letterSpacing: 0.00,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff2A0079),
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                  .slideY(begin: 0.3, end: 0, delay: 200.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                  .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0), delay: 200.ms, duration: 500.ms, curve: Curves.easeOutCubic),
              
              verticalSpace(12),
              
              // Subtitle with smooth entrance
              Text(
                "Questions? We got answers!",
                style: TextStyle(
                  fontFamily: 'Karla',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                  height: 1.450,
                  color: const Color(0xFF302D53),
                ),
                textAlign: TextAlign.start,
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                  .slideY(begin: 0.2, end: 0, delay: 300.ms, duration: 500.ms, curve: Curves.easeOutCubic),
              
              verticalSpace(30),
              
              // FAQ items with staggered animations
              Column(
                children: [
                  _buildAnimatedExpansionTile(
                    title: 'What is Dayfi?',
                    content: 'DayFi is a mobile app that lets you send money, hold multiple currencies (NGN, USD, EUR, GBP), and trade crypto like XLM with low fees. It\'s built on the Stellar blockchain to make global finance simple and affordable for young Nigerians.',
                    delay: 400.ms,
                  ),
                  _buildDivider(500.ms),
                  _buildAnimatedExpansionTile(
                    title: 'How can I sign up on Dayfi?',
                    content: "Find the Dayfi app in the App Store (for Apple devices) or the Play Store (for Android devices). You can search for the app or follow a link to the app's page.",
                    delay: 600.ms,
                  ),
                  _buildDivider(700.ms),
                  _buildAnimatedExpansionTile(
                    title: 'What fees does DayFi charge?',
                    content: 'We charge a 0.1% fee on swaps and trades (e.g., \$0.10 on a \$100 transaction). There are no hidden fees, and Stellar\'s base transaction fee (~\$0.001) is included.',
                    delay: 800.ms,
                  ),
                  _buildDivider(900.ms),
                  _buildAnimatedExpansionTile(
                    title: 'What currencies can I hold in the DayFi wallet?',
                    content: "You can hold NGN, USD (via USDC), EUR (via EURC), and GBP (via GBPC) in one wallet. We plan to add more currencies after our beta launch.",
                    delay: 1000.ms,
                  ),
                  _buildDivider(1100.ms),
                  _buildAnimatedExpansionTile(
                    title: 'Is DayFi safe to use?',
                    content: 'Yes! DayFi is built on Stellar, a secure blockchain with a proven track record. Your wallet is protected by Stellar\'s encryption, and we use Soroban smart contracts to ensure safe transactions.',
                    delay: 1200.ms,
                  ),
                  _buildDivider(1300.ms),
                  _buildAnimatedExpansionTile(
                    title: 'How do I start trading crypto with DayFi?',
                    content: 'Once the app launches, you can buy and sell crypto like XLM or Wrapped Bitcoin with a tap. We charge a 0.1% fee per trade (e.g., \$0.10 on a \$100 trade), and in-app tutorials guide you through the process.',
                    delay: 1400.ms,
                  ),
                  _buildDivider(1500.ms),
                  _buildAnimatedExpansionTile(
                    title: 'Who can use DayFi?',
                    content: "DayFi is designed for tech-savvy young professionals and students in Nigeria, especially in Nigeria. You'll need a smartphone (Android or iOS) and an internet connection to use the app.",
                    delay: 1600.ms,
                  ),
                  _buildDivider(1700.ms),
                  _buildAnimatedExpansionTile(
                    title: 'How does DayFi help with financial inclusion?',
                    content: 'DayFi lets you hold and use global currencies like USD and EUR, which many Nigerians can\'t easily access. It also makes crypto trading simple and affordable, helping you participate in the global economy.',
                    delay: 1800.ms,
                  ),
                ],
              ),
              
              verticalSpace(72),
              
              // Help button with final animation
              FilledBtn(
                onPressed: () {},
                text: 'Do you need help?',
                backgroundColor: Colors.transparent,
                textColor: const Color(0xff5645F5),
              )
                  .animate()
                  .fadeIn(delay: 1900.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                  .slideY(begin: 0.3, end: 0, delay: 1900.ms, duration: 500.ms, curve: Curves.easeOutCubic)
                  .scale(begin: const Offset(0.98, 0.98), end: const Offset(1.0, 1.0), delay: 1900.ms, duration: 500.ms, curve: Curves.easeOutCubic),
              
              verticalSpace(40),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper method to create animated expansion tiles
  Widget _buildAnimatedExpansionTile({
    required String title,
    required String content,
    required Duration delay,
  }) {
    return CustomExpansionTile(
      title: title,
      content: content,
    )
        .animate()
        .fadeIn(delay: delay, duration: 500.ms, curve: Curves.easeOutCubic)
        .slideY(begin: 0.2, end: 0, delay: delay, duration: 500.ms, curve: Curves.easeOutCubic)
        .scale(begin: const Offset(0.98, 0.98), end: const Offset(1.0, 1.0), delay: delay, duration: 500.ms, curve: Curves.easeOutCubic);
  }

  /// Helper method to create animated dividers
  Widget _buildDivider(Duration delay) {
    return Divider(
      height: 0,
      color: const Color(0xff2A0079).withOpacity(.35),
    )
        .animate()
        .fadeIn(delay: delay, duration: 300.ms, curve: Curves.easeOutCubic);
  }

  @override
  FaqsViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      FaqsViewModel();
}

class CustomExpansionTile extends StatelessWidget {
  final String title;
  final String content;

  const CustomExpansionTile({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide.none,
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide.none,
      ),
      tilePadding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 12,
      ),
      iconColor: Color(0xff2A0079),
      textColor: Color(0xff2A0079),
      leading: Image.asset(
        "assets/images/question-mark.png",
        height: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          height: 1.450,
          fontFamily: 'Boldonse',
          letterSpacing: .255,
          color: Color(0xff2A0079),
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.5,
              fontFamily: 'Karla',
              letterSpacing: .1,
              color: Color(0xff304463),
            ),
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }
}
