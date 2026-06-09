import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/web/constants/landing_copy.dart';
import 'package:dayfi/features/web/utils/web_layout.dart';
import 'package:dayfi/features/web/widgets/landing/landing_copyable_text.dart';
import 'package:dayfi/features/web/widgets/web_landing_shell.dart';
import 'package:dayfi/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qr_flutter/qr_flutter.dart';

class LandingFullBleedSection extends StatelessWidget {
  const LandingFullBleedSection({
    super.key,
    required this.backgroundColor,
    required this.child,
    this.padding,
  });

  final Color backgroundColor;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final pagePadding = WebLayout.pagePadding(viewportWidth);
    final contentWidth = WebLayout.contentMaxWidth(viewportWidth);
    final verticalPad = WebLayout.sectionVerticalGap(viewportWidth) * 2;
    final resolvedPadding =
        padding ?? EdgeInsets.symmetric(vertical: verticalPad);

    return ColoredBox(
      color: backgroundColor,
      child: Padding(
        padding: resolvedPadding,
        child: Center(
          child: SizedBox(
            width: contentWidth,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: pagePadding),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Alternating full-bleed band colors for the marketing landing page.
abstract final class LandingSectionColors {
  LandingSectionColors._();

  static const hero = AppColors.splashBackgroundLight;
  static const highlights = AppColors.neutral900;
  static const security = Color.fromARGB(255, 14, 14, 14);
  static const howItWorks = AppColors.neutral900;
  static const testimonials = Color.fromARGB(255, 14, 14, 14);
  static const faq = AppColors.neutral900;
  static const finalCta = Color.fromARGB(255, 38, 24, 12);
}

class LandingAnnouncementBanner extends StatelessWidget {
  const LandingAnnouncementBanner({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.orange500,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              children: [
                LandingCopyableText(
                  LandingCopy.announcementText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Chirp',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.neutral0,
                  ),
                ),
                LandingCopyableText(
                  LandingCopy.announcementCta,
                  style: const TextStyle(
                    fontFamily: 'Chirp',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral0,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.neutral0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LandingHeroSection extends StatelessWidget {
  const LandingHeroSection({
    super.key,
    required this.contentWidth,
    required this.isMobile,
    required this.isDesktop,
  });

  final double contentWidth;
  final bool isMobile;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final leftColumn = _HeroLeftColumn(contentWidth: contentWidth);
    // final visual = _HeroTransferVisual(showHand: isDesktop);

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(flex: 5, child: leftColumn),
          const SizedBox(width: 48),
          
          Expanded(
            flex: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    // border: Border.all(color: Colors.black87, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black87.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset('assets/images/one.png', height: 524),
                  ),
                ),
                const SizedBox(width: 24),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    // border: Border.all(color: Colors.black87, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black87.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset('assets/images/three.png', height: 524),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        leftColumn,
        const SizedBox(height: 72),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                // border: Border.all(color: Colors.black87, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black87.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset('assets/images/one.png', height: 512),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroLeftColumn extends StatelessWidget {
  const _HeroLeftColumn({required this.contentWidth});

  final double contentWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = WebLayout.isMobile(contentWidth);

    return Padding(
      padding: EdgeInsets.only(
        right:
            isMobile
                ? 0
                : WebLayout.sectionRightInset(contentWidth, fraction: 0.08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LandingCopyableText(
            "Send money in a heartbeat",
            style: theme.textTheme.titleLarge?.copyWith(
              fontFamily: 'FunnelDisplay',
              fontSize: isMobile ? 52 : 88,
              fontWeight: FontWeight.w400,
              height: 1,
              letterSpacing: -2,
              color: AppColors.neutral900,
            ),
          ),

          // _HeroHeadlinePills(isMobile: isMobile),
          const SizedBox(height: 24),
          LandingCopyableText(
            LandingCopy.heroSubtitleShort,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontFamily: 'Chirp',
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.w400,
              height: 1.55,
              letterSpacing: 0.1,
              color: AppColors.neutral800,
            ),
          ),

          // SizedBox(height: isMobile ? 16 : 24),
          // Wrap(
          //   spacing: 12,
          //   runSpacing: 12,
          //   children: [
          //     FilledButton(
          //       onPressed:
          //           () => Navigator.of(context).pushNamed(AppRoute.signupPath),
          //       style: FilledButton.styleFrom(
          //         backgroundColor: AppColors.orange500,
          //         foregroundColor: AppColors.neutral0,
          //         padding: EdgeInsets.symmetric(
          //           horizontal: WebLayout.isMobile(contentWidth) ? 32 : 40,
          //           vertical: 22,
          //         ),
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(56),
          //         ),
          //       ),
          //       child: Text(
          //         LandingCopy.navSignUp,
          //         style: const TextStyle(
          //           fontFamily: 'Chirp',
          //           fontSize: 16,
          //           fontWeight: FontWeight.w500,
          //         ),
          //       ),
          //     ),
          //     OutlinedButton(
          //       onPressed:
          //           () => Navigator.of(context).pushNamed(AppRoute.loginPath),
          //       style: OutlinedButton.styleFrom(
          //         padding: EdgeInsets.symmetric(
          //           horizontal: WebLayout.isMobile(contentWidth) ? 32 : 40,
          //           vertical: 22,
          //         ),
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(56),
          //         ),
          //       ),
          //       child: Text(
          //         LandingCopy.navLogin,
          //         style: const TextStyle(
          //           fontFamily: 'Chirp',
          //           fontSize: 16,
          //           fontWeight: FontWeight.w500,
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
          SizedBox(height: isMobile ? 28 : 40),
          LayoutBuilder(
            builder: (context, constraints) {
              // final stacked = constraints.maxWidth < 360;
              return CustomPaint(
                painter: DashedBorderPainter(
                  color: Color.fromARGB(255, 48, 48, 48).withValues(alpha: .35),
                  radius: 18,
                  strokeWidth: 1.2,
                  dashWidth: 6,
                  dashGap: 2,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    // padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        Image.asset(
                          'assets/images/coming_soon_to_the_app_store.png',
                          height: 40,
                        ),
                        Image.asset(
                          'assets/images/coming_soon_on_google_play.png',
                          height: 40,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HeroHeadlinePills extends StatelessWidget {
  const _HeroHeadlinePills({required this.isMobile});

  final bool isMobile;

  static const _pillPink = Color(0xFFFFE8EE);
  static const _pillBorder = Color(0x33000000);

  @override
  Widget build(BuildContext context) {
    final fontSize = isMobile ? 36.0 : 54.0;
    final smallFontSize = isMobile ? 34.0 : 52.0;

    return
    // Positioned(
    //   left: isMobile ? -8 : -18,
    //   top: isMobile ? 52 : 72,
    //   child: _HeroSparkle(
    //     color: const Color(0xFF4CD964),
    //     size: isMobile ? 34 : 48,
    //   ),
    // ),
    // Positioned(
    //   right: isMobile ? 12 : 36,
    //   top: isMobile ? -6 : -10,
    //   child: _HeroSparkle(
    //     color: AppColors.orange500,
    //     size: isMobile ? 28 : 40,
    //   ),
    // ),
    // Positioned(
    //   right: isMobile ? -4 : 0,
    //   bottom: isMobile ? -8 : -12,
    //   child: _HeroSparkle(
    //     color: const Color(0xFF7A30E9),
    //     size: isMobile ? 30 : 42,
    //   ),
    // ),
    SizedBox(
      // height: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RotationTransition(
            turns: const AlwaysStoppedAnimation(3),
            child: _HeroHeadlinePill(
              text: "Send money",
              fontSize: fontSize,
              backgroundColor: AppColors.orange200,
              textColor: Colors.black87,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 22 : 32,
                vertical: isMobile ? 22 : 32,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 40),
            child: _HeroHeadlinePill(
              text: "in a",
              fontSize: fontSize,
              backgroundColor: AppColors.orange500,
              textColor: AppColors.neutral0,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 22 : 32,
                vertical: isMobile ? 22 : 32,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: _HeroHeadlinePill(
              text: "heartbeat",
              fontSize: fontSize,
              backgroundColor: AppColors.orange200,
              textColor: Colors.black87,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 22 : 32,
                vertical: isMobile ? 22 : 32,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroHeadlinePill extends StatelessWidget {
  const _HeroHeadlinePill({
    required this.text,
    required this.fontSize,
    required this.backgroundColor,
    required this.padding,
    this.textColor = AppColors.neutral900,
  });

  final String text;
  final double fontSize;
  final Color backgroundColor;
  final Color textColor;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black87, width: 2.5),
        // boxShadow: const [
        //   BoxShadow(
        //     color: Color(0x14000000),
        //     blurRadius: 0,
        //     offset: Offset(0, 3),
        //   ),
        // ],
      ),
      child: Padding(
        padding: padding,
        child: LandingCopyableText(
          text,
          style: TextStyle(
            fontFamily: 'FunnelDisplay',
            fontSize: fontSize,
            fontWeight: FontWeight.w400,
            height: 1,
            letterSpacing: -0.5,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

// class _HeroSparkle extends StatelessWidget {
//   const _HeroSparkle({required this.color, required this.size});

//   final Color color;
//   final double size;

//   @override
//   Widget build(BuildContext context) {
//     return Transform.rotate(
//       angle: 0.35,
//       child: Icon(Icons.brightness_7_rounded, color: color, size: size),
//     );
//   }
// }

// class _HeroTransferVisual extends StatelessWidget {
//   const _HeroTransferVisual({required this.showHand});

//   final bool showHand;

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       clipBehavior: Clip.none,
//       alignment: Alignment.topCenter,
//       children: [
//         Positioned(
//           left: -28,
//           top: 48,
//           child: Transform.rotate(
//             angle: -0.25,
//             child: _HeroDecorShape(
//               width: 120,
//               height: 120,
//               color: AppColors.orange500.withValues(alpha: 0.85),
//             ),
//           ),
//         ),
//         Positioned(
//           right: showHand ? 48 : -12,
//           bottom: -16,
//           child: Transform.rotate(
//             angle: 0.4,
//             child: _HeroDecorShape(
//               width: 96,
//               height: 96,
//               color: const Color(0xFF3B82F6).withValues(alpha: 0.75),
//             ),
//           ),
//         ),
//         Positioned(
//           left: showHand ? 80 : 24,
//           top: -20,
//           child: Transform.rotate(
//             angle: 0.15,
//             child: _HeroDecorShape(
//               width: 72,
//               height: 72,
//               color: const Color(0xFF7A30E9).withValues(alpha: 0.7),
//             ),
//           ),
//         ),
//         if (showHand)
//           Positioned(
//             right: -24,
//             top: -8,
//             child: Image.asset(
//               'assets/images/download (3).png',
//               width: 160,
//               fit: BoxFit.contain,
//             ),
//           ),
//         Padding(
//           padding: EdgeInsets.only(top: showHand ? 36 : 0),
//           child: const LandingTransferPreviewCard(),
//         ),
//       ],
//     );
//   }
// }

// class _HeroDecorShape extends StatelessWidget {
//   const _HeroDecorShape({
//     required this.width,
//     required this.height,
//     required this.color,
//   });

//   final double width;
//   final double height;
//   final Color color;

//   @override
//   Widget build(BuildContext context) {
//     return Icon(Icons.brightness_7_rounded, size: width, color: color);
//   }
// }

class LandingTransferPreviewCard extends StatelessWidget {
  const LandingTransferPreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: AppColors.neutral0,
        border: Border.all(color: AppColors.neutral900.withValues(alpha: 0.08)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 32,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stackAmounts = constraints.maxWidth < 420;
          final amountRow =
              stackAmounts
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _AmountBlock(
                        label: LandingCopy.previewYouSendLabel,
                        symbol: LandingCopy.previewYouSendSymbol,
                        amount: LandingCopy.previewYouSend,
                        currency: LandingCopy.previewYouSendCurrency,
                      ),
                      const SizedBox(height: 12),
                      const Icon(
                        Icons.arrow_downward_rounded,
                        color: AppColors.orange500,
                      ),
                      const SizedBox(height: 12),
                      _AmountBlock(
                        label: LandingCopy.previewReceiverGetsLabel,
                        symbol: LandingCopy.previewReceiverSymbol,
                        amount: LandingCopy.previewReceiverGets,
                        currency: LandingCopy.previewReceiverCurrency,
                        highlight: true,
                      ),
                    ],
                  )
                  : Row(
                    children: [
                      Expanded(
                        child: _AmountBlock(
                          label: LandingCopy.previewYouSendLabel,
                          symbol: LandingCopy.previewYouSendSymbol,
                          amount: LandingCopy.previewYouSend,
                          currency: LandingCopy.previewYouSendCurrency,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.orange500,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _AmountBlock(
                          label: LandingCopy.previewReceiverGetsLabel,
                          symbol: LandingCopy.previewReceiverSymbol,
                          amount: LandingCopy.previewReceiverGets,
                          currency: LandingCopy.previewReceiverCurrency,
                          highlight: true,
                        ),
                      ),
                    ],
                  );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              amountRow,
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F4EE),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _PreviewRow(
                      label: LandingCopy.previewFeeLabel,
                      value: LandingCopy.previewFee,
                      valueColor: AppColors.success500,
                    ),
                    const SizedBox(height: 8),
                    _PreviewRow(
                      label: LandingCopy.previewTotalLabel,
                      value: LandingCopy.previewTotal,
                    ),
                    const SizedBox(height: 8),
                    _PreviewRow(
                      label: LandingCopy.previewRateLabel,
                      value: LandingCopy.previewRate,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              LandingCopyableText(
                LandingCopy.previewDeliveryMethodLabel.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Chirp',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: AppColors.neutral700,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.neutral0,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.neutral900.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.success500.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.account_balance_rounded,
                        size: 18,
                        color: AppColors.success500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LandingCopy.previewDeliveryMethod,
                            style: const TextStyle(
                              fontFamily: 'Chirp',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.neutral900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Transfers within minutes',
                            style: TextStyle(
                              fontFamily: 'Chirp',
                              fontSize: 13,
                              color: AppColors.neutral700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.neutral700,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed:
                      () =>
                          Navigator.of(context).pushNamed(AppRoute.signupPath),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.orange500,
                    foregroundColor: AppColors.neutral0,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text(
                    LandingCopy.previewSendCta,
                    style: TextStyle(
                      fontFamily: 'Chirp',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AmountBlock extends StatelessWidget {
  const _AmountBlock({
    required this.label,
    required this.symbol,
    required this.amount,
    required this.currency,
    this.highlight = false,
  });

  final String label;
  final String symbol;
  final String amount;
  final String currency;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LandingCopyableText(
          label,
          style: const TextStyle(
            fontFamily: 'Chirp',
            fontSize: 13,
            color: AppColors.neutral700,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LandingCopyableText(
              symbol,
              style: TextStyle(
                fontFamily: 'FunnelDisplay',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: highlight ? AppColors.orange500 : AppColors.neutral900,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                amount,
                style: TextStyle(
                  fontFamily: 'FunnelDisplay',
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: highlight ? AppColors.orange500 : AppColors.neutral900,
                ),
              ),
            ),
          ],
        ),
        LandingCopyableText(
          currency,
          style: const TextStyle(
            fontFamily: 'Chirp',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral900,
          ),
        ),
      ],
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        LandingCopyableText(
          label,
          style: const TextStyle(
            fontFamily: 'Chirp',
            fontSize: 14,
            color: AppColors.neutral700,
          ),
        ),
        LandingCopyableText(
          value,
          style: TextStyle(
            fontFamily: 'Chirp',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.neutral900,
          ),
        ),
      ],
    );
  }
}

class LandingQrDownloadCard extends StatelessWidget {
  const LandingQrDownloadCard({
    super.key,
    this.compact = false,
    this.dashedBorder = false,
  });

  final bool compact;
  final bool dashedBorder;

  @override
  Widget build(BuildContext context) {
    final content =
        compact
            ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_qrCode(), const SizedBox(height: 16), _qrText()],
            )
            : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _qrCode(),
                const SizedBox(width: 16),
                Expanded(child: _qrText()),
              ],
            );

    final padded = Padding(padding: const EdgeInsets.all(20), child: content);

    if (dashedBorder) {
      return CustomPaint(
        painter: _LandingDashedBorderPainter(
          color: AppColors.neutral900.withValues(alpha: 0.35),
          radius: 20,
          strokeWidth: 1.2,
          dashWidth: 6,
          dashGap: 5,
        ),
        child: padded,
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.neutral50,
        border: Border.all(color: AppColors.neutral900.withValues(alpha: 0.08)),
      ),
      child: content,
    );
  }

  Widget _qrCode() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: QrImageView(
        data: LandingCopy.qrUrl,
        version: QrVersions.auto,
        size: 88,
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget _qrText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LandingCopyableText(
          dashedBorder ? LandingCopy.heroQrScanText : LandingCopy.qrSubtitle,
          style: const TextStyle(
            fontFamily: 'Chirp',
            fontSize: 14,
            height: 1.5,
            color: AppColors.neutral900,
          ),
        ),
        const SizedBox(height: 14),
        const Row(
          children: [
            Icon(Icons.apple, color: AppColors.neutral900, size: 22),
            SizedBox(width: 12),
            Icon(Icons.android, color: AppColors.neutral900, size: 22),
          ],
        ),
      ],
    );
  }
}

class _LandingDashedBorderPainter extends CustomPainter {
  const _LandingDashedBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashGap,
  });

  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;

    final path =
        Path()..addRRect(
          RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
        );

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, end.clamp(0, metric.length)),
          paint,
        );
        distance += dashWidth + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LandingDashedBorderPainter oldDelegate) {
    return color != oldDelegate.color ||
        radius != oldDelegate.radius ||
        strokeWidth != oldDelegate.strokeWidth ||
        dashWidth != oldDelegate.dashWidth ||
        dashGap != oldDelegate.dashGap;
  }
}

class LandingDeliveryHighlightsSection extends StatelessWidget {
  const LandingDeliveryHighlightsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = constraints.maxWidth;
        final isMobile = WebLayout.isMobile(contentWidth);
        final children =
            LandingCopy.deliveryHighlights
                .map(
                  (block) =>
                      _HighlightCard(block: block, contentWidth: contentWidth),
                )
                .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isMobile)
              Column(
                children:
                    LandingCopy.deliveryHighlights
                        .map(
                          (b) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _HighlightCard(
                              block: b,
                              contentWidth: contentWidth,
                            ),
                          ),
                        )
                        .toList(),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < children.length; i++) ...[
                    if (i > 0) const SizedBox(width: 20),
                    children[i],
                  ],
                ],
              ),
            const SizedBox(height: 48),
            Padding(
              padding: EdgeInsets.only(
                right: WebLayout.sectionRightInset(
                  contentWidth,
                  fraction: 0.25,
                ),
              ),
              child: LandingCopyableText(
                LandingCopy.deliveryMethodsTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontFamily: 'FunnelDisplay',
                  fontSize: isMobile ? 68 : 112,
                  fontWeight: FontWeight.w400,
                  height: 1,
                  letterSpacing: -2,
                ),
              ),
            ),
            SizedBox(height: WebLayout.sectionBottomSpacing(contentWidth)),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: LandingCopy.deliveryMethods.length,
              itemBuilder: (context, index) {
                return _DeliveryMethodCard(
                  method: LandingCopy.deliveryMethods[index],
                  contentWidth: contentWidth,
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({required this.block, required this.contentWidth});

  final LandingHighlightBlock block;
  final double contentWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = WebLayout.isMobile(contentWidth);
    return Padding(
      padding: EdgeInsets.only(
        bottom: WebLayout.sectionLargeRightInset(contentWidth),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,

            padding: EdgeInsets.only(
              right: WebLayout.sectionLargeRightInset(contentWidth),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LandingCopyableText(
                  block.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontFamily: 'FunnelDisplay',
                    fontSize: isMobile ? 68 : 112,
                    fontWeight: FontWeight.w400,
                    height: 1,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(height: 40),
                LandingCopyableText(
                  block.body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Chirp',
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.w400,
                    height: 1.55,
                    letterSpacing: 0.2,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40 * 2),
          Align(
            alignment: Alignment.centerRight,
            child: SvgPicture.asset(block.icon, height: 60 * 9),
          ),
        ],
      ),
    );
  }
}

class _DeliveryMethodCard extends StatelessWidget {
  const _DeliveryMethodCard({required this.method, required this.contentWidth});

  final LandingDeliveryMethod method;
  final double contentWidth;

  String _icon() {
    switch (method.iconName) {
      case 'bank':
        return 'assets/icons/svgs/building-bank.svg';
      case 'mobile':
        return 'assets/icons/svgs/device-mobile.svg';
      case 'id':
        return 'assets/icons/svgs/at.svg';
      case 'bills':
        return 'assets/icons/svgs/invoice_c.svg';
      default:
        return 'assets/icons/svgs/building-bank.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = WebLayout.isMobile(contentWidth);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            right: WebLayout.sectionExtraRightInset(contentWidth),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SizedBox(
              //   width: 60,
              //   height: 60,
              //   child: Stack(
              //     alignment: Alignment.center,
              //     children: [
              //       SvgPicture.asset(
              //         'assets/icons/svgs/swap.svg',
              //         width: 60,
              //         height: 60,
              //         colorFilter: ColorFilter.mode(
              //           AppColors.orange500,
              //           BlendMode.srcIn,
              //         ),
              //       ),
              //       SvgPicture.asset(
              //         _icon(),
              //         width: 40,
              //         height: 40,
              //         colorFilter: ColorFilter.mode(
              //           AppColors.neutral0,
              //           BlendMode.srcIn,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              // const SizedBox(height: 12),
              LandingCopyableText(
                method.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: 'Chirp',
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.w500,
                  height: 1.55,
                  letterSpacing: 0.2,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              LandingCopyableText(
                method.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Chirp',
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w400,
                  height: 1.55,
                  letterSpacing: 0.2,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 48),
        Container(
          padding: const EdgeInsets.all(20),
          margin: EdgeInsets.only(
            bottom: WebLayout.sectionBottomSpacing(contentWidth, fraction: 0.1),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(64),
            color: AppColors.orange500.withValues(alpha: 0.06),
          ),
          child: SizedBox(width: double.infinity, height: 500),
        ),
      ],
    );
  }
}

class LandingSecuritySection extends StatelessWidget {
  const LandingSecuritySection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = constraints.maxWidth;
        final isMobile = WebLayout.isMobile(contentWidth);
        final badges =
            LandingCopy.securityBadges
                .map(
                  (b) =>
                      _SecurityBadgeCard(badge: b, contentWidth: contentWidth),
                )
                .toList();

        return SizedBox(
          width: double.infinity,
          // padding: const EdgeInsets.all(32),
          // decoration: BoxDecoration(
          //   borderRadius: BorderRadius.circular(20),
          //   gradient: LinearGradient(
          //     begin: Alignment.topLeft,
          //     end: Alignment.bottomRight,
          //     colors:
          //         isDark
          //             ? [AppColors.neutral900, AppColors.neutral800]
          //             : [AppColors.neutral50, AppColors.neutral0],
          //   ),
          //   border: Border.all(
          //     color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.12),
          //   ),
          // ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  right: WebLayout.sectionRightInset(
                    contentWidth,
                    fraction: 0.28,
                  ),
                ),
                child: Column(
                  children: [
                    LandingCopyableText(
                      LandingCopy.securityTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontFamily: 'FunnelDisplay',
                        fontSize: isMobile ? 68 : 112,
                        fontWeight: FontWeight.w400,
                        height: 1,
                        letterSpacing: -2,
                      ),
                    ),
                    const SizedBox(height: 40),
                    LandingCopyableText(
                      LandingCopy.securitySubtitle,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontFamily: 'Chirp',
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.w400,
                        height: 1.55,
                        letterSpacing: 0.2,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 72),
              if (isMobile)
                Column(
                  children:
                      badges
                          .map(
                            (w) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: w,
                            ),
                          )
                          .toList(),
                )
              else
                Column(
                  children: [badges[0], const SizedBox(height: 72), badges[1]],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SecurityBadgeCard extends StatelessWidget {
  const _SecurityBadgeCard({required this.badge, required this.contentWidth});

  final LandingSecurityBadge badge;
  final double contentWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = WebLayout.isMobile(contentWidth);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 72, vertical: 112),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(48),
        // border: Border.all(
        //   color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.15),
        // ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/svgs/swap.svg',
                  width: 60,
                  height: 60,
                  colorFilter: ColorFilter.mode(
                    AppColors.orange500,
                    BlendMode.srcIn,
                  ),
                ),
                ClipRRect(
                  child: SvgPicture.asset(
                    badge.title.contains("NGN")
                        ? "assets/icons/svgs/shield-check.svg"
                        : "assets/icons/svgs/security-safe.svg",
                    width: 40,
                    height: 40,
                    color: LandingSectionColors.hero,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          Text(
            badge.title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontFamily: 'Chirp',
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.w500,
              height: 1.55,
              letterSpacing: 0.2,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          LandingCopyableText(
            badge.description,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'Chirp',
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.w400,
              height: 1.55,
              letterSpacing: 0.2,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class LandingHowItWorksSection extends StatelessWidget {
  const LandingHowItWorksSection({super.key, required this.contentWidth});

  final double contentWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = WebLayout.isMobile(contentWidth);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            right: WebLayout.sectionLargeRightInset(contentWidth),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LandingCopyableText(
                LandingCopy.howItWorksTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontFamily: 'FunnelDisplay',
                  fontSize: isMobile ? 68 : 112,
                  fontWeight: FontWeight.w400,
                  height: 1,
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(height: 40),
              LandingCopyableText(
                LandingCopy.howItWorksSubtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontFamily: 'Chirp',
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w400,
                  height: 1.55,
                  letterSpacing: 0.2,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),
        if (isMobile)
          Column(
            children:
                LandingCopy.howItWorksSteps
                    .map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _StepTile(step: s, contentWidth: contentWidth),
                      ),
                    )
                    .toList(),
          )
        else
          Column(
            children:
                LandingCopy.howItWorksSteps
                    .map((s) => _StepTile(step: s, contentWidth: contentWidth))
                    .toList(),
          ),
      ],
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({required this.step, required this.contentWidth});

  final LandingStep step;
  final double contentWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = WebLayout.isMobile(contentWidth);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(14),
      //   border: Border.all(
      //     color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.15),
      //   ),
      // ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(radius: 8, backgroundColor: AppColors.orange500),
          const SizedBox(width: 18),
          LandingCopyableText(
            step.title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontFamily: 'Chirp',
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.w400,
              height: 1.55,
              letterSpacing: 0.2,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class LandingTestimonialsSection extends StatelessWidget {
  const LandingTestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = constraints.maxWidth;
        final isMobile = WebLayout.isMobile(contentWidth);
        final cards =
            LandingCopy.testimonials
                .map(
                  (t) => _TestimonialCard(
                    testimonial: t,
                    contentWidth: contentWidth,
                  ),
                )
                .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                right: WebLayout.sectionRightInset(
                  contentWidth,
                  fraction: 0.28,
                ),
              ),
              child: LandingCopyableText(
                LandingCopy.testimonialsTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontFamily: 'FunnelDisplay',
                  fontSize: isMobile ? 68 : 112,
                  fontWeight: FontWeight.w400,
                  height: 1,
                  letterSpacing: -2,
                ),
              ),
            ),
            SizedBox(height: WebLayout.sectionVerticalGap(contentWidth) * 1.5),
            if (isMobile)
              Column(
                children:
                    cards
                        .map(
                          (c) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: c,
                          ),
                        )
                        .toList(),
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < cards.length; i++) ...[
                    if (i > 0) const SizedBox(width: 16),
                    Expanded(child: cards[i]),
                  ],
                ],
              ),
          ],
        );
      },
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  const _TestimonialCard({
    required this.testimonial,
    required this.contentWidth,
  });

  final LandingTestimonial testimonial;
  final double contentWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = WebLayout.isMobile(contentWidth);
    return Stack(
      children: [
        Positioned(
          top: 0,
          right: 20,
          child: Icon(
            Icons.format_quote_rounded,
            color: AppColors.orange500.withValues(alpha: 0.7),
            size: isMobile ? 64 : 112,
          ),
        ),
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: isMobile ? 16 : 48),
          padding: const EdgeInsets.symmetric(horizontal: 54, vertical: 112),
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(48),
            // border: Border.all(
            //   color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.15),
            // ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LandingCopyableText(
                testimonial.name,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontFamily: 'Chirp',
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.w500,
                  height: 1.55,
                  letterSpacing: 0.2,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              LandingCopyableText(
                testimonial.quote,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Chirp',
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w300,
                  height: 1.55,
                  letterSpacing: 0.2,
                  color: theme.colorScheme.onSurface,
                ),
              ),

              // const SizedBox(height: 12),
              // LandingCopyableText(
              //   testimonial.location,
              //   style: theme.textTheme.bodySmall?.copyWith(
              //     fontFamily: 'Chirp',
              //     fontSize: isMobile ? 16 : 18,
              //     fontWeight: FontWeight.w400,
              //     height: 1.55,
              //     letterSpacing: 0.2,
              //     color: theme.colorScheme.onSurface,
              //   ),
              // ),
            ],
          ),
        ),
      ],
    );
  }
}

class LandingFaqSection extends StatefulWidget {
  const LandingFaqSection({super.key});

  @override
  State<LandingFaqSection> createState() => _LandingFaqSectionState();
}

class _LandingFaqSectionState extends State<LandingFaqSection> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = constraints.maxWidth;
        final isMobile = WebLayout.isMobile(contentWidth);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LandingCopyableText(
              LandingCopy.faqTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontFamily: 'FunnelDisplay',
                fontSize: isMobile ? 68 : 112,
                fontWeight: FontWeight.w400,
                height: 1,
                letterSpacing: -2,
              ),
            ),
            SizedBox(height: WebLayout.sectionVerticalGap(contentWidth) * 1.5),
            ...LandingCopy.faqs.asMap().entries.map((entry) {
              final index = entry.key;
              final faq = entry.value;
              return _LandingFaqTile(
                faq: faq,
                expanded: _expandedIndex == index,
                isMobile: isMobile,
                onTap:
                    () => setState(
                      () =>
                          _expandedIndex =
                              _expandedIndex == index ? null : index,
                    ),
                onHover: (hovering) {
                  setState(() {
                    if (hovering) {
                      _expandedIndex = index;
                    } else if (_expandedIndex == index) {
                      _expandedIndex = null;
                    }
                  });
                },
              );
            }),
            const SizedBox(height: 16),
            // TextButton(
            //   onPressed: () => Navigator.of(context).pushNamed(AppRoute.webFaqPath),
            //   child: Text(
            //     LandingCopy.faqSupportCta,
            //     style: const TextStyle(
            //       fontFamily: 'Chirp',
            //       fontWeight: FontWeight.w600,
            //     ),
            //   ),
            // ),
          ],
        );
      },
    );
  }
}

class _LandingFaqTile extends StatelessWidget {
  const _LandingFaqTile({
    required this.faq,
    required this.expanded,
    required this.isMobile,
    required this.onTap,
    required this.onHover,
  });

  final LandingFaq faq;
  final bool expanded;
  final bool isMobile;
  final VoidCallback onTap;
  final void Function(bool hovering) onHover;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(56),
          onTap: onTap,
          onHover: onHover,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 360),
            curve: Curves.easeInOutCubic,
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 28 : 88,
              vertical: expanded ? 44 : 36,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(
                alpha: expanded ? 0.22 : 0.15,
              ),
              borderRadius: BorderRadius.circular(56),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        faq.question,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontFamily: 'Chirp',
                          fontSize: isMobile ? 20 : 24,
                          fontWeight: FontWeight.w400,
                          height: 1.55,
                          letterSpacing: 0.2,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 360),
                  curve: Curves.easeInOutCubic,
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.hardEdge,
                  child:
                      expanded
                          ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 24),
                              LandingCopyableText(
                                faq.answer,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontFamily: 'Chirp',
                                  fontSize: isMobile ? 16 : 18,
                                  fontWeight: FontWeight.w400,
                                  height: 1.55,
                                  letterSpacing: 0.2,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          )
                          : const SizedBox(width: double.infinity),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LandingBeatingHeart extends StatefulWidget {
  const _LandingBeatingHeart({required this.size});

  final double size;

  @override
  State<_LandingBeatingHeart> createState() => _LandingBeatingHeartState();
}

class _LandingBeatingHeartState extends State<_LandingBeatingHeart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1,
          end: 1.14,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 14,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.14,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 14,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1,
          end: 1.1,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 12,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.1,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 12,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(1), weight: 28),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: SvgPicture.asset(
        'assets/icons/svgs/vecteezy_heart-vector-design_27875990.svg',
        height: widget.size,
        width: widget.size,
      ),
    );
  }
}

class LandingFinalCtaSection extends StatelessWidget {
  const LandingFinalCtaSection({super.key, required this.contentWidth});

  final double contentWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = WebLayout.isMobile(contentWidth);

    return Column(
      children: [
        LandingCopyableText(
          LandingCopy.finalCtaTitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontFamily: 'FunnelDisplay',
            fontSize: isMobile ? 68 : 112,
            fontWeight: FontWeight.w400,
            height: 1,
            letterSpacing: -2,
          ),
        ),

        SizedBox(height: WebLayout.sectionVerticalGap(contentWidth) * 2),

        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 64 : 142),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(48 * 2),
            color: AppColors.orange500.withValues(alpha: 0.1),
          ),
          child: Column(
            children: [
              if (isMobile)
                Opacity(
                  opacity: 0,
                  child: Column(
                    children: [
                      const LandingQrDownloadCard(compact: true),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed:
                            () => Navigator.of(
                              context,
                            ).pushNamed(AppRoute.signupPath),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.orange500,
                          foregroundColor: AppColors.neutral0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Text(LandingCopy.finalCtaButton),
                      ),
                    ],
                  ),
                )
              else
                Opacity(
                  opacity: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 280,
                        child: LandingQrDownloadCard(),
                      ),
                      const SizedBox(width: 40),
                      FilledButton(
                        onPressed:
                            () => Navigator.of(
                              context,
                            ).pushNamed(AppRoute.signupPath),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.orange500,
                          foregroundColor: AppColors.neutral0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Text(
                          LandingCopy.finalCtaButton,
                          style: const TextStyle(
                            fontFamily: 'Chirp',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        SizedBox(height: WebLayout.sectionVerticalGap(contentWidth) * 3),

        LandingCopyableText(
          "Put your money where your heart is",
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontFamily: 'FunnelDisplay',
            fontSize: isMobile ? 68 : 112,
            fontWeight: FontWeight.w400,
            height: 1,
            letterSpacing: -2,
          ),
        ),

        SizedBox(height: WebLayout.sectionVerticalGap(contentWidth) * 2),

        _LandingBeatingHeart(size: isMobile ? 80 * 1.5 : 112 * 2.5),
      ],
    );
  }
}
