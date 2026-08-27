import 'package:dayfi/common/constants/product_features.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/utils/haptic_helper.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
// import 'package:dayfi/common/widgets/buttons/secondary_button.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/dayflow/constants/dayflow_copy.dart';
import 'package:dayfi/features/pay/widgets/pay_bill_icon_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// DayFlow / DayEarn promo row above Assets on Home.
class HomePromoBannersRow extends StatelessWidget {
  final VoidCallback onDayFlow;
  final VoidCallback onEarn;

  const HomePromoBannersRow({
    super.key,
    required this.onDayFlow,
    required this.onEarn,
  });

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      if (ProductFeatures.dayEarnHomePromo) ...[
        Expanded(
          child: _PromoBanner(
            onTap: onEarn,
            innerIconAsset: 'assets/icons/svgs/clock-dollar.svg',
            accentColor: AppColors.purple600,
            title: 'DayEarn',
            subtitle: 'Earn up to 20% annually',
          ),
        ),
        const SizedBox(width: 8),
      ],
      Expanded(
        child: _PromoBanner(
          onTap: onDayFlow,
          innerIconAsset: 'assets/icons/svgs/automation.svg',
          accentColor: AppColors.teal600,
          title: DayFlowCopy.featureName,
          subtitle: DayFlowCopy.homeSubtitle,
        ),
      ),
    ];

    return Row(children: children);
  }
}

class _PromoBanner extends StatelessWidget {
  final VoidCallback onTap;
  final String innerIconAsset;
  final String title;
  final String subtitle;
  final Color accentColor;
  final String? badge;
  final bool isComingSoon;

  const _PromoBanner({
    required this.onTap,
    required this.innerIconAsset,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    // ignore: unused_element_parameter
    this.isComingSoon = false,
    // ignore: unused_element_parameter
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final surface = Theme.of(context).colorScheme.surface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: accentColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            // gradient: LinearGradient(
            //   begin: Alignment.topLeft,
            //   end: Alignment.bottomRight,
            //   colors: [
            //     accentColor.withValues(alpha: isDark ? 0.24 : 0.14),
            //     accentColor.withValues(alpha: isDark ? 0.10 : 0.05),
            //   ],
            // ),
            color: surface,
            borderRadius: BorderRadius.circular(16),
            // border: Border.all(color: accentColor.withValues(alpha: 0.20)),
          ),
          child: SizedBox(
            height: 118,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ColorfulIconBadge(
                        innerIconAsset: innerIconAsset,
                        accentColor: accentColor,
                      ),
                      const Spacer(),
                      if (badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary400.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            badge!,
                            style: TextStyle(
                              fontFamily: 'Chirp',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary400,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),

                      if (isComingSoon)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Coming soon',
                            style: AppTypography.labelSmall.copyWith(
                              fontFamily: 'Chirp',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Chirp',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      letterSpacing: -0.05,
                      height: 1.2,
                      color: onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Chirp',
                      fontSize: 12.5,
                      height: 1.25,
                      color: onSurface.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Filled accent circle + white glyph used by the colorful Home promo banners.
class _ColorfulIconBadge extends StatelessWidget {
  const _ColorfulIconBadge({
    required this.innerIconAsset,
    required this.accentColor,
  });

  final String innerIconAsset;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          // decoration: BoxDecoration(shape: BoxShape.circle, ),
          child: Center(
            child: SvgPicture.asset(
              "assets/icons/svgs/recipients.svg",
              width: 40,
              height: 40,
              color: accentColor,
            ),
          ),
        ),
        Center(
          child: SvgPicture.asset(
            innerIconAsset,
            width: 26,
            height: 26,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
      ],
    );
  }
}

const _kTapToPayNotifyKey = 'tap_to_pay_notify_opt_in';
const _kTapToPayHeroAsset = 'assets/images/Tap-to-Pay-pop-up-v3.webp';
const _kCardNetworksLogo =
    'assets/images/visa-and-mastercard-logo-featuring-overlapping-circles-on-a-white-background-free-vector.jpg';

/// Coming-soon reveal sheet for Tap to Pay on Home.
abstract final class TapToPayComingSoonSheet {
  static Future<void> show(BuildContext context) {
    HapticHelper.lightImpact();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.85),
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _TapToPaySheetBody(),
    );
  }
}

class _TapToPaySheetBody extends StatefulWidget {
  const _TapToPaySheetBody();

  @override
  State<_TapToPaySheetBody> createState() => _TapToPaySheetBodyState();
}

class _TapToPaySheetBodyState extends State<_TapToPaySheetBody> {
  bool _notifySaved = false;
  bool _loadingPrefs = true;

  @override
  void initState() {
    super.initState();
    _loadNotifyState();
  }

  Future<void> _loadNotifyState() async {
    final saved =
        locator<SharedPreferences>().getBool(_kTapToPayNotifyKey) ?? false;
    if (mounted) {
      setState(() {
        _notifySaved = saved;
        _loadingPrefs = false;
      });
    }
  }

  Future<void> _onNotifyMe() async {
    HapticHelper.success();
    await locator<SharedPreferences>().setBool(_kTapToPayNotifyKey, true);
    if (!mounted) return;
    setState(() => _notifySaved = true);
    TopSnackbar.showSafe(
      context,
      message:
          'You\'re on the list — we\'ll ping you when Tap to Pay goes live.',
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final heroWidth = screenWidth - 36;
    // Match Tap-to-Pay hero asset aspect (485×794) so the card + phone fit without crop.
    final heroHeight = (heroWidth * (694 / 435)).clamp(340.0, 420.0);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: onSurface.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 40),
                  Expanded(
                    child: Column(
                      children: [
                        // PayBillIconBadge(
                        //   innerIconAsset: 'assets/icons/svgs/credit-card.svg',
                        //   size: 40,
                        //   innerSize: 26,
                        // ),
                        // const SizedBox(height: 24),
                        Text(
                          'Tap to Pay',
                          textAlign: TextAlign.center,
                          style: Theme.of(
                            context,
                          ).textTheme.headlineMedium?.copyWith(
                            fontFamily: 'FunnelDisplay',
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Coming soon to Dayfi',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Chirp',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  _TapToPaySheetCloseButton(
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.fromLTRB(18, 8, 18, bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: heroHeight,
                    width: double.infinity,
                    child: const _TapToPayHeroVisual()
                        .animate()
                        .fadeIn(delay: 80.ms, duration: 400.ms)
                        .scale(
                          begin: const Offset(0.94, 0.94),
                          end: const Offset(1, 1),
                          delay: 80.ms,
                          duration: 450.ms,
                          curve: Curves.easeOutCubic,
                        ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Hold your phone near any contactless terminal, and pay from your Dayfi balance in seconds. No plastic card required.',
                    style: TextStyle(
                      fontFamily: 'Chirp',
                      fontSize: 14,
                      height: 1.4,
                      letterSpacing: -0.25,
                      color: onSurface.withValues(alpha: 0.72),
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 260.ms, duration: 350.ms),
                  const SizedBox(height: 18),
                  Text(
                    'Built with global card networks',
                    style: TextStyle(
                      fontFamily: 'Chirp',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.asset(
                        _kCardNetworksLogo,
                        fit: BoxFit.contain,
                        height: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (!_loadingPrefs)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: PrimaryButton(
                            text:
                                _notifySaved
                                    ? 'You\'re on the notify list'
                                    : 'Notify me when it\'s live',
                            onPressed: _notifySaved ? null : _onNotifyMe,
                            fullWidth: true,
                            height: 48,
                            borderRadius: 38,
                            backgroundColor: AppColors.purple500ForTheme(
                              context,
                            ),
                            textColor: AppColors.neutral0,
                            fontFamily: 'Chirp',
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          )
                          .animate()
                          .fadeIn(delay: 420.ms, duration: 320.ms)
                          .slideY(begin: 0.12, end: 0, delay: 420.ms),
                    ),
                  const SizedBox(height: 8),
                  // SecondaryButton(
                  //   text: 'Maybe later',
                  //   onPressed: () => Navigator.pop(context),
                  //   borderColor: Colors.transparent,
                  //   textColor: onSurface.withValues(alpha: 0.75),
                  //   height: 44,
                  //   borderRadius: 38,
                  //   fontFamily: 'Chirp',
                  //   fontSize: 16,
                  //   fontWeight: FontWeight.w500,
                  // ).animate().fadeIn(delay: 480.ms, duration: 280.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hero visual — product mock + ambient NFC pulse.
class _TapToPayHeroVisual extends StatelessWidget {
  const _TapToPayHeroVisual();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: RadialGradient(
                center: const Alignment(0, 0.35),
                radius: 0.85,
                colors: [
                  AppColors.primary400.withValues(alpha: 0.22),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        const Positioned.fill(child: _NfcPulseRings()),
        ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                _kTapToPayHeroAsset,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
                alignment: Alignment.center,
                errorBuilder:
                    (_, __, ___) => Container(
                      color: Theme.of(context).colorScheme.surface,
                      alignment: Alignment.center,
                      child: PayBillIconBadge(
                        innerIconAsset: 'assets/icons/svgs/credit-card.svg',
                        size: 56,
                        innerSize: 28,
                      ),
                    ),
              ),
            )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.02, 1.02),
              duration: 2.8.seconds,
              curve: Curves.easeInOut,
            ),
      ],
    );
  }
}

/// Close control — matches [DeliveryMethodsSheet] header.
class _TapToPaySheetCloseButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _TapToPaySheetCloseButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: () {
        onPressed();
        FocusScope.of(context).unfocus();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/svgs/notificationn.svg',
            height: 40,
            color: Theme.of(context).colorScheme.surface,
          ),
          SizedBox(
            height: 40,
            width: 40,
            child: Center(
              child: Image.asset(
                'assets/icons/pngs/cancelicon.png',
                height: 20,
                width: 20,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NfcPulseRings extends StatefulWidget {
  const _NfcPulseRings();

  @override
  State<_NfcPulseRings> createState() => _NfcPulseRingsState();
}

class _NfcPulseRingsState extends State<_NfcPulseRings>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Stack(
          alignment: Alignment.center,
          children: List.generate(3, (i) {
            final t = ((_ctrl.value + i * 0.33) % 1.0);
            final scale = 0.35 + t * 0.95;
            final opacity = (1 - t) * 0.45;
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary400.withValues(alpha: opacity),
                    width: 2,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
