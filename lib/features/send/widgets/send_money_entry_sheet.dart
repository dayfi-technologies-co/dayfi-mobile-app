import 'package:dayfi/app_locator.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/models/payment_capabilities.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/services/remote/payment_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Teal banknote tone to match the reference “Fiat & local rails” icon.
const Color _fiatRailIconTeal = Color(0xFF0D9488);

/// Gold / amber for the reference “Stablecoin” Bitcoin-style icon.
const Color _stablecoinIconGold = Color(0xFFE6A819);

/// Shared entry for “Send money”: same bottom sheet as Home when stablecoin
/// top-up is enabled; otherwise goes straight to fiat destination selection.
Future<void> openSendMoneyEntry(BuildContext context) async {
  PaymentCapabilities caps = PaymentCapabilities.empty;
  try {
    caps = await locator<PaymentService>().fetchPaymentCapabilities();
  } catch (_) {}

  if (!context.mounted) return;

  if (!caps.stablecoinTopup) {
    appRouter.pushNamed(AppRoute.selectDestinationCountryView);
    return;
  }

  await showModalBottomSheet<void>(
    // ignore: deprecated_member_use
    barrierColor: Colors.black.withOpacity(0.85),
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (ctx) {
      return _SendMoneyChoiceSheet(parentContext: context);
    },
  );
}

class _SendMoneyChoiceSheet extends StatelessWidget {
  const _SendMoneyChoiceSheet({required this.parentContext});

  final BuildContext parentContext;

  Widget _fiatRailsIcon(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        SvgPicture.asset(
          'assets/icons/svgs/swap.svg',
          height: 40,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        SvgPicture.asset(
          'assets/icons/svgs/building-bank.svg',
          height: 28,
          color: Theme.of(context).colorScheme.surface,
        ),
      ],
    );
  }

  Widget _stablecoinIcon(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        SvgPicture.asset(
          'assets/icons/svgs/swap.svg',
          height: 40,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        SvgPicture.asset(
          'assets/icons/svgs/currency-dollar.svg',
          height: 28,
          color: Theme.of(context).colorScheme.surface,
        ),
      ],
    );
  }

  void _afterPop(VoidCallback action) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!parentContext.mounted) return;
      action();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 40, width: 40),
                Text(
                  'Choose sending method',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontFamily: 'FunnelDisplay',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    Navigator.pop(context);
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
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Opacity(
              opacity: .7,
              child: Text(
                'Choose how you want to send.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Chirp',
                  letterSpacing: -.25,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              children: [
                _sendMethodTile(
                  context: context,
                  icon: _fiatRailsIcon(context),
                  titleLine: 'Fiat & local rails',
                  subtitleLine:
                      'Bank, mobile money, Dayfi Tag, and other local rails.',
                  onTap: () {
                    Navigator.pop(context);
                    _afterPop(() {
                      appRouter.pushNamed(
                        AppRoute.selectDestinationCountryView,
                      );
                    });
                  },
                ),
                const SizedBox(height: 12),
                Opacity(
                  opacity: .4,
                  child: _sendMethodTile(
                    context: context,
                    icon: _stablecoinIcon(context),
                    titleLine: 'Digital dollar',
                    subtitleLine:
                        'Stablecoin wallet and address. Cross-border made easy.',
                    onTap: () {
                      // Navigator.pop(context);
                      // _afterPop(() {
                      //   appRouter.pushNamed(AppRoute.sendScreen);
                      // });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sendMethodTile({
    required BuildContext context,
    required Widget icon,
    required String titleLine,
    required String subtitleLine,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SizedBox(width: 40, height: 40, child: icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titleLine,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontFamily: 'Chirp',
                      fontSize: 18,
                      letterSpacing: -.25,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitleLine,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                      fontFamily: 'Chirp',
                      letterSpacing: -.25,
                      fontSize: 14,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(.75),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 32),
            Icon(Icons.chevron_right, color: AppColors.neutral400, size: 20),
          ],
        ),
      ),
    );
  }
}
