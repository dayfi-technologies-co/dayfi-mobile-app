import 'package:dayfi/app_locator.dart';
import 'package:dayfi/common/utils/haptic_helper.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/profile/vm/profile_viewmodel.dart';
import 'package:dayfi/features/send/views/send_review_view.dart';
import 'package:dayfi/features/send/vm/transaction_pin_viewmodel.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/services/remote/payment_service.dart';
import 'package:dayfi/services/remote/wallet_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// On-chain send (USDC / EURC on Stellar + Ethereum), aligned with dayfi.wallet SendScreen.
class WalletCryptoSendView extends ConsumerStatefulWidget {
  final Map<String, dynamic> selectedData;

  const WalletCryptoSendView({super.key, required this.selectedData});

  @override
  ConsumerState<WalletCryptoSendView> createState() =>
      _WalletCryptoSendViewState();
}

class _WalletCryptoSendViewState extends ConsumerState<WalletCryptoSendView> {
  final _toController = TextEditingController();
  final _amountController = TextEditingController();
  final _memoController = TextEditingController();
  final _isProcessingPinNotifier = ValueNotifier<bool>(false);

  String _asset = 'USDC';
  String _networkKey = 'stellar';
  bool _configLoading = true;
  bool _balancesLoading = true;
  bool _sending = false;
  String? _amountError;
  Map<String, dynamic>? _assetsMap;
  List<Map<String, dynamic>> _networks = [];
  Map<String, dynamic> _balances = {
    'stellar': <String, dynamic>{},
    'ethereum': <String, dynamic>{},
  };

  static const _assetMeta = {
    'USDC': (emoji: '💵', label: 'USDC'),
    'EURC': (emoji: '💶', label: 'EURC'),
  };

  @override
  void initState() {
    super.initState();
    final receive =
        widget.selectedData['receiveCurrency']?.toString().toUpperCase() ??
        widget.selectedData['debitCurrency']?.toString().toUpperCase() ??
        'USD';
    _asset = receive == 'EUR' ? 'EURC' : 'USDC';
    _amountController.addListener(_validateAmount);
    _toController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSendConfig();
      _loadBalances();
    });
  }

  @override
  void dispose() {
    _toController.dispose();
    _amountController.dispose();
    _memoController.dispose();
    _isProcessingPinNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadSendConfig() async {
    try {
      final config = await locator<PaymentService>().fetchCryptoSendConfig();
      if (!mounted) return;
      setState(() {
        _networks = (config['networks'] as List<dynamic>? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        _assetsMap = config['assets'] as Map<String, dynamic>? ??
            {'USDC': ['stellar', 'ethereum'], 'EURC': ['stellar', 'ethereum']};
        _applyDefaults();
        _configLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _networks = [
          {'key': 'stellar', 'name': 'Stellar', 'assets': ['USDC', 'EURC']},
          {'key': 'ethereum', 'name': 'Ethereum', 'assets': ['USDC', 'EURC']},
        ];
        _assetsMap = {
          'USDC': ['stellar', 'ethereum'],
          'EURC': ['stellar', 'ethereum'],
        };
        _configLoading = false;
      });
    }
  }

  Future<void> _loadBalances() async {
    setState(() => _balancesLoading = true);
    try {
      final b = await walletService.fetchCryptoBalances();
      if (mounted) setState(() => _balances = b);
    } catch (_) {
      /* show zero balances */
    } finally {
      if (mounted) setState(() => _balancesLoading = false);
    }
  }

  void _applyDefaults() {
    final nets = _networksForAsset(_asset);
    if (nets.isNotEmpty && !nets.contains(_networkKey)) {
      _networkKey = nets.first;
    }
  }

  List<String> _networksForAsset(String code) {
    final raw = _assetsMap?[code];
    if (raw is List) return raw.map((e) => e.toString()).toList();
    return ['stellar'];
  }

  List<String> get _sendableAssets {
    const order = ['USDC', 'EURC'];
    return order.where((c) => _networksForAsset(c).isNotEmpty).toList();
  }

  String _networkLabel(String key) {
    for (final n in _networks) {
      if (n['key'] == key) return n['name']?.toString() ?? key;
    }
    if (key.isEmpty) return key;
    return key[0].toUpperCase() + key.substring(1);
  }

  double _availableBalance() {
    final bucket =
        _networkKey == 'ethereum' ? 'ethereum' : 'stellar';
    final map = _balances[bucket];
    if (map is! Map) return 0;
    final raw = map[_asset]?.toString() ?? '0';
    var bal = double.tryParse(raw) ?? 0;
    if (_networkKey == 'stellar' && _asset == 'XLM') {
      bal = (bal - 2.0).clamp(0.0, double.infinity);
    }
    if (_networkKey == 'ethereum') {
      bal = (bal - 0.0001).clamp(0.0, double.infinity);
    }
    return bal;
  }

  void _validateAmount() {
    final amount = double.tryParse(_amountController.text.trim());
    final available = _availableBalance();
    setState(() {
      if (amount == null || _amountController.text.trim().isEmpty) {
        _amountError = null;
      } else if (amount <= 0) {
        _amountError = 'Amount must be greater than 0';
      } else if (amount > available + 0.000001) {
        _amountError = 'Insufficient on-chain balance';
      } else {
        _amountError = null;
      }
    });
  }

  String? _recipientAddress() {
    final raw = _toController.text.trim();
    if (_networkKey == 'stellar') {
      if (RegExp(r'^G[A-Z0-9]{55}$').hasMatch(raw)) return raw;
      return null;
    }
    if (_networkKey == 'ethereum') {
      if (RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(raw)) return raw;
      return null;
    }
    return raw.isNotEmpty ? raw : null;
  }

  bool get _canSend {
    if (_configLoading || _sending || _amountError != null) return false;
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) return false;
    if (_recipientAddress() == null) return false;
    return _networksForAsset(_asset).contains(_networkKey);
  }

  String get _recipientHint {
    if (_networkKey == 'stellar') {
      return 'Stellar address (G…)';
    }
    if (_networkKey == 'ethereum') {
      return 'Ethereum address (0x…)';
    }
    return 'Wallet address';
  }

  void _showPickerSheet({
    required String title,
    required List<Widget> children,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.onSurface.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleMedium.copyWith(
                      fontFamily: 'FunnelDisplay',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  void _showAssetPicker() {
    _showPickerSheet(
      title: 'Choose asset',
      children: _sendableAssets.map((code) {
        final meta = _assetMeta[code]!;
        return _PickerRow(
          leading: Text(meta.emoji, style: const TextStyle(fontSize: 28)),
          title: meta.label,
          subtitle: _networksForAsset(code).map(_networkLabel).join(' · '),
          onTap: () {
            setState(() {
              _asset = code;
              _applyDefaults();
              _amountController.clear();
              _amountError = null;
            });
            _validateAmount();
            Navigator.pop(context);
          },
        );
      }).toList(),
    );
  }

  void _showNetworkPicker() {
    final keys = _networksForAsset(_asset);
    _showPickerSheet(
      title: 'Choose network',
      children: keys.map((key) {
        return _PickerRow(
          title: _networkLabel(key),
          onTap: () {
            setState(() => _networkKey = key);
            _validateAmount();
            Navigator.pop(context);
          },
        );
      }).toList(),
    );
  }

  void _onSendPressed() {
    HapticHelper.mediumImpact();
    final profile = ref.read(profileViewModelProvider).user;
    final hasPin =
        profile?.transactionPin != null &&
        profile!.transactionPin!.isNotEmpty;
    if (!hasPin) {
      appRouter.pushNamed(
        AppRoute.transactionPinCreateView,
        arguments: {'returnRoute': AppRoute.walletCryptoSendView},
      );
      return;
    }
    ref.read(transactionPinProvider.notifier).resetForm();
    _isProcessingPinNotifier.value = false;
    showModalBottomSheet<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (ctx) => ValueListenableBuilder<bool>(
        valueListenable: _isProcessingPinNotifier,
        builder: (_, processing, __) => TransactionPinBottomSheet(
          onPinEntered: _submitSend,
          isProcessing: processing,
        ),
      ),
    );
  }

  Future<void> _submitSend(String pin) async {
    final to = _recipientAddress();
    final amount = _amountController.text.trim();
    if (to == null) {
      TopSnackbar.show(
        context,
        message: 'Enter a valid $_recipientHint',
        isError: true,
      );
      return;
    }

    _isProcessingPinNotifier.value = true;
    setState(() => _sending = true);

    try {
      final response = await locator<PaymentService>().sendCrypto(
        to: to,
        amount: amount,
        asset: _asset,
        network: _networkKey,
        memo: _memoController.text.trim(),
        pin: pin,
      );

      if (!mounted) return;
      Navigator.of(context).pop();

      if (response.success) {
        final hash = response.hash ?? '';
        appRouter.pushNamedAndRemoveUntil(
          AppRoute.sendPaymentSuccessView,
          (route) => false,
          arguments: {
            'recipientData': {
              'name': to.length > 16 ? '${to.substring(0, 12)}…' : to,
            },
            'selectedData': {
              ...widget.selectedData,
              'cryptoAsset': _asset,
              'cryptoNetwork': _networkKey,
              'sendAmount': amount,
            },
            'paymentData': {'hash': hash},
            'transactionId': hash,
          },
        );
      } else {
        TopSnackbar.show(
          context,
          message: response.message.isNotEmpty
              ? response.message
              : 'Could not complete crypto send',
          isError: true,
        );
        ref.read(transactionPinProvider.notifier).resetForm();
      }
    } catch (e) {
      if (mounted) {
        TopSnackbar.show(
          context,
          message: e.toString().replaceFirst('Exception: ', ''),
          isError: true,
        );
        ref.read(transactionPinProvider.notifier).resetForm();
      }
    } finally {
      _isProcessingPinNotifier.value = false;
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final assetLabel = _assetMeta[_asset]?.label ?? _asset;
    final available = _availableBalance();
    final onSurface = Theme.of(context).colorScheme.onSurface;

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
            color: onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Send crypto',
          style: AppTypography.titleMedium.copyWith(
            fontFamily: 'FunnelDisplay',
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Send $assetLabel',
                  style: AppTypography.headlineSmall.copyWith(
                    fontFamily: 'FunnelDisplay',
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Send from your custodial wallet on Stellar or Ethereum.\nOnly send $assetLabel on the network you select.',
                  style: AppTypography.bodySmall.copyWith(
                    color: onSurface.withOpacity(0.55),
                    height: 1.35,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              if (_configLoading)
                const Center(child: CircularProgressIndicator(strokeWidth: 2))
              else
                Row(
                  children: [
                    Expanded(
                      child: _DropdownField(
                        label: _assetMeta[_asset]?.emoji ?? '●',
                        value: assetLabel,
                        onTap: _showAssetPicker,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _DropdownField(
                        label: '⛓',
                        value: _networkLabel(_networkKey),
                        onTap: _showNetworkPicker,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  'via $assetLabel on ${_networkLabel(_networkKey)}',
                  style: TextStyle(
                    fontFamily: 'Chirp',
                    fontSize: 12,
                    color: onSurface.withOpacity(0.45),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _filledField(
                controller: _toController,
                hint: _recipientHint,
                autocorrect: false,
              ),
              const SizedBox(height: 16),
              _filledField(
                controller: _amountController,
                hint: 'Amount',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                suffix: Text(
                  assetLabel,
                  style: TextStyle(
                    fontFamily: 'Chirp',
                    fontWeight: FontWeight.w600,
                    color: onSurface.withOpacity(0.7),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () {
                  final max = _availableBalance();
                  _amountController.text = max.toStringAsFixed(2);
                  _validateAmount();
                },
                child: Center(
                  child: _balancesLoading
                      ? Text(
                          'Loading balance…',
                          style: TextStyle(
                            fontFamily: 'Chirp',
                            fontSize: 12,
                            color: onSurface.withOpacity(0.45),
                          ),
                        )
                      : Text(
                          'Available: ${available.toStringAsFixed(2)} $assetLabel',
                          style: TextStyle(
                            fontFamily: 'Chirp',
                            fontSize: 12,
                            color: onSurface.withOpacity(0.5),
                          ),
                        ),
                ),
              ),
              if (_amountError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    _amountError!,
                    style: const TextStyle(
                      fontFamily: 'Chirp',
                      fontSize: 12,
                      color: AppColors.orange500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (_networkKey == 'stellar') ...[
                const SizedBox(height: 16),
                _filledField(
                  controller: _memoController,
                  hint: 'Memo (optional, max 28 chars)',
                  maxLength: 28,
                ),
              ],
              const SizedBox(height: 8),
              _InfoBanner(
                text: _networkKey == 'ethereum'
                    ? 'You need a small amount of ETH on this address for gas fees.'
                    : 'Keep at least 2 XLM on Stellar for network fees and trustlines.',
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _canSend && !_sending ? _onSendPressed : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    disabledBackgroundColor:
                        onSurface.withOpacity(0.12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _sending
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Send',
                          style: AppTypography.labelLarge.copyWith(
                            color: Colors.white,
                            fontFamily: 'Chirp',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filledField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    Widget? suffix,
    bool autocorrect = true,
    int? maxLength,
  }) {
    final fill = Theme.of(context).colorScheme.surface;
    return TextField(
      controller: controller,
      autocorrect: autocorrect,
      keyboardType: keyboardType,
      maxLength: maxLength,
      style: AppTypography.bodyMedium.copyWith(
        fontFamily: 'Chirp',
        fontSize: 15,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: 'Chirp',
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35),
        ),
        filled: true,
        fillColor: fill,
        counterText: maxLength != null ? '' : null,
        suffixIcon: suffix != null
            ? Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Center(widthFactor: 0, child: suffix),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              Text(label, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Chirp',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _PickerRow({
    this.leading,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 12)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Chirp',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontFamily: 'Chirp',
                        fontSize: 13,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final String text;

  const _InfoBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary50.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary200.withOpacity(0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primary600),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Chirp',
                fontSize: 12.5,
                height: 1.35,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.75),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
