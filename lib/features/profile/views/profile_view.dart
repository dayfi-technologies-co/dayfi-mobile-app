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
      backgroundColor: AppColors.neutral50,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: AppColors.neutral0,
            elevation: 0,
            pinned: true,
            expandedHeight: 200.h,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary500,
                      AppColors.primary600,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Profile Picture
                        Container(
                          width: 80.w,
                          height: 80.w,
                          decoration: BoxDecoration(
                            color: AppColors.success500,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.neutral0,
                              width: 3.w,
                            ),
                          ),
                          child: Icon(
                            Icons.person,
                            color: AppColors.neutral0,
                            size: 40.sp,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        
                        // Tier Badge
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: AppColors.primary400,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            'Tier 1',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.neutral0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        
                        // User Name
                        Text(
                          profileState.userName,
                          style: AppTypography.headlineSmall.copyWith(
                            color: AppColors.neutral0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  // Edit Profile Button
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Navigate to edit profile
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary500,
                        foregroundColor: AppColors.neutral0,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Edit Profile',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.neutral0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // Account Settings Section
                  _buildSection(
                    title: 'ACCOUNT SETTINGS',
                    children: [
                      _buildSettingsItem(
                        icon: Icons.speed_outlined,
                        iconColor: AppColors.primary500,
                        title: 'Account Limits',
                        subtitle: 'View and manage your transfer limits',
                        onTap: () {
                          // TODO: Navigate to account limits
                        },
                      ),
                      _buildSettingsItem(
                        icon: Icons.account_balance_wallet_outlined,
                        iconColor: AppColors.primary500,
                        title: 'Payment Methods',
                        subtitle: 'Manage your payment options',
                        onTap: () {
                          // TODO: Navigate to payment methods
                        },
                      ),
                      _buildSettingsItem(
                        icon: Icons.upload_file_outlined,
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
                        icon: Icons.people_outline,
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
                        icon: Icons.help_outline,
                        iconColor: AppColors.neutral600,
                        title: 'Help Center',
                        subtitle: 'Get help and support',
                        onTap: () {
                          // TODO: Navigate to help center
                        },
                      ),
                      _buildSettingsItem(
                        icon: Icons.phone_outlined,
                        iconColor: AppColors.neutral600,
                        title: 'Contact Us',
                        subtitle: 'Reach out to our support team',
                        onTap: () {
                          // TODO: Navigate to contact us
                        },
                      ),
                      _buildSettingsItem(
                        icon: Icons.info_outline,
                        iconColor: AppColors.neutral600,
                        title: 'About',
                        subtitle: 'App version and information',
                        onTap: () {
                          // TODO: Navigate to about
                        },
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: OutlinedButton(
                      onPressed: () {
                        _showLogoutDialog();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error500,
                        side: BorderSide(color: AppColors.error200),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Logout',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.error500,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 32.h),
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
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            color: AppColors.neutral0,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.neutral900,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.neutral400,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionItem({
    required IconData icon,
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
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.neutral900,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: actionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                actionText,
                style: AppTypography.labelMedium.copyWith(
                  color: actionColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.chevron_right,
              color: AppColors.neutral400,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.neutral0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        title: Text(
          'Logout',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.neutral900,
            fontWeight: FontWeight.w400,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.neutral600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.neutral600,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(profileViewModelProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error500,
              foregroundColor: AppColors.neutral0,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Logout',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.neutral0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
