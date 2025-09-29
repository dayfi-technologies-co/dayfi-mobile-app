import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/buttons/secondary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';

// Constants for consistent styling
class _ProfileConstants {
  static const double headerPaddingTop = 8.0;
  static const double headerPaddingBottom = 0.0;
  static const double contentPadding = 18.0;
  static const double sectionSpacing = 32.0;
  static const double buttonHeight = 60.0;
  static const double buttonBorderRadius = 38.0;
  static const double containerBorderRadius = 12.0;
  static const double tierContainerBorderRadius = 40.0;
  static const double iconContainerSize = 30.0;
  static const double profileImageHeight = 84.0;
  static const double tierImageHeight = 32.0;
  static const double dialogIconSize = 80.0;
  static const double shadowOpacity = 0.05;
  static const double shadowBlur = 2.0;
  static const double shadowSpread = 0.5;
  static const double shadowOffset = 2.0;
}

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

  // Settings sections data
  List<Map<String, dynamic>> get _accountSettings => [
    {
      'icon': "assets/icons/svgs/Box.svg",
      'iconColor': AppColors.primary500,
      'title': 'Account Limits',
      'subtitle': 'View and manage your transfer limits',
      'onTap': () => _navigateToAccountLimits(),
    },
    {
      'icon': "assets/icons/svgs/Box.svg",
      'iconColor': AppColors.pink700,
      'title': 'Payment Methods',
      'subtitle': 'Manage your payment options',
      'onTap': () => _navigateToPaymentMethods(),
    },
    {
      'icon': "assets/icons/svgs/Box.svg",
      'iconColor': AppColors.warning500,
      'title': 'Upload Documents',
      'subtitle': 'Complete your KYC verification',
      'onTap': () => _navigateToDocumentUpload(),
    },
  ];

  List<Map<String, dynamic>> get _promotions => [
    {
      'icon': "assets/icons/svgs/Box.svg",
      'iconColor': AppColors.success500,
      'title': 'Referrals',
      'subtitle': 'Invite friends and earn rewards',
      'actionText': 'Get ₦5000',
      'actionColor': AppColors.success500,
      'onTap': () => _navigateToReferrals(),
    },
  ];

  List<Map<String, dynamic>> get _securitySettings => [
    {
      'icon': "assets/icons/svgs/Box.svg",
      'iconColor': AppColors.primary500,
      'title': 'Change my PIN',
      'subtitle': '',
      'onTap': () => _navigateToChangePin(),
    },
  ];

  List<Map<String, dynamic>> get _helpAndSupport => [
    {
      'icon': "assets/icons/svgs/Box.svg",
      'iconColor': AppColors.primary700,
      'title': 'Contact Us',
      'subtitle': 'Reach out to our support team',
      'onTap': () => _navigateToContactUs(),
    },
    {
      'icon': "assets/icons/svgs/Box.svg",
      'iconColor': AppColors.teal500,
      'title': 'FAQs',
      'subtitle': '',
      'onTap': () => _navigateToFAQs(),
    },
  ];

  List<Map<String, dynamic>> get _aboutUs => [
    {
      'icon': "assets/icons/svgs/Box.svg",
      'iconColor': AppColors.primary700,
      'title': 'Terms & Conditions',
      'subtitle': 'Reach out to our support team',
      'onTap': () => _navigateToTermsAndConditions(),
    },
    {
      'icon': "assets/icons/svgs/Box.svg",
      'iconColor': AppColors.teal500,
      'title': 'Privacy Notice',
      'subtitle': '',
      'onTap': () => _navigateToPrivacyNotice(),
    },
  ];

  // Navigation methods (placeholders for future implementation)
  void _navigateToEditProfile() {
    Navigator.pushNamed(context, '/editProfileView');
  }

  void _navigateToAccountLimits() {
    // TODO: Navigate to account limits
  }

  void _navigateToPaymentMethods() {
    // TODO: Navigate to payment methods
  }

  void _navigateToDocumentUpload() {
    // TODO: Navigate to document upload
  }

  void _navigateToReferrals() {
    // TODO: Navigate to referrals
  }

  void _navigateToChangePin() {
    // TODO: Navigate to change PIN
  }

  void _navigateToContactUs() {
    // TODO: Navigate to contact us
  }

  void _navigateToFAQs() {
    // TODO: Navigate to FAQs
  }

  void _navigateToTermsAndConditions() {
    // TODO: Navigate to terms and conditions
  }

  void _navigateToPrivacyNotice() {
    // TODO: Navigate to privacy notice
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
            fontSize: 28.00,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Header Section
            _buildHeaderSection(profileState),

            SizedBox(height: 18.h),

            // Content
            _buildContentSection(profileState),
          ],
        ),
      ),
    );
  }

  // Header Section Widget
  Widget _buildHeaderSection(ProfileState profileState) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        24.w,
        _ProfileConstants.headerPaddingTop.h,
        24.w,
        _ProfileConstants.headerPaddingBottom.h,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildProfileImageWithTier(profileState),
          SizedBox(height: 12.h),
          _buildUserName(profileState),
        ],
      ),
    );
  }

  // Profile Image with Tier Badge
  Widget _buildProfileImageWithTier(ProfileState profileState) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 32.h),
          child: Image.asset(
            "assets/icons/pngs/account.png",
            height: _ProfileConstants.profileImageHeight.h,
          ),
        ),
        if (!profileState.isLoading) _buildTierBadge(),
      ],
    );
  }

  // Tier Badge Widget
  Widget _buildTierBadge() {
    return Positioned(
      bottom: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: AppColors.neutral0,
          borderRadius: BorderRadius.circular(
            _ProfileConstants.tierContainerBorderRadius.r,
          ),
        ),
        child: Row(
          children: [
            Image.asset(
              'assets/icons/pngs/tier1.png',
              height: _ProfileConstants.tierImageHeight.h,
            ),
            SizedBox(width: 4.h),
            Text(
              "Tier 1",
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.info600,
                fontSize: 16.sp,
                fontFamily: AppTypography.secondaryFontFamily,
                fontWeight: AppTypography.regular,
                height: 1,
                letterSpacing: -.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // User Name Widget
  Widget _buildUserName(ProfileState profileState) {
    return Text(
      profileState.userName,
      style: AppTypography.headlineSmall.copyWith(
        color: AppColors.neutral900,
        fontSize: 30.sp,
        fontWeight: FontWeight.w600,
        fontFamily: 'CabinetGrotesk',
        height: .95,
      ),
      textAlign: TextAlign.center,
    );
  }

  // Content Section Widget
  Widget _buildContentSection(ProfileState profileState) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _ProfileConstants.contentPadding.w,
      ),
      child: Column(
        children: [
          _buildEditProfileButton(profileState),
          SizedBox(height: 36.h),
          _buildSettingsSections(),
          SizedBox(height: 28.h),
          _buildLogoutButton(),
          SizedBox(height: 50.h),
          _buildPartnershipInfo(),
          SizedBox(height: 400.h),
        ],
      ),
    );
  }

  // Edit Profile Button
  Widget _buildEditProfileButton(ProfileState profileState) {
    return PrimaryButton(
      borderRadius: _ProfileConstants.buttonBorderRadius,
      text: "Edit Profile",
      onPressed:
          profileState.isLoading
              ? null
              : _navigateToEditProfile,
      backgroundColor:
          profileState.isLoading ? AppColors.neutral300 : AppColors.purple500,
      height: _ProfileConstants.buttonHeight.h,
      textColor: AppColors.neutral0,
      fontFamily: 'Karla',
      letterSpacing: -.8,
      fontSize: 18,
      width: 375.w,
      fullWidth: true,
    );
  }

  // Settings Sections
  Widget _buildSettingsSections() {
    return Column(
      children: [
        _buildSection(
          title: 'ACCOUNT SETTINGS',
          children:
              _accountSettings
                  .map(
                    (item) => _buildSettingsItem(
                      icon: item['icon'],
                      iconColor: item['iconColor'],
                      title: item['title'],
                      subtitle: item['subtitle'],
                      onTap: item['onTap'],
                    ),
                  )
                  .toList(),
        ),
        SizedBox(height: _ProfileConstants.sectionSpacing.h),
        _buildSection(
          title: 'PROMOTIONS',
          children:
              _promotions
                  .map(
                    (item) => _buildPromotionItem(
                      icon: item['icon'],
                      iconColor: item['iconColor'],
                      title: item['title'],
                      subtitle: item['subtitle'],
                      actionText: item['actionText'],
                      actionColor: item['actionColor'],
                      onTap: item['onTap'],
                    ),
                  )
                  .toList(),
        ),
        SizedBox(height: _ProfileConstants.sectionSpacing.h),
        _buildSection(
          title: 'SECURITY',
          children:
              _securitySettings
                  .map(
                    (item) => _buildSettingsItem(
                      icon: item['icon'],
                      iconColor: item['iconColor'],
                      title: item['title'],
                      subtitle: item['subtitle'],
                      onTap: item['onTap'],
                    ),
                  )
                  .toList(),
        ),
        SizedBox(height: _ProfileConstants.sectionSpacing.h),
        _buildSection(
          title: 'HELP AND SUPPORT',
          children:
              _helpAndSupport
                  .map(
                    (item) => _buildSettingsItem(
                      icon: item['icon'],
                      iconColor: item['iconColor'],
                      title: item['title'],
                      subtitle: item['subtitle'],
                      onTap: item['onTap'],
                    ),
                  )
                  .toList(),
        ),
        SizedBox(height: _ProfileConstants.sectionSpacing.h),
        _buildSection(
          title: 'ABOUT US',
          children:
              _aboutUs
                  .map(
                    (item) => _buildSettingsItem(
                      icon: item['icon'],
                      iconColor: item['iconColor'],
                      title: item['title'],
                      subtitle: item['subtitle'],
                      onTap: item['onTap'],
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }

  // Logout Button
  Widget _buildLogoutButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.neutral0,
        borderRadius: BorderRadius.circular(
          _ProfileConstants.containerBorderRadius.r,
        ),
        boxShadow: [_buildShadow()],
      ),
      child: _buildSettingsItem(
        icon: "assets/icons/svgs/Box.svg",
        iconColor: AppColors.error500,
        title: 'Log out',
        subtitle: 'Get help and support',
        onTap: _showLogoutDialog,
      ),
    );
  }

  // Shadow Helper
  BoxShadow _buildShadow() {
    return BoxShadow(
      color: const Color.fromARGB(
        255,
        123,
        36,
        211,
      ).withOpacity(_ProfileConstants.shadowOpacity),
      blurRadius: _ProfileConstants.shadowBlur,
      offset: const Offset(0, _ProfileConstants.shadowOffset),
      spreadRadius: _ProfileConstants.shadowSpread,
    );
  }

  // Section Container
  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        SizedBox(height: 8.h),
        _buildSectionContainer(children),
      ],
    );
  }

  // Section Title
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.labelLarge.copyWith(
        color: AppColors.neutral700,
        fontSize: 11.sp,
        fontWeight: FontWeight.w400,
        fontFamily: 'Karla',
        letterSpacing: -.3,
        height: 1.2,
      ),
    );
  }

  // Section Container
  Widget _buildSectionContainer(List<Widget> children) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.neutral0,
        borderRadius: BorderRadius.circular(
          _ProfileConstants.containerBorderRadius.r,
        ),
        boxShadow: [_buildShadow()],
      ),
      child: Column(children: children),
    );
  }

  // Settings Item Widget
  Widget _buildSettingsItem({
    required String icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        _ProfileConstants.containerBorderRadius.r,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        child: Row(
          children: [
            _buildIconContainer(iconColor),
            SizedBox(width: 16.w),
            Expanded(child: _buildItemText(title, iconColor)),
            _buildChevronIcon(),
          ],
        ),
      ),
    );
  }

  // Icon Container
  Widget _buildIconContainer(Color iconColor) {
    return Container(
      width: _ProfileConstants.iconContainerSize.w,
      height: _ProfileConstants.iconContainerSize.w,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(1),
        borderRadius: BorderRadius.circular(24.r),
      ),
      // child: SvgPicture.asset(icon, color: iconColor, height: 20.sp),
    );
  }

  // Item Text
  Widget _buildItemText(String title, Color iconColor) {
    return Text(
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
    );
  }

  // Chevron Icon
  Widget _buildChevronIcon() {
    return Icon(Icons.chevron_right, color: AppColors.neutral400, size: 26.sp);
  }

  // Promotion Item Widget
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
      borderRadius: BorderRadius.circular(24.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        child: Row(
          children: [
            _buildIconContainer(iconColor),
            SizedBox(width: 16.w),
            Expanded(child: _buildItemText(title, AppColors.neutral800)),
            _buildActionBadge(actionText, actionColor),
            SizedBox(width: 8.w),
            _buildChevronIcon(),
          ],
        ),
      ),
    );
  }

  // Action Badge
  Widget _buildActionBadge(String actionText, Color actionColor) {
    return Container(
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
    );
  }

  // Logout Dialog
  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => _buildLogoutDialog(),
    );
  }

  // Logout Dialog Widget
  Widget _buildLogoutDialog() {
    return Dialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: Container(
        padding: EdgeInsets.all(28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogIcon(),
            SizedBox(height: 24.h),
            _buildDialogTitle(),
            SizedBox(height: 16.h),
            _buildDialogButtons(),
          ],
        ),
      ),
    );
  }

  // Dialog Icon
  Widget _buildDialogIcon() {
    return Container(
      width: _ProfileConstants.dialogIconSize.w,
      height: _ProfileConstants.dialogIconSize.w,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
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
    );
  }

  // Dialog Title
  Widget _buildDialogTitle() {
    return Text(
      'Are you sure you want to logout?',
      style: TextStyle(
        fontFamily: 'CabinetGrotesk',
        fontSize: 20.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.neutral900,
        letterSpacing: -0.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  // Dialog Buttons
  Widget _buildDialogButtons() {
    return Column(
      children: [
        _buildDialogLogoutButton(),
        SizedBox(height: 12.h),
        _buildCancelButton(),
      ],
    );
  }

  // Logout Button
  Widget _buildDialogLogoutButton() {
    return PrimaryButton(
      text: 'Yes, Logout',
      onPressed: () {
        Navigator.pop(context);
        ref.read(profileViewModelProvider.notifier).logout();
      },
      backgroundColor: AppColors.purple500,
      textColor: AppColors.neutral0,
      borderRadius: _ProfileConstants.buttonBorderRadius,
      height: _ProfileConstants.buttonHeight.h,
      width: double.infinity,
      fullWidth: true,
      fontFamily: 'Karla',
      fontSize: 18,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.8,
    );
  }

  // Cancel Button
  Widget _buildCancelButton() {
    return SecondaryButton(
      text: 'Cancel',
      onPressed: () => Navigator.pop(context),
      borderColor: AppColors.purple500,
      textColor: AppColors.purple500,
      width: double.infinity,
      fullWidth: true,
      height: _ProfileConstants.buttonHeight.h,
      borderRadius: _ProfileConstants.buttonBorderRadius,
      fontFamily: 'Karla',
      fontSize: 18,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.8,
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
              'Financial services are regulated by the relevant authorities in their operating regions.',
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
