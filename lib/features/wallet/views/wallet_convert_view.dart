import 'dart:async';

import 'package:dayfi/common/constants/wallet_flag_assets.dart';
import 'package:dayfi/common/services/feature_activity_service.dart';
import 'package:dayfi/common/helpers/transaction_completion_flow.dart';
import 'package:dayfi/common/helpers/transaction_pin_flow.dart';
import 'package:dayfi/common/widgets/buttons/primary_button.dart';
import 'package:dayfi/common/widgets/dayfi_screen_app_bar.dart';
import 'package:dayfi/common/widgets/top_snackbar.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/routes/route.dart';
import 'package:dayfi/features/wallet/providers/wallet_hub_provider.dart';
import 'package:dayfi/features/transactions/vm/transactions_viewmodel.dart';
import 'package:dayfi/app_locator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/common/widgets/dayfi_loading_indicator.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WalletConvertView extends ConsumerStatefulWidget {
  /// When opened from a wallet detail screen, pre-select this as the "from" wallet.
  final String? initialFromCurrency;

  const WalletConvertView({super.key, this.initialFromCurrency});

  @override
  ConsumerState<WalletConvertView> createState() => _WalletConvertViewState();
}

class _WalletConvertViewState extends ConsumerState<WalletConvertView> {
  final _amountController = TextEditingController();
  late String _fromCurrency;
  late String _toCurrency;
  double? _rate;
  bool _loadingRate = false;
  final bool _swapping = false;
  String? _ratesUpdatedAt;
  Timer? _rateRefreshTimer;

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
    final initial = widget.initialFromCurrency?.toUpperCase();
    if (initial != null && _currencies.contains(initial)) {
      _fromCurrency = initial;
      _toCurrency = _currencies.firstWhere(
        (c) => c != initial,
        orElse: () => initial == 'NGN' ? 'USD' : 'NGN',
      );
    } else {
      _fromCurrency = 'USD';
      _toCurrency = 'NGN';
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(walletHubProvider.notifier).load();
      _loadRate();
    });
    _rateRefreshTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _loadRate(silent: true),
    );
  }

  @override
  void dispose() {
    _rateRefreshTimer?.cancel();
    _amountController.dispose();
    super.dispose();
  }

  double get _inputAmount =>
      double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;

  double get _outputAmount => _inputAmount * (_rate ?? 0);

  Future<void> _loadRate({bool silent = false}) async {
    if (_fromCurrency == _toCurrency) return;
    if (!silent) setState(() => _loadingRate = true);
    try {
      final rate = await walletService.fetchExchangeRate(
        fromCurrency: _fromCurrency,
        toCurrency: _toCurrency,
      );
      if (mounted) {
        setState(() {
          _rate = rate;
          _ratesUpdatedAt = DateTime.now().toIso8601String();
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _rate = null);
        if (!silent) {
          TopSnackbar.showSafe(
            context,
            message: 'Rate unavailable for this pair',
            isError: true,
          );
        }
      }
    } finally {
      if (mounted && !silent) setState(() => _loadingRate = false);
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

  Future<void> _onConvert() async {
    if (_inputAmount <= 0 || _rate == null) return;

    final hub = ref.read(walletHubProvider).hub;
    final fromRow = hub?.rowFor(_fromCurrency);
    if (fromRow != null && fromRow.balance < _inputAmount) {
      TopSnackbar.showSafe(
        context,
        message: 'Insufficient balance',
        isError: true,
      );
      return;
    }

    final ok = await TransactionPinFlow.requestPinAndRun<bool>(
      context: context,
      ref: ref,
      returnRoute: AppRoute.walletConvertView,
      task: (pin) async {
        await walletService.ensureLedgerWallet(_fromCurrency);
        await walletService.ensureLedgerWallet(_toCurrency);
        await walletService.swapWallets(
          fromCurrency: _fromCurrency,
          toCurrency: _toCurrency,
          amount: _inputAmount,
          pin: pin,
        );
        await ref.read(walletHubProvider.notifier).refresh();
        FeatureActivityService.instance.invalidate();
        await ref.read(transactionsProvider.notifier).loadTransactions();
        return true;
      },
    );
    if (ok != true || !mounted) return;

    await TransactionCompletionFlow.pushSuccess(
      context,
      screen: TransactionCompletionFlow.swapSuccess(
        fromSymbol: _symbols[_fromCurrency]!,
        toSymbol: _symbols[_toCurrency]!,
        fromAmount: _formatNumber(_inputAmount),
        toAmount: _formatNumber(_outputAmount),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canConvert = _inputAmount > 0 && _rate != null && !_swapping;

    return DayfiFeatureScaffold(
      title: 'Swap money',
      body: LayoutBuilder(
        builder: (context, constraints) {
          final fieldWidth = constraints.maxWidth - 36;
          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              CupertinoSliverRefreshControl(onRefresh: () => _loadRate()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ConvertCard(
                        label: 'From',
                        currency: _fromCurrency,
                        currencies:
                            _currencies.where((c) => c != _toCurrency).toList(),
                        symbol: _symbols[_fromCurrency]!,
                        fieldWidth: fieldWidth,
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
                                color: Theme.of(
                                  context,
                                ).dividerColor.withOpacity(0.1),
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
                        currencies:
                            _currencies
                                .where((c) => c != _fromCurrency)
                                .toList(),
                        symbol: _symbols[_toCurrency]!,
                        fieldWidth: fieldWidth,
                        displayAmount:
                            _rate != null && _inputAmount > 0
                                ? '${_symbols[_toCurrency]}${_formatNumber(_outputAmount)}'
                                : null,
                        onCurrencyChanged: (c) {
                          setState(() => _toCurrency = c);
                          _loadRate();
                        },
                        editable: false,
                      ),
                      const SizedBox(height: 8),
                      if (_loadingRate)
                        const DayfiLoadingCenter()
                      else if (_rate != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          // decoration: BoxDecoration(
                          //   color: Theme.of(context).colorScheme.surface,
                          //   borderRadius: BorderRadius.circular(10),
                          // ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Exchange rate',
                                    style: TextStyle(
                                      fontFamily: 'Chirp',
                                      fontSize: 13,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.5),
                                    ),
                                  ),
                                  Text(
                                    '1 $_fromCurrency = ${_symbols[_toCurrency]}${_formatNumber(_rate!)}',
                                    style: TextStyle(
                                      fontFamily: 'Chirp',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              // const SizedBox(height: 4),
                              // Text(
                              //   'Live rate · pull down to refresh',
                              //   style: TextStyle(
                              //     fontFamily: 'Chirp',
                              //     fontSize: 11,
                              //     color: Theme.of(
                              //       context,
                              //     ).colorScheme.onSurface.withOpacity(0.4),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: PrimaryButton(
                          text:
                              canConvert
                                  ? 'Swap ${_symbols[_fromCurrency]}${_formatNumber(_inputAmount)}'
                                  : 'Enter an amount',
                          onPressed: canConvert ? _onConvert : null,
                          enabled: canConvert,
                          isLoading: _swapping,
                          fullWidth: true,
                          borderRadius: 38,
                          height: 48,
                          backgroundColor: AppColors.purple500ForTheme(context),
                          textColor: AppColors.neutral0,
                          fontFamily: 'Chirp',
                          letterSpacing: -.2,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
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
  final double fieldWidth;
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
    this.fieldWidth = 360,
    this.controller,
    this.displayAmount,
    this.onCurrencyChanged,
    this.onChanged,
    this.editable = false,
  });

  static TextStyle _amountTextStyle(
    BuildContext context, {
    bool faint = false,
  }) {
    return TextStyle(
      fontFamily: 'FunnelDisplay',
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.15,
      color:
          faint
              ? Theme.of(context).colorScheme.onSurface.withOpacity(0.3)
              : Theme.of(context).colorScheme.onSurface,
    );
  }

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
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              GestureDetector(
                onTap: () async {
                  final picked = await showModalBottomSheet<String>(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder:
                        (_) => _CurrencyPickerSheet(
                          currencies: currencies,
                          flags: _flags,
                        ),
                  );
                  if (picked != null) onCurrencyChanged?.call(picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.06),
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
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (editable)
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
                    style: _amountTextStyle(context),
                    cursorColor: AppColors.purple400,
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      fillColor: Colors.transparent,
                      contentPadding: EdgeInsets.zero,
                      prefixText: symbol,
                      prefixStyle: _amountTextStyle(context),
                      hintText: '0.00',
                      hintStyle: _amountTextStyle(context, faint: true),
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    Text(
                      displayAmount ?? '${symbol}0.00',
                      style: _amountTextStyle(
                        context,
                        faint: displayAmount == null,
                      ),
                    ),
                  ],
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

  const _CurrencyPickerSheet({required this.currencies, required this.flags});

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
