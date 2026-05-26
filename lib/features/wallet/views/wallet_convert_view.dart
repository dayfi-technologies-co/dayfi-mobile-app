import 'package:dayfi/common/constants/wallet_flag_assets.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/common/widgets/text_fields/pin_text_field.dart';
import 'package:dayfi/core/theme/app_typography.dart';
import 'package:dayfi/features/wallet/providers/wallet_hub_provider.dart';
import 'package:dayfi/app_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WalletConvertView extends ConsumerStatefulWidget {
  const WalletConvertView({super.key});

  @override
  ConsumerState<WalletConvertView> createState() => _WalletConvertViewState();
}

class _WalletConvertViewState extends ConsumerState<WalletConvertView> {
  final _amountController = TextEditingController();
  String _fromCurrency = 'USD';
  String _toCurrency = 'NGN';
  double? _rate;
  bool _loadingRate = false;
  bool _swapping = false;

  final Map<String, String> _symbols = {
    'USD': r'$',
    'NGN': '₦',
    'GBP': '£',
    'EUR': '€',
  };

  final List<String> _currencies = ['USD', 'GBP', 'EUR', 'NGN'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(walletHubProvider.notifier).load();
      _loadRate();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get _inputAmount =>
      double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;

  double get _outputAmount => _inputAmount * (_rate ?? 0);

  Future<void> _loadRate() async {
    if (_fromCurrency == _toCurrency) return;
    setState(() => _loadingRate = true);
    try {
      final rate = await walletService.fetchExchangeRate(
        fromCurrency: _fromCurrency,
        toCurrency: _toCurrency,
      );
      if (mounted) setState(() => _rate = rate);
    } catch (_) {
      if (mounted) setState(() => _rate = null);
    } finally {
      if (mounted) setState(() => _loadingRate = false);
    }
  }

  void _swapCurrencies() {
    setState(() {
      final tmp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = tmp;
      _amountController.clear();
      _rate = null;
    });
    _loadRate();
  }

  Future<String?> _promptPin() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm with PIN', style: TextStyle(fontFamily: 'Chirp')),
        content: PinTextField(
          controller: controller,
          onCompleted: (pin) => Navigator.pop(ctx, pin),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _onConvert() async {
    if (_inputAmount <= 0 || _rate == null) return;

    final hub = ref.read(walletHubProvider).hub;
    final fromRow = hub?.rowFor(_fromCurrency);
    if (fromRow != null && fromRow.balance < _inputAmount) {
      TopSnackbar.show(context, message: 'Insufficient balance', isError: true);
      return;
    }

    final pin = await _promptPin();
    if (pin == null || pin.length < 4) return;

    setState(() => _swapping = true);
    try {
      await walletService.ensureLedgerWallet(_fromCurrency);
      await walletService.ensureLedgerWallet(_toCurrency);
      await walletService.swapWallets(
        fromCurrency: _fromCurrency,
        toCurrency: _toCurrency,
        amount: _inputAmount,
        pin: pin,
      );
      await ref.read(walletHubProvider.notifier).refresh();
      if (!mounted) return;
      TopSnackbar.show(
        context,
        message:
            'Converted ${_symbols[_fromCurrency]}${_formatNumber(_inputAmount)} to ${_symbols[_toCurrency]}${_formatNumber(_outputAmount)}',
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        TopSnackbar.show(
          context,
          message: e.toString().replaceFirst('Exception: ', ''),
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _swapping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Convert',
          style: AppTypography.titleMedium.copyWith(
            fontFamily: 'FunnelDisplay',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ConvertCard(
              label: 'From',
              currency: _fromCurrency,
              currencies: _currencies.where((c) => c != _toCurrency).toList(),
              symbol: _symbols[_fromCurrency]!,
              controller: _amountController,
              onCurrencyChanged: (c) {
                setState(() => _fromCurrency = c);
                _loadRate();
              },
              editable: true,
              onChanged: (_) => setState(() {}),
            ),
            Center(
              child: GestureDetector(
                onTap: _swapCurrencies,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withOpacity(0.1),
                    ),
                  ),
                  child: Icon(
                    Icons.swap_vert_rounded,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            _ConvertCard(
              label: 'To',
              currency: _toCurrency,
              currencies: _currencies.where((c) => c != _fromCurrency).toList(),
              symbol: _symbols[_toCurrency]!,
              displayAmount: _inputAmount > 0 && _rate != null
                  ? '${_symbols[_toCurrency]}${_formatNumber(_outputAmount)}'
                  : null,
              onCurrencyChanged: (c) {
                setState(() => _toCurrency = c);
                _loadRate();
              },
              editable: false,
            ),
            const SizedBox(height: 16),
            if (_loadingRate)
              const Center(child: CircularProgressIndicator(strokeWidth: 2))
            else if (_inputAmount > 0 && _rate != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Exchange rate',
                      style: TextStyle(
                        fontFamily: 'Chirp',
                        fontSize: 13,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                      ),
                    ),
                    Text(
                      '1 $_fromCurrency = ${_symbols[_toCurrency]}${_formatNumber(_rate!)}',
                      style: TextStyle(
                        fontFamily: 'Chirp',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _inputAmount > 0 && _rate != null && !_swapping
                    ? _onConvert
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  disabledBackgroundColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _swapping
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _inputAmount > 0 && _rate != null
                            ? 'Convert ${_symbols[_fromCurrency]}${_formatNumber(_inputAmount)}'
                            : 'Enter an amount',
                        style: const TextStyle(
                          fontFamily: 'Chirp',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(double v) {
    if (v == 0) return '0.00';
    final s = v.toStringAsFixed(2);
    final parts = s.split('.');
    var integer = parts[0];
    final buf = StringBuffer();
    for (var i = 0; i < integer.length; i++) {
      if (i > 0 && (integer.length - i) % 3 == 0) buf.write(',');
      buf.write(integer[i]);
    }
    return '${buf.toString()}.${parts[1]}';
  }
}

class _ConvertCard extends StatelessWidget {
  final String label;
  final String currency;
  final List<String> currencies;
  final String symbol;
  final TextEditingController? controller;
  final String? displayAmount;
  final ValueChanged<String>? onCurrencyChanged;
  final ValueChanged<String>? onChanged;
  final bool editable;

  static const Map<String, String> _flags = {
    'USD': 'assets/icons/svgs/world_flags/united states.svg',
    'GBP': 'assets/icons/svgs/world_flags/united kingdom.svg',
    'EUR': WalletFlagAssets.eur,
    'NGN': 'assets/icons/svgs/world_flags/nigeria.svg',
  };

  const _ConvertCard({
    required this.label,
    required this.currency,
    required this.currencies,
    required this.symbol,
    this.controller,
    this.displayAmount,
    this.onCurrencyChanged,
    this.onChanged,
    this.editable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Chirp',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  final picked = await showModalBottomSheet<String>(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (_) => _CurrencyPickerSheet(
                      currencies: currencies,
                      flags: _flags,
                    ),
                  );
                  if (picked != null) onCurrencyChanged?.call(picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipOval(
                        child: SvgPicture.asset(
                          _flags[currency]!,
                          width: 22,
                          height: 22,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        currency,
                        style: TextStyle(
                          fontFamily: 'Chirp',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: editable
                    ? TextField(
                        controller: controller,
                        onChanged: onChanged,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                        ],
                        style: TextStyle(
                          fontFamily: 'Chirp',
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: '${symbol}0.00',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      )
                    : Text(
                        displayAmount ?? '${symbol}0.00',
                        style: TextStyle(
                          fontFamily: 'Chirp',
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: displayAmount != null
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.3),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CurrencyPickerSheet extends StatelessWidget {
  final List<String> currencies;
  final Map<String, String> flags;

  static const Map<String, String> _names = {
    'USD': 'US Dollar',
    'GBP': 'British Pound',
    'EUR': 'Euro',
    'NGN': 'Nigerian Naira',
  };

  const _CurrencyPickerSheet({
    required this.currencies,
    required this.flags,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Text(
              'Select currency',
              style: TextStyle(
                fontFamily: 'FunnelDisplay',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: List.generate(currencies.length, (i) {
                final c = currencies[i];
                return InkWell(
                  onTap: () => Navigator.pop(context, c),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        ClipOval(
                          child: SvgPicture.asset(
                            flags[c]!,
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _names[c] ?? c,
                            style: const TextStyle(
                              fontFamily: 'Chirp',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(c),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
