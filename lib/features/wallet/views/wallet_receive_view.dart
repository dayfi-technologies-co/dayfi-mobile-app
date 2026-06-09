import 'dart:async';

import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/constants/username_copy.dart';
import 'package:dayfi/common/widgets/dayfi_screen_app_bar.dart';
import 'package:dayfi/common/widgets/dayfi_screen_description.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/features/wallet/constants/grey_demo_bank_accounts.dart';
import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';
import 'package:dayfi/features/wallet/providers/wallet_hub_provider.dart';
import 'package:dayfi/models/user_model.dart';
import 'package:dayfi/models/wallet.dart';
import 'package:dayfi/models/wallet_hub.dart';
import 'package:dayfi/common/utils/tier_utils.dart';
import 'package:dayfi/common/utils/kyc_flow_navigation.dart';
import 'package:dayfi/features/wallet/add_money_flow.dart';
import 'package:dayfi/features/wallet/widgets/add_money_option_list.dart';
import 'package:dayfi/services/local/local_cache.dart';
import 'package:dayfi/features/dayflow/dayflow_flow.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/common/widgets/dayfi_loading_indicator.dart';
import 'package:dayfi/features/wallet/constants/crypto_network_catalog.dart';
import 'package:dayfi/features/wallet/widgets/crypto_network_picker.dart';
import 'package:dayfi/common/widgets/dayfi_readonly_copy_field.dart';
import 'package:dayfi/common/widgets/dayfi_receive_extra_details_card.dart';
import 'package:dayfi/common/widgets/dayfi_receive_tab_shell.dart';
import 'package:dayfi/common/widgets/dayfi_username_share_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

// ─── Entry: method picker (full screen, bottom-sheet-style list) ─────────────

class AddMoneySelectWalletView extends ConsumerWidget {
  const AddMoneySelectWalletView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const DayfiScreenAppBar(title: 'Add money'),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isWide ? 500 : double.infinity,
              ),
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  isWide ? 24 : 18,
                  12,
                  isWide ? 24 : 18,
                  24,
                ),
                children: [
                  DayfiScreenDescription(text: kAddMoneyHubDescription),
                  AddMoneyOptionList(
                    options: kAddMoneyMethodOptions,
                    onTap: (option) => handleAddMoneyMethodTap(context, option),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Username receive — no tabs.
class AddMoneyUsernameView extends ConsumerWidget {
  const AddMoneyUsernameView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tag = _resolveDayfiTag(ref);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: DayfiScreenAppBar(
        title: addMoneyViaTitle('Username'),
      ),
      body: AddMoneyUsernameBody(
        dayfiId: tag?.replaceFirst('@', '') ?? '',
        hasUsername: tag != null,
      ),
    );
  }
}

/// Bank transfer receive for one currency — no tabs.
class AddMoneyBankView extends ConsumerWidget {
  final String currency;
  final bool retainCurrencySheetOnBack;

  const AddMoneyBankView({
    super.key,
    required this.currency,
    this.retainCurrencySheetOnBack = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hub = ref.watch(walletHubProvider).hub;
    final c = currency.toUpperCase();

    final scaffold = Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: DayfiScreenAppBar(
        title: addMoneyViaTitle('Bank transfer'),
        onBack:
            retainCurrencySheetOnBack
                ? () => Navigator.pop(context, false)
                : null,
      ),
      body: AddMoneyBankBody(
        currency: c,
        hub: hub,
        accountName: ref.watch(profileViewModelProvider).userName,
        onClose:
            retainCurrencySheetOnBack
                ? () => Navigator.pop(context, true)
                : null,
      ),
    );

    if (!retainCurrencySheetOnBack) return scaffold;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pop(context, false);
      },
      child: scaffold,
    );
  }
}

/// Cached Stellar/ETH deposit addresses from the wallet hub (same source as bank details).
Map<String, dynamic>? cryptoReceivePayloadFromHub(WalletHubSnapshot? hub) {
  if (hub == null) return null;
  String? stellar;
  String? eth;
  for (final w in hub.ledgerWallets) {
    final s = w.stellarDepositAddress?.trim();
    if (stellar == null && s != null && s.isNotEmpty) stellar = s;
    final e = w.ethereumDepositAddress?.trim();
    if (eth == null && e != null && e.isNotEmpty) eth = e;
  }
  if ((stellar ?? '').isEmpty && (eth ?? '').isEmpty) return null;
  return {
    'stellarAddress': stellar ?? '',
    'ethereumAddress': eth ?? '',
    'networks':
        CryptoNetworkCatalog.defaultsForReceive(
          stellarAddress: stellar ?? '',
          evmAddress: eth ?? '',
        ).map((n) => {
          'key': n.key,
          'name': n.name,
          'subtitle': n.subtitle,
          'rail': n.rail,
          'recommended': n.recommended,
          'enabled': n.enabled,
          'assets': n.assets,
          'address': n.address,
        }).toList(),
  };
}

/// On-chain stablecoin deposit — no tabs.
class AddMoneyCryptoView extends ConsumerStatefulWidget {
  final String coin;

  const AddMoneyCryptoView({super.key, required this.coin});

  @override
  ConsumerState<AddMoneyCryptoView> createState() => _AddMoneyCryptoViewState();
}

class _AddMoneyCryptoViewState extends ConsumerState<AddMoneyCryptoView> {
  Map<String, dynamic>? _cryptoDetails;
  bool _loadingCrypto = false;
  bool _provisioningCrypto = false;
  String? _cryptoError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCrypto());
  }

  Future<void> _loadCrypto() async {
    final cached = cryptoReceivePayloadFromHub(ref.read(walletHubProvider).hub);
    if (cached != null && mounted) {
      setState(() {
        _cryptoDetails = cached;
        _loadingCrypto = false;
        _cryptoError = null;
      });
      unawaited(_refreshCryptoDetailsSilently());
      return;
    }

    setState(() {
      _loadingCrypto = true;
      _cryptoError = null;
    });
    try {
      var data = await walletService.fetchReceiveCrypto();
      final stellar = data['stellarAddress']?.toString().trim() ?? '';
      final eth = data['ethereumAddress']?.toString().trim() ?? '';
      if (stellar.isEmpty && eth.isEmpty) {
        data = await _provisionAndFetchCrypto();
      }
      if (mounted) setState(() => _cryptoDetails = data);
    } catch (e) {
      try {
        final data = await _provisionAndFetchCrypto();
        if (mounted) setState(() => _cryptoDetails = data);
      } catch (e2) {
        if (mounted) {
          setState(() {
            _cryptoDetails = null;
            _cryptoError = e2.toString().replaceFirst('Exception: ', '');
          });
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingCrypto = false;
          _provisioningCrypto = false;
        });
      }
    }
  }

  Future<void> _refreshCryptoDetailsSilently() async {
    try {
      final data = await walletService.fetchReceiveCrypto();
      if (!mounted) return;
      final stellar = data['stellarAddress']?.toString().trim() ?? '';
      final eth = data['ethereumAddress']?.toString().trim() ?? '';
      if (stellar.isNotEmpty || eth.isNotEmpty) {
        setState(() => _cryptoDetails = data);
      }
    } catch (_) {
      // Keep showing cached hub addresses.
    }
  }

  Future<void> _refreshCryptoNow() async {
    setState(() => _loadingCrypto = true);
    try {
      await walletService.syncCryptoInflows();
      await _loadCrypto();
      await ref.read(walletHubProvider.notifier).refresh();
      if (mounted) {
        TopSnackbar.show(context, message: 'Deposits synced');
        await DayFlowFlow.promptPendingIncome(context);
      }
    } catch (e) {
      if (mounted) {
        TopSnackbar.show(
          context,
          message: e.toString().replaceFirst('Exception: ', ''),
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _loadingCrypto = false);
    }
  }

  Future<Map<String, dynamic>> _provisionAndFetchCrypto() async {
    if (mounted) setState(() => _provisioningCrypto = true);
    final outcome = await walletProvisionService.runWithProgress((_, __, ___) {});
    if (!outcome.success) {
      throw Exception(outcome.errorMessage ?? 'Wallet setup failed');
    }
    await ref.read(walletHubProvider.notifier).refresh();
    return walletService.fetchReceiveCrypto();
  }

  @override
  Widget build(BuildContext context) {
    final coin = widget.coin.toUpperCase();
    final hubPayload = cryptoReceivePayloadFromHub(ref.watch(walletHubProvider).hub);
    final details = _cryptoDetails ?? hubPayload;
    final hubLoading =
        ref.watch(walletHubProvider).isLoading && hubPayload == null;

    if (details == null && (_loadingCrypto || _provisioningCrypto || hubLoading)) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: DayfiScreenAppBar(
          title: addMoneyViaTitle(kAddMoneyCryptoLabel),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const DayfiLoadingIndicator(),
              const SizedBox(height: 12),
              Text(
                _provisioningCrypto
                    ? 'Setting up your crypto wallets…'
                    : 'Loading deposit addresses…',
                style: TextStyle(
                  fontFamily: 'Chirp',
                  fontSize: 13,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.55),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: DayfiScreenAppBar(
        title: addMoneyViaTitle(kAddMoneyCryptoLabel),
      ),
      body: AddMoneyCryptoBody(
        coin: coin,
        available: details != null,
        cryptoPayload: details,
        errorMessage: _cryptoError,
        onRefresh: _refreshCryptoNow,
      ),
    );
  }
}

String? _resolveDayfiTag(WidgetRef ref) {
  final cached = locator<LocalCache>().getFromLocalCache('dayfi_id');
  if (cached != null && cached.toString().isNotEmpty) {
    final t = cached.toString();
    return t.startsWith('@') ? t : '@$t';
  }
  final profile = ref.read(profileViewModelProvider).user;
  final fromUser = profile?.dayfiId;
  if (fromUser != null && fromUser.isNotEmpty) {
    return fromUser.startsWith('@') ? fromUser : '@$fromUser';
  }
  for (final w in ref.read(walletHubProvider).hub?.ledgerWallets ?? <Wallet>[]) {
    if (w.dayfiId.isNotEmpty && w.dayfiId != 'null') {
      return w.dayfiId.startsWith('@') ? w.dayfiId : '@${w.dayfiId}';
    }
  }
  return null;
}

/// Legacy wrapper — opens bank receive for a currency (wallet detail Add).
class WalletReceiveView extends StatelessWidget {
  final String currency;
  final String symbol;
  final String name;
  final String flagPath;

  const WalletReceiveView({
    super.key,
    required this.currency,
    required this.symbol,
    required this.name,
    required this.flagPath,
  });

  @override
  Widget build(BuildContext context) {
    return AddMoneyBankView(currency: currency);
  }
}

// ─── Shared receive bodies ───────────────────────────────────────────────────

class AddMoneyUsernameBody extends StatelessWidget {
  final String dayfiId;
  final bool hasUsername;

  const AddMoneyUsernameBody({
    super.key,
    required this.dayfiId,
    required this.hasUsername,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasUsername) {
      return DayfiReceiveTabShell(
        showTitle: false,
        description: UsernameCopy.setInProfile,
        primaryButtonText: UsernameCopy.create,
        onPrimaryPressed: () {
          Navigator.pushNamed(context, AppRoute.dayfiTagExplanationView);
        },
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 8, bottom: 32),
      child: DayfiUsernameShareContent(
        dayfiId: dayfiId,
        showTitle: false,
        onClose: () => Navigator.pop(context),
      ),
    );
  }
}

class AddMoneyBankBody extends ConsumerStatefulWidget {
  final String currency;
  final WalletHubSnapshot? hub;
  final String accountName;
  final VoidCallback? onClose;

  const AddMoneyBankBody({
    super.key,
    required this.currency,
    required this.hub,
    required this.accountName,
    this.onClose,
  });

  @override
  ConsumerState<AddMoneyBankBody> createState() => _AddMoneyBankBodyState();
}

class _AddMoneyBankBodyState extends ConsumerState<AddMoneyBankBody> {
  bool _provisioning = false;
  bool _refreshingAfterKyc = false;
  String? _provisionError;

  bool _canCreateNgnAccount(User? user) {
    return TierUtils.canProvisionNgnVirtualAccount(user);
  }

  bool _canCreateNgnAccountNow() {
    return _canCreateNgnAccount(ref.watch(profileViewModelProvider).user);
  }

  bool _needsNgnIdentityVerification(User? user) {
    if (user == null) return true;
    return !_canCreateNgnAccount(user);
  }

  bool _needsNgnIdentityVerificationNow() {
    return _needsNgnIdentityVerification(
      ref.watch(profileViewModelProvider).user,
    );
  }

  bool get _hasBankDetails {
    final currency = widget.currency.toUpperCase();
    final grey = widget.hub?.greyFor(currency);
    final ngnRow = widget.hub?.rowFor('NGN');
    if (currency == 'NGN') {
      return ngnRow?.accountNumber?.isNotEmpty ?? false;
    }
    return grey?.hasBankDisplayDetails ?? false;
  }

  String _kycSuccessMessage({
    required KycUpgradeOutcome? outcome,
    required bool hasNgnAccount,
  }) {
    final fromFlow = outcome?.message?.trim();
    if (fromFlow != null && fromFlow.isNotEmpty) return fromFlow;
    if (widget.currency.toUpperCase() == 'NGN' && hasNgnAccount) {
      return 'Your NGN bank account is ready.';
    }
    return 'Verification complete.';
  }

  Future<void> _openUpgradeFlow() async {
    final outcome = await KycFlowNavigation.startUpgrade(
      context,
      ref: ref,
      showBackButton: true,
      showIntro: false,
    );
    if (!mounted || outcome?.success != true) return;

    setState(() => _refreshingAfterKyc = true);
    try {
      await ref.read(profileViewModelProvider.notifier).loadUserProfile();
      await ref.read(walletHubProvider.notifier).refresh();
      if (!mounted) return;

      final refreshedHub = ref.read(walletHubProvider).hub;
      final hasNgnAccount =
          refreshedHub?.rowFor('NGN')?.accountNumber?.isNotEmpty ?? false;
      TopSnackbar.showSafe(
        context,
        message: _kycSuccessMessage(
          outcome: outcome,
          hasNgnAccount: hasNgnAccount,
        ),
      );

      final hasBankDetailsNow =
          widget.currency.toUpperCase() == 'NGN'
              ? hasNgnAccount
              : (refreshedHub?.greyFor(widget.currency)?.hasBankDisplayDetails ??
                  false);

      if (widget.currency.toUpperCase() == 'NGN' &&
          !hasBankDetailsNow &&
          _canCreateNgnAccount(ref.read(profileViewModelProvider).user)) {
        await _requestNgnAccount(showSuccessSnackbar: false);
      }
    } finally {
      if (mounted) setState(() => _refreshingAfterKyc = false);
    }
  }

  Future<void> _requestNgnAccount({bool showSuccessSnackbar = true}) async {
    final user = ref.read(profileViewModelProvider).user;
    if (!_canCreateNgnAccount(user)) {
      if (mounted) {
        setState(() {
          _provisionError =
              'Verify your BVN first to create your NGN bank account.';
        });
      }
      return;
    }

    setState(() {
      _provisioning = true;
      _provisionError = null;
    });
    try {
      await walletService.provisionNgnFiatAccount();
      await ref.read(walletHubProvider.notifier).refresh();
      if (mounted && showSuccessSnackbar) {
        TopSnackbar.show(context, message: 'NGN account details updated');
      }
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      if (mounted) {
        setState(() {
          _provisionError = message.contains('BVN')
              ? 'Verify your BVN to create your NGN bank account.'
              : message;
        });
        TopSnackbar.show(
          context,
          message: message,
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _provisioning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = widget.currency.toUpperCase();
    final grey = widget.hub?.greyFor(currency);
    final ngnRow = widget.hub?.rowFor('NGN');
    final greyAccountNumber = grey?.accountNumber ?? '';
    final greyIban = grey?.iban ?? '';
    final bankName =
        currency == 'NGN'
            ? (ngnRow?.bankName ?? 'Bank')
            : (grey?.bankName ?? 'Grey');

    return _FiatTab(
      currency: currency,
      hasDisplayDetails: _hasBankDetails,
      isDemoAccount: grey?.isDemoAccount ?? false,
      accountNumber:
          currency == 'NGN' ? (ngnRow?.accountNumber ?? '') : greyAccountNumber,
      iban: greyIban,
      bankName: bankName,
      routingNumber: grey?.routingNumber ?? '',
      accountName: widget.accountName,
      statusLabel: grey?.statusLabel,
      provisioning: _provisioning,
      refreshingAfterKyc: _refreshingAfterKyc,
      onRequestNgnAccount: _requestNgnAccount,
      onUpgrade: _openUpgradeFlow,
      needsNgnIdentityVerification: _needsNgnIdentityVerificationNow(),
      canCreateNgnAccount: _canCreateNgnAccountNow(),
      provisionError: _provisionError,
      onClose: widget.onClose,
    );
  }
}

class AddMoneyCryptoBody extends StatefulWidget {
  final String coin;
  final bool available;
  final Map<String, dynamic>? cryptoPayload;
  final String? errorMessage;
  final Future<void> Function()? onRefresh;

  const AddMoneyCryptoBody({
    super.key,
    required this.coin,
    required this.available,
    this.cryptoPayload,
    this.errorMessage,
    this.onRefresh,
  });

  @override
  State<AddMoneyCryptoBody> createState() => _AddMoneyCryptoBodyState();
}

class _AddMoneyCryptoBodyState extends State<AddMoneyCryptoBody> {
  String _selectedNetworkKey = 'stellar';
  late List<CryptoNetworkOption> _networks;

  @override
  void initState() {
    super.initState();
    _networks = _resolveNetworks();
    _selectedNetworkKey = _defaultNetworkKey();
  }

  @override
  void didUpdateWidget(covariant AddMoneyCryptoBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cryptoPayload != widget.cryptoPayload) {
      _networks = _resolveNetworks();
      if (!_networks.any((n) => n.key == _selectedNetworkKey && _hasAddress(n))) {
        _selectedNetworkKey = _defaultNetworkKey();
      }
    }
  }

  List<CryptoNetworkOption> _resolveNetworks() {
    final payload = widget.cryptoPayload;
    final stellar = payload?['stellarAddress']?.toString() ?? '';
    final eth = payload?['ethereumAddress']?.toString() ?? '';
    return CryptoNetworkCatalog.parseReceiveNetworks(
      payload,
      stellarAddress: stellar,
      evmAddress: eth,
    );
  }

  List<CryptoNetworkOption> get _readyNetworks =>
      _networks.where((n) => n.enabled && n.address.trim().isNotEmpty).toList();

  String _defaultNetworkKey() {
    final ready = _readyNetworks;
    if (ready.isEmpty) return 'stellar';
    final recommended = ready.where((n) => n.recommended);
    if (recommended.isNotEmpty) return recommended.first.key;
    return ready.first.key;
  }

  bool _hasAddress(CryptoNetworkOption network) =>
      network.enabled && network.address.trim().isNotEmpty;

  CryptoNetworkOption? get _selectedNetwork =>
      CryptoNetworkCatalog.find(_networks, _selectedNetworkKey) ??
      CryptoNetworkCatalog.find(_readyNetworks, _selectedNetworkKey);

  String get _currentAddress => _selectedNetwork?.address.trim() ?? '';

  Future<void> _openNetworkPicker() async {
    final coin = widget.coin.toUpperCase();
    await showCryptoNetworkPickerSheet(
      context: context,
      title: 'Choose network',
      subtitle: 'Receive $coin on the selected network',
      networks: _networks,
      selectedKey: _selectedNetworkKey,
      receiveMode: true,
      onSelected: (network) {
        setState(() => _selectedNetworkKey = network.key);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.available) {
      return DayfiReceiveTabShell(
        showTitle: false,
        description:
            widget.errorMessage ?? 'Pull to refresh or try again in a moment.',
        showCloseButton: true,
      );
    }

    final coin = widget.coin.toUpperCase();
    final network = _selectedNetwork;
    final networkLabel =
        network == null
            ? 'Network'
            : CryptoNetworkCatalog.displayNetworkLabel(network);
    final networkShort = network?.name ?? 'Network';
    final shareText = '$coin deposit ($networkShort)\n$_currentAddress';

    final body = DayfiReceiveTabShell(
      showTitle: false,
      description:
          'Only send $coin on $networkShort. Other assets may be lost.',
      showCloseButton: true,
      children: [
        CryptoNetworkSelectorField(
          iconAsset: CryptoNetworkCatalog.iconAsset(_selectedNetworkKey),
          value: networkShort,
          onTap: _openNetworkPicker,
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            'via $coin on $networkShort',
            style: TextStyle(
              fontFamily: 'Chirp',
              fontSize: 12.5,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_currentAddress.isEmpty) ...[
          Text(
            'No deposit address for this network yet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Chirp',
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
            ),
          ),
        ] else ...[
          Center(
            child: Container(
              padding: const EdgeInsets.all(14),
              child: QrImageView(
                data: _currentAddress,
                version: QrVersions.auto,
                size: MediaQuery.of(context).size.width * 0.5,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 24),
          DayfiReadonlyCopyField(
            label: 'Wallet address',
            value: _currentAddress,
            shareText: shareText,
            shareSubject: '$coin deposit',
            maxLines: 4,
          ),
        ],
        const SizedBox(height: 20),
        DayfiReceiveExtraDetailsCard(
          rows: [
            (label: 'Token', value: coin),
            (label: 'Network', value: networkLabel),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );

    if (widget.onRefresh == null) return body;
    return RefreshIndicator(onRefresh: widget.onRefresh!, child: body);
  }
}

// ─── Bank transfer body ──────────────────────────────────────────────────────

class _FiatTab extends StatelessWidget {
  final String currency;
  final bool hasDisplayDetails;
  final bool isDemoAccount;
  final String accountNumber;
  final String iban;
  final String bankName;
  final String routingNumber;
  final String accountName;
  final String? statusLabel;
  final bool provisioning;
  final bool refreshingAfterKyc;
  final VoidCallback onRequestNgnAccount;
  final VoidCallback onUpgrade;
  final bool needsNgnIdentityVerification;
  final bool canCreateNgnAccount;
  final String? provisionError;
  final VoidCallback? onClose;

  const _FiatTab({
    required this.currency,
    required this.hasDisplayDetails,
    required this.isDemoAccount,
    required this.accountNumber,
    required this.iban,
    required this.bankName,
    required this.routingNumber,
    required this.accountName,
    this.statusLabel,
    required this.provisioning,
    this.refreshingAfterKyc = false,
    required this.onRequestNgnAccount,
    required this.onUpgrade,
    required this.needsNgnIdentityVerification,
    required this.canCreateNgnAccount,
    this.provisionError,
    this.onClose,
  });

  GreyDemoBankDetails? get _greyDemo => greyDemoBankFor(currency);

  bool get _usesGreyDemo =>
      !hasDisplayDetails && supportsGreyDemoBankTab(currency);

  bool get _showBankDetails => hasDisplayDetails || _usesGreyDemo;

  String get _bankName => _usesGreyDemo ? _greyDemo!.bankName : bankName;

  String get _accountNumber =>
      _usesGreyDemo ? _greyDemo!.accountNumber : accountNumber;

  String get _iban => _usesGreyDemo ? _greyDemo!.iban : iban;

  String get _routingNumber =>
      _usesGreyDemo ? _greyDemo!.routingNumber : routingNumber;

  bool get _isDemoBank => isDemoAccount || _usesGreyDemo;

  String _routingLabel(String c) {
    switch (c.toUpperCase()) {
      case 'GBP':
        return 'Sort code';
      case 'EUR':
        return _iban.isNotEmpty ? 'BIC' : 'Routing number';
      case 'USD':
        return 'Routing number';
      default:
        return 'Routing number';
    }
  }

  String _primaryAccountValue() {
    if (currency.toUpperCase() == 'EUR' && _iban.isNotEmpty) {
      return _iban;
    }
    return _accountNumber;
  }

  String _primaryAccountLabel() {
    if (currency.toUpperCase() == 'EUR' && _iban.isNotEmpty) {
      return 'IBAN';
    }
    return 'Account number';
  }

  String _shareText() {
    final lines = <String>[
      'Bank: $_bankName',
      '${_primaryAccountLabel()}: ${_primaryAccountValue()}',
    ];
    if (_routingNumber.isNotEmpty) {
      lines.add('${_routingLabel(currency)}: $_routingNumber');
    }
    if (accountName.isNotEmpty) {
      lines.add('Name: $accountName');
    }
    lines.add('Currency: ${currency.toUpperCase()}');
    return lines.join('\n');
  }

  Widget _buildBankDetailsContent() {
    final c = currency.toUpperCase();
    final isDemo = _isDemoBank;
    final primaryValue = _primaryAccountValue();
    final statusMessage =
        isDemo
            ? 'Sample Grey sandbox account for demo. '
                'Real wire deposits credit your wallet after business verification.'
            : c == 'NGN'
            ? 'Send NGN to this account. Deposits credit your global balance.'
            : 'Wire or transfer to this account. Funds credit your global balance.';

    final extraRows = <({String label, String value})>[
      (label: 'Bank name', value: _bankName),
      if (accountName.isNotEmpty) (label: 'Account name', value: accountName),
      if (_routingNumber.isNotEmpty)
        (label: _routingLabel(c), value: _routingNumber),
      (label: 'Currency', value: c),
      if (isDemo)
        (
          label: 'Status',
          value: statusLabel ?? 'Demo · Grey sandbox',
        ),
    ];

    return DayfiReceiveTabShell(
      showTitle: false,
      description: statusMessage,
      showCloseButton: true,
      onClose: onClose,
      children: [
        DayfiReadonlyCopyField(
          label: _primaryAccountLabel(),
          value: primaryValue,
          shareText: _shareText(),
          shareSubject: 'Bank account ($currency)',
          maxLines: currency.toUpperCase() == 'EUR' ? 4 : 3,
        ),
        const SizedBox(height: 20),
        DayfiReceiveExtraDetailsCard(rows: extraRows),
        const SizedBox(height: 32),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = currency.toUpperCase();

    if (refreshingAfterKyc) {
      return DayfiReceiveTabShell(
        showTitle: false,
        description: 'Loading your bank account details…',
        showCloseButton: true,
        onClose: onClose,
        children: const [
          Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: DayfiLoadingCenter(),
          ),
        ],
      );
    }

    if (_showBankDetails) {
      return _buildBankDetailsContent();
    }

    if (c == 'NGN') {
      if (needsNgnIdentityVerification) {
        return _NgnUpgradeRequired(onUpgrade: onUpgrade);
      }
      final errorText = provisionError?.trim();
      return DayfiReceiveTabShell(
        showTitle: false,
        description:
            provisioning
                ? 'Creating your NGN virtual account. This usually takes a few seconds.'
                : errorText?.isNotEmpty == true
                ? errorText!
                : 'Tap below to create your NGN virtual account for bank transfers.',
        primaryButtonText:
            provisioning || !canCreateNgnAccount ? null : 'Create bank account',
        onPrimaryPressed:
            provisioning || !canCreateNgnAccount ? null : onRequestNgnAccount,
        children: [
          if (provisioning)
            const Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: DayfiLoadingCenter(),
            ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

class _NgnUpgradeRequired extends StatelessWidget {
  final VoidCallback onUpgrade;

  const _NgnUpgradeRequired({required this.onUpgrade});

  @override
  Widget build(BuildContext context) {
    return DayfiReceiveTabShell(
      showTitle: false,
      description:
          'Verify your BVN to get a Nigerian bank account for deposits. '
          'It takes about 30 seconds.',
      primaryButtonText: 'Verify identity',
      onPrimaryPressed: onUpgrade,
    );
  }
}
