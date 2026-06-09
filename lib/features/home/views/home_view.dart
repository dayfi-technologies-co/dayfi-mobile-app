import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/constants/wallet_flag_assets.dart';
import 'package:dayfi/common/constants/username_copy.dart';
import 'package:dayfi/common/utils/haptic_helper.dart';
import 'package:dayfi/common/utils/available_balance_calculator.dart';
import 'package:dayfi/features/main/views/main_view.dart';
import 'package:dayfi/common/widgets/dayfi_refresh_scroll_view.dart';
import 'package:dayfi/common/widgets/shimmer_widgets.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/home/vm/home_viewmodel.dart';
import 'package:dayfi/features/wallet/providers/wallet_hub_provider.dart';
import 'package:dayfi/features/wallet/widgets/pay_with_currency_sheet.dart';
// import 'package:dayfi/features/budget/views/create_budget_view.dart';
import 'package:dayfi/features/dayearn/dayearn_flow.dart';
import 'package:dayfi/features/dayearn/dayearn_entry.dart';
import 'package:dayfi/features/dayflow/daybudget_flow.dart';
import 'package:dayfi/features/dayflow/dayflow_flow.dart';
import 'package:dayfi/features/dayflow/helpers/dayflow_analytics.dart';
import 'package:dayfi/features/dayflow/models/dayflow_models.dart';
import 'package:dayfi/features/dayflow/services/dayflow_api_service.dart';
import 'package:dayfi/features/dayflow/services/dayflow_income_service.dart';
import 'package:dayfi/features/dayflow/services/dayflow_dashboard_cache.dart';
import 'package:dayfi/features/dayflow/services/dayflow_local_store.dart';
import 'package:dayfi/features/dayflow/services/dayflow_user_storage.dart';
import 'package:dayfi/features/dayearn/services/dayearn_summary_cache.dart';
// import 'package:dayfi/features/dayflow/widgets/dayflow_budget_summary_banner.dart';
// import 'package:dayfi/features/dayflow/widgets/dayflow_income_banner.dart';
// import 'package:dayfi/common/services/feature_activity_service.dart';
import 'package:dayfi/features/home/widgets/home_promo_banners.dart';
// import 'package:dayfi/features/profile/widgets/profile_upgrade_card.dart';
import 'package:dayfi/features/profile/views/user_profile_view.dart';
import 'package:dayfi/features/send/constants/send_country_metadata.dart';
import 'package:dayfi/features/send/helpers/standard_send_destinations.dart';
import 'package:dayfi/features/notifications/views/notifications_view.dart';
import 'package:dayfi/features/notifications/vm/notifications_viewmodel.dart';
import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';
import 'package:dayfi/features/send/vm/send_viewmodel.dart';
import 'package:dayfi/features/send/send_flow.dart';
import 'package:dayfi/features/transactions/vm/transactions_viewmodel.dart';
import 'package:dayfi/features/budget/helpers/budget_notification_helper.dart';
import 'package:dayfi/models/notification_item.dart';
import 'package:dayfi/models/wallet_hub.dart';
import 'package:dayfi/models/wallet_transaction.dart';
import 'package:dayfi/services/notification_service.dart' as push;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dayfi/models/payment_response.dart' as payment;
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/services/remote/wallet_service.dart';
import 'package:dayfi/services/local/secure_storage.dart';
import 'package:dayfi/common/constants/storage_keys.dart';
import 'package:dayfi/common/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intercom_flutter/intercom_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
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
  final bool _isRefreshing = false;
  String _displayBalanceCurrency = 'USD';
  double? _displayRate = 1.0;
  bool _loadingDisplayRate = false;
  DayFlowIncomeEvent? _pendingIncome;
  DayFlowDashboardSnapshot? _budgetSnapshot;
  bool _sendBootstrapStarted = false;
  final SecureStorageService _secureStorage = locator<SecureStorageService>();

  static const List<String> _balanceCurrencies = ['USD', 'GBP', 'EUR', 'NGN'];

  static const Map<String, String> _balanceSymbols = {
    'USD': r'$',
    'NGN': '₦',
    'GBP': '£',
    'EUR': '€',
  };

  static const Map<String, String> _balanceFlags = {
    'USD': 'assets/icons/svgs/world_flags/united states.svg',
    'GBP': 'assets/icons/svgs/world_flags/united kingdom.svg',
    'EUR': WalletFlagAssets.eur,
    'NGN': 'assets/icons/svgs/world_flags/nigeria.svg',
  };

  @override
  void initState() {
    super.initState();
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
      _refreshNotificationsInbox();
      _checkPendingDayFlowIncome();
      _loadDayBudgetSummary();
      _prefetchDayEarnSummary();
      _loadDisplayBalanceCurrencyPreference();
      _loadDayfiId();
      _loadBalanceVisibilityPreference();
      _bootstrapSendViewModel();
    });
  }

  void _bootstrapSendViewModel() {
    if (_sendBootstrapStarted) return;
    _sendBootstrapStarted = true;

    Future.microtask(() async {
      final sendViewModel = ref.read(sendViewModelProvider.notifier);
      if (!sendViewModel.isInitialized && !sendViewModel.isInitializing) {
        await sendViewModel.initialize();
      }
      final sendState = ref.read(sendViewModelProvider);
      if (sendState.networks.isEmpty) {
        await sendViewModel.prefetchNigerianBanks();
      }
    });
  }

  Future<void> _loadDisplayBalanceCurrencyPreference() async {
    try {
      final saved = locator<SharedPreferences>().getString(
        StorageKeys.homeDisplayBalanceCurrency,
      );
      if (saved != null && _balanceCurrencies.contains(saved)) {
        setState(() => _displayBalanceCurrency = saved);
        ref.read(selectedDebitCurrencyProvider.notifier).state = saved;
      }
    } catch (_) {}
    await _loadDisplayRate();
  }

  Future<void> _saveDisplayBalanceCurrencyPreference(String currency) async {
    try {
      await locator<SharedPreferences>().setString(
        StorageKeys.homeDisplayBalanceCurrency,
        currency,
      );
    } catch (_) {}
  }

  Future<void> _loadDisplayRate() async {
    if (_displayBalanceCurrency == 'USD') {
      if (mounted) setState(() => _displayRate = 1.0);
      return;
    }
    if (mounted) setState(() => _loadingDisplayRate = true);
    try {
      final rate = await walletService.fetchExchangeRate(
        fromCurrency: 'USD',
        toCurrency: _displayBalanceCurrency,
      );
      if (mounted) setState(() => _displayRate = rate);
    } catch (_) {
      if (mounted) setState(() => _displayRate = null);
    } finally {
      if (mounted) setState(() => _loadingDisplayRate = false);
    }
  }

  Future<void> _pickDisplayBalanceCurrency() async {
    final picked = await showPayWithCurrencySheet(
      context,
      selected: _displayBalanceCurrency,
      title: 'Display balance in',
      helperText: null,
    );
    if (picked == null || picked == _displayBalanceCurrency) return;
    setState(() => _displayBalanceCurrency = picked);
    ref.read(selectedDebitCurrencyProvider.notifier).state = picked;
    await _saveDisplayBalanceCurrencyPreference(picked);
    await _loadDisplayRate();
  }

  Widget _buildBalanceCurrencyChip() {
    final flag = _balanceFlags[_displayBalanceCurrency]!;
    return GestureDetector(
      onTap: _pickDisplayBalanceCurrency,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.06),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipOval(
              child: SvgPicture.asset(
                flag,
                width: 18,
                height: 18,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadDayBudgetSummary() async {
    try {
      await DayFlowUserStorage.ensureUserScope();
      final localPlan = await DayFlowLocalStore.instance.loadCachedPlan();
      WalletHubSnapshot? hub;
      try {
        hub = await walletService.fetchWalletHub();
      } catch (_) {}

      if (DayflowDashboardCache.instance.peek() == null &&
          localPlan != null &&
          hub != null) {
        DayflowDashboardCache.instance.put(
          DayFlowAnalytics.buildLocalDashboard(
            plan: localPlan,
            hub: hub,
            flows: const [],
          ),
        );
      }

      final dash = await dayFlowApiService.fetchDashboard(
        localPlan: localPlan,
        localHub: hub,
      );
      if (!mounted) return;
      if (dash != null) {
        DayflowDashboardCache.instance.put(dash);
      }
      setState(() => _budgetSnapshot = dash);
    } catch (_) {
      if (!mounted) return;
      setState(() => _budgetSnapshot = null);
    }
  }

  Future<void> _prefetchDayEarnSummary() async {
    try {
      await dayEarnService.fetchSummary();
    } catch (_) {}
  }

  Future<void> _checkPendingDayFlowIncome() async {
    try {
      final income = await DayFlowIncomeService.instance.latestPending(
        preferCurrency: 'NGN',
      );
      if (!mounted) return;
      setState(() => _pendingIncome = income);
    } catch (_) {}
  }

  Future<void> _onPlanPendingIncome() async {
    final income = _pendingIncome;
    if (income == null) return;
    setState(() => _pendingIncome = null);
    await DayFlowFlow.openForIncome(context, income);
    if (mounted) await _checkPendingDayFlowIncome();
  }

  Future<void> _dismissPendingIncome() async {
    final income = _pendingIncome;
    if (income == null) return;
    await DayFlowIncomeService.instance.dismiss(income);
    if (!mounted) return;
    setState(() => _pendingIncome = null);
  }

  Future<void> _refreshNotificationsInbox() async {
    await ref
        .read(notificationsProvider.notifier)
        .loadNotifications(isInitialLoad: false);
    await _surfaceNewInboxAlerts();
  }

  Future<void> _surfaceNewInboxAlerts() async {
    try {
      final items = ref.read(notificationsProvider).notifications;
      final prefs = locator<SharedPreferences>();
      for (final item in items) {
        if (item.isRead) continue;
        final isTransaction = item.type == NotificationType.transaction;
        final isBudget = isBudgetNotification(item);
        if (!isTransaction && !isBudget) continue;

        final seenKey = 'seen_notif_${item.id}';
        if (prefs.getBool(seenKey) == true) continue;
        await prefs.setBool(seenKey, true);

        if (isBudget) {
          await push.NotificationService().triggerBudgetReminderAlert(
            title: item.title,
            message: item.message,
            budgetId: budgetIdFromNotification(item) ?? item.id,
          );
        } else {
          final refId = item.metadata?['reference']?.toString() ?? item.id;
          await push.NotificationService().triggerInboxAlert(
            title: item.title,
            message: item.message,
            transactionId: refId,
          );
        }
      }
    } catch (_) {}
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

  Future<void> _refreshHome() async {
    await Future.wait([
      ref.read(homeViewModelProvider.notifier).refreshWalletDetails(),
      ref.read(walletHubProvider.notifier).refresh(),
    ]);
    await ref.read(transactionsProvider.notifier).loadTransactions();
    await _refreshNotificationsInbox();
    await _checkPendingDayFlowIncome();
    await _loadDayBudgetSummary();
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

  void _onSendMoneyTapped() {
    openSendFromHomeOrTab(context, payWithCurrency: _displayBalanceCurrency);
  }

  void _onAddMoneyTapped() {
    if (!mounted) return;
    Navigator.pushNamed(context, AppRoute.addMoneySelectWalletView);
  }

  void _onPayTapped() {
    if (!mounted) return;
    Navigator.pushNamed(context, AppRoute.payBillsScopeView);
  }

  void _onBudgetsTapped() {
    if (!mounted) return;
    Navigator.pushNamed(context, AppRoute.budgetsView);
  }

  Future<void> _onDayFlowTapped() async {
    if (!mounted) return;
    await DayBudgetFlow.open(context);
  }

  Future<void> _onDayEarnTapped() async {
    if (!mounted) return;
    final cachedPots = DayEarnSummaryCache.instance.peek()?.pots;
    final hasPots =
        cachedPots != null && cachedPots.isNotEmpty ||
        await DayEarnEntry.shouldSkipIntro();
    if (!mounted) return;
    if (hasPots) {
      DayEarnFlow.openHome(context);
      return;
    }
    await DayEarnFlow.openCreate(context);
  }

  @override
  void dispose() {
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
    final sendState = ref.watch(sendViewModelProvider);
    final unreadNotificationCount =
        ref.watch(notificationsProvider).unreadCount;
    final sendViewModel = ref.read(sendViewModelProvider.notifier);
    if (sendState.channels.isEmpty && !sendState.isLoading) {
      Future.microtask(() => sendViewModel.initialize());
    }

    return Stack(
      children: [
        Scaffold(
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

                return InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UserProfileView(),
                      ),
                    );
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset("assets/icons/pngs/account.png", height: 40),
                      const SizedBox(width: 8),
                      Text(
                        firstName,
                        style: AppTypography.titleMedium.copyWith(
                          fontFamily: 'Chirp',
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            // leadingWidth: 0,
            centerTitle: false,
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
                          "assets/icons/svgs/contact.svg",
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
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsView(),
                      ),
                    );
                    if (mounted) {
                      await ref
                          .read(notificationsProvider.notifier)
                          .loadNotifications();
                    }
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: AlignmentGeometry.center,
                    children: [
                      SvgPicture.asset(
                        "assets/icons/svgs/notificationn.svg",
                        height: 40,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      Center(
                        child: SvgPicture.asset(
                          "assets/icons/svgs/bell2.svg",
                          height: 28,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                      ),
                      if (unreadNotificationCount > 0)
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: unreadNotificationCount > 8 ? 4 : 5,
                              vertical: 2,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.purple500ForTheme(context),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              unreadNotificationCount > 99
                                  ? '99+'
                                  : '$unreadNotificationCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                height: 1,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
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
                      physics: dayfiRefreshScrollPhysics,
                      slivers: [
                        DayfiRefreshSliverControl(onRefresh: _refreshHome),
                        SliverPadding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              // Padding(
                              //   padding: EdgeInsets.symmetric(
                              //     horizontal: isWide ? 24 : 18,
                              //   ),
                              //   child: const ProfileUpgradeCard(),
                              // ),
                              const SizedBox(height: 4),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isWide ? 24 : 18,
                                ),
                                child: _buildWalletBalanceCard(),
                              ),

                              const SizedBox(height: 12),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isWide ? 20 : 14,
                                ),
                                child: _buildHomeActionButtons(context),
                              ),

                              const SizedBox(height: 12),
                              _buildHomePromoSection(),

                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isWide ? 24 : 18,
                                ),
                                child: _infoCard(),
                              ),

                              const SizedBox(height: 32),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isWide ? 24 : 18,
                                ),
                                child: _buildQuickSendHeader(),
                              ),
                              _buildQuickSendList(sendState),

                              // const SizedBox(height: 24),
                              // _buildRecentTransactions(),

                              // if (_budgetSnapshot != null &&
                              //     _budgetSnapshot!.hasActivePlan &&
                              //     (_budgetSnapshot!.committedThisPeriod > 0 ||
                              //         _budgetSnapshot!
                              //             .scheduleInstances
                              //             .upcoming
                              //             .isNotEmpty))
                              //   Padding(
                              //     padding: EdgeInsets.fromLTRB(
                              //      isWide ? 24 : 18,
                              //      24,
                              //      isWide ? 24 : 18,
                              //      0,
                              //     ),
                              //     child: DayFlowBudgetSummaryBanner(
                              //       snapshot: _budgetSnapshot!,
                              //     ),
                              //   ),
                              const SizedBox(height: 124),
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
        ),

        // Opacity(opacity: .5, child: Image.asset('assets/images/IMG_3058.jpeg')),
      ],
    );
  }

  Widget _buildHomePromoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // if (_pendingIncome != null)
          //   DayFlowIncomeBanner(
          //     income: _pendingIncome!,
          //     onPlan: _onPlanPendingIncome,
          //     onDismiss: _dismissPendingIncome,
          //   ),
          const SizedBox(height: 12),
          HomePromoBannersRow(
            onTapToPay: () => TapToPayComingSoonSheet.show(context),
            onDayFlow: _onDayFlowTapped,
            onEarn: _onDayEarnTapped,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildWalletBalanceCard() {
    final homeState = ref.watch(homeViewModelProvider);
    final transactionsState = ref.watch(transactionsProvider);
    final showBalanceLoading =
        homeState.isLoading && homeState.totalAvailableBalance == null;
    final balance = homeState.balance;

    // Calculate pending amounts
    final pendingAmount = AvailableBalanceCalculator.calculatePendingAmount(
      transactionsState.transactions,
      currency: homeState.currency,
    );
    final pendingCount = AvailableBalanceCalculator.getPendingTransactionCount(
      transactionsState.transactions,
    );
    final hasPendingTransactions = pendingCount > 0;

    // Calculate available balance (always USD-equivalent from hub)
    final availableBalanceUsd =
        AvailableBalanceCalculator.calculateAvailableBalance(
          balance,
          transactionsState.transactions,
          currency: 'USD',
        );
    final rate = _displayBalanceCurrency == 'USD' ? 1.0 : (_displayRate ?? 0.0);
    final displayBalance = availableBalanceUsd * rate;
    final displaySymbol = _balanceSymbols[_displayBalanceCurrency] ?? r'$';
    final pendingDisplay = pendingAmount * rate;

    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 24, 0, 12),
        // decoration: BoxDecoration(
        //   color: Theme.of(context).colorScheme.surface,
        //   borderRadius: BorderRadius.circular(12),
        // ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Total available balance   ".toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Chirp',
                    fontSize: 12.5,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyLarge!.color!.withOpacity(.85),
                    fontWeight: FontWeight.w600,
                    letterSpacing: -.04,
                    height: 1,
                  ),
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: _toggleBalanceVisibility,
                  child: Center(
                    child: SvgPicture.asset(
                      _isBalanceVisible
                          ? "assets/icons/svgs/eye.svg"
                          : "assets/icons/svgs/eye-closed.svg",
                      height: 22,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.color!.withOpacity(0.45),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // this is show the total balance across all wallets in usd
            if (showBalanceLoading)
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBalanceCurrencyChip(),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_loadingDisplayRate &&
                                _displayBalanceCurrency != 'USD')
                              LoadingAnimationWidget.horizontalRotatingDots(
                                color: Theme.of(context).colorScheme.primary,
                                size: 24,
                              )
                            else if (_displayRate == null &&
                                _displayBalanceCurrency != 'USD')
                              Text(
                                'Rate unavailable',
                                style: TextStyle(
                                  fontFamily: 'Chirp',
                                  fontSize: 14,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.5),
                                ),
                              )
                            else
                              RichText(
                                text: TextSpan(
                                  children:
                                      _isBalanceVisible
                                          ? [
                                            TextSpan(
                                              text: displaySymbol,
                                              style: TextStyle(
                                                fontSize: 30,
                                                height: 1,
                                                fontFamily: 'Chirp',
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.onSurface,
                                                letterSpacing: -1,
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                                  _formatNumber(
                                                    displayBalance,
                                                  ).split('.')[0],
                                              style: TextStyle(
                                                fontSize: 40.0,
                                                height: 1,
                                                fontFamily: 'Chirp',
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.onSurface,
                                                letterSpacing: -1,
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                                  ".${_formatNumber(displayBalance).split('.').length > 1 ? _formatNumber(displayBalance).split('.')[1] : '00'}",
                                              style: TextStyle(
                                                fontSize: 40.0,
                                                height: 1,
                                                fontFamily: 'Chirp',
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.onSurface,
                                                letterSpacing: -1,
                                              ),
                                            ),
                                          ]
                                          : [
                                            TextSpan(
                                              text: '*****',
                                              style: TextStyle(
                                                fontSize: 40.0,
                                                height: 1,
                                                fontFamily: 'Chirp',
                                                fontWeight: FontWeight.w500,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.onSurface,
                                                letterSpacing: -1.2,
                                              ),
                                            ),
                                          ],
                                ),
                              ),
                            if (_displayBalanceCurrency != 'USD') ...[
                              const SizedBox(height: 4),
                              Text(
                                _isBalanceVisible
                                    ? '${_formatNumber(availableBalanceUsd)} USD'
                                    : '***** USD',
                                style: AppTypography.titleMedium.copyWith(
                                  fontFamily: 'Chirp',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: -.2,
                                  height: 1.2,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge!.color!.withOpacity(.8),
                                ),
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
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
                              '$displaySymbol${_formatNumber(pendingDisplay)} pending across '
                              '$pendingCount transaction${pendingCount > 1 ? 's' : ''}',
                              style: TextStyle(
                                fontFamily: 'Chirp',
                                fontSize: 12.5,
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
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSendHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Quick Send',
            style: AppTypography.titleMedium.copyWith(
              fontFamily: 'Chirp',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              letterSpacing: -.2,
              height: 1.2,
              color: Theme.of(
                context,
              ).textTheme.bodyLarge!.color!.withOpacity(.8),
            ),
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            HapticHelper.lightImpact();
            openSendFromHomeOrTab(
              context,
              payWithCurrency: _displayBalanceCurrency,
            );
          },
          child: Text(
            'See all',
            style: AppTypography.bodyMedium.copyWith(
              fontFamily: 'Chirp',
              fontWeight: FontWeight.w600,
              color: AppColors.primary500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickSendList(SendState sendState) {
    final destinations = buildStandardSendDestinations(sendState.channels);
    final destByKey = {
      for (final d in destinations)
        '${d.country?.toUpperCase()}-${d.currency?.toUpperCase()}': d,
    };

    final quickCountries =
        topAfricanCountries
            .where(
              (c) => destByKey.containsKey(
                '${c['code']?.toUpperCase()}-${c['currency']?.toUpperCase()}',
              ),
            )
            .toList();

    if (sendState.isLoading && sendState.channels.isEmpty) {
      return ShimmerWidgets.quickSendListShimmer(context);
    }

    if (quickCountries.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 72,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: quickCountries.length,
        itemBuilder: (context, idx) {
          final country = quickCountries[idx];
          final code = country['code']!.toUpperCase();
          final currency = country['currency']!.toUpperCase();
          final name = sendCountryDisplayName(code);

          return GestureDetector(
            onTap: () {
              HapticHelper.lightImpact();
              ref.read(selectedDebitCurrencyProvider.notifier).state =
                  _displayBalanceCurrency;
              showSendDeliveryMethodsSheet(
                context,
                selectedCountry: code,
                selectedCurrency: currency,
                debitCurrency: _displayBalanceCurrency,
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Chip(
                backgroundColor: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.transparent),
                ),
                labelPadding: const EdgeInsets.fromLTRB(8.0, 2.0, 0, 2.0),
                avatar: SvgPicture.asset(
                  sendCountryFlagAsset(code),
                  height: 32,
                ),
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: AppTypography.medium,
                        height: 1.5,
                        fontFamily: 'Chirp',
                        letterSpacing: -.250,
                        fontSize: 18,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      currency,
                      style: AppTypography.bodyLarge.copyWith(
                        fontFamily: 'Chirp',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.primary,
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

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 4),
          Image.asset('assets/images/idea.png', height: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your global wallet — send worldwide, pay bills, earn with Daily Earn, and budget with DayFlow.',
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
    String icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.only(top: 16, bottom: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(icon, height: 28, color: AppColors.orange500),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                height: 1.3,
                fontFamily: 'Chirp',
                letterSpacing: 0,
                fontSize: 12.5,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeActionButtons(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: _buildActionButtonWidget(
                context,
                'Send',
                "assets/icons/svgs/brand-telegram.svg",
                _onSendMoneyTapped,
              ),
            ),
            Expanded(
              child: _buildActionButtonWidget(
                context,
                'Add',
                "assets/icons/svgs/add_c.svg",
                _onAddMoneyTapped,
              ),
            ),
            Expanded(
              child: _buildActionButtonWidget(
                context,
                'Pay',
                "assets/icons/svgs/invoice_c.svg",
                _onPayTapped,
              ),
            ),
            Expanded(
              child: _buildActionButtonWidget(
                context,
                'Budget',
                "assets/icons/svgs/bell-dollar.svg",
                _onBudgetsTapped,
              ),
            ),
          ],
        ),
      ],
    );
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
        return WalletFlagAssets.eur;
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
      return UsernameCopy.label;
    }

    final sendState = ref.read(sendViewModelProvider);
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
