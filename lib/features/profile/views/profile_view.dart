import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/buttons/secondary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileViewModelProvider.notifier).loadUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileViewModelProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: const SizedBox.shrink(),
        leadingWidth: 0,
        title: Text(
          "Account",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontFamily: 'CabinetGrotesk',
            fontSize: 30.00,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),

      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            pinned: false,
            leading: const SizedBox.shrink(),
            leadingWidth: 0,
            expandedHeight: 200.h,
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Profile Picture
                      // Container(
                      //   width: 80.w,
                      //   height: 80.w,
                      //   decoration: BoxDecoration(
                      //     color: AppColors.success500,
                      //     shape: BoxShape.circle,
                      //     border: Border.all(
                      //       color: AppColors.neutral0,
                      //       width: 3.w,
                      //     ),
                      //   ),
                      //   child: Icon(
                      //     Icons.person,
                      //     color: AppColors.neutral0,
                      //     size: 40.sp,
                      //   ),
                      // ),
                      // SizedBox(height: 12.h),

                      // // Tier Badge
                      // Container(
                      //   padding: EdgeInsets.symmetric(
                      //     horizontal: 12.w,
                      //     vertical: 4.h,
                      //   ),
                      //   decoration: BoxDecoration(
                      //     color: AppColors.primary400,
                      //     borderRadius: BorderRadius.circular(12.r),
                      //   ),
                      //   child: Text(
                      //     'Tier 1',
                      //     style: AppTypography.labelMedium.copyWith(
                      //       color: AppColors.neutral0,
                      //       fontWeight: FontWeight.w400,
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(height: 8.h),

                      // User Name
                      Text(
                        profileState.userName,
                        style: AppTypography.headlineSmall.copyWith(
                          color: AppColors.neutral900,
                          fontSize: 30.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'CabinetGrotesk',

                          height: .95,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(18.w),
              child: Column(
                children: [
                  // Edit Profile Button
                  PrimaryButton(
                    borderRadius: 38,
                    text: "Edit Profile",
                    onPressed: null,
                    backgroundColor: AppColors.purple500,
                    height: 60.h,
                    textColor: AppColors.neutral0,
                    fontFamily: 'Karla',
                    letterSpacing: -.8,
                    fontSize: 18,
                    width: 375.w,
                    fullWidth: true,
                  ),

                  SizedBox(height: 36.h),

                  // Account Settings Section
                  _buildSection(
                    title: 'ACCOUNT SETTINGS',
                    children: [
                      _buildSettingsItem(
                        icon: "assets/icons/svgs/Box.svg",
                        iconColor: AppColors.primary500,
                        title: 'Account Limits',
                        subtitle: 'View and manage your transfer limits',
                        onTap: () {
                          // TODO: Navigate to account limits
                        },
                      ),
                      _buildSettingsItem(
                        icon: "assets/icons/svgs/Box.svg",
                        iconColor: AppColors.pink700,
                        title: 'Payment Methods',
                        subtitle: 'Manage your payment options',
                        onTap: () {
                          // TODO: Navigate to payment methods
                        },
                      ),
                      _buildSettingsItem(
                        icon: "assets/icons/svgs/Box.svg",
                        iconColor: AppColors.warning500,
                        title: 'Upload Documents',
                        subtitle: 'Complete your KYC verification',
                        onTap: () {
                          // TODO: Navigate to document upload
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // Promotions Section
                  _buildSection(
                    title: 'PROMOTIONS',
                    children: [
                      _buildPromotionItem(
                        icon: "assets/icons/svgs/Box.svg",
                        iconColor: AppColors.success500,
                        title: 'Referrals',
                        subtitle: 'Invite friends and earn rewards',
                        actionText: 'Get ₦5000',
                        actionColor: AppColors.success500,
                        onTap: () {
                          // TODO: Navigate to referrals
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // Support Section
                  _buildSection(
                    title: 'SUPPORT',
                    children: [
                      _buildSettingsItem(
                        icon: "assets/icons/svgs/Box.svg",
                        iconColor: AppColors.teal500,
                        title: 'Help Center',
                        subtitle: 'Get help and support',
                        onTap: () {
                          // TODO: Navigate to help center
                        },
                      ),
                      _buildSettingsItem(
                        icon: "assets/icons/svgs/Box.svg",
                        iconColor: AppColors.primary700,
                        title: 'Contact Us',
                        subtitle: 'Reach out to our support team',
                        onTap: () {
                          // TODO: Navigate to contact us
                        },
                      ),
                      _buildSettingsItem(
                        icon: "assets/icons/svgs/Box.svg",
                        iconColor: AppColors.neutral600,
                        title: 'About',
                        subtitle: 'App version and information',
                        onTap: () {
                          // TODO: Navigate to about
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 28.h),

                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.neutral0,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(
                            255,
                            123,
                            36,
                            211,
                          ).withOpacity(0.05),
                          blurRadius: 2.0,
                          offset: const Offset(0, 2),
                          spreadRadius: 0.5,
                        ),
                      ],
                    ),
                    child: _buildSettingsItem(
                      icon: "assets/icons/svgs/Box.svg",
                      iconColor: AppColors.error500,
                      title: 'Log out',
                      subtitle: 'Get help and support',
                      onTap: () {
                        _showLogoutDialog();
                      },
                    ),
                  ),
                  SizedBox(height: 50.h),
                  _buildPartnershipInfo(),
                  SizedBox(height: 400.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.neutral700,
            fontSize: 11.sp,
            fontWeight: FontWeight.w400,
            fontFamily: 'Karla',
            letterSpacing: -.3,
            height: 1.2,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.neutral0,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(
                  255,
                  123,
                  36,
                  211,
                ).withOpacity(0.05),
                blurRadius: 2.0,
                offset: const Offset(0, 2),
                spreadRadius: 0.5,
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required String icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        child: Row(
          children: [
            Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              // child: SvgPicture.asset(icon, color: iconColor, height: 20.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleMedium.copyWith(
                      fontFamily: 'Karla',
                      color:
                          iconColor == AppColors.error500
                              ? AppColors.error500
                              : AppColors.neutral800,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -1,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.neutral400, size: 26.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionItem({
    required String icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String actionText,
    required Color actionColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        child: Row(
          children: [
            Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              // child: SvgPicture.asset(icon, color: iconColor, height: 20.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleMedium.copyWith(
                      fontFamily: 'Karla',
                      color: AppColors.neutral800,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -1,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: actionColor,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                actionText,
                style: AppTypography.labelMedium.copyWith(
                  color: Colors.white,
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Karla',
                  letterSpacing: -.3,
                  height: 1.2,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.chevron_right, color: AppColors.neutral400, size: 26.sp),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
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
                        colors: [AppColors.error400, AppColors.error600],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.error500.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    // child: Icon(
                    //   Icons.check_circle_rounded,
                    //   color: Colors.white,
                    //   size: 40.w,
                    // ),
                  ),

                  SizedBox(height: 24.h),

                  // Title with auth view styling
                  Text(
                    'Are you sure you want to logout?',
                    style: TextStyle(
                      fontFamily: 'CabinetGrotesk',
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.neutral900,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 16.h),

                  // Continue button with auth view styling
                  PrimaryButton(
                    text: 'Yes, Logout',
                    onPressed: () {
                      Navigator.pop(context);
                      ref.read(profileViewModelProvider.notifier).logout();
                    },
                    backgroundColor: AppColors.purple500,
                    textColor: AppColors.neutral0,
                    borderRadius: 38,
                    height: 56.h,
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
                    text: 'Cancel',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    borderColor: AppColors.purple500,
                    textColor: AppColors.purple500,
                    width: double.infinity,
                    fullWidth: true,
                    height: 56.h,
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

  Widget _buildPartnershipInfo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        children: [
          Center(
            child: Text(
              'DayFi is powered by Yellow Card in partnership with Smile ID.',
              style: AppTypography.bodySmall.copyWith(
                fontFamily: 'Karla',
                color: AppColors.neutral800,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                letterSpacing: -.6,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 14.h),
          Center(
            child: Text(
              'Yellow Card Financial Services is regulated by the relevant authorities in its operating regions.',
              style: AppTypography.bodySmall.copyWith(
                fontFamily: 'Karla',
                color: AppColors.neutral800,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                letterSpacing: -.6,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 14.h),
          Center(
            child: Text(
              'Version 1.0.0',
              style: AppTypography.bodySmall.copyWith(
                fontFamily: 'Karla',
                color: AppColors.neutral800,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                letterSpacing: -.6,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
