import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/utils/haptic_helper.dart';
import 'package:dayfi/common/utils/available_balance_calculator.dart';
import 'package:dayfi/features/main/views/main_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:dayfi/common/utils/tier_utils.dart';
import 'package:dayfi/common/widgets/empty_state_widget.dart';
import 'package:dayfi/common/widgets/shimmer_widgets.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/home/vm/home_viewmodel.dart';
import 'package:dayfi/features/notifications/views/notifications_view.dart';
import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';
import 'package:dayfi/features/send/vm/send_viewmodel.dart';
import 'package:dayfi/features/send/widgets/delivery_methods_sheet.dart';
import 'package:dayfi/features/transactions/vm/transactions_viewmodel.dart';
import 'package:dayfi/models/wallet_transaction.dart';
import 'package:dayfi/models/payment_response.dart' as payment;
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/services/remote/wallet_service.dart';
import 'package:dayfi/services/local/secure_storage.dart';
import 'package:dayfi/common/constants/storage_keys.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:dayfi/features/auth/upload_documents/views/upload_documents_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  // Top 7 African countries for quick send
  final List<Map<String, String>> topAfricanCountries = [
    {'code': 'NG', 'name': 'Nigeria', 'currency': 'NGN'},
    {'code': 'KE', 'name': 'Kenya', 'currency': 'KES'},
    {'code': 'TZ', 'name': 'Tanzania', 'currency': 'TZS'},
    {'code': 'ZA', 'name': 'South Africa', 'currency': 'ZAR'},
    {'code': 'SN', 'name': 'Senegal', 'currency': 'XOF'},
    {'code': 'CM', 'name': 'Cameroon', 'currency': 'XAF'},
    {'code': 'BW', 'name': 'Botswana', 'currency': 'BWP'},
    {'code': 'UG', 'name': 'Uganda', 'currency': 'UGX'},
    {'code': 'RW', 'name': 'Rwanda', 'currency': 'RWF'},
  ];

  String? _dayfiId;
  bool _isLoadingDayfiId = true;
  bool _isBalanceVisible = true;
  bool _isRefreshing = false;
  final SecureStorageService _secureStorage = locator<SecureStorageService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize wallet data when view loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load profile first to get user name
      ref
          .read(profileViewModelProvider.notifier)
          .loadUserProfile(isInitialLoad: true);
      ref.read(homeViewModelProvider.notifier).initialize();
      ref
          .read(transactionsProvider.notifier)
          .loadTransactions(isInitialLoad: true);
      _loadDayfiId();
      _loadBalanceVisibilityPreference();
    });
  }

  void _toggleBalanceVisibility() {
    setState(() {
      _isBalanceVisible = !_isBalanceVisible;
    });
    // Save the preference to persistent storage
    _saveBalanceVisibilityPreference(_isBalanceVisible);
  }

  Future<void> _loadBalanceVisibilityPreference() async {
    try {
      final hideBalance = await _secureStorage.read(
        StorageKeys.hideUserBalance,
      );
      if (hideBalance.isNotEmpty) {
        setState(() {
          _isBalanceVisible = hideBalance != 'true';
        });
      }
    } catch (e) {
      // If there's an error loading the preference, keep the default (visible)
      AppLogger.error('Error loading balance visibility preference: $e');
    }
  }

  Future<void> _saveBalanceVisibilityPreference(bool isVisible) async {
    try {
      await _secureStorage.write(
        StorageKeys.hideUserBalance,
        (!isVisible).toString(),
      );
    } catch (e) {
      AppLogger.error('Error saving balance visibility preference: $e');
    }
  }

  // Helper to get initials from a name
  String _getInitials(String name) {
    final words =
        name.trim().split(RegExp(r"\\s+")).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) {
      final w = words[0];
      if (w.isEmpty) return '?';
      return w[0].toUpperCase();
    }
    final first = words.first;
    final last = words.last;
    final firstChar = first.isNotEmpty ? first[0] : '';
    final lastChar = last.isNotEmpty ? last[0] : '';
    final initials = (firstChar + lastChar).toUpperCase();
    return initials.isEmpty ? '?' : initials;
  }

  Future<void> _loadDayfiId() async {
    // Load cached dayfi tag from storage first
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

      // Find the first wallet with a non-empty dayfi tag
      if (walletResponse.wallets.isNotEmpty) {
        final walletWithDayfiId = walletResponse.wallets.firstWhere(
          (wallet) => wallet.dayfiId.isNotEmpty && wallet.dayfiId != 'null',
          orElse: () => walletResponse.wallets.first,
        );

        if (walletWithDayfiId.dayfiId.isNotEmpty &&
            walletWithDayfiId.dayfiId != 'null') {
          // Cache the dayfi tag for next time
          await localCache.saveToLocalCache(
            key: 'dayfi_id',
            value: walletWithDayfiId.dayfiId,
          );

          setState(() {
            _dayfiId = walletWithDayfiId.dayfiId;
            _isLoadingDayfiId = false;
          });
        } else {
          // No valid dayfi tag found, clear any cached value
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
      // Don't show error to user, just don't display dayfi tag
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
    // Ensure channels are loaded in the background for quick send
    final sendState = ref.watch(sendViewModelProvider);
    final sendViewModel = ref.read(sendViewModelProvider.notifier);
    if (sendState.channels.isEmpty && !sendState.isLoading) {
      // Trigger channel loading if not already loaded
      Future.microtask(() => sendViewModel.initialize());
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: .5,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leadingWidth: 1,
        foregroundColor: Theme.of(context).scaffoldBackgroundColor,
        shadowColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        leading: const SizedBox.shrink(),
        title: Consumer(
          builder: (context, ref, child) {
            final profileState = ref.watch(profileViewModelProvider);
            final userName = profileState.userName;
            final firstName = userName.split(' ').first;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Home',
                  style: AppTypography.titleMedium.copyWith(
                    fontFamily: 'FunnelDisplay',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            );
          },
        ),

        // leadingWidth: 0,
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: _navigateToContactUs,
              child: Stack(
                alignment: AlignmentGeometry.center,
                children: [
                  SvgPicture.asset(
                    "assets/icons/svgs/notificationn.svg",
                    height: 40,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  Center(
                    child: SvgPicture.asset(
                      "assets/icons/svgs/support.svg",
                      height: 28,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 18),
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
                    height: 40,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  Center(
                    child: SvgPicture.asset(
                      "assets/icons/svgs/bell.svg",
                      height: 28,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWide = constraints.maxWidth > 600;
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isWide ? 500 : double.infinity,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    CupertinoSliverRefreshControl(
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
                          await ref
                              .read(transactionsProvider.notifier)
                              .loadTransactions();

                          // Success haptic
                          HapticHelper.success();
                        } catch (e) {
                          // Error haptic
                          HapticHelper.error();
                          // Log error but don't crash the app
                          // print('Error refreshing HomeView: $e');
                        }
                      },
                    ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isWide ? 24 : 18,
                            ),
                            child: _buildUpgradeCard(),
                          ),

                          SizedBox(height: 8),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isWide ? 24 : 18,
                            ),
                            child: _buildWalletBalanceCard(),
                          ),

                          SizedBox(height: 12),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isWide ? 24 : 18,
                            ),
                            child: _buildHomeActionButtons(context),
                          ),

                          SizedBox(height: 12),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isWide ? 24 : 18,
                            ),
                            child: _infoCard(),
                          ),

                          SizedBox(height: 32),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isWide ? 24 : 18,
                            ),
                            child: Text(
                              'Quick Send',
                              style: AppTypography.titleMedium.copyWith(
                                fontFamily: 'Chirp',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -.2,
                                height: 1.450,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge!.color!.withOpacity(.75),
                              ),
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Show shimmer while channels are loading
                          if (sendState.isLoading || sendState.channels.isEmpty)
                            ShimmerWidgets.quickSendListShimmer(context)
                          else
                            SizedBox(
                              height: 72,
                              child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                itemCount: topAfricanCountries.length,
                                // separatorBuilder: (context, idx) => SizedBox(width: 8),
                                itemBuilder: (context, idx) {
                                  final country = topAfricanCountries[idx];
                                  // Only show chip if channel exists for this country/currency
                                  final hasChannel = sendState.channels.any(
                                    (c) =>
                                        c.country?.toUpperCase() ==
                                            country['code'] &&
                                        c.currency?.toUpperCase() ==
                                            country['currency'] &&
                                        c.status == 'active',
                                  );
                                  if (!hasChannel) {
                                    return const SizedBox.shrink();
                                  }
                                  return GestureDetector(
                                    onTap: () {
                                      sendViewModel.updateReceiveCountry(
                                        country['code']!,
                                        country['currency']!,
                                      );

                                      showModalBottomSheet(
                                        barrierColor: Colors.black.withOpacity(
                                          0.85,
                                        ),
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor:
                                            Theme.of(
                                              context,
                                            ).scaffoldBackgroundColor,
                                        builder: (BuildContext ctx) {
                                          return DeliveryMethodsSheet(
                                            selectedCountry: country['code']!,
                                            selectedCurrency:
                                                country['currency']!,
                                          );
                                        },
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: Chip(
                                        backgroundColor:
                                            Theme.of(
                                              context,
                                            ).colorScheme.surface,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          side: BorderSide(
                                            color: Colors.transparent,
                                          ),
                                        ),
                                        labelPadding: const EdgeInsets.fromLTRB(
                                          8.0,
                                          2.0,
                                          0,
                                          2.0,
                                        ),
                                        avatar: SvgPicture.asset(
                                          _getFlagPath(country['code']),
                                          height: 32,
                                        ),
                                        label: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              country['name']!,
                                              style: AppTypography.bodyLarge
                                                  .copyWith(
                                                    fontWeight:
                                                        AppTypography.medium,
                                                    height: 1.5,
                                                    fontFamily: 'Chirp',
                                                    letterSpacing: -.250,
                                                    fontSize: 18,
                                                    color:
                                                        Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge!
                                                            .color,
                                                  ),
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              country['currency']!,
                                              style: AppTypography.bodyLarge
                                                  .copyWith(
                                                    fontFamily: 'Chirp',
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color:
                                                        Theme.of(
                                                          context,
                                                        ).colorScheme.primary,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                          // SizedBox(height: 18),

                          // Padding(
                          //   padding: EdgeInsets.symmetric(horizontal: 18),
                          //   child: Text(
                          //     'Quick Send',
                          //     style: AppTypography.titleMedium.copyWith(
                          //       fontFamily: 'Chirp',
                          //       fontSize: 14,
                          //       fontWeight: FontWeight.w500,
                          //       letterSpacing: -.2,
                          //       height: 1.450,
                          //       color: Theme.of(
                          //         context,
                          //       ).textTheme.bodyLarge!.color!.withOpacity(.75),
                          //     ),
                          //     textAlign: TextAlign.start,
                          //     overflow: TextOverflow.ellipsis,
                          //   ),
                          // ),
                          // _buildRecentTransactions(),
                          SizedBox(height: 112),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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

    return tierDescription ==
            'You\'re currently on Tier 2. You have access to the highest transfer limits.'
        ? const SizedBox()
        : Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
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
              Image.asset("assets/icons/pngs/account_4.png", height: 40),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Increase transfer limit',
                      style: AppTypography.titleMedium.copyWith(
                        fontFamily: 'FunnelDisplay',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        text: "$tierDescription ",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Chirp',
                          letterSpacing: -.250,
                          height: 1.2,
                        ),
                        children: [
                          WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                        // Import the correct class for the upload documents view
                                        // If it's UploadDocumentsView, adjust as needed
                                        // ignore: prefer_const_constructors
                                        UploadDocumentsView(
                                          showBackButton: true,
                                        ),
                                  ),
                                );
                              },
                              child: Text(
                                nextTierInfo,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Chirp',
                                  letterSpacing: -.4,
                                  height: 1.2,
                                  // decoration: TextDecoration.underline,
                                ),
                              ),
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

  Widget _buildWalletBalanceCard() {
    final homeState = ref.watch(homeViewModelProvider);
    final transactionsState = ref.watch(transactionsProvider);
    final isLoading = homeState.isLoading;
    final balance = homeState.balance;
    final hasBalance = balance != '0.00' && balance.isNotEmpty;

    // Calculate pending amounts
    final pendingAmount = AvailableBalanceCalculator.calculatePendingAmount(
      transactionsState.transactions,
      currency: homeState.currency,
    );
    final pendingCount = AvailableBalanceCalculator.getPendingTransactionCount(
      transactionsState.transactions,
    );
    final hasPendingTransactions = pendingCount > 0;

    // Calculate available balance
    final availableBalance =
        AvailableBalanceCalculator.calculateAvailableBalance(
          balance,
          transactionsState.transactions,
          currency: homeState.currency,
        );

    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 24, 0, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              hasPendingTransactions
                  ? "Available balance   "
                  : "Your balance   ",
              style: TextStyle(
                fontFamily: 'Chirp',
                fontSize: 12,
                color: Theme.of(
                  context,
                ).textTheme.bodyLarge!.color!.withOpacity(.85),
                fontWeight: FontWeight.w600,
                letterSpacing: -.04,
                height: 1.450,
              ),
            ),
            SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        _getFlagPath(
                          _getCountryCodeFromCurrency(homeState.currency),
                        ),
                        height: 20.0,
                      ),
                      SizedBox(width: 6),
                      Text(
                        "${homeState.currency} ",
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.success600,
                          fontSize: 14,
                          fontFamily: AppTypography.secondaryFontFamily,
                          fontWeight: AppTypography.regular,
                          height: 1,
                          letterSpacing: -.70,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: _toggleBalanceVisibility,
                  child: Stack(
                    alignment: AlignmentGeometry.center,
                    children: [
                      SvgPicture.asset(
                        "assets/icons/svgs/notificationn.svg",
                        height: 20,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                      Center(
                        child: SvgPicture.asset(
                          _isBalanceVisible
                              ? "assets/icons/svgs/eye.svg"
                              : "assets/icons/svgs/eye-closed.svg",
                          height: 16,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 6),

            if (isLoading && !hasBalance)
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 5),
                child: LoadingAnimationWidget.horizontalRotatingDots(
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              )
            else
              Column(
                children: [
                  const SizedBox(height: 8),
                  Text(
                    _isBalanceVisible
                        ? _formatNumber(availableBalance)
                        : '*****',
                    style: TextStyle(
                      fontSize: 40,
                      height: 1,
                      fontFamily: 'Chirp',
                      fontWeight: FontWeight.w700,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(1),
                      letterSpacing: -.40,
                    ),
                  ),

                  const SizedBox(height: 8),
                  // Show pending info if there are pending transactions
                  if (hasPendingTransactions && _isBalanceVisible) ...[
                    SizedBox(height: 8),
                    InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        // Navigate to transactions tab and search for "pending"
                        HapticHelper.lightImpact();
                        // Switch to transactions tab (index 1)
                        mainViewKey.currentState?.changeTab(1);
                        // Search for pending transactions
                        ref
                            .read(transactionsProvider.notifier)
                            .searchTransactions('pending');
                      },

                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning100.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 14,
                              color: AppColors.warning600,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${homeState.currencySymbol}${_formatNumber(pendingAmount)} pending across '
                              '$pendingCount transaction${pendingCount > 1 ? 's' : ''}',
                              style: TextStyle(
                                fontFamily: 'Chirp',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.warning600,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),

            SizedBox(height: 18),
          ],
        ),
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 4),
          Image.asset("assets/images/idea.png", height: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Send money via bank transfers, mobile money and more globally',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 14,
                fontFamily: 'Chirp',
                fontWeight: FontWeight.w500,
                letterSpacing: -0.4,
                height: 1.5,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtonWidget(
    BuildContext context,
    String label,
    String description,
    String iconAsset,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,

          // boxShadow: [
          //   BoxShadow(
          //     color: const Color.fromARGB(255, 123, 36, 211).withOpacity(0.05),
          //     blurRadius: 2.0,
          //     offset: const Offset(0, 2.0),
          //     spreadRadius: 0.5,
          //   ),
          // ],

          // border: Border.all(
          //   color: Theme.of(context).colorScheme.outline.withOpacity(.15),
          //   width: .5,
          // ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background circle
                      SvgPicture.asset(
                        iconAsset,
                        height: 40,
                        color: AppColors.purple400,
                      ),

                      // Foreground icon
                      Center(
                        child: Transform.rotate(
                          angle: label == "Send Money" ? -.8 : 0,
                          child: Icon(
                            label == "Send Money"
                                ? Icons.arrow_forward
                                : Icons.add,
                            size: label == "Send Money" ? 26 : 28,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                height: 1.5,
                fontFamily: 'Chirp',
                letterSpacing: -.250,

                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Opacity(
              opacity: .7,
              child: Text(
                description,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                  fontFamily: 'Chirp',
                  letterSpacing: -.25,
                  fontSize: 14,
                ),
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
        Expanded(
          child: _buildActionButtonWidget(
            context,
            'Topup Wallet',
            "Add money to your Dayfi wallet instantly",
            'assets/icons/svgs/transactions.svg',
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
                // debug// print('Navigation error: $e');
              }
            },
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _buildActionButtonWidget(
            context,
            'Send Money',
            'Transfer funds locally or across borders',
            'assets/icons/svgs/transactions.svg',
            () {
              appRouter.pushNamed(AppRoute.selectDestinationCountryView);
            },
          ),
        ),
        // const SizedBox(width: 12),

        // Expanded(
        //   child: _buildActionButtonWidget(
        //     context,
        //     'Send crypto',
        //     "Send funds straight to wallet addresses",
        //     'assets/icons/svgs/swap.svg',
        //     () async {
        //       try {
        //         await Navigator.pushNamed(
        //           context,
        //           AppRoute.sendFetchCryptoChannelsView,
        //           // arguments: <String, dynamic>{
        //           //   'selectedData': <String, dynamic>{},
        //           //   'recipientData': <String, dynamic>{},
        //           //   'senderData': <String, dynamic>{},
        //           //   'paymentData': <String, dynamic>{},
        //           // },
        //         );
        //       } catch (e) {
        //         // Handle navigation error silently or show a message
        //         // debug// print('Navigation error: $e');
        //       }
        //     },
        //   ),
        // ),
      ],
    );
  }

  Widget _buildRecentTransactions() {
    final transactionsState = ref.watch(transactionsProvider);
    final profileState = ref.watch(profileViewModelProvider);
    final user = profileState.user;

    // Build multiple name variations for comparison
    Set<String> userNames = {};
    if (user != null) {
      final firstName = user.firstName.trim().toLowerCase();
      final middleName = user.middleName?.trim().toLowerCase();
      final lastName = user.lastName.trim().toLowerCase();

      // Add different name combinations
      if (firstName.isNotEmpty && lastName.isNotEmpty) {
        userNames.add('$firstName $lastName');
        userNames.add('$firstName$lastName');
        userNames.add('$firstName $lastName'.trim());
      }

      if (middleName != null && middleName.isNotEmpty) {
        if (firstName.isNotEmpty && lastName.isNotEmpty) {
          userNames.add('$firstName $middleName $lastName');
          userNames.add('$firstName $middleName$lastName');
          userNames.add('$firstName$middleName$lastName');
        }
      }

      // Also add the userName from profileState (which includes middle name)
      final userName = profileState.userName.toLowerCase().trim();
      if (userName.isNotEmpty && userName != 'loading...') {
        userNames.add(userName);
        // Add without spaces
        userNames.add(userName.replaceAll(' ', ''));
      }
    }

    // Sort transactions by timestamp (most recent first)
    final sortedTransactions = List<WalletTransaction>.from(
      transactionsState.transactions,
    )..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Filter out duplicates and self-transactions
    final seenAccountNumbers = <String>{};
    final filteredTransactions =
        sortedTransactions.where((tx) {
          final beneficiary = tx.beneficiary;
          final source = tx.source;

          // Skip if beneficiary name is empty or whitespace only
          if (beneficiary.name.trim().isEmpty) {
            return false;
          }

          // Filter out self-transactions
          final beneficiaryName = beneficiary.name.toLowerCase().trim();
          final beneficiaryNameNoSpaces = beneficiaryName.replaceAll(' ', '');

          for (final userName in userNames) {
            final userNameNoSpaces = userName.replaceAll(' ', '');

            if (beneficiaryName == userName ||
                beneficiaryNameNoSpaces == userNameNoSpaces) {
              return false; // Hide this transaction
            }
          }

          // Create a unique key combining source account number and beneficiary account number (dayfi tag)
          final sourceAccountNumber = source.accountNumber ?? '';
          final beneficiaryAccountNumber = beneficiary.accountNumber ?? '';

          // For dayfi tags, use the beneficiary's account number as the unique identifier
          final uniqueKey =
              source.accountType?.toLowerCase() == 'dayfi'
                  ? 'dayfi_${beneficiaryAccountNumber.toLowerCase()}'
                  : 'other_${sourceAccountNumber}';

          if (seenAccountNumbers.contains(uniqueKey)) {
            return false; // Skip duplicate
          }
          seenAccountNumbers.add(uniqueKey);
          return true;
        }).toList();

    // Get top 5 recent transactions
    final recentTransactions = filteredTransactions.take(5).toList();

    // If we have cached transactions (even if empty), show empty state immediately if not loading new data
    if (recentTransactions.isEmpty) {
      if (transactionsState.isLoading &&
          transactionsState.transactions.isEmpty) {
        // Only show shimmer if there is truly no cached data at all
        return Padding(
          padding: EdgeInsets.only(top: 16),
          child: ShimmerWidgets.transactionListShimmer(context, itemCount: 5),
        );
      } else {
        // Show empty state if not loading or if we have already loaded once
        return Padding(
          padding: const EdgeInsets.only(top: 88.0),
          child: EmptyStateWidget(
            icon: Icons.receipt_long_outlined,
            title: 'No transactions yet',
            message:
                'your transactions will appear here once you start sending or receiving money',
            actionText: 'Send Money',
            onAction: () {
              Navigator.pushNamed(context, '/send');
            },
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            'Send Again',
            style: AppTypography.titleMedium.copyWith(
              fontFamily: 'Chirp',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: -.2,
              height: 1.450,
              color: Theme.of(
                context,
              ).textTheme.bodyLarge!.color!.withOpacity(.75),
            ),
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(height: 8),
        SizedBox(
          height: 72,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12),
            itemCount: recentTransactions.length,
            itemBuilder: (context, i) {
              final tx = recentTransactions[i];
              final beneficiary = tx.beneficiary;
              final source = tx.source;
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoute.sendView,
                    arguments: <String, dynamic>{
                      'beneficiaryWithSource': {
                        'beneficiary': beneficiary,
                        'source': source,
                      },
                      'fromRecipients': true,
                    },
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Chip(
                    padding: EdgeInsets.all(4),
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.transparent),
                    ),
                    labelPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    avatar: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SvgPicture.asset(
                              "assets/icons/svgs/recipients.svg",
                              width: 40,
                              height: 40,
                              color: AppColors.purple500ForTheme(context),
                            ),
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: Center(
                                child: Text(
                                  _getInitials(beneficiary.name),
                                  style: TextStyle(
                                    color: AppColors.neutral0,
                                    fontFamily: 'Chirp',
                                    fontSize: 16,
                                    letterSpacing: -.25,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: AppColors.neutral0,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.neutral200,
                                width: 1,
                              ),
                            ),
                            child: ClipOval(
                              child: SvgPicture.asset(
                                _getFlagPath(beneficiary.country),
                                fit: BoxFit.cover,
                                width: 24,
                                height: 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    label: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          beneficiary.name.split(' ').first,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            fontFamily: 'Chirp',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _getAccountIcon(source, beneficiary),
                            SizedBox(width: 4),
                            Flexible(
                              child:
                                  source.accountType?.toLowerCase() == 'dayfi'
                                      ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            beneficiary.accountNumber
                                                    ?.split("@")
                                                    .last ??
                                                '',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.copyWith(
                                              fontFamily: 'Chirp',
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: -.25,
                                              height: 1.450,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withOpacity(0.6),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(width: 8),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 3,
                                              horizontal: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.warning400
                                                  .withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              "dayfi tag",
                                              style: TextStyle(
                                                fontFamily: 'Chirp',
                                                fontSize: 10,
                                                color: AppColors.warning600,
                                                fontWeight: FontWeight.w600,
                                                height: 1.2,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                      : Text(
                                        '${_getNetworkName(source)} • ${_getAccountNumber(source, beneficiary)}',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.copyWith(
                                          fontFamily: 'Chirp',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: -.4,
                                          height: 1.450,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.6),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
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
        margin: EdgeInsets.only(bottom: isLast ? 12 : 24, top: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Transaction Type Icon (Inflow/Outflow)
            SizedBox(
              width: 40,
              height: 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  SvgPicture.asset(
                    'assets/icons/svgs/account.svg',
                    height: 40,
                    color: _getTransactionTypeColorForTransaction(
                      transaction,
                    ).withOpacity(0.35),
                  ),
                  // Foreground icon
                  Center(
                    child: SvgPicture.asset(
                      _getTransactionTypeIconForTransaction(transaction),
                      height: 20,
                      color: _getTransactionTypeColorForTransaction(
                        transaction,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),

            // Transaction Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    _getBeneficiaryDisplayName(transaction),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontFamily: 'Chirp',
                      fontSize: 16,
                      letterSpacing: -.250,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 4),
                  if (transaction.reason != null &&
                      transaction.reason!.isNotEmpty) ...[
                    Text(
                      _capitalizeWords(transaction.reason!),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'Chirp',
                        fontWeight: FontWeight.w500,
                        letterSpacing: -.1,
                        height: 1.5,
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(.65),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  Text(
                    _formatTransactionTime(transaction.timestamp),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Chirp',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -.2,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),
            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _getTransactionAmount(transaction),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontFamily: 'Chirp',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  _getStatusText(transaction.status),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Chirp',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -.25,
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
    final isCollection = transaction.status.toLowerCase().contains(
      'collection',
    );
    final isPayment = transaction.status.toLowerCase().contains('payment');

    // Check if this is a dayfi tag transfer
    final isDayfiTransfer =
        transaction.source.accountType?.toLowerCase() == 'dayfi' ||
        transaction.beneficiary.accountType?.toLowerCase() == 'dayfi';

    // For collection (incoming money)
    if (isCollection) {
      if (isDayfiTransfer &&
          transaction.beneficiary.accountNumber != null &&
          transaction.beneficiary.accountNumber!.isNotEmpty) {
        final tag = transaction.beneficiary.accountNumber!;
        final displayTag = tag.startsWith('@') ? tag : '@$tag';
        return 'Money received from $displayTag';
      }
      return 'Money added to your wallet';
    }

    // For payment (outgoing money)
    if (isPayment) {
      // Check if it's a wallet top-up (sending to yourself)
      final profileState = ref.read(profileViewModelProvider);
      final user = profileState.user;

      if (user != null) {
        final userFullName =
            '${user.firstName} ${user.lastName}'.trim().toUpperCase();
        final beneficiaryName =
            transaction.beneficiary.name.trim().toUpperCase();

        // if (beneficiaryName == userFullName ||
        //     beneficiaryName == 'SELF FUNDING' ||
        //     (beneficiaryName.contains('SELF') &&
        //         beneficiaryName.contains('FUNDING'))) {
        //   return 'Topped up your wallet';
        // }
      }

      // Regular payment to another person
      if (isDayfiTransfer &&
          transaction.beneficiary.accountNumber != null &&
          transaction.beneficiary.accountNumber!.isNotEmpty) {
        final tag = transaction.beneficiary.accountNumber!;
        final displayTag = tag.startsWith('@') ? tag : '@$tag';
        return 'Sent money to $displayTag';
      }

      // Payment to beneficiary name
      return 'Sent to ${transaction.beneficiary.name}';
    }

    // Fallback to beneficiary name
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
      // Add 1 hour to the timestamp
      final date = DateTime.parse(timestamp).add(const Duration(hours: 1));

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

  String _getAccountNumber(Source source, Beneficiary beneficiary) {
    // For DayFi transfers, use beneficiary.accountNumber (the dayfi tag)
    if (source.accountType?.toLowerCase() == 'dayfi' &&
        beneficiary.accountNumber != null &&
        beneficiary.accountNumber!.isNotEmpty) {
      return '@${beneficiary.accountNumber!}';
    }

    // For other transfers, use source.accountNumber
    if (source.accountNumber != null && source.accountNumber!.isNotEmpty) {
      return source.accountNumber!;
    }

    return 'N/A';
  }

  String _getNetworkName(Source source) {
    if (source.accountType?.toLowerCase() == 'dayfi') {
      return 'dayfi tag';
    }

    final sendState = ref.watch(sendViewModelProvider);
    final networkId = source.networkId;

    if (networkId == null || networkId.isEmpty) {
      return 'Bank Transfer';
    }

    final network = sendState.networks.firstWhere(
      (n) => n.id == networkId,
      orElse: () => payment.Network(id: null, name: null),
    );

    return network.name ?? 'Bank Transfer';
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
      width: 32,
      height: 32,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
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
