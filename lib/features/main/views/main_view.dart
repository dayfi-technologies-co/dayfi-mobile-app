import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dayfi/features/send/views/send_view.dart';
import 'package:dayfi/features/transactions/views/transactions_view.dart';
import 'package:dayfi/features/recipients/views/recipients_view.dart';
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

class MainView extends ConsumerStatefulWidget {
  const MainView({super.key});

  @override
  ConsumerState<MainView> createState() => _MainViewState();
}

class _MainViewState extends ConsumerState<MainView> {
  int _currentIndex = 0;
  final SecureStorageService _secureStorage = locator<SecureStorageService>();

  final List<Widget> _screens = [
    const SendView(),
    const TransactionsView(),
    const RecipientsView(),
    const ProfileView(),
  ];

  @override
  void initState() {
    super.initState();
    // Check if welcome has been shown and show it only once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowWelcome();
      _checkBiometricSetup();
    });
  }

  Future<void> _checkAndShowWelcome() async {
    try {
      final hasSeenWelcome = await _secureStorage.read(
        StorageKeys.hasSeenWelcome,
      );

      // Only show welcome if user hasn't seen it before
      if (hasSeenWelcome.isEmpty || hasSeenWelcome != 'true') {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          _showWelcomeBottomSheet();
        }
      }
    } catch (e) {
      // Handle error silently
      // If there's an error, show welcome as fallback
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        _showWelcomeBottomSheet();
      }
    }
  }

  Future<void> _checkBiometricSetup() async {
    try {
      // Check if biometric setup has been completed
      final biometricSetupCompleted = await _secureStorage.read(StorageKeys.biometricSetupCompleted);
      
      // If biometric setup is not completed, show a reminder after a delay
      if (biometricSetupCompleted != 'true') {
        await Future.delayed(const Duration(seconds: 2)); // Wait a bit after app loads
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
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Container(
            padding: EdgeInsets.all(28.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Biometric icon
                Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.purple400, AppColors.purple600],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.purple500.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.security,
                    color: Colors.white,
                    size: 40.w,
                  ),
                ),

                SizedBox(height: 24.h),

                // Title
                Text(
                  'Enable Biometric Security',
                  style: AppTypography.titleLarge.copyWith(
                    fontFamily: 'CabinetGrotesk',
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 16.h),

                // Description
                Text(
                  'Add an extra layer of security to your account with biometric authentication. You can enable this later in settings if you prefer.',
                  style: AppTypography.bodyMedium.copyWith(
                    fontFamily: 'Karla',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 24.h),

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
                  height: 60.h,
                  width: double.infinity,
                  fullWidth: true,
                  fontFamily: 'Karla',
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.8,
                ),
                SizedBox(height: 12.h),

                // Skip button
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Mark as completed so we don't show this again
                    _secureStorage.write(StorageKeys.biometricSetupCompleted, 'true');
                    _secureStorage.write('biometric_enabled', 'false');
                  },
                  child: Text(
                    'Skip for now',
                    style: AppTypography.bodyMedium.copyWith(
                      fontFamily: 'Karla',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.neutral500,
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
        body: IndexedStack(index: _currentIndex, children: _screens),
        bottomNavigationBar: Container(
          margin: EdgeInsets.fromLTRB(48.w, 0, 48.w, 36.h), // float up a bit
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(100.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: "assets/icons/svgs/swap.svg",
                  isSelected: _currentIndex == 0,
                ),
                _buildNavItem(
                  index: 1,
                  icon: "assets/icons/svgs/transactions.svg",
                  isSelected: _currentIndex == 1,
                ),
                _buildNavItem(
                  index: 2,
                  icon: "assets/icons/svgs/recipients.svg",
                  isSelected: _currentIndex == 2,
                ),
                _buildNavItem(
                  index: 3,
                  icon: "assets/icons/pngs/account.png",
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
        setState(() {
          _currentIndex = index;
          // _showWelcomeBottomSheet();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          // color: isSelected ? AppColors.purple500 : Colors.transparent,
          borderRadius: BorderRadius.circular(50.r),
        ),
        child: Opacity(
          opacity: isSelected ? 1 : 0.25,
          child:
              isPNG
                  ? Image.asset(icon, height: 40.sp)
                  : SvgPicture.asset(icon, height: 40.sp),
        ),
      ),
    );
  }

  void _showWelcomeBottomSheet() {
    showModalBottomSheet(
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
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 40.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => _dismissWelcomeBottomSheet(context),
                  child: Icon(
                    Icons.close,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 28.w,
                  ),
                ),
              ],
            ),

            SizedBox(height: 40.h),

            // Title
            Text(
              'Welcome to Dayfi App',
              style: AppTypography.headlineLarge.copyWith(
                fontFamily: 'CabinetGrotesk',
                fontSize: 28.sp,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 40.h),

            // Features list
            _buildFeatureItem(
              icon: _buildSendMoneyIcon(),
              title: 'Send Money',
              description:
                  'Transfer funds across borders using any of the available payment methods on the app.',
            ),

            SizedBox(height: 24.h),

            _buildFeatureItem(
              icon: _buildTransactionsIcon(),
              title: 'Transactions',
              description:
                  'Check the details and status of all your payments in one dashboard.',
            ),

            SizedBox(height: 24.h),

            _buildFeatureItem(
              icon: _buildRecipientsIcon(),
              title: 'Recipients',
              description:
                  'Add and/or edit the information of people who receive money from you.',
            ),

            SizedBox(height: 24.h),

            _buildFeatureItem(
              icon: _buildProfileIcon(),
              title: 'Profile',
              description:
                  'Find your personal details provided during sign up. Easily update your info anytime.',
            ),

            SizedBox(height: MediaQuery.of(context).size.width * .46),

            // Okay button
            PrimaryButton(
              text: 'Okay',
              onPressed: () => _dismissWelcomeBottomSheet(context),
              backgroundColor: AppColors.purple500,
              textColor: AppColors.neutral0,
              borderRadius: 40.r,
              height: 60.h,
              width: double.infinity,
              fullWidth: true,
              fontFamily: 'Karla',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
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

        SizedBox(width: 16.w),

        // Text content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text(
                title,
                style: AppTypography.headlineSmall.copyWith(
                  fontFamily: 'CabinetGrotesk',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.3,
                ),
              ),

              SizedBox(height: 4.h),

              Text(
                description,
                style: AppTypography.bodyMedium.copyWith(
                  fontFamily: 'Karla',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -.6,
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

  Widget _buildSendMoneyIcon() {
    return SvgPicture.asset("assets/icons/svgs/swap.svg", height: 40.h);
  }

  Widget _buildTransactionsIcon() {
    return SvgPicture.asset("assets/icons/svgs/transactions.svg", height: 40.h);
  }

  Widget _buildRecipientsIcon() {
    return SvgPicture.asset("assets/icons/svgs/recipients.svg", height: 40.h);
  }

  Widget _buildProfileIcon() {
    return Image.asset("assets/icons/pngs/account.png", height: 40.h);
  }
}
