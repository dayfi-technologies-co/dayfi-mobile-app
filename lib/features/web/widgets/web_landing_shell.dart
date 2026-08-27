import 'package:dayfi/common/utils/dayfi_platform.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/web/constants/landing_copy.dart';
import 'package:dayfi/features/web/utils/open_external_url.dart';
import 'package:dayfi/features/web/utils/web_layout.dart';
import 'package:dayfi/features/web/widgets/landing/landing_cookie_banner.dart';
import 'package:dayfi/features/web/widgets/landing/landing_copyable_text.dart';
import 'package:dayfi/features/web/widgets/landing/landing_sections.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/services/local/intercom_support_service.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';

class WebLandingShell extends StatefulWidget {
  const WebLandingShell({
    super.key,
    required this.child,
    this.activeRoute,
    this.showFooter = true,
    this.fullWidthChild = false,
  });

  final Widget child;
  final String? activeRoute;
  final bool showFooter;

  /// When true, [child] spans the full viewport width (for full-bleed section bands).
  final bool fullWidthChild;

  @override
  State<WebLandingShell> createState() => _WebLandingShellState();
}

class _WebLandingShellState extends State<WebLandingShell> {
  bool _menuOpen = false;

  void _navigate(String route) {
    setState(() => _menuOpen = false);
    if (route == '_contact') {
      IntercomSupportService.openContactSupport();
      return;
    }
    if (route == '_cookie_settings') {
      resetWebCookieConsent();
      return;
    }
    if (ModalRoute.of(context)?.settings.name == route) return;
    Navigator.of(context).pushNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface =
        isDark ? AppColors.neutral950 : AppColors.splashBackgroundLight;
    return Scaffold(
      backgroundColor: surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final viewportWidth = constraints.maxWidth;
            final isMobile = WebLayout.isMobile(viewportWidth);
            final pagePadding = WebLayout.pagePadding(viewportWidth);
            final contentWidth = WebLayout.contentMaxWidth(viewportWidth);

            return Stack(
              children: [
                SelectionArea(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ColoredBox(
                          color: LandingSectionColors.hero,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _WebHeaderBar(
                                theme: theme,
                                contentWidth: contentWidth,
                                pagePadding: pagePadding,
                                isMobile: isMobile,
                                activeRoute: widget.activeRoute,
                                menuOpen: _menuOpen,
                                onToggleMenu:
                                    () =>
                                        setState(() => _menuOpen = !_menuOpen),
                                onNavigate: _navigate,
                              ),
                              if (widget.fullWidthChild) widget.child,
                            ],
                          ),
                        ),

                        if (!widget.fullWidthChild)
                          Center(
                            child: SizedBox(
                              width: contentWidth,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: pagePadding,
                                ),
                                child: widget.child,
                              ),
                            ),
                          ),
                        if (widget.showFooter)
                          WebFooter(
                            activeRoute: widget.activeRoute,
                            onNavigate: _navigate,
                          ),
                        // const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: LandingCookieBanner(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _WebHeaderBar extends StatelessWidget {
  const _WebHeaderBar({
    required this.theme,
    required this.contentWidth,
    required this.pagePadding,
    required this.isMobile,
    required this.activeRoute,
    required this.menuOpen,
    required this.onToggleMenu,
    required this.onNavigate,
  });

  final ThemeData theme;
  final double contentWidth;
  final double pagePadding;
  final bool isMobile;
  final String? activeRoute;
  final bool menuOpen;
  final VoidCallback onToggleMenu;
  final void Function(String route) onNavigate;

  static const _headerNav = <_NavLink>[
    _NavLink(LandingCopy.navContact, '_contact'),
    _NavLink(LandingCopy.navLogin, AppRoute.loginPath),
    _NavLink(LandingCopy.navSignUp, AppRoute.signupPath),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: SizedBox(
              width: contentWidth,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: pagePadding),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => onNavigate(AppRoute.webLandingView),
                      borderRadius: BorderRadius.circular(8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/logo_splash.png',
                            width: 32,
                            height: 32,
                          ),
                          // const SizedBox(width: 10),
                          // LandingCopyableText(
                          //   LandingCopy.brandName,
                          //   style: theme.textTheme.titleLarge?.copyWith(
                          //     fontFamily: 'FunnelDisplay',
                          //     fontWeight: FontWeight.w700,
                          //     letterSpacing: -0.5,
                          //     color: AppColors.neutral900,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (isMobile)
                      IconButton(
                        onPressed: onToggleMenu,
                        icon: Icon(
                          menuOpen ? Icons.close : Icons.menu,
                          color: AppColors.neutral900,
                        ),
                      )
                    else
                      ..._headerNav.map((link) => _buildNavLink(link)),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (isMobile && menuOpen)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Center(
              child: SizedBox(
                width: contentWidth,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: pagePadding),
                  child: Column(
                    children: _headerNav.map(_buildNavLink).toList(),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNavLink(_NavLink link) {
    final isSignUp = link.route == AppRoute.signupPath;
    if (isSignUp) {
      return Padding(
        padding: EdgeInsets.only(
          left: isMobile ? 0 : 16,
          top: isMobile ? 16 : 0,
          bottom: isMobile ? 4 : 0,
        ),
        child: SizedBox(
          width: isMobile ? double.infinity : null,
          child: FilledButton(
            onPressed: () => onNavigate(link.route),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.orange500,
              foregroundColor: AppColors.neutral0,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 32 : 40,
                vertical: 22,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(56),
              ),
            ),
            child: Text(
              link.label,
              style: const TextStyle(
                fontFamily: 'Chirp',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    return _HeaderNavItem(
      label: link.label,
      isActive: activeRoute == link.route,
      onTap: () => onNavigate(link.route),
    );
  }
}

class _NavLink {
  const _NavLink(this.label, this.route);
  final String label;
  final String route;
}

class _HeaderNavItem extends StatefulWidget {
  const _HeaderNavItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_HeaderNavItem> createState() => _HeaderNavItemState();
}

class _HeaderNavItemState extends State<_HeaderNavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isActive ? AppColors.orange500 : AppColors.neutral700;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: Text(
            widget.label,
            style: TextStyle(
              fontFamily: 'Chirp',
              fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
              color: color,
              decoration:
                  _hovered ? TextDecoration.underline : TextDecoration.none,
              decorationColor: color,
            ),
          ),
        ),
      ),
    );
  }
}

class WebFooter extends StatelessWidget {
  const WebFooter({
    super.key,
    required this.activeRoute,
    required this.onNavigate,
  });

  final String? activeRoute;
  final void Function(String route) onNavigate;

  static const _footerBackground = Color(0xFF1A1A1A);
  static const _footerMuted = Color(0xFFB8B8B8);
  static const _footerHeading = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _footerBackground,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final viewportWidth = constraints.maxWidth;
          final contentWidth = WebLayout.contentMaxWidth(viewportWidth);
          final pagePadding = WebLayout.pagePadding(viewportWidth);
          final isMobile = WebLayout.isMobile(viewportWidth);

          return Center(
            child: SizedBox(
              width: contentWidth,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  pagePadding,
                  isMobile ? 88 : 164,
                  pagePadding,
                  isMobile ? 0 : 0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isMobile) ...[
                      const _FooterQrPanel(),
                      const SizedBox(height: 40),
                      _FooterLinksGrid(
                        activeRoute: activeRoute,
                        onNavigate: onNavigate,
                        isMobile: true,
                      ),
                    ] else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 6,
                            child: Row(children: [_FooterQrPanel()]),
                          ),
                          const SizedBox(width: 72),
                          Expanded(
                            flex: 7,
                            child: _FooterLinksGrid(
                              activeRoute: activeRoute,
                              onNavigate: onNavigate,
                              isMobile: false,
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: isMobile ? 48 : 72),
                    ...LandingCopy.footerLegalFinePrint.map(
                      (paragraph) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: LandingCopyableText(
                          paragraph,
                          style: const TextStyle(
                            fontFamily: 'Chirp',
                            fontSize: 14,
                            height: 1.6,
                            color: _footerMuted,
                          ),
                        ),
                      ),
                    ),

                    // _FooterPagePills(
                    //   onNavigate: onNavigate,
                    //   isMobile: isMobile,
                    // ),
                    // const SizedBox(height: 40),
                    _FooterSocialPills(isMobile: isMobile),

                    SizedBox(height: isMobile ? 32 : 48),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FooterQrPanel extends StatelessWidget {
  const _FooterQrPanel();

  @override
  Widget build(BuildContext context) {
    final qrCode = Container(
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

      // QrImageView(
      //   data: LandingCopy.qrUrl,
      //   version: QrVersions.auto,
      //   size: 88,
      //   backgroundColor: Colors.white,
      // ),
    );

    // final qrCopy = Column(
    //   crossAxisAlignment: CrossAxisAlignment.start,
    //   children: [
    //     LandingCopyableText(
    //       LandingCopy.footerQrScanText,
    //       style: const TextStyle(
    //         fontFamily: 'Chirp',
    //         fontSize: 14,
    //         height: 1.5,
    //         color: _WebFooter._footerHeading,
    //       ),
    //     ),
    //     const SizedBox(height: 14),
    //     const Row(
    //       children: [
    //         Icon(Icons.apple, color: _WebFooter._footerHeading, size: 22),
    //         SizedBox(width: 12),
    //         Icon(Icons.android, color: _WebFooter._footerHeading, size: 22),
    //       ],
    //     ),
    //   ],
    // );

    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 360;
        return CustomPaint(
          painter: DashedBorderPainter(
            color: WebFooter._footerHeading.withValues(alpha: .35),
            radius: 20,
            strokeWidth: 1.2,
            dashWidth: 6,
            dashGap: 2,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: stacked ? qrCode : qrCode,
          ),
        );
      },
    );
  }
}

class _FooterLinksGrid extends StatelessWidget {
  const _FooterLinksGrid({
    required this.activeRoute,
    required this.onNavigate,
    required this.isMobile,
  });

  final String? activeRoute;
  final void Function(String route) onNavigate;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final companyColumn = _FooterLinkColumn(
      title: LandingCopy.footerCompanyTitle,
      links: LandingCopy.footerCompanyLinks,
      activeRoute: activeRoute,
      onNavigate: onNavigate,
      isMobile: isMobile,
      trailing: _FooterLinkColumn(
        title: LandingCopy.footerLegalTitle,
        links: LandingCopy.footerLegalLinks,
        activeRoute: activeRoute,
        onNavigate: onNavigate,
        isMobile: isMobile,
        topSpacing: 48,
      ),
    );

    final supportColumn = _FooterLinkColumn(
      title: LandingCopy.footerSupportTitle,
      links: LandingCopy.footerSupportLinks,
      activeRoute: activeRoute,
      onNavigate: onNavigate,
      isMobile: isMobile,
    );

    final sendColumn = _FooterLinkColumn(
      title: LandingCopy.footerSendTitle,
      links: LandingCopy.footerSendLinks,
      activeRoute: activeRoute,
      onNavigate: onNavigate,
      isMobile: isMobile,
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          companyColumn,
          const SizedBox(height: 32),
          supportColumn,
          const SizedBox(height: 32),
          sendColumn,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: companyColumn),
        const SizedBox(width: 40),
        Expanded(flex: 3, child: supportColumn),
        const SizedBox(width: 40),
        Expanded(flex: 3, child: sendColumn),
      ],
    );
  }
}

class _FooterLinkColumn extends StatelessWidget {
  const _FooterLinkColumn({
    required this.title,
    required this.links,
    required this.activeRoute,
    required this.onNavigate,
    required this.isMobile,
    this.trailing,
    this.topSpacing = 0,
  });

  final String title;
  final List<LandingFooterLink> links;
  final String? activeRoute;
  final void Function(String route) onNavigate;
  final bool isMobile;
  final Widget? trailing;
  final double topSpacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (topSpacing > 0) SizedBox(height: topSpacing),
        LandingCopyableText(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontFamily: 'Chirp',
            fontSize: isMobile ? 17 : 19,
            fontWeight: FontWeight.w600,
            height: 1.55,
            letterSpacing: 0.2,

            color: WebFooter._footerHeading,
          ),
        ),
        const SizedBox(height: 16),
        ...links.map(
          (link) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Align(
              alignment: Alignment.centerLeft,
              child: _FooterHoverLink(
                label: link.label,
                isActive: activeRoute == link.route,
                isMobile: isMobile,
                onTap: () => onNavigate(link.route),
              ),
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _FooterHoverLink extends StatefulWidget {
  const _FooterHoverLink({
    required this.label,
    required this.isActive,
    required this.isMobile,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final bool isMobile;
  final VoidCallback onTap;

  @override
  State<_FooterHoverLink> createState() => _FooterHoverLinkState();
}

class _FooterHoverLinkState extends State<_FooterHoverLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color =
        widget.isActive ? AppColors.orange500 : WebFooter._footerMuted;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Text(
          widget.label,
          style: TextStyle(
            fontFamily: 'Chirp',
            fontSize: widget.isMobile ? 14 : 16,
            fontWeight: FontWeight.w400,
            height: 1.55,
            letterSpacing: 0.2,
            color: color,
            decoration:
                _hovered ? TextDecoration.underline : TextDecoration.none,
            decorationColor: color,
          ),
        ),
      ),
    );
  }
}

class _FooterSocialPills extends StatelessWidget {
  const _FooterSocialPills({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final pills = LandingCopy.footerSocialPills;

    if (isMobile) {
      return Wrap(
        spacing: 12,
        runSpacing: 16,
        alignment: WrapAlignment.center,
        children: [
          for (final pill in pills) _FooterSocialTiltedPill(pill: pill),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return SizedBox(
          height: 400,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Positioned(
              //   left: 0,
              //   top: 8,
              //   child: _FooterScallopIcon(
              //     child: SvgPicture.asset(
              //       'assets/icons/svgs/vecteezy_heart-vector-design_27875990.svg',
              //       width: 28,
              //       height: 28,
              //       colorFilter: const ColorFilter.mode(
              //         AppColors.orange500,
              //         BlendMode.srcIn,
              //       ),
              //     ),
              //   ),
              // ),
              Positioned(
                left: 150,
                top: 180,
                child: _FooterSocialTiltedPill(pill: pills[1]),
              ),
              Positioned(
                left: width * 0.30,
                top: 0,
                child: _FooterSocialTiltedPill(pill: pills[3]),
              ),
              Positioned(
                left: width * 0.42,
                top: 280,
                child: _FooterSocialTiltedPill(pill: pills[2]),
              ),
              Positioned(
                right: 220,
                top: 145,
                child: _FooterSocialTiltedPill(pill: pills[0]),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FooterSocialTiltedPill extends StatelessWidget {
  const _FooterSocialTiltedPill({required this.pill});

  final LandingFooterSocialPill pill;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: pill.rotationDegrees * 3.14159 / 180,
      child: Material(
        color: pill.backgroundColor,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: () => openExternalUrl(pill.url),
          borderRadius: BorderRadius.circular(999),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: pill.backgroundColor.withValues(alpha: 0.85),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            child: Text(
              pill.label,
              style: TextStyle(
                fontFamily: 'Chirp',
                fontSize: 40,
                fontWeight: FontWeight.w300,
                letterSpacing: 1.5,
                color: pill.foregroundColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  const DashedBorderPainter({
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

    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rect);
    final metrics = path.computeMetrics().toList();

    for (final metric in metrics) {
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
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) {
    return color != oldDelegate.color ||
        radius != oldDelegate.radius ||
        strokeWidth != oldDelegate.strokeWidth ||
        dashWidth != oldDelegate.dashWidth ||
        dashGap != oldDelegate.dashGap;
  }
}

/// Wraps [child] in [WebLandingShell] on web; returns [child] unchanged on native.
Widget wrapWithWebShellIfNeeded({
  required Widget child,
  String? activeRoute,
  bool showFooter = true,
}) {
  if (!isDayfiWeb) return child;
  return WebLandingShell(
    activeRoute: activeRoute,
    showFooter: showFooter,
    child: child,
  );
}
