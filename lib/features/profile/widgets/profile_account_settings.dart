import 'package:dayfi/common/helpers/biometric_preferences.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/profile/profile_settings_navigation.dart';
import 'package:dayfi/features/profile/widgets/profile_settings_style.dart';
import 'package:dayfi/features/profile/widgets/profile_settings_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Account-centric settings shown on [UserProfileView] (from Home avatar).
class ProfileAccountSettings extends ConsumerStatefulWidget {
  const ProfileAccountSettings({super.key});

  @override
  ConsumerState<ProfileAccountSettings> createState() =>
      _ProfileAccountSettingsState();
}

class _ProfileAccountSettingsState extends ConsumerState<ProfileAccountSettings> {
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricStatus();
  }

  Future<void> _loadBiometricStatus() async {
    try {
      final enabled = await BiometricPreferences.isEnabled();
      if (mounted) setState(() => _biometricEnabled = enabled);
    } catch (e) {
      AppLogger.error('Error loading biometric status: $e');
    }
  }

  Future<void> _onBiometricChanged(bool value) async {
    if (value) {
      await ProfileSettingsNavigation.toBiometricSetup();
      await _loadBiometricStatus();
      return;
    }

    try {
      await BiometricPreferences.setEnabled(false);
      if (mounted) {
        setState(() => _biometricEnabled = false);
        TopSnackbar.show(
          context,
          message: 'Biometric authentication disabled',
          isError: false,
        );
      }
    } catch (e) {
      AppLogger.error('Error disabling biometrics: $e');
      if (mounted) {
        TopSnackbar.show(
          context,
          message: 'Failed to disable biometrics',
          isError: true,
        );
      }
    }
  }

  static final _mutedIcon = AppColors.neutral700.withValues(alpha: 0.35);

  ProfileSettingsTile _tile({
    required String icon2,
    required String title,
    required VoidCallback onTap,
    String? actionText,
  }) {
    return ProfileSettingsTile(
      icon: 'assets/icons/svgs/account.svg',
      icon2: icon2,
      iconColor: _mutedIcon,
      title: title,
      onTap: onTap,
      actionText: actionText,
      actionColor: AppColors.neutral600,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ProfileSettingsStyle.contentPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileSettingsSection(
            title: 'ACCOUNT',
            children: [
              _tile(
                icon2: 'assets/icons/svgs/user1.svg',
                title: 'Account Limits',
                onTap: ProfileSettingsNavigation.toAccountLimits,
              ),
            ],
          ),
          const SizedBox(height: ProfileSettingsStyle.sectionSpacing),
          ProfileSettingsSection(
            title: 'SECURITY',
            children: [
              _tile(
                icon2: 'assets/icons/svgs/security-safe.svg',
                title: 'Recovery phrase',
                onTap: ProfileSettingsNavigation.toRecoveryPhrase,
              ),
              _tile(
                icon2: 'assets/icons/svgs/security-safe.svg',
                title: 'Change my Transaction PIN',
                onTap: ProfileSettingsNavigation.toChangeTransactionPin,
              ),
              _tile(
                icon2: 'assets/icons/svgs/security-safe.svg',
                title: 'Reset my Transaction PIN',
                onTap: ProfileSettingsNavigation.toResetTransactionPin,
              ),
              ProfileBiometricSettingsTile(
                enabled: _biometricEnabled,
                onChanged: _onBiometricChanged,
              ),
            ],
          ),
          const SizedBox(height: ProfileSettingsStyle.sectionSpacing),
          ProfileSettingsSection(
            title: 'REWARDS',
            children: [
              _tile(
                icon2: 'assets/icons/svgs/gift.svg',
                title: 'Referrals',
                actionText: 'Coming soon',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
