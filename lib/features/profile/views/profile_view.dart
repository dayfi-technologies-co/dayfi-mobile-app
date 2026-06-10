import 'package:dayfi/common/constants/product_features.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/widgets/dayfi_screen_app_bar.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/buttons/secondary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/profile/profile_settings_navigation.dart';
import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';
import 'package:dayfi/features/profile/widgets/profile_settings_style.dart';
import 'package:dayfi/features/profile/widgets/profile_settings_widgets.dart';
import 'package:dayfi/features/profile/widgets/profile_upgrade_card.dart';
import 'package:flutter_svg/svg.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/services/remote/auth_service.dart';
import 'package:dayfi/services/data_clearing_service.dart';

class _ProfileConstants {
  static const double buttonHeight = 48.0;
  static const double buttonBorderRadius = 38.0;
  static const double dialogIconSize = 80.0;
}

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  static final _mutedIcon = AppColors.neutral700.withValues(alpha: 0.35);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(profileViewModelProvider.notifier)
          .loadUserProfile(isInitialLoad: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileViewModelProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const DayfiScreenAppBar(
        title: 'More',
        showBackButton: false,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWide = constraints.maxWidth > 600;
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isWide ? 500 : double.infinity,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [_buildContentSection(profileState)],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContentSection(ProfileState profileState) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ProfileSettingsStyle.contentPadding,
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          const ProfileUpgradeCard(),
          const SizedBox(height: 16),
          _buildSettingsSections(),
          SizedBox(height: 28),
          _buildLogoutButton(),
          SizedBox(height: 28),
          _buildDeleteButton(),
          SizedBox(height: 48),
          _buildPartnershipInfo(),
          SizedBox(height: 112),
        ],
      ),
    );
  }

  Widget _buildSettingsSections() {
    return Column(
      children: [
        ProfileSettingsSection(
          title: 'ACCOUNT',
          children: [
            ProfileSettingsTile(
              icon: 'assets/icons/svgs/account.svg',
              icon2: 'assets/icons/svgs/user1.svg',
              iconColor: _mutedIcon,
              title: 'Profile',
              onTap: ProfileSettingsNavigation.toUserProfile,
            ),
          ],
        ),
        const SizedBox(height: ProfileSettingsStyle.sectionSpacing),
        const ProfileSettingsSection(
          title: 'APPEARANCE',
          children: [ProfileThemeSettingsTile()],
        ),
        const SizedBox(height: ProfileSettingsStyle.sectionSpacing),
        ProfileSettingsSection(
          title: 'MONEY',
          children: [
            ProfileSettingsTile(
              icon: 'assets/icons/svgs/account.svg',
              icon2: 'assets/icons/svgs/coin.svg',
              iconColor: _mutedIcon,
              title: 'Budgets',
              onTap: ProfileSettingsNavigation.toBudgets,
            ),
            ProfileSettingsTile(
              icon: 'assets/icons/svgs/account.svg',
              icon2: 'assets/icons/svgs/automation.svg',
              iconColor: _mutedIcon,
              title: 'DayFlow',
              onTap: () => ProfileSettingsNavigation.toDayFlow(context),
            ),
          ],
        ),
        const SizedBox(height: ProfileSettingsStyle.sectionSpacing),
        ProfileSettingsSection(
          title: 'HELP AND SUPPORT',
          children: [
            ProfileSettingsTile(
              icon: 'assets/icons/svgs/account.svg',
              icon2: 'assets/icons/svgs/contact.svg',
              iconColor: _mutedIcon,
              title: 'Contact Us',
              onTap: () => ProfileSettingsNavigation.contactUs(context),
            ),
            ProfileSettingsTile(
              icon: 'assets/icons/svgs/account.svg',
              icon2: 'assets/icons/svgs/message-question.svg',
              iconColor: _mutedIcon,
              title: 'FAQs',
              onTap: ProfileSettingsNavigation.toFaqs,
            ),
          ],
        ),
        const SizedBox(height: ProfileSettingsStyle.sectionSpacing),
        ProfileSettingsSection(
          title: 'ABOUT US',
          children: [
            ProfileSettingsTile(
              icon: 'assets/icons/svgs/account.svg',
              icon2: 'assets/icons/svgs/terms.svg',
              iconColor: _mutedIcon,
              title: 'Terms & Conditions',
              onTap: () => ProfileSettingsNavigation.toTerms(context),
            ),
            ProfileSettingsTile(
              icon: 'assets/icons/svgs/account.svg',
              icon2: 'assets/icons/svgs/privacy.svg',
              iconColor: _mutedIcon,
              title: 'Privacy Notice',
              onTap: () => ProfileSettingsNavigation.toPrivacy(context),
            ),
          ],
        ),
      ],
    );
  }

  ProfileSettingsTile _logoutTile() => ProfileSettingsTile(
    icon: 'assets/icons/svgs/account.svg',
    icon2: 'assets/icons/svgs/logout1.svg',
    iconColor: _mutedIcon,
    title: 'Log out',
    onTap: _showLogoutDialog,
  );

  ProfileSettingsTile _deleteTile() => ProfileSettingsTile(
    icon: 'assets/icons/svgs/account.svg',
    icon2: 'assets/icons/svgs/delete.svg',
    iconColor: AppColors.error500,
    title: 'Delete Account',
    onTap: ProductFeatures.profileDeleteAccount
        ? _showDeleteAccountDialog
        : () => ProfileSettingsNavigation.contactUs(context),
  );

  Widget _buildLogoutButton() => _logoutTile();

  Widget _buildDeleteButton() => _deleteTile();

  Widget _buildPartnershipInfo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Center(
            child: Text(
              'Financial services are regulated by the relevant authorities in their operating regions.',
              style: AppTypography.bodySmall.copyWith(
                fontFamily: 'Chirp',
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.75),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.20,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 14),
          Center(
            child: Text(
              'Version 1.0.0',
              style: AppTypography.bodySmall.copyWith(
                fontFamily: 'Chirp',
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.75),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.20,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // Dialog methods
  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => _buildLogoutDialog(),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => _buildDeleteAccountDialog(),
    );
  }

  Widget _buildLogoutDialog() {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogIcon("assets/icons/svgs/logout1.svg"),
            SizedBox(height: 24),
            _buildDialogTitle(
              'Are you sure you want to logout? You will be asked to create a new passcode.',
            ),
            SizedBox(height: 16),
            _buildDialogButtons(_buildDialogLogoutButton, _buildCancelButton),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteAccountDialog() {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogIcon("assets/icons/svgs/delete.svg"),
            SizedBox(height: 24),
            _buildDialogDescription(
              'Are you sure you want to delete your account?\nThis action cannot be undone.\n\nAll your data, including transaction history, will be permanently removed.',
            ),
            SizedBox(height: 32),
            _buildDialogButtons(_buildDeleteAccountButton, _buildCancelButton),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogIcon(String iconPath) {
    return Container(
      width: _ProfileConstants.dialogIconSize,
      height: _ProfileConstants.dialogIconSize,
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
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SvgPicture.asset(iconPath, color: Colors.white),
      ),
    );
  }

  Widget _buildDialogTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'FunnelDisplay',
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurface,
        letterSpacing: -0.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDialogDescription(String description) {
    return Text(
      description,
      style: AppTypography.bodyMedium.copyWith(
        fontFamily: 'FunnelDisplay',
        fontSize: 20,
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.5,
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDialogButtons(
    Widget Function() primaryButton,
    Widget Function() secondaryButton,
  ) {
    return Column(
      children: [primaryButton(), SizedBox(height: 12), secondaryButton()],
    );
  }

  Widget _buildDialogLogoutButton() {
    return PrimaryButton(
      text: 'Yes, Logout',
      onPressed: () {
        Navigator.pop(context);
        ref.read(profileViewModelProvider.notifier).logout(ref);
      },
      backgroundColor: AppColors.purple500,
      textColor: AppColors.neutral0,
      borderRadius: _ProfileConstants.buttonBorderRadius,
      height: _ProfileConstants.buttonHeight,
      width: double.infinity,
      fullWidth: true,
      fontFamily: 'Chirp',
      fontSize: 18,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.3,
    );
  }

  Widget _buildDeleteAccountButton() {
    return PrimaryButton(
      text: 'Delete Account',
      onPressed: () async {
        Navigator.pop(context);
        await _deleteAccount();
      },
      backgroundColor: AppColors.error500,
      textColor: AppColors.neutral0,
      borderRadius: _ProfileConstants.buttonBorderRadius,
      height: _ProfileConstants.buttonHeight,
      width: double.infinity,
      fullWidth: true,
      fontFamily: 'Chirp',
      fontSize: 18,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.3,
    );
  }

  Widget _buildCancelButton() {
    return SecondaryButton(
      text: 'Cancel',
      onPressed: () => Navigator.pop(context),
      borderColor: Colors.transparent,
      textColor: AppColors.purple500ForTheme(context),
      width: double.infinity,
      fullWidth: true,
      height: _ProfileConstants.buttonHeight,
      borderRadius: _ProfileConstants.buttonBorderRadius,
      fontFamily: 'Chirp',
      fontSize: 18,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.3,
    );
  }

  Future<void> _deleteAccount() async {
    try {
      if (mounted) {
        TopSnackbar.show(
          context,
          message: 'Deleting account...',
          isError: false,
        );
      }

      final authService = locator<AuthService>();
      final response = await authService.deleteAccount();

      if (!response.error) {
        await locator<DataClearingService>().clearAllUserData(ref);
        if (mounted) {
          appRouter.pushOnboardingAndClearStack();
          TopSnackbar.show(
            context,
            message: 'Account deleted successfully',
            isError: false,
          );
        }
      } else {
        if (mounted) {
          TopSnackbar.show(
            context,
            message: response.message ?? 'Failed to delete account',
            isError: true,
          );
        }
      }
    } catch (e) {
      AppLogger.error('Error deleting account: $e');
      if (mounted) {
        TopSnackbar.show(
          context,
          message: 'Failed to delete account. Please try again.',
          isError: true,
        );
      }
    }
  }
}
