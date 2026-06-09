import 'package:dayfi/features/dayx/services/dayx_action_handler.dart';
import 'package:dayfi/features/dayx/widgets/dayx_orb_button.dart';
import 'package:dayfi/features/dayx/widgets/dayx_overlay.dart';
import 'package:dayfi/features/dayx/services/dayx_voice_hold_bridge.dart';
import 'package:dayfi/features/dayx/widgets/dayx_voice_overlay.dart';
import 'package:dayfi/features/home/views/home_view.dart';
import 'package:dayfi/features/home/vm/home_viewmodel.dart';
import 'package:dayfi/features/recipients/views/recipients_view.dart';
import 'package:dayfi/features/transactions/views/transactions_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/features/profile/views/profile_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/app_locator.dart';
import 'package:dayfi/services/local/secure_storage.dart';
import 'package:dayfi/common/constants/storage_keys.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:dayfi/services/notification_service.dart';
import 'package:dayfi/services/remote/auth_service.dart';
import 'package:dayfi/services/local/biometric_service.dart';
import 'package:dayfi/common/helpers/biometric_preferences.dart';
import 'dart:convert';

final mainViewKey = GlobalKey<_MainViewState>();

class MainView extends ConsumerStatefulWidget {
  final int initialTabIndex;
  final bool promptBiometricSetup;

  const MainView({
    super.key,
    this.initialTabIndex = 0,
    this.promptBiometricSetup = false,
  });

  @override
  ConsumerState<MainView> createState() => _MainViewState();
}

class _MainViewState extends ConsumerState<MainView> {
  late int _currentIndex;
  final SecureStorageService _secureStorage = locator<SecureStorageService>();

  final List<Widget> _screens = [
    const HomeView(),
    const TransactionsView(),
    const RecipientsView(),
    const ProfileView(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
    // Check if welcome has been shown and show it only once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowWelcome();
      if (widget.promptBiometricSetup) {
        _checkBiometricSetup();
      }
    });
  }

  void changeTab(int index) {
    if (mounted && index >= 0 && index < _screens.length) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  Future<void> _checkAndShowWelcome() async {
    try {
      final hasSeenWelcome = await _secureStorage.read(
        StorageKeys.hasSeenWelcome,
      );
      final hasReceivedWelcomeNotification = await _secureStorage.read(
        StorageKeys.hasReceivedWelcomeNotification,
      );

      // Only show welcome if user hasn't seen it before
      if (hasSeenWelcome.isEmpty || hasSeenWelcome != 'true') {
        await Future.delayed(const Duration(milliseconds: 500));

        // Trigger welcome notification if not already received
        if (hasReceivedWelcomeNotification.isEmpty ||
            hasReceivedWelcomeNotification != 'true') {
          await _triggerWelcomeNotification();
        }

        if (mounted) {
          _showWelcomeBottomSheet();
        }
      }
    } catch (e) {
      AppLogger.error('Error in _checkAndShowWelcome: $e');
      // Handle error silently
      // If there's an error, show welcome as fallback
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        _showWelcomeBottomSheet();
      }
    }
  }

  Future<void> _triggerWelcomeNotification() async {
    try {
      // Get user name from storage
      final userJson = await _secureStorage.read(StorageKeys.user);
      String userName = 'User';

      if (userJson.isNotEmpty) {
        try {
          final data = jsonDecode(userJson);
          if (data is Map<String, dynamic>) {
            final firstName = data['first_name'] ?? data['firstName'] ?? '';
            if (firstName.isNotEmpty) {
              userName = firstName;
            }
          }
        } catch (e) {
          AppLogger.error('Error parsing user data for notification: $e');
        }
      }

      // Initialize notification service and trigger welcome notification
      final notificationService = NotificationService();
      await notificationService.init();
      await notificationService.triggerSignUpSuccess(userName);

      // Mark notification as sent
      await _secureStorage.write(
        StorageKeys.hasReceivedWelcomeNotification,
        'true',
      );

      AppLogger.info('Welcome notification triggered for: $userName');
    } catch (e) {
      AppLogger.error('Error triggering welcome notification: $e');
    }
  }

  Future<void> _checkBiometricSetup() async {
    try {
      final bool isBiometricsSetup = await BiometricPreferences.isEnabled();
      final completed = await _secureStorage.read(
        StorageKeys.biometricSetupCompleted,
      );

      final bool deviceHasBiometrics =
          await BiometricService.isDeviceBiometricCapable();

      if (deviceHasBiometrics && !isBiometricsSetup && completed != 'true') {
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          _showBiometricReminder();
        }
      }
    } catch (e) {
      // Handle error silently
      AppLogger.error('Error checking biometric setup: $e');
    }
  }

  void _showBiometricReminder() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Biometric icon
                // Container(
                //   width: 80,
                //   height: 80,
                //   decoration: BoxDecoration(
                //     gradient: LinearGradient(
                //       begin: Alignment.topLeft,
                //       end: Alignment.bottomRight,
                //       colors: [AppColors.purple400, AppColors.orange500],
                //     ),
                //     shape: BoxShape.circle,
                //     boxShadow: [
                //       BoxShadow(
                //         color: AppColors.purple500ForTheme(
                //           context,
                //         ).withOpacity(0.15),
                //         blurRadius: 20,
                //         spreadRadius: 2,
                //         offset: const Offset(0, 4),
                //       ),
                //     ],
                //   ),
                //   child: Padding(
                //     padding: const EdgeInsets.all(10.0),
                //     child: SvgPicture.asset(
                //       "assets/icons/svgs/security-safe.svg",
                //       color: Colors.white,
                //       height: 24,
                //     ),
                //   ),
                // ),

                // SizedBox(height: 24),

                // Title
                // Text(
                //   'Enable Biometric Security',
                //   style: AppTypography.titleLarge.copyWith(
                //     fontFamily: 'FunnelDisplay',
                //     fontSize: 18,
                //     // // height: 1.6,
                //     fontWeight: FontWeight.w600,
                //     color: Theme.of(context).colorScheme.onSurface,
                //   ),
                //   textAlign: TextAlign.center,
                // ),

                // SizedBox(height: 16),

                // Description
                Text(
                  'Add an extra layer of security to your account with biometric authentication.',
                  style: AppTypography.bodyMedium.copyWith(
                    fontFamily: 'Chirp',
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -.25,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.9),
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 32),

                // Enable button
                PrimaryButton(
                  text: 'Enable Biometrics',
                  onPressed: () {
                    Navigator.of(context).pop();
                    appRouter.pushNamed(AppRoute.biometricSetupView);
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
                  letterSpacing: -0.3,
                ),
                SizedBox(height: 8),

                // Skip button
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await BiometricPreferences.markPromptDismissed();
                    await _updateBiometricStatus(false);
                  },
                  child: Text(
                    'Skip for now',
                    style: AppTypography.bodyMedium.copyWith(
                      fontFamily: 'Chirp',
                      fontSize: 16,
                      letterSpacing: -0.3,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateBiometricStatus(bool isEnabled) async {
    try {
      final authService = locator<AuthService>();

      // Call the backend API
      await authService.updateBiometrics(isBiometricsSetup: isEnabled);
      await BiometricPreferences.setEnabled(isEnabled);

      AppLogger.info('Biometric status updated: $isEnabled');
    } catch (e) {
      AppLogger.error('Error updating biometric status: $e');
    }
  }

  void _openDayX() {
    DayxOverlay.show(
      context,
      onChangeTab: changeTab,
      onNavigate: (target) {
        DayxNavigation.handle(
          context: context,
          target: target,
          changeTab: changeTab,
        );
      },
    );
  }

  void _openDayXVoice({required bool fromNavHold}) {
    DayxVoiceHoldBridge.onHoldReleased =
        fromNavHold ? DayxVoiceOverlay.requestFinalizeListening : null;
    DayxVoiceOverlay.show(
      context,
      fromNavHold: fromNavHold,
      onChangeTab: changeTab,
      onNavigate: (target) {
        DayxNavigation.handle(
          context: context,
          target: target,
          changeTab: changeTab,
        );
      },
    ).whenComplete(DayxVoiceHoldBridge.clear);
  }

  void _onDayXHoldStart() {
    _openDayXVoice(fromNavHold: true);
  }

  void _onDayXHoldEnd() {
    DayxVoiceHoldBridge.notifyHoldReleased();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Disable device back button
      onPopInvoked: (didPop) {
        // Optional: Show a dialog or snackbar to inform user
        // For now, we'll just prevent the back action silently
      },
      child: Scaffold(
        extendBody: true, // 👈 makes nav bar float over body
        // IndexedStack (not AnimatedSwitcher) so off-stage tabs still receive
        // stable layout constraints. AnimatedSwitcher was leaving Transactions /
        // Recipients with a blank body until a hot reload repainted the sliver tree.
        body: IndexedStack(index: _currentIndex, children: _screens),
        bottomNavigationBar: Container(
          padding: EdgeInsets.fromLTRB(8, 4, 8, 4), // float up a bit
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            // borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _buildNavItem(
                    index: 0,
                    icon: "assets/icons/svgs/swap.svg",
                    isSelected: _currentIndex == 0,
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    index: 1,
                    icon: "assets/icons/svgs/transactions.svg",
                    isSelected: _currentIndex == 1,
                  ),
                ),
                
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 12),
                  width: 56,
                  child: Transform.translate(
                    offset: const Offset(0, -14),
                    child: DayxOrbButton(
                      onTap: _openDayX,
                      onHoldStart: _onDayXHoldStart,
                      onHoldEnd: _onDayXHoldEnd,
                    ),
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    index: 2,
                    icon: "assets/icons/svgs/recipients.svg",
                    isSelected: _currentIndex == 2,
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    index: 3,
                    icon: "assets/icons/pngs/account.png",
                    isSelected: _currentIndex == 3,
                    isPNG: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String icon,
    required bool isSelected,
    bool isPNG = false,
  }) {
    return GestureDetector(
      onTap: () {
        if (index != _currentIndex) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 0) {
            ref
                .read(homeViewModelProvider.notifier)
                .fetchWalletDetails(forceRefresh: true);
          }
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        height: 80,
        padding: EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(50)),
        child: Opacity(
          opacity: isSelected ? 1 : 0.25,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              isPNG
                  ? Image.asset(icon, height: 40)
                  : SvgPicture.asset(
                    icon,
                    height: 40,
                    // color: index == 1 ? Color(0xFF5F2EA1) : null,
                  ),
              SizedBox(height: 4),
              Text(
                _labelForIndex(index),
                style: AppTypography.bodySmall.copyWith(
                  fontFamily: 'Chirp',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _labelForIndex(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'History';
      case 2:
        return 'People';
      case 3:
        return 'More';
      default:
        return '';
    }
  }

  void _showWelcomeBottomSheet() {
    showModalBottomSheet(
      barrierColor: Colors.black.withOpacity(0.85),
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildWelcomeBottomSheet(),
    );
  }

  Future<void> _dismissWelcomeBottomSheet(BuildContext context) async {
    // Mark welcome as seen
    await _secureStorage.write(StorageKeys.hasSeenWelcome, 'true');

    // Close the bottom sheet
    Navigator.of(context).pop();
  }

  Widget _buildWelcomeBottomSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () => _dismissWelcomeBottomSheet(context),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/svgs/notificationn.svg',
                              height: 40,
                              color: Theme.of(context).colorScheme.surface,
                            ),
                            SizedBox(
                              height: 40,
                              width: 40,
                              child: Center(
                                child: Image.asset(
                                  'assets/icons/pngs/cancelicon.png',
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
                  const SizedBox(height: 16),
                  Text(
                    'Welcome to Dayfi',
                    style: AppTypography.headlineLarge.copyWith(
                      fontSize: 24,
                      fontFamily: 'FunnelDisplay',
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Everything you need to move, grow, and manage your money — in one place.',
                    style: AppTypography.bodyMedium.copyWith(
                      fontFamily: 'Chirp',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -.25,
                      height: 1.35,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.color!.withOpacity(.75),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  _buildFeatureItem(
                    icon: _buildHomeTabIcon(),
                    title: 'Home',
                    description:
                        'Your balance, wallets, and recent activity — plus quick actions to send, add, swap, and pay bills.',
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    icon: _buildTransactionsTabIcon(),
                    title: 'History',
                    description:
                        'Search and review every deposit, send, swap, bill payment, and investment.',
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    icon: _buildRecipientsTabIcon(),
                    title: 'Recipients',
                    description:
                        'Saved beneficiaries and Dayfi tags — send again in one tap.',
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    icon: _buildMoreIcon(),
                    title: 'More',
                    description:
                        'Profile, account limits, security, support, and settings.',
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(48, 8, 48, 32),
            child: PrimaryButton(
              text: 'Get started',
              onPressed: () => _dismissWelcomeBottomSheet(context),
              backgroundColor: AppColors.purple500,
              textColor: AppColors.neutral0,
              borderRadius: 40,
              height: 48,
              width: double.infinity,
              fullWidth: true,
              fontFamily: 'Chirp',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required Widget icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon
        Center(child: icon),
        SizedBox(width: 16),

        // Text content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontFamily: 'Chirp',
                  fontSize: 18,
                  letterSpacing: -.25,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),

              SizedBox(height: 4),

              Text(
                description,
                style: AppTypography.bodyMedium.copyWith(
                  fontFamily: 'Chirp',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -.25,
                  height: 1.450,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyLarge!.color!.withOpacity(.75),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHomeTabIcon() {
    return SvgPicture.asset('assets/icons/svgs/swap.svg', height: 36);
  }

  Widget _buildTransactionsTabIcon() {
    return SvgPicture.asset('assets/icons/svgs/transactions.svg', height: 36);
  }

  Widget _buildRecipientsTabIcon() {
    return SvgPicture.asset('assets/icons/svgs/recipients.svg', height: 36);
  }

  Widget _buildMoreIcon() {
    return Image.asset('assets/icons/pngs/account.png', height: 36);
  }

  Widget _buildQuickActionIcon(String assetPath) {
    return SvgPicture.asset(assetPath, height: 32);
  }
}
