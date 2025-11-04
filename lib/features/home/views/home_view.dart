import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/utils/tier_utils.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/main/views/main_view.dart';
import 'package:dayfi/features/notifications/views/notifications_view.dart';
import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';
import 'package:dayfi/features/send/views/send_payment_method_view.dart';
import 'package:dayfi/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: const SizedBox.shrink(),
        leadingWidth: 0,
        title: Text(
          "Home",
          style: AppTypography.titleLarge.copyWith(
            fontFamily: 'CabinetGrotesk',
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 18.w),
            child: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationsView()),
                );
              },
              child: SvgPicture.asset(
                "assets/icons/svgs/notificationn.svg",
                height: 32.sp,
              ),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.0.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transfer Limit Card
            _buildUpgradeCard(),
            SizedBox(height: 16.h),
            Container(
              width: MediaQuery.of(context).size.width,
              // height: 150,
              // margin: EdgeInsets.only(top: 8, right: 8, left: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Your universal wallet balance",
                      style: TextStyle(
                        fontFamily: 'Karla',
                        fontSize: 12.5,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(.6),
                        fontWeight: FontWeight.w500,
                        letterSpacing: -.08,
                        height: 1.450,
                      ),
                    ),
                    const SizedBox(height: 4),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "₦",
                          style: TextStyle(
                            // fontFamily: '',
                            fontSize: 24.sp,
                            fontFamily: 'CabinetGrotesk',
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                            // color: Color(0xff2A0079),
                            // height: ,
                            letterSpacing: 0,
                          ),
                        ),

                        Text(
                          "0.00",
                          style: TextStyle(
                            // fontFamily: '',
                            fontSize: 36.sp,
                            fontFamily: 'CabinetGrotesk',
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                            // color: Color(0xff2A0079),
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 18.h),

            _buildHomeActionButtons(context),

            SizedBox(height: 112.h),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeCard() {
    final profileState = ref.watch(profileViewModelProvider);
    final user = profileState.user;

    // Only show upgrade card if user can upgrade
    if (!TierUtils.canUpgrade(user)) {
      return const SizedBox.shrink();
    }

    final tierDescription = TierUtils.getTierDescription(user);
    final nextTierInfo = TierUtils.getNextTierInfo(user);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        // border: Border.all(color: AppColors.warning400.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral500.withOpacity(0.05),
            blurRadius: 4.0,
            offset: const Offset(0, 4),
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset("assets/icons/pngs/account_4.png", height: 40.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Increase transfer limit',
                  style: AppTypography.titleMedium.copyWith(
                    fontFamily: 'CabinetGrotesk',
                    fontSize: 19.00,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                RichText(
                  text: TextSpan(
                    text: tierDescription,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Karla',
                      letterSpacing: -.3,
                      height: 1.2,
                    ),
                    children: [
                      TextSpan(
                        text: ' $nextTierInfo.',
                        style: TextStyle(
                          color: Color(0xFF2787A1),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Karla',
                          letterSpacing: -.4,
                          height: 1.2,
                          // decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtonWidget(
    BuildContext context,
    String label,
    String iconAsset,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56.h,
        // width: double.infinity,
        // width: MediaQuery.of(context).size.width * .4165,
        decoration: BoxDecoration(
          color: AppColors.purple500,
          boxShadow: [
            BoxShadow(
              blurRadius: 0,
              spreadRadius: 0,
              color: AppColors.purple200,
              offset:
                  label == "Fund"
                      ? const Offset(-1.5, 2.5)
                      : const Offset(1.5, 2.5),
            ),
          ],
          borderRadius: BorderRadius.circular(48.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(label == "Swap" ? 0 : 0.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // _buildRotatedIcon(label, iconAsset),
              const SizedBox(width: 12),
              Text(
                label,
                textAlign: TextAlign.center, // center the text since stretched
                style: TextStyle(
                  // fontSize: 18.sp,
                  fontWeight: AppTypography.medium,
                  // letterSpacing: 0.00,
                  height: 1.450,
                  // fontFamily: "Karla",
                  color: Colors.white,

                  // color: _HomeViewConstants.primaryColor,
                  fontFamily: 'Karla',
                  letterSpacing: -.8,
                  fontSize: 18,
                  // width: double.infinity,
                  // fullWidth: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Fund
        Expanded(
          child: _buildActionButtonWidget(
            context,
            'Fund',
            'assets/svgs/arrow-narrow-down.svg',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => SendPaymentMethodView(
                        selectedData: {},
                        recipientData: {},
                        senderData: {},
                        paymentData: {},
                      ),
                ),
              );
            },
          ),
        ),

        const SizedBox(width: 12),

        // Send
        Expanded(
          child: _buildActionButtonWidget(
            context,
            'Send',
            'assets/svgs/swap.svg',
            () {
              if (mainViewKey.currentState != null) {
                mainViewKey.currentState!.changeTab(1);
              } else {
                appRouter.pushNamed(AppRoute.mainView, arguments: 1);
              }
            },
          ),
        ),
      ],
    );
  }
}
