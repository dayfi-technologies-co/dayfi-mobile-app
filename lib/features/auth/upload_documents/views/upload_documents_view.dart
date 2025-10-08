import 'package:flutter/material.dart';
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBar(
                  scrolledUnderElevation: 0,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  elevation: 0,
                  automaticallyImplyLeading: widget.showBackButton,
                  leading:
                      widget.showBackButton
                          ? IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.arrow_back_ios,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          )
                          : null,
                  title: Text(
                    "Verify Your Identity",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontFamily: 'CabinetGrotesk',
                      fontSize: 28.00,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 4.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subtitle
                      Text(
                        "Please provide us with the information and documents requested to complete your KYC verification.",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Karla',
                          letterSpacing: -.6,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 36.h),

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
                      _buildActionButtons(uploadDocsState, uploadDocsNotifier),
                      SizedBox(height: 50.h),
                    ],
                  ),
                ),
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
            AppColors.purple500.withOpacity(0.1),
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
                  color: AppColors.purple500,
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
                  fontSize: 18.sp,
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
                    color: AppColors.neutral500,
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
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 16.h),
        _buildDocumentUploadCard(
          "Government ID + BVN Verification",
          "Verify your identity using Smile ID",
          Icons.credit_card,
          AppColors.purple500,
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
            fontSize: 18.sp,
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
    UploadDocumentsState state,
    UploadDocumentsNotifier notifier,
  ) {
    return Column(
      children: [
        // Verify Now Button
        PrimaryButton(
          borderRadius: 38,
          text: "Submit",
          onPressed:
              state.isBusy ? null : () => _showSmileIdVerification(context),
          backgroundColor: AppColors.purple500,
          height: 60.h,
          textColor: AppColors.neutral0,
          fontFamily: 'Karla',
          letterSpacing: -.8,
          fontSize: 18,
          width: double.infinity,
          fullWidth: true,
          isLoading: state.isBusy,
        ),
        widget.showBackButton ? SizedBox.shrink() : SizedBox(height: 16.h),

        // Skip for Later Button
        widget.showBackButton
            ? SizedBox.shrink()
            : TextButton(
              onPressed:
                  state.isBusy ? null : () => notifier.skipForLater(context),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              ),
              child: Text(
                "Skip for Later",
                style: AppTypography.bodyLarge.copyWith(
                  fontFamily: 'Karla',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutral500,
                  letterSpacing: -.6,
                ),
              ),
            ),
      ],
    );
  }
}
