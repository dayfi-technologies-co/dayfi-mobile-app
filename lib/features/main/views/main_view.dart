import 'package:dayfi/features/home/views/home_view.dart';
import 'package:dayfi/features/send/views/select_destination_country_view.dart';
import 'package:dayfi/features/invest/views/invest_view.dart';
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
import 'dart:convert';

final mainViewKey = GlobalKey<_MainViewState>();

class MainView extends ConsumerStatefulWidget {
  final int initialTabIndex;

  const MainView({super.key, this.initialTabIndex = 0});

  @override
  ConsumerState<MainView> createState() => _MainViewState();
}

class _MainViewState extends ConsumerState<MainView> {
  late int _currentIndex;
  final SecureStorageService _secureStorage = locator<SecureStorageService>();

  // Tab order: Home (0) | Send (1) | Invest (2) | More (3)
  final List<Widget> _screens = [
    const HomeView(),
    const SelectDestinationCountryView(hasBackButton: false),
    const InvestView(),
    const ProfileView(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
    // Check if welcome has been shown and show it only once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowWelcome();
      _checkBiometricSetup();
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
      final userJson = await _secureStorage.read(StorageKeys.user);
      bool isBiometricsSetup = false;
      if (userJson.isNotEmpty) {
        try {
          final data = jsonDecode(userJson);
          if (data is Map<String, dynamic>) {
            isBiometricsSetup = (data['is_biometrics_setup'] as bool?) ?? false;
          }
        } catch (_) {}
      }

      // Only show the biometric reminder if the device supports biometrics
      // and the user has NOT enabled biometrics for this app.
      final bool deviceHasBiometrics =
          await BiometricService.isBiometricAvailable();

      if (deviceHasBiometrics && !isBiometricsSetup) {
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

      // Update local storage
      final userJson = await _secureStorage.read(StorageKeys.user);
      if (userJson.isNotEmpty) {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        userMap['is_biometrics_setup'] = isEnabled;
        await _secureStorage.write(StorageKeys.user, json.encode(userMap));
      }

      AppLogger.info('Biometric status updated: $isEnabled');
    } catch (e) {
      AppLogger.error('Error updating biometric status: $e');
    }
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
          padding: EdgeInsets.fromLTRB(24, 4, 24, 4), // float up a bit
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
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: "assets/icons/svgs/home-2.svg",
                  isSelected: _currentIndex == 0,
                ),
                _buildNavItem(
                  index: 1,
                  icon: "assets/icons/svgs/brand-telegram.svg",
                  isSelected: _currentIndex == 1,
                ),
                _buildNavItem(
                  index: 2,
                  icon: "assets/icons/svgs/clock-dollar.svg",
                  isSelected: _currentIndex == 2,
                ),
                _buildNavItem(
                  index: 3,
                  icon: "assets/icons/svgs/user-square-rounded.svg",
                  isSelected: _currentIndex == 3,
                  isPNG: true,
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
            // _showWelcomeBottomSheet();
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        height: 72,
        padding: EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(50)),
        child: Opacity(
          opacity: isSelected ? 1 : 0.25,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(icon, height: 28,        color: Theme.of(context).colorScheme.onSurface,),
              SizedBox(height: 2),
              Text(
                _labelForIndex(index),
                style: AppTypography.bodySmall.copyWith(
                  fontFamily: 'Chirp',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
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
        return 'Send';
      case 2:
        return 'Invest';
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
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(18, 18, 18, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () => _dismissWelcomeBottomSheet(context),
                  child: Stack(
                    alignment: AlignmentGeometry.center,
                    children: [
                      SvgPicture.asset(
                        "assets/icons/svgs/notificationn.svg",
                        height: 40,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      SizedBox(
                        height: 40,
                        width: 40,
                        child: Center(
                          child: Image.asset(
                            "assets/icons/pngs/cancelicon.png",
                            height: 20,
                            width: 20,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 32),

            // Title
            Text(
              'Welcome to Dayfi App',
              style: AppTypography.headlineLarge.copyWith(
                fontSize: 18,
                fontFamily: 'FunnelDisplay',
                // letterSpacing: -.5,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
                // height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 32),

            // Features list
            _buildFeatureItem(
              icon: _buildHomeIcon(),
              title: 'Home',
              description:
                  'Top up your wallet, check your balance, and send globally.',
            ),

            SizedBox(height: 20),

            _buildFeatureItem(
              icon: _buildSendIcon(),
              title: 'Send',
              description:
                  'Transfer money to anyone, anywhere — fast and secure.',
            ),

            SizedBox(height: 20),

            _buildFeatureItem(
              icon: _buildInvestIcon(),
              title: 'Invest',
              description:
                  'Grow your money with crypto and savings — coming soon.',
            ),

            SizedBox(height: 20),

            _buildFeatureItem(
              icon: _buildMoreIcon(),
              title: 'More',
              description:
                  'Profile, transactions, recipients, and account settings.',
            ),

            // SizedBox(height: MediaQuery.of(context).size.width * .46),
            Spacer(),

            // Okay button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: PrimaryButton(
                text: 'Okay',
                onPressed: () => _dismissWelcomeBottomSheet(context),
                backgroundColor: AppColors.purple500,
                textColor: AppColors.neutral0,
                borderRadius: 40,
                height: 48.00000,
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

  Widget _buildHomeIcon() {
    return SvgPicture.asset("assets/icons/svgs/home.svg", height: 36);
  }

  Widget _buildSendIcon() {
    return SvgPicture.asset("assets/icons/svgs/swap.svg", height: 36);
  }

  Widget _buildInvestIcon() {
    return SvgPicture.asset("assets/icons/svgs/cryptoo.svg", height: 36);
  }

  Widget _buildMoreIcon() {
    return Image.asset("assets/icons/pngs/account.png", height: 36);
  }
}
