import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/buttons/secondary_button.dart';
import 'package:dayfi/common/widgets/shimmer_widgets.dart';
import 'package:dayfi/common/utils/haptic_helper.dart';
import 'package:dayfi/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';
import 'package:dayfi/features/legal/terms_of_use.dart';
import 'package:dayfi/features/legal/privacy_notice.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intercom_flutter/intercom_flutter.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/common/utils/tier_utils.dart';
import 'package:dayfi/services/notification_service.dart';
import 'package:dayfi/services/remote/wallet_service.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:share_plus/share_plus.dart';

// Constants for consistent styling
class _ProfileConstants {
  static const double headerPaddingTop = 8.0;
  static const double headerPaddingBottom = 0.0;
  static const double contentPadding = 18.0;
  static const double sectionSpacing = 32.0;
  static const double buttonHeight = 48.000;
  static const double buttonBorderRadius = 38.0;
  static const double containerBorderRadius = 12.0;
  static const double tierContainerBorderRadius = 40.0;
  static const double iconContainerSize = 40.0;
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
  String? _dayfiId;
  bool _isLoadingDayfiId = true;
  bool _isBiometricEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(profileViewModelProvider.notifier)
          .loadUserProfile(isInitialLoad: true);
      _loadDayfiId();
      _loadBiometricStatus();
    });
  }

  Future<void> _loadBiometricStatus() async {
    try {
      final userData = await localCache.getUser();
      final biometricEnabled = userData['biometric_enabled'] as bool? ?? false;
      if (mounted) {
        setState(() {
          _isBiometricEnabled = biometricEnabled;
        });
      }
    } catch (e) {
      AppLogger.error('Error loading biometric status: $e');
    }
  }

  Future<void> _handleBiometricToggle(bool value) async {
    if (value) {
      // Navigate to biometric setup
      await appRouter.pushNamed(
        AppRoute.biometricSetupView,
        arguments: {'fromProfile': true},
      );

      // Reload biometric status after returning
      await _loadBiometricStatus();
    } else {
      // Disable biometrics
      try {
        await localCache.saveToLocalCache(
          key: 'biometric_enabled',
          value: false,
        );
        final userData = await localCache.getUser();
        userData['biometric_enabled'] = false;
        await localCache.saveToLocalCache(key: 'user', value: userData);

        setState(() {
          _isBiometricEnabled = false;
        });

        if (mounted) {
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
  }

  Future<void> _loadDayfiId() async {
    // Load cached Dayfi Tag from storage first
    final cachedDayfiId = localCache.getFromLocalCache('dayfi_id') as String?;
    if (cachedDayfiId != null &&
        cachedDayfiId.isNotEmpty &&
        cachedDayfiId != 'null') {
      setState(() {
        _dayfiId = cachedDayfiId;
        _isLoadingDayfiId = false;
      });
    } else {
      // Only show loading if there's no cached data
      setState(() {
        _isLoadingDayfiId = true;
      });
    }

    try {
      final walletService = locator<WalletService>();
      final walletResponse = await walletService.fetchWalletDetails();

      // Find the first wallet with a non-empty Dayfi Tag
      if (walletResponse.wallets.isNotEmpty) {
        final walletWithDayfiId = walletResponse.wallets.firstWhere(
          (wallet) => wallet.dayfiId.isNotEmpty && wallet.dayfiId != 'null',
          orElse: () => walletResponse.wallets.first,
        );

        if (walletWithDayfiId.dayfiId.isNotEmpty &&
            walletWithDayfiId.dayfiId != 'null') {
          // Cache the Dayfi Tag for next time
          await localCache.saveToLocalCache(
            key: 'dayfi_id',
            value: walletWithDayfiId.dayfiId,
          );

          setState(() {
            _dayfiId = walletWithDayfiId.dayfiId;
            _isLoadingDayfiId = false;
          });
          AppLogger.info('Dayfi Tag loaded: ${walletWithDayfiId.dayfiId}');
        } else {
          // No valid Dayfi Tag found, clear any cached value
          await localCache.removeFromLocalCache('dayfi_id');
          setState(() {
            _dayfiId = null;
            _isLoadingDayfiId = false;
          });
        }
      } else {
        setState(() {
          _isLoadingDayfiId = false;
        });
      }
    } catch (e) {
      AppLogger.error('Error loading Dayfi Tag: $e');
      setState(() {
        _isLoadingDayfiId = false;
      });
      // Don't show error to user, just don't display Dayfi Tag
    }
  }

  // Settings sections data
  List<Map<String, dynamic>> get _accountSettings => [
    {
      'icon': "assets/icons/svgs/account.svg",
      'icon2': "assets/icons/svgs/user1.svg",
      'iconColor': AppColors.neutral700.withOpacity(.35),
      'title': 'Account Limits',
      'subtitle': 'View and manage your transfer limits',
      'onTap': () => _navigateToAccountLimits(),
    },
    // {
    //   'icon': "assets/icons/svgs/Box.svg",
    //   'iconColor': AppColors.pink700,
    //   'title': 'Payment Methods',
    //   'subtitle': 'Manage your payment options',
    //   'onTap': () => _navigateToPaymentMethods(),
    // },
    // {
    //   'icon': "assets/icons/svgs/recipients.svg",
    //   'iconColor': Theme.of(context).colorScheme.primary,
    //   'title': 'Beneficiaries',
    //   'subtitle': 'View and manage your beneficiaries',
    //   'onTap': () => _navigateToBeneficiaries(),
    // },
    // {
    //   'icon': "assets/icons/svgs/Box.svg",
    //   'iconColor': AppColors.warning500,
    //   'title': 'Upload Documents',
    //   'subtitle': 'Complete your KYC verification',
    //   'onTap': () => _navigateToDocumentUpload(),
    // },
  ];

  List<Map<String, dynamic>> get _promotions => [
    {
      'icon': "assets/icons/svgs/account.svg",
      'icon2': "assets/icons/svgs/gift.svg",
      'iconColor': AppColors.neutral700.withOpacity(.35),
      'title': 'Referrals',
      'subtitle': 'Invite friends and earn rewards',
      'actionText': "Coming soon", // 'Get ₦5000',
      'actionColor': AppColors.neutral600,
      'onTap': () => _navigateToReferrals(),
    },
  ];

  List<Map<String, dynamic>> get _securitySettings => [
    // {
    //   'icon': "assets/icons/svgs/account.svg",
    //   'icon2': "assets/icons/svgs/fingerprint.svg",
    //   'iconColor': AppColors.neutral700.withOpacity(.35),
    //   'title': 'Biometric Authentication',
    //   'subtitle': '',
    //   'isToggle': true,
    //   'onTap': null, // Will be handled by toggle
    // },
    {
      'icon': "assets/icons/svgs/account.svg",
      'icon2': "assets/icons/svgs/security-safe.svg",
      'iconColor': AppColors.neutral700.withOpacity(.35),
      'title': 'Change my Transaction PIN',
      'subtitle': '',
      'onTap': () => _navigateToChangeTransactionPin(),
    },
    {
      'icon': "assets/icons/svgs/account.svg",
      'icon2': "assets/icons/svgs/security-safe.svg",
      'iconColor': AppColors.neutral700.withOpacity(.35),
      'title': 'Reset my Transaction PIN',
      'subtitle': '',
      'onTap': () => _navigateToResetTransactionPin(),
    },
  ];

  List<Map<String, dynamic>> get _helpAndSupport => [
    {
      'icon': "assets/icons/svgs/account.svg",
      'icon2': "assets/icons/svgs/contact.svg",
      'iconColor': AppColors.neutral700.withOpacity(.35),
      'title': 'Contact Us',
      'subtitle': 'Reach out to our support team',
      'onTap': () => _navigateToContactUs(),
    },
    {
      'icon': "assets/icons/svgs/account.svg",
      'icon2': "assets/icons/svgs/message-question.svg",
      'iconColor': AppColors.neutral700.withOpacity(.35),
      'title': 'FAQs',
      'subtitle': '',
      'actionText': "Coming soon", // 'Get ₦5000',
      'actionColor': AppColors.neutral600,
      'onTap': () => _navigateToFAQs(),
    },
  ];

  List<Map<String, dynamic>> get _aboutUs => [
    {
      'icon': "assets/icons/svgs/account.svg",
      'icon2': "assets/icons/svgs/terms.svg",
      'iconColor': AppColors.neutral700.withOpacity(.35),
      'title': 'Terms & Conditions',
      'subtitle': 'Reach out to our support team',
      'onTap': () => _navigateToTermsAndConditions(),
    },
    {
      'icon': "assets/icons/svgs/account.svg",
      'icon2': "assets/icons/svgs/privacy.svg",
      'iconColor': AppColors.neutral700.withOpacity(.35),
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
    appRouter.pushNamed(AppRoute.accountLimitsView);
  }

  // void _navigateToBeneficiaries() {
  //   appRouter.pushNamed(AppRoute.recipientsView);
  // }

  // void _navigateToPaymentMethods() {
  //   // TODO: Navigate to payment methods
  // }

  // void _navigateToDocumentUpload() {
  //   appRouter.pushNamed(
  //     AppRoute.uploadDocumentsView,
  //     arguments: {'showBackButton': true},
  //   );
  // }

  void _navigateToReferrals() {
    // TODO: Navigate to referrals
  }

  void _navigateToChangeTransactionPin() {
    appRouter.pushNamed(AppRoute.changeTransactionPinOldView);
  }

  void _navigateToResetTransactionPin() {
    appRouter.pushNamed(AppRoute.resetTransactionPinIntroView);
  }

  void _navigateToContactUs() async {
    try {
      await Intercom.instance.displayMessenger();
    } catch (e) {
      // Fallback in case Intercom fails
      if (mounted) {
        TopSnackbar.show(
          context,
          message: 'Unable to open support chat. Please try again later.',
          isError: true,
        );
      }
    }
  }

  void _navigateToFAQs() {
    appRouter.pushNamed(AppRoute.faqView);
  }

  // Test notification method (temporary for testing)
  void _testNotification() async {
    try {
      final notificationService = NotificationService();
      await notificationService.init();

      // Fire immediately with a clear payload
      await notificationService.showLocalNotification(
        'Test Notification',
        'This is a test from Profile > Test Notification button',
        data: {'type': 'test', 'action': 'test', 'source': 'profile_view'},
      );

      // if (mounted) {
      //   TopSnackbar.show(
      //     context,
      //     message: 'Notification triggered. Check your notification shade.',
      //     isError: false,
      //   );
      // }
    } catch (e) {
      // if (mounted) {
      //   TopSnackbar.show(
      //     context,
      //     message: 'Failed to trigger notification: $e',
      //     isError: true,
      //   );
      // }
    }
  }

  void _navigateToTermsAndConditions() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TermsOfUseView()),
    );
  }

  void _navigateToPrivacyNotice() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrivacyNoticeView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileViewModelProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: .5,
        foregroundColor: Theme.of(context).scaffoldBackgroundColor,
        shadowColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,

        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: const SizedBox.shrink(),
        leadingWidth: 0,
        title: Text(
          "Account",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontFamily: 'FunnelDisplay',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
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
                  children: [
                    // Header Section
                    _buildHeaderSection(profileState),

                    SizedBox(height: 18),

                    // Content
                    _buildContentSection(profileState),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Header Section Widget
  Widget _buildHeaderSection(ProfileState profileState) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        24,
        _ProfileConstants.headerPaddingTop,
        24,
        _ProfileConstants.headerPaddingBottom,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildProfileImageWithTier(profileState),
          SizedBox(height: 12),
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
          padding: EdgeInsets.only(bottom: 32),
          child: Image.asset(
            "assets/icons/pngs/account.png",
            height: _ProfileConstants.profileImageHeight,
          ),
        ),
        if (!profileState.isLoading) _buildTierBadge(profileState),
      ],
    );
  }

  // Tier Badge Widget
  Widget _buildTierBadge(ProfileState profileState) {
    final tierDisplayName = TierUtils.getTierDisplayName(profileState.user);
    final tierIconPath = TierUtils.getTierIconPath(profileState.user);
    final tierColor = TierUtils.getTierColor(profileState.user);

    // Get color based on tier
    Color tierColorValue;
    switch (tierColor) {
      case 'success600':
        tierColorValue = AppColors.success600;
        break;
      case 'warning600':
        tierColorValue = AppColors.warning600;
        break;
      default:
        tierColorValue = AppColors.info600;
    }

    return Positioned(
      bottom: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(
            _ProfileConstants.tierContainerBorderRadius,
          ),
        ),
        child: Row(
          children: [
            Image.asset(
              tierIconPath,
              height: _ProfileConstants.tierImageHeight,
            ),
            SizedBox(width: 4),
            Text(
              tierDisplayName,
              style: AppTypography.labelMedium.copyWith(
                color: tierColorValue,
                fontSize: 16,
                fontFamily: AppTypography.secondaryFontFamily,
                fontWeight: AppTypography.regular,
                height: 1,
                letterSpacing: -.70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // User Name Widget
  Widget _buildUserName(ProfileState profileState) {
    // Check if Dayfi Tag exists
    // final hasDayfiTag = _dayfiId != null && _dayfiId!.isNotEmpty;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // User's name
        Text(
          profileState.userName.isNotEmpty
              ? profileState.userName
                  .split(' ')
                  .map(
                    (word) =>
                        word.isNotEmpty
                            ? word[0].toUpperCase() + word.substring(1)
                            : '',
                  )
                  .join(' ')
              : '',
          style: AppTypography.headlineSmall.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 28,
            fontWeight: FontWeight.w600,
            fontFamily: 'FunnelDisplay',
            height: .95,
            letterSpacing: -.25,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Content Section Widget
  Widget _buildContentSection(ProfileState profileState) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _ProfileConstants.contentPadding,
      ),
      child: Column(
        children: [
          _buildEditProfileButton(profileState),
          SizedBox(height: 36),
          _buildSettingsSections(),
          SizedBox(height: 28),
          _buildLogoutButton(),
          SizedBox(height: 50),
          _buildPartnershipInfo(),
          SizedBox(height: 112),
        ],
      ),
    );
  }

  // Edit Profile Button
  Widget _buildEditProfileButton(ProfileState profileState) {
    return Column(
      children: [
        PrimaryButton(
          borderRadius: _ProfileConstants.buttonBorderRadius,
          text: "Edit Profile",
          onPressed: profileState.isLoading ? null : _navigateToEditProfile,
          backgroundColor:
              profileState.isLoading
                  ? AppColors.purple500
                  : AppColors.purple500,
          height: _ProfileConstants.buttonHeight,
          textColor: AppColors.neutral0,
          fontFamily: 'Chirp',
          letterSpacing: -.70,
          fontSize: 18,
          width: 375,
          fullWidth: true,
        ), // Dayfi Tag section
        SizedBox(height: 24),
        if (_isLoadingDayfiId) ...[
          ShimmerWidgets.textShimmer(context, width: 200, height: 20),
        ] else if (_dayfiId != null && _dayfiId!.isNotEmpty) ...[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(
                _ProfileConstants.containerBorderRadius,
              ),
              boxShadow: [_buildShadow()],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      '@',
                      style: TextStyle(
                        // fontFamily: 'FunnelDisplay',',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        letterSpacing: 0.00,
                        height: 1.450,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      _dayfiId!,
                      style: TextStyle(
                        // fontFamily: 'FunnelDisplay',',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        letterSpacing: 0.00,
                        height: 1.450,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 12),
                Row(
                  children: [
                    Semantics(
                      button: true,
                      label: 'Copy Dayfi Tag',
                      hint: 'Double tap to copy your Dayfi Tag to clipboard',
                      child: GestureDetector(
                        onTap: () {
                          HapticHelper.lightImpact();
                          Clipboard.setData(ClipboardData(text: '@$_dayfiId'));
                          TopSnackbar.show(
                            context,
                            message: 'Dayfi Tag copied to clipboard',
                            isError: false,
                          );
                        },
                        child: Row(
                          children: [
                            Text(
                              "copy",
                              style: TextStyle(
                                fontFamily: 'Chirp',
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                letterSpacing: 0.00,
                                height: 1.450,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            SizedBox(width: 6),
                            SvgPicture.asset(
                              "assets/icons/svgs/copy.svg",
                              color: Theme.of(context).colorScheme.primary,
                              height: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Semantics(
                      button: true,
                      label: 'Share Dayfi Tag',
                      hint: 'Double tap to share your Dayfi Tag',
                      child: GestureDetector(
                        onTap: () async {
                          HapticHelper.lightImpact();
                          try {
                            await Share.share(
                              'Send me money on DayFi! My tag is @$_dayfiId\n\nDownload DayFi: https://dayfi.co',
                              subject: 'My Dayfi Tag',
                            );
                          } catch (e) {
                            if (mounted) {
                              TopSnackbar.show(
                                context,
                                message: 'Unable to share. Please try again.',
                                isError: true,
                              );
                            }
                          }
                        },
                        child: Row(
                          children: [
                            Text(
                              "share",
                              style: TextStyle(
                                fontFamily: 'Chirp',
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                letterSpacing: 0.00,
                                height: 1.450,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            SizedBox(width: 6),
                            SvgPicture.asset(
                              "assets/icons/svgs/share.svg",
                              color: Theme.of(context).colorScheme.primary,
                              height: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ] else ...[
          SizedBox(height: 8),
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            onTap: () async {
              final result = await Navigator.pushNamed(
                context,
                AppRoute.dayfiTagExplanationView,
              );
              // Reload Dayfi Tag if created
              if (result != null && result is String && result.isNotEmpty) {
                // Strip @ prefix if present, as we store it without @
                final dayfiIdValue =
                    result.startsWith('@') ? result.substring(1) : result;

                // Cache the new Dayfi Tag immediately
                await localCache.saveToLocalCache(
                  key: 'dayfi_id',
                  value: dayfiIdValue,
                );

                // Update state immediately with the result
                setState(() {
                  _dayfiId = dayfiIdValue;
                  _isLoadingDayfiId = false;
                });

                // Also reload from API in the background to ensure consistency
                _loadDayfiId();
              }
            },

            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Text(
                "Create your Dayfi Tag",
                style: TextStyle(
                  fontFamily: 'Chirp',
                  color: AppColors.purple500ForTheme(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -.25,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ],
      ],
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
                      icon2: item['icon2'],
                      iconColor: item['iconColor'],
                      title: item['title'],
                      subtitle: item['subtitle'],
                      onTap: item['onTap'],
                    ),
                  )
                  .toList(),
        ),
        SizedBox(height: _ProfileConstants.sectionSpacing),
        _buildSection(
          title: 'PROMOTIONS',
          children:
              _promotions
                  .map(
                    (item) => _buildPromotionItem(
                      icon: item['icon'],
                      icon2: item['icon2'],
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
        SizedBox(height: _ProfileConstants.sectionSpacing),
        _buildSection(
          title: 'SECURITY',
          children:
              _securitySettings
                  .map(
                    (item) => _buildSettingsItem(
                      icon: item['icon'],
                      icon2: item['icon2'],
                      iconColor: item['iconColor'],
                      title: item['title'],
                      subtitle: item['subtitle'],
                      onTap: item['onTap'],
                      isToggle: item['isToggle'] ?? false,
                      toggleValue:
                          item['isToggle'] == true ? _isBiometricEnabled : null,
                      onToggleChanged:
                          item['isToggle'] == true
                              ? _handleBiometricToggle
                              : null,
                    ),
                  )
                  .toList(),
        ),
        SizedBox(height: _ProfileConstants.sectionSpacing),
        _buildSection(
          title: 'HELP AND SUPPORT',
          children:
              _helpAndSupport
                  .map(
                    (item) => _buildSettingsItem(
                      icon: item['icon'],
                      icon2: item['icon2'],
                      iconColor: item['iconColor'],
                      title: item['title'],
                      subtitle: item['subtitle'],
                      onTap: item['onTap'],
                    ),
                  )
                  .toList(),
        ),
        SizedBox(height: _ProfileConstants.sectionSpacing),
        _buildSection(
          title: 'ABOUT US',
          children:
              _aboutUs
                  .map(
                    (item) => _buildSettingsItem(
                      icon: item['icon'],
                      icon2: item['icon2'],
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
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(
          _ProfileConstants.containerBorderRadius,
        ),
        boxShadow: [_buildShadow()],
      ),
      child: _buildSettingsItem(
        icon: "assets/icons/svgs/account.svg",
        icon2: "assets/icons/svgs/logout1.svg",
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
        SizedBox(height: 8),
        _buildSectionContainer(children),
      ],
    );
  }

  // Section Title
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.labelLarge.copyWith(
        color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(.85),
        fontSize: 11,
        fontWeight: FontWeight.w500,
        fontFamily: 'Chirp',
        letterSpacing: -.25,
        height: 1.2,
      ),
    );
  }

  // Section Container
  Widget _buildSectionContainer(List<Widget> children) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(
          _ProfileConstants.containerBorderRadius,
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
    required VoidCallback? onTap,
    required String icon2,
    bool isToggle = false,
    bool? toggleValue,
    ValueChanged<bool>? onToggleChanged,
  }) {
    return InkWell(
      onTap: isToggle ? null : onTap,
      borderRadius: BorderRadius.circular(
        _ProfileConstants.containerBorderRadius,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            _buildIconContainer(iconColor, icon, icon2),
            SizedBox(width: 16),
            Expanded(child: _buildItemText(title, iconColor)),
            isToggle
                ? Switch(
                  value: toggleValue ?? false,
                  onChanged: onToggleChanged,
                  activeColor: Theme.of(context).colorScheme.primary,
                )
                : _buildChevronIcon(),
          ],
        ),
      ),
    );
  }

  // Icon Container
  Widget _buildIconContainer(Color iconColor, String icon, String icon2) {
    return SizedBox(
      width: _ProfileConstants.iconContainerSize,
      height: _ProfileConstants.iconContainerSize,
      // decoration: BoxDecoration(
      //   color: iconColor.withOpacity(1),
      //   borderRadius: BorderRadius.circular(24),
      // ),
      child: Stack(
        alignment: AlignmentGeometry.center,
        children: [
          SvgPicture.asset(
            icon,
            height: 40,
            color:
                icon2 == "assets/icons/svgs/logout1.svg"
                    ? AppColors.error600
                    : Theme.of(context).scaffoldBackgroundColor,
          ),
          Center(
            child: SvgPicture.asset(
              icon2,
              height: 24,
              color:
                  icon2 == "assets/icons/svgs/logout1.svg"
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface.withOpacity(.8),
            ),
          ),
        ],
      ),
    );
  }

  // Item Text
  Widget _buildItemText(String title, Color iconColor) {
    return Text(
      title,
      style: AppTypography.titleMedium.copyWith(
        fontFamily: 'Chirp',
        color:
            iconColor == AppColors.error500
                ? AppColors.error500
                : Theme.of(context).colorScheme.onSurface,
        fontSize: 18,
        fontWeight: FontWeight.w500,
        letterSpacing: -.250,
        height: 1.2,
      ),
    );
  }

  // Chevron Icon
  Widget _buildChevronIcon() {
    return Icon(Icons.chevron_right, color: AppColors.neutral400, size: 20);
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
    required String icon2,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            _buildIconContainer(iconColor, icon, icon2),
            SizedBox(width: 16),
            Expanded(
              child: _buildItemText(
                title,
                Theme.of(context).colorScheme.onSurface,
              ),
            ),
            _buildActionBadge(actionText, actionColor),
            SizedBox(width: 8),
            _buildChevronIcon(),
          ],
        ),
      ),
    );
  }

  // Action Badge
  Widget _buildActionBadge(String actionText, Color actionColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: actionColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        actionText,
        style: AppTypography.labelMedium.copyWith(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          fontFamily: 'Chirp',
          letterSpacing: -.25,
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogIcon(),
            SizedBox(height: 24),
            _buildDialogTitle(),
            SizedBox(height: 16),
            _buildDialogButtons(),
          ],
        ),
      ),
    );
  }

  // Dialog Icon
  Widget _buildDialogIcon() {
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
    );
  }

  // Dialog Title
  Widget _buildDialogTitle() {
    return Text(
      'Are you sure you want to logout? You will be asked to create a new passcode.',
      style: TextStyle(
        fontFamily: 'FunnelDisplay',
        fontSize: 20,

        // height: 1.6,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurface,
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
        SizedBox(height: 12),
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
      letterSpacing: -0.8,
    );
  }

  // Cancel Button
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
      letterSpacing: -0.8,
    );
  }

  Widget _buildPartnershipInfo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          // Center(
          //   child: Text(
          //     'DayFi is powered by Yellow Card in partnership with Smile ID.',
          //     style: AppTypography.bodySmall.copyWith(
          //       fontFamily: 'Chirp',
          //       color: Theme.of(
          //         context,
          //       ).colorScheme.onSurface.withOpacity(0.75),
          //       fontSize: 14,
          //       fontWeight: FontWeight.w500,
          //       letterSpacing: -.25,
          //       height: 1.2,
          //     ),
          //     textAlign: TextAlign.center,
          //   ),
          // ),
          // SizedBox(height: 14),
          Center(
            child: Text(
              'Financial services are regulated by the relevant authorities in their operating regions.',
              style: AppTypography.bodySmall.copyWith(
                fontFamily: 'Chirp',
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.75),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: -.25,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // SizedBox(height: 14),
          // // Test notification button (temporary)
          // Center(
          //   child: TextButton(
          //     onPressed: _testNotification,
          //     child: Text('Test Notification'),
          //   ),
          // ),
          SizedBox(height: 14),
          Center(
            child: Text(
              'Version 1.0.0',
              style: AppTypography.bodySmall.copyWith(
                fontFamily: 'Chirp',
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.75),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: -.25,
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
