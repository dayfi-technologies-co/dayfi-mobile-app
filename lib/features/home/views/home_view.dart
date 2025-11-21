import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/utils/tier_utils.dart';
import 'package:dayfi/common/utils/haptic_helper.dart';
import 'package:dayfi/common/widgets/empty_state_widget.dart';
import 'package:dayfi/common/widgets/shimmer_widgets.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/notifications/views/notifications_view.dart';
import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';
import 'package:dayfi/features/home/vm/home_viewmodel.dart';
import 'package:dayfi/features/transactions/vm/transactions_viewmodel.dart';
import 'package:dayfi/models/wallet_transaction.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/services/remote/wallet_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intercom_flutter/intercom_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView>
    with WidgetsBindingObserver {
  String? _dayfiId;
  bool _isLoadingDayfiId = true;
  bool _isBalanceVisible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize wallet data when view loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeViewModelProvider.notifier).initialize();
      ref
          .read(transactionsProvider.notifier)
          .loadTransactions(isInitialLoad: true);
      _loadDayfiId();
    });
  }

  void _toggleBalanceVisibility() {
    setState(() {
      _isBalanceVisible = !_isBalanceVisible;
    });
  }

  Future<void> _loadDayfiId() async {
    // Load cached DayFi ID from storage first
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

      // Find the first wallet with a non-empty Dayfi ID
      if (walletResponse.wallets.isNotEmpty) {
        final walletWithDayfiId = walletResponse.wallets.firstWhere(
          (wallet) => wallet.dayfiId.isNotEmpty && wallet.dayfiId != 'null',
          orElse: () => walletResponse.wallets.first,
        );

        if (walletWithDayfiId.dayfiId.isNotEmpty &&
            walletWithDayfiId.dayfiId != 'null') {
          // Cache the DayFi ID for next time
          await localCache.saveToLocalCache(
            key: 'dayfi_id',
            value: walletWithDayfiId.dayfiId,
          );

          setState(() {
            _dayfiId = walletWithDayfiId.dayfiId;
            _isLoadingDayfiId = false;
          });
        } else {
          // No valid DayFi ID found, clear any cached value
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
      setState(() {
        _isLoadingDayfiId = false;
      });
      // Don't show error to user, just don't display Dayfi ID
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leadingWidth: 0,
        leading: const SizedBox.shrink(),
        title: Row(
          children: [
            Image.asset("assets/icons/pngs/account_4.png", height: 40.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final profileState = ref.watch(profileViewModelProvider);
                  final userName = profileState.userName;
                  final firstName = userName.split(' ').first;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, $firstName',
                        style: AppTypography.titleMedium.copyWith(
                          fontFamily: 'CabinetGrotesk',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),

        // leadingWidth: 0,
        centerTitle: false,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: _navigateToContactUs,
              child: Stack(
                alignment: AlignmentGeometry.center,
                children: [
                  SvgPicture.asset(
                    "assets/icons/svgs/notificationn.svg",
                    height: 40.sp,
                    color: AppColors.neutral700.withOpacity(.35),
                  ),
                  Center(
                    child: SvgPicture.asset(
                      "assets/icons/svgs/support.svg",
                      height: 28,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(.65),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
              child: Stack(
                alignment: AlignmentGeometry.center,
                children: [
                  SvgPicture.asset(
                    "assets/icons/svgs/notificationn.svg",
                    height: 40.sp,
                    color: AppColors.neutral700.withOpacity(.35),
                  ),
                  Center(
                    child: SvgPicture.asset(
                      "assets/icons/svgs/bell.svg",
                      height: 28,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(.65),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Haptic feedback for pull-to-refresh
          HapticHelper.lightImpact();

          // Dismiss keyboard when refreshing
          FocusScope.of(context).unfocus();

          // Refresh wallet data and transactions
          try {
            await ref
                .read(homeViewModelProvider.notifier)
                .refreshWalletDetails();
            await ref.read(transactionsProvider.notifier).loadTransactions();

            // Success haptic
            HapticHelper.success();
          } catch (e) {
            // Error haptic
            HapticHelper.error();
            // Log error but don't crash the app
            print('Error refreshing HomeView: $e');
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.0.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transfer Limit Card
              // _buildUpgradeCard(),
              // SizedBox(height: 16.h),
              _buildWalletBalanceCard(),
              SizedBox(height: 12.h),
              _buildHomeActionButtons(context),
              // SizedBox(height: 12.h),
              // Padding(
              //   padding: EdgeInsets.symmetric(
              //     horizontal: MediaQuery.of(context).size.width * .2,
              //   ),
              //   child: PrimaryButton(
              //     borderRadius: 38.r,
              //     text: "Add Money",
              //     onPressed: () async {
              //       try {
              //         await Navigator.pushNamed(
              //           context,
              //           AppRoute.sendPaymentMethodView,
              //           arguments: <String, dynamic>{
              //             'selectedData': <String, dynamic>{},
              //             'recipientData': <String, dynamic>{},
              //             'senderData': <String, dynamic>{},
              //             'paymentData': <String, dynamic>{},
              //           },
              //         );
              //       } catch (e) {
              //         // Handle navigation error silently or show a message
              //         debugPrint('Navigation error: $e');
              //       }
              //     },
              //     backgroundColor: AppColors.purple500,
              //     height: 48.000.h,
              //     textColor: AppColors.neutral0,
              //     fontFamily: 'Karla',
              //     letterSpacing: -.8,
              //     fontSize: 18,
              //     width: 375.w,
              //     fullWidth: true,
              //   ),
              // ), //
              SizedBox(height: 28.h),
              _buildRecentTransactions(),
              SizedBox(height: 112.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletBalanceCard() {
    final homeState = ref.watch(homeViewModelProvider);
    final isLoading = homeState.isLoading;
    final balance = homeState.balance;
    final hasBalance = balance != '0.00' && balance.isNotEmpty;

    return AspectRatio(
      aspectRatio: 15 / 6.9,
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          // border: Border.all(color: AppColors.neutral200),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.neutral500.withOpacity(0.05),
              blurRadius: 2.0,
              offset: const Offset(0, 2),
              spreadRadius: 0.25,
            ),
          ],
          // border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.asset(
                'assets/icons/pngs/backgroud.png',
                fit: BoxFit.cover,
                // color: Colors.orangeAccent.shade200,
                width: MediaQuery.of(context).size.width,
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(12, 24, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 3,
                                horizontal: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    homeState.currency,
                                    style: const TextStyle(
                                      fontFamily: 'Karla',
                                      fontSize: 12,
                                      color: Color(0xff2A0079),
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -.04,
                                      height: 1.450,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  SvgPicture.asset(
                                    _getFlagPath(
                                      _getCountryCodeFromCurrency(
                                        homeState.currency,
                                      ),
                                    ),
                                    height: 18.0.h,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "  Local wallet",
                                style: TextStyle(
                                  fontFamily: 'Karla',
                                  fontSize: 12,
                                  color: AppColors.purple500ForTheme(
                                    context,
                                  ), // innit
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -.04,
                                  overflow: TextOverflow.ellipsis,
                                  height: 1.450,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // InkWell(
                      //   splashColor: Colors.transparent,
                      //   highlightColor: Colors.transparent,
                      //   onTap: _toggleBalanceVisibility,
                      //   child: Stack(
                      //     alignment: AlignmentGeometry.center,
                      //     children: [
                      //       SvgPicture.asset(
                      //         "assets/icons/svgs/notificationn.svg",
                      //         height: 32.sp,
                      //         color: AppColors.neutral700.withOpacity(.35),
                      //       ),
                      //       Center(
                      //         child: SvgPicture.asset(
                      //           _isBalanceVisible
                      //               ? "assets/icons/svgs/eye.svg"
                      //               : "assets/icons/svgs/eye-closed.svg",
                      //           height: 28,
                      //           color: Theme.of(
                      //             context,
                      //           ).colorScheme.onSurface.withOpacity(.65),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Your balance ".toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Karla',
                          fontSize: 12,
                          color: AppColors.neutral700,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -.04,
                          height: 1.450,
                        ),
                      ),
                      if (isLoading && !hasBalance)
                        LoadingAnimationWidget.horizontalRotatingDots(
                          color: AppColors.primary600,
                          size: 20,
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _isBalanceVisible
                                    ? _formatNumber(
                                      double.tryParse(
                                            balance.replaceAll(
                                              RegExp(r'[^\d.]'),
                                              '',
                                            ),
                                          ) ??
                                          0.0,
                                    )
                                    : '*****',
                                style: TextStyle(
                                  fontSize: 38.sp,
                                  height: 1.2,
                                  fontFamily: 'CabinetGrotesk',
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(1),
                                  letterSpacing: -.6,
                                ),
                              ),
                            ),
                            Image.asset(
                              'assets/icons/pngs/logoo.png',
                              height: 28,
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
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
                    fontSize: 15.20,
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
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(
                        text: ' $nextTierInfo.',
                        style: TextStyle(
                          color: Color(0xFF2787A1),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
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
        height: 50.h,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              blurRadius: 0,
              spreadRadius: 0,
              color: Theme.of(context).colorScheme.onSecondary,
              offset: Offset(label == "Topup Wallet" ? -1 : 1, 2),
            ),
          ],
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(.25),
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(48.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 32.w,
              height: 32.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  // label == "Topup Wallet"
                  //     ? SvgPicture.asset(
                  //       iconAsset,
                  //       height: 32.sp,
                  //       color: Color(0xFFFFD800),
                  //     )
                  //     : const SizedBox.shrink(),
                  // // Foreground icon
                  Center(
                    child: SvgPicture.asset(
                      iconAsset,
                      // height: 18.sp,
                      color: label == 'Topup Wallet' ? Color(0xffEA4857) : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: AppTypography.medium,
                height: 1.5,
                fontFamily: 'Karla',
                letterSpacing: -.8,
                fontSize: 18,
              ),
            ),
          ],
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
            'Topup Wallet',
            'assets/icons/svgs/topup.svg',
            () async {
              try {
                await Navigator.pushNamed(
                  context,
                  AppRoute.sendPaymentMethodView,
                  arguments: <String, dynamic>{
                    'selectedData': <String, dynamic>{},
                    'recipientData': <String, dynamic>{},
                    'senderData': <String, dynamic>{},
                    'paymentData': <String, dynamic>{},
                  },
                );
              } catch (e) {
                // Handle navigation error silently or show a message
                debugPrint('Navigation error: $e');
              }
            },
          ),
        ),

        const SizedBox(width: 8),

        // Send
        Expanded(
          child: _buildActionButtonWidget(
            context,
            'Send Money',
            'assets/icons/svgs/swap.svg',
            () {
              appRouter.pushNamed(AppRoute.selectDestinationCountryView);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions() {
    final transactionsState = ref.watch(transactionsProvider);

    // Sort transactions by timestamp (most recent first) and get top 5
    final sortedTransactions = List<WalletTransaction>.from(
      transactionsState.transactions,
    )..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final recentTransactions = sortedTransactions.take(5).toList();

    // Show shimmer loading only if there's no cached data
    if (transactionsState.isLoading && recentTransactions.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: 16.h),
        child: ShimmerWidgets.transactionListShimmer(context, itemCount: 5),
      );
    }

    if (recentTransactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 88.0),
        child: EmptyStateWidget(
          icon: Icons.receipt_long_outlined,
          title: 'No transactions yet',
          message:
              'Your transactions will appear here once you start sending or receiving money',
          actionText: 'Send Money',
          onAction: () {
            Navigator.pushNamed(context, '/send');
          },
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: [
              SizedBox(height: 4.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent transactions',
                    style: AppTypography.titleMedium.copyWith(
                      fontFamily: 'Karla',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -.2,
                      height: 1.450,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.color!.withOpacity(.75),
                    ),
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(width: 12.h),
                  // Check if recent transactions length is greater than 5
                  Center(
                    child: InkWell(
                      onTap: () {
                        appRouter.pushNamed(AppRoute.transactionsView);
                      },
                      child: Text(
                        'See all',
                        style: AppTypography.bodyMedium.copyWith(
                          fontFamily: 'Karla',
                          color: AppColors.purple500ForTheme(context),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -.3,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              for (int i = 0; i < recentTransactions.length; i++)
                _buildTransactionCard(
                  recentTransactions[i],
                  isLast: i == recentTransactions.length - 1,
                ),
            ],
          ),
        ),

        // SizedBox(height: 32.h),
      ],
    );
  }

  Widget _buildTransactionCard(
    WalletTransaction transaction, {
    bool isLast = false,
  }) {
    return InkWell(
      onTap: () {
        appRouter.pushNamed(
          AppRoute.transactionDetailsView,
          arguments: transaction,
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: isLast ? 12.h : 24.h, top: 12.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Transaction Type Icon (Inflow/Outflow)
            SizedBox(
              width: 36.w,
              height: 36.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  SvgPicture.asset(
                    'assets/icons/svgs/transactions.svg',
                    height: 36.sp,
                    color: _getTransactionTypeColorForTransaction(
                      transaction,
                    ).withOpacity(0.35),
                  ),
                  // Foreground icon
                  Center(
                    child: SvgPicture.asset(
                      _getTransactionTypeIconForTransaction(transaction),
                      height: 20.sp,
                      color: _getTransactionTypeColorForTransaction(
                        transaction,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),

            // Transaction Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    _getBeneficiaryDisplayName(transaction),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontFamily: 'Karla',
                      fontSize: 18.sp,
                      letterSpacing: -.3,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    // maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 4.h),
                  if (transaction.reason != null &&
                      transaction.reason!.isNotEmpty) ...[
                    Text(
                      _capitalizeWords(transaction.reason!),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'Karla',
                        fontWeight: FontWeight.w400,
                        letterSpacing: -.1,
                        height: 1.5,
                        fontSize: 12.sp,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(.45),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  Text(
                    _formatTransactionTime(transaction.timestamp),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Karla',
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -.2,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _getTransactionAmount(transaction),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontFamily: 'Karla',
                    fontSize: 16.sp,

                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  _getStatusText(transaction.status).toUpperCase(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Karla',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -.5,
                    height: 1.450,
                    color: _getStatusColor(transaction.status),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success-collection' || 'success-payment':
        return AppColors.success500;
      case 'pending-collection' || 'pending-payment':
        return AppColors.warning500;
      case 'failed-collection' || 'failed-payment':
        return AppColors.error500;
      default:
        return AppColors.neutral500;
    }
  }

  String _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'success-collection' || 'success-payment':
        return 'assets/icons/svgs/circle-check.svg';
      case 'pending-collection' || 'pending-payment':
        return "assets/icons/svgs/exclamation-circle.svg";
      case 'failed-collection' || 'failed-payment':
        return "assets/icons/svgs/circle-x.svg";
      default:
        return "assets/icons/svgs/info-circle.svg";
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'success-collection' || 'success-payment':
        return 'Completed';
      case 'pending-collection' || 'pending-payment':
        return 'Pending';
      case 'failed-collection' || 'failed-payment':
        return 'Failed';
      default:
        return 'Unknown';
    }
  }

  String _getBeneficiaryDisplayName(WalletTransaction transaction) {
    // Check if this is a DayFi tag transfer
    if (transaction.source.accountType?.toLowerCase() == 'dayfi' ||
        transaction.beneficiary.accountType?.toLowerCase() == 'dayfi') {
      // For DayFi transfers, show the recipient's DayFi tag
      if (transaction.beneficiary.accountNumber != null &&
          transaction.beneficiary.accountNumber!.isNotEmpty) {
        final tag = transaction.beneficiary.accountNumber!;
        return tag.startsWith('@')
            ? tag.toUpperCase()
            : '@${tag.toUpperCase()}';
      }
      // Fallback to beneficiary name if no account number
      return transaction.beneficiary.name.toUpperCase();
    }

    // Check if this is a collection transaction (wallet funding)
    if (transaction.status.toLowerCase().contains('collection')) {
      return 'Wallet Top Up';
    }

    final profileState = ref.read(profileViewModelProvider);
    final user = profileState.user;

    if (user != null) {
      // Build user's full name from first name and last name
      final userFullName =
          '${user.firstName} ${user.lastName}'.trim().toUpperCase();
      final beneficiaryName = transaction.beneficiary.name.trim().toUpperCase();

      // Check if beneficiary name matches user's full name or is SELF FUNDING
      if (beneficiaryName == userFullName ||
          beneficiaryName == 'SELF FUNDING' ||
          beneficiaryName.contains('SELF') &&
              beneficiaryName.contains('FUNDING')) {
        return 'Wallet Top Up';
      }
    }

    // Default: return uppercase beneficiary name
    return transaction.beneficiary.name.toUpperCase();
  }

  String _getTransactionAmount(WalletTransaction transaction) {
    // Use actual amounts from the transaction data
    if (transaction.sendAmount != null && transaction.sendAmount! > 0) {
      return '₦${_formatNumber(transaction.sendAmount!)}';
    } else if (transaction.receiveAmount != null &&
        transaction.receiveAmount! > 0) {
      return '₦${_formatNumber(transaction.receiveAmount!)}';
    } else {
      return 'N/A';
    }
  }

  String _formatNumber(double amount) {
    // Format number with thousands separators
    String formatted = amount.toStringAsFixed(2);
    List<String> parts = formatted.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : '00';

    // Add commas for thousands separators
    String formattedInteger = '';
    for (int i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        formattedInteger += ',';
      }
      formattedInteger += integerPart[i];
    }

    return '$formattedInteger.$decimalPart';
  }

  String _formatTransactionTime(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);

      // Format time as HH:MM AM/PM
      final hour =
          date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
      final minute = date.minute.toString().padLeft(2, '0');
      final period = date.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    } catch (e) {
      return '';
    }
  }

  String _capitalizeWords(String text) {
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  // Get transaction type icon (inflow/outflow)
  String _getTransactionTypeIcon(String status) {
    // Collection = money coming in (inflow)
    if (status.toLowerCase().contains('collection')) {
      return 'assets/icons/svgs/arrow-narrow-down.svg'; // Down arrow for inflow
    }
    // Payment = money going out (outflow)
    else if (status.toLowerCase().contains('payment')) {
      return 'assets/icons/svgs/arrow-narrow-up.svg'; // Up arrow for outflow
    }
    return 'assets/icons/svgs/info-circle1.svg';
  }

  // Get transaction type color (inflow/outflow)
  Color _getTransactionTypeColor(String status) {
    // Collection = money coming in (green)
    if (status.toLowerCase().contains('collection')) {
      return AppColors.success500;
    }
    // Payment = money going out (orange/warning)
    else if (status.toLowerCase().contains('payment')) {
      return AppColors.warning500;
    }
    return AppColors.neutral500;
  }

  // Get transaction type icon with beneficiary check (for individual transactions)
  String _getTransactionTypeIconForTransaction(WalletTransaction transaction) {
    final beneficiaryName = _getBeneficiaryDisplayName(transaction);

    // If wallet funded, always show pay-in icon (down arrow)
    if (beneficiaryName == 'Wallet Top Up') {
      return 'assets/icons/svgs/arrow-narrow-down.svg';
    }

    // Otherwise use status-based logic
    return _getTransactionTypeIcon(transaction.status);
  }

  // Get transaction type color with beneficiary check (for individual transactions)
  Color _getTransactionTypeColorForTransaction(WalletTransaction transaction) {
    final beneficiaryName = _getBeneficiaryDisplayName(transaction);

    // If wallet funded, always show green (pay-in color)
    if (beneficiaryName == 'Wallet Top Up') {
      return AppColors.success500;
    }

    // Otherwise use status-based logic
    return _getTransactionTypeColor(transaction.status);
  }

  // Helper function to get country code from currency
  String _getCountryCodeFromCurrency(String currency) {
    switch (currency.toUpperCase()) {
      case 'NGN':
        return 'NG';
      case 'USD':
        return 'US';
      case 'GBP':
        return 'GB';
      case 'EUR':
        return 'DE'; // Default to Germany for EUR (most common)
      case 'GHS':
        return 'GH';
      case 'RWF':
        return 'RW';
      case 'KES':
        return 'KE';
      case 'UGX':
        return 'UG';
      case 'TZS':
        return 'TZ';
      case 'ZAR':
        return 'ZA';
      case 'CAD':
        return 'CA';
      default:
        return 'NG'; // Default to Nigeria
    }
  }

  // Helper function to get flag SVG path from country code
  String _getFlagPath(String? countryCode) {
    switch (countryCode?.toUpperCase()) {
      case 'NG':
        return 'assets/icons/svgs/world_flags/nigeria.svg';
      case 'GH':
        return 'assets/icons/svgs/world_flags/ghana.svg';
      case 'RW':
        return 'assets/icons/svgs/world_flags/rwanda.svg';
      case 'KE':
        return 'assets/icons/svgs/world_flags/kenya.svg';
      case 'UG':
        return 'assets/icons/svgs/world_flags/uganda.svg';
      case 'TZ':
        return 'assets/icons/svgs/world_flags/tanzania.svg';
      case 'ZA':
        return 'assets/icons/svgs/world_flags/south africa.svg';
      case 'BF':
        return 'assets/icons/svgs/world_flags/burkina faso.svg';
      case 'BJ':
        return 'assets/icons/svgs/world_flags/benin.svg';
      case 'BW':
        return 'assets/icons/svgs/world_flags/botswana.svg';
      case 'CD':
        return 'assets/icons/svgs/world_flags/democratic republic of congo.svg';
      case 'CG':
        return 'assets/icons/svgs/world_flags/republic of the congo.svg';
      case 'CI':
        return 'assets/icons/svgs/world_flags/ivory coast.svg';
      case 'CM':
        return 'assets/icons/svgs/world_flags/cameroon.svg';
      case 'GA':
        return 'assets/icons/svgs/world_flags/gabon.svg';
      case 'MW':
        return 'assets/icons/svgs/world_flags/malawi.svg';
      case 'SN':
        return 'assets/icons/svgs/world_flags/senegal.svg';
      case 'TG':
        return 'assets/icons/svgs/world_flags/togo.svg';
      case 'ZM':
        return 'assets/icons/svgs/world_flags/zambia.svg';
      case 'US':
        return 'assets/icons/svgs/world_flags/united states.svg';
      case 'GB':
        return 'assets/icons/svgs/world_flags/united kingdom.svg';
      case 'CA':
        return 'assets/icons/svgs/world_flags/canada.svg';
      case 'DE':
        return 'assets/icons/svgs/world_flags/germany.svg';
      default:
        return 'assets/icons/svgs/world_flags/nigeria.svg'; // fallback
    }
  }

  Widget _getAccountIcon(Source source, Beneficiary beneficiary) {
    final accountType = source.accountType?.toLowerCase() ?? '';
    String overlayIcon;
    switch (accountType) {
      case 'dayfi':
        overlayIcon = 'assets/icons/svgs/at.svg';
        break;
      case 'bank':
        overlayIcon = 'assets/icons/svgs/building-bank.svg';
        break;
      case 'phone':
      case 'mobile':
      case 'mobile_money':
      case 'momo':
        overlayIcon = 'assets/icons/svgs/device-mobile.svg';
        break;
      case 'crypto':
        overlayIcon = 'assets/icons/svgs/currency-dollar.svg';
        break;
      case 'card':
        overlayIcon = 'assets/icons/svgs/carddd.svg';
        break;
      default:
        overlayIcon = 'assets/icons/svgs/paymentt.svg';
    }

    return Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24.r)),
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          SvgPicture.asset(
            'assets/icons/svgs/swap.svg',
            height: 22,
            color: AppColors.neutral700.withOpacity(.35),
          ),
          SvgPicture.asset(
            overlayIcon,
            height: 16,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(.65),
          ),
        ],
      ),
    );
  }
}
