import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/profile/views/recovery_phrase_view.dart';
import 'package:dayfi/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

enum _ReceivePhase {
  loading,
  intro,
  provisioning,
  main,
  awaitingAddresses,
  error,
}

/// Receive USDC (Stellar or Ethereum) or USDT (Ethereum only) — currency then network.
///
/// When deposit addresses are missing, shows an intro and on-chain provisioning
/// flow (backend job or dev simulation), then QR / copy / share.
class DigitalDollarReceiveView extends StatefulWidget {
  const DigitalDollarReceiveView({super.key});

  @override
  State<DigitalDollarReceiveView> createState() =>
      _DigitalDollarReceiveViewState();
}

class _DigitalDollarReceiveViewState extends State<DigitalDollarReceiveView> {
  _ReceivePhase _phase = _ReceivePhase.loading;
  bool _loading = true;
  bool _provisioningBusy = false;
  String? _stellarAddress;
  String? _ethereumAddress;
  bool _isWalletBackedUp = true;
  String? _provisionError;
  final List<_ProvisionRow> _provisionRows = [];

  /// `USDC` or `USDT`
  String _currencyCode = 'USDC';

  /// `stellar` or `ethereum`
  String _networkKey = 'stellar';

  static const _usdcSvg = 'assets/icons/svgs/usd-coin-usdc-logo.svg';
  static const _usdtSvg = 'assets/icons/svgs/tether-usdt-logo.svg';

  List<String> get _networksForCurrency {
    if (_currencyCode == 'USDT') return const ['ethereum'];
    return const ['stellar', 'ethereum'];
  }

  bool get _hasAnyAddress {
    final s = _stellarAddress?.trim() ?? '';
    final e = _ethereumAddress?.trim() ?? '';
    return s.isNotEmpty || e.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _provisionError = null;
    });
    try {
      final userMap = await localCache.getUser();
      final user = User.fromJson(userMap);
      final res = await walletService.fetchWalletDetails();
      String? st;
      String? ev;
      for (final w in res.wallets) {
        if (st == null &&
            (w.stellarDepositAddress != null &&
                w.stellarDepositAddress!.trim().isNotEmpty)) {
          st = w.stellarDepositAddress!.trim();
        }
        if (ev == null &&
            (w.ethereumDepositAddress != null &&
                w.ethereumDepositAddress!.trim().isNotEmpty)) {
          ev = w.ethereumDepositAddress!.trim();
        }
      }
      if (!mounted) return;
      setState(() {
        _stellarAddress = st;
        _ethereumAddress = ev;
        _isWalletBackedUp = user.isWalletBackedUp;
        _loading = false;
        if (_hasAnyAddress) {
          _phase = _ReceivePhase.main;
        } else if (_phase == _ReceivePhase.provisioning ||
            _phase == _ReceivePhase.awaitingAddresses) {
          _phase = _ReceivePhase.awaitingAddresses;
        } else {
          _phase = _ReceivePhase.intro;
        }
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _phase = _ReceivePhase.error;
          _provisionError = 'Could not load wallet. Check connection and retry.';
        });
      }
    }
  }

  Future<void> _startProvision() async {
    setState(() {
      _phase = _ReceivePhase.provisioning;
      _provisioningBusy = true;
      _provisionRows.clear();
      for (var i = 0; i < 5; i++) {
        _provisionRows.add(_ProvisionRow(index: i, label: '', done: false));
      }
    });
    try {
      final outcome = await walletProvisionService.runWithProgress(
        (index, label, completed) {
          if (!mounted) return;
          setState(() {
            while (_provisionRows.length <= index) {
              _provisionRows.add(
                _ProvisionRow(index: _provisionRows.length, label: '', done: false),
              );
            }
            _provisionRows[index] = _ProvisionRow(
              index: index,
              label: label,
              done: completed,
            );
          });
        },
      );
      if (!mounted) return;
      if (!outcome.success) {
        setState(() {
          _provisioningBusy = false;
          _phase = _ReceivePhase.error;
          _provisionError = outcome.errorMessage ?? 'Provisioning failed';
        });
        return;
      }
      await _load();
      if (!mounted) return;
      setState(() {
        _provisioningBusy = false;
        if (_hasAnyAddress) {
          _phase = _ReceivePhase.main;
        } else {
          _phase = _ReceivePhase.awaitingAddresses;
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _provisioningBusy = false;
          _phase = _ReceivePhase.error;
          _provisionError = e.toString();
        });
      }
    }
  }

  void _setCurrency(String code) {
    setState(() {
      _currencyCode = code;
      if (code == 'USDT') {
        _networkKey = 'ethereum';
      } else if (!_networksForCurrency.contains(_networkKey)) {
        _networkKey = 'stellar';
      }
    });
  }

  String _settlementHint() {
    if (_currencyCode == 'USDT') return 'USDT on Ethereum';
    if (_networkKey == 'ethereum') return 'USDC on Ethereum';
    return 'USDC on Stellar';
  }

  String _addressForSelection() {
    if (_networkKey == 'ethereum') return _ethereumAddress ?? '';
    return _stellarAddress ?? '';
  }

  void _copy(String text) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    TopSnackbar.show(context, message: 'Copied to clipboard', isError: false);
  }

  Future<void> _share(String text) async {
    if (text.isEmpty) return;
    await Share.share(text);
  }

  Future<void> _openCurrencyPicker() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Currency',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                    fontFamily: 'FunnelDisplay',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _sheetTile(
                  ctx,
                  title: 'USDC',
                  selected: _currencyCode == 'USDC',
                  leading: SvgPicture.asset(_usdcSvg, height: 28, width: 28),
                  onTap: () {
                    _setCurrency('USDC');
                    Navigator.pop(ctx);
                  },
                ),
                _sheetTile(
                  ctx,
                  title: 'USDT',
                  subtitle: 'Ethereum only',
                  selected: _currencyCode == 'USDT',
                  leading: SvgPicture.asset(_usdtSvg, height: 28, width: 28),
                  onTap: () {
                    _setCurrency('USDT');
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openNetworkPicker() async {
    final nets = _networksForCurrency;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Network',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                    fontFamily: 'FunnelDisplay',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ...nets.map((key) {
                  final title = key == 'stellar' ? 'Stellar' : 'Ethereum';
                  return _sheetTile(
                    ctx,
                    title: title,
                    selected: _networkKey == key,
                    leading:
                        key == 'stellar'
                            ? SvgPicture.asset(
                              'assets/icons/svgs/stellar-xlm-logo.svg',
                              height: 28,
                              width: 28,
                            )
                            : Icon(
                              Icons.currency_bitcoin,
                              size: 28,
                              color: Theme.of(ctx).colorScheme.onSurface,
                            ),
                    onTap: () {
                      setState(() => _networkKey = key);
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sheetTile(
    BuildContext ctx, {
    required String title,
    String? subtitle,
    required bool selected,
    required VoidCallback onTap,
    Widget? leading,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color:
                selected
                    ? AppColors.purple500ForTheme(ctx).withValues(alpha: 0.08)
                    : Theme.of(ctx).colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.35,
                    ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              if (leading != null) ...[leading, const SizedBox(width: 12)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                        fontFamily: 'Chirp',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            ctx,
                          ).colorScheme.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                  ],
                ),
              ),
              if (selected)
                Icon(
                  Icons.check_circle,
                  color: AppColors.purple500ForTheme(ctx),
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pickerChip({
    required String label,
    required Widget? leading,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: leading != null ? 8 : 14,
          vertical: leading != null ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            if (leading != null) ...[leading, const SizedBox(width: 8)],
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Chirp',
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                  letterSpacing: -0.1,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              size: 20,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.45),
            ),
          ],
        ),
      ),
    );
  }

  String _shortAddress(String a) {
    if (a.length <= 18) return a;
    return '${a.substring(0, 10)}...${a.substring(a.length - 10)}';
  }

  Widget _currencyLeading() {
    if (_currencyCode == 'USDT') {
      return SvgPicture.asset(_usdtSvg, height: 22, width: 22);
    }
    return SvgPicture.asset(_usdcSvg, height: 22, width: 22);
  }

  Widget _networkLeading() {
    if (_networkKey == 'stellar') {
      return SvgPicture.asset(
        'assets/icons/svgs/stellar-xlm-logo.svg',
        height: 22,
        width: 22,
      );
    }
    return Icon(
      Icons.currency_bitcoin,
      size: 22,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  Widget _backupBanner() {
    if (_isWalletBackedUp || !_hasAnyAddress) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: AppColors.warning500.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () async {
            await Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const RecoveryPhraseView(),
              ),
            );
            await _load();
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.warning500,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Back up your recovery phrase before sending large amounts.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'Chirp',
                      height: 1.25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _introBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Text(
            'On-chain wallets',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontFamily: 'FunnelDisplay',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'We create dedicated Stellar and Ethereum receive addresses for USDC and USDT. '
            'Nothing is created until you continue — tap below when you are ready.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.35,
              fontFamily: 'Chirp',
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.78),
            ),
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            text: 'Create my wallets',
            isLoading: _provisioningBusy,
            enabled: !_provisioningBusy,
            onPressed: _startProvision,
          ),
        ],
      ),
    );
  }

  Widget _provisioningBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Setting up your wallets',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontFamily: 'FunnelDisplay',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This usually takes under a minute. Keep the app open.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontFamily: 'Chirp',
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 22),
          ..._provisionRows.map((row) {
            final hasLabel = row.label.isNotEmpty;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(
                    row.done ? Icons.check_circle : Icons.radio_button_off,
                    size: 22,
                    color:
                        row.done
                            ? AppColors.purple500ForTheme(context)
                            : Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.25),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      hasLabel ? row.label : '…',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Chirp',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          if (_provisioningBusy) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _awaitingAddressesBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.hourglass_empty_rounded,
            size: 72,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'Provisioning finished',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontFamily: 'Chirp',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Deposit addresses are not visible yet. They will appear once your account syncs from the server.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              height: 1.35,
              fontFamily: 'Chirp',
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(text: 'Refresh', onPressed: _load),
        ],
      ),
    );
  }

  Widget _errorBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.error_outline,
            size: 72,
            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 16),
          Text(
            _provisionError ?? 'Something went wrong',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontFamily: 'Chirp',
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Try again',
            onPressed: () {
              setState(() => _phase = _ReceivePhase.intro);
              _load();
            },
          ),
        ],
      ),
    );
  }

  Widget _mainBody() {
    final address = _addressForSelection();
    final ready = address.isNotEmpty;
    final networkLabel = _networkKey == 'stellar' ? 'Stellar' : 'Ethereum';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          _backupBanner(),
          Row(
            children: [
              Expanded(
                child: _pickerChip(
                  label: _currencyCode,
                  leading: _currencyLeading(),
                  onTap: _openCurrencyPicker,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _pickerChip(
                  label: networkLabel,
                  leading: _networkLeading(),
                  onTap: _openNetworkPicker,
                ),
              ),
            ],
          ).animate().fadeIn(),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              _settlementHint(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.45),
                fontFamily: 'Chirp',
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (!ready) ...[
            Icon(
              Icons.qr_code_2_rounded,
              size: 88,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.12),
            ),
            const SizedBox(height: 12),
            Text(
              'No address for this network yet',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.4),
                fontFamily: 'Chirp',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pick the other network or refresh after funding is enabled.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                height: 1.3,
                fontFamily: 'Chirp',
              ),
            ),
          ] else ...[
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: address,
                  version: QrVersions.auto,
                  size: 210,
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  dataModuleStyle: QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  backgroundColor: Theme.of(context).colorScheme.surface,
                ),
              ),
            ).animate().fadeIn(delay: 80.ms),
            const SizedBox(height: 14),
            Text(
              networkLabel,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 13.5,
                fontFamily: 'Chirp',
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _copy(address),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  _shortAddress(address),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Chirp',
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 120.ms),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _share(address),
                    icon: const Icon(Icons.ios_share, size: 18),
                    label: const Text('Share'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _copy(address),
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Copy'),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 140.ms),
          ],
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0.5,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new, size: 18),
        ),
        title: Text(
          'Via digital dollar',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontFamily: 'FunnelDisplay',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child:
            _loading && _phase == _ReceivePhase.loading
                ? const Center(child: CircularProgressIndicator())
                : switch (_phase) {
                  _ReceivePhase.intro => _introBody(),
                  _ReceivePhase.provisioning => _provisioningBody(),
                  _ReceivePhase.awaitingAddresses => _awaitingAddressesBody(),
                  _ReceivePhase.error => _errorBody(),
                  _ReceivePhase.main => _mainBody(),
                  _ReceivePhase.loading => const Center(
                    child: CircularProgressIndicator(),
                  ),
                },
      ),
    );
  }
}

class _ProvisionRow {
  final int index;
  final String label;
  final bool done;

  _ProvisionRow({
    required this.index,
    required this.label,
    required this.done,
  });
}
