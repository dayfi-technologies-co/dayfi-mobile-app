import 'package:dayfi/app_locator.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/features/wallet/providers/wallet_hub_provider.dart';
import 'package:dayfi/models/wallet.dart';
import 'package:dayfi/models/wallet_hub.dart';
import 'package:dayfi/services/local/local_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dayfi/services/remote/wallet_provision_service.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

// ─── Entry: wallet selector ─────────────────────────────────────────────────

class AddMoneySelectWalletView extends ConsumerStatefulWidget {
  const AddMoneySelectWalletView({super.key});

  @override
  ConsumerState<AddMoneySelectWalletView> createState() =>
      _AddMoneySelectWalletViewState();
}

class _AddMoneySelectWalletViewState extends ConsumerState<AddMoneySelectWalletView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(walletHubProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hub = ref.watch(walletHubProvider).hub;
    final rows = hub?.displayRows ?? WalletHubSnapshot.walletCatalog.map((m) {
      return WalletDisplayRow(
        currency: m['currency']! as String,
        name: m['name']! as String,
        symbol: m['symbol']! as String,
        flagPath: m['flag']! as String,
        balance: 0,
      );
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add money',
          style: AppTypography.titleMedium.copyWith(
            fontFamily: 'FunnelDisplay',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
            child: Text(
              'Which wallet do you want to fund?',
              style: TextStyle(
                fontFamily: 'Chirp',
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(rows.length, (i) {
                    final row = rows[i];
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.vertical(
                            top: i == 0
                                ? const Radius.circular(14)
                                : Radius.zero,
                            bottom: i == rows.length - 1
                                ? const Radius.circular(14)
                                : Radius.zero,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => WalletReceiveView(
                                  currency: row.currency,
                                  symbol: row.symbol,
                                  name: row.name,
                                  flagPath: row.flagPath,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                ClipOval(
                                  child: SvgPicture.asset(
                                    row.flagPath,
                                    width: 36,
                                    height: 36,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        row.name,
                                        style: TextStyle(
                                          fontFamily: 'Chirp',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                      ),
                                      Text(
                                        row.currency,
                                        style: TextStyle(
                                          fontFamily: 'Chirp',
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.45),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 18,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.3),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (i < rows.length - 1)
                          Divider(
                            height: 1,
                            indent: 62,
                            color: Theme.of(context)
                                .dividerColor
                                .withOpacity(0.06),
                          ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─── Receive: 3 tabs per wallet ─────────────────────────────────────────────


class WalletReceiveView extends ConsumerStatefulWidget {
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
  ConsumerState<WalletReceiveView> createState() => _WalletReceiveViewState();
}

class _WalletReceiveViewState extends ConsumerState<WalletReceiveView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _cryptoDetails;
  bool _loadingCrypto = false;
  bool _provisioningCrypto = false;
  String? _cryptoError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(walletHubProvider.notifier).load(showLoading: false);
    });
    if (_hasCrypto) _loadCrypto();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool get _hasFiat {
    final c = widget.currency.toUpperCase();
    final row = ref.read(walletHubProvider).hub?.rowFor(c);
    if (c == 'NGN') {
      return row?.accountNumber != null && row!.accountNumber!.isNotEmpty;
    }
    final grey = ref.read(walletHubProvider).hub?.greyFor(c);
    return grey?.fiatReceiveReady ?? false;
  }

  bool get _hasCrypto {
    final c = widget.currency.toUpperCase();
    return c == 'USD' || c == 'EUR';
  }

  bool get _fiatComingSoon {
    final c = widget.currency.toUpperCase();
    return c != 'NGN' && !_hasFiat;
  }

  Future<void> _loadCrypto() async {
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
      if (mounted) {
        setState(() => _cryptoDetails = data);
      }
    } catch (e) {
      try {
        final data = await _provisionAndFetchCrypto();
        if (mounted) setState(() => _cryptoDetails = data);
      } catch (e2) {
        if (mounted) {
          setState(() {
            _cryptoDetails = null;
            _cryptoError = e2.toString();
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

  Future<Map<String, dynamic>> _provisionAndFetchCrypto() async {
    if (mounted) setState(() => _provisioningCrypto = true);
    final outcome = await walletProvisionService.runWithProgress((_, __, ___) {});
    if (!outcome.success) {
      throw Exception(outcome.errorMessage ?? 'Wallet setup failed');
    }
    return walletService.fetchReceiveCrypto();
  }

  String? get _dayfiTag {
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

  @override
  Widget build(BuildContext context) {
    final hub = ref.watch(walletHubProvider).hub;
    final grey = hub?.greyFor(widget.currency);
    final ngnRow = hub?.rowFor('NGN');
    final accountName = ref.watch(profileViewModelProvider).userName;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add ${widget.currency}',
          style: AppTypography.titleMedium.copyWith(
            fontFamily: 'FunnelDisplay',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                tabs: const [
                  Tab(text: 'Username'),
                  Tab(text: 'Fiat'),
                  Tab(text: 'Crypto'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _UsernameTab(
            dayfiTag: _dayfiTag ?? 'Set your Dayfi Tag in profile',
            currency: widget.currency,
          ),
          _FiatTab(
            currency: widget.currency,
            available: _hasFiat,
            comingSoon: _fiatComingSoon,
            accountNumber: widget.currency == 'NGN'
                ? (ngnRow?.accountNumber ?? '')
                : (grey?.accountNumber ?? grey?.iban ?? ''),
            bankName: widget.currency == 'NGN'
                ? (ngnRow?.bankName ?? 'Bank')
                : (grey?.bankName ?? 'Grey'),
            routingNumber: '',
            accountName: accountName,
            statusLabel: grey?.statusLabel,
          ),
          _loadingCrypto || _provisioningCrypto
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 12),
                      Text(
                        _provisioningCrypto
                            ? 'Setting up your crypto wallets…'
                            : 'Loading deposit addresses…',
                        style: TextStyle(
                          fontFamily: 'Chirp',
                          fontSize: 13,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.55),
                        ),
                      ),
                    ],
                  ),
                )
              : _CryptoTab(
                  currency: widget.currency,
                  available: _hasCrypto && _cryptoDetails != null,
                  stellarAddress:
                      _cryptoDetails?['stellarAddress']?.toString() ?? '',
                  ethAddress:
                      _cryptoDetails?['ethereumAddress']?.toString() ?? '',
                  errorMessage: _cryptoError,
                ),
        ],
      ),
    );
  }
}

class _UsernameTab extends StatelessWidget {
  final String dayfiTag;
  final String currency;

  const _UsernameTab({required this.dayfiTag, required this.currency});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 32),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.alternate_email_rounded,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  'Your Dayfi Tag',
                  style: TextStyle(
                    fontFamily: 'Chirp',
                    fontSize: 13,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  dayfiTag,
                  style: TextStyle(
                    fontFamily: 'FunnelDisplay',
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Anyone on Dayfi can send $currency to your tag.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Chirp',
                    fontSize: 13,
                    height: 1.5,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _CopyButton(label: 'Copy tag', value: dayfiTag),
          const SizedBox(height: 12),
          _ShareButton(value: dayfiTag),
        ],
      ),
    );
  }
}

class _FiatTab extends ConsumerStatefulWidget {
  final String currency;
  final bool available;
  final bool comingSoon;
  final String accountNumber;
  final String bankName;
  final String routingNumber;
  final String accountName;
  final String? statusLabel;

  const _FiatTab({
    required this.currency,
    required this.available,
    required this.comingSoon,
    required this.accountNumber,
    required this.bankName,
    required this.routingNumber,
    required this.accountName,
    this.statusLabel,
  });

  @override
  ConsumerState<_FiatTab> createState() => _FiatTabState();
}

class _FiatTabState extends ConsumerState<_FiatTab> {
  bool _provisioning = false;

  Future<void> _requestNgnAccount() async {
    setState(() => _provisioning = true);
    try {
      await walletService.provisionNgnFiatAccount();
      await ref.read(walletHubProvider.notifier).refresh();
      if (mounted) {
        TopSnackbar.show(context, message: 'NGN account details updated');
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
      if (mounted) setState(() => _provisioning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = widget.currency;
    final available = widget.available;
    final comingSoon = widget.comingSoon;
    final accountNumber = widget.accountNumber;
    final bankName = widget.bankName;
    final routingNumber = widget.routingNumber;
    final accountName = widget.accountName;
    final statusLabel = widget.statusLabel;
    if (comingSoon) {
      return _UnavailableTab(
        icon: Icons.account_balance_rounded,
        title: 'Bank transfer — coming soon',
        message:
            'Fiat virtual accounts for $currency via Grey will appear here once KYB is complete. You can still receive via Username or Crypto (where available).',
        badge: statusLabel ?? 'Coming soon',
      );
    }

    if (!available || accountNumber.isEmpty) {
      if (currency == 'NGN') {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_balance_rounded, size: 40),
                const SizedBox(height: 16),
                const Text(
                  'Request NGN bank account',
                  style: TextStyle(fontFamily: 'Chirp', fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Get a Flutterwave virtual account to receive NGN by bank transfer.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Chirp', fontSize: 13),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _provisioning ? null : _requestNgnAccount,
                  child: _provisioning
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Request bank account'),
                ),
              ],
            ),
          ),
        );
      }
      return _UnavailableTab(
        icon: Icons.account_balance_rounded,
        title: 'Bank account not ready',
        message:
            'Complete verification in Grey to activate this account.',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoBanner(
            icon: Icons.info_outline_rounded,
            message: currency == 'NGN'
                ? 'Send NGN to this account. Deposits credit your unified USD balance after FX.'
                : 'Wire or ACH to this account. Funds credit your USD balance.',
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                _DetailRow(label: 'Bank name', value: bankName),
                _DetailRow(
                  label: 'Account number',
                  value: accountNumber,
                  copyable: true,
                ),
                if (currency == 'USD' && routingNumber.isNotEmpty)
                  _DetailRow(
                    label: 'Routing number',
                    value: routingNumber,
                    copyable: true,
                  ),
                _DetailRow(label: 'Account name', value: accountName),
                _DetailRow(label: 'Currency', value: currency),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _CopyButton(label: 'Copy account number', value: accountNumber),
        ],
      ),
    );
  }
}

class _CryptoTab extends StatefulWidget {
  final String currency;
  final bool available;
  final String stellarAddress;
  final String ethAddress;
  final String? errorMessage;

  const _CryptoTab({
    required this.currency,
    required this.available,
    required this.stellarAddress,
    required this.ethAddress,
    this.errorMessage,
  });

  @override
  State<_CryptoTab> createState() => _CryptoTabState();
}

class _CryptoTabState extends State<_CryptoTab> {
  String _selectedNetwork = 'stellar';

  String get _coinLabel => widget.currency == 'EUR' ? 'EURC' : 'USDC';

  String get _currentAddress => _selectedNetwork == 'stellar'
      ? widget.stellarAddress
      : widget.ethAddress;

  @override
  Widget build(BuildContext context) {
    if (!widget.available) {
      return _UnavailableTab(
        icon: Icons.currency_bitcoin_rounded,
        title: widget.currency == 'GBP'
            ? 'GBP crypto not supported'
            : 'Could not load deposit address',
        message: widget.currency == 'GBP'
            ? 'GBP has no standard USDC/EURC-style token on Ethereum testnet. Use Fiat or Convert.'
            : (widget.errorMessage ??
                'Pull to refresh or try again in a moment.'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select network',
            style: TextStyle(
              fontFamily: 'Chirp',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _NetworkChip(
                  label: 'Stellar',
                  sublabel: 'Recommended',
                  selected: _selectedNetwork == 'stellar',
                  onTap: () => setState(() => _selectedNetwork = 'stellar'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _NetworkChip(
                  label: 'Ethereum',
                  sublabel: 'ERC-20',
                  selected: _selectedNetwork == 'eth',
                  onTap: () => setState(() => _selectedNetwork = 'eth'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoBanner(
            icon: Icons.warning_amber_rounded,
            message:
                'Only send $_coinLabel on ${_selectedNetwork == 'stellar' ? 'Stellar' : 'Ethereum (ERC-20)'}. Other assets may be lost.',
            isWarning: true,
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: QrImageView(
                data: _currentAddress,
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                _DetailRow(label: 'Token', value: _coinLabel),
                _DetailRow(
                  label: 'Network',
                  value: _selectedNetwork == 'stellar'
                      ? 'Stellar Network'
                      : 'Ethereum (ERC-20)',
                ),
                _DetailRow(
                  label: 'Address',
                  value: _currentAddress,
                  copyable: true,
                  truncate: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _CopyButton(label: 'Copy address', value: _currentAddress),
          const SizedBox(height: 12),
          _ShareButton(value: _currentAddress),
        ],
      ),
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool copyable;
  final bool truncate;

  const _DetailRow({
    required this.label,
    required this.value,
    this.copyable = false,
    this.truncate = false,
  });

  @override
  Widget build(BuildContext context) {
    final display = truncate && value.length > 16
        ? '${value.substring(0, 8)}...${value.substring(value.length - 6)}'
        : value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Chirp',
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              display,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontFamily: 'Chirp',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          if (copyable && value.isNotEmpty) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Copied', style: TextStyle(fontFamily: 'Chirp')),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: Icon(
                Icons.copy_rounded,
                size: 14,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final IconData icon;
  final String message;
  final bool isWarning;

  const _InfoBanner({
    required this.icon,
    required this.message,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isWarning ? AppColors.warning600 : Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontFamily: 'Chirp',
                fontSize: 12,
                height: 1.5,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnavailableTab extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? badge;

  const _UnavailableTab({
    required this.icon,
    required this.title,
    required this.message,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.25)),
            const SizedBox(height: 16),
            if (badge != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    fontFamily: 'Chirp',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            Text(title, textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Chirp',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              )),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Chirp',
                fontSize: 13,
                height: 1.5,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
              )),
          ],
        ),
      ),
    );
  }
}

class _CopyButton extends StatelessWidget {
  final String label;
  final String value;

  const _CopyButton({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: value.isEmpty
            ? null
            : () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied')),
                );
              },
        icon: const Icon(Icons.copy_rounded, size: 16),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  final String value;
  const _ShareButton({required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: value.isEmpty ? null : () => Share.share(value),
        icon: const Icon(Icons.share_rounded, size: 16),
        label: const Text('Share'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class _NetworkChip extends StatelessWidget {
  final String label;
  final String sublabel;
  final bool selected;
  final VoidCallback onTap;

  const _NetworkChip({
    required this.label,
    required this.sublabel,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.08)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
              style: TextStyle(
                fontFamily: 'Chirp',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              )),
            Text(sublabel,
              style: TextStyle(
                fontFamily: 'Chirp',
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
              )),
          ],
        ),
      ),
    );
  }
}
