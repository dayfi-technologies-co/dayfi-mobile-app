import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Short explainer before stablecoin / digital dollar channel selection (Yellow Card).
class StablecoinTopupIntroView extends ConsumerWidget {
  const StablecoinTopupIntroView({super.key, this.routeArgs = const {}});

  /// e.g. `{'forSend': true}` when opened from Send money (vs wallet top-up tone).
  final Map<String, dynamic> routeArgs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forSend = routeArgs['forSend'] == true;
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: AppColors.purple500,
        body: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isWide = constraints.maxWidth > 600;
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isWide ? 400 : double.infinity,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWide ? 24 : 18,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(height: 24, width: 24),
                            InkWell(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () => Navigator.pop(context),
                              child: Stack(
                                alignment: AlignmentGeometry.center,
                                children: [
                                  SvgPicture.asset(
                                    "assets/icons/svgs/notificationn.svg",
                                    height: 40,
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                  ),
                                  SizedBox(
                                    height: 40,
                                    width: 40,
                                    child: Center(
                                      child: Image.asset(
                                        "assets/icons/pngs/cancelicon.png",
                                        height: 20,
                                        width: 20,
                                        color:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyLarge!.color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/svgs/currency-dollar.svg',
                              height:
                                  isWide
                                      ? 160
                                      : MediaQuery.of(context).size.width * 0.5,
                              width:
                                  isWide
                                      ? 160
                                      : MediaQuery.of(context).size.width * 0.5,
                              color: AppColors.warning500,
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              forSend
                                  ? 'Pay with digital dollar'
                                  : 'Digital dollar top-up',
                              style: AppTypography.headlineLarge.copyWith(
                                fontFamily: 'FunnelDisplay',
                                fontSize: isWide ? 32 : 28,
                                height: 1.2,
                                fontWeight: FontWeight.w600,
                                color: AppColors.neutral0,
                                letterSpacing: -0.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              forSend
                                  ? 'Complete your transfer using stablecoins on a supported network. '
                                      'You will enter an amount, pick a channel, then receive wallet details.'
                                  : 'Fund your wallet using stablecoins on supported networks. '
                                      'You will enter an amount, pick a channel, then receive wallet details.',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Chirp',
                                color: AppColors.neutral0.withValues(
                                  alpha: 0.88,
                                ),
                                letterSpacing: -.25,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        // if (xlmMinFunding) ...[
                        //   const SizedBox(height: 16),
                        //   Text(
                        //     'By default we send from the master account and add the trustline. '
                        //     'Use at least 1.5 XLM so Stellar minimum reserve and network fees are covered before you add other assets.',
                        //     style: Theme.of(
                        //       context,
                        //     ).textTheme.bodyMedium?.copyWith(
                        //       fontSize: 15,
                        //       fontWeight: FontWeight.w500,
                        //       fontFamily: 'Chirp',
                        //       color: AppColors.neutral0.withValues(alpha: 0.92),
                        //       letterSpacing: -.25,
                        //       height: 1.45,
                        //     ),
                        //     textAlign: TextAlign.center,
                        //   ),
                        // ],
                        const SizedBox(height: 32),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: PrimaryButton(
                            borderRadius: 38,
                            text: 'Continue',
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                forSend
                                    ? AppRoute.sendScreen
                                    : AppRoute.receiveScreen,
                              );
                            },
                            backgroundColor: AppColors.neutral0,
                            height: 48,
                            textColor: AppColors.orange500,
                            fontFamily: 'Chirp',
                            letterSpacing: -.70,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            width: double.infinity,
                            fullWidth: true,
                          ),
                        ),
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
