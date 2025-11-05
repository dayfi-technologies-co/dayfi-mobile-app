import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/utils/tier_utils.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/main/views/main_view.dart';
import 'package:dayfi/features/notifications/views/notifications_view.dart';
import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';
import 'package:dayfi/features/home/vm/home_viewmodel.dart';
import 'package:dayfi/features/send/views/send_payment_method_view.dart';
import 'package:dayfi/features/transactions/vm/transactions_viewmodel.dart';
import 'package:dayfi/models/wallet_transaction.dart';
import 'package:dayfi/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
    // Initialize wallet data when view loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeViewModelProvider.notifier).initialize();
      ref.read(transactionsProvider.notifier).loadTransactions();
    });
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

      body: RefreshIndicator(
        onRefresh: () async {
          // Dismiss keyboard when refreshing
          FocusScope.of(context).unfocus();

          // Refresh wallet data and transactions
          try {
            await ref
                .read(homeViewModelProvider.notifier)
                .refreshWalletDetails();
            await ref.read(transactionsProvider.notifier).loadTransactions();
          } catch (e) {
            // Log error but don't crash the app
            print('Error refreshing HomeView: $e');
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.0.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transfer Limit Card
              // _buildUpgradeCard(),
              // SizedBox(height: 16.h),
              _buildWalletBalanceCard(),
              SizedBox(height: 18.h),
              _buildHomeActionButtons(context),
              SizedBox(height: 40.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontFamily: 'CabinetGrotesk',
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -.4,
                      height: 1.450,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.color!.withOpacity(.75),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              _buildRecentTransactions(),
              SizedBox(height: 24.h),
              Center(
                child: InkWell(
                  onTap: () {
                    appRouter.pushNamed(AppRoute.transactionsView);
                  },
                  child: Text(
                    'See all transactions',
                    style: AppTypography.bodyMedium.copyWith(
                      fontFamily: 'Karla',
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      letterSpacing: 0.00,
                      height: 1.450,
                      color: AppColors.purple500ForTheme(context),
                    ),
                  ),
                ),
              ),

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

    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        // border: Border.all(color: AppColors.neutral200),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral500.withOpacity(0.05),
            blurRadius: 4.0,
            offset: const Offset(0, 4),
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 18, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Your universal wallet balance",
              style: TextStyle(
                fontFamily: 'Karla',
                fontSize: 12.5,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(.6),
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Country flag
                    SvgPicture.asset(
                      _getFlagPath(
                        _getCountryCodeFromCurrency(homeState.currency),
                      ),
                      height: 18.0.h,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      homeState.currency,
                      style: AppTypography.bodyMedium.copyWith(
                        fontFamily: 'CabinetGrotesk',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8.w),
                  ],
                ),

                if (isLoading)
                  Text(
                    "0.00",
                    style: TextStyle(
                      fontSize: 40.sp,
                      fontFamily: 'CabinetGrotesk',
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                      letterSpacing: 0,
                    ),
                  )
                else
                  Text(
                    balance,
                    style: TextStyle(
                      fontSize: 40.sp,
                      fontFamily: 'CabinetGrotesk',
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                      letterSpacing: 0,
                    ),
                  ),
              ],
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

  Widget _buildRecentTransactions() {
    final transactionsState = ref.watch(transactionsProvider);

    // Sort transactions by timestamp (most recent first) and get top 2
    final sortedTransactions = List<WalletTransaction>.from(
      transactionsState.transactions,
    )..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final recentTransactions = sortedTransactions.take(3).toList();

    if (transactionsState.isLoading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: 112),
          child: LoadingAnimationWidget.horizontalRotatingDots(
            color: AppColors.primary600,
            size: 24,
          ),
        ),
      );
    }

    if (recentTransactions.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          'No transactions yet',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontFamily: 'Karla',
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          for (int i = 0; i < recentTransactions.length; i++)
            _buildTransactionCard(
              recentTransactions[i],
              isLast: i == recentTransactions.length - 1,
            ),
        ],
      ),
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
        margin: EdgeInsets.only(bottom: isLast ? 8.h : 24.h, top: 8.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Status Icon
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: _getStatusColor(transaction.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: SvgPicture.asset(
                _getStatusIcon(transaction.status),
                color: _getStatusColor(transaction.status),
                height: 20.sp,
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
                      letterSpacing: -.6,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    _getStatusText(transaction.status),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Karla',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -.6,
                      height: 1.450,
                      color: _getStatusColor(transaction.status),
                    ),
                  ),
                  if (transaction.reason != null &&
                      transaction.reason!.isNotEmpty) ...[
                    Text(
                      transaction.reason!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'Karla',
                        fontWeight: FontWeight.w400,
                        letterSpacing: -.6,
                        height: 1.450,
                        fontSize: 12.sp,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Amount
            Text(
              _getTransactionAmount(transaction),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontFamily: 'Karla',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success-collection':
        return AppColors.success500;
      case 'pending-collection':
        return AppColors.warning500;
      case 'failed-collection':
        return AppColors.error500;
      default:
        return AppColors.neutral500;
    }
  }

  String _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'success-collection':
        return 'assets/icons/svgs/circle-check.svg';
      case 'pending-collection':
        return "assets/icons/svgs/exclamation-circle.svg";
      case 'failed-collection':
        return "assets/icons/svgs/circle-x.svg";
      default:
        return "assets/icons/svgs/info-circle.svg";
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'success-collection':
        return 'Completed';
      case 'pending-collection':
        return 'Pending';
      case 'failed-collection':
        return 'Failed';
      default:
        return 'Unknown';
    }
  }

  String _getBeneficiaryDisplayName(WalletTransaction transaction) {
    final profileState = ref.read(profileViewModelProvider);
    final user = profileState.user;

    if (user != null) {
      // Build user's full name from first name and last name
      final userFullName =
          '${user.firstName} ${user.lastName}'.trim().toUpperCase();
      final beneficiaryName = transaction.beneficiary.name.trim().toUpperCase();

      // Check if beneficiary name matches user's full name
      if (beneficiaryName == userFullName) {
        return 'Top-Up';
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
}
