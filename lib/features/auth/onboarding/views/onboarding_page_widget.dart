import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';
// import 'package:dayfi/core/theme/app_colors.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import '../models/onboarding_page.dart';

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage page;

  const OnboardingPageWidget({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 600;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 32.0 : 12.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                        child:
                            page.illustrationPath.endsWith('.png')
                                ? Image.asset(
                                  page.illustrationPath,
                                  width: isWide ? 180 : 144,
                                  height: isWide ? 180 : 144,
                                )
                                : SvgPicture.asset(
                                  page.illustrationPath,
                                  width: isWide ? 180 : 144,
                                  height: isWide ? 180 : 144,
                                ),
                      )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 600.ms)
                      .slideY(begin: 0.18, end: 0, duration: 600.ms)
                      .scale(begin: const Offset(.98, .98), duration: 500.ms),

                  SizedBox(height: isWide ? 32 : 24),

                  /// TITLE
                  Text(
                        page.title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: isWide ? 56 : 40,
                          letterSpacing:-.250,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'FunnelDisplay',
                          height: 1,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: 0.25, end: 0, duration: 600.ms)
                      .then()
                      .shimmer(
                        duration: 1800.ms,
                        color: Theme.of(
                          context,
                        ).scaffoldBackgroundColor.withOpacity(0.4),
                        angle: 20,
                      ),

                  SizedBox(height: isWide ? 32 : 24),

                  /// SUBTITLE
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWide ? 24 : MediaQuery.of(context).size.width * 0.08,
                    ),
                    child: Text(
                          "${page.subtitle} ${page.description.isNotEmpty ? page.description : ''}",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            letterSpacing: 0,
                            color: Theme.of(
                              context,
                            ).textTheme.headlineLarge?.color!.withOpacity(0.85),
                            fontSize: isWide ? 20 : 18,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                            fontFamily: "Chirp",
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 150.ms, duration: 600.ms)
                        .slideY(begin: 0.2, end: 0, duration: 600.ms),
                  ),
                ],
              )
              .animate()
              .fadeIn(duration: 450.ms)
              .blurXY(begin: 4, end: 0, duration: 450.ms),
        ),
      ),
    );
  }
}
