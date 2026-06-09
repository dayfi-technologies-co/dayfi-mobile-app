import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/constants/username_copy.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/common/utils/haptic_helper.dart';
import 'package:dayfi/common/utils/tier_utils.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/services/remote/wallet_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:share_plus/share_plus.dart';

class ProfileHeaderSection extends ConsumerStatefulWidget {
  const ProfileHeaderSection({super.key});

  @override
  ConsumerState<ProfileHeaderSection> createState() =>
      _ProfileHeaderSectionState();
}

class _ProfileHeaderSectionState extends ConsumerState<ProfileHeaderSection> {
  static const double _profileImageHeight = 84.0;
  static const double _tierImageHeight = 32.0;
  static const double _buttonHeight = 48.0;
  static const double _buttonBorderRadius = 38.0;
  static const double _containerBorderRadius = 12.0;
  static const double _tierContainerBorderRadius = 40.0;

  String? _dayfiId;
  bool _isLoadingDayfiId = true;

  static String? _normalizeStoredDayfiId(String? raw) {
    if (raw == null) return null;
    final t = raw.trim();
    if (t.isEmpty || t.toLowerCase() == 'null') return null;
    return t.startsWith('@') ? t.substring(1) : t;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(profileViewModelProvider.notifier)
          .loadUserProfile(isInitialLoad: true);
      _loadDayfiId();
    });
  }

  Future<String?> _readDayfiIdFromStoredUser() async {
    try {
      final user = await localCache.getUser();
      final raw = user['dayfi_id'] ?? user['dayfiId'];
      return _normalizeStoredDayfiId(raw?.toString());
    } catch (e) {
      AppLogger.error('Error reading Dayfi Tag from stored user: $e');
      return null;
    }
  }

  Future<void> _loadDayfiId() async {
    final cachedDayfiId = _normalizeStoredDayfiId(
      localCache.getFromLocalCache('dayfi_id') as String?,
    );
    if (cachedDayfiId != null && cachedDayfiId.isNotEmpty) {
      setState(() {
        _dayfiId = cachedDayfiId;
        _isLoadingDayfiId = false;
      });
    } else {
      setState(() => _isLoadingDayfiId = true);
    }

    try {
      final walletService = locator<WalletService>();
      final walletResponse = await walletService.fetchWalletDetails();

      if (walletResponse.wallets.isNotEmpty) {
        final walletWithDayfiId = walletResponse.wallets.firstWhere(
          (wallet) => wallet.dayfiId.isNotEmpty && wallet.dayfiId != 'null',
          orElse: () => walletResponse.wallets.first,
        );

        final fromWallet = _normalizeStoredDayfiId(walletWithDayfiId.dayfiId);
        if (fromWallet != null && fromWallet.isNotEmpty) {
          await localCache.saveToLocalCache(key: 'dayfi_id', value: fromWallet);
          setState(() {
            _dayfiId = fromWallet;
            _isLoadingDayfiId = false;
          });
        } else {
          final fromUser = await _readDayfiIdFromStoredUser();
          if (fromUser != null && fromUser.isNotEmpty) {
            await localCache.saveToLocalCache(key: 'dayfi_id', value: fromUser);
            setState(() {
              _dayfiId = fromUser;
              _isLoadingDayfiId = false;
            });
          } else {
            await localCache.removeFromLocalCache('dayfi_id');
            setState(() {
              _dayfiId = null;
              _isLoadingDayfiId = false;
            });
          }
        }
      } else {
        final fromUser = await _readDayfiIdFromStoredUser();
        if (fromUser != null && fromUser.isNotEmpty) {
          await localCache.saveToLocalCache(key: 'dayfi_id', value: fromUser);
          setState(() {
            _dayfiId = fromUser;
            _isLoadingDayfiId = false;
          });
        } else {
          setState(() => _isLoadingDayfiId = false);
        }
      }
    } catch (e) {
      AppLogger.error('Error loading Dayfi Tag: $e');
      final fromUser = await _readDayfiIdFromStoredUser();
      if (fromUser != null && fromUser.isNotEmpty) {
        setState(() {
          _dayfiId = fromUser;
          _isLoadingDayfiId = false;
        });
      } else {
        setState(() => _isLoadingDayfiId = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileViewModelProvider);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Column(
        children: [
          _buildProfileImageWithTier(profileState),
          const SizedBox(height: 12),
          _buildUserName(profileState),
          const SizedBox(height: 18),
          _buildEditProfileButton(profileState),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProfileImageWithTier(ProfileState profileState) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 32),
          child: Image(
            image: AssetImage('assets/icons/pngs/account.png'),
            height: _profileImageHeight,
          ),
        ),
        if (!profileState.isLoading) _buildTierBadge(profileState),
      ],
    );
  }

  Widget _buildTierBadge(ProfileState profileState) {
    final tierDisplayName = TierUtils.getTierDisplayName(profileState.user);
    final tierIconPath = TierUtils.getTierIconPath(profileState.user);
    final tierColor = TierUtils.getTierColor(profileState.user);

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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(_tierContainerBorderRadius),
        ),
        child: Row(
          children: [
            Image.asset(tierIconPath, height: _tierImageHeight),
            const SizedBox(width: 4),
            Text(
              tierDisplayName,
              style: AppTypography.labelMedium.copyWith(
                color: tierColorValue,
                fontSize: 16,
                fontFamily: AppTypography.secondaryFontFamily,
                fontWeight: AppTypography.regular,
                height: 1,
                letterSpacing: -0.7,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserName(ProfileState profileState) {
    return Text(
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
        fontSize: 24,
        fontWeight: FontWeight.w600,
        fontFamily: 'FunnelDisplay',
        height: 0.95,
        letterSpacing: -0.20,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildEditProfileButton(ProfileState profileState) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: PrimaryButton(
            borderRadius: _buttonBorderRadius,
            text: 'Edit Profile',
            onPressed:
                profileState.isLoading
                    ? null
                    : () => Navigator.pushNamed(context, AppRoute.editProfileView),
            backgroundColor: AppColors.purple500,
            height: _buttonHeight,
            textColor: AppColors.neutral0,
            fontFamily: 'Chirp',
            letterSpacing: -0.7,
            fontSize: 18,
            width: 375,
            fullWidth: true,
          ),
        ),
        // const SizedBox(height: 24),
        // if (_isLoadingDayfiId) ...[
        //   ShimmerWidgets.textShimmer(context, width: 200, height: 20),
        // ] else if (_dayfiId != null && _dayfiId!.isNotEmpty) ...[
        //   _buildDayfiTagSection(),
        // ] else ...[
        //   _buildCreateDayfiTagSection(),
        // ],
      ],
    );
  }

  BoxShadow _cardShadow() {
    return BoxShadow(
      color: const Color.fromARGB(255, 123, 36, 211).withOpacity(0.05),
      blurRadius: 2,
      offset: const Offset(0, 2),
      spreadRadius: 0.5,
    );
  }

  Widget _buildDayfiTagSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(_containerBorderRadius),
        boxShadow: [_cardShadow()],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                '@',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                _dayfiId!,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticHelper.lightImpact();
                  Clipboard.setData(ClipboardData(text: '@$_dayfiId'));
                  TopSnackbar.show(
                    context,
                    message: UsernameCopy.copiedToClipboard,
                  );
                },
                child: Row(
                  children: [
                    Text(
                      'copy',
                      style: TextStyle(
                        fontFamily: 'Chirp',
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    SvgPicture.asset(
                      'assets/icons/svgs/copy.svg',
                      color: Theme.of(context).colorScheme.primary,
                      height: 16,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () async {
                  HapticHelper.lightImpact();
                  try {
                    await Share.share(
                      UsernameCopy.shareInvite('@$_dayfiId'),
                      subject: UsernameCopy.myUsername,
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
                      'share',
                      style: TextStyle(
                        fontFamily: 'Chirp',
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    SvgPicture.asset(
                      'assets/icons/svgs/share.svg',
                      color: Theme.of(context).colorScheme.primary,
                      height: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCreateDayfiTagSection() {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () async {
        final result = await Navigator.pushNamed(
          context,
          AppRoute.dayfiTagExplanationView,
        );
        if (result != null && result is String && result.isNotEmpty) {
          final dayfiIdValue =
              result.startsWith('@') ? result.substring(1) : result;
          await localCache.saveToLocalCache(
            key: 'dayfi_id',
            value: dayfiIdValue,
          );
          setState(() {
            _dayfiId = dayfiIdValue;
            _isLoadingDayfiId = false;
          });
          _loadDayfiId();
        }
      },
      child: Text(
        UsernameCopy.create,
        style: TextStyle(
          fontFamily: 'Chirp',
          color: AppColors.purple500ForTheme(context),
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.20,
          height: 1.2,
        ),
      ),
    );
  }
}
