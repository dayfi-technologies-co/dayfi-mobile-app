import 'package:dayfi/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/routes/route.dart';
import 'package:flutter_svg/svg.dart';
import 'package:dayfi/services/local/local_cache.dart';
import 'package:dayfi/app_locator.dart';

class ResetTransactionPinIntroView extends ConsumerStatefulWidget {
  const ResetTransactionPinIntroView({super.key});

  @override
  ConsumerState<ResetTransactionPinIntroView> createState() =>
      _ResetTransactionPinIntroViewState();
}

class _ResetTransactionPinIntroViewState
    extends ConsumerState<ResetTransactionPinIntroView> {
  bool _isLoading = false;

  Future<void> _handleContinue() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get user email from local cache
      final localCache = locator<LocalCache>();
      final userMap = await localCache.getUser();
      final email = userMap['email'] ?? '';

      if (email.isNotEmpty && mounted) {
        appRouter.pushNamed(
          AppRoute.resetTransactionPinOtpView,
          arguments: email,
        );
      } else {
        debugPrint("Error: User email not found in local cache.");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppColors.purple900,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth > 600;
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWide ? 500 : double.infinity,
                ),
                child: SafeArea(
                  bottom: false,
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

                        SizedBox(height: 32),

                        // Lock Icon
                        Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            Container(
                              width: 124,
                              height: 124,
                              decoration: BoxDecoration(shape: BoxShape.circle),
                              child: SvgPicture.asset(
                                'assets/icons/svgs/cautionn.svg',
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "Reset your\ntransaction PIN",
                          style: AppTypography.headlineLarge.copyWith(
                            fontFamily: 'FunnelDisplay',
                            fontSize: 28,
                            height: 1.2,
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutral0,
                            // height: 1.2,
                            letterSpacing: -0.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "We'll verify your identity via OTP sent to your registered email, then you can create a new PIN.",
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Chirp',
                            color: AppColors.neutral50,
                            letterSpacing: -.25,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 32),
                        PrimaryButton(
                          borderRadius: 38,
                          text: "Continue",
                          onPressed: _isLoading ? null : _handleContinue,
                          isLoading: _isLoading,
                          backgroundColor: AppColors.neutral0,
                          height: 48.00000,
                          textColor: AppColors.purple500ForTheme(context),
                          fontFamily: 'Chirp',
                          letterSpacing: -.70,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          width: double.infinity,
                          fullWidth: true,
                        ),
                        SizedBox(height: 50),
                      ],
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
}
