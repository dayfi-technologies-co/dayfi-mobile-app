import 'package:dayfi/features/web/utils/web_layout.dart';
import 'package:dayfi/features/web/widgets/landing/landing_sections.dart';
import 'package:dayfi/features/web/widgets/web_landing_shell.dart';
import 'package:dayfi/routes/route.dart';
import 'package:flutter/material.dart';

class WebLandingView extends StatelessWidget {
  const WebLandingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const WebLandingShell(
      showAnnouncement: false,
      activeRoute: AppRoute.webLandingView,
      fullWidthChild: true,
      child: _LandingContent(),
    );
  }
}

class _LandingContent extends StatelessWidget {
  const _LandingContent();

  @override
  Widget build(BuildContext context) {
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final isMobile = WebLayout.isMobile(viewportWidth);
    final isDesktop = WebLayout.isDesktop(viewportWidth);
    final topPad = WebLayout.sectionVerticalGap(viewportWidth) * 2;
    final heroTopPad = topPad * .5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LandingFullBleedSection(
          backgroundColor: LandingSectionColors.hero,
          padding: EdgeInsets.fromLTRB(0, heroTopPad, 0, topPad),
          child: LandingHeroSection(
            contentWidth: WebLayout.contentInnerWidth(viewportWidth),
            isMobile: isMobile,
            isDesktop: isDesktop,
          ),
        ),
        LandingFullBleedSection(
          backgroundColor: LandingSectionColors.highlights,
          child: const LandingDeliveryHighlightsSection(),
        ),
        LandingFullBleedSection(
          backgroundColor: LandingSectionColors.security,
          child: const LandingSecuritySection(),
        ),
        LandingFullBleedSection(
          backgroundColor: LandingSectionColors.howItWorks,
          child: LandingHowItWorksSection(
            contentWidth: WebLayout.contentInnerWidth(viewportWidth),
          ),
        ),
        LandingFullBleedSection(
          backgroundColor: LandingSectionColors.testimonials,
          child: const LandingTestimonialsSection(),
        ),
        LandingFullBleedSection(
          backgroundColor: LandingSectionColors.faq,
          child: const LandingFaqSection(),
        ),
        LandingFullBleedSection(
          backgroundColor: LandingSectionColors.finalCta,
          child: LandingFinalCtaSection(
            contentWidth: WebLayout.contentInnerWidth(viewportWidth),
          ),
        ),
      ],
    );
  }
}
