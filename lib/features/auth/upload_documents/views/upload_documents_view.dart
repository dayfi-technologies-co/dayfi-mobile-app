import 'package:dayfi/common/widgets/buttons/secondary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/features/auth/upload_documents/vm/upload_documents_viewmodel.dart';

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

  // Show Smile ID verification screen
  void _showSmileIdVerification(BuildContext context) {
    // Use the Enhanced KYC method directly
    ref
        .read(uploadDocumentsProvider.notifier)
        .startSmileIdVerification(context);
  }

  @override
  Widget build(BuildContext context) {
    final uploadDocsState = ref.watch(uploadDocumentsProvider);
    final uploadDocsNotifier = ref.read(uploadDocumentsProvider.notifier);

    return WillPopScope(
      onWillPop: () async => false, // Disable device back button
      child: Scaffold(
        backgroundColor: AppColors.purple500,
        body: SafeArea(
            bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 4.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(height: 54.h),
                Padding(
                  padding: EdgeInsets.only(left: 28.w),
                  child: Image.asset(
                    'assets/images/upload_doc.png',
                    width: MediaQuery.of(context).size.width * 0.5,
                  ),
                ),
                Text(
                  "Your account is ready! You can now transfer up to 1,000 USD per month and 10,000 USD per year. Submit additional documents to increase your limit to 20,000 USD per month and 100,000 USD",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Karla',
                    color: AppColors.neutral50,
                    letterSpacing: -.3,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                // SizedBox(height: 36.h),

                // // KYC Tier Information Card
                // _buildKycTierCard(),
                // SizedBox(height: 32.h),

                // // Current Tier Status
                // _buildCurrentTierStatus(),
                // SizedBox(height: 32.h),

                // // Upload Documents Section
                // _buildUploadDocumentsSection(uploadDocsNotifier),
                // SizedBox(height: 32.h),

                // // Benefits of Tier 2
                // _buildTier2Benefits(),
                // SizedBox(height: 40.h),

                // Action Buttons
                _buildActionButtons(
                  context,
                  uploadDocsState,
                  uploadDocsNotifier,
                ),
                // SizedBox(height: 50.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKycTierCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.purple500ForTheme(context).withOpacity(0.1),
            AppColors.purple600.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.purple200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.purple500ForTheme(context),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.verified_user,
                  color: AppColors.neutral0,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                "KYC Verification Tiers",
                style: AppTypography.titleLarge.copyWith(
                  fontFamily: 'CabinetGrotesk',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.purple700,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildTierComparison(),
        ],
      ),
    );
  }

  Widget _buildTierComparison() {
    return Column(
      children: [
        _buildTierRow(
          "Tier 1 (Current)",
          "₦50k single • ₦300k daily",
          AppColors.neutral500,
          Icons.check_circle_outline,
        ),
        SizedBox(height: 12.h),
        _buildTierRow(
          "Tier 2 (Upgrade)",
          "₦200k single • ₦500k daily",
          AppColors.purple600,
          Icons.star_outline,
        ),
      ],
    );
  }

  Widget _buildTierRow(
    String title,
    String limits,
    Color color,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16.sp),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            title,
            style: AppTypography.bodyMedium.copyWith(
              fontFamily: 'Karla',
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ),
        Text(
          limits,
          style: AppTypography.bodySmall.copyWith(
            fontFamily: 'Karla',
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentTierStatus() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.neutral200, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.neutral400,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.person_outline,
              color: AppColors.neutral0,
              size: 16.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Current Status: Tier 1",
                  style: AppTypography.bodyMedium.copyWith(
                    fontFamily: 'Karla',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.neutral700,
                  ),
                ),
                Text(
                  "Basic verification completed",
                  style: AppTypography.bodySmall.copyWith(
                    fontFamily: 'Karla',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.neutral400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadDocumentsSection(UploadDocumentsNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Upload Documents",
          style: AppTypography.titleMedium.copyWith(
            fontFamily: 'CabinetGrotesk',
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 16.h),
        _buildDocumentUploadCard(
          "Government ID + BVN Verification",
          "Verify your identity using Smile ID",
          Icons.credit_card,
          AppColors.purple500ForTheme(context),
          () => notifier.startSmileIdVerification(context),
        ),
      ],
    );
  }

  Widget _buildDocumentUploadCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.neutral0,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.neutral200, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.neutral100.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: color, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyLarge.copyWith(
                      fontFamily: 'Karla',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral800,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: AppTypography.bodyMedium.copyWith(
                      fontFamily: 'Karla',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.neutral400,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTier2Benefits() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Benefits of Tier 2 Verification",
          style: AppTypography.titleMedium.copyWith(
            fontFamily: 'CabinetGrotesk',
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 16.h),
        _buildBenefitItem(
          "Higher Transaction Limits",
          "Send up to ₦200k per transaction",
          Icons.trending_up,
        ),
        SizedBox(height: 12.h),
        _buildBenefitItem(
          "Increased Daily Limits",
          "Up to ₦500k daily transaction limit",
          Icons.schedule,
        ),
        SizedBox(height: 12.h),
        _buildBenefitItem(
          "Enhanced Security",
          "Verified identity for better protection",
          Icons.security,
        ),
        SizedBox(height: 12.h),
        _buildBenefitItem(
          "Full App Access",
          "Unlock all DayFi features",
          Icons.apps,
        ),
      ],
    );
  }

  Widget _buildBenefitItem(String title, String description, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: AppColors.neutral100,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Icon(icon, color: AppColors.neutral600, size: 16.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.bodyMedium.copyWith(
                  fontFamily: 'Karla',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutral800,
                ),
              ),
              Text(
                description,
                style: AppTypography.bodySmall.copyWith(
                  fontFamily: 'Karla',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.neutral600,
                ),
              ),
            ],
          ),
        ),
      ],
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
                  state.isBusy ? null : () => _showSmileIdVerification(context),
              backgroundColor: Colors.white,
              height: 48.000.h,
              textColor: AppColors.purple500ForTheme(context),
              fontFamily: 'Karla',
              letterSpacing: -.8,
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

        // SizedBox(height: 12.h),

        // Skip button
        // SecondaryButton(
        //       text: state.isBusy ? "Please wait..." : "I'll do it later",
        //       borderRadius: 38,
        //       onPressed:
        //           state.isBusy
        //               ? null
        //               : () => _showSkipDialog(context, state, notifier),
        //       borderColor: Colors.transparent,
        //       height: 48.000.h,
        //       textColor: AppColors.neutral0,
        //       fontFamily: 'Karla',
        //       letterSpacing: -.8,
        //       fontSize: 18,
        //       width: double.infinity,
        //       fullWidth: true,
        //     )
        //     .animate()
        //     .fadeIn(
        //       delay: 1000.ms,
        //       duration: 500.ms,
        //       curve: Curves.easeOutCubic,
        //     )
        //     .slideY(
        //       begin: 0.3,
        //       end: 0,
        //       delay: 1000.ms,
        //       duration: 500.ms,
        //       curve: Curves.easeOutCubic,
        //     )
        //     .scale(
        //       begin: const Offset(0.9, 0.9),
        //       end: const Offset(1.0, 1.0),
        //       delay: 1000.ms,
        //       duration: 500.ms,
        //       curve: Curves.easeOutCubic,
        //     ),

        // Padding(
        //   padding: EdgeInsets.only(top: 12.h),
        //   child: TextButton(
        //     onPressed:
        //         state.isBusy ? null : () => notifier.skipForLater(context),
        //     child: Text(
        //       'Retry',
        //       style: TextStyle(
        //         fontFamily: 'Karla',
        //         color: AppColors.purple500ForTheme(context),
        //         fontSize: 16.sp,
        //         fontWeight: FontWeight.w600,
        //         letterSpacing: -.3,
        //         height: 1.4,
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
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Container(
              padding: EdgeInsets.all(28.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success icon with enhanced styling
                  Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.purple400, AppColors.purple600],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.purple500ForTheme(
                            context,
                          ).withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.security,
                      color: Colors.white,
                      size: 40.w,
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Title with auth view styling
                  Text(
                    'Skipping verification means lower transfer limits. Do you want to proceed?',
                    style: TextStyle(
                      fontFamily: 'CabinetGrotesk',
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 16.h),

                  // Continue button with auth view styling
                  PrimaryButton(
                    text: 'Yes, I\'ll do it later',
                    onPressed: () {
                      Navigator.of(context).pop();
                      state.isBusy
                          ? null
                          : () => notifier.skipForLater(context);
                    },
                    backgroundColor: AppColors.purple500,
                    textColor: AppColors.neutral0,
                    borderRadius: 38,
                    height: 48.000.h,
                    width: double.infinity,
                    fullWidth: true,
                    fontFamily: 'Karla',
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.8,
                  ),
                  SizedBox(height: 12.h),

                  // Cancel button with auth view styling
                  SecondaryButton(
                    text: 'No, enable it now',
                    onPressed: () {
                      Navigator.of(context).pop();
                      state.isBusy
                          ? null
                          : () => notifier.skipForLater(context);
                    },
                    borderColor: Colors.transparent,
                    textColor: AppColors.purple500ForTheme(context),
                    width: double.infinity,
                    fullWidth: true,
                    height: 48.000.h,
                    borderRadius: 38,
                    fontFamily: 'Karla',
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.8,
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
