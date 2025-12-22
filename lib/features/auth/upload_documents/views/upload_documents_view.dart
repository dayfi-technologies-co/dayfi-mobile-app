import 'package:dayfi/common/widgets/buttons/secondary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/features/auth/upload_documents/vm/upload_documents_viewmodel.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';

class UploadDocumentsView extends ConsumerStatefulWidget {
  final bool showBackButton;

  const UploadDocumentsView({super.key, this.showBackButton = false});

  @override
  ConsumerState<UploadDocumentsView> createState() =>
      _UploadDocumentsViewState();
}

class _UploadDocumentsViewState extends ConsumerState<UploadDocumentsView> {
  @override
  void initState() {
    super.initState();
    // Reset form state when view is initialized (handles logout navigation)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(uploadDocumentsProvider.notifier).resetForm();
    });
  }

  @override
  Widget build(BuildContext context) {
    final uploadDocsState = ref.watch(uploadDocumentsProvider);
    final uploadDocsNotifier = ref.read(uploadDocumentsProvider.notifier);

    return WillPopScope(
      onWillPop: () async => false, // Disable device back button
      child: Scaffold(
        backgroundColor: AppColors.purple500,
        body: Stack(
          children: [
            if (!widget.showBackButton)
              Positioned.fill(
                child: IgnorePointer(
                  child: Lottie.asset(
                    'assets/icons/svgs/confetti.json',
                    fit: BoxFit.cover,
                    repeat: false,
                  ),
                ),
              ),
            SafeArea(
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
                            //  SizedBox(height: 18),
                            if (widget.showBackButton)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                              Theme.of(
                                                context,
                                              ).colorScheme.surface,
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
                            if (!widget.showBackButton) SizedBox(height: 12),
                            Padding(
                              padding: EdgeInsets.only(left: 28),
                              child: Image.asset(
                                'assets/images/upload_doc.png',
                                width:
                                    isWide
                                        ? 180
                                        : MediaQuery.of(context).size.width *
                                            0.5,
                              ),
                            ),

                            // Title
                            Column(
                              children: [
                                Text(
                                      "Upgrade account limits",
                                      style: AppTypography.headlineMedium
                                          .copyWith(
                                            fontFamily: 'FunnelDisplay',
                                            fontSize: isWide ? 32 : 28,
                                            height: 1.2,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.neutral0,
                                            // height: 1.2,
                                            // letterSpacing: -.4,
                                          ),
                                      textAlign: TextAlign.center,
                                    )
                                    .animate()
                                    .fadeIn(
                                      delay: 500.ms,
                                      duration: 400.ms,
                                      curve: Curves.easeOutCubic,
                                    )
                                    .slideY(
                                      begin: 0.3,
                                      end: 0,
                                      delay: 500.ms,
                                      duration: 400.ms,
                                      curve: Curves.easeOutCubic,
                                    ),

                                SizedBox(height: 18),
                                Text(
                                  widget.showBackButton
                                      ? "Just one step left.\nupgrade your account to complete this transaction.\nIt only takes about 30 seconds, promise."
                                      : "Your account is ready! You can now transfer up to 1,000 USD per month and 10,000 USD per year. Submit additional documents to increase your limit to 20,000 USD per month and 100,000 USD",
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Chirp',
                                    color: AppColors.neutral100,
                                    letterSpacing: -.25,
                                    height: 1.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            // SizedBox(height: 36),

                            // // KYC Tier Information Card
                            // _buildKycTierCard(),
                            // SizedBox(height: 32),

                            // // Current Tier Status
                            // _buildCurrentTierStatus(),
                            // SizedBox(height: 32),

                            // // Upload Documents Section
                            // _buildUploadDocumentsSection(uploadDocsNotifier),
                            // SizedBox(height: 32),

                            // // Benefits of Tier 2
                            // _buildTier2Benefits(),
                            // SizedBox(height: 40),

                            // Action Buttons
                            _buildActionButtons(
                              context,
                              uploadDocsState,
                              uploadDocsNotifier,
                            ),
                            // SizedBox(height: 50),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    UploadDocumentsState state,
    UploadDocumentsNotifier notifier,
  ) {
    return Column(
      children: [
        // Enable biometrics button
        PrimaryButton(
              text: "Increase limits",
              borderRadius: 38,
              onPressed:
                  () => notifier.navigateToNINAndBVNVerification(
                    context,
                    showBackButton: widget.showBackButton,
                  ),
              backgroundColor: Colors.white,
              height: 48.00000,
              textColor: AppColors.purple500ForTheme(context),
              fontFamily: 'Chirp',
              letterSpacing: -.70,
              fontSize: 18,
              width: double.infinity,
              fullWidth: true,
              isLoading: state.isBusy,
            )
            .animate()
            .fadeIn(
              delay: 1000.ms,
              duration: 500.ms,
              curve: Curves.easeOutCubic,
            )
            .slideY(
              begin: 0.3,
              end: 0,
              delay: 1000.ms,
              duration: 500.ms,
              curve: Curves.easeOutCubic,
            )
            .scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1.0, 1.0),
              delay: 1000.ms,
              duration: 500.ms,
              curve: Curves.easeOutCubic,
            ),

        SizedBox(height: 12),

        // Skip button
        SecondaryButton(
              text: state.isBusy ? "" : "I'll do it later",
              borderRadius: 38,
              onPressed:
                  state.isBusy
                      ? null
                      : () => _showSkipDialog(context, state, notifier),
              borderColor: Colors.transparent,
              height: 48.00000,
              textColor: AppColors.neutral0,
              fontFamily: 'Chirp',
              letterSpacing: -.70,
              fontSize: 18,
              width: double.infinity,
              fullWidth: true,
            )
            .animate()
            .fadeIn(
              delay: 1000.ms,
              duration: 500.ms,
              curve: Curves.easeOutCubic,
            )
            .slideY(
              begin: 0.3,
              end: 0,
              delay: 1000.ms,
              duration: 500.ms,
              curve: Curves.easeOutCubic,
            )
            .scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1.0, 1.0),
              delay: 1000.ms,
              duration: 500.ms,
              curve: Curves.easeOutCubic,
            ),

        SizedBox(height: 24),

        // Padding(
        //   padding: EdgeInsets.only(top: 12),
        //   child: TextButton(
        //     onPressed:
        //         state.isBusy ? null : () => notifier.skipForLater(context),
        //     child: Text(
        //       'Retry',
        //       style: TextStyle(
        //         fontFamily: 'Chirp',
        //         color: AppColors.purple500ForTheme(context),
        //         fontSize: 16,
        //         fontWeight: FontWeight.w600,
        //         letterSpacing: -.25,
        //         height: 1.2,
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  void _showSkipDialog(
    BuildContext context,
    UploadDocumentsState state,
    UploadDocumentsNotifier notifier,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (BuildContext context) => Dialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              padding: EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success icon with enhanced styling
                  // Container(
                  //   width: 80,
                  //   height: 80,
                  //   decoration: BoxDecoration(
                  //     gradient: LinearGradient(
                  //       begin: Alignment.topLeft,
                  //       end: Alignment.bottomRight,
                  //       colors: [AppColors.purple400, AppColors.purple600],
                  //     ),
                  //     shape: BoxShape.circle,
                  //     boxShadow: [
                  //       BoxShadow(
                  //         color: AppColors.purple500ForTheme(
                  //           context,
                  //         ).withOpacity(0.3),
                  //         blurRadius: 20,
                  //         spreadRadius: 2,
                  //         offset: const Offset(0, 4),
                  //       ),
                  //     ],
                  //   ),
                  //   child: Icon(
                  //     Icons.security,
                  //     color: Colors.white,
                  //     size: 40,
                  //   ),
                  // ),

                  // SizedBox(height: 24),

                  // Title with auth view styling
                  Text(
                    'Skipping verification means lower transfer limits. Do you want to proceed?',
                    style: TextStyle(
                      fontFamily: 'Chirp',
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                      letterSpacing: -0.8,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 24),

                  // Continue button with auth view styling
                  PrimaryButton(
                    text: 'Yes, I\'ll do it later',
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (!widget.showBackButton) {
                        notifier.skipForLater(context);
                      }
                      if (widget.showBackButton) Navigator.of(context).pop();
                    },
                    backgroundColor: AppColors.purple500,
                    textColor: AppColors.neutral0,
                    borderRadius: 38,
                    height: 48.00000,
                    width: double.infinity,
                    fullWidth: true,
                    fontFamily: 'Chirp',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.8,
                  ),
                  SizedBox(height: 12),

                  // Cancel button with auth view styling
                  SecondaryButton(
                    text: 'No, enable it now',
                    onPressed: () {
                      Navigator.of(context).pop();
                      notifier.navigateToNINAndBVNVerification(context);
                    },
                    borderColor: Colors.transparent,
                    textColor: Theme.of(context).textTheme.bodyLarge!.color!,
                    width: double.infinity,
                    fullWidth: true,
                    height: 48.00000,
                    borderRadius: 38,
                    fontFamily: 'Chirp',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.8,
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
