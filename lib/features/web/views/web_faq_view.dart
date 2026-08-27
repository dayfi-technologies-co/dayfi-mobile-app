import 'package:dayfi/features/web/widgets/landing/landing_sections.dart';
import 'package:dayfi/features/web/widgets/web_landing_shell.dart';
import 'package:dayfi/routes/route.dart';
import 'package:flutter/material.dart';

/// Web marketing FAQ page — same shell and typography as the landing page.
class WebFaqView extends StatelessWidget {
  const WebFaqView({super.key});

  @override
  Widget build(BuildContext context) {
    return const WebLandingShell(
      activeRoute: AppRoute.webFaqPath,
      fullWidthChild: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LandingFullBleedSection(
            backgroundColor: LandingSectionColors.faq,
            child: LandingFaqSection(),
          ),
        ],
      ),
    );
  }
}
